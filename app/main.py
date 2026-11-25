"""lab-app: a tiny service built to be deployed, observed and broken on purpose.

Endpoints
  GET /         hello + version (shows which release is serving)
  GET /work     simulated work; latency and failures controlled by env vars
  GET /healthz  liveness: the process is alive
  GET /readyz   readiness: true only after STARTUP_DELAY_S has passed
  GET /metrics  Prometheus metrics (request count + latency histogram)
"""
import os
import random
import time

from fastapi import FastAPI, HTTPException, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Histogram, generate_latest

APP_VERSION = os.getenv("APP_VERSION", "dev")
FAIL_RATE = float(os.getenv("FAIL_RATE", "0"))          # 0.0–1.0 share of /work calls that fail
EXTRA_LATENCY_MS = int(os.getenv("EXTRA_LATENCY_MS", "0"))
STARTUP_DELAY_S = float(os.getenv("STARTUP_DELAY_S", "0"))

STARTED_AT = time.monotonic()

REQUESTS = Counter("lab_requests_total", "HTTP requests", ["path", "status"])
LATENCY = Histogram(
    "lab_request_duration_seconds", "HTTP request latency", ["path"],
    buckets=(0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5),
)

app = FastAPI(title="lab-app", version=APP_VERSION)


@app.middleware("http")
async def record_metrics(request: Request, call_next):
    path = request.url.path
    start = time.perf_counter()
    status = 500
    try:
        response = await call_next(request)
        status = response.status_code
        return response
    finally:
        if path != "/metrics":
            REQUESTS.labels(path=path, status=str(status)).inc()
            LATENCY.labels(path=path).observe(time.perf_counter() - start)


@app.get("/")
def root():
    return {"service": "lab-app", "version": APP_VERSION}


@app.get("/work")
def work():
    time.sleep((random.uniform(5, 30) + EXTRA_LATENCY_MS) / 1000)
    if random.random() < FAIL_RATE:
        raise HTTPException(status_code=500, detail="simulated failure")
    return {"ok": True, "version": APP_VERSION}


@app.get("/healthz")
def healthz():
    return {"status": "alive"}


@app.get("/readyz")
def readyz(response: Response):
    if time.monotonic() - STARTED_AT < STARTUP_DELAY_S:
        response.status_code = 503
        return {"status": "starting"}
    return {"status": "ready"}


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
