# 2. Kubernetes

Objective: **deploy a containerised app, and manipulate resources via the API**.

## Do

1. Deploy from raw manifests and watch it come up:
   ```bash
   kubectl apply -f k8s/
   kubectl -n lab get pods -w            # READY 0/1 for ~10s: the readiness probe
   scripts/smoke-test.sh
   ```
2. Inspect what you created:
   ```bash
   kubectl -n lab describe deploy lab-app
   kubectl -n lab get rs,pods -o wide     # Deployment → ReplicaSet → Pods, spread over nodes
   kubectl -n lab get endpoints lab-app   # pod IPs behind the Service
   kubectl explain deployment.spec.strategy.rollingUpdate
   ```
3. Rolling update and rollback:
   ```bash
   kubectl -n lab set image deploy/lab-app app=lab-app:1.1.0
   kubectl -n lab rollout status deploy/lab-app
   kubectl -n lab rollout history deploy/lab-app
   kubectl -n lab rollout undo deploy/lab-app
   ```
4. Break it on purpose:
   - Set the image to `lab-app:9.9.9` (doesn't exist). What do `get pods` and `describe pod` say? Why does the app keep serving? (Hint: `maxUnavailable: 0`.) Undo.
   - Set `STARTUP_DELAY_S: "120"` in the ConfigMap, `kubectl apply`, `kubectl rollout restart`. Watch the rollout stall on readiness. Fix it.
5. Use the API directly: `scripts/k8s-api.sh` (list pods, PATCH the scale subresource, stream events).
6. Clean up before milestone 3: `kubectl delete -f k8s/`

## Prove it

- Rollout history, the stuck `ErrImagePull` rollout with the old pods still serving, and the `k8s-api.sh` output.

## Explain it

- What does the Deployment controller do when you change the image? (New ReplicaSet, scale up/down by surge rules.)
- Why does the Service find new pods without being changed? (Label selector → endpoints.)
- What is `kubectl` actually doing? (REST calls to the API server; `kubectl -v=8 get pods` shows them.)
- Requests vs limits: what happens when a container exceeds its memory limit?

## ADSS link

The backend Deployment in adss-gitops uses the same probes, a 10-minute startup window for Flyway, rolling updates and a `preStop` sleep. The eventing restart CronJob calls the same API with a narrowly-scoped Role.
