# lab-app service level objectives

Fill in the **Measured** column from Grafana after running `scripts/load.sh`.

| SLI (what we measure) | SLO (target) | Window | Error budget | Measured |
| --- | --- | --- | --- | --- |
| Availability: share of `/work` requests that don't return 5xx | 99% | 1 hour (lab) / 30 days (real) | 1% of requests | |
| Latency: share of `/work` requests faster than 250 ms | 95% | 1 hour (lab) / 30 days (real) | 5% of requests | |

## PromQL

```promql
# availability
sum(rate(lab_requests_total{path="/work",status!~"5.."}[1h]))
/ sum(rate(lab_requests_total{path="/work"}[1h]))

# latency: share under 250 ms
sum(rate(lab_request_duration_seconds_bucket{path="/work",le="0.25"}[1h]))
/ sum(rate(lab_request_duration_seconds_count{path="/work"}[1h]))
```

## Error budget policy (write your own)

- Budget left: ship as normal.
- Budget burning fast (alert `LabAppErrorBudgetBurn`): pause risky deploys, investigate.
- Budget spent: only reliability fixes until the window recovers.
