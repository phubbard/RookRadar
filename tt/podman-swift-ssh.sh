#!/bin/bash

# Configuration variables
PROJECT_DIR="./Study/study-swift-monofile"
CONTAINER_IMAGE="ghcr.io/bhyslop/recipemuster:test_sftrr.20250309__222204"
PODMAN_CONFIG="pdvm-rbw"  # Your podman configuration

echo "Opening interactive shell in swift container..."
podman -c "$PODMAN_CONFIG" run --rm -it \
    --network host \
    -v "./Study:/app" \
    "$CONTAINER_IMAGE" \
    /bin/bash

echo "Shell session ended."

