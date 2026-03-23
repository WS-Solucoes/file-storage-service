FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /build

# Copia apenas o projeto correto
COPY pom.xml ./
COPY src ./src

RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /build/target/*-exec.jar app.jar
EXPOSE 9085
CMD ["java", "-jar", "app.jar"]
