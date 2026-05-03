# 🚀 DevOps Todo API — Complete Beginner's Guide

> **A full DevOps project using Docker, Jenkins, and Kubernetes — explained so clearly that anyone can follow it, even with zero prior experience.**

---

## 📖 Table of Contents

1. [What is this project?](#1-what-is-this-project)
2. [What will you learn?](#2-what-will-you-learn)
3. [Tools you need to install](#3-tools-you-need-to-install)
4. [Understanding the project structure](#4-understanding-the-project-structure)
5. [Part 1 — Running with Docker Compose](#5-part-1--running-with-docker-compose)
6. [Part 2 — Setting up Jenkins CI/CD](#6-part-2--setting-up-jenkins-cicd)
7. [Part 3 — Deploying to Kubernetes](#7-part-3--deploying-to-kubernetes)
8. [Part 4 — Making it public with ngrok](#8-part-4--making-it-public-with-ngrok)
9. [Testing the API](#9-testing-the-api)
10. [Using the Calendar UI](#10-using-the-calendar-ui)
11. [Daily startup checklist](#11-daily-startup-checklist)
12. [Useful commands cheat sheet](#12-useful-commands-cheat-sheet)
13. [How everything connects](#13-how-everything-connects)
14. [Tech stack explained](#14-tech-stack-explained)

---

## 1. What is this project?

This project is a **Todo REST API** — a backend service that lets you create, read, update and delete todo tasks. But the real point of this project is **not** the Todo app itself. The point is everything around it:

- **Docker** packages the app into a container so it runs the same way on every computer
- **Jenkins** automatically runs tests, builds the Docker image, and deploys it every time you push code
- **Kubernetes** runs your containers in a cluster, restarts them if they crash, and scales them when traffic increases
- **ngrok** gives your locally running app a public URL so anyone can access it from their phone or laptop

Think of it like this:

```
Your Code → Jenkins tests it → Docker packages it → Kubernetes runs it → ngrok shares it
```

This is exactly how real companies like Swiggy, Zomato, and Razorpay ship their software.

---

## 2. What will you learn?

By completing this project you will understand:

- How to write a REST API with Node.js and Express
- How to write automated tests with Jest
- How to containerize an app with Docker (multi-stage builds)
- How to use Docker Compose to run multiple services together
- How to set up a Jenkins CI/CD pipeline from scratch
- What a Jenkinsfile is and how to write one
- How Kubernetes works (Deployments, Services, Ingress, HPA, ConfigMaps)
- How Kustomize manages different environments (dev vs prod)
- How to expose a local app to the internet with ngrok

---

## 3. Tools you need to install

Install these one by one. Do not skip any.

---

### 🔧 Git

Git lets you download the project from GitHub and track code changes.

**Windows:**
1. Go to https://git-scm.com/download/win
2. Download the installer and run it
3. Keep clicking **Next** — all default options are fine
4. Click **Finish**

**macOS:**
Open Terminal and run:
```bash
xcode-select --install
```

**Ubuntu/Linux:**
```bash
sudo apt update && sudo apt install git -y
```

✅ **Verify:** Open a terminal and run `git --version`
You should see something like: `git version 2.43.0`

---

### 🔧 Node.js v20

Node.js runs the JavaScript application.

**Windows & macOS:**
1. Go to https://nodejs.org
2. Click the big green button that says **"20.x.x LTS"**
3. Download and run the installer
4. Keep clicking **Next** — defaults are fine

**Ubuntu/Linux:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y
```

✅ **Verify:** Run `node --version`
You should see: `v20.x.x`

---

### 🔧 Docker Desktop

Docker is the most important tool in this project. It packages your app into containers.

**Windows:**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click **"Download for Windows"**
3. Run the installer
4. When asked, make sure **"Use WSL 2"** is checked ✅
5. **Restart your computer** when asked
6. After restart, open Docker Desktop from the Start menu
7. Wait for the whale icon 🐳 in the bottom-right taskbar to stop animating

> ⚠️ **Important:** Docker Desktop must be open and running EVERY TIME you want to use Docker commands. If you see errors like "cannot connect to Docker daemon", just open Docker Desktop and wait for it to start.

**macOS:**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click **"Download for Mac"**
3. If your Mac has an M1/M2/M3 chip, choose **Apple Silicon**. Otherwise choose **Intel**
4. Open the downloaded `.dmg` file and drag Docker to Applications
5. Open Docker from Applications and wait for the whale in the menu bar to stop animating

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

✅ **Verify:** Run `docker --version`
You should see: `Docker version 26.x.x`

Also verify Compose: `docker compose version`
You should see: `Docker Compose version v2.x.x`

---

### 🔧 kubectl

kubectl (say "kube-control") is the command line tool that talks to Kubernetes.

**Windows (run PowerShell as Administrator):**
```powershell
winget install Kubernetes.kubectl
```

**macOS:**
```bash
brew install kubectl
```
> If you don't have Homebrew, install it first from https://brew.sh

**Ubuntu/Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

✅ **Verify:** Run `kubectl version --client`
You should see: `Client Version: v1.28.x`

---

### 🔧 Minikube

Minikube creates a mini Kubernetes cluster right on your laptop for testing.

**Windows (run PowerShell as Administrator):**
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

✅ **Verify:** Run `minikube version`
You should see: `minikube version: v1.32.x`

---

### 🔧 ngrok

ngrok gives your local app a public URL that anyone can access.

1. Go to https://ngrok.com and click **"Sign up for free"**
2. Verify your email
3. Go to https://ngrok.com/download and download for Windows
4. Extract the zip file — you get a file called `ngrok.exe`
5. Move `ngrok.exe` into your `devops-project` folder

✅ **Verify:** In PowerShell, navigate to your project folder and run `.\ngrok --version`

---

### ✅ Final check — verify all tools

Run each of these. Every single one must show a version number:

```bash
git --version
node --version
npm --version
docker --version
docker compose version
kubectl version --client
minikube version
```

If any command says **"not recognized"** or **"command not found"** — go back and reinstall that tool.

---

## 4. Understanding the Project Structure

Before we start, let's understand what each file and folder does:

```
devops-project/
│
├── app/                      ← The actual Node.js application
│   ├── src/
│   │   └── index.js          ← Main file — the Express REST API
│   ├── tests/
│   │   └── app.test.js       ← Automated tests (9 tests)
│   └── package.json          ← Lists all npm dependencies
│
├── docker/
│   └── nginx.conf            ← Nginx reverse proxy configuration
│
├── jenkins/
│   └── casc.yaml             ← Jenkins auto-configuration file
│
├── k8s/                      ← All Kubernetes configuration files
│   ├── base/                 ← Base config shared by all environments
│   │   ├── deployment.yaml   ← How to run the app in Kubernetes
│   │   ├── service.yaml      ← How to expose the app inside the cluster
│   │   ├── ingress.yaml      ← How to expose the app to the outside
│   │   ├── hpa.yaml          ← Auto-scaling configuration
│   │   ├── configmap.yaml    ← Environment variables
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/              ← Dev-specific settings (1 replica)
│       │   ├── namespace.yaml
│       │   └── kustomization.yaml
│       └── prod/             ← Prod-specific settings (3 replicas)
│           ├── namespace.yaml
│           └── kustomization.yaml
│
├── scripts/
│   ├── setup.sh              ← One-command setup script
│   ├── deploy.sh             ← Deploy to Kubernetes
│   └── minikube-setup.sh     ← Set up local Kubernetes
│
├── Dockerfile                ← Instructions to build the Docker image
├── docker-compose.yml        ← Runs app + Jenkins + Nginx together
├── Jenkinsfile               ← The CI/CD pipeline definition
├── todo-app-ui.html          ← The visual calendar UI
└── README.md                 ← This file
```

**Key concept:** The same application code runs in all three ways:
- Locally via `docker compose` for development
- Via Jenkins for automated testing and building
- Via Kubernetes for production-like deployment

---

## 5. Part 1 — Running with Docker Compose

This is the easiest way to get everything running. One command starts three services:
- **app** — the Todo API on port 3000
- **jenkins** — the CI/CD server on port 8080
- **nginx** — a reverse proxy on port 80

### Step 1 — Download the project

```powershell
# Extract the zip/tar file
tar -xzf devops-project.tar.gz

# Go into the project folder
cd devops-project
```

### Step 2 — Make sure Docker Desktop is running

Open Docker Desktop from the Start menu. Wait for the whale icon 🐳 in the taskbar to stop moving. Do not proceed until it is completely still.

### Step 3 — Start all services

```powershell
docker compose up -d
```

The `-d` flag means "detached" — it runs in the background. The first time you run this it will download Docker images from the internet which takes **3-10 minutes** depending on your internet speed. This is normal.

When it finishes you should see:
```
✔ Container jenkins      Running
✔ Container todo-api     Running
✔ Container nginx-proxy  Running
```

### Step 4 — Install Docker inside Jenkins

This is a required step every time you start fresh containers. Jenkins needs Docker to build images:

```powershell
docker exec -u 0 jenkins bash -c "apt-get update -qq && apt-get install -y docker.io && chmod 666 /var/run/docker.sock"
```

This will print a lot of text and take 1-2 minutes. Wait for it to finish and return to the prompt.

### Step 5 — Verify the app is running

Open your browser and go to: http://localhost:3000/health

You should see:
```json
{"status":"UP","version":"1.0.0-local","timestamp":"2026-04-23T..."}
```

🎉 **Your app is running!**

Also check these URLs:
- http://localhost:3000/ready → `{"status":"READY"}`
- http://localhost:3000/api/todos → list of todo items
- http://localhost:8080 → Jenkins dashboard

---

## 6. Part 2 — Setting up Jenkins CI/CD

Jenkins is a server that automatically runs your tests, builds your Docker image, and deploys your app every time you push code. Think of it as your robot developer.

### Step 1 — Open Jenkins

Go to http://localhost:8080 in your browser.

### Step 2 — Get the initial admin password

Jenkins creates a random password the first time it starts. Run this to see it:

```powershell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

It will print something like: `a3f8b2c1d4e5f6a7b8c9d0e1f2a3b4c5`

Copy that entire string.

### Step 3 — Unlock Jenkins

1. Paste the password into the **"Administrator password"** box on the Jenkins page
2. Click **"Continue"**

### Step 4 — Install suggested plugins

1. Click **"Install suggested plugins"**
2. A progress screen appears — wait for all plugins to finish downloading (2-5 minutes)
3. Do not close the browser

### Step 5 — Create your admin user

Fill in:
- **Username:** admin (or any name you like)
- **Password:** choose something you'll remember
- **Full name:** your name
- **Email:** your email

Click **"Save and Continue"** then **"Save and Finish"** then **"Start using Jenkins"**

### Step 6 — Install extra plugins

1. Click **"Manage Jenkins"** in the left sidebar
2. Click **"Plugins"**
3. Click **"Available plugins"** tab
4. Search for and check each of these one by one:
   - `NodeJS`
   - `Docker Pipeline`
   - `HTML Publisher`
5. Click **"Install"** at the bottom
6. Check **"Restart Jenkins when installation is complete"**
7. Wait for Jenkins to restart (1-2 minutes)

### Step 7 — Configure NodeJS

This tells Jenkins which version of Node.js to use when running tests:

1. Click **"Manage Jenkins"** → **"Tools"**
2. Scroll all the way down to **"NodeJS installations"**
3. Click **"Add NodeJS"**
4. In the **Name** field type exactly: `NodeJS-20` ← capital N, capital J, hyphen, 20
5. In the **Version** dropdown select: `NodeJS 20.x.x`
6. Click **"Save"** at the bottom

### Step 8 — Create a Pipeline job

A Pipeline job is what runs your CI/CD stages:

1. Click **"New Item"** on the Jenkins home page
2. Type `todo-api-pipeline` in the name field
3. Click **"Pipeline"** (not Freestyle)
4. Click **"OK"**
5. Scroll down to the **"Pipeline"** section
6. Change **Definition** dropdown to: **"Pipeline script from SCM"**
7. Change **SCM** to: **"Git"**
8. In **Repository URL** paste your GitHub repo URL:
   `https://github.com/SUYOGGAMPAWAR/Todo-REST-API-built-as-a-DevOps`
9. In **Branch Specifier** type: `*/main` ← must be exactly this
10. **Script Path** should already say: `Jenkinsfile` ← leave it as is
11. Click **"Save"**

### Step 9 — Run the pipeline

1. Click **"Build Now"** in the left sidebar
2. A new build appears under **"Build History"**
3. Click on it to open it
4. Click **"Console Output"** to watch the stages run live

The pipeline runs these 9 stages:
```
✅ Checkout     — downloads your code from GitHub
✅ Install      — runs npm install
✅ Lint         — checks for syntax errors
✅ Test         — runs all 9 tests
✅ Docker Build — builds the Docker image
✅ Security Scan — scans for vulnerabilities
⏭  Push Image   — skipped (you haven't set up Docker Hub yet)
⏭  Deploy       — skipped (requires push)
```

**All green = success** 🎉

---

## 7. Part 3 — Deploying to Kubernetes

Kubernetes runs your Docker containers in a cluster. Minikube creates a mini cluster on your own laptop.

### Step 1 — Start Minikube

```powershell
minikube start --driver=docker --cpus=2 --memory=3g --addons=ingress,metrics-server
```

This creates a Kubernetes cluster inside Docker. First time takes **3-5 minutes**. You'll see a progress bar. When done you'll see:
```
✅  Done! kubectl is now configured to use "minikube" cluster
```

### Step 2 — Point Docker to Minikube's engine

This is a critical step. It makes Docker commands run inside Minikube instead of on your host machine:

**Windows (PowerShell):**
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

**Mac/Linux:**
```bash
eval $(minikube docker-env)
```

> ⚠️ **Important:** You must run this command in the SAME terminal window you use for the next steps. If you open a new terminal, run it again.

### Step 3 — Build the Docker image inside Minikube

```powershell
docker build --target production -t todo-api:local .
```

This builds your app's Docker image. Takes about 60-90 seconds.

### Step 4 — Fix the Kubernetes overlay files

The kustomization files need to be updated. Open `k8s/overlays/dev/kustomization.yaml` in Notepad or VS Code and make sure it looks exactly like this:

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

### Step 5 — Deploy to Kubernetes

```powershell
kubectl apply -k k8s/overlays/dev/
```

You should see:
```
namespace/todo-dev created
configmap/todo-api-config created
deployment.apps/todo-api created
service/todo-api created
ingress.networking.k8s.io/todo-api-ingress created
horizontalpodautoscaler.autoscaling/todo-api-hpa created
```

### Step 6 — Point the deployment to your local image

The deployment still has a placeholder image name. Fix it with these two commands:

```powershell
kubectl set image deployment/todo-api todo-api=todo-api:local -n todo-dev
```

```powershell
kubectl patch deployment todo-api -n todo-dev -p '{\"spec\":{\"template\":{\"spec\":{\"containers\":[{\"name\":\"todo-api\",\"imagePullPolicy\":\"Never\"}]}}}}'
```

### Step 7 — Wait for the pod to start

```powershell
kubectl get pods -n todo-dev -w
```

Watch the table. Wait until the **STATUS** column shows `Running` and **READY** shows `1/1`:

```
NAME                        READY   STATUS    RESTARTS   AGE
todo-api-7d6f9b-xxxxx       1/1     Running   0          45s
```

Press `Ctrl+C` to stop watching.

### Step 8 — Access the app through Kubernetes

```powershell
kubectl port-forward svc/todo-api 3000:80 -n todo-dev
```

Keep this terminal running. Now open http://localhost:3000/health in your browser.

You should see: `{"status":"UP","version":"1.0.0-local"}`

🎉 **Your app is now running in Kubernetes!**

---

## 8. Part 4 — Making it Public with ngrok

ngrok creates a tunnel from the internet to your local machine, giving your app a public URL that anyone can access.

### Step 1 — Connect your ngrok account (first time only)

1. Go to https://dashboard.ngrok.com/get-started/your-authtoken
2. Copy your auth token (long string of letters and numbers)
3. Run in PowerShell:

```powershell
.\ngrok config add-authtoken YOUR_TOKEN_HERE
```

Replace `YOUR_TOKEN_HERE` with the actual token you copied.

### Step 2 — Start the tunnel

Make sure `docker compose up -d` is running (from Part 1). Then in a **new PowerShell window**:

```powershell
cd C:\Users\ACER\devops-project
.\ngrok http 3000
```

You will see a screen like this:
```
Session Status    online
Account           Your Name (Plan: Free)
Forwarding        https://onyx-connector-caterer.ngrok-free.app -> http://localhost:3000
```

The `https://onyx-connector-caterer.ngrok-free.app` part is your **public URL**. Copy it.

### Step 3 — Open the Calendar UI

1. Open the `todo-app-ui.html` file by double-clicking it
2. An orange/purple banner appears at the top asking for the URL
3. Paste your ngrok URL (e.g. `https://onyx-connector-caterer.ngrok-free.app`)
4. Click **"Connect"**

The status dot should turn 🟢 green and you'll see your todos load.

### Step 4 — Share with anyone

Send two things to whoever you want to share with:
1. The `todo-app-ui.html` file
2. Your ngrok URL

They open the HTML file in any browser, paste the URL, click Connect — and they're using your live app. Works on phones, tablets, laptops — any device.

> ⚠️ **The ngrok URL changes every time you restart ngrok** on the free plan. You'll need to share the new URL each session.

---

## 9. Testing the API

### Using a browser
Just type these URLs directly:
- http://localhost:3000/health
- http://localhost:3000/api/todos
- http://localhost:3000/ready

### Using PowerShell

```powershell
# Get all todos
Invoke-WebRequest -Uri http://localhost:3000/api/todos -Method GET

# Create a new todo
Invoke-WebRequest -Uri http://localhost:3000/api/todos -Method POST -ContentType "application/json" -Body '{"title": "Learn Kubernetes"}'

# Mark a todo as completed (replace 4 with the actual id)
Invoke-WebRequest -Uri http://localhost:3000/api/todos/4 -Method PUT -ContentType "application/json" -Body '{"completed": true}'

# Delete a todo
Invoke-WebRequest -Uri http://localhost:3000/api/todos/4 -Method DELETE
```

### API Endpoints Reference

| Method | URL | What it does |
|--------|-----|--------------|
| GET | `/health` | Check if the app is alive |
| GET | `/ready` | Check if the app is ready to serve traffic |
| GET | `/api/todos` | Get all todos |
| GET | `/api/todos/1` | Get todo with id 1 |
| POST | `/api/todos` | Create a new todo |
| PUT | `/api/todos/1` | Update todo with id 1 |
| DELETE | `/api/todos/1` | Delete todo with id 1 |

---

## 10. Using the Calendar UI

The `todo-app-ui.html` file is a visual app that connects to your API.

### How to use it

1. Open Docker Desktop and wait for it to fully start
2. Run `docker compose up -d` in PowerShell
3. Run `.\ngrok http 3000` in a second PowerShell window
4. Double-click `todo-app-ui.html` to open it in your browser
5. Paste your ngrok URL in the connect box and click Connect

### Features

| Feature | How to use it |
|---------|--------------|
| **Add a task to a date** | Click any date on the calendar → type in the input box → press Enter |
| **Mark task as done** | Click the checkbox next to any task |
| **Delete a task** | Click the × button next to any task |
| **Navigate months** | Use the ‹ and › arrows on the calendar |
| **Jump to today** | Click the "Today" button |
| **View all tasks** | Scroll down to the Agenda section |

### What the colored dots mean

| Dot color | Meaning |
|-----------|---------|
| 🔵 Blue | That date has pending tasks |
| 🟢 Green | All tasks on that date are done |
| 🟠 Orange | Some tasks done, some pending |

---

## 11. Daily Startup Checklist

Every time you want to work on this project, follow this checklist in order:

```
□ Step 1 — Open Docker Desktop and wait for whale 🐳 to stop animating

□ Step 2 — Open PowerShell and go to project folder
            cd C:\Users\ACER\devops-project

□ Step 3 — Start Docker Compose
            docker compose up -d

□ Step 4 — Install Docker in Jenkins (needed after every fresh start)
            docker exec -u 0 jenkins bash -c "apt-get update -qq && apt-get install -y docker.io && chmod 666 /var/run/docker.sock"

□ Step 5 — (Optional) Start Minikube if you want Kubernetes
            minikube start --driver=docker

□ Step 6 — (Optional) Point Docker to Minikube
            & minikube -p minikube docker-env --shell powershell | Invoke-Expression

□ Step 7 — (Optional) Port-forward Kubernetes service [Terminal 2]
            kubectl port-forward svc/todo-api 3000:80 -n todo-dev

□ Step 8 — Start ngrok to get public URL [Terminal 3]
            .\ngrok http 3000

□ Step 9 — Open todo-app-ui.html, paste ngrok URL, click Connect
```

---

## 12. Useful Commands Cheat Sheet

### Docker commands

```powershell
# See all running containers
docker ps

# See all containers including stopped ones
docker ps -a

# Start all services
docker compose up -d

# Stop all services
docker compose down

# View app logs
docker compose logs -f app

# View Jenkins logs
docker compose logs -f jenkins

# Go inside a container
docker exec -it jenkins bash

# Install Docker inside Jenkins
docker exec -u 0 jenkins bash -c "apt-get update -qq && apt-get install -y docker.io && chmod 666 /var/run/docker.sock"
```

### Kubernetes commands

```powershell
# See all pods in dev namespace
kubectl get pods -n todo-dev

# Watch pods update in real time
kubectl get pods -n todo-dev -w

# See details about a pod (useful for debugging)
kubectl describe pod -n todo-dev

# See logs from a pod
kubectl logs <pod-name> -n todo-dev

# See all services
kubectl get svc -n todo-dev

# Deploy to dev
kubectl apply -k k8s/overlays/dev/

# Port forward the service
kubectl port-forward svc/todo-api 3000:80 -n todo-dev

# Check rollout status
kubectl rollout status deployment/todo-api -n todo-dev
```

### Minikube commands

```powershell
# Start Minikube
minikube start --driver=docker --cpus=2 --memory=3g

# Stop Minikube
minikube stop

# Check status
minikube status

# Open Kubernetes dashboard in browser
minikube dashboard

# Point Docker to Minikube (run in every new terminal)
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

### ngrok commands

```powershell
# Start tunnel on port 3000
.\ngrok http 3000

# Check ngrok web interface (while ngrok is running)
# Open http://127.0.0.1:4040 in browser
```

---

## 13. How Everything Connects

Here is the full picture of how all the tools work together:

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR LAPTOP                          │
│                                                         │
│  ┌──────────┐    ┌──────────┐    ┌──────────────────┐  │
│  │  VS Code │    │ Browser  │    │  PowerShell      │  │
│  │ (coding) │    │(testing) │    │  (commands)      │  │
│  └────┬─────┘    └────┬─────┘    └────────┬─────────┘  │
│       │               │                   │             │
│       │ git push      │ localhost:3000     │             │
│       ▼               │                   │             │
│  ┌──────────┐         │                   │             │
│  │  GitHub  │         │                   │             │
│  └────┬─────┘         │                   │             │
│       │ webhook       │                   │             │
│       ▼               │                   │             │
│  ┌──────────────────────────────────────┐ │             │
│  │         Docker Desktop               │ │             │
│  │                                      │ │             │
│  │  ┌──────────┐   ┌─────────────────┐ │ │             │
│  │  │ Jenkins  │   │   Minikube K8s  │ │ │             │
│  │  │ :8080    │   │                 │ │ │             │
│  │  │          │   │  ┌───────────┐  │ │ │             │
│  │  │ Pipeline │   │  │  Pod 1    │  │ │ │             │
│  │  │ Stages:  │   │  │ todo-api  │◄─┼─┼─┘             │
│  │  │ 1.Test   │   │  └───────────┘  │ │               │
│  │  │ 2.Build  │   │  ┌───────────┐  │ │               │
│  │  │ 3.Deploy │   │  │  Pod 2    │  │ │               │
│  │  └──────────┘   │  │ todo-api  │  │ │               │
│  │                 │  └───────────┘  │ │               │
│  │  ┌──────────┐   │       │         │ │               │
│  │  │  Nginx   │   │    Service      │ │               │
│  │  │  :80     │   │       │         │ │               │
│  │  └──────────┘   │    Ingress      │ │               │
│  │                 └─────────────────┘ │               │
│  └──────────────────────────────────────┘              │
│                         │                               │
│                    ngrok tunnel                         │
│                         │                               │
└─────────────────────────┼───────────────────────────────┘
                          │
              ┌───────────▼────────────┐
              │   ngrok servers        │
              │   (internet)           │
              └───────────┬────────────┘
                          │
              https://xxxx.ngrok-free.app
                          │
              ┌───────────▼────────────┐
              │  Anyone's device       │
              │  Phone / Laptop / Tab  │
              └────────────────────────┘
```

---

## 14. Tech Stack Explained

Here is what every technology does and why it's used:

| Technology | What it is | Why it's used in this project |
|-----------|-----------|-------------------------------|
| **Node.js** | JavaScript runtime | Runs the Express server |
| **Express** | Web framework | Handles HTTP requests and routes |
| **Jest** | Testing framework | Runs automated tests on the API |
| **Supertest** | HTTP test library | Makes fake API calls during tests |
| **Docker** | Containerization platform | Packages the app so it runs the same everywhere |
| **Docker Compose** | Multi-container tool | Runs app + Jenkins + Nginx with one command |
| **Nginx** | Web server / proxy | Sits in front of the app, handles rate limiting |
| **Jenkins** | CI/CD server | Automates the test → build → deploy process |
| **Jenkinsfile** | Pipeline definition | Tells Jenkins what stages to run |
| **Kubernetes** | Container orchestrator | Runs containers in a cluster, auto-restarts, auto-scales |
| **Minikube** | Local Kubernetes | Creates a real K8s cluster on your laptop |
| **Kustomize** | K8s config manager | Lets you have different configs for dev and prod |
| **HPA** | Horizontal Pod Autoscaler | Automatically adds more pods when traffic increases |
| **ngrok** | Tunneling tool | Gives your local app a public internet URL |

---

## 🆘 Common Problems and Fixes

| Problem | What it means | Fix |
|---------|--------------|-----|
| `Cannot connect to Docker daemon` | Docker Desktop is not running | Open Docker Desktop and wait for whale 🐳 to stop animating |
| `docker: not found` in Jenkins | Docker not installed in Jenkins container | Run the `docker exec -u 0 jenkins bash -c "..."` install command |
| `ImagePullBackOff` in Kubernetes | Wrong image name or pull policy | Run `kubectl set image` and `kubectl patch` commands from Step 6 |
| `port is already in use` | Another process is using that port | Run `docker compose down` then `docker compose up -d` again |
| `wsl: unexpectedly stopped` | WSL crashed | Run `wsl --shutdown` in PowerShell, then reopen Docker Desktop |
| `NodeJS-20 not configured` | NodeJS tool not set up in Jenkins | Go to Manage Jenkins → Tools → Add NodeJS named `NodeJS-20` |
| `refs/heads/**` error | Wrong branch specifier in Jenkins job | Change branch specifier to `*/main` |
| `npm ci` fails | Missing package-lock.json | Use `npm install` instead of `npm ci` in Jenkinsfile |
| ngrok shows blank page | Missing bypass header | The HTML file already includes the fix — use the latest version |
| Pod stuck in `Pending` | Image not found in Minikube | Run `eval $(minikube docker-env)` then rebuild the image |

---

*DevOps Internship Project — Savitribai Phule Pune University 2025-26*
*Dr. D.Y. Patil Technical Campus, Talegaon Dabhade, Pune*
*Student: Suyog Gampawar — Computer Science, TE-A*
