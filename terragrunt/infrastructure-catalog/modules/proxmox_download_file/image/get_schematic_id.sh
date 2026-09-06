#!/bin/sh

# Send schematic.yaml and capture the response
response=$(curl -s -X POST --data-binary @schematic.yaml "https://factory.talos.dev/schematics")

# Extract the "id" field using jq
echo "$response" | jq -r '.id'
