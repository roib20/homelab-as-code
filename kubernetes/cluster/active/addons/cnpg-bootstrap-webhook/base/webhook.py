import base64
import binascii
import json
import os
import ssl
import subprocess
import sys
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

API = "https://kubernetes.default.svc"
TOKEN_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/token"
CA_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
ANNOTATION = "postgresql.cnpg.homelab.towerofkubes.com/barman-server-name"
API_TIMEOUT = 3
BARMAN_TIMEOUT = 8
MAX_BODY_SIZE = 1024 * 1024
CNPG_GROUP = "postgresql.cnpg.io"


def request(path):
    with open(TOKEN_PATH, encoding="utf-8") as stream:
        token = stream.read().strip()
    req = urllib.request.Request(API + path, headers={"Authorization": f"Bearer {token}"})
    context = ssl.create_default_context(cafile=CA_PATH)
    try:
        with urllib.request.urlopen(req, context=context, timeout=API_TIMEOUT) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, None


def secret_value(namespace, selector, cache=None):
    name = selector["name"]
    secret = cache.get(name) if cache is not None else None
    if secret is None:
        status, secret = request(f"/api/v1/namespaces/{namespace}/secrets/{name}")
        if status != 200:
            raise RuntimeError(f"Secret {name} is unavailable")
        if cache is not None:
            cache[name] = secret
    value = secret.get("data", {}).get(selector["key"])
    if value is None:
        raise RuntimeError(f"Secret {name} has no key {selector['key']}")
    return base64.b64decode(value, validate=True).decode()


def completed_backups(namespace, object_store, server_name):
    configuration = object_store["spec"]["configuration"]
    credentials = configuration["s3Credentials"]
    secrets = {}
    region = secret_value(namespace, credentials["region"], secrets)
    env = os.environ.copy()
    env.update(
        {
            "AWS_ACCESS_KEY_ID": secret_value(namespace, credentials["accessKeyId"], secrets),
            "AWS_SECRET_ACCESS_KEY": secret_value(namespace, credentials["secretAccessKey"], secrets),
            "AWS_DEFAULT_REGION": region,
            "AWS_REGION": region,
        }
    )
    command = ["barman-cloud-backup-list", "--cloud-provider", "aws-s3", "--format", "json"]
    sensitive = [
        region,
        env["AWS_ACCESS_KEY_ID"],
        env["AWS_SECRET_ACCESS_KEY"],
        configuration["destinationPath"],
    ]
    for item in object_store["spec"].get("instanceSidecarConfiguration", {}).get("env", []):
        if item.get("name") == "AWS_ENDPOINT_URL" and "valueFrom" in item:
            endpoint = secret_value(namespace, item["valueFrom"]["secretKeyRef"], secrets)
            sensitive.append(endpoint)
            command.extend(["--endpoint-url", endpoint])
    command.extend([configuration["destinationPath"], server_name])
    result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=BARMAN_TIMEOUT, check=False)
    if result.returncode != 0:
        detail = " ".join(result.stderr.split())
        for value in sensitive:
            if value:
                detail = detail.replace(value, "[redacted]")
        detail = detail[:512]
        message = "Barman catalog query failed"
        if detail:
            message += f": {detail}"
        raise RuntimeError(message)
    catalog = json.loads(result.stdout)
    entries = catalog.get("backups_list") if isinstance(catalog, dict) else None
    if not isinstance(entries, list):
        raise TypeError("Barman catalog returned an unexpected response")
    return any(isinstance(entry, dict) and entry.get("status") == "DONE" for entry in entries)


