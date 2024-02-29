#!/bin/bash
set -e

# Mandatory variables
# export KUBERNETES_ADDR=${KUBERNETES_ADDR:?}
USER_NAME=${1:?}

# Optional variables
export CLUSTER_NAME=${CLUSTER_NAME:=cluster}
TMP_DIR=${TMP_DIR:=/tmp/tokens}
USER_GROUP=${USER_GROUP:=admin}

# TODO: Add option for kubernetes port
if [ -z "$KUBERNETES_ADDR" ]
then
      KUBERNETES_ADDR=$(podman inspect kind-control-plane | jq -r '.[].HostConfig.PortBindings."6443/tcp"[].HostIp')
      export KUBERNETES_ADDR=$KUBERNETES_ADDR:6443
fi

echo "Creating user: '$USER_NAME' for cluster '$KUBERNETES_ADDR'"

# Get CA cert and CA key
mkdir -p $TMP_DIR
docker cp kind-control-plane:/etc/kubernetes/pki/ca.crt $TMP_DIR/
docker cp kind-control-plane:/etc/kubernetes/pki/ca.key $TMP_DIR/
CA_CRT_PATH=$TMP_DIR/ca.crt
CA_KEY_PATH=$TMP_DIR/ca.key

# Generate users key
USER_CRT_PATH=$TMP_DIR/$USER_NAME.crt
USER_KEY_PATH=$TMP_DIR/$USER_NAME.key
USER_CSR_PATH=$TMP_DIR/$USER_NAME.csr
openssl genrsa -out $USER_KEY_PATH 2048
openssl req -new -key $USER_KEY_PATH -out $USER_CSR_PATH -subj "/CN=$USER_NAME/O=$USER_GROUP"
openssl x509 -req -in $USER_CSR_PATH -CA $CA_CRT_PATH -CAkey $CA_KEY_PATH -CAcreateserial -out $USER_CRT_PATH -days 36000

# Create honeytoken config
export USER_CRT=$(cat $USER_CRT_PATH | base64 -w0)
export USER_KEY=$(cat $USER_KEY_PATH | base64 -w0)
export CA_CRT=$(cat $CA_CRT_PATH | base64 -w0)
envsubst < config/template.yaml > output/$USER_NAME.yaml

# Cleanup tmp
# rm $TMP_DIR/*