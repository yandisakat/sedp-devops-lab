#!/usr/bin/env bash
# Milestone 2: talk to the Kubernetes API directly, without kubectl's helpers.
# kubectl proxy handles auth; everything else is plain HTTP + JSON.
source "$(dirname "$0")/lib.sh"
require kubectl curl jq
require_kind_context

port=18001
kubectl proxy --port="$port" >/dev/null 2>&1 &
proxy_pid=$!
trap 'kill "$proxy_pid" 2>/dev/null || true' EXIT
sleep 1
api="http://localhost:$port"

log "1. API groups the server offers"
curl -fs "$api/apis" | jq -r '.groups[].name' | head -15

log "2. Pods in '$APP_NS' (GET /api/v1/namespaces/$APP_NS/pods)"
curl -fs "$api/api/v1/namespaces/$APP_NS/pods" \
  | jq -r '.items[] | [.metadata.name, .status.phase, .spec.nodeName] | @tsv'

log "3. Scale the Deployment to 3 with a PATCH to the scale subresource"
curl -fs -X PATCH \
  -H 'Content-Type: application/merge-patch+json' \
  -d '{"spec":{"replicas":3}}' \
  "$api/apis/apps/v1/namespaces/$APP_NS/deployments/lab-app/scale" | jq '{spec, status}'

log "4. Watch events for 15s (a streaming GET with ?watch=true)"
timeout 15 curl -fsN "$api/api/v1/namespaces/$APP_NS/events?watch=true" \
  | jq -r '.object | "\(.reason)\t\(.involvedObject.name)\t\(.message)"' || true

log "5. Scale back to 2"
curl -fs -X PATCH -H 'Content-Type: application/merge-patch+json' \
  -d '{"spec":{"replicas":2}}' \
  "$api/apis/apps/v1/namespaces/$APP_NS/deployments/lab-app/scale" >/dev/null
log "done. Note: with ArgoCD selfHeal on (milestone 4), this scale would be reverted."
