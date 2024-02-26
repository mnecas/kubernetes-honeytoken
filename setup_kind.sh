#!/bin/bash
set -e


# Mandatory variables
export KUBERNETES_ADDR=${KUBERNETES_ADDR:?}
export WEBHOOK_ADDR=${WEBHOOK_ADDR:?}

# Optional variables
export USER_GROUP=${USER_GROUP:=admin}
export TMP_DIR=${TMP_DIR:=tmp}

# TODO:
# - Add dockerifle and compose for server
# - Create webhook server and get address from it 


# Create temporary configs
mkdir -p $TMP_DIR
envsubst < config/audit-policy.yaml > $TMP_DIR/audit-policy.yaml
envsubst < config/audit-webhook.yaml > $TMP_DIR/audit-webhook.yaml
envsubst < config/kind-config.yaml > $TMP_DIR/kind-config.yaml

# Create cluster
kind create cluster --config $TMP_DIR/kind-config.yaml

# Log information about the cluster

