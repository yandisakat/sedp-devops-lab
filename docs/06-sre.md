# 6. SRE: SLOs, alerts, chaos and postmortems

Objective: **fundamentals of SRE**.

## Do

1. Read `sre/slo.md` and write your error budget policy in it.
2. Apply the alerts: `kubectl apply -f sre/prometheus-rule.yaml`. Find them in Prometheus (`kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090`, then Alerts).
3. **Incident:** in a PR, set `config.FAIL_RATE: "0.3"` in dev. Run `APP_NS=lab-dev scripts/load.sh 600 5` and watch `LabAppErrorBudgetBurn` go Pending, then Firing (Alertmanager: `svc/monitoring-kube-prometheus-alertmanager 9093`).
4. Mitigate with `git revert` of that PR. Note detection time and recovery time.
5. **Chaos:** `APP_NS=lab-dev scripts/chaos.sh`. Run it during load and check whether any requests failed. Then repeat with `replicaCount: 1` and compare.
6. Write a postmortem for step 3 from `sre/postmortem-template.md` and save it as `docs/evidence/postmortem-fail-rate.md`.
7. Measure and record the SLOs in `sre/slo.md`.

`LabAppNoReadyPods` watches a Deployment. After milestone 7 swaps it for a Rollout, rewrite that rule as an exercise.

## Prove it

- The firing alert, the revert PR, chaos recovery times with 2 replicas vs 1, and the postmortem.

## Explain it

- SLI vs SLO vs SLA. What is an error budget for, beyond a number?
- Why alert on burn rate rather than “any error”?
- What is toil? Name one piece of toil in ADSS and how you'd remove it.
- Why blameless postmortems?

## ADSS link

ADSS has probes, Alertmanager and CronJobs restarting Debezium and eventing every 3 hours. That's toil worth discussing with Dieter: what would an SLO for eventing lag look like?
