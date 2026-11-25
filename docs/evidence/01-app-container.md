# Milestone 1: App and container

No screenshots for this milestone — everything here is CLI output (tests, curl,
docker). Captured 2026-11-25.

## 1. Unit tests

```bash
cd app && python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt && python -m pytest -q
```

```
.....                                                                    [100%]
5 passed, 96 warnings in 1.41s
```

Shows: all 5 tests pass (root version, work success/failure paths, readiness
delay, metrics counting) before building anything.

## 2. Readiness vs liveness (`/readyz` 503 → 200)

```bash
STARTUP_DELAY_S=10 uvicorn main:app --port 8000
curl -i localhost:8000/readyz
```

Immediately after start:

```
readyz: 503
{"status":"starting"}
```

After the 10s delay:

```
readyz: 200
{"status":"ready"}

healthz: {"status":"alive"}        # alive the whole time, even while not ready
root:    {"service":"lab-app","version":"dev"}
work:    {"ok":true,"version":"dev"}
```

`/metrics` after a handful of requests (`curl localhost:8000/metrics | grep lab_`):

```
lab_requests_total{path="/readyz",status="503"} 2.0
lab_requests_total{path="/readyz",status="200"} 2.0
lab_requests_total{path="/healthz",status="200"} 1.0
lab_requests_total{path="/",status="200"} 1.0
lab_requests_total{path="/work",status="200"} 1.0
lab_request_duration_seconds_count{path="/work"} 1.0
lab_request_duration_seconds_sum{path="/work"} 0.0191
```

Shows: `/healthz` (liveness) is 200 the whole time — the process is alive and
would not be restarted. `/readyz` (readiness) is 503 until `STARTUP_DELAY_S`
elapses — a real Deployment would hold traffic out of the Service's endpoints
until this flips, without killing the pod.

## 3. Two image versions: size and layers

```bash
scripts/build-load.sh 1.0.0
# ...edit root()'s return value in main.py...
scripts/build-load.sh 1.1.0
docker image inspect lab-app:1.0.0 --format '{{.Size}}'
docker image inspect lab-app:1.1.0 --format '{{.Size}}'
docker history lab-app:1.0.0
docker history lab-app:1.1.0
```

Sizes: `1.0.0` = 55,817,796 bytes, `1.1.0` = 55,817,820 bytes (24 bytes
larger — exactly the extra JSON field added to `root()`).

Layer history (both images, abbreviated):

```
CREATED BY                                SIZE
CMD [...]                                 0B
USER 10001                                0B
RUN useradd --uid 10001 ...               49.2kB
COPY main.py .                            12.3kB
RUN pip install -r requirements.txt       43.8MB
COPY requirements.txt .                   12.3kB
WORKDIR /app                              8.19kB
...python:3.12-slim base layers...        ~160MB
```

Build time: `1.0.0` took ~12s (full `pip install`); `1.1.0` took ~0.2s to
export. Shows: because `requirements.txt` is `COPY`'d and `pip install` run
*before* `COPY main.py .`, changing only `main.py` reuses every layer up to
and including the 43.8MB dependency install from Docker's build cache — only
the `COPY main.py` and `useradd` layers (tiny) re-ran. This is why layer
order matters for build speed, and why "build once" works: the same
`requirements.txt` layer is shared across every app-code change.

## lib.sh / set -euo pipefail

Read `scripts/lib.sh` and `scripts/build-load.sh`. `set -euo pipefail` means:

- `-e`: exit immediately if any command fails (e.g. a bad `docker build`
  doesn't get papered over by a later command's success).
- `-u`: reference to an unset variable is an error, not an empty string
  (catches typos like `$CLSUTER_NAME`).
- `-o pipefail`: a pipeline's exit status is its last *failing* command, not
  just the last command — so `docker build ... | tee log` still fails the
  script if the build fails.

Combined with `require` (checks tools exist up front) and the `version`
regex guard in `build-load.sh`, the script fails fast and loud instead of
half-running with a missing tool or a malformed tag.
