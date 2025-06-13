#!/bin/bash

echo "=== Jenkins CD 연습 환경 설정 ==="

# 1. Docker Compose로 환경 시작
echo "1. Docker Compose 환경 시작 중..."
docker-compose up -d

# 2. Jenkins 초기화 대기
echo "2. Jenkins 초기화 대기 중... (30초)"
sleep 30

# 3. Jenkins 초기 비밀번호 출력
echo "3. Jenkins 초기 비밀번호:"
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo ""
echo "=== 설정 완료 ==="
echo "Jenkins 접속: http://localhost:8081"
echo "Server 1 접속: http://localhost:8082"
echo "Server 2 접속: http://localhost:8083"
echo ""
echo "다음 단계:"
echo "1. http://localhost:8081 접속"
echo "2. 위의 초기 비밀번호 입력"
echo "3. 'Install suggested plugins' 선택"
echo "4. 관리자 계정 생성"
echo "5. README.md의 3-5단계 진행" 