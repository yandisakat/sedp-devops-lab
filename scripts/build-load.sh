#!/usr/bin/env bash
# Build the app image and load it straight into the kind nodes (no registry).
# Usage: scripts/build-load.sh <version>      e.g. scripts/build-load.sh 1.0.0
source "$(dirname "$0")/lib.sh"
require docker kind

version="${1:-}"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "usage: $0 <semver>, e.g. 1.0.0"

root="$(cd "$(dirname "$0")/.." && pwd)"
image="${IMAGE_REPO}:${version}"

log "building $image"
docker build -t "$image" "$root/app"

log "loading $image into kind cluster '$CLUSTER_NAME'"
kind load docker-image "$image" --name "$CLUSTER_NAME"
log "done: set image.tag: \"$version\" to deploy it"
