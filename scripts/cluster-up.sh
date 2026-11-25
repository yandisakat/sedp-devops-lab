#!/usr/bin/env bash
# Create a local kind cluster: one control plane, two workers (so pod spreading
# and node failure are visible).
source "$(dirname "$0")/lib.sh"
require kind kubectl docker

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
  log "cluster '$CLUSTER_NAME' already exists"
else
  log "creating cluster '$CLUSTER_NAME'"
  kind create cluster --name "$CLUSTER_NAME" --config - <<'YAML'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
YAML
fi

kubectl config use-context "kind-${CLUSTER_NAME}" >/dev/null
kubectl get nodes -o wide
