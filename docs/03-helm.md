# 3. Helm

Objective: **foundational Helm**: charts, templates, values, releases.

## Do

1. Read the chart: `charts/lab-app/values.yaml`, then `templates/_helpers.tpl` (the shared pod template) and `templates/deployment.yaml`.
2. Render before you install, and compare environments:
   ```bash
   helm lint charts/lab-app
   helm template lab-app charts/lab-app -f gitops/envs/dev/values.yaml > /tmp/dev.yaml
   helm template lab-app charts/lab-app -f gitops/envs/prod/values.yaml > /tmp/prod.yaml
   diff /tmp/dev.yaml /tmp/prod.yaml
   ```
3. Install, upgrade, roll back:
   ```bash
   helm install lab-app charts/lab-app -n lab --create-namespace -f gitops/envs/dev/values.yaml
   helm upgrade lab-app charts/lab-app -n lab -f gitops/envs/dev/values.yaml --set image.tag=1.1.0
   helm history lab-app -n lab
   helm rollback lab-app 1 -n lab
   helm get values lab-app -n lab --all
   ```
4. Change `config.FAIL_RATE` with `--set` and watch the pods roll by themselves. Find out why (`checksum/config` in `_helpers.tpl`).
5. Add something small to the chart yourself, such as a `PodDisruptionBudget` behind `pdb.enabled`. Bump `version` in `Chart.yaml`.
6. Uninstall before milestone 4: `helm uninstall lab-app -n lab`

## Prove it

- The dev/prod diff, `helm history` after the rollback, and your PDB template plus its rendered output.

## Explain it

- Chart vs release vs values. `version` vs `appVersion`.
- Why does a ConfigMap change alone not restart pods, and how does the checksum annotation fix that?
- Where are release records stored? (Secrets in the namespace: `kubectl -n lab get secrets -l owner=helm`.)

## ADSS link

adss-gitops uses one `generic` chart (on bitnami `common`) for every service and a `generic-cronjob` chart; each environment supplies values. Argo CD renders them, so `helm install` is never run by hand there.
