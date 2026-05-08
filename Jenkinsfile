pipeline {

    agent any

    environment {

        IMAGE_NAME = "priyabratakhandual/maturity-app"

        TAG = "${BUILD_NUMBER}"
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
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
            }
        }

        stage('Tag Docker Image') {

            steps {

                sh '''
                docker tag priyabratakhandual/maturity-app:latest $IMAGE_NAME:$TAG
                '''
            }
        }

        stage('Push Docker Image') {

            steps {

                sh '''
                docker push $IMAGE_NAME:$TAG
                '''
            }
        }

        stage('Update GitOps Repo') {

            steps {

                withCredentials([string(
                    credentialsId: 'github-creds',
                    variable: 'GITHUB_TOKEN'
                )]) {

                    sh '''

                    rm -rf maturity-gitops

                    git clone https://${GITHUB_TOKEN}@github.com/priyabratakhandual/gitops.git

                    cd maturity-gitops/maturity-app

                    sed -i "s/tag:.*/tag: \\"$TAG\\"/" values.yaml

                    cat values.yaml

                    git config user.email "jenkins@example.com"

                    git config user.name "jenkins"

                    git add values.yaml

                    git commit -m "Updated image tag to $TAG"

                    git push
                    '''
                }
            }
        }
    }

    post {

        success {

            echo 'GitOps Deployment Successful'
        }

        failure {

            echo 'Pipeline Failed'
        }
    }
}