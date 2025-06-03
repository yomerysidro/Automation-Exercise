pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

    environment {
        DOCKER_IMAGE = 'yomerysidro/automation-exercise-website'
        SONAR_PROJECT_KEY = 'automationexercise'
        SONAR_PROJECT_NAME = 'AutomationExercise'
    }

    stages {
        stage('Clone Repository') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    git url: 'https://github.com/yomerysidro/Automation-Exercise.git', branch: 'main'
                }
            }
        }

        stage('Verify Dockerfile exists') {
            steps {
                echo 'Verificando que el Dockerfile existe...'
                sh 'ls -la'
                sh 'cat Dockerfile'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar -Dsonar.projectKey=automationexercise -Dsonar.projectName="AutomationExercise"'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    sh "docker build -t ${DOCKER_IMAGE}:1 ."
                    sh "docker tag ${DOCKER_IMAGE}:1 ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    script {
                        echo "Desplegando contenedor localmente como 'automation-exercise-app'"
                        sh 'docker ps -q --filter name=automation-exercise-app | grep -q . && docker stop automation-exercise-app && docker rm automation-exercise-app || true'
                        sh "docker run -d --name automation-exercise-app -p 8080:8080 ${DOCKER_IMAGE}:1"
                        echo "Aplicación desplegada: http://<IP_DEL_AGENTE>:8080"
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline finalizado. Limpieza del workspace...'
            cleanWs()
            echo '✅ Despliegue exitoso.'
        }
    }
}
