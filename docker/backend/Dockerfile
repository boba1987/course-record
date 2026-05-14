# Build context: course-record repo root (see docker-compose.yml).
FROM maven:3.9.9-eclipse-temurin-17 AS build
WORKDIR /build
COPY course-record-backend/pom.xml .
COPY course-record-backend/src ./src
RUN mvn -B -DskipTests package

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /build/target/course-record-*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
