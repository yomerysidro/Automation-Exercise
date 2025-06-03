pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = "yomerysidro/automation-exercise-website"
        DOCKER_IMAGE_TAG = "${env.BUILD_ID}"
        CONTAINER_NAME = "automation-exercise-app"
        DOCKER_REGISTRY_CREDENTIALS_ID = 'dockerhub-credentials'
    }

    stages {
        stage('Clone Repository') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    git branch: 'main', url: 'https://github.com/yomerysidro/Automation-Exercise.git'
                }
            }
        }

        stage('Verify Dockerfile exists') {
            steps {
                echo "Verificando que el Dockerfile existe..."
                sh 'ls -la'
                sh 'cat Dockerfile'
            }
        }

        stage('Build Docker Image') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                    sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                }
            }
        }

        stage('Push Docker Image to Registry (Optional)') {
            when {
                expression { return env.DOCKER_REGISTRY_CREDENTIALS_ID != null && false } // Pon true si deseas habilitar el push
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_REGISTRY_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker logout"
                    }
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        echo "Desplegando contenedor localmente como '${CONTAINER_NAME}'"
                        sh "docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || true"
                        // Usa el puerto 8080 -> 8080 suponiendo que tu app corre en 8080
                        sh "docker run -d --name ${CONTAINER_NAME} -p 8080:8080 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        echo "Aplicación desplegada: http://<IP_DEL_AGENTE>:8080"
                    }
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado. Limpieza del workspace..."
            cleanWs()
        }
        success {
            echo "✅ Despliegue exitoso."
        }
        failure {
            echo "❌ Error durante el pipeline."
        }
    }
}
