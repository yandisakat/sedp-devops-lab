# Demo for Dieter (about 15 minutes)

Before you start: cluster up, load running in dev, tabs open for Argo CD, Grafana, Jaeger and the GitHub PR list.

| Min | Show | Say |
| --- | --- | --- |
| 0–1 | README objective table | Eight objectives, one lab, mirrored on ADSS patterns. |
| 1–4 | Open a PR changing `image.tag` → merge → Argo CD syncs → smoke test | GitOps: the PR is the deploy. CI ran shellcheck, tests and helm lint first. |
| 4–5 | `kubectl scale` → Argo CD heals it | Git is the source of truth; drift gets reverted. |
| 5–8 | Grafana golden signals, then one trace in Jaeger | OTel: the operator injected tracing with no code change; the collector redacts headers. |
| 8–11 | Bad canary PR → analysis fails → automatic abort | Argo Rollouts plus Prometheus decide; the SLO is the gate. |
| 11–13 | Postmortem and SLO doc | SRE: error budget, burn-rate alert, recovery times from the chaos test. |
| 13–15 | `git log --graph`, `env-diff.sh`, questions | Git and Bash, then what I'd apply to ADSS. |

Questions to bring:

- How does ADSS use Argo Workflows?
- Would an eventing-lag SLO replace the 3-hourly restarts?
- Could the backend run canaries, given startup migrations?
