#!/usr/bin/env bash
# Install the platform pieces each milestone needs into the local cluster.
# Usage: scripts/install-platform.sh <argocd|observability|rollouts|workflows>
source "$(dirname "$0")/lib.sh"
require kubectl helm
require_kind_context

root="$(cd "$(dirname "$0")/.." && pwd)"

install_argocd() {
  log "installing Argo CD"
  kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
  log "admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
  log "UI: kubectl -n argocd port-forward svc/argocd-server 8443:443  ->  https://localhost:8443"
}

install_observability() {
  log "installing cert-manager (needed by the OpenTelemetry Operator webhooks)"
  helm repo add jetstack https://charts.jetstack.io --force-update
  helm upgrade --install cert-manager jetstack/cert-manager \
    -n cert-manager --create-namespace --set crds.enabled=true --wait

  log "installing kube-prometheus-stack (Prometheus, Alertmanager, Grafana)"
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update
  helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
    -n monitoring --create-namespace -f "$root/observability/kube-prometheus-values.yaml" --wait

  log "installing the OpenTelemetry Operator"
  helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts --force-update
  helm upgrade --install otel-operator open-telemetry/opentelemetry-operator \
    -n opentelemetry-operator-system --create-namespace \
    --set manager.collectorImage.repository=otel/opentelemetry-collector-contrib --wait

  log "installing Jaeger, the collector, the Instrumentation and the dashboard"
  kubectl apply -f "$root/observability/jaeger.yaml"
  kubectl apply -f "$root/observability/collector.yaml"
  kubectl apply -f "$root/observability/instrumentation.yaml"
  kubectl apply -f "$root/observability/dashboard.yaml"
}

install_rollouts() {
  log "installing Argo Rollouts"
  kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -
  kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
  kubectl -n argo-rollouts rollout status deploy/argo-rollouts --timeout=300s
  log "optional CLI plugin: brew install argoproj/tap/kubectl-argo-rollouts"
}

install_workflows() {
  log "installing Argo Workflows (server auth mode, local lab only)"
  helm repo add argo https://argoproj.github.io/argo-helm --force-update
  helm upgrade --install argo-workflows argo/argo-workflows \
    -n argo --create-namespace --set 'server.authModes={server}' --wait
  kubectl apply -f "$root/argo/workflows/rbac.yaml"
  log "UI: kubectl -n argo port-forward svc/argo-workflows-server 2746:2746  ->  http://localhost:2746"
}

case "${1:-}" in
  argocd)        install_argocd ;;
  observability) install_observability ;;
  rollouts)      install_rollouts ;;
  workflows)     install_workflows ;;
  *) die "usage: $0 <argocd|observability|rollouts|workflows>" ;;
esac
