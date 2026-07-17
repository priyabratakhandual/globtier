pipeline {

    agent any

    environment {
        AWS_REGION   = "ap-south-1"
        IMAGE_NAME   = "priyabratakhandual/maturity:latest"
        CLUSTER_NAME = "my-ecs-cluster"
        SERVICE_NAME = "my-app-service"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/priyabratakhandual/globtier.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker-compose build
                '''
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Tag Image') {
            steps {
                sh '''
                    docker tag priyabratakhandual/maturity:latest $IMAGE_NAME:latest
                '''
            }
        }

        stage('Push Image') {
            steps {
                sh '''
                    docker push $IMAGE_NAME:latest
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                    aws ecs update-service \
                        --cluster $CLUSTER_NAME \
                        --service $SERVICE_NAME \
                        --force-new-deployment \
                        --region $AWS_REGION

                    aws ecs wait services-stable \
                        --cluster $CLUSTER_NAME \
                        --services $SERVICE_NAME \
                        --region $AWS_REGION
                '''
            }
        }
    }

    post {
        success {
            echo 'ECS Deployment Successful'
        }

        failure {
            echo 'ECS Deployment Failed'
        }

        always {
            sh 'docker image prune -af || true'
        }
    }
}