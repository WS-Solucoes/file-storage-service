# File Storage Service

Microsserviço de armazenamento de arquivos para o ecossistema WS-Services.  
**Porta:** `9085`

## Visão Geral

Serviço independente de infraestrutura responsável por upload, download e gerenciamento de arquivos. Suporta MinIO (S3 compatível) e armazenamento local.

## Arquitetura

```
┌─────────────┐     ┌──────────────────┐     ┌─────────┐
│  Frontend    │────▶│   API Gateway    │────▶│  MinIO   │
│  (9300)      │     │   (9080)         │     │  (9000)  │
└─────────────┘     └──────────────────┘     └─────────┘
                           │                       ▲
                    ┌──────┴───────┐               │
                    │              │               │
               ┌────▼────┐  ┌─────▼──────────┐    │
               │ eRH     │  │ File Storage   │────┘
               │ (9083)  │  │ Service (9085) │
               └─────────┘  └────────────────┘
                    │              ▲
                    └──────────────┘
                      Feign Client
```

## API REST

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/v1/files` | Upload de arquivo (multipart) |
| `POST` | `/api/v1/files/bytes` | Upload de bytes |
| `GET` | `/api/v1/files/download?path=xxx` | Download como stream |
| `GET` | `/api/v1/files/download/bytes?path=xxx` | Download como bytes |
| `DELETE` | `/api/v1/files?path=xxx` | Deletar arquivo |
| `GET` | `/api/v1/files/info?path=xxx` | Metadados do arquivo |
| `GET` | `/api/v1/files/exists?path=xxx` | Verificar existência |
| `GET` | `/api/v1/files/list?prefix=xxx` | Listar arquivos |
| `POST` | `/api/v1/files/copy` | Copiar arquivo |
| `POST` | `/api/v1/files/move` | Mover arquivo |
| `GET` | `/api/v1/files/health` | Health check |

## Configuração

### Variáveis de Ambiente

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `FILE_STORAGE_PORT` | `9085` | Porta do serviço |
| `STORAGE_TYPE` | `MINIO` | Tipo: `MINIO` ou `LOCAL` |
| `MINIO_ENDPOINT` | `http://localhost:9000` | URL do MinIO |
| `MINIO_ACCESS_KEY` | `minioadmin` | Chave de acesso |
| `MINIO_SECRET_KEY` | `minioadmin` | Chave secreta |
| `MINIO_BUCKET` | `ws-documentos` | Nome do bucket |
| `EUREKA_SERVER_URL` | `http://localhost:8761/eureka` | URL do Eureka |

### application.yml

```yaml
storage:
  type: MINIO
  minio:
    endpoint: http://localhost:9000
    access-key: minioadmin
    secret-key: minioadmin
    bucket: ws-documentos
```

## Integração com eRH-Service

O eRH-Service se conecta ao file-storage-service via **Feign Client**:

- **Dev (LOCAL):** `ERH_STORAGE_TYPE=LOCAL` — usa sistema de arquivos local, sem dependência do file-storage-service
- **Docker/Prod (REMOTE):** `ERH_STORAGE_TYPE=REMOTE` — delega operações ao file-storage-service via REST

## Docker

```bash
# Iniciar tudo (incluindo MinIO + File Storage)
docker-compose up -d

# Acessar console MinIO
# http://localhost:9001 (minioadmin/minioadmin)

# Swagger do File Storage
# http://localhost:9085/api-doc/swagger.html
```

## Desenvolvimento Local

```bash
# Compilar
mvn -pl file-storage-service clean package -DskipTests

# Executar (requer MinIO rodando em localhost:9000)
java -jar file-storage-service/target/*-exec.jar
```
