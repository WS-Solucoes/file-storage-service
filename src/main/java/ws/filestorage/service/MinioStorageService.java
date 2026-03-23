package ws.filestorage.service;

import io.minio.*;
import io.minio.errors.ErrorResponseException;
import io.minio.messages.Item;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import ws.filestorage.config.StorageProperties;
import ws.filestorage.exception.StorageException;
import ws.filestorage.exception.StorageFileNotFoundException;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Implementação de StorageService para MinIO (compatível com Amazon S3).
 * Ativado quando storage.type=MINIO no application.yml (padrão).
 */
@Service
@ConditionalOnProperty(prefix = "storage", name = "type", havingValue = "MINIO", matchIfMissing = true)
public class MinioStorageService implements StorageService {

    private static final Logger log = LoggerFactory.getLogger(MinioStorageService.class);

    private final StorageProperties storageProperties;
    private MinioClient minioClient;
    private String bucket;

    public MinioStorageService(StorageProperties storageProperties) {
        this.storageProperties = storageProperties;
    }

    @PostConstruct
    public void init() {
        StorageProperties.Minio minioProps = storageProperties.getMinio();
        this.bucket = minioProps.getBucket();

        this.minioClient = MinioClient.builder()
                .endpoint(minioProps.getEndpoint())
                .credentials(minioProps.getAccessKey(), minioProps.getSecretKey())
                .build();

        try {
            boolean found = minioClient.bucketExists(
                    BucketExistsArgs.builder().bucket(bucket).build()
            );
            if (!found) {
                minioClient.makeBucket(
                        MakeBucketArgs.builder().bucket(bucket).build()
                );
                log.info("Bucket MinIO criado: {}", bucket);
            }
            log.info("MinIO Storage inicializado - endpoint: {}, bucket: {}",
                    minioProps.getEndpoint(), bucket);
        } catch (Exception e) {
            log.error("Erro ao inicializar MinIO: {}", e.getMessage(), e);
            throw new StorageException("Falha ao conectar ao MinIO: " + e.getMessage(), e);
        }
    }

