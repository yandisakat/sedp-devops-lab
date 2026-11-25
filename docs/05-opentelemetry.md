# 5. OpenTelemetry

Objective: **unified observability with OpenTelemetry**: traces, metrics and, by extension, logs.

## Do

1. Install: `scripts/install-platform.sh observability` (cert-manager, kube-prometheus-stack, the OTel Operator, Jaeger, the collector, the Instrumentation and the dashboard). Allow about 5 minutes.
2. In a PR to `staging`, opt the app in through `gitops/envs/dev/values.yaml`:
   ```yaml
   podAnnotations:
     instrumentation.opentelemetry.io/inject-python: "observability/python"
   serviceMonitor:
     enabled: true
   ```
3. After the sync, see what the operator changed: `kubectl -n lab-dev get pod -l app.kubernetes.io/name=lab-app -o yaml | grep -iE 'otel|initContainers' -A2`
4. Generate traffic: `APP_NS=lab-dev scripts/load.sh 300 5`
5. **Traces:** `kubectl -n observability port-forward svc/jaeger 16686`. Open one `/work` trace and name its spans.
6. **Metrics:** `kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80` (admin/admin). Open “lab-app golden signals”, then build one panel of your own.
7. **Pipeline:** `kubectl -n observability logs deploy/otel-collector | tail` (the debug exporter). The SDK captures the `authorization` and `user-agent` headers (see `observability/instrumentation.yaml`), and the collector deletes `authorization`. Send `curl -H 'Authorization: secret' …/work` and check the span in Jaeger: `user-agent` is there, `authorization` isn't. Explain where it was removed and why there.
8. Set `config.EXTRA_LATENCY_MS: "300"` by PR. Find the change in the latency panel and in trace durations.

## Prove it

- A Jaeger trace screenshot, the Grafana dashboard under load, the latency change and the PR that caused it.

## Explain it

- Traces vs metrics vs logs: what question does each answer?
- What do the SDK, the collector and the backend (Jaeger, Prometheus) each do? Why put a collector in the middle?
- What did the operator inject, and why didn't the app code change?
- Sampling: why keep 100% here but not in production? What is context propagation?

## ADSS link

ADSS uses the OTel Operator with per-language inject annotations, Jaeger, Prometheus and Grafana, and redacts sensitive headers. Go auto-instrumentation isn't supported on Bottlerocket nodes.
