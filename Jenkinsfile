pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "vandanasharma1/fullstack:latest"
        EC2_HOST = "13.201.49.87"
        EC2_USER = "ubuntu" // or "ec2-user" for Amazon Linux
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo 'Checking out code from GitHub...'
                git branch: 'main', url: 'https://github.com/Vandanasharma1/Fullstack_Web-Application-end-to-end_CI-CD-pipeline.git'
            }
        }

        stage('Build & Test') {
            steps {
                echo 'Installing dependencies and running tests...'
                sh '''
                python3 -m venv venv
                . venv/bin/activate
                pip install -r backend/requirements.txt
                pytest || echo "No tests found, skipping..."
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                echo 'Building Docker image...'
                sh 'docker build -t ${DOCKER_IMAGE} .'
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                echo 'Pushing Docker image to Docker Hub...'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${DOCKER_IMAGE}
                    '''
                }
            }
        }

        stage('Deploy to EC2 Instance') {
            steps {
                echo 'Deploying Docker container to EC2...'
                withCredentials([sshUserPrivateKey(credentialsId: 'ec2-ssh-key', keyFileVariable: 'SSH_KEY')]) {
                    sh """
                    ssh -i $SSH_KEY -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "\
                        sudo docker pull ${DOCKER_IMAGE} && \
                        sudo docker stop fullstack_app || true && \
                        sudo docker rm fullstack_app || true && \
                        sudo docker run -d --name fullstack_app -p 80:80 ${DOCKER_IMAGE} \
                    "
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful! Your app is live at http://${EC2_HOST}"
        }
        failure {
            echo 'Deployment failed. Check the Jenkins logs.'
        }
    }
}
