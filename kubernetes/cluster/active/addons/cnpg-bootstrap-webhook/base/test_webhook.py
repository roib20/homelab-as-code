import base64
import binascii
import importlib.util
import json
import threading
import unittest
from http.client import HTTPConnection
from http.server import ThreadingHTTPServer
from io import StringIO
from pathlib import Path
from unittest import mock

SPEC = importlib.util.spec_from_file_location("webhook", Path(__file__).with_name("webhook.py"))
webhook = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(webhook)


def cluster(annotated=True, external_clusters=None):
    annotations = {webhook.ANNOTATION: "example-postgres"} if annotated else {}
    spec = {
        "bootstrap": {"initdb": {"database": "app", "owner": "app"}},
        "plugins": [
            {
                "name": "barman-cloud.cloudnative-pg.io",
                "parameters": {"barmanObjectName": "cnpg-backups"},
            }
        ],
    }
    if external_clusters is not None:
        spec["externalClusters"] = external_clusters
    return {"metadata": {"namespace": "default", "annotations": annotations}, "spec": spec}


class RecoveryPatchTests(unittest.TestCase):
    def setUp(self):
        self.object_store = {"spec": {"configuration": {"s3Credentials": {}, "destinationPath": "s3://backups"}}}

    def test_unannotated_cluster_is_unchanged(self):
        self.assertEqual(webhook.recovery_patch(cluster(annotated=False)), [])

    @mock.patch.object(webhook, "completed_backups", return_value=False)
    @mock.patch.object(webhook, "request")
    def test_initdb_is_kept_without_backup(self, request, _completed_backups):
        request.return_value = (200, self.object_store)
        self.assertEqual(webhook.recovery_patch(cluster()), [])

    @mock.patch.object(webhook, "completed_backups", return_value=True)
    @mock.patch.object(webhook, "request")
    def test_recovery_preserves_existing_external_clusters(self, request, _completed_backups):
        request.return_value = (200, self.object_store)
        patch = webhook.recovery_patch(cluster(external_clusters=[{"name": "existing"}]))
        self.assertEqual(patch[0]["value"]["recovery"]["source"], "clusterBackup")
        self.assertEqual(patch[1]["path"], "/spec/externalClusters/-")

    @mock.patch.object(webhook, "completed_backups", return_value=True)
    @mock.patch.object(webhook, "request")
    def test_recovery_rejects_source_name_collision(self, request, _completed_backups):
        request.return_value = (200, self.object_store)
        with self.assertRaisesRegex(ValueError, "already contains clusterBackup"):
            webhook.recovery_patch(cluster(external_clusters=[{"name": "clusterBackup"}]))

    @mock.patch.object(webhook, "request", return_value=(404, None))
    def test_missing_object_store_is_rejected(self, _request):
        with self.assertRaisesRegex(RuntimeError, "ObjectStore cnpg-backups is unavailable"):
            webhook.recovery_patch(cluster())


class BarmanTests(unittest.TestCase):
    @mock.patch.object(webhook, "secret_value", return_value="value")
    @mock.patch.object(webhook.subprocess, "run")
    def test_malformed_catalog_is_rejected(self, run, _secret_value):
        run.return_value = mock.Mock(returncode=0, stdout=json.dumps([]))
        object_store = {
            "spec": {
                "configuration": {
                    "destinationPath": "s3://backups",
                    "s3Credentials": {
                        "region": {},
                        "accessKeyId": {},
                        "secretAccessKey": {},
                    },
                }
            }
        }
        with self.assertRaisesRegex(TypeError, "unexpected response"):
            webhook.completed_backups("default", object_store, "example-postgres")
        self.assertEqual(run.call_args.kwargs["timeout"], webhook.BARMAN_TIMEOUT)

    @mock.patch.object(webhook, "secret_value", return_value="value")
    @mock.patch.object(webhook.subprocess, "run")
    def test_completed_backups_accepts_done_entry(self, run, _secret_value):
        run.return_value = mock.Mock(returncode=0, stdout=json.dumps({"backups_list": [{"status": "DONE"}]}))
        object_store = {
            "spec": {
                "configuration": {
                    "destinationPath": "s3://backups",
                    "s3Credentials": {"region": {}, "accessKeyId": {}, "secretAccessKey": {}},
                }
            }
        }
        self.assertTrue(webhook.completed_backups("default", object_store, "example-postgres"))

    @mock.patch.object(webhook, "secret_value", side_effect=["region", "access", "password"])
    @mock.patch.object(webhook.subprocess, "run")
    def test_barman_failure_includes_sanitized_stderr(self, run, _secret_value):
        run.return_value = mock.Mock(returncode=1, stdout="", stderr="  password failed\nwith details ")
        object_store = {
            "spec": {
                "configuration": {
                    "destinationPath": "s3://backups",
                    "s3Credentials": {"region": {}, "accessKeyId": {}, "secretAccessKey": {}},
                }
            }
        }
        with self.assertRaisesRegex(RuntimeError, r"Barman catalog query failed: \[redacted\] failed with details"):
            webhook.completed_backups("default", object_store, "server")

    @mock.patch.object(webhook, "request")
    def test_invalid_secret_encoding_is_rejected(self, request):
        request.return_value = (200, {"data": {"key": "not base64"}})
        with self.assertRaises(binascii.Error):
            webhook.secret_value("default", {"name": "secret", "key": "key"})

    @mock.patch.object(webhook, "request")
    def test_secret_value_decodes_utf8(self, request):
        value = base64.b64encode(b"secret").decode()
        request.return_value = (200, {"data": {"key": value}})
        self.assertEqual(webhook.secret_value("default", {"name": "secret", "key": "key"}), "secret")

    @mock.patch.object(webhook, "request")
    def test_secret_reads_are_cached(self, request):
        first = base64.b64encode(b"first").decode()
        second = base64.b64encode(b"second").decode()
        request.return_value = (200, {"data": {"first": first, "second": second}})
        cache = {}

        self.assertEqual(webhook.secret_value("default", {"name": "secret", "key": "first"}, cache), "first")
        self.assertEqual(webhook.secret_value("default", {"name": "secret", "key": "second"}, cache), "second")
        request.assert_called_once()


