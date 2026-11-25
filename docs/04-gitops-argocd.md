# 4. GitOps with Argo CD

Objectives: **GitOps** (deploy with a pull request) and the first part of **Argo**.

From here on, **never `kubectl apply` or `helm install` the app by hand**. Git is the only way in.

## Do

1. Install: `scripts/install-platform.sh argocd`. Log in to the UI (the script prints how).
2. Create both environments: `kubectl apply -f gitops/argocd/`
   - `lab-app-dev` follows the `staging` branch → namespace `lab-dev`
   - `lab-app-prod` follows `main` → namespace `lab-prod`
3. **Deploy by PR:** on a feature branch, change `image.tag` to `"1.1.0"` in `gitops/envs/dev/values.yaml` and open a PR to `staging`. Merge it, then watch Argo CD sync (`argocd app get lab-app-dev`, or the UI). Check it: `APP_NS=lab-dev scripts/smoke-test.sh`
4. **Drift and self-heal:** `kubectl -n lab-dev scale deploy/lab-app --replicas=5`. Watch Argo CD put it back to 2. Then `kubectl -n lab-dev delete svc lab-app` and watch it come back.
5. **Prune:** in a PR, set `pdb.enabled: true` (the PodDisruptionBudget you added in milestone 3) and merge. Then set it back to `false` and watch Argo CD delete the object, because git no longer declares it.
6. **Rollback = `git revert`:** merge a PR with a bad tag (`9.9.9`). See the app go Degraded while the old pods keep serving. `git revert` the merge commit in a new PR and merge it.
7. **Promote:** open a PR from `staging` to `main`. Merge it and watch `lab-app-prod` sync with 3 replicas.

## Prove it

- PR links for each step, Argo CD screenshots (Synced/Healthy, then OutOfSync, Degraded), and `argocd app history lab-app-dev`.

## Explain it

- The four GitOps principles: declarative, versioned, pulled, continuously reconciled. Where did you see each?
- Push vs pull deployment: why doesn't CI need cluster credentials here?
- What are `selfHeal` and `prune`, and when would you turn them off?
- Why environment branches? What's the trade-off against environment folders on one branch?

## ADSS link

adss-gitops uses environment branches, Argo CD with `selfHeal` and `prune`, Image Updater writing new tags to `staging`, and an Auto-PR promoting to `main`. Production only accepts `vX.Y.Z` tags.
