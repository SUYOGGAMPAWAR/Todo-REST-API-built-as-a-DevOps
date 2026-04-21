# 🚀 DevOps Todo API — Docker · Jenkins · Kubernetes

A production-grade DevOps project featuring a Node.js REST API deployed through a full CI/CD pipeline using Docker, Jenkins, and Kubernetes (Minikube).

---

## 📁 Project Structure

```
devops-project/
├── app/
│   ├── src/
│   │   └── index.js              # Express REST API
│   ├── tests/
│   │   └── app.test.js           # Jest + Supertest tests
│   └── package.json
├── docker/
│   └── nginx.conf                # Nginx reverse proxy
├── jenkins/
│   └── casc.yaml                 # Jenkins config as code
├── k8s/
│   ├── base/                     # Shared Kubernetes manifests
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── ingress.yaml
│   │   ├── hpa.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       │   ├── namespace.yaml
│       │   └── kustomization.yaml
│       └── prod/
│           ├── namespace.yaml
│           └── kustomization.yaml
├── scripts/
│   ├── setup.sh
│   ├── deploy.sh
│   └── minikube-setup.sh
├── Dockerfile
├── docker-compose.yml
├── Jenkinsfile
└── README.md
```

---

## 📋 Prerequisites

Install all of these before starting. Run the verify command after each install.

### 1. Git
**Windows:** https://git-scm.com/download/win → run installer → keep defaults

**macOS:**
```bash
xcode-select --install
```

**Ubuntu/Linux:**
```bash
sudo apt update && sudo apt install git -y
```

✅ Verify: `git --version`

---

### 2. Node.js v20
**Windows & macOS:** https://nodejs.org → download **20.x.x LTS** → run installer

**Ubuntu/Linux:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y
```

✅ Verify: `node --version` (should show v20.x.x)

---

### 3. Docker Desktop
**Windows & macOS:** https://www.docker.com/products/docker-desktop/ → download → install → restart PC

**Ubuntu/Linux:**
```bash
sudo apt update
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo usermod -aG docker $USER && newgrp docker
```

> ⚠️ On Windows, enable **WSL 2** when prompted during install.

✅ Verify: `docker --version` and `docker compose version`

---

### 4. kubectl
**Windows (PowerShell as Admin):**
```powershell
winget install Kubernetes.kubectl
```

**macOS:**
```bash
brew install kubectl
```

**Ubuntu/Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

✅ Verify: `kubectl version --client`

---

### 5. Minikube
**Windows (PowerShell as Admin):**
```powershell
winget install Kubernetes.minikube
```

**macOS:**
```bash
brew install minikube
```

**Ubuntu/Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

✅ Verify: `minikube version`

---

### ✅ Final Prerequisites Check

Run all of these — each must print a version number:

```bash
git --version
node --version
npm --version
docker --version
docker compose version
kubectl version --client
minikube version
```

---

## 🐳 Part 1 — Run with Docker Compose

### Step 1 — Extract and enter the project

```powershell
tar -xzf devops-project.tar.gz
cd devops-project
```

### Step 2 — Fix the Dockerfile

Open `Dockerfile` and find the `deps` stage. Change `npm ci` to `npm install`:

```dockerfile
# Change this:
RUN npm ci --only=production && \
    cp -r node_modules node_modules_prod && \
    npm ci

# To this:
RUN npm install --only=production && \
    cp -r node_modules node_modules_prod && \
    npm install
```

> This is required because `npm ci` needs a `package-lock.json` file which is not included in the repo.

### Step 3 — Fix the docker-compose.yml

Open `docker-compose.yml` and change the Jenkins image from `lts-jdk17` to `lts-jdk21`:

```yaml
# Change this:
image: jenkins/jenkins:lts-jdk17

