#!/usr/bin/env bash
# Check the deployed app answers on every endpoint. Exits non-zero on failure,
# so it can gate a pipeline (and power `git bisect run`).
# Usage: scripts/smoke-test.sh [service] [namespace]
source "$(dirname "$0")/lib.sh"
require kubectl curl jq

svc="${1:-lab-app}"
ns="${2:-$APP_NS}"
port=18080

kubectl -n "$ns" port-forward "svc/$svc" "$port:80" >/dev/null 2>&1 &
pf_pid=$!
trap 'kill "$pf_pid" 2>/dev/null || true' EXIT

for _ in {1..20}; do
  curl -fs "http://localhost:$port/healthz" >/dev/null 2>&1 && break
  sleep 0.5
done

failures=0
for path in / /healthz /readyz /work /metrics; do
  code="$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:$port$path")"
  if [[ "$code" == "200" ]]; then
    log "PASS $path ($code)"
  else
    warn "FAIL $path ($code)"
    failures=$((failures + 1))
  fi
done

version="$(curl -fs "http://localhost:$port/" | jq -r .version)"
log "serving version: $version"
(( failures == 0 )) || die "$failures endpoint(s) failed"
