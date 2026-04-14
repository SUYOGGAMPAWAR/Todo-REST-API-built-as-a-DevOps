# 🚀 DevOps Todo API — Full CI/CD Project

> A production-grade DevOps project demonstrating **Docker**, **Jenkins CI/CD**, and **Kubernetes** orchestration for a Node.js REST API.

---

## 📐 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Machine                        │
│                                                                 │
│   git push ──────────────────────► GitHub / GitLab             │
│                                           │                     │
└───────────────────────────────────────────┼─────────────────────┘
                                            │ Webhook
                                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Jenkins (CI/CD)                          │
│                                                                 │
│  1. Checkout  →  2. Install  →  3. Lint  →  4. Test            │
│       │                                        │                │
│       └──────────► 5. Docker Build             │                │
│                          │        ◄────────────┘                │
│                    6. Trivy Scan                                 │
│                          │                                      │
│                    7. Push to Registry ──────► Docker Hub       │
│                          │                                      │
│                    8. kubectl apply ──────────► Kubernetes      │
│                          │                                      │
│                    9. Smoke Test                                 │
└─────────────────────────────────────────────────────────────────┘
                                            │
                                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                           │
│                                                                 │
│  ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│  │  Pod 1   │     │  Pod 2   │     │  Pod N   │  ← HPA scales │
│  │ todo-api │     │ todo-api │     │ todo-api │                │
│  └────┬─────┘     └────┬─────┘     └────┬─────┘               │
│       └────────────────┴────────────────┘                      │
│                         │                                       │
│                    ┌────┴────┐                                  │
│                    │ Service │                                  │
│                    └────┬────┘                                  │
│                         │                                       │
│                    ┌────┴────┐                                  │
│                    │ Ingress │ ← todo-api.local                 │
│                    └─────────┘                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
devops-project/
├── app/                          # Node.js Express application
│   ├── src/
│   │   └── index.js              # Main app (Express REST API)
│   ├── tests/
│   │   └── app.test.js           # Jest unit + integration tests
│   └── package.json
│
├── docker/
│   └── nginx.conf                # Nginx reverse proxy config
│
├── jenkins/
│   └── casc.yaml                 # Jenkins Configuration as Code
│
├── k8s/
│   ├── base/                     # Shared K8s manifests
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml       # With liveness/readiness/startup probes
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml              # Horizontal Pod Autoscaler
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/                  # Dev environment (1 replica)
│       │   └── kustomization.yaml
│       └── prod/                 # Prod environment (3 replicas)
│           └── kustomization.yaml
│
├── scripts/
│   └── setup.sh                  # One-shot local bootstrap
│
├── Dockerfile                    # Multi-stage build (deps → test → prod)
├── docker-compose.yml            # Local dev: app + jenkins + nginx
├── Jenkinsfile                   # Declarative pipeline (9 stages)
└── README.md
```

---

## 🐳 Docker

### Multi-Stage Dockerfile
The `Dockerfile` uses **three stages** for an optimized, secure image:

| Stage | Purpose |
|-------|---------|
| `deps` | Install all npm dependencies with caching |
| `test` | Run tests — fails the build if tests fail |
| `production` | Lean image with only prod deps, runs as non-root |

```bash
# Build production image
docker build --target production -t todo-api:latest .

# Run the container
docker run -p 3000:3000 todo-api:latest

# Check health
curl http://localhost:3000/health
```

### Docker Compose (local dev)
Runs three services: the app, Jenkins, and Nginx proxy.

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop everything
docker-compose down
```

| Service | Port | URL |
|---------|------|-----|
| App (Node.js) | 3000 | http://localhost:3000 |
| Nginx (proxy) | 80 | http://localhost |
| Jenkins | 8080 | http://localhost:8080 |

---

## 🏗 Jenkins CI/CD Pipeline

### Pipeline Stages

```
Checkout → Install → Lint → Test → Docker Build → Security Scan → Push → Deploy → Smoke Test
```

| Stage | What it does |
|-------|-------------|
| **Checkout** | Clones the repo, captures git metadata |
| **Install** | `npm ci` — clean, reproducible install |
| **Lint** | Syntax check (plug in ESLint for full linting) |
| **Test** | Jest with coverage; publishes HTML report |
| **Docker Build** | Multi-stage build with build args |
| **Security Scan** | Trivy image vulnerability scan |
| **Push Image** | Pushes tagged + `latest` to Docker Hub |
| **Deploy** | `kubectl apply -k` via kustomize overlay |
| **Smoke Test** | Hits `/health` post-deploy |

