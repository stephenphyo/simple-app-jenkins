pipeline {
    agent any

    environment {
        APP_NAME = 'simple-app'
        APP_VERSION = '1.0'
        AWS_DEFAULT_REGION = 'ap-southeast-1'
        CREDENTIAL_ID = 'aws-alpha-23-jenkins-01'
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
                        
                        docker build -t $AWS_ECR_REGISTRY/$APP_NAME:$APP_VERSION .
                        docker tag $AWS_ECR_REGISTRY/$APP_NAME:$APP_VERSION $AWS_ECR_REGISTRY/$APP_NAME:latest
                        aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_ECR_REGISTRY
                        docker push $AWS_ECR_REGISTRY/$APP_NAME --all-tags
                    '''
                }
            }
        }

        stage('deploy-aws-ecs') {
            agent {
                docker {
                    image "amazon/aws-cli"
                    args "--entrypoint=''"
                    reuseNode true
                }
            }

            environment {
                AWS_ECS_CLUSTER = 'jenkins-cluster-01'
                AWS_ECS_SERVICE = 'td-simple-app-service-jjmo321w'
                AWS_ECS_TASK_DEFINITION = 'td-simple-app'
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
                        aws --version
                        sed -i "s/{VERSION}/$APP_VERSION/g" aws/aws-ecs-001-td-simple-app.json
                        TASK_DEFINITION_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/aws-ecs-001-td-simple-app.json --query 'taskDefinition.revision' --output text)
                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE --task-definition $AWS_ECS_TASK_DEFINITION:$TASK_DEFINITION_REVISION
                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE
                    '''
                }
            }
        }
    }
}
