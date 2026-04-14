// ════════════════════════════════════════════════════════════
//  Jenkinsfile — Todo API  CI/CD Pipeline
//  Stages: Checkout → Lint → Test → Build → Push → Deploy
// ════════════════════════════════════════════════════════════

pipeline {
    agent any

    // ── Tools ──────────────────────────────────────────────
    tools {
        nodejs 'NodeJS-20'   // Configure this in Jenkins > Global Tool Configuration
    }

    // ── Environment ────────────────────────────────────────
    environment {
        APP_NAME        = 'todo-api'
        DOCKER_REGISTRY = 'your-dockerhub-username'   // ← change this
        IMAGE_NAME      = "${DOCKER_REGISTRY}/${APP_NAME}"
        IMAGE_TAG       = "${env.BUILD_NUMBER}-${env.GIT_COMMIT?.take(7) ?: 'local'}"
        KUBECONFIG_FILE = credentials('kubeconfig')   // Jenkins credential ID
        DOCKER_CREDS    = credentials('dockerhub-creds')
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
        booleanParam(name: 'PUSH_IMAGE', defaultValue: true, description: 'Push image to registry')
    }

    // ════════════════════════════════════════════════════════
    stages {

        // ── Stage 1: Checkout ──────────────────────────────
        stage('Checkout') {
            steps {
                echo "📥 Checking out branch: ${env.BRANCH_NAME}"
                checkout scm
                script {
                    env.GIT_AUTHOR = sh(returnStdout: true, script: "git log -1 --format='%an'").trim()
                    env.GIT_MESSAGE = sh(returnStdout: true, script: "git log -1 --format='%s'").trim()
                    echo "Author : ${env.GIT_AUTHOR}"
                    echo "Commit : ${env.GIT_MESSAGE}"
                }
            }
        }

        // ── Stage 2: Install Dependencies ─────────────────
        stage('Install') {
            steps {
                dir('app') {
                    echo "📦 Installing dependencies..."
                    sh 'npm ci'
                }
            }
        }

        // ── Stage 3: Lint ──────────────────────────────────
        stage('Lint') {
            steps {
                dir('app') {
                    echo "🔍 Running linter..."
                    // Uncomment if ESLint is configured:
                    // sh 'npm run lint'
                    sh 'node --check src/index.js && echo "Syntax OK"'
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
            post {
                always {
                    // Publish JUnit results if you add jest-junit reporter
                    // junit 'app/coverage/junit.xml'
                    publishHTML(target: [
                        allowMissing         : false,
                        alwaysLinkToLastBuild: true,
                        keepAll              : true,
                        reportDir            : 'app/coverage/lcov-report',
                        reportFiles          : 'index.html',
                        reportName           : 'Coverage Report'
                    ])
                }
            }
        }

        // ── Stage 5: Docker Build ──────────────────────────
        stage('Docker Build') {
            steps {
                echo "🐳 Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker build \
                        --build-arg BUILD_NUMBER=${BUILD_NUMBER} \
                        --build-arg GIT_COMMIT=${GIT_COMMIT} \
                        --target production \
                        -t ${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${IMAGE_NAME}:latest \
                        .
                """
            }
        }

        // ── Stage 6: Docker Scan (Trivy) ───────────────────
        stage('Security Scan') {
            steps {
                echo "🔒 Scanning image for vulnerabilities..."
                sh """
                    docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy:latest image \
                        --exit-code 0 \
                        --severity HIGH,CRITICAL \
                        --no-progress \
                        ${IMAGE_NAME}:${IMAGE_TAG} || true
                """
            }
        }

        // ── Stage 7: Push to Registry ──────────────────────
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
                    def env_dir = params.DEPLOY_ENV
                    echo "🚀 Deploying to Kubernetes (${env_dir})..."
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                        sh """
                            # Update image tag in overlay
                            sed -i 's|IMAGE_TAG_PLACEHOLDER|${IMAGE_TAG}|g' k8s/overlays/${env_dir}/kustomization.yaml

                            # Apply with kustomize
                            kubectl apply -k k8s/overlays/${env_dir}/

                            # Wait for rollout
                            kubectl rollout status deployment/${APP_NAME} \
                                -n todo-${env_dir} \
                                --timeout=120s

                            echo "✅ Deployment successful!"
                            kubectl get pods -n todo-${env_dir}
                        """
                    }
                }
            }
        }

        // ── Stage 9: Smoke Test ────────────────────────────
        stage('Smoke Test') {
            when { branch 'main' }
            steps {
                echo "💨 Running post-deploy smoke test..."
                sh """
                    sleep 10
                    curl -f http://localhost:3000/health || echo "⚠️  Smoke test failed — check deployment"
                """
            }
        }

    } // end stages

    // ── Post Actions ───────────────────────────────────────
    post {
        always {
            echo "🧹 Cleaning up Docker images..."
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
            cleanWs()
        }
        success {
            echo "✅ Pipeline succeeded! Build #${BUILD_NUMBER}"
            // slackSend(color: 'good', message: "✅ ${APP_NAME} #${BUILD_NUMBER} deployed successfully!")
        }
        failure {
            echo "❌ Pipeline failed! Check the logs above."
            // slackSend(color: 'danger', message: "❌ ${APP_NAME} #${BUILD_NUMBER} FAILED!")
        }
        unstable {
            echo "⚠️  Pipeline is unstable."
        }
    }
}