# To this:
image: jenkins/jenkins:lts-jdk21
```

> Jenkins LTS now requires Java 21 minimum. The jdk17 image will crash-loop.

### Step 4 — Remove any old leftover containers

```powershell
docker ps -a
```

If you see any old Jenkins containers (with random names like `dreamy_lederberg`, `pensive_nash`), remove them:

```powershell
docker stop <container-name>
docker rm <container-name>
```

### Step 5 — Start all services

```powershell
docker compose up -d
```

Wait about 60 seconds, then verify all 3 containers are running:

```powershell
docker ps
```

You should see:
```
NAMES
jenkins       (jenkins/jenkins:lts-jdk21)
nginx-proxy   (nginx:alpine)
todo-api      (devops-project-app)
```

### Step 6 — Install Docker inside Jenkins

This step is required every time you start the containers from scratch:

```powershell
docker exec -u 0 jenkins bash -c "apt-get update -qq && apt-get install -y docker.io && chmod 666 /var/run/docker.sock"
```

Wait 1-2 minutes. Then verify:

```powershell
docker exec jenkins docker --version
```

Expected output: `Docker version 26.x.x`

### Step 7 — Test the app

Open your browser and visit:

- http://localhost:3000/health → `{"status":"UP","version":"1.0.0-local"}`
- http://localhost:3000/ready → `{"status":"READY"}`
- http://localhost:3000/api/todos → list of todos

---

## 🏗️ Part 2 — Set Up Jenkins CI/CD Pipeline

### Step 1 — Open Jenkins

Go to http://localhost:8080

### Step 2 — Get the admin password

```powershell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy the output and paste it into the Jenkins unlock screen.

### Step 3 — Install suggested plugins

Click **"Install suggested plugins"** and wait for completion (2-5 minutes).

### Step 4 — Create admin user

Fill in username, password, and email when prompted.

### Step 5 — Install extra plugins

Go to **Manage Jenkins → Plugins → Available plugins** and install:
- `NodeJS`
- `Docker Pipeline`
- `HTML Publisher`

Check **"Restart Jenkins when installation is complete"**.

### Step 6 — Configure NodeJS tool

1. Go to **Manage Jenkins → Tools**
2. Scroll to **NodeJS installations**
3. Click **"Add NodeJS"**
4. Set **Name** to exactly: `NodeJS-20` ← case sensitive!
5. Select version **20.x.x**
6. Click **Save**

### Step 7 — Fix the Jenkinsfile

Open `Jenkinsfile` and make sure it has these exact changes:

**Change `npm ci` to `npm install` in the Install stage:**
```groovy
stage('Install') {
    steps {
        dir('app') {
            echo "📦 Installing dependencies..."
            sh 'npm install'    // NOT npm ci
        }
    }
}
```

**Make sure the environment block has NO `credentials()` calls** — only plain strings:
```groovy
environment {
    APP_NAME        = 'todo-api'
    DOCKER_REGISTRY = 'your-dockerhub-username'
    IMAGE_NAME      = "${DOCKER_REGISTRY}/${APP_NAME}"
    IMAGE_TAG       = "${env.BUILD_NUMBER}"
}
```

**Make sure the post block has a try/catch:**
```groovy
post {
    always {
        script {
            try {
                sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            } catch (err) {
                echo "Cleanup skipped: ${err.message}"
            }
        }
        cleanWs()
    }
}
```

### Step 8 — Create a Pipeline job

1. Click **"New Item"**
2. Name it `todo-api-pipeline`
3. Select **"Pipeline"** → OK
4. Scroll to **Pipeline** section
5. Set Definition to **"Pipeline script from SCM"**
6. SCM: **Git**
7. Repository URL: `https://github.com/YOUR-USERNAME/YOUR-REPO`
8. Branch Specifier: `*/main` ← NOT `refs/heads/**`
9. Script Path: `Jenkinsfile`
10. Click **Save**

### Step 9 — Run the pipeline

Click **"Build Now"**. The pipeline will run through these stages:

```
Checkout → Install → Lint → Test → Docker Build → Security Scan → (Push) → (Deploy)
```

Expected result: **9/9 tests passing**, Docker image built successfully.

