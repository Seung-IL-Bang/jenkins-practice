pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'spring-hello'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REGISTRY = 'localhost:5000'
    }
    
    stages {
        stage('Prepare') {
            steps {
                script {
                    echo "Preparing environment..."
                    // 네트워크 생성 (이미 있으면 무시)
                    sh "docker network create jenkins-network || true"
                    
                    // curl 설치 확인
                    sh "which curl || (apt-get update && apt-get install -y curl)"
                    
                    // Docker 권한 확인
                    sh "docker --version"
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                    
                    // 빌드된 이미지 확인
                    sh "docker images ${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Deploy to Server 1') {
            steps {
                script {
                    echo "Deploying to Server 1..."
                    
                    // 기존 컨테이너 정리
                    sh "docker stop server1 || true"
                    sh "docker rm server1 || true"
                    
                    // 새 컨테이너 시작
                    sh """
                        docker run -d \
                        --name server1 \
                        --network jenkins-network \
                        -p 8082:8080 \
                        -e SERVER_NAME=server1 \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                    
                    // 컨테이너 시작 확인
                    sh "docker ps | grep server1"
                    
                    // 헬스체크 (더 안전하게)
                    echo "Waiting for server1 to start..."
                    sh """
                        for i in {1..30}; do
                            if curl -f http://localhost:8082/ 2>/dev/null; then
                                echo "Server1 is healthy!"
                                break
                            fi
                            echo "Attempt \$i: Server1 not ready yet..."
                            sleep 5
                        done
                    """
                }
            }
        }
        
        stage('Deploy to Server 2') {
            steps {
                script {
                    echo "Deploying to Server 2..."
                    
                    sh "docker stop server2 || true"
                    sh "docker rm server2 || true"
                    
                    sh """
                        docker run -d \
                        --name server2 \
                        --network jenkins-network \
                        -p 8083:8080 \
                        -e SERVER_NAME=server2 \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                    
                    sh "docker ps | grep server2"
                    
                    echo "Waiting for server2 to start..."
                    sh """
                        for i in {1..30}; do
                            if curl -f http://localhost:8083/ 2>/dev/null; then
                                echo "Server2 is healthy!"
                                break
                            fi
                            echo "Attempt \$i: Server2 not ready yet..."
                            sleep 5
                        done
                    """
                }
            }
        }
        
        stage('Final Health Check') {
            steps {
                script {
                    echo "Performing final health check..."
                    sh "curl -f http://localhost:8082/ && echo 'Server1 OK'"
                    sh "curl -f http://localhost:8083/ && echo 'Server2 OK'"
                    echo "All servers are healthy!"
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Cleaning up old images..."
                sh """
                    docker images ${IMAGE_NAME} --format "table {{.Repository}}\\t{{.Tag}}\\t{{.ID}}" | \
                    tail -n +2 | sort -k2 -nr | tail -n +6 | awk '{print \$3}' | \
                    xargs -r docker rmi -f || true
                """
            }
        }
        failure {
            script {
                echo "Deployment failed! Collecting debug info..."
                sh "docker ps -a | grep server || true"
                sh "docker logs server1 || true"
                sh "docker logs server2 || true"
            }
        }
        success {
            echo "Rolling deployment completed successfully!"
        }
    }
}