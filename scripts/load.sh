#!/usr/bin/env bash
# Send steady traffic to /work so dashboards, traces and SLOs have data.
# Usage: scripts/load.sh [seconds] [requests-per-second]
source "$(dirname "$0")/lib.sh"
require kubectl curl

duration="${1:-120}"
rps="${2:-5}"
port=18081

kubectl -n "$APP_NS" port-forward svc/lab-app "$port:80" >/dev/null 2>&1 &
pf_pid=$!
trap 'kill "$pf_pid" 2>/dev/null || true' EXIT
sleep 2

ok=0; failed=0
end=$((SECONDS + duration))
log "sending ~${rps} req/s for ${duration}s"
while (( SECONDS < end )); do
  for ((i = 0; i < rps; i++)); do
    if curl -fs -o /dev/null "http://localhost:$port/work"; then
      ok=$((ok + 1))
    else
      failed=$((failed + 1))
    fi
  done
  sleep 1
done

total=$((ok + failed))
log "sent $total, ok $ok, failed $failed"
if (( total > 0 )); then
  log "success rate: $(awk -v o="$ok" -v t="$total" 'BEGIN { printf "%.2f%%", o / t * 100 }')"
fi
