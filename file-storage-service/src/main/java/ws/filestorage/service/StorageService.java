package ws.filestorage.service;

import java.io.InputStream;
import java.util.List;

/**
 * Interface abstrata para serviço de armazenamento de arquivos.
 * Implementações: MinIO (S3) e Local (sistema de arquivos).
 */
public interface StorageService {

    /**
     * Salva bytes no caminho especificado.
     */
    void save(String storagePath, byte[] content, String contentType);

    /**
     * Salva stream no caminho especificado.
     */
    void save(String storagePath, InputStream inputStream, long size, String contentType);

    /**
     * Lê o conteúdo do arquivo como bytes.
     */
    byte[] load(String storagePath);

    /**
     * Lê o conteúdo do arquivo como InputStream.
     */
    InputStream loadAsStream(String storagePath);

    /**
     * Deleta o arquivo.
     */
    boolean delete(String storagePath);

    /**
     * Verifica se o arquivo existe.
     */
    boolean exists(String storagePath);

    /**
     * Obtém o tamanho do arquivo em bytes.
     */
    long getFileSize(String storagePath);

    /**
     * Obtém o content-type do arquivo.
     */
    String getContentType(String storagePath);

    /**
     * Lista arquivos em um diretório/prefixo.
     */
    List<String> listFiles(String prefix);

    /**
     * Copia um arquivo.
     */
    void copy(String sourcePath, String targetPath);

    /**
     * Move um arquivo.
     */
    void move(String sourcePath, String targetPath);
}
