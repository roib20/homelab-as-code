import base64
import binascii
import json
import os
import ssl
import subprocess
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

API = "https://kubernetes.default.svc"
TOKEN_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/token"
CA_PATH = "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
ANNOTATION = "postgresql.cnpg.homelab.towerofkubes.com/barman-server-name"
API_TIMEOUT = 3
BARMAN_TIMEOUT = 8


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


def secret_value(namespace, selector):
    status, secret = request(f"/api/v1/namespaces/{namespace}/secrets/{selector['name']}")
    if status != 200:
        raise RuntimeError(f"Secret {selector['name']} is unavailable")
    value = secret.get("data", {}).get(selector["key"])
    if value is None:
        raise RuntimeError(f"Secret {selector['name']} has no key {selector['key']}")
    return base64.b64decode(value, validate=True).decode()


def completed_backups(namespace, object_store, server_name):
    configuration = object_store["spec"]["configuration"]
    credentials = configuration["s3Credentials"]
    region = secret_value(namespace, credentials["region"])
    env = os.environ.copy()
    env.update(
        {
            "AWS_ACCESS_KEY_ID": secret_value(namespace, credentials["accessKeyId"]),
            "AWS_SECRET_ACCESS_KEY": secret_value(namespace, credentials["secretAccessKey"]),
            "AWS_DEFAULT_REGION": region,
            "AWS_REGION": region,
        }
    )
    command = ["barman-cloud-backup-list", "--cloud-provider", "aws-s3", "--format", "json"]
    for item in object_store["spec"].get("instanceSidecarConfiguration", {}).get("env", []):
        if item.get("name") == "AWS_ENDPOINT_URL" and "valueFrom" in item:
            endpoint = secret_value(namespace, item["valueFrom"]["secretKeyRef"])
            command.extend(["--endpoint-url", endpoint])
    command.extend([configuration["destinationPath"], server_name])
    result = subprocess.run(command, env=env, capture_output=True, text=True, timeout=BARMAN_TIMEOUT, check=False)
    if result.returncode != 0:
        raise RuntimeError("Barman catalog query failed")
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
    def do_GET(self):
        status = 200 if self.path == "/healthz" else 404
        self.send_response(status)
        self.end_headers()

    def do_POST(self):
        review = {}
        try:
            review = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
            request_data = review["request"]
            patch = recovery_patch(request_data["object"])
            response = {"uid": request_data["uid"], "allowed": True}
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
            json.JSONDecodeError,
            subprocess.SubprocessError,
        ) as error:
            response = {"uid": review.get("request", {}).get("uid", ""), "allowed": False, "status": {"message": str(error)}}
        body = json.dumps({"apiVersion": "admission.k8s.io/v1", "kind": "AdmissionReview", "response": response}).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

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
