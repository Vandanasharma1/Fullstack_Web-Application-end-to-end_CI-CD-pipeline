pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vandanasharma1/fullstack:latest"
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo 'Checking out source code...'
                git branch: 'main',
                    url: 'https://github.com/Vandanasharma1/Fullstack_Web-Application-end-to-end_CI-CD-pipeline.git'
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Setting up Python environment and running tests...'
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install --upgrade pip
                pip install -r backend/requirements.txt

                # Run tests only if pytest exists
                if command -v pytest > /dev/null; then
                    pytest
                else
                    echo "pytest not installed. Skipping tests."
                fi
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh '''
                docker build -t ${DOCKER_IMAGE} .
                '''
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                echo 'Logging into Docker Hub and pushing image...'
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }

        stage('Deploy with Docker Compose') {
            steps {
                echo 'Deploying application using Docker Compose...'
                sh '''
                docker compose down || true
                docker compose pull
                docker compose up -d --build
                docker system prune -f
                '''
            }
        }
    }

    post {
        success {
            echo "Deployment successful! Application is running."
        }
        failure {
            echo "Pipeline failed. Check logs carefully."
        }
    }
}
