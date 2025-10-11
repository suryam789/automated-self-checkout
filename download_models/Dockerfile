# syntax=docker/dockerfile:1
FROM python:3.12-slim

# Set proxy environment variables FIRST (before any network operations)
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG NO_PROXY
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
ENV NO_PROXY=$NO_PROXY
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY
ENV no_proxy=$NO_PROXY

# Install system dependencies and CA certificates for SSL
RUN apt-get update && \
    apt-get install -y wget curl bash ca-certificates libgl1 libglib2.0-0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Debug: print proxy and environment before installing dependencies
RUN echo "HTTP_PROXY: $HTTP_PROXY" && \
    echo "HTTPS_PROXY: $HTTPS_PROXY" && \
    env

# Set workdir to downloader_app (avoiding workspace conflicts)
WORKDIR /downloader_app

# Copy your requirements
COPY download_models/requirements.txt /downloader_app/requirements.txt

# Install Python dependencies with verbose output for logs
RUN pip3 install --upgrade pip -v --no-cache-dir && \
    pip3 install -v --no-cache-dir -r /downloader_app/requirements.txt

# Copy scripts to downloader_app directory
COPY download_models/*.sh /downloader_app/
# COPY download_models/efnetv2b0_download_quantize.py /downloader_app/efnetv2b0_download_quantize.py

# Make the scripts executable
RUN chmod +x /downloader_app/downloadModels.sh
RUN chmod +x /downloader_app/downloadAndQuantizeModel.sh
RUN chmod +x /downloader_app/download_age_prediction.sh
RUN chmod +x /downloader_app/download_effnetb0.sh

# Create models directory in the right location for volume mount
RUN mkdir -p /downloader_app/models

# Set MODELS_DIR environment variable to override script defaults
ENV MODELS_DIR=/downloader_app/models

# Debug: Show what files we have and their paths
RUN echo "======================================================= Files in /downloader_app ===" && ls -la /downloader_app/

# Default command - run scripts from downloader_app directory
CMD ["/bin/bash", "-c", "\
    chmod -R 755 /downloader_app/models && \
    /downloader_app/downloadModels.sh && \
    /downloader_app/download_age_prediction.sh && \
    /downloader_app/download_effnetb0.sh"]