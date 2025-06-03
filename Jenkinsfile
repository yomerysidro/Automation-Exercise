pipeline {
    agent any

    tools {
        maven 'MAVEN_HOME' // Debe coincidir con el nombre registrado en "Global Tool Configuration"
        jdk 'JDK17'         // Asegúrate de que el JDK 17 está registrado con este nombre exacto
    }

    environment {
        MAVEN_OPTS = '-Xmx1024m'
    }

    stages {
        stage('Clone') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    git branch: 'main', url: 'https://github.com/yomerysidro/Automation-Exercise.git'
                }
            }
        }

        stage('Build') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    sh "mvn clean compile"
                }
            }
        }

        stage('Test') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    sh "mvn test"
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    sh "mvn package -DskipTests"
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    withSonarQubeEnv('sonarqube') {
                        sh """
                            mvn sonar:sonar \
                                -Dsonar.projectKey=AutomationExercise \
                                -Dsonar.projectName='Automation Exercise' \
                                -Dsonar.projectVersion=1.0 \
                                -Dsonar.sources=src/main/java \
                                -Dsonar.tests=src/test/java \
                                -Dsonar.java.binaries=target/classes \
                                -Dsonar.junit.reportsPath=target/surefire-reports \
                                -Dsonar.jacoco.reportsPath=target/site/jacoco/jacoco.xml
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Deploy Preparation') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        sh "ls -la target/*.jar"
                        echo "JAR file ready for deployment"
                        sh "java -jar target/*.jar --version || echo 'Version info not available'"
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Pipeline executed successfully! 🎉"
            echo "Project approved by SonarQube and ready for deployment."
        }
        failure {
            echo "Pipeline failed! ❌"
        }
        unstable {
            echo "Pipeline completed but with warnings ⚠️"
        }
    }
}
