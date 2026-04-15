// ════════════════════════════════════════════════════════════
//  Jenkinsfile — Todo API  CI/CD Pipeline
//  Stages: Checkout → Install → Lint → Test → Build → Push → Deploy → Smoke Test
// ════════════════════════════════════════════════════════════

pipeline {
    agent any

    // ── Tools ──────────────────────────────────────────────
    tools {
        nodejs 'NodeJS-20'   // Must match name in Manage Jenkins → Tools
    }

    // ── Environment ────────────────────────────────────────
    // NOTE: No credentials() calls here — those are handled inside stages
    //       using withCredentials{} blocks to avoid startup failures
    environment {
        APP_NAME        = 'todo-api'
        DOCKER_REGISTRY = 'your-dockerhub-username'   // ← change this to your Docker Hub username
        IMAGE_NAME      = "${DOCKER_REGISTRY}/${APP_NAME}"
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
    }

    // ── Options ────────────────────────────────────────────
    options {
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    // ── Parameters (manual trigger) ────────────────────────
    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['dev', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip test stage')
        booleanParam(name: 'PUSH_IMAGE', defaultValue: false, description: 'Push image to Docker Hub registry')
    }

    // ════════════════════════════════════════════════════════
    stages {

        // ── Stage 1: Checkout ──────────────────────────────
        stage('Checkout') {
            steps {
                echo "📥 Checking out branch: ${env.BRANCH_NAME ?: 'main'}"
                checkout scm
                script {
                    env.GIT_AUTHOR  = sh(returnStdout: true, script: "git log -1 --format='%an'").trim()
                    env.GIT_MESSAGE = sh(returnStdout: true, script: "git log -1 --format='%s'").trim()
                    echo "Author  : ${env.GIT_AUTHOR}"
                    echo "Commit  : ${env.GIT_MESSAGE}"
                }
            }
        }

        // ── Stage 2: Install Dependencies ─────────────────
        // Using 'npm install' instead of 'npm ci' because
        // package-lock.json is not committed to the repo.
        // To use 'npm ci' in future: run 'npm install' locally,
        // commit the generated package-lock.json, then switch back.
        stage('Install') {
            steps {
                dir('app') {
                    echo "📦 Installing dependencies..."
                    sh 'npm install'
                }
            }
        }

        // ── Stage 3: Lint ──────────────────────────────────
        stage('Lint') {
            steps {
                dir('app') {
                    echo "🔍 Checking syntax..."
                    sh 'node --check src/index.js && echo "✅ Syntax OK"'
                }
            }
        }

        // ── Stage 4: Test ──────────────────────────────────
        stage('Test') {
            when { expression { !params.SKIP_TESTS } }
            steps {
                dir('app') {
                    echo "🧪 Running tests with coverage..."
                    sh 'npm run test:ci'
                }
            }
        }

        // ── Stage 5: Docker Build ──────────────────────────
        stage('Docker Build') {
            steps {
                echo "🐳 Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker build \\
                        --build-arg BUILD_NUMBER=${BUILD_NUMBER} \\
                        --target production \\
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \\
                        -t ${IMAGE_NAME}:latest \\
                        .
                """
            }
        }

        // ── Stage 6: Docker Scan (Trivy) ───────────────────
        stage('Security Scan') {
            steps {
                echo "🔒 Scanning image for vulnerabilities..."
                sh """
                    docker run --rm \\
                        -v /var/run/docker.sock:/var/run/docker.sock \\
                        aquasec/trivy:latest image \\
                        --exit-code 0 \\
                        --severity HIGH,CRITICAL \\
                        --no-progress \\
                        ${IMAGE_NAME}:${IMAGE_TAG} || true
                """
            }
        }

        // ── Stage 7: Push to Registry ──────────────────────
        // Only runs if PUSH_IMAGE parameter is true AND dockerhub-creds exist
        stage('Push Image') {
            when { expression { params.PUSH_IMAGE } }
            steps {
                echo "📤 Pushing to Docker Hub..."
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${IMAGE_NAME}:latest
                        docker logout
                    """
                }
            }
        }

        // ── Stage 8: Deploy to Kubernetes ──────────────────
        // Only runs on main branch AND if image was pushed
        stage('Deploy') {
            when {
                allOf {
                    expression { params.PUSH_IMAGE }
                    anyOf {
                        branch 'main'
                        branch 'master'
                    }
                }
            }
            steps {
                script {
                    def envDir = params.DEPLOY_ENV
                    echo "🚀 Deploying to Kubernetes (${envDir})..."
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                            sed -i 's|IMAGE_TAG_PLACEHOLDER|${IMAGE_TAG}|g' k8s/overlays/${envDir}/kustomization.yaml
                            kubectl apply -k k8s/overlays/${envDir}/
                            kubectl rollout status deployment/${APP_NAME} \\
                                -n todo-${envDir} \\
                                --timeout=120s
                            echo "✅ Deployment successful!"
                            kubectl get pods -n todo-${envDir}
                        """
                    }
                }
            }
        }

    } // end stages

    // ── Post Actions ───────────────────────────────────────
    post {
        always {
            echo "🧹 Cleaning up..."
            script {
                // Safe cleanup — only try if IMAGE_NAME is available
                try {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
                } catch (err) {
                    echo "Image cleanup skipped: ${err.message}"
                }
            }
            cleanWs()
        }
        success {
            echo "✅ Pipeline #${BUILD_NUMBER} completed successfully!"
        }
        failure {
            echo "❌ Pipeline #${BUILD_NUMBER} failed. Check the logs above."
        }
    }
}
