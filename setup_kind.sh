#!/bin/bash
set -e

# Mandatory variables
export KUBERNETES_ADDR=${KUBERNETES_ADDR:?}
export SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL:?}

# Optional variables
export USER_GROUP=${USER_GROUP:=admin}
export TMP_DIR=${TMP_DIR:=tmp}

# Create kind network where the webhook and kind cluster will run
docker network create kind --ignore

# Build the webhook_server
docker build --env SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL -t webhook_server webhook/
WEBHOOK_CONTAINER_ID=$(docker run --name webhook -d --rm --network kind localhost/webhook_server:latest)
WEBHOOK_ADDR=$(docker inspect $WEBHOOK_CONTAINER_ID | jq -r ".[].NetworkSettings.Networks.kind.IPAddress")
export WEBHOOK_ADDR=$WEBHOOK_ADDR:5000
# Create temporary configs
mkdir -p $TMP_DIR
envsubst < config/audit-policy.yaml > $TMP_DIR/audit-policy.yaml
envsubst < config/audit-webhook.yaml > $TMP_DIR/audit-webhook.yaml
envsubst < config/kind-config.yaml > $TMP_DIR/kind-config.yaml

# Create cluster
kind create cluster --config $TMP_DIR/kind-config.yaml
