pipeline {
    agent any // Puedes especificar un agente con Docker si es necesario: agent { label 'docker-agent' }

    environment {
        // Cambia 'yomerysidro' por tu usuario de Docker Hub si es diferente o si usas otro registry
        DOCKER_IMAGE_NAME = "yomerysidro/automation-exercise-website" // Ejemplo: tu_usuario_dockerhub/nombre_imagen
        DOCKER_IMAGE_TAG = "${env.BUILD_ID}"
        CONTAINER_NAME = "automation-exercise-app"
        // (Opcional: Para push a registry)
        DOCKER_REGISTRY_CREDENTIALS_ID = 'dockerhub-credentials' // ID de tus credenciales de Docker Hub en Jenkins
        // (Opcional: Para despliegue remoto SSH)
        // REMOTE_SERVER_USER = "your_ssh_user"
        // REMOTE_SERVER_HOST = "your_server_ip_or_hostname"
        // SSH_CREDENTIALS_ID = 'remote-server-ssh-credentials' // ID de tus credenciales SSH en Jenkins
    }

    stages {
        stage('Clone Repository') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    // Usando tu repositorio Git
                    git branch: 'main', url: 'https://github.com/yomerysidro/Automation-Exercise.git'
                }
            }
        }

        stage('Lint Static Files (Optional)') {
            // Este stage es opcional y requeriría herramientas como html-lint, stylelint, eslint
            // instaladas en el agente. Si no las tienes, puedes omitir este stage.
            steps {
                echo "Skipping Linting stage (o configúralo si es necesario)."
            }
        }

        stage('Build Docker Image') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        // El Dockerfile debe estar en la raíz del repo clonado.
                        // Tu repositorio "Automation-Exercise" tiene el Dockerfile en la raíz.
                        sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ${DOCKER_IMAGE_NAME}:latest"
                    }
                }
            }
        }

        stage('Push Docker Image to Registry (Optional)') {
            // Descomenta y configura si quieres subir tu imagen a Docker Hub u otro registry.
            // Necesitas tener credenciales configuradas en Jenkins.
            when {
                // Ejecutar solo si las credenciales están definidas
                // Cambia 'false' a 'true' para habilitar este stage si lo necesitas
                expression { return env.DOCKER_REGISTRY_CREDENTIALS_ID != null && false }
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_REGISTRY_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin" // Puedes añadir la URL del registry si no es Docker Hub
                        sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        sh "docker push ${DOCKER_IMAGE_NAME}:latest"
                        sh "docker logout"
                    }
                }
            }
        }

        stage('Deploy to Staging/Production (Example: Local Docker Run)') {
            // Despliega ejecutando el contenedor en el mismo agente de Jenkins.
            // Para un despliegue real, considera SSH, Kubernetes, etc.
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        echo "Desplegando contenedor ${CONTAINER_NAME}..."
                        // Detener y remover si ya existe una versión anterior
                        sh "docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || true"
                        // Ejecutar el nuevo contenedor
                        // Mapea el puerto 8080 del host al 80 del contenedor. Cambia 8080 si está ocupado.
                        sh "docker run -d --name ${CONTAINER_NAME} -p 8080:80 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                        echo "Sitio web debería estar disponible en http://<jenkins_agent_ip>:8080"
                    }
                }
            }
        }

        /*
        // EJEMPLO: Despliegue a un servidor remoto vía SSH
        stage('Deploy to Remote Server via SSH (Optional)') {
            when {
                // Cambia 'false' a 'true' y configura si lo necesitas
                expression { return env.SSH_CREDENTIALS_ID != null && env.REMOTE_SERVER_HOST != null && false }
            }
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    withCredentials([sshUserPrivateKey(credentialsId: env.SSH_CREDENTIALS_ID, keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no -i \$SSH_KEY ${SSH_USER}@${REMOTE_SERVER_HOST} << EOF
                                echo 'Conectado al servidor remoto...'
                                # (Opcional) docker login si el registry es privado
                                # docker login -u tu_usuario_registry -p tu_token_o_pass tu_registry.com

                                echo 'Haciendo pull de la nueva imagen (asumiendo que fue pusheada a un registry)...'
                                docker pull ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}

                                echo 'Deteniendo y eliminando contenedor anterior si existe...'
                                docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || true
                                
                                echo 'Ejecutando nuevo contenedor...'
                                docker run -d --name ${CONTAINER_NAME} -p 80:80 ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} // Ajusta el puerto si es necesario
                                
                                echo 'Limpiando imágenes antiguas (opcional)...'
                                docker image prune -f || true

                                echo 'Despliegue completado en el servidor remoto.'
                            EOF
                        """
                    }
                }
            }
        }
        */
    }

    post {
        always {
            echo "Pipeline finalizado."
            // Opcional: Limpiar imágenes Docker del agente para ahorrar espacio
            // sh "docker rmi ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} || true"
            // sh "docker rmi ${DOCKER_IMAGE_NAME}:latest || true"
            cleanWs() // Limpia el workspace
        }
        success {
            echo "Pipeline ejecutado exitosamente! 🎉"
        }
        failure {
            echo "Pipeline falló! ❌"
        }
        unstable {
            echo "Pipeline completado pero con advertencias ⚠️"
        }
    }
}