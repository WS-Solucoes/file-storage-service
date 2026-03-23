package ws.filestorage.service;

import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import ws.filestorage.config.StorageProperties;
import ws.filestorage.exception.StorageException;
import ws.filestorage.exception.StorageFileNotFoundException;

import java.io.*;
import java.nio.file.*;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * Implementação de StorageService para armazenamento em sistema de arquivos local.
 * Ativado quando storage.type=LOCAL no application.yml.
 */
@Service
@ConditionalOnProperty(prefix = "storage", name = "type", havingValue = "LOCAL")
public class LocalStorageService implements StorageService {

    private static final Logger log = LoggerFactory.getLogger(LocalStorageService.class);

    private final StorageProperties storageProperties;
    private Path basePath;

    public LocalStorageService(StorageProperties storageProperties) {
        this.storageProperties = storageProperties;
    }

    @PostConstruct
    public void init() {
        this.basePath = Paths.get(storageProperties.getLocal().getBasePath()).toAbsolutePath().normalize();
        try {
            Files.createDirectories(basePath);
            log.info("Storage local inicializado em: {}", basePath);
        } catch (IOException e) {
            throw new StorageException("Não foi possível criar diretório de storage: " + basePath, e);
        }
    }

    @Override
    public void save(String storagePath, byte[] content, String contentType) {
        try {
            Path targetPath = resolveAndValidate(storagePath);
            Files.createDirectories(targetPath.getParent());
            Files.write(targetPath, content);
            log.debug("Arquivo salvo: {} ({} bytes)", storagePath, content.length);
        } catch (IOException e) {
            throw new StorageException("Erro ao salvar arquivo: " + storagePath, e);
        }
    }

    @Override
    public void save(String storagePath, InputStream inputStream, long size, String contentType) {
        try {
            Path targetPath = resolveAndValidate(storagePath);
            Files.createDirectories(targetPath.getParent());
            Files.copy(inputStream, targetPath, StandardCopyOption.REPLACE_EXISTING);
            log.debug("Arquivo salvo via stream: {}", storagePath);
        } catch (IOException e) {
            throw new StorageException("Erro ao salvar arquivo: " + storagePath, e);
        }
    }

    @Override
    public byte[] load(String storagePath) {
        try {
            Path filePath = resolveAndValidate(storagePath);
            if (!Files.exists(filePath)) {
                throw new StorageFileNotFoundException("Arquivo não encontrado: " + storagePath);
            }
            return Files.readAllBytes(filePath);
        } catch (StorageFileNotFoundException e) {
            throw e;
        } catch (IOException e) {
            throw new StorageException("Erro ao carregar arquivo: " + storagePath, e);
        }
    }

    @Override
    public InputStream loadAsStream(String storagePath) {
        try {
            Path filePath = resolveAndValidate(storagePath);
            if (!Files.exists(filePath)) {
                throw new StorageFileNotFoundException("Arquivo não encontrado: " + storagePath);
            }
            return new FileInputStream(filePath.toFile());
        } catch (StorageFileNotFoundException e) {
            throw e;
        } catch (IOException e) {
            throw new StorageException("Erro ao ler arquivo: " + storagePath, e);
        }
    }

    @Override
    public boolean delete(String storagePath) {
        try {
            Path filePath = resolveAndValidate(storagePath);
            return Files.deleteIfExists(filePath);
        } catch (IOException e) {
            log.error("Erro ao deletar arquivo {}: {}", storagePath, e.getMessage());
            return false;
        }
    }

    @Override
    public boolean exists(String storagePath) {
        Path filePath = resolveAndValidate(storagePath);
        return Files.exists(filePath);
    }

    @Override
    public long getFileSize(String storagePath) {
        try {
            Path filePath = resolveAndValidate(storagePath);
            return Files.exists(filePath) ? Files.size(filePath) : -1;
        } catch (IOException e) {
            return -1;
        }
    }

    @Override
    public String getContentType(String storagePath) {
        try {
            Path filePath = resolveAndValidate(storagePath);
            String mime = Files.probeContentType(filePath);
            return mime != null ? mime : "application/octet-stream";
        } catch (IOException e) {
            return "application/octet-stream";
        }
    }

    @Override
    public List<String> listFiles(String prefix) {
        try {
            Path dirPath = resolveAndValidate(prefix);
            if (!Files.exists(dirPath) || !Files.isDirectory(dirPath)) {
                return Collections.emptyList();
            }
            try (Stream<Path> stream = Files.list(dirPath)) {
                return stream
                        .filter(Files::isRegularFile)
                        .map(p -> basePath.relativize(p).toString().replace("\\", "/"))
                        .collect(Collectors.toList());
            }
        } catch (IOException e) {
            log.error("Erro ao listar arquivos em {}: {}", prefix, e.getMessage());
            return Collections.emptyList();
        }
    }

    @Override
    public void copy(String sourcePath, String targetPath) {
        try {
            Path source = resolveAndValidate(sourcePath);
            Path target = resolveAndValidate(targetPath);
            Files.createDirectories(target.getParent());
            Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new StorageException("Erro ao copiar arquivo: " + e.getMessage(), e);
        }
    }

    @Override
    public void move(String sourcePath, String targetPath) {
        try {
            Path source = resolveAndValidate(sourcePath);
            Path target = resolveAndValidate(targetPath);
            Files.createDirectories(target.getParent());
            Files.move(source, target, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new StorageException("Erro ao mover arquivo: " + e.getMessage(), e);
        }
    }

    private Path resolveAndValidate(String relativePath) {
        Path resolved = basePath.resolve(relativePath).normalize();
        if (!resolved.startsWith(basePath)) {
            throw new StorageException("Acesso negado: caminho fora do diretório base");
        }
        return resolved;
    }
}
