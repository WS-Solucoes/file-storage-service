package ws.filestorage.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Configurações para o serviço de armazenamento.
 * Suporta LOCAL (sistema de arquivos) e MINIO (S3 compatível).
 */
@Configuration
@ConfigurationProperties(prefix = "storage")
public class StorageProperties {

    private StorageType type = StorageType.MINIO;
    private Local local = new Local();
    private Minio minio = new Minio();

    public StorageType getType() { return type; }
    public void setType(StorageType type) { this.type = type; }
    public Local getLocal() { return local; }
    public void setLocal(Local local) { this.local = local; }
    public Minio getMinio() { return minio; }
    public void setMinio(Minio minio) { this.minio = minio; }

    public enum StorageType {
        LOCAL,
        MINIO
    }

    public static class Local {
        private String basePath = "./storage-files";

        public String getBasePath() { return basePath; }
        public void setBasePath(String basePath) { this.basePath = basePath; }
    }

    public static class Minio {
        private String endpoint = "http://localhost:9000";
        private String accessKey = "minioadmin";
        private String secretKey = "minioadmin";
        private String bucket = "ws-documentos";
        private String region = "us-east-1";
        private boolean secure = false;

        public String getEndpoint() { return endpoint; }
        public void setEndpoint(String endpoint) { this.endpoint = endpoint; }
        public String getAccessKey() { return accessKey; }
        public void setAccessKey(String accessKey) { this.accessKey = accessKey; }
        public String getSecretKey() { return secretKey; }
        public void setSecretKey(String secretKey) { this.secretKey = secretKey; }
        public String getBucket() { return bucket; }
        public void setBucket(String bucket) { this.bucket = bucket; }
        public String getRegion() { return region; }
        public void setRegion(String region) { this.region = region; }
        public boolean isSecure() { return secure; }
        public void setSecure(boolean secure) { this.secure = secure; }
    }
}
