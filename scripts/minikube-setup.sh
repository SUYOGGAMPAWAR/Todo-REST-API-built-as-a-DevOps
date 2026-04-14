#!/usr/bin/env bash
# scripts/minikube-setup.sh — Spin up a local Kubernetes cluster with minikube
set -euo pipefail

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }

log "=== Setting up Minikube for local K8s testing ==="

# Start minikube (Docker driver)
minikube start \
    --driver=docker \
    --cpus=2 \
    --memory=3g \
    --addons=ingress,metrics-server

log "Minikube started!"

# Point docker CLI to minikube's daemon (so local images work)
warn "Run this to use minikube's Docker daemon:"
echo "    eval \$(minikube docker-env)"

# Build image inside minikube
warn "Build the image inside minikube after running the above:"
echo "    docker build --target production -t todo-api:local ."

# Apply dev overlay
log "Applying dev overlay to minikube..."
kubectl apply -k k8s/overlays/dev/

# Wait
kubectl rollout status deployment/todo-api -n todo-dev --timeout=120s

# Port-forward for local testing
log "Port-forwarding service to localhost:3000 ..."
warn "Press Ctrl+C to stop forwarding"
kubectl port-forward svc/todo-api 3000:80 -n todo-dev
