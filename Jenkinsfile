pipeline {
    agent any

    triggers {
        pollSCM('* * * * *')  // 1분마다 체크 (개발용으로는 충분히 빠름)
    }
    
    environment {
        IMAGE_NAME = 'spring-hello'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        REGISTRY = 'localhost:5000'  // 로컬 테스트용
    }
    
    stages {
        stage('Checkout') {
            steps {

                // 워크스페이스 완전 정리
                cleanWs()

                // Git에서 소스코드 가져오기
                git branch: 'main', url: 'https://github.com/Seung-IL-Bang/jenkins-practice'
            }
        }
        
        stage('Verify Files') {
            steps {
                script {
                    // 파일 확인
                    sh "ls -la"
                    sh "cat Dockerfile || echo 'Dockerfile not found'"
                }
            }
        }
        
        stage('Prepare Environment') {
            steps {
                script {
                    echo "Preparing environment..."
                    // 네트워크 생성 (이미 있으면 무시)
                    sh "docker network create jenkins-network || true"
                    
                    // 네트워크 확인
                    sh "docker network ls | grep jenkins-network"
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build --no-cache -t ${IMAGE_NAME}:${IMAGE_TAG} ."
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
                    sh "sleep 15"
                    // 헬스체크를 더 견고하게
                    sh """
                        for i in {1..10}; do
                            if curl -f http://server1:8080/; then
                                echo "Server 1 is healthy"
                                break
                            fi
                            echo "Attempt \$i failed, retrying in 5 seconds..."
                            sleep 5
                            if [ \$i -eq 10 ]; then
                                echo "Server 1 health check failed after 10 attempts"
                                exit 1
                            fi
                        done
                    """
                    
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
                    sh "sleep 15"
                    // 헬스체크를 더 견고하게
                    sh """
                        for i in {1..10}; do
                            if curl -f http://server2:8080/; then
                                echo "Server 2 is healthy"
                                break
                            fi
                            echo "Attempt \$i failed, retrying in 5 seconds..."
                            sleep 5
                            if [ \$i -eq 10 ]; then
                                echo "Server 2 health check failed after 10 attempts"
                                exit 1
                            fi
                        done
                    """
                    
                    echo "Server 2 deployment completed successfully"
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    echo "Performing final health check..."
                    
                    // 두 서버 모두 헬스체크
                    sh """
                        echo "Checking Server 1..."
                        for i in {1..5}; do
                            if curl -f http://server1:8080/; then
                                echo "Server 1 is healthy"
                                break
                            fi
                            echo "Server 1 check attempt \$i failed, retrying..."
                            sleep 3
                            if [ \$i -eq 5 ]; then
                                echo "Server 1 final health check failed"
                                exit 1
                            fi
                        done
                    """
                    
                    sh """
                        echo "Checking Server 2..."
                        for i in {1..5}; do
                            if curl -f http://server2:8080/; then
                                echo "Server 2 is healthy"
                                break
                            fi
                            echo "Server 2 check attempt \$i failed, retrying..."
                            sleep 3
                            if [ \$i -eq 5 ]; then
                                echo "Server 2 final health check failed"
                                exit 1
                            fi
                        done
                    """
                    
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