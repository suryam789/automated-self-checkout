#!/bin/bash

if [ -n "$HTTP_PROXY" ]; then
    export http_proxy="$HTTP_PROXY"
fi
if [ -n "$HTTPS_PROXY" ]; then
    export https_proxy="$HTTPS_PROXY"
fi

VIDEO_SOURCE=${1:-""}

# Use MODELS_DIR environment variable instead of hardcoded path
MODELS_DIR="${MODELS_DIR:-/downloader_app/models}"
FACE_MODEL="$MODELS_DIR/face_detection/FP16/face-detection-retail-0004.xml"
AGE_MODEL="$MODELS_DIR/age_prediction/FP16/age-gender-recognition-retail-0013.xml"
DEVICE="CPU"

set -e

mkdir -p "$MODELS_DIR/face_detection/FP16"
mkdir -p "$MODELS_DIR/age_prediction/FP16"

if [ -f "$FACE_MODEL" ] && [ -f "$AGE_MODEL" ]; then
    echo "Models already downloaded ✓"
    echo "Face detection model: $FACE_MODEL"
    echo "Age prediction model: $AGE_MODEL"
else
    echo "Downloading models using Open Model Zoo downloader..."
    
    echo "Downloading face detection model..."
    omz_downloader --name face-detection-retail-0004 --output_dir "$MODELS_DIR/temp_face"
     
    echo "Downloading age prediction model..."
    omz_downloader --name age-gender-recognition-retail-0013 --output_dir "$MODELS_DIR/temp_age"
    
    echo "Organizing face detection model..."
    if [ -d "$MODELS_DIR/temp_face/intel/face-detection-retail-0004" ]; then
        cp -r "$MODELS_DIR/temp_face/intel/face-detection-retail-0004"/* "$MODELS_DIR/face_detection/"
    fi
    
    echo "Organizing age prediction model..."
    if [ -d "$MODELS_DIR/temp_age/intel/age-gender-recognition-retail-0013" ]; then
        cp -r "$MODELS_DIR/temp_age/intel/age-gender-recognition-retail-0013"/* "$MODELS_DIR/age_prediction/"
    fi
    
    rm -rf "$MODELS_DIR/temp_face" "$MODELS_DIR/temp_age"
    
    echo "Listing downloaded models..."
    find "$MODELS_DIR" -name "*.xml" -o -name "*.bin" | sort
    
    echo "Model download and organization completed successfully!"
fi

echo "Downloading model-proc JSON files..."

wget -O "$MODELS_DIR/age_prediction/age-gender-recognition-retail-0013.json" \
    https://raw.githubusercontent.com/open-edge-platform/edge-ai-libraries/main/libraries/dl-streamer/samples/gstreamer/model_proc/intel/age-gender-recognition-retail-0013.json

wget -O "$MODELS_DIR/face_detection/face-detection-retail-0004.json" \
    https://raw.githubusercontent.com/open-edge-platform/edge-ai-libraries/main/libraries/dl-streamer/samples/gstreamer/model_proc/intel/face-detection-retail-0004.json

echo "Downloaded JSON files:"
ls "$MODELS_DIR/age_prediction"/*.json "$MODELS_DIR/face_detection"/*.json