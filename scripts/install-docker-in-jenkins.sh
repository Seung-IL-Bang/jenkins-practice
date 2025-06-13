#!/bin/bash

echo "=== Jenkins 컨테이너에 Docker 설치 ==="

# Jenkins 컨테이너에 Docker 설치
echo "1. Jenkins 컨테이너에 Docker 설치 중..."
docker exec jenkins sh -c "
    apt-get update && 
    apt-get install -y docker.io && 
    usermod -aG docker jenkins
"

echo "2. Jenkins 컨테이너 재시작..."
docker restart jenkins

echo "3. Docker 설치 확인..."
sleep 10
docker exec jenkins docker --version

echo "=== Docker 설치 완료 ==="
echo "이제 Jenkins에서 Docker 명령어를 사용할 수 있습니다." 