    @Override
    public void save(String storagePath, byte[] content, String contentType) {
        try {
            String key = normalizeKey(storagePath);
            ByteArrayInputStream bais = new ByteArrayInputStream(content);
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucket)
                            .object(key)
                            .stream(bais, content.length, -1)
                            .contentType(contentType != null ? contentType : detectContentType(storagePath))
                            .build()
            );
            log.debug("Arquivo salvo no MinIO: {} ({} bytes)", key, content.length);
        } catch (Exception e) {
            log.error("Erro ao salvar arquivo no MinIO {}: {}", storagePath, e.getMessage());
            throw new StorageException("Erro ao salvar arquivo: " + storagePath, e);
        }
    }

    @Override
    public void save(String storagePath, InputStream inputStream, long size, String contentType) {
        try {
            String key = normalizeKey(storagePath);
            minioClient.putObject(
                    PutObjectArgs.builder()
                            .bucket(bucket)
                            .object(key)
                            .stream(inputStream, size, size > 0 ? -1 : 10485760)
                            .contentType(contentType != null ? contentType : detectContentType(storagePath))
                            .build()
            );
            log.debug("Arquivo salvo via stream no MinIO: {}", key);
        } catch (Exception e) {
            log.error("Erro ao salvar stream no MinIO {}: {}", storagePath, e.getMessage());
            throw new StorageException("Erro ao salvar arquivo: " + storagePath, e);
        }
    }

    @Override
    public byte[] load(String storagePath) {
        try (InputStream in = loadAsStream(storagePath);
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            in.transferTo(out);
            return out.toByteArray();
        } catch (IOException e) {
            log.error("Erro ao carregar arquivo do MinIO {}: {}", storagePath, e.getMessage());
            throw new StorageException("Erro ao carregar arquivo: " + storagePath, e);
        }
    }

    @Override
    public InputStream loadAsStream(String storagePath) {
        try {
            return minioClient.getObject(
                    GetObjectArgs.builder()
                            .bucket(bucket)
                            .object(normalizeKey(storagePath))
                            .build()
            );
        } catch (ErrorResponseException e) {
            if ("NoSuchKey".equals(e.errorResponse().code())) {
                throw new StorageFileNotFoundException("Arquivo não encontrado: " + storagePath);
            }
            throw new StorageException("Erro ao ler arquivo: " + storagePath, e);
        } catch (Exception e) {
            log.error("Erro ao ler arquivo do MinIO {}: {}", storagePath, e.getMessage());
            throw new StorageException("Erro ao abrir arquivo para leitura: " + storagePath, e);
        }
    }

    @Override
    public boolean delete(String storagePath) {
        try {
            String key = normalizeKey(storagePath);
            minioClient.removeObject(
                    RemoveObjectArgs.builder()
                            .bucket(bucket)
                            .object(key)
                            .build()
            );
            log.debug("Arquivo deletado do MinIO: {}", key);
            return true;
        } catch (Exception e) {
            log.error("Erro ao deletar arquivo do MinIO {}: {}", storagePath, e.getMessage());
            return false;
        }
    }

    @Override
    public boolean exists(String storagePath) {
        try {
            minioClient.statObject(
                    StatObjectArgs.builder()
                            .bucket(bucket)
                            .object(normalizeKey(storagePath))
                            .build()
            );
            return true;
        } catch (ErrorResponseException e) {
            if ("NoSuchKey".equals(e.errorResponse().code())) {
                return false;
            }
            throw new StorageException("Erro ao verificar existência: " + storagePath, e);
        } catch (Exception e) {
            throw new StorageException("Erro ao verificar existência: " + storagePath, e);
        }
    }

    @Override
    public long getFileSize(String storagePath) {
        try {
            StatObjectResponse stat = minioClient.statObject(
                    StatObjectArgs.builder()
                            .bucket(bucket)
                            .object(normalizeKey(storagePath))
                            .build()
            );
            return stat.size();
        } catch (Exception e) {
            log.error("Erro ao obter tamanho do arquivo {}: {}", storagePath, e.getMessage());
            return -1;
        }
    }

    @Override
    public String getContentType(String storagePath) {
        try {
            StatObjectResponse stat = minioClient.statObject(
                    StatObjectArgs.builder()
                            .bucket(bucket)
                            .object(normalizeKey(storagePath))
                            .build()
            );
            return stat.contentType();
        } catch (Exception e) {
            return detectContentType(storagePath);
        }
    }

    @Override
    public List<String> listFiles(String prefix) {
        List<String> files = new ArrayList<>();
        try {
            String normalizedPrefix = normalizeKey(prefix);
            if (!normalizedPrefix.isEmpty() && !normalizedPrefix.endsWith("/")) {
                normalizedPrefix += "/";
            }

            Iterable<Result<Item>> results = minioClient.listObjects(
                    ListObjectsArgs.builder()
                            .bucket(bucket)
                            .prefix(normalizedPrefix)
                            .recursive(false)
                            .build()
            );
            for (Result<Item> result : results) {
                Item item = result.get();
                if (!item.isDir()) {
                    files.add(item.objectName());
                }
            }
        } catch (Exception e) {
            log.error("Erro ao listar arquivos no MinIO {}: {}", prefix, e.getMessage());
        }
        return files;
    }

    @Override
    public void copy(String sourcePath, String targetPath) {
        try {
            minioClient.copyObject(
                    CopyObjectArgs.builder()
                            .bucket(bucket)
                            .object(normalizeKey(targetPath))
                            .source(CopySource.builder()
                                    .bucket(bucket)
                                    .object(normalizeKey(sourcePath))
                                    .build())
                            .build()
            );
            log.debug("Arquivo copiado no MinIO: {} -> {}", sourcePath, targetPath);
        } catch (Exception e) {
            log.error("Erro ao copiar arquivo no MinIO: {}", e.getMessage());
            throw new StorageException("Erro ao copiar arquivo", e);
        }
    }

    @Override
    public void move(String sourcePath, String targetPath) {
        copy(sourcePath, targetPath);
        delete(sourcePath);
    }

    // ===== Utilitários =====

    private String normalizeKey(String path) {
        if (path == null) return "";
        return path.replace("\\", "/")
                .replaceAll("/+", "/")
                .replaceAll("^/", "");
    }

    private String detectContentType(String filename) {
        if (filename == null) return "application/octet-stream";
        String lower = filename.toLowerCase();
        if (lower.endsWith(".pdf")) return "application/pdf";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".gif")) return "image/gif";
        if (lower.endsWith(".doc")) return "application/msword";
        if (lower.endsWith(".docx")) return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
        if (lower.endsWith(".xls")) return "application/vnd.ms-excel";
        if (lower.endsWith(".xlsx")) return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        if (lower.endsWith(".csv")) return "text/csv";
        if (lower.endsWith(".txt")) return "text/plain";
        if (lower.endsWith(".xml")) return "application/xml";
        if (lower.endsWith(".json")) return "application/json";
        if (lower.endsWith(".zip")) return "application/zip";
        if (lower.endsWith(".rar")) return "application/x-rar-compressed";
        return "application/octet-stream";
    }
}
