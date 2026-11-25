#!/usr/bin/env bash
# Milestone 6: kill one app pod and time how long until every replica is Ready again.
source "$(dirname "$0")/lib.sh"
require kubectl
require_kind_context

selector="app.kubernetes.io/name=lab-app"
victim="$(kubectl -n "$APP_NS" get pods -l "$selector" -o jsonpath='{.items[0].metadata.name}')"
[[ -n "$victim" ]] || die "no lab-app pods found in '$APP_NS'"

want="$(kubectl -n "$APP_NS" get deploy lab-app -o jsonpath='{.spec.replicas}' 2>/dev/null \
  || kubectl -n "$APP_NS" get rollout lab-app -o jsonpath='{.spec.replicas}')"

log "deleting pod $victim (want $want ready replicas)"
start=$SECONDS
kubectl -n "$APP_NS" delete pod "$victim" --wait=false

sleep 2
while true; do
  ready="$(kubectl -n "$APP_NS" get pods -l "$selector" \
    -o jsonpath='{range .items[*]}{.status.conditions[?(@.type=="Ready")].status}{"\n"}{end}' \
    | grep -c True || true)"
  (( ready >= want )) && break
  (( SECONDS - start > 180 )) && die "not recovered after 180s"
  sleep 1
done
log "recovered: $ready/$want ready after $((SECONDS - start))s"
log "record this time-to-recover in docs/evidence/06-sre.md"