class HTTPTests(unittest.TestCase):
    def setUp(self):
        self.server = ThreadingHTTPServer(("127.0.0.1", 0), webhook.Webhook)
        self.thread = threading.Thread(target=self.server.serve_forever)
        self.thread.start()

    def tearDown(self):
        self.server.shutdown()
        self.thread.join()
        self.server.server_close()

    def post(self, value, path="/mutate", content_type="application/json"):
        connection = HTTPConnection(*self.server.server_address)
        body = value if isinstance(value, bytes) else json.dumps(value).encode()
        connection.request("POST", path, body, {"Content-Type": content_type})
        response = connection.getresponse()
        result = response.status, json.loads(response.read()) if response.getheader("Content-Type") == "application/json" else None
        connection.close()
        return result

    @mock.patch.object(webhook, "recovery_patch", return_value=[{"op": "add", "path": "/spec/x", "value": 1}])
    def test_allowed_mutation_returns_encoded_patch(self, recovery_patch):
        status, review = self.post(
            {
                "apiVersion": "admission.k8s.io/v1",
                "kind": "AdmissionReview",
                "request": {
                    "uid": "request-1",
                    "operation": "CREATE",
                    "resource": {"group": "postgresql.cnpg.io", "version": "v1", "resource": "clusters"},
                    "object": {},
                },
            }
        )
        self.assertEqual(status, 200)
        self.assertEqual(review["response"]["uid"], "request-1")
        self.assertEqual(json.loads(base64.b64decode(review["response"]["patch"])), recovery_patch.return_value)

    def test_malformed_request_is_denied_and_logged(self):
        with mock.patch("sys.stderr", new_callable=StringIO) as stderr:
            status, review = self.post({"apiVersion": "admission.k8s.io/v1", "kind": "AdmissionReview"})
        self.assertEqual(status, 200)
        self.assertFalse(review["response"]["allowed"])
        self.assertIn('"level": "error"', stderr.getvalue())

    @mock.patch.object(webhook, "recovery_patch", side_effect=RuntimeError("recovery failed"))
    def test_recovery_failure_denies_valid_review(self, _recovery_patch):
        with mock.patch("sys.stderr", new_callable=StringIO) as stderr:
            status, review = self.post(
                {
                    "apiVersion": "admission.k8s.io/v1",
                    "kind": "AdmissionReview",
                    "request": {
                        "uid": "request-2",
                        "operation": "CREATE",
                        "resource": {"group": "postgresql.cnpg.io", "version": "v1", "resource": "clusters"},
                        "object": {},
                    },
                }
            )
        self.assertEqual(status, 200)
        self.assertFalse(review["response"]["allowed"])
        self.assertEqual(review["response"]["uid"], "request-2")
        self.assertIn("recovery failed", stderr.getvalue())

    def test_wrong_path_is_rejected(self):
        status, _ = self.post({}, "/wrong")
        self.assertEqual(status, 404)

    def test_wrong_content_type_is_denied(self):
        with mock.patch("sys.stderr", new_callable=StringIO):
            status, review = self.post({}, content_type="text/plain")
        self.assertEqual(status, 415)
        self.assertFalse(review["response"]["allowed"])


if __name__ == "__main__":
    unittest.main()
