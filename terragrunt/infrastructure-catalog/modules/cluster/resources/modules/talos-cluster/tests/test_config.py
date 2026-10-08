"""Validate rendered Talos patches offline."""

import json
from pathlib import Path
import subprocess
import tempfile
import tomllib


MODULE = Path(__file__).resolve().parents[1]
TEMPLATES = MODULE.parents[1] / "templates"
SOURCE = (MODULE / "config.tf").read_text()
# ponytail: extracts this block by layout; use an HCL parser if its structure changes.
PATCHES = SOURCE.split("config_patches = ", 1)[1].split("\n}\n", 1)[0].strip()
SWAP_ENABLED = SOURCE.split("zswap_patches_enabled = ", 1)[1].splitlines()[0]
TALOS_VERSION = "v1.14.1"
KUBERNETES_VERSION = "1.37.1"
INSTALLER = f"factory.talos.dev/installer:{TALOS_VERSION}"


def run(args, **kwargs):
    result = subprocess.run(args, text=True, capture_output=True, **kwargs)
    if result.returncode:
        raise RuntimeError(f"{args[0]} failed:\n{result.stderr}{result.stdout}")
    return result.stdout


def template(name, values):
    return f"templatefile({json.dumps(str(TEMPLATES / name))}, {json.dumps(values)})"


