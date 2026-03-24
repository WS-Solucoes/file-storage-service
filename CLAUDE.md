# File Storage

Domínio: upload, download e gerenciamento de arquivos e documentos.
Registrado no Eureka como `file-storage-service`. Porta: `9085`. Prefixo gateway: `/storage/`.

## Arquitetura

Strategy pattern para múltiplos backends de storage + Factory condicional.

```
ws/filestorage/
├── config/
│   ├── StorageProperties.java       # @ConfigurationProperties binder
│   ├── StorageServiceFactory.java   # @ConditionalOnProperty (MINIO/LOCAL)
│   └── WebConfig.java               # CORS
├── controller/
│   ├── FileController.java          # @RestController /api/v1/files
│   └── dto/
│       ├── FileUploadResponse.java
│       └── FileInfoResponse.java
├── service/
│   ├── StorageService.java          # Interface
│   ├── MinioStorageService.java     # @ConditionalOnProperty(storage.type=MINIO)
│   └── LocalStorageService.java     # @ConditionalOnProperty(storage.type=LOCAL)
└── exception/
    ├── StorageException.java
    └── StorageFileNotFoundException.java
```

## Endpoints REST

```
POST   /api/v1/files              # Upload multipart
POST   /api/v1/files/bytes        # Upload raw bytes
GET    /api/v1/files/{id}         # Download
DELETE /api/v1/files/{id}         # Delete
GET    /api/v1/files/info/{id}    # Metadata
POST   /api/v1/files/copy         # Copy
POST   /api/v1/files/move         # Move
```

## MinIO (Storage S3-compatible)

- `MINIO_ENDPOINT` — URL (dev: `http://localhost:9000`)
- `MINIO_ACCESS_KEY` / `MINIO_SECRET_KEY`
- `minio.bucket` — bucket padrão: `ws-documentos`
- `minio.region` — `us-east-1`
- Console MinIO em porta `9001` (apenas dev/staging)
- Operações: putObject, getObject, removeObject, listObjects, copyObject, moveObject

## Configuração

`storage.type`: `MINIO` (produção) ou `LOCAL` (desenvolvimento sem MinIO).
Nunca hardcodar credenciais — sempre variáveis de ambiente.

**Sem banco de dados** — este serviço não usa PostgreSQL.

## Swagger / OpenAPI

Obrigatório expor spec. Usar springdoc-openapi-starter-webmvc-ui.
