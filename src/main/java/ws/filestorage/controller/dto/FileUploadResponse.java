package ws.filestorage.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Resposta do upload de arquivo.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FileUploadResponse {

    private String storagePath;
    private String originalFilename;
    private String contentType;
    private long size;
    private String message;
}
