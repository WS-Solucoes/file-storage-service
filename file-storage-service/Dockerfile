FROM maven:3.9.9-eclipse-temurin-21 AS builder
WORKDIR /workspace

# Copia TODOS os pom.xml do monorepo (necessário para resolver o reactor)
COPY pom.xml ./
COPY common/pom.xml common/pom.xml
COPY eFrotas/pom.xml eFrotas/pom.xml
COPY eRH-Service/pom.xml eRH-Service/pom.xml
COPY processos-service/pom.xml processos-service/pom.xml
COPY api-gateway/pom.xml api-gateway/pom.xml
COPY service-discovery/pom.xml service-discovery/pom.xml
COPY file-storage-service/pom.xml file-storage-service/pom.xml

RUN mvn -pl file-storage-service -am dependency:go-offline

COPY file-storage-service/src file-storage-service/src
RUN mvn -pl file-storage-service -am clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=builder /workspace/file-storage-service/target/*-exec.jar app.jar
EXPOSE 9085
CMD ["java", "-jar", "app.jar"]
