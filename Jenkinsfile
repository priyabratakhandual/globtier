pipeline {

    agent any

    environment {
        AWS_REGION     = "ap-south-1"
        AWS_ACCOUNT_ID = "253627981876"

        ECR_REGISTRY   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        ECR_REPOSITORY = "maturity"

        IMAGE_NAME     = "${ECR_REGISTRY}/${ECR_REPOSITORY}"

        GITOPS_REPO    = "https://github.com/priyabratakhandual/gitops.git"
        GITOPS_BRANCH  = "master"
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

                    echo "========================================"
                    echo "Building Docker Image"
                    echo "========================================"

                    echo "Image: ${IMAGE_NAME}:${BUILD_NUMBER}"

                    docker build \
                        --platform linux/amd64 \
                        --provenance=false \
                        --sbom=false \
                        -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                '''
            }
        }

        stage('Login to AWS ECR') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Login to AWS ECR"
                    echo "========================================"

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

                    echo "========================================"
                    echo "Push Image to ECR"
                    echo "========================================"

                    echo "Pushing: ${IMAGE_NAME}:${BUILD_NUMBER}"

                    docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                '''
            }
        }

        stage('Verify ECR Image') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Verify ECR Image"
                    echo "========================================"

                    aws ecr describe-images \
                        --repository-name ${ECR_REPOSITORY} \
                        --image-ids imageTag=${BUILD_NUMBER} \
                        --region ${AWS_REGION}
                '''
            }
        }

        stage('Update GitOps') {
            steps {

                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-gitops',
                        usernameVariable: 'GIT_USERNAME',
                        passwordVariable: 'GIT_TOKEN'
                    )
                ]) {

                    sh '''
                        set -e

                        echo "========================================"
                        echo "Update GitOps Repository"
                        echo "========================================"

                        rm -rf gitops

                        git clone \
                            --branch ${GITOPS_BRANCH} \
                            https://${GIT_USERNAME}:${GIT_TOKEN}@github.com/priyabratakhandual/gitops.git \
                            gitops

                        cd gitops

                        echo "GitOps branch:"
                        git branch --show-current

                        echo "========================================"
                        echo "Current Image Tag"
                        echo "========================================"

                        grep -n "tag:" maturity/values.yaml

                        echo "========================================"
                        echo "Updating Image Tag"
                        echo "========================================"

                        sed -i \
                            "s/^  tag:.*/  tag: \\"${BUILD_NUMBER}\\"/" \
                            maturity/values.yaml

                        echo "========================================"
                        echo "Updated Image Tag"
                        echo "========================================"

                        grep -n "tag:" maturity/values.yaml

                        echo "========================================"
                        echo "Git Status"
                        echo "========================================"

                        git status

                        git config user.name "Jenkins"
                        git config user.email "jenkins@localhost"

                        git add maturity/values.yaml

                        git commit \
                            -m "Update maturity image to ${BUILD_NUMBER}" || true

                        echo "========================================"
                        echo "Pushing GitOps Changes"
                        echo "========================================"

                        git push origin ${GITOPS_BRANCH}

                        echo "========================================"
                        echo "GitOps Update Completed"
                        echo "========================================"
                    '''
                }
            }
        }
    }

    post {

        success {
            echo "========================================"
            echo "BUILD SUCCESSFUL"
            echo "========================================"

            echo "Image pushed:"
            echo "${IMAGE_NAME}:${BUILD_NUMBER}"

            echo "GitOps image tag:"
            echo "${BUILD_NUMBER}"

            echo "GitOps branch:"
            echo "${GITOPS_BRANCH}"
        }

        failure {
            echo "========================================"
            echo "BUILD FAILED"
            echo "========================================"
        }

        always {
            sh '''
                docker image prune -af || true
                rm -rf gitops || true
            '''
        }
    }
}