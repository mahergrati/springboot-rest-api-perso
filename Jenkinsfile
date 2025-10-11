pipeline {
    agent any

    environment {
        // 🔧 Variables globales
        MAVEN_HOME = tool 'M2_HOME'                     // Maven configuré dans Jenkins
        DOCKERHUB_USER = 'maher2002'                    // ton compte Docker Hub
        IMAGE_NAME = 'springboot-rest-api'               // nom de ton image Docker
        VERSION = "v${env.BUILD_NUMBER}"                 // version dynamique
    }

    options {
        // 🧹 Gestion de la file d’attente et nettoyage
        buildDiscarder(logRotator(numToKeepStr: '10'))   // garder seulement 10 builds
        timestamps()                                     // ajoute l'heure dans les logs
        disableConcurrentBuilds()                        // empêche plusieurs builds simultanés
    }

    tools {
        // 🛠️ Utilise le Maven installé dans Jenkins
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
                    junit '**/target/surefire-reports/*.xml'  // 🔍 Afficher les rapports JUnit dans Jenkins
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
                echo '🚀 Déploiement de l’application...'
                // Si tu veux exécuter le conteneur localement :
                // sh "docker run -d -p 8080:8080 ${DOCKERHUB_USER}/${IMAGE_NAME}:latest"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline exécuté avec succès !'
            emailext(
                to: 'mohamedmaher.grati@gmail.com',
                subject: "✅ Jenkins Build #${BUILD_NUMBER} réussi",
                body: """
                <h2>🎉 Build Jenkins réussi !</h2>
                <p>Le projet <b>${IMAGE_NAME}</b> a été compilé, testé et déployé avec succès.</p>
                <ul>
                    <li><b>Version :</b> ${VERSION}</li>
                    <li><b>Image Docker :</b> ${DOCKERHUB_USER}/${IMAGE_NAME}:${VERSION}</li>
                    <li><b>Durée :</b> ${currentBuild.durationString}</li>
                </ul>
                """,
                mimeType: 'text/html'
            )
        }

        failure {
            echo '❌ Échec du pipeline.'
            emailext(
                to: 'mohamedmaher.grati@gmail.com',
                subject: "❌ Jenkins Build #${BUILD_NUMBER} échoué",
                body: """
                <h2>⚠️ Build Jenkins échoué !</h2>
                <p>Le projet <b>${IMAGE_NAME}</b> a rencontré une erreur durant l’exécution.</p>
                <p>Consultez les logs Jenkins pour plus d’informations.</p>
                """,
                mimeType: 'text/html'
            )
        }

        always {
            echo '🧹 Nettoyage du workspace...'
            cleanWs()  // supprime les fichiers du workspace à la fin
        }
    }
}
