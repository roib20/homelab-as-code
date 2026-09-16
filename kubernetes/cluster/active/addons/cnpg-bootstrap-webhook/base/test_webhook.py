import base64
import binascii
import importlib.util
import json
import unittest
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


if __name__ == "__main__":
    unittest.main()
