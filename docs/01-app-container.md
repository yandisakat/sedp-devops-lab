# 1. App and container

Objective: **DevOps fundamentals** (build once, ship the same artefact) and **Bash**.

## Do

1. Run the tests locally:
   ```bash
   cd app && python3 -m venv .venv && source .venv/bin/activate
   pip install -r requirements-dev.txt && python -m pytest -q
   ```
2. Run the app and hit each endpoint:
   ```bash
   STARTUP_DELAY_S=10 uvicorn main:app --port 8000
   curl -i localhost:8000/readyz   # 503 for 10s, then 200
   curl localhost:8000/work; curl localhost:8000/metrics | grep lab_
   ```
3. Build and load two versions into kind (edit the `root()` message in between so they differ):
   ```bash
   scripts/build-load.sh 1.0.0
   scripts/build-load.sh 1.1.0
   docker image inspect lab-app:1.0.0 --format '{{.Size}}'
   docker history lab-app:1.0.0
   ```
4. Read `scripts/lib.sh` and `scripts/build-load.sh` line by line; note what `set -euo pipefail` changes.

## Prove it

- Test output, the `/readyz` 503 → 200 switch, image size and layers.

## Explain it

- Liveness vs readiness: what happens to traffic and to the container when each fails?
- Why configure behaviour with env vars instead of baking it in? (Same image in every environment.)
- Why run as a non-root user? Why does layer order in the Dockerfile matter for build speed?

## ADSS link

ADSS images are built once by `release.yml`, tagged with GitVersion and pushed to ECR; environments differ only in values.