> Push and Deploy stages are skipped by default (PUSH_IMAGE = false). This is correct for local development.

---

## ☸️ Part 3 — Deploy to Kubernetes (Minikube)

### Step 1 — Start Minikube

```powershell
minikube start --driver=docker --cpus=2 --memory=3g --addons=ingress,metrics-server
```

Wait 3-5 minutes for first-time setup.

### Step 2 — Fix the Kubernetes overlays

**Create `k8s/overlays/dev/namespace.yaml`:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: todo-dev
  labels:
    environment: dev
```

**Create `k8s/overlays/prod/namespace.yaml`:**
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: todo-prod
  labels:
    environment: prod
```

**Replace `k8s/base/kustomization.yaml`** — remove `namespace.yaml` from resources and fix deprecated fields:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - configmap.yaml
  - deployment.yaml
  - service.yaml
  - ingress.yaml
  - hpa.yaml

labels:
  - pairs:
      app: todo-api
      managed-by: kustomize
    includeSelectors: false
```

**Replace `k8s/overlays/dev/kustomization.yaml`:**
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: todo-dev

resources:
  - namespace.yaml
  - ../../base

images:
  - name: todo-api
    newTag: local

patches:
  - patch: |-
      - op: replace
        path: /spec/replicas
        value: 1
    target:
      kind: Deployment
      name: todo-api

configMapGenerator:
  - name: todo-api-config
    behavior: merge
    literals:
      - NODE_ENV=development
      - APP_VERSION=dev
```

### Step 3 — Point Docker to Minikube's engine

**Windows (PowerShell):**
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

**Mac/Linux:**
```bash
eval $(minikube docker-env)
```

> ⚠️ Run this in the **same terminal** you'll use for the next steps. Must be repeated every time you open a new terminal.

### Step 4 — Build the image inside Minikube

```powershell
docker build --target production -t todo-api:local .
```

### Step 5 — Deploy to Kubernetes

```powershell
kubectl apply -k k8s/overlays/dev/
```

### Step 6 — Fix the image reference

The deployment still has the placeholder image name. Fix it:

```powershell
kubectl set image deployment/todo-api todo-api=todo-api:local -n todo-dev
```

Set the pull policy to never pull from internet (use local image):

```powershell
kubectl patch deployment todo-api -n todo-dev -p '{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"todo-api\",\"imagePullPolicy\":\"Never\"}]}}}}'
```

### Step 7 — Wait for pod to be Running

```powershell
kubectl get pods -n todo-dev -w
```

Wait until STATUS shows `Running`. Press `Ctrl+C` to stop watching.

```
NAME                        READY   STATUS    RESTARTS   AGE
todo-api-xxxxxxxxx-xxxxx    1/1     Running   0          30s
```

### Step 8 — Port-forward and access the app

```powershell
kubectl port-forward svc/todo-api 3000:80 -n todo-dev
```

Open your browser: http://localhost:3000/health

Expected: `{"status":"UP","version":"1.0.0-local","timestamp":"..."}`

---

## 🧪 Testing the API

### Browser
- http://localhost:3000/health
- http://localhost:3000/ready
- http://localhost:3000/api/todos

### PowerShell

```powershell
# Get all todos
Invoke-WebRequest -Uri http://localhost:3000/api/todos -Method GET

# Create a new todo
Invoke-WebRequest -Uri http://localhost:3000/api/todos -Method POST -ContentType "application/json" -Body '{"title": "My first todo!"}'

# Update a todo (use the id from the create response)
Invoke-WebRequest -Uri http://localhost:3000/api/todos/4 -Method PUT -ContentType "application/json" -Body '{"completed": true}'

# Delete a todo
Invoke-WebRequest -Uri http://localhost:3000/api/todos/4 -Method DELETE
```

### Mac/Linux (curl)
```bash
curl http://localhost:3000/api/todos
curl -X POST http://localhost:3000/api/todos -H "Content-Type: application/json" -d '{"title":"My todo"}'
curl -X PUT http://localhost:3000/api/todos/4 -H "Content-Type: application/json" -d '{"completed":true}'
curl -X DELETE http://localhost:3000/api/todos/4
```

