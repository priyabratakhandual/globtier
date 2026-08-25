pipeline {

    agent any

    environment {
        AWS_REGION     = "ap-south-1"
        AWS_ACCOUNT_ID = "253627981876"

        ECR_REGISTRY   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPOSITORY = "maturity"

        IMAGE_NAME     = "${ECR_REGISTRY}/${ECR_REPOSITORY}"
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
                    set -e

                    echo "Building image:"
                    echo "${IMAGE_NAME}:${BUILD_NUMBER}"

                    docker build \
                        --platform linux/amd64 \
                        -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh '''
                    aws ecr get-login-password \
                        --region ${AWS_REGION} | \
                    docker login \
                        --username AWS \
                        --password-stdin ${ECR_REGISTRY}
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    set -e

                    echo "Pushing image:"
                    echo "${IMAGE_NAME}:${BUILD_NUMBER}"

                    docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify ECR Image') {
            steps {
                sh '''
                    aws ecr describe-images \
                        --repository-name ${ECR_REPOSITORY} \
                        --image-ids imageTag=${BUILD_NUMBER} \
                        --region ${AWS_REGION}
                '''
            }
        }
    }

    post {

        success {
            echo "Docker image pushed successfully!"
            echo "Image: ${IMAGE_NAME}:${BUILD_NUMBER}"
        }

        failure {
            echo "Docker/ECR build failed!"
        }

        always {
            sh '''
                docker image prune -af || true
            '''
        }
    }
}