def recovery_patch(cluster):
    namespace = cluster["metadata"]["namespace"]
    server_name = cluster["metadata"].get("annotations", {}).get(ANNOTATION)
    if not server_name:
        return []
    initdb = cluster["spec"].get("bootstrap", {}).get("initdb")
    if not isinstance(initdb, dict) or not initdb.get("database") or not initdb.get("owner"):
        raise ValueError("Annotated clusters require bootstrap.initdb database and owner")
    plugin = next(
        (
            item
            for item in cluster["spec"].get("plugins", [])
            if item.get("name") == "barman-cloud.cloudnative-pg.io"
        ),
        None,
    )
    object_store_name = plugin.get("parameters", {}).get("barmanObjectName") if plugin else None
    if not object_store_name:
        raise ValueError("Annotated clusters require the Barman Cloud WAL archiver plugin")
    status, object_store = request(
        f"/apis/barmancloud.cnpg.io/v1/namespaces/{namespace}/objectstores/{object_store_name}"
    )
    if status != 200:
        raise RuntimeError(f"ObjectStore {object_store_name} is unavailable")
    if not completed_backups(namespace, object_store, server_name):
        return []
    external_clusters = cluster["spec"].get("externalClusters", [])
    if not isinstance(external_clusters, list):
        raise TypeError("spec.externalClusters must be a list")
    if any(item.get("name") == "clusterBackup" for item in external_clusters if isinstance(item, dict)):
        raise ValueError("spec.externalClusters already contains clusterBackup")
    external_cluster = {
        "name": "clusterBackup",
        "plugin": {
            "name": "barman-cloud.cloudnative-pg.io",
            "parameters": {
                "barmanObjectName": object_store_name,
                "serverName": server_name,
            },
        },
    }
    patch = [
        {
            "op": "replace",
            "path": "/spec/bootstrap",
            "value": {
                "recovery": {
                    "source": "clusterBackup",
                    "database": initdb["database"],
                    "owner": initdb["owner"],
                }
            },
        },
    ]
    if external_clusters:
        patch.append({"op": "add", "path": "/spec/externalClusters/-", "value": external_cluster})
    else:
        patch.append({"op": "add", "path": "/spec/externalClusters", "value": [external_cluster]})
    return patch


class Webhook(BaseHTTPRequestHandler):
    def _send_review(self, status: int, response: dict[str, Any]) -> None:
        body = json.dumps(
            {"apiVersion": "admission.k8s.io/v1", "kind": "AdmissionReview", "response": response}
        ).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _deny(self, message: str, uid: str = "", status: int = 400) -> None:
        response = {"uid": uid, "allowed": False, "status": {"message": message}}
        print(
            json.dumps({"level": "error", "message": message, "requestUID": uid}),
            file=sys.stderr,
            flush=True,
        )
        self._send_review(status, response)

    def do_GET(self):
        status = 200 if self.path == "/healthz" else 404
        self.send_response(status)
        self.end_headers()

    def do_POST(self):
        if self.path != "/mutate":
            self.send_error(404)
            return
        if self.headers.get_content_type() != "application/json":
            self._deny("Content-Type must be application/json", status=415)
            return
        try:
            length = int(self.headers["Content-Length"])
        except (KeyError, TypeError, ValueError):
            self._deny("Content-Length is required")
            return
        if length < 0 or length > MAX_BODY_SIZE:
            self._deny("request body is too large", status=413)
            return
        review = {}
        review_status = 400
        try:
            review = json.loads(self.rfile.read(length))
            if not isinstance(review, dict) or review.get("apiVersion") != "admission.k8s.io/v1" or review.get("kind") != "AdmissionReview":
                raise ValueError("request must be an AdmissionReview v1")
            review_status = 200
            request_data = review["request"]
            if not isinstance(request_data, dict):
                raise TypeError("AdmissionReview request is required")
            uid = request_data.get("uid", "")
            if not isinstance(uid, str) or not uid:
                raise ValueError("request uid is required")
            if request_data.get("operation") != "CREATE":
                raise ValueError("only CREATE requests are supported")
            resource = request_data.get("resource", {})
            if resource != {"group": CNPG_GROUP, "version": "v1", "resource": "clusters"}:
                raise ValueError("request is not a CloudNativePG Cluster")
            patch = recovery_patch(request_data["object"])
            response = {"uid": uid, "allowed": True}
            if patch:
                response["patchType"] = "JSONPatch"
                response["patch"] = base64.b64encode(json.dumps(patch).encode()).decode()
        except (
            binascii.Error,
            KeyError,
            OSError,
            RuntimeError,
            TypeError,
            UnicodeError,
            ValueError,
            subprocess.SubprocessError,
        ) as error:
            uid = review.get("request", {}).get("uid", "") if isinstance(review, dict) and isinstance(review.get("request"), dict) else ""
            self._deny(str(error), uid, review_status)
            return
        self._send_review(200, response)

    def log_message(self, _format, *_args):
        return


def main():
    server = ThreadingHTTPServer(("", 8443), Webhook)
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain("/tls/tls.crt", "/tls/tls.key")
    server.socket = context.wrap_socket(server.socket, server_side=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
