# 7. Argo Rollouts and Argo Workflows

Objective: **Argo for complex deployments and workflows**.

## Do: progressive delivery with Rollouts

1. Install: `scripts/install-platform.sh rollouts`
2. In a PR to `staging`, switch dev to a canary with automatic analysis:
   ```yaml
   rollout:
     enabled: true
     analysis:
       enabled: true
   ```
   After the sync, the Deployment is pruned and a Rollout replaces it.
3. **Good release:** build a new version (`scripts/build-load.sh 1.2.0`), then set `image.tag: "1.2.0"` by PR. Start `APP_NS=lab-dev scripts/load.sh 600 5` and watch: `kubectl argo rollouts get rollout lab-app -n lab-dev --watch`. At the manual pause, promote it: `kubectl argo rollouts promote lab-app -n lab-dev`.
4. **Bad release:** by PR, set `config.FAIL_RATE: "0.4"`. The config checksum changes the pod template, so this starts a canary. Only the new pods read the new value, because env vars are read at start. Keep load running. Watch the analysis fail and the Rollout abort back to the stable pods without you touching anything.

   Without a service mesh, Rollouts sets the canary weight by pod count, so 25% means about 1 new pod. Explain why a mesh or ingress would make the weights exact.
5. Revert the bad PR in git so git matches what's running.

## Do: pipelines with Workflows

1. Install: `scripts/install-platform.sh workflows`
2. Submit the CI DAG: `argo submit -n argo argo/workflows/ci-dag.yaml -p repo=https://github.com/<you>/sedp-devops-lab.git --watch`
3. Open the UI and look at the DAG: shellcheck and unit tests run in parallel, and helm-lint waits for both.
4. Break a test on a branch, run the workflow with `-p revision=<branch>` and see where it stops.

## Prove it

- Rollout screenshots (paused at 25%, then aborted with the analysis result), and the workflow DAG green, then red.

## Explain it

- Rolling update vs canary vs blue-green: what does each risk, and what does each cost?
- What did the AnalysisTemplate measure, and why is that better than a human watching a dashboard?
- Argo CD vs Rollouts vs Workflows: what does each do and how do they fit together?
- Steps vs DAG in a workflow.

## ADSS link

ADSS uses Argo CD and Image Updater. Ask Dieter how ADSS uses Argo Workflows, and whether canaries would suit the backend, given Flyway migrations run at startup.
