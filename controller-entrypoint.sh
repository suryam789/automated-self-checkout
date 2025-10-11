#!/bin/bash

echo "ASC Controller Container Started!"

export MODEL_TYPE=${MODEL_TYPE:-yolo11n}
export TARGET_DEVICE=${TARGET_DEVICE:-CPU}

echo "Configuration:"
echo "  MODEL_TYPE: $MODEL_TYPE"
echo "  TARGET_DEVICE: $TARGET_DEVICE"

echo ""
echo "Checking Docker connectivity..."
docker --version

echo ""
echo "Step 1: Building model downloader (sibling container)..."
cd /workspace

# Build with proxy settings
BUILD_ARGS=""
if [ -n "$HTTP_PROXY" ]; then
    BUILD_ARGS="$BUILD_ARGS --build-arg HTTP_PROXY=$HTTP_PROXY"
    echo "Using HTTP_PROXY: $HTTP_PROXY"
fi
if [ -n "$HTTPS_PROXY" ]; then
    BUILD_ARGS="$BUILD_ARGS --build-arg HTTPS_PROXY=$HTTPS_PROXY"
    echo "Using HTTPS_PROXY: $HTTPS_PROXY"
fi
if [ -n "$NO_PROXY" ]; then
    BUILD_ARGS="$BUILD_ARGS --build-arg NO_PROXY=$NO_PROXY"
    echo "Using NO_PROXY: $NO_PROXY"
fi

echo "Building model downloader with proxy settings..."
docker build $BUILD_ARGS -t model-downloader:latest -f download_models/Dockerfile .

echo ""
echo "Step 2: Running model download in sibling container (direct host mount)..."

# Simple approach: Use environment variable passed from host
HOST_MODELS_PATH="${HOST_MODELS_DIR:-/workspace/models}"

echo "Using host models path: $HOST_MODELS_PATH"
echo "Mounting: $HOST_MODELS_PATH -> /downloader_app/models"

docker run --rm \
  --network host \
  -v "$HOST_MODELS_PATH:/downloader_app/models" \
  -e MODEL_TYPE="$MODEL_TYPE" \
  -e TARGET_DEVICE="$TARGET_DEVICE" \
  -e MODELS_DIR="/downloader_app/models" \
  -e HTTP_PROXY="$HTTP_PROXY" \
  -e HTTPS_PROXY="$HTTPS_PROXY" \
  -e http_proxy="$HTTP_PROXY" \
  -e https_proxy="$HTTPS_PROXY" \
  -e NO_PROXY="$NO_PROXY" \
  -e no_proxy="$NO_PROXY" \
  model-downloader:latest

echo ""
echo "Step 3: Cleaning up model downloader image..."
docker rmi model-downloader:latest || echo "Image already removed"

echo ""
echo "Models downloaded to host:"
ls -la /workspace/models/

echo "All models ready! Sibling container downloaded to mounted location."

echo ""
echo "Step 4: Updating submodules..."
git submodule update --init --recursive || echo "Submodules update had issues"

echo ""
echo "Step 5: Starting application..."
echo "Controller ready. Press Ctrl+C to stop."
while true; do
    sleep 30
    echo "Controller heartbeat: $(date) | Models available on host"
done
