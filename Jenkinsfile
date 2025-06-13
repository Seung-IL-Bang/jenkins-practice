pipeline {
    agent any
    
    environment {
        IMAGE_NAME = 'spring-hello'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REGISTRY = 'localhost:5000'  // 로컬 테스트용
    }
    
    stages {
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Deploy to Server 1') {
            steps {
                script {
                    echo "Deploying to Server 1..."
                    
                    // 서버 1 중지
                    sh "docker stop server1 || true"
                    sh "docker rm server1 || true"
                    
                    // 새 이미지로 서버 1 시작
                    sh """
                        docker run -d \
                        --name server1 \
                        --network jenkins-network \
                        -p 8082:8080 \
                        -e SERVER_NAME=server1 \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                    
                    // 헬스체크
                    sh "sleep 10"
                    sh "curl -f http://localhost:8082/ || exit 1"
                    
                    echo "Server 1 deployment completed successfully"
                }
            }
        }
        
        stage('Deploy to Server 2') {
            steps {
                script {
                    echo "Deploying to Server 2..."
                    
                    // 서버 2 중지
                    sh "docker stop server2 || true"
                    sh "docker rm server2 || true"
                    
                    // 새 이미지로 서버 2 시작
                    sh """
                        docker run -d \
                        --name server2 \
                        --network jenkins-network \
                        -p 8083:8080 \
                        -e SERVER_NAME=server2 \
                        --restart unless-stopped \
                        ${IMAGE_NAME}:${IMAGE_TAG}
                    """
                    
                    // 헬스체크
                    sh "sleep 10"
                    sh "curl -f http://localhost:8083/ || exit 1"
                    
                    echo "Server 2 deployment completed successfully"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    echo "Performing final health check..."
                    
                    // 두 서버 모두 헬스체크
                    sh "curl -f http://localhost:8082/ || exit 1"
                    sh "curl -f http://localhost:8083/ || exit 1"
                    
                    echo "All servers are healthy!"
                }
            }
        }
    }
    
    post {
        always {
            script {
                // 이전 이미지 정리 (최근 5개만 유지)
                sh """
                    docker images ${IMAGE_NAME} --format "table {{.Repository}}\\t{{.Tag}}\\t{{.ID}}" | tail -n +2 | sort -k2 -n | head -n -5 | awk '{print \$3}' | xargs -r docker rmi -f || true
                """
            }
        }
        failure {
            echo "Deployment failed! Check the logs above."
        }
        success {
            echo "Rolling deployment completed successfully!"
        }
    }
} 