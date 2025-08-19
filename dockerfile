# ---------- Build stage ----------
FROM gradle:8.9-jdk21 AS build
WORKDIR /app


# Copy wrapper and config first to leverage Docker cache
COPY gradlew gradle/ /app/
COPY settings.gradle* build.gradle* /app/
RUN chmod +x gradlew || true
# Prime Gradle (optional)
RUN ./gradlew --no-daemon --version || true


# Now copy the rest of the source
COPY . /app


# Build the JAR (runs tests by default). If you don't have tests, keep it—fast ones help your quality gate.
# For non–Spring Boot projects, replace bootJar with build.
RUN ./gradlew --no-daemon clean test bootJar || ./gradlew --no-daemon clean build


# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app


# Copy fat JAR
COPY --from=build /app/build/libs/*.jar /app/app.jar


EXPOSE 8080
ENV JAVA_OPTS=""
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]