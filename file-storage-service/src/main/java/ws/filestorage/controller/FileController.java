package ws.filestorage.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import ws.filestorage.controller.dto.FileInfoResponse;
import ws.filestorage.controller.dto.FileUploadResponse;
import ws.filestorage.service.StorageService;

import java.io.InputStream;
import java.util.List;
import java.util.Map;

/**
 * REST API para operações de armazenamento de arquivos.
 * Upload, download, delete, info, list, copy, move.
 */
@RestController
@RequestMapping("/api/v1/files")
@Tag(name = "File Storage", description = "API de armazenamento de arquivos")
public class FileController {

    private static final Logger log = LoggerFactory.getLogger(FileController.class);

    private final StorageService storageService;

    public FileController(StorageService storageService) {
        this.storageService = storageService;
    }

    // ==================== Upload ====================

    @Operation(summary = "Upload de arquivo", description = "Faz upload de um arquivo para o caminho especificado")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<FileUploadResponse> upload(
            @RequestParam("file") MultipartFile file,
            @RequestParam("storagePath") String storagePath) {

        log.info("Upload recebido: {} -> {}", file.getOriginalFilename(), storagePath);

        try {
            storageService.save(storagePath, file.getInputStream(), file.getSize(), file.getContentType());

            FileUploadResponse response = FileUploadResponse.builder()
                    .storagePath(storagePath)
                    .originalFilename(file.getOriginalFilename())
                    .contentType(file.getContentType())
                    .size(file.getSize())
                    .message("Arquivo enviado com sucesso")
                    .build();

            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Erro no upload: {}", e.getMessage());
            throw new RuntimeException("Erro ao fazer upload: " + e.getMessage(), e);
        }
    }

    @Operation(summary = "Upload de bytes", description = "Faz upload de bytes diretamente")
    @PostMapping(value = "/bytes", consumes = MediaType.APPLICATION_OCTET_STREAM_VALUE)
    public ResponseEntity<FileUploadResponse> uploadBytes(
            @RequestBody byte[] content,
            @RequestParam("storagePath") String storagePath,
            @RequestParam(value = "contentType", defaultValue = "application/octet-stream") String contentType) {

        log.info("Upload bytes recebido: {} ({} bytes)", storagePath, content.length);
        storageService.save(storagePath, content, contentType);

        FileUploadResponse response = FileUploadResponse.builder()
                .storagePath(storagePath)
                .contentType(contentType)
                .size(content.length)
                .message("Arquivo enviado com sucesso")
                .build();

        return ResponseEntity.ok(response);
    }

    // ==================== Download ====================

    @Operation(summary = "Download de arquivo", description = "Baixa um arquivo pelo caminho de storage")
    @GetMapping("/download")
    public ResponseEntity<InputStreamResource> download(@RequestParam("path") String storagePath) {
        log.info("Download solicitado: {}", storagePath);

        InputStream inputStream = storageService.loadAsStream(storagePath);
        String contentType = storageService.getContentType(storagePath);
        long fileSize = storageService.getFileSize(storagePath);

        // Extrair nome do arquivo do path
        String filename = storagePath.contains("/")
                ? storagePath.substring(storagePath.lastIndexOf("/") + 1)
                : storagePath;

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.parseMediaType(contentType))
                .contentLength(fileSize > 0 ? fileSize : -1)
                .body(new InputStreamResource(inputStream));
    }

    @Operation(summary = "Download como bytes", description = "Retorna o conteúdo do arquivo como byte array")
    @GetMapping("/download/bytes")
    public ResponseEntity<byte[]> downloadBytes(@RequestParam("path") String storagePath) {
        byte[] content = storageService.load(storagePath);
        String contentType = storageService.getContentType(storagePath);

        String filename = storagePath.contains("/")
                ? storagePath.substring(storagePath.lastIndexOf("/") + 1)
                : storagePath;

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + filename + "\"")
                .contentType(MediaType.parseMediaType(contentType))
                .body(content);
    }

    // ==================== Delete ====================

    @Operation(summary = "Deletar arquivo", description = "Remove um arquivo do storage")
    @DeleteMapping
    public ResponseEntity<Map<String, Object>> delete(@RequestParam("path") String storagePath) {
        log.info("Delete solicitado: {}", storagePath);
        boolean deleted = storageService.delete(storagePath);
        return ResponseEntity.ok(Map.of(
                "path", storagePath,
                "deleted", deleted,
                "message", deleted ? "Arquivo deletado com sucesso" : "Arquivo não encontrado"
        ));
    }

    // ==================== Info ====================

    @Operation(summary = "Informações do arquivo", description = "Retorna metadados de um arquivo")
    @GetMapping("/info")
    public ResponseEntity<FileInfoResponse> info(@RequestParam("path") String storagePath) {
        boolean exists = storageService.exists(storagePath);
        FileInfoResponse response = FileInfoResponse.builder()
                .storagePath(storagePath)
                .exists(exists)
                .size(exists ? storageService.getFileSize(storagePath) : 0)
                .contentType(exists ? storageService.getContentType(storagePath) : null)
                .build();
        return ResponseEntity.ok(response);
    }

    // ==================== Exists ====================

    @Operation(summary = "Verificar existência", description = "Verifica se um arquivo existe no storage")
    @GetMapping("/exists")
    public ResponseEntity<Map<String, Object>> exists(@RequestParam("path") String storagePath) {
        boolean exists = storageService.exists(storagePath);
        return ResponseEntity.ok(Map.of("path", storagePath, "exists", exists));
    }

    // ==================== List ====================

    @Operation(summary = "Listar arquivos", description = "Lista arquivos de um diretório/prefixo")
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> list(
            @RequestParam(value = "prefix", defaultValue = "") String prefix) {
        List<String> files = storageService.listFiles(prefix);
        return ResponseEntity.ok(Map.of("prefix", prefix, "files", files, "count", files.size()));
    }

    // ==================== Copy / Move ====================

    @Operation(summary = "Copiar arquivo", description = "Copia um arquivo de um caminho para outro")
    @PostMapping("/copy")
    public ResponseEntity<Map<String, Object>> copy(@RequestBody Map<String, String> body) {
        String source = body.get("source");
        String target = body.get("target");
        storageService.copy(source, target);
        return ResponseEntity.ok(Map.of(
                "source", source,
                "target", target,
                "message", "Arquivo copiado com sucesso"
        ));
    }

    @Operation(summary = "Mover arquivo", description = "Move um arquivo de um caminho para outro")
    @PostMapping("/move")
    public ResponseEntity<Map<String, Object>> move(@RequestBody Map<String, String> body) {
        String source = body.get("source");
        String target = body.get("target");
        storageService.move(source, target);
        return ResponseEntity.ok(Map.of(
                "source", source,
                "target", target,
                "message", "Arquivo movido com sucesso"
        ));
    }

    // ==================== Health ====================

    @Operation(summary = "Health check do storage", description = "Verifica se o storage está operacional")
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "UP", "service", "file-storage-service"));
    }
}
