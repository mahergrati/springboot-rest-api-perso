pipeline {
    agent any

    environment {
        MAVEN_HOME = tool 'M2_HOME'
        DOCKERHUB_USER = 'maher2002'
        IMAGE_NAME = 'springboot-rest-api'
        VERSION = "v${env.BUILD_NUMBER}"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        disableConcurrentBuilds()
    }

    tools {
        maven 'M2_HOME'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📦 Clonage du dépôt Git...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Compilation du projet Spring Boot...'
                sh "${MAVEN_HOME}/bin/mvn clean package -DskipTests"
            }
        }

        stage('Unit Tests') {
            steps {
                echo '🧪 Exécution des tests unitaires...'
                sh "${MAVEN_HOME}/bin/mvn test"
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        // 🟦 Nouvelle étape ajoutée : Analyse SonarQube
        stage('SonarQube Analysis') {
            steps {
                echo '🔍 Analyse du code avec SonarQube...'
                withCredentials([string(credentialsId: 'jenkins-sonar', variable: 'SONAR_TOKEN')]) {
                    withSonarQubeEnv('SonarQube') {
                        sh """
                            ${MAVEN_HOME}/bin/mvn sonar:sonar \
                            -Dsonar.projectKey=springboot-rest-api \
                            -Dsonar.host.url=http://192.168.33.10:9000 \
                            -Dsonar.login=$SONAR_TOKEN
                        """
                    }
                }
            }
        }
        stage('Quality Gate') {
             steps {
                echo '🚦 Vérification du Quality Gate SonarQube...'
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Publish to Nexus') {
            steps {
                echo '📦 Publication de l’artefact Maven dans Nexus...'
                 withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh """
                    ${MAVEN_HOME}/bin/mvn deploy \
                    -DskipTests \
                    -Dnexus.username=$NEXUS_USER \
                    -Dnexus.password=$NEXUS_PASS
                     """
                }
             }
        }



        stage('Build Docker Image') {
            steps {
                echo "🐳 Construction de l'image Docker : ${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}"
                sh "docker build -t ${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION} ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                echo '📤 Envoi de l’image sur Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh """
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}
                        docker tag ${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION} ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:latest
                        docker logout
                    """
                }
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Déploiement local du conteneur Docker...'
                sh '''
                    docker stop springboot-api || true
                    docker rm springboot-api || true
                    docker pull maher2002/springboot-rest-api:latest
                    docker run -d -p 1235:8080 --name springboot-api maher2002/springboot-rest-api:latest
                '''
            }
        }

        stage('Health Check') {
            steps {
                echo '🩺 Vérification du service...'
                sh '''
                    sleep 10
                    curl -f http://localhost:1235/api/tutorials || (echo "❌ API non disponible !" && exit 1)
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline exécuté avec succès !'
        }
        failure {
            echo '❌ Échec du pipeline. Consultez les logs Jenkins.'
        }
        always {
            echo '🧹 Nettoyage du workspace...'
            // cleanWs()
        }
    }
}
