# 🚀 Complete Beginner's Guide — How to Run the DevOps Todo API

> Don't worry if you're new to this! This guide explains **every single step** from zero — including installing all the tools you need before even touching the project.

---

## 📋 Table of Contents

1. [What You Need (Prerequisites)](#1-what-you-need-prerequisites)
2. [Installing the Prerequisites](#2-installing-the-prerequisites)
   - [Install Git](#-install-git)
   - [Install Node.js](#-install-nodejs)
   - [Install Docker](#-install-docker)
   - [Install kubectl](#-install-kubectl)
   - [Install Minikube](#-install-minikube)
3. [Verify Everything is Installed](#3-verify-everything-is-installed)
4. [Download the Project](#4-download-the-project)
5. [Run with Docker Compose (Easiest Way)](#5-run-with-docker-compose-easiest-way)
6. [Set Up Jenkins](#6-set-up-jenkins)
7. [Run on Kubernetes with Minikube](#7-run-on-kubernetes-with-minikube)
8. [Testing the API](#8-testing-the-api)
9. [Stopping Everything](#9-stopping-everything)
10. [Troubleshooting Common Errors](#10-troubleshooting-common-errors)

---

## 1. What You Need (Prerequisites)

These are the tools you **must install** before running the project. Don't skip any of them.

| Tool | What it does | Required? |
|------|-------------|-----------|
| **Git** | Downloads the project from GitHub | ✅ Yes |
| **Node.js (v20)** | Runs the JavaScript application | ✅ Yes |
| **Docker Desktop** | Builds and runs containers | ✅ Yes |
| **kubectl** | Talks to your Kubernetes cluster | ✅ Yes |
| **Minikube** | Creates a mini Kubernetes cluster on your laptop | ✅ Yes |

### 💻 System Requirements

| | Minimum |
|-|---------|
| **RAM** | 4 GB (8 GB recommended) |
| **Disk Space** | 10 GB free |
| **OS** | Windows 10/11, macOS 11+, or Ubuntu 20.04+ |
| **Internet** | Required (to download images) |

---

## 2. Installing the Prerequisites

### 🔧 Install Git

Git lets you download ("clone") the project from GitHub.

**Windows:**
1. Go to https://git-scm.com/download/win
2. Download and run the installer
3. Keep clicking "Next" — the default options are fine
4. At the end, click "Finish"

**macOS:**
Open the Terminal app and run:
```bash
xcode-select --install
```
A popup will appear — click "Install".

**Ubuntu/Linux:**
Open a terminal and run:
```bash
sudo apt update && sudo apt install git -y
```

---

### 🔧 Install Node.js

Node.js runs the Todo API application.

**Windows & macOS:**
1. Go to https://nodejs.org
2. Click the button that says **"20.x.x LTS"** (LTS = Long Term Support, most stable)
3. Download and run the installer
4. Keep clicking "Next" — defaults are fine

**Ubuntu/Linux:**
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install nodejs -y
```

---

### 🔧 Install Docker Desktop

Docker packages your app into containers. Docker Desktop is the easiest way to install it.

**Windows:**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click **"Download for Windows"**
3. Run the installer
4. When prompted, make sure **"Use WSL 2"** is checked (Windows only)
5. Restart your computer when asked
6. After restart, open Docker Desktop from the Start menu
7. Wait for the whale icon 🐳 in the taskbar to stop animating — that means Docker is ready

**macOS:**
1. Go to https://www.docker.com/products/docker-desktop/
2. Click **"Download for Mac"** — choose Apple Silicon (M1/M2/M3) or Intel depending on your Mac
3. Open the downloaded `.dmg` file and drag Docker to Applications
4. Open Docker from Applications
5. Wait for the whale icon in the menu bar to stop animating

**Ubuntu/Linux:**
```bash
# Install Docker Engine
sudo apt update
sudo apt install ca-certificates curl gnupg -y
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Allow running Docker without sudo
sudo usermod -aG docker $USER
newgrp docker
```

---

### 🔧 Install kubectl

kubectl (pronounced "kube-control") is the command-line tool for Kubernetes.

**Windows:**
1. Open PowerShell as Administrator
2. Run this command:
```powershell
winget install Kubernetes.kubectl
```
Or download manually from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/

**macOS:**
```bash
brew install kubectl
```
> If you don't have Homebrew, install it first: https://brew.sh

**Ubuntu/Linux:**
```bash
sudo apt update && sudo apt install -y kubectl
```
If that doesn't work:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

### 🔧 Install Minikube

Minikube creates a real Kubernetes cluster on your own laptop for testing.

**Windows:**
1. Open PowerShell as Administrator
2. Run:
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

---

## 3. Verify Everything is Installed

Open a terminal (Command Prompt or PowerShell on Windows, Terminal on Mac/Linux) and run these commands one by one. Each should print a version number — if it does, that tool is installed correctly.

```bash
git --version
# Expected: git version 2.x.x

node --version
# Expected: v20.x.x

npm --version
# Expected: 10.x.x

docker --version
# Expected: Docker version 24.x.x

docker compose version
# Expected: Docker Compose version v2.x.x

kubectl version --client
# Expected: Client Version: v1.28.x

minikube version
# Expected: minikube version: v1.32.x
```

> ⚠️ If any command says **"command not found"** — that tool wasn't installed correctly. Go back to its install step above.

---

## 4. Download the Project

Open a terminal and run these commands:

```bash
# 1. Go to your home folder (or wherever you keep your projects)
cd ~

# 2. Extract the project (if you downloaded the .tar.gz file)
tar -xzf devops-project.tar.gz

# 3. Go into the project folder
cd devops-project

# 4. Check the files are there
ls
```

You should see files like `Dockerfile`, `docker-compose.yml`, `Jenkinsfile`, and folders like `app/`, `k8s/`, `scripts/`.

---

## 5. Run with Docker Compose (Easiest Way)

This is the **recommended first step**. It starts the app + Jenkins + Nginx all at once with a single command.

### Step 5.1 — Make sure Docker Desktop is running

Open Docker Desktop and wait until it says **"Docker is running"** (the whale icon should be still, not animating).

### Step 5.2 — Run the setup script

```bash
# Make the script executable (Mac/Linux only — skip on Windows)
chmod +x scripts/setup.sh

# Run it
./scripts/setup.sh
```

**On Windows**, run this instead:
```bash
docker compose build
docker compose up -d
```

### Step 5.3 — Wait for it to start

The first time you run this, Docker needs to download images from the internet. This can take **3–10 minutes** depending on your internet speed. You'll see a lot of text scrolling — that's normal.

When it's done, you'll see something like:
```
[✓] App is UP!
  🌐 App (direct)    → http://localhost:3000
  🔀 App (via nginx) → http://localhost:80
  🏗  Jenkins         → http://localhost:8080
```

### Step 5.4 — Verify the app is running

Open your web browser and go to:
```
http://localhost:3000/health
```

You should see:
```json
{ "status": "UP", "version": "1.0.0-local", "timestamp": "..." }
```

🎉 **The app is running!**

---

## 6. Set Up Jenkins

Jenkins is the CI/CD server. It automates building, testing, and deploying your app.

### Step 6.1 — Open Jenkins

Go to http://localhost:8080 in your browser.

### Step 6.2 — Get the admin password

Jenkins generates a random password the first time it starts. Run this to see it:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy the long string of letters and numbers it prints.

### Step 6.3 — Unlock Jenkins

1. Paste the password into the "Administrator password" box on the Jenkins page
2. Click **"Continue"**

### Step 6.4 — Install suggested plugins

1. Click **"Install suggested plugins"**
2. Wait for all the plugins to install (takes 2–5 minutes)
3. Jenkins will show a progress screen — don't close it

### Step 6.5 — Create your admin user

Fill in a username, password, and email address when prompted, then click **"Save and Continue"**.

### Step 6.6 — Install extra plugins needed for this project

1. Go to **Manage Jenkins → Plugins → Available plugins**
2. Search for and install each of these:
   - `NodeJS`
   - `Docker Pipeline`
   - `HTML Publisher`
   - `Kubernetes CLI`
3. Check the boxes and click **"Install"**
4. Check **"Restart Jenkins when installation is complete"**

### Step 6.7 — Configure NodeJS tool

1. Go to **Manage Jenkins → Tools**
2. Scroll down to **"NodeJS installations"**
3. Click **"Add NodeJS"**
4. Set Name to: `NodeJS-20`
5. Choose version: `20.x.x`
6. Click **"Save"**

### Step 6.8 — Add Docker Hub credentials

1. Go to **Manage Jenkins → Credentials → System → Global credentials → Add credentials**
2. Fill in:
   - Kind: `Username with password`
   - Username: your Docker Hub username
   - Password: your Docker Hub access token (get one at https://hub.docker.com → Account Settings → Security → New Access Token)
   - ID: `dockerhub-creds`
3. Click **"Create"**

### Step 6.9 — Create a Pipeline job

1. Click **"New Item"** on the Jenkins home page
2. Enter a name like `todo-api-pipeline`
3. Select **"Pipeline"** and click **"OK"**
4. Scroll down to **"Pipeline"** section
5. Change Definition to: **"Pipeline script from SCM"**
6. SCM: **Git**
7. Repository URL: the URL of your GitHub repo
8. Script Path: `Jenkinsfile`
9. Click **"Save"**

### Step 6.10 — Run the pipeline

1. Click **"Build Now"** on the left sidebar
2. Watch the stages light up green as they pass ✅
3. Click on the build number → **"Console Output"** to see detailed logs

---

## 7. Run on Kubernetes with Minikube

This deploys the app to a real Kubernetes cluster running on your laptop.

### Step 7.1 — Start Minikube

```bash
minikube start --driver=docker --cpus=2 --memory=3g --addons=ingress,metrics-server
```

This creates a mini Kubernetes cluster. It takes **3–5 minutes** the first time. You'll see a progress bar.

When done, you'll see:
```
✅  Done! kubectl is now configured to use "minikube" cluster
```

### Step 7.2 — Point Docker to Minikube's engine

This step is important — it makes sure your Docker image is available inside Minikube:

**Mac/Linux:**
```bash
eval $(minikube docker-env)
```

**Windows (PowerShell):**
```powershell
& minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

> ⚠️ You must run this **in the same terminal window** you'll use for the next steps.

### Step 7.3 — Build the image inside Minikube

```bash
docker build --target production -t todo-api:local .
```

### Step 7.4 — Update the image name in the dev overlay

Open `k8s/overlays/dev/kustomization.yaml` in any text editor and change:
```yaml
images:
  - name: your-dockerhub-username/todo-api
    newTag: IMAGE_TAG_PLACEHOLDER
```
To:
```yaml
images:
  - name: todo-api
    newTag: local
```

### Step 7.5 — Deploy to Kubernetes

```bash
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

### Step 7.6 — Wait for the pods to start

```bash
kubectl get pods -n todo-dev --watch
```

Wait until the STATUS column shows `Running` for all pods:
```
NAME                        READY   STATUS    RESTARTS   AGE
todo-api-7d6f9b8c4-x2kpq    1/1     Running   0          30s
```

Press `Ctrl+C` to stop watching.

### Step 7.7 — Access the app

```bash
kubectl port-forward svc/todo-api 3000:80 -n todo-dev
```

Now open http://localhost:3000/health in your browser. The app is running in Kubernetes! 🎉

Press `Ctrl+C` to stop port-forwarding when done.

---

## 8. Testing the API

You can test the API using your browser or a tool called **curl** (available in all terminals).

```bash
# Check health
curl http://localhost:3000/health

# Get all todos
curl http://localhost:3000/api/todos

# Create a new todo
curl -X POST http://localhost:3000/api/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "My first todo!"}'

# Update a todo (replace 1 with the ID you got above)
curl -X PUT http://localhost:3000/api/todos/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'

# Delete a todo
curl -X DELETE http://localhost:3000/api/todos/1
```

> 💡 **Windows users:** If curl doesn't work, try using **PowerShell** or install a tool called [Postman](https://www.postman.com/) — it lets you test APIs with a nice visual interface.

---

## 9. Stopping Everything

### Stop Docker Compose services:
```bash
docker compose down
```

### Stop Minikube:
```bash
minikube stop
```

### Start everything again later:
```bash
# Docker Compose
docker compose up -d

# Minikube
minikube start
kubectl port-forward svc/todo-api 3000:80 -n todo-dev
```

---

## 10. Troubleshooting Common Errors

### ❌ "Cannot connect to the Docker daemon"
Docker Desktop is not running. Open Docker Desktop and wait for it to fully start.

---

### ❌ "Port is already allocated" or "address already in use"
Another program is using that port. Stop it or find what's using it:

**Mac/Linux:**
```bash
lsof -i :3000   # Check port 3000
kill -9 <PID>   # Kill the process (replace <PID> with the number shown)
```

**Windows (PowerShell):**
```powershell
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

---

### ❌ "minikube start" fails
Make sure Docker Desktop is running first. Minikube uses Docker as its engine. Also ensure you have at least 4 GB of free RAM.

---

### ❌ Jenkins shows a blank page or won't load
Jenkins takes about 60 seconds to fully start. Wait and then refresh the page.

---

### ❌ "ImagePullBackOff" in Kubernetes pods
```bash
kubectl describe pod <pod-name> -n todo-dev
```
This usually means the image name is wrong or Minikube can't find it. Make sure you ran `eval $(minikube docker-env)` before building the image in Step 7.2.

---

### ❌ Tests fail during Docker build
The build will stop and show the failing test. Read the error message — it usually tells you what went wrong. You can run tests locally first:
```bash
cd app
npm install
npm test
```

---

### ❌ "kubectl: command not found"
kubectl wasn't installed or isn't in your PATH. Revisit the kubectl install step above.

---

## ✅ Summary — Quick Reference

| What you want to do | Command |
|--------------------|---------|
| Start everything (app + Jenkins + Nginx) | `docker compose up -d` |
| Stop everything | `docker compose down` |
| View running containers | `docker ps` |
| View app logs | `docker compose logs -f app` |
| View Jenkins logs | `docker compose logs -f jenkins` |
| Start Minikube | `minikube start` |
| Deploy to Kubernetes | `kubectl apply -k k8s/overlays/dev/` |
| See pods | `kubectl get pods -n todo-dev` |
| Access app via Kubernetes | `kubectl port-forward svc/todo-api 3000:80 -n todo-dev` |
| Run tests locally | `cd app && npm test` |
| Get Jenkins admin password | `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword` |

---

*You've got this! DevOps can look intimidating at first, but once each piece is running, it all clicks into place. 💪*
