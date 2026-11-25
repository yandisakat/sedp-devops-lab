#!/usr/bin/env bash
# Delete the local cluster. Asks first, because everything in it goes.
source "$(dirname "$0")/lib.sh"
require kind

read -r -p "Delete kind cluster '$CLUSTER_NAME'? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { log "cancelled"; exit 0; }
kind delete cluster --name "$CLUSTER_NAME"