---

## 📊 Useful Commands

### Docker
```powershell
docker ps                          # list running containers
docker compose up -d               # start all services
docker compose down                # stop all services
docker compose logs -f app         # view app logs
docker compose logs -f jenkins     # view jenkins logs
```

### Kubernetes
```powershell
kubectl get pods -n todo-dev                    # list pods
kubectl get pods -n todo-dev -w                 # watch pods live
kubectl describe pod -n todo-dev               # debug a pod
kubectl logs -n todo-dev <pod-name>            # view pod logs
kubectl get svc -n todo-dev                    # list services
kubectl rollout status deployment/todo-api -n todo-dev  # check rollout
```

### Minikube
```powershell
minikube start                     # start cluster
minikube stop                      # stop cluster
minikube status                    # check status
minikube dashboard                 # open K8s dashboard in browser
```

---

## ⚠️ Important Notes

| Situation | What to do |
|-----------|-----------|
| Restarted Docker Desktop | Run `docker compose up -d` then re-install Docker in Jenkins |
| Jenkins can't find `docker` | Run: `docker exec -u 0 jenkins bash -c "apt-get update -qq && apt-get install -y docker.io && chmod 666 /var/run/docker.sock"` |
| Pod stuck in `ImagePullBackOff` | Run `kubectl set image` and `kubectl patch` commands from Part 3 Step 6 |
| Port-forward stopped | Re-run `kubectl port-forward svc/todo-api 3000:80 -n todo-dev` |
| New terminal for Minikube | Re-run `& minikube -p minikube docker-env --shell powershell | Invoke-Expression` |
| Pipeline fails on `npm ci` | Make sure Jenkinsfile uses `npm install` not `npm ci` |
| Jenkins NodeJS error | Go to Manage Jenkins → Tools → Add NodeJS installation named `NodeJS-20` |
| Branch specifier error | Set branch to `*/main` not `refs/heads/**` |

---

## 🏗️ Architecture

```
Developer → GitHub → Jenkins (CI/CD)
                          │
              ┌───────────┴────────────┐
              │                        │
         npm install              Docker Build
         npm test                 Trivy Scan
         (9 tests pass)           Push to Hub
              │                        │
              └───────────┬────────────┘
                          │
                   kubectl apply
                          │
              ┌───────────▼────────────┐
              │   Kubernetes (Minikube) │
              │                        │
              │  ┌──────┐  ┌──────┐   │
              │  │ Pod  │  │ Pod  │   │ ← HPA scales 2-10
              │  └──┬───┘  └──┬───┘   │
              │     └────┬────┘        │
              │       Service          │
              │          │             │
              │       Ingress          │
              └───────────────────────┘
                          │
                   localhost:3000
```

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Application | Node.js 20, Express 4 |
| Testing | Jest, Supertest |
| Containerization | Docker (multi-stage), Docker Compose |
| Reverse Proxy | Nginx |
| CI/CD | Jenkins (Declarative Pipeline) |
| Orchestration | Kubernetes + Kustomize |
| Auto-scaling | Horizontal Pod Autoscaler (HPA) |
| Security Scan | Trivy (Aqua Security) |
| Local K8s | Minikube |

---

## 📄 API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Liveness probe — returns `{"status":"UP"}` |
| GET | `/ready` | Readiness probe — returns `{"status":"READY"}` |
| GET | `/api/todos` | Get all todos |
| GET | `/api/todos/:id` | Get one todo |
| POST | `/api/todos` | Create todo — body: `{"title":"..."}` |
| PUT | `/api/todos/:id` | Update todo — body: `{"completed":true}` |
| DELETE | `/api/todos/:id` | Delete todo |

---

*DevOps Internship Project — Savitribai Phule Pune University 2025-26*
*Dr. D.Y. Patil Technical Campus, Talegaon Dabhade, Pune*
