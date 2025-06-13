#!/bin/bash

echo "=== 배포 테스트 스크립트 ==="

# 서버 상태 확인
echo "1. 서버 상태 확인:"
docker-compose ps

echo ""
echo "2. 서버 응답 테스트:"

# Server 1 테스트
echo "Server 1 응답:"
curl -s http://localhost:8082/ || echo "Server 1 연결 실패"

echo ""
echo "Server 2 응답:"
curl -s http://localhost:8083/ || echo "Server 2 연결 실패"

echo ""
echo "3. 컨테이너 로그 확인:"
echo "Server 1 로그 (최근 5줄):"
docker-compose logs --tail=5 server1

echo ""
echo "Server 2 로그 (최근 5줄):"
docker-compose logs --tail=5 server2

echo ""
echo "=== 테스트 완료 ===" 