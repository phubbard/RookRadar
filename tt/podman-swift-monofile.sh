#!/bin/bash

# Configuration variables
PROJECT_DIR="./Study/study-swift-monofile"
CONTAINER_IMAGE="ghcr.io/bhyslop/recipemuster:test_sftrr.20250309__222204"
PODMAN_CONFIG="pdvm-rbw"  # Your podman configuration

echo "Running Swift code in a temporary container..."
podman -c "$PODMAN_CONFIG" run --rm \
    --network host \
    -v "./Study:/app" \
    "$CONTAINER_IMAGE" \
    swift "/app/study-swift-monofile/monofile.swift"

echo "Execution complete."


