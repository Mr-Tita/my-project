# ---------- Build stage ----------
FROM gradle:8.9-jdk21 AS build
WORKDIR /app
COPY . .
# For Spring Boot fat jar:
RUN gradle --no-daemon clean build
# or: gradle --no-daemon clean test bootJar

# ---------- Runtime stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
