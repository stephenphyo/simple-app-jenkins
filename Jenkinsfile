pipeline {
    agent any

    environment {
        APP_NAME = 'simple-app'
        AWS_DEFAULT_REGION = 'ap-southeast-1'
    }

    stages {

        stage('build-app') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    node --version
                    npm --version

                    npm ci
                    npm run build
                '''
            }
        }

        stage('build-docker-image-push-aws-ecr') {
            agent {
                docker {
                    image 'awscli-docker'
                    reuseNode true
                }
            }
            environment {
                AWS_ECR_REGISTRY = '356855127394.dkr.ecr.ap-southeast-1.amazonaws.com'
                CREDENTIAL_ID = 'aws-alpha-23-jenkins-01'
            }
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: env.CREDENTIAL_ID,
                        usernameVariable: 'AWS_ACCESS_KEY_ID',
                        passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                    )
                ]) {
                    sh '''
                        export DOCKER_HOST=tcp://172.17.0.1:2375
                        aws --version
                        docker version
                        
                        docker build -t $AWS_ECR_REGISTRY/$APP_NAME:2 .
                        docker tag $AWS_ECR_REGISTRY/$APP_NAME:2 $AWS_ECR_REGISTRY/$APP_NAME:latest
                        aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
                        docker push $AWS_ECR_REGISTRY/$APP_NAME --all-tags
                    '''
                }
            }
        }
    }
}
