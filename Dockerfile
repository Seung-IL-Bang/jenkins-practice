# syntax=docker/dockerfile:1
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app
COPY . .
# gradlew에 실행 권한 추가
RUN chmod +x ./gradlew
# 소스코드 복사 (여기서 캐시 무효화)
COPY src/ src/
# 클린 빌드
RUN ./gradlew clean bootJar --no-daemon --no-build-cache

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENV SERVER_NAME=unknown
ENTRYPOINT ["sh", "-c", "java -jar app.jar"] 