FROM eclipse-temurin:17-jdk-jammy

ARG JAR_FILE=target/automationexercise-1.0-SNAPSHOT.jar

WORKDIR /app
EXPOSE 8086

COPY ${JAR_FILE} automationexercise.jar

ENTRYPOINT ["java", "-jar", "automationexercise.jar"]
