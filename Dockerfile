# =============================
# Etapa 1: Build
# =============================
FROM openjdk:21-slim AS builder

RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia todo o projeto
COPY . .

# Executa o build usando o pom “pai” (que fica na raiz)
# Se o nome do pom pai for pom.xml mesmo, só rodar:
RUN mvn clean package -DskipTests

# =============================
# Etapa 2: Imagem final
# =============================
FROM openjdk:21-jdk
WORKDIR /app

# Copia o jar executável gerado do módulo eFrotas
COPY --from=builder /app/eFrotas/target/*-exec.jar efrotas.jar

EXPOSE 8080
CMD ["java", "-jar", "efrotas.jar"]

