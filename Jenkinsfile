pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '55e1b1b0-b51a-4039-a7ff-80f42e13e78d'
        NETLIFY_AUTH_TOKEN = credentials('NETLIFY_AUTH_TOKEN')
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
                        
                        docker build -t $AWS_ECR_REGISTRY/$APP_NAME:latest .
                        aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
                        docker push $AWS_ECR_REGISTRY/$APP_NAME:latest $AWS_ECR_REGISTRY/$APP_NAME:10
                    '''
                }
            }
        }
    }
}
