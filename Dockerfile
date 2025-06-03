FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY target/automationexercise-1.0-SNAPSHOT.jar automationexercise.jar
ENTRYPOINT ["java", "-jar", "automationexercise.jar"]
