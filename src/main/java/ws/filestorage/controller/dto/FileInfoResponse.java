package ws.filestorage.controller.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Informações sobre um arquivo armazenado.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FileInfoResponse {

    private String storagePath;
    private long size;
    private String contentType;
    private boolean exists;
}