with tempfile.TemporaryDirectory(prefix="talos-config-check-") as directory:
    def render(expression):
        output = run(["tofu", "console"], input=f"jsonencode({expression})\n", cwd=directory)
        return json.loads(json.loads(output))

    cluster = render(template("talos_cluster.yaml.tftpl", {
        "cluster_endpoint": "https://192.168.1.50:6443", "cluster_name": "regression",
        "cluster_pod_subnet": "10.244.0.0/16", "cluster_service_subnet": "10.96.0.0/12",
        "cluster_node_subnet": "192.168.1.0/24",
        "cluster_extraManifests": ["https://example.com/crds.yaml"],
    }))
    for role in ("controlplane", "worker"):
        machine = render(template("talos_machine.yaml.tftpl", {
            "machine_type": role, "cluster_node_subnet": "192.168.1.0/24",
            "machine_timeservers": ["time.cloudflare.com"],
            "machine_install": {"disk": "/dev/vda", "wipe": False},
            "machine_labels": [{"key": "homelab", "value": "true"}],
            "machine_annotations": [{"key": "example.com/rack", "value": "rack-1"}],
            "machine_files": [],
        }))
        # Legacy files trigger strict deprecation warnings; check their preservation separately.
        custom_file = {
            "path": "/var/etc/regression.conf", "op": "create",
            "permissions": 0o600, "content": "preserve this\nsecond line",
        }
        file_machine = render(f'yamldecode({json.dumps(machine)})')
        file_machine["files"] = [custom_file]
        file_patch = render(template(
            MODULE / "resources/talos-patches/machine.yaml.tftpl",
            {"machine_config": file_machine},
        ))
        file_docs = render(f'[for doc in split("---\\n", {json.dumps(file_patch)}) : yamldecode(doc) if trimspace(doc) != ""]')
        assert file_docs[0]["machine"]["files"] == [custom_file]
        for swap in (False, True):
            print(f"Checking {role}, swap={swap}", flush=True)
            replacements = {
                "local.zswap_patches_enabled": f"({SWAP_ENABLED})",
                "${path.module}": str(MODULE),
                "var.talos_cluster_config": json.dumps(cluster),
                "var.swap_disk_min": "32", "var.swap_disk_max": "32",
                "var.zswap.max_pool_percent": "20", "var.zswap.shrinker_enabled": "true",
                "var.zswap.enabled": json.dumps(swap),
                'try(each.value.hostname, "")': '"regression"',
                "each.value.machine_nameservers": '["1.1.1.1"]',
                "each.value.machine_interfaces": json.dumps([{
                    "mtu": 1500, "addresses": ["192.168.1.61/24"],
                    "gateway": "192.168.1.1", "routes": [],
                }]),
                "var.cluster_vip": '"192.168.1.50"',
                "data.helm_template.bootstrap_charts": json.dumps({"test": {
                    "name": "test", "crds": ["apiVersion: v1\nkind: Namespace\nmetadata:\n  name: test-crd"],
                    "manifest": "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: test",
                }}),
                "each.value.secureboot ? local.machine_installer_secureboot[each.key] : local.machine_installer[each.key]": json.dumps(INSTALLER),
                "each.value.talos_config": json.dumps(machine),
                "var.ts_authkey": '"test-only"', "each.key": '"regression"',
            }
            expression = PATCHES
            for old, new in replacements.items():
                expression = expression.replace(old, new)
            patch_args = []
            for index, patch in enumerate(render(expression)):
                path = Path(directory) / f"patch-{index}.yaml"
                path.write_text(patch)
                patch_args.extend(["--config-patch", f"@{path}"])
            config = run([
                "talosctl", "gen", "config", "regression", "https://192.168.1.50:6443",
                "--talos-version", TALOS_VERSION, "--kubernetes-version", KUBERNETES_VERSION,
                "--with-docs=false", "--with-examples=false", "--output-types", role,
                "--output", "-", *patch_args,
            ])
            path = Path(directory) / "config.yaml"
            path.write_text(config)
            run(["talosctl", "validate", "--config", str(path), "--mode", "cloud", "--strict"])
            docs = render(f'[for doc in split("\\n---\\n", {json.dumps(config)}) : yamldecode(doc)]')
            identities = [(doc["kind"], doc.get("name")) for doc in docs if "kind" in doc]
            assert len(identities) == len(set(identities)), identities
            kinds = {doc["kind"]: doc for doc in docs if "kind" in doc and "name" not in doc}
            named = {(doc["kind"], doc["name"]): doc for doc in docs if "kind" in doc and "name" in doc}
            assert kinds["SecurityProfileConfig"]["workloadIsolation"] is True
            legacy = docs[0]["machine"]
            assert not {"kubelet", "install", "time", "nodeLabels", "nodeAnnotations"} & legacy.keys()
            assert kinds["KubeletConfig"]["config"]["maxPods"] == 200
            assert ("memorySwap" in kinds["KubeletConfig"]["config"]) == swap
            if swap:
                assert kinds["KubeletConfig"]["config"]["memorySwap"]["swapBehavior"] == "LimitedSwap"
            assert kinds["KubeletConfig"]["clusterDNS"] == ["10.96.0.10"]
            assert kinds["UnattendedInstallConfig"]["installer"]["image"] == INSTALLER
            assert kinds["UnattendedInstallConfig"]["provisioning"]["wipe"] is False
            assert kinds["UnattendedInstallConfig"]["provisioning"]["diskSelector"]["match"] == 'disk.dev_path == "/dev/vda"'
            assert kinds["ResolverConfig"]["hostDNS"]["forwardKubeDNSToHost"] is False
            assert kinds["KubeNodeConfig"]["labels"]["homelab"] == "true"
            assert kinds["KubeNodeConfig"]["annotations"]["example.com/rack"] == "rack-1"
            assert ("KubeTalosAPIAccessConfig" in kinds) == (role == "controlplane")
            assert (("SwapVolumeConfig", "zswap") in named) == swap
            assert ("ZswapConfig" in kinds) == swap
            assert ("UserVolumeConfig", "longhorn") in named
            assert kinds["TimeSyncConfig"]["ntp"]["servers"] == ["time.cloudflare.com"]
            sysctls = kinds["SysctlConfig"]["params"]
            assert sysctls["user.max_user_namespaces"] == "11255"
            assert ("vm.swappiness" in sysctls) == swap
            assert ("vm.page-cluster" in sysctls) == swap
            if swap:
                assert sysctls["vm.swappiness"] == "130"
                assert sysctls["vm.page-cluster"] == "0"
            cri = tomllib.loads(named["CRICustomizationConfig", "homelab"]["content"])["plugins"]
            assert cri["io.containerd.cri.v1.images"]["discard_unpacked_layers"] is False
            assert cri["io.containerd.cri.v1.runtime"]["cdi_spec_dirs"] == ["/var/cdi/static", "/var/cdi/dynamic"]
            assert {doc["name"] for doc in docs if doc.get("kind") == "KernelModuleConfig"} >= {"binfmt_misc", "nvme_tcp", "vfio_pci"}
            inline = {doc["name"]: doc["manifest"] for doc in docs if doc.get("kind") == "KubeInlineManifestConfig"}
            if role == "controlplane":
                assert docs[0]["cluster"]["etcd"]["advertisedSubnets"] == ["192.168.1.0/24"]
                assert not kinds["KubeNodeConfig"].get("taints")
                assert "KubeFlannelCNIConfig" not in kinds
                assert kinds["KubeProxyConfig"]["enabled"] is False
                assert kinds["KubeCoreDNSConfig"]["enabled"] is False
                assert inline == {
                    "test-crd-0": "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: test-crd",
                    "test": "apiVersion: v1\nkind: Namespace\nmetadata:\n  name: test",
                }
                assert named["KubeExternalManifestConfig", "extra-manifest-0"]["url"] == "https://example.com/crds.yaml"
            else:
                assert not inline
                assert not any(kind == "KubeExternalManifestConfig" for kind, name in named)
                assert "KubeCoreDNSConfig" not in kinds
            print(f"PASS: {role}, swap={swap}")
