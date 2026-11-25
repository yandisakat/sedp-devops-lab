#!/usr/bin/env bash
# Milestone 0: confirm every tool the lab needs is installed.
source "$(dirname "$0")/lib.sh"

missing=0
for tool in docker kind kubectl helm git python3 shellcheck jq curl; do
  if command -v "$tool" >/dev/null 2>&1; then
    log "ok      $tool"
  else
    warn "missing $tool"
    missing=$((missing + 1))
  fi
done

docker info >/dev/null 2>&1 || { warn "docker is installed but not running"; missing=$((missing + 1)); }

(( missing == 0 )) || die "$missing problem(s) found"
log "all prerequisites present"
