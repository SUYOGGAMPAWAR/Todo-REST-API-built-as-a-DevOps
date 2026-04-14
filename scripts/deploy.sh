#!/usr/bin/env bash
# scripts/deploy.sh — Deploy to Kubernetes via kustomize
# Usage: ./scripts/deploy.sh [dev|prod] [image-tag]

set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
die()  { echo -e "${RED}[✗]${NC} $1"; exit 1; }

ENV=${1:-dev}
TAG=${2:-latest}

[[ "$ENV" =~ ^(dev|prod)$ ]] || die "Environment must be 'dev' or 'prod'. Got: $ENV"

OVERLAY="k8s/overlays/${ENV}"
NAMESPACE="todo-${ENV}"

log "=== Deploying todo-api to ${ENV} (tag: ${TAG}) ==="

# Patch image tag
sed -i.bak "s|IMAGE_TAG_PLACEHOLDER|${TAG}|g" "${OVERLAY}/kustomization.yaml"

# Apply
log "Applying manifests from ${OVERLAY}..."
kubectl apply -k "${OVERLAY}/"

# Restore placeholder (for next deploy / git cleanliness)
sed -i.bak "s|${TAG}|IMAGE_TAG_PLACEHOLDER|g" "${OVERLAY}/kustomization.yaml"
rm -f "${OVERLAY}/kustomization.yaml.bak"

# Wait for rollout
log "Waiting for rollout to complete..."
kubectl rollout status deployment/todo-api \
    -n "${NAMESPACE}" \
    --timeout=120s

echo ""
log "=== Deployment complete! ==="
echo ""
kubectl get pods -n "${NAMESPACE}" -o wide
echo ""
kubectl get svc  -n "${NAMESPACE}"
