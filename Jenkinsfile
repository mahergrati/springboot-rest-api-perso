pipeline {
    agent any

    tools {
        maven 'M2_HOME'  // Assure-toi que Maven est configuré dans Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 Clonage du dépôt...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🔨 Compilation du projet Spring Boot...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Exécution des tests unitaires...'
                sh 'mvn test'
            }
        }

        stage('Deploy') {
            steps {
                echo '🚀 Déploiement terminé avec succès !'
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline réussi !'
        }
        failure {
            echo '❌ Pipeline échoué !'
        }
    }
}
