# SEDP DevOps lab (OPS-3731)

One small service that grows through eight milestones: container → Kubernetes → Helm →
GitOps with Argo CD → OpenTelemetry → SLOs → Argo Rollouts and Workflows. Git and
Bash are used the whole way through. Everything runs in a local **kind** cluster, so
it's safe to break.

Each milestone guide in `docs/` has the same parts: **Do** (steps), **Prove it**
(evidence to capture in `docs/evidence/`), **Explain it** (questions to be able to
answer without notes) and **ADSS link** (where the real system does the same thing).

## Objectives → milestones

| OPS-3731 objective | Priority | Milestones |
| --- | --- | --- |
| Fundamentals of DevOps and SRE | 1 | 1, 2, 6 |
| GitOps: deploy to Kubernetes with a pull request | 1 | 4 |
| Kubernetes: deploy a container, manipulate resources via the API | 1 | 2 |
| OpenTelemetry for unified observability | 1 | 5 |
| Git: branches, inspect, update, merge, rebase | 2 | 4, 8 (and every PR) |
| Basic Bash | 2 | every `scripts/*.sh`, 8 |
| Argo for complex deployments and workflows | 2 | 4, 7 |
| Helm foundations | 3 | 3 |

## Milestones

| # | Guide | You end with |
| --- | --- | --- |
| 0 | [Setup](docs/00-setup.md) | Tools installed, repo on GitHub with `main` and `staging` |
| 1 | [App and container](docs/01-app-container.md) | Tested app, image built and loaded into kind |
| 2 | [Kubernetes](docs/02-kubernetes.md) | App running from raw manifests; rolled, broken, scaled through the API |
| 3 | [Helm](docs/03-helm.md) | Same app as a chart with per-environment values; upgrade and rollback |
| 4 | [GitOps with Argo CD](docs/04-gitops-argocd.md) | Deploys happen only by PR; drift healed; promotion staging → main |
| 5 | [OpenTelemetry](docs/05-opentelemetry.md) | Traces in Jaeger, metrics and a dashboard in Grafana |
| 6 | [SRE](docs/06-sre.md) | SLOs, a firing alert, a chaos test and a postmortem |
| 7 | [Argo Rollouts and Workflows](docs/07-argo.md) | A canary that rolls itself back; CI as a workflow DAG |
| 8 | [Git and Bash](docs/08-git-bash.md) | Rebase, conflict, cherry-pick, bisect, reflog; a script of your own |

## Suggested schedule (target date on OPS-3731: 2 Dec 2026)

| Day | Milestones |
| --- | --- |
| Wed 25 Nov | 0, 1 |
| Thu 26 Nov | 2 |
| Fri 27 Nov | 3, 4 |
| Mon 30 Nov | 5, 6 |
| Tue 1 Dec | 7, 8, rehearse the demo |
| Wed 2 Dec | Demo to Dieter (`docs/demo-script.md`) |

If time runs short, keep the priority 1 objectives (milestones 1, 2, 4, 5, 6) and ask
Dieter to move the date for the rest.

## Layout

```
app/            FastAPI service, tests, Dockerfile
k8s/            raw manifests (milestone 2)
charts/lab-app/ Helm chart (milestones 3–7)
gitops/         per-environment values + Argo CD Applications (milestone 4)
observability/  collector, Instrumentation, Jaeger, Prometheus values, dashboard (milestone 5)
sre/            SLOs, alert rules, postmortem template (milestone 6)
argo/workflows/ CI pipeline as an Argo Workflow (milestone 7)
scripts/        Bash for everything you run more than once
docs/           milestone guides, demo script, evidence log
```

Nothing here is ADSS code or config; it's a personal lab that mirrors ADSS patterns.
