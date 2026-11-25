#!/usr/bin/env bash
# Shared helpers. Source it:  source "$(dirname "$0")/lib.sh"
set -euo pipefail

CLUSTER_NAME="${CLUSTER_NAME:-sedp-lab}"
APP_NS="${APP_NS:-lab}"
IMAGE_REPO="${IMAGE_REPO:-lab-app}"

log()  { printf '\033[1;34m[%s]\033[0m %s\n' "$(date +%H:%M:%S)" "$*"; }
warn() { printf '\033[1;33m[warn]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

# require <command>...: stop early with a clear message if a tool is missing.
require() {
  local cmd
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || die "'$cmd' is not installed (see docs/00-setup.md)"
  done
}

# Refuse to touch anything but the local kind cluster.
require_kind_context() {
  local ctx
  ctx="$(kubectl config current-context 2>/dev/null || true)"
  [[ "$ctx" == "kind-${CLUSTER_NAME}" ]] \
    || die "current kube context is '${ctx:-none}', expected 'kind-${CLUSTER_NAME}'. Run: kubectl config use-context kind-${CLUSTER_NAME}"
}
