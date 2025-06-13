# Jenkins CD 연습 환경

이 프로젝트는 Jenkins를 사용한 Continuous Deployment (CD) 연습을 위한 환경입니다.

## 구성 요소

- **Spring Boot 애플리케이션**: 간단한 Hello World API
- **Jenkins**: CI/CD 파이프라인 실행
- **서버 1 & 서버 2**: 롤링 배포 대상 서버들
- **Docker Compose**: 전체 환경 관리

## 포트 구성

- Jenkins: http://localhost:8081
- Server 1: http://localhost:8082
- Server 2: http://localhost:8083

## 연습 단계

### 1단계: 환경 시작
```bash
# Docker Compose로 전체 환경 시작
docker-compose up -d

# Jenkins 초기 비밀번호 확인
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 2단계: Jenkins 초기 설정
1. http://localhost:8081 접속
2. 초기 비밀번호 입력
3. "Install suggested plugins" 선택
4. 관리자 계정 생성
5. Jenkins URL 설정 (http://localhost:8081)

### 3단계: Jenkins 플러그인 설치
1. Jenkins 관리 > 플러그인 관리
2. 다음 플러그인 설치:
   - Docker Pipeline
   - Docker plugin
   - Pipeline Utility Steps

### 4단계: Jenkins Job 생성
1. "새로운 Item" 클릭
2. "Pipeline" 선택
3. Job 이름: "spring-hello-deploy"
4. Pipeline 섹션에서 "Pipeline script from SCM" 선택
5. SCM: Git
6. Repository URL: 현재 프로젝트 경로
7. Script Path: Jenkinsfile

### 5단계: 배포 테스트
1. Job 실행
2. 각 단계별 로그 확인
3. 서버 응답 확인:
   ```bash
   curl http://localhost:8082/
   curl http://localhost:8083/
   ```

## 롤링 배포 시나리오

1. **Build**: Docker 이미지 빌드
2. **Deploy to Server 1**: 서버 1에 새 버전 배포
3. **Health Check**: 서버 1 헬스체크
4. **Deploy to Server 2**: 서버 2에 새 버전 배포
5. **Health Check**: 서버 2 헬스체크
6. **Final Health Check**: 전체 시스템 헬스체크

## 실제 환경 적용 시 고려사항

1. **이미지 레지스트리**: ghcr.io 사용
2. **서버 접근**: SSH 또는 Docker API
3. **보안**: 인증서, 키 관리
4. **모니터링**: 로그 수집, 알림 설정
5. **롤백**: 실패 시 이전 버전으로 복구

## 유용한 명령어

```bash
# 환경 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs jenkins
docker-compose logs server1
docker-compose logs server2

# 환경 정리
docker-compose down -v

# 특정 서비스만 재시작
docker-compose restart server1
```

## 문제 해결

### Jenkins에서 Docker 명령어 실행 안 될 때
- Jenkins 컨테이너에 Docker 소켓 마운트 확인
- Jenkins 사용자가 docker 그룹에 속하는지 확인

### 서버 연결 안 될 때
- 네트워크 설정 확인
- 포트 충돌 확인
- 컨테이너 상태 확인 