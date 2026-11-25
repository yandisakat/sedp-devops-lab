# 0. Setup

## Do

1. Install tools (macOS):
   ```bash
   brew install kind kubectl helm jq shellcheck argocd argo
   ```
   Plus a Docker runtime: Docker Desktop, OrbStack or Colima. Give it at least 4 CPUs and 8 GB RAM; milestone 5 runs Prometheus and Grafana.
2. Check: `scripts/check-prereqs.sh`
3. Create a **public** GitHub repo `sedp-devops-lab` under your own account and push this folder:
   ```bash
   git init -b main && git add . && git commit -m "Initial lab scaffold"
   git remote add origin https://github.com/<you>/sedp-devops-lab.git
   git push -u origin main
   git switch -c staging && git push -u origin staging
   ```
4. In GitHub settings, protect `main` and `staging`: require a pull request and the `ci` check.
5. Replace `YOUR_GITHUB_USER` in `gitops/argocd/*.yaml` and `argo/workflows/ci-dag.yaml` (on a branch, via PR, to practise the flow).
6. Create the cluster: `scripts/cluster-up.sh`

## Prove it

- `kubectl get nodes` showing 3 nodes.
- Screenshot of the branch protection rules.

## Explain it

- Why kind for a lab, and what's different from EKS? (Networking, load balancers, IAM, node groups.)
- Why protect `main` and `staging`? (Every change gets reviewed and tested; the branch *is* the environment.)
