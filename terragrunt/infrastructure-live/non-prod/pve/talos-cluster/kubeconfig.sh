#!/bin/sh

# Create config directories if they don't exist
mkdir -p ~/.kube
mkdir -p ~/.talos

# Write kubeconfig to default location
terragrunt stack output --format="json" | jq -r '."talos-cluster".kubeconfig_raw' > ~/.kube/config
chmod 600 ~/.kube/config

# Write talosconfig to default location
terragrunt stack output --json | jq -r '."talos-cluster".talosconfig_raw' > ~/.talos/config
chmod 600 ~/.talos/config

echo "Configs written:"
echo "~/.kube/config (kubeconfig)"
echo "~/.talos/config (talosconfig)"