### Setup Jenkins

1. Start Jenkins via Docker Compose:
   ```bash
   docker-compose up -d jenkins
   ```
2. Get the initial admin password:
   ```bash
   docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
   ```
3. Navigate to http://localhost:8080, complete setup wizard.
4. Install plugins: **Pipeline**, **NodeJS**, **Docker Pipeline**, **HTML Publisher**, **Kubernetes CLI**.
5. Add credentials:
   - `dockerhub-creds` — Docker Hub username/token
   - `kubeconfig` — your `~/.kube/config` file
6. Create a **Pipeline** job pointing to this repository.

---

## ☸️ Kubernetes

### What's Included

| Manifest | Description |
|----------|-------------|
| `namespace.yaml` | Separate namespaces for dev and prod |
| `configmap.yaml` | App environment variables |
| `deployment.yaml` | Rolling update strategy, probes, security contexts |
| `service.yaml` | ClusterIP service |
| `ingress.yaml` | Nginx ingress (host-based routing) |
| `hpa.yaml` | Auto-scales 2–10 pods based on CPU/memory |

### Deployment with Kustomize

```bash
# Deploy to dev
kubectl apply -k k8s/overlays/dev/

# Deploy to prod
kubectl apply -k k8s/overlays/prod/

# Watch rollout
kubectl rollout status deployment/todo-api -n todo-dev

# Scale manually
kubectl scale deployment todo-api --replicas=5 -n todo-prod

# View pods
kubectl get pods -n todo-dev -w
```

### Probes (Health Checks)

| Probe | Path | Purpose |
|-------|------|---------|
| **Liveness** | `/health` | Restart container if unhealthy |
| **Readiness** | `/ready` | Remove from load balancer until ready |
| **Startup** | `/health` | Give slow-starting containers time |

---

## 🧪 API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness probe |
| GET | `/api/todos` | List all todos |
| GET | `/api/todos/:id` | Get single todo |
| POST | `/api/todos` | Create todo `{"title": "..."}` |
| PUT | `/api/todos/:id` | Update todo |
| DELETE | `/api/todos/:id` | Delete todo |

```bash
# Example API calls
curl http://localhost:3000/api/todos
curl -X POST http://localhost:3000/api/todos -H "Content-Type: application/json" -d '{"title":"Deploy to prod"}'
curl -X PUT http://localhost:3000/api/todos/1 -H "Content-Type: application/json" -d '{"completed":true}'
curl -X DELETE http://localhost:3000/api/todos/1
```

---

## 🚀 Quick Start

```bash
# 1. Clone and enter the project
git clone <your-repo> && cd devops-project

# 2. Run the one-shot setup script
chmod +x scripts/setup.sh && ./scripts/setup.sh

# 3. App is live at:
#    http://localhost:3000  (direct)
#    http://localhost:80    (via Nginx)
#    http://localhost:8080  (Jenkins)
```

---

## 🔑 Key DevOps Concepts Demonstrated

- **Infrastructure as Code** — all config is version-controlled
- **Multi-stage Docker builds** — minimal, secure production images
- **CI/CD Pipeline** — automated test → build → push → deploy
- **GitOps with Kustomize** — environment-specific overlays without duplication
- **Zero-downtime deployments** — rolling updates with `maxUnavailable: 0`
- **Horizontal scaling** — HPA auto-scales based on CPU/memory
- **Security hardening** — non-root containers, read-only filesystem, dropped capabilities
- **Observability** — health/ready/startup probes, Prometheus annotations
- **Reverse proxy** — Nginx with rate limiting in front of the app

---

## 📋 Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Docker | ≥ 24 | https://docs.docker.com/get-docker/ |
| Docker Compose | ≥ 2 | Bundled with Docker Desktop |
| Node.js | ≥ 20 | https://nodejs.org |
| kubectl | ≥ 1.28 | https://kubernetes.io/docs/tasks/tools/ |
| minikube (local K8s) | ≥ 1.32 | https://minikube.sigs.k8s.io |
