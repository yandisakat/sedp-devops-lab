import importlib

from fastapi.testclient import TestClient


def make_client(monkeypatch, **env):
    for key, value in env.items():
        monkeypatch.setenv(key, value)
    import main
    importlib.reload(main)  # re-read env vars at import time
    return TestClient(main.app)


def test_root_reports_version(monkeypatch):
    client = make_client(monkeypatch, APP_VERSION="1.2.3")
    assert client.get("/").json()["version"] == "1.2.3"


def test_work_succeeds_when_fail_rate_zero(monkeypatch):
    client = make_client(monkeypatch, FAIL_RATE="0")
    assert all(client.get("/work").status_code == 200 for _ in range(20))


def test_work_fails_when_fail_rate_one(monkeypatch):
    client = make_client(monkeypatch, FAIL_RATE="1")
    assert client.get("/work").status_code == 500


def test_readyz_waits_for_startup_delay(monkeypatch):
    client = make_client(monkeypatch, STARTUP_DELAY_S="60")
    assert client.get("/readyz").status_code == 503
    assert client.get("/healthz").status_code == 200  # alive but not ready


def test_metrics_count_requests(monkeypatch):
    client = make_client(monkeypatch, FAIL_RATE="0")
    client.get("/work")
    body = client.get("/metrics").text
    assert 'lab_requests_total{path="/work",status="200"}' in body
