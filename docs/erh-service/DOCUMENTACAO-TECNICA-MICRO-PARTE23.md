# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 23
## Módulo de Gestão Documental (GED)

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar documentos digitais dos servidores, aposentados e pensionistas, incluindo upload, armazenamento, categorização, versionamento e acesso controlado ao prontuário funcional digital.

### 1.2 Escopo
- Upload e armazenamento de documentos
- Prontuário funcional digital
- Categorização e indexação
- Controle de versões
- Assinatura digital
- Temporalidade e descarte
- Pesquisa e recuperação

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### Documento
```java
@Entity
@Table(name = "documento")
public class Documento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50)
    private String codigo;
    
    @Column(nullable = false, length = 300)
    private String titulo;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_documento_id", nullable = false)
    private TipoDocumento tipoDocumento;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "categoria_id")
    private CategoriaDocumento categoria;
    
    // Vinculação
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id")
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aposentado_id")
    private Aposentado aposentado;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pensionista_id")
    private Pensionista pensionista;
    
    @Column(name = "entidade_tipo", length = 50)
    private String entidadeTipo; // Ex: "FERIAS", "LICENCA", "AVALIACAO"
    
    @Column(name = "entidade_id")
    private Long entidadeId;
    
    // Arquivo
    @Column(name = "nome_arquivo", nullable = false, length = 300)
    private String nomeArquivo;
    
    @Column(name = "nome_original", length = 300)
    private String nomeOriginal;
    
    @Column(name = "extensao", length = 20)
    private String extensao;
    
    @Column(name = "mime_type", length = 100)
    private String mimeType;
    
    @Column(name = "tamanho_bytes")
    private Long tamanhoBytes;
    
    @Column(name = "storage_path", nullable = false, length = 500)
    private String storagePath;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "storage_type")
    private StorageType storageType;
    
    @Column(name = "hash_md5", length = 32)
    private String hashMD5;
    
    @Column(name = "hash_sha256", length = 64)
    private String hashSHA256;
    
    // Metadados
    @Column(name = "data_documento")
    private LocalDate dataDocumento;
    
    @Column(name = "numero_documento", length = 100)
    private String numeroDocumento;
    
    @Column(name = "orgao_emissor", length = 200)
    private String orgaoEmissor;
    
    @Column(name = "data_validade")
    private LocalDate dataValidade;
    
    // Versionamento
    @Column(name = "versao", nullable = false)
    private Integer versao = 1;
    
    @ManyToOne
    @JoinColumn(name = "documento_pai_id")
    private Documento documentoPai;
    
    @Column(name = "versao_atual")
    private Boolean versaoAtual = true;
    
    // Status
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoDocumento situacao;
    
    @Column(name = "confidencial")
    private Boolean confidencial = false;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_acesso")
    private NivelAcessoDocumento nivelAcesso;
    
    // Assinatura Digital
    @Column(name = "assinado_digitalmente")
    private Boolean assinadoDigitalmente = false;
    
    @Column(name = "data_assinatura")
    private LocalDateTime dataAssinatura;
    
    @Column(name = "certificado_info", columnDefinition = "TEXT")
    private String certificadoInfo;
    
    // Temporalidade
    @Column(name = "data_arquivamento")
    private LocalDate dataArquivamento;
    
    @Column(name = "data_descarte_prevista")
    private LocalDate dataDescartePrevista;
    
    @Column(name = "descartado")
    private Boolean descartado = false;
    
    @Column(name = "data_descarte")
    private LocalDate dataDescarte;
    
    // OCR
    @Column(name = "ocr_processado")
    private Boolean ocrProcessado = false;
    
    @Column(name = "conteudo_ocr", columnDefinition = "TEXT")
    private String conteudoOCR;
    
    // Auditoria
    @Column(name = "data_upload", nullable = false)
    private LocalDateTime dataUpload;
    
    @ManyToOne
    @JoinColumn(name = "usuario_upload_id")
    private Usuario usuarioUpload;
    
    @Column(name = "data_atualizacao")
    private LocalDateTime dataAtualizacao;
    
    @OneToMany(mappedBy = "documento", cascade = CascadeType.ALL)
    private List<DocumentoTag> tags = new ArrayList<>();
    
    @OneToMany(mappedBy = "documento", cascade = CascadeType.ALL)
    private List<AcessoDocumento> acessos = new ArrayList<>();
}
```

#### TipoDocumento
```java
@Entity
@Table(name = "tipo_documento")
public class TipoDocumento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 20)
    private String codigo;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @ManyToOne
    @JoinColumn(name = "categoria_id")
    private CategoriaDocumento categoria;
    
    @Column(name = "extensoes_permitidas", length = 200)
    private String extensoesPermitidas; // "pdf,jpg,png"
    
    @Column(name = "tamanho_maximo_mb")
    private Integer tamanhoMaximoMB;
    
    @Column(name = "exige_assinatura")
    private Boolean exigeAssinatura = false;
    
    @Column(name = "prazo_temporalidade_anos")
    private Integer prazoTemporalidadeAnos;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "destino_pos_temporalidade")
    private DestinoTemporalidade destinoPosTemporalidade;
    
    @Column(name = "obrigatorio_prontuario")
    private Boolean obrigatorioProntuario = false;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @OneToMany(mappedBy = "tipoDocumento")
    private List<CampoMetadado> camposMetadados = new ArrayList<>();
}
```

#### CategoriaDocumento
```java
@Entity
@Table(name = "categoria_documento")
public class CategoriaDocumento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 20)
    private String codigo;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @ManyToOne
    @JoinColumn(name = "categoria_pai_id")
    private CategoriaDocumento categoriaPai;
    
    @Column(name = "nivel")
    private Integer nivel = 1;
    
    @Column(name = "ordem")
    private Integer ordem;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @OneToMany(mappedBy = "categoriaPai")
    private List<CategoriaDocumento> subcategorias = new ArrayList<>();
}
```

#### ProntuarioFuncional
```java
@Entity
@Table(name = "prontuario_funcional")
public class ProntuarioFuncional {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id")
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aposentado_id")
    private Aposentado aposentado;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pensionista_id")
    private Pensionista pensionista;
    
    @Column(name = "numero_prontuario", nullable = false, length = 30)
    private String numeroProntuario;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoProntuario situacao;
    
    @Column(name = "data_abertura")
    private LocalDate dataAbertura;
    
    @Column(name = "data_encerramento")
    private LocalDate dataEncerramento;
    
    @Column(name = "localizacao_fisica", length = 200)
    private String localizacaoFisica;
    
    @Column(name = "digitalizado")
    private Boolean digitalizado = false;
    
    @Column(name = "data_digitalizacao")
    private LocalDate dataDigitalizacao;
    
    @Column(name = "total_documentos")
    private Integer totalDocumentos = 0;
    
    @Column(name = "total_paginas")
    private Integer totalPaginas = 0;
    
    @OneToMany(mappedBy = "prontuario", cascade = CascadeType.ALL)
    @OrderBy("ordem")
    private List<SecaoProntuario> secoes = new ArrayList<>();
}
```

#### SecaoProntuario
```java
@Entity
@Table(name = "secao_prontuario")
public class SecaoProntuario {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prontuario_id", nullable = false)
    private ProntuarioFuncional prontuario;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Column(name = "ordem", nullable = false)
    private Integer ordem;
    
    @ManyToOne
    @JoinColumn(name = "categoria_id")
    private CategoriaDocumento categoria;
    
    @OneToMany(mappedBy = "secao")
    @OrderBy("dataDocumento DESC")
    private List<DocumentoProntuario> documentos = new ArrayList<>();
}
```

#### DocumentoProntuario
```java
@Entity
@Table(name = "documento_prontuario")
public class DocumentoProntuario {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prontuario_id", nullable = false)
    private ProntuarioFuncional prontuario;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "secao_id")
    private SecaoProntuario secao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "documento_id", nullable = false)
    private Documento documento;
    
    @Column(name = "ordem")
    private Integer ordem;
    
    @Column(name = "pagina_inicial")
    private Integer paginaInicial;
    
    @Column(name = "pagina_final")
    private Integer paginaFinal;
    
    @Column(name = "data_inclusao")
    private LocalDateTime dataInclusao;
}
```

#### AcessoDocumento
```java
@Entity
@Table(name = "acesso_documento")
public class AcessoDocumento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "documento_id", nullable = false)
    private Documento documento;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_acesso", nullable = false)
    private TipoAcessoDocumento tipoAcesso;
    
    @Column(name = "data_acesso", nullable = false)
    private LocalDateTime dataAcesso;
    
    @Column(name = "ip_acesso", length = 50)
    private String ipAcesso;
    
    @Column(name = "user_agent", length = 500)
    private String userAgent;
}
```

#### DocumentoTag
```java
@Entity
@Table(name = "documento_tag")
public class DocumentoTag {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "documento_id", nullable = false)
    private Documento documento;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tag_id", nullable = false)
    private Tag tag;
}
```

#### Tag
```java
@Entity
@Table(name = "tag")
public class Tag {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50, unique = true)
    private String nome;
    
    @Column(length = 7)
    private String cor; // #FFFFFF
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum StorageType {
    LOCAL("Local"),
    S3("Amazon S3"),
    AZURE_BLOB("Azure Blob Storage"),
    MINIO("MinIO");
}

public enum SituacaoDocumento {
    ATIVO("Ativo"),
    ARQUIVADO("Arquivado"),
    DESCARTADO("Descartado"),
    PENDENTE_VALIDACAO("Pendente de Validação"),
    REJEITADO("Rejeitado");
}

public enum NivelAcessoDocumento {
    PUBLICO("Público"),
    INTERNO("Interno"),
    RESTRITO("Restrito"),
    CONFIDENCIAL("Confidencial"),
    SECRETO("Secreto");
}

public enum DestinoTemporalidade {
    GUARDA_PERMANENTE("Guarda Permanente"),
    ELIMINACAO("Eliminação"),
    AMOSTRAGEM("Amostragem");
}

public enum SituacaoProntuario {
    ATIVO("Ativo"),
    ARQUIVADO("Arquivado"),
    ENCERRADO("Encerrado");
}

public enum TipoAcessoDocumento {
    VISUALIZACAO("Visualização"),
    DOWNLOAD("Download"),
    IMPRESSAO("Impressão"),
    EDICAO("Edição");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Upload de Documentos

| Código | Regra | Descrição |
|--------|-------|-----------|
| UPL-001 | Extensão | Validar extensões permitidas por tipo |
| UPL-002 | Tamanho | Respeitar limite de tamanho por tipo |
| UPL-003 | Antivírus | Escanear arquivo antes de armazenar |
| UPL-004 | Hash | Gerar hash para integridade |
| UPL-005 | Duplicidade | Verificar duplicidade por hash |

### 4.2 Prontuário Funcional

| Código | Regra | Descrição |
|--------|-------|-----------|
| PRO-001 | Único | Um prontuário por servidor |
| PRO-002 | Obrigatórios | Documentos obrigatórios conforme tipo |
| PRO-003 | Organização | Documentos organizados por seção |
| PRO-004 | Integridade | Não permitir exclusão física |

### 4.3 Acesso

| Código | Regra | Descrição |
|--------|-------|-----------|
| ACE-001 | Permissão | Validar nível de acesso do usuário |
| ACE-002 | Confidencial | Documentos confidenciais com acesso restrito |
| ACE-003 | Auditoria | Registrar todos os acessos |
| ACE-004 | Próprios | Servidor pode ver seus próprios documentos |

### 4.4 Temporalidade

| Código | Regra | Descrição |
|--------|-------|-----------|
| TMP-001 | Prazo | Respeitar prazo de guarda por tipo |
| TMP-002 | Listagem | Gerar listagem de eliminação |
| TMP-003 | Aprovação | Descarte exige aprovação da comissão |
| TMP-004 | Permanente | Alguns documentos são de guarda permanente |

---

## 5. SERVIÇOS

### 5.1 DocumentoService
```java
@Service
@Transactional
public class DocumentoService {
    
    @Autowired
    private StorageService storageService;
    
    @Autowired
    private AntivirusService antivirusService;
    
    @Autowired
    private OCRService ocrService;
    
    public Documento upload(DocumentoUploadDTO dto, MultipartFile arquivo) {
        TipoDocumento tipo = tipoDocumentoRepository.findById(dto.getTipoDocumentoId()).orElseThrow();
        
        // UPL-001: Validar extensão
        String extensao = getExtensao(arquivo.getOriginalFilename());
        validarExtensao(extensao, tipo);
        
        // UPL-002: Validar tamanho
        validarTamanho(arquivo.getSize(), tipo);
        
        // UPL-003: Escanear antivírus
        if (!antivirusService.isLimpo(arquivo.getInputStream())) {
            throw new BusinessException("Arquivo contém ameaças detectadas");
        }
        
        // UPL-004: Gerar hashes
        String hashMD5 = calcularHash(arquivo.getBytes(), "MD5");
        String hashSHA256 = calcularHash(arquivo.getBytes(), "SHA-256");
        
        // UPL-005: Verificar duplicidade
        if (dto.getServidorId() != null && 
            documentoRepository.existsByServidorAndHash(dto.getServidorId(), hashSHA256)) {
            throw new BusinessException("Documento já existe para este servidor");
        }
        
        // Salvar arquivo no storage
        String storagePath = storageService.salvar(arquivo, gerarCaminho(dto));
        
        Documento documento = new Documento();
        documento.setCodigo(gerarCodigo());
        documento.setTitulo(dto.getTitulo());
        documento.setDescricao(dto.getDescricao());
        documento.setTipoDocumento(tipo);
        documento.setNomeArquivo(gerarNomeArquivo(extensao));
        documento.setNomeOriginal(arquivo.getOriginalFilename());
        documento.setExtensao(extensao);
        documento.setMimeType(arquivo.getContentType());
        documento.setTamanhoBytes(arquivo.getSize());
        documento.setStoragePath(storagePath);
        documento.setStorageType(storageService.getType());
        documento.setHashMD5(hashMD5);
        documento.setHashSHA256(hashSHA256);
        documento.setDataDocumento(dto.getDataDocumento());
        documento.setNumeroDocumento(dto.getNumeroDocumento());
        documento.setSituacao(SituacaoDocumento.ATIVO);
        documento.setNivelAcesso(dto.getNivelAcesso() != null ? dto.getNivelAcesso() : NivelAcessoDocumento.INTERNO);
        documento.setDataUpload(LocalDateTime.now());
        documento.setUsuarioUpload(getUsuarioLogado());
        
        // Vinculação
        if (dto.getServidorId() != null) {
            documento.setServidor(servidorRepository.findById(dto.getServidorId()).orElseThrow());
        }
        documento.setEntidadeTipo(dto.getEntidadeTipo());
        documento.setEntidadeId(dto.getEntidadeId());
        
        // Calcular temporalidade
        if (tipo.getPrazoTemporalidadeAnos() != null) {
            documento.setDataDescartePrevista(
                LocalDate.now().plusYears(tipo.getPrazoTemporalidadeAnos())
            );
        }
        
        documento = documentoRepository.save(documento);
        
        // Processar OCR assíncrono para PDFs e imagens
        if (deveProcessarOCR(extensao)) {
            processarOCRAsync(documento.getId());
        }
        
        // Adicionar ao prontuário se aplicável
        if (dto.getServidorId() != null && tipo.getObrigatorioProntuario()) {
            adicionarAoProntuario(documento);
        }
        
        return documento;
    }
    
    public Resource download(Long documentoId) {
        Documento documento = documentoRepository.findById(documentoId).orElseThrow();
        
        // Validar acesso
        validarAcesso(documento, TipoAcessoDocumento.DOWNLOAD);
        
        // Registrar acesso
        registrarAcesso(documento, TipoAcessoDocumento.DOWNLOAD);
        
        return storageService.carregar(documento.getStoragePath());
    }
    
    public Documento novaVersao(Long documentoId, MultipartFile arquivo) {
        Documento documentoAnterior = documentoRepository.findById(documentoId).orElseThrow();
        
        // Marca versão anterior como não atual
        documentoAnterior.setVersaoAtual(false);
        documentoRepository.save(documentoAnterior);
        
        // Cria nova versão
        DocumentoUploadDTO dto = DocumentoUploadDTO.builder()
            .tipoDocumentoId(documentoAnterior.getTipoDocumento().getId())
            .titulo(documentoAnterior.getTitulo())
            .servidorId(documentoAnterior.getServidor() != null ? documentoAnterior.getServidor().getId() : null)
            .build();
        
        Documento novaVersao = upload(dto, arquivo);
        novaVersao.setDocumentoPai(documentoAnterior.getDocumentoPai() != null 
            ? documentoAnterior.getDocumentoPai() 
            : documentoAnterior);
        novaVersao.setVersao(documentoAnterior.getVersao() + 1);
        
        return documentoRepository.save(novaVersao);
    }
    
    public List<Documento> buscar(DocumentoBuscaDTO filtros) {
        Specification<Documento> spec = Specification.where(null);
        
        if (filtros.getServidorId() != null) {
            spec = spec.and((root, query, cb) -> 
                cb.equal(root.get("servidor").get("id"), filtros.getServidorId()));
        }
        
        if (filtros.getTipoDocumentoId() != null) {
            spec = spec.and((root, query, cb) -> 
                cb.equal(root.get("tipoDocumento").get("id"), filtros.getTipoDocumentoId()));
        }
        
        if (filtros.getTextoBusca() != null) {
            String termo = "%" + filtros.getTextoBusca().toLowerCase() + "%";
            spec = spec.and((root, query, cb) -> cb.or(
                cb.like(cb.lower(root.get("titulo")), termo),
                cb.like(cb.lower(root.get("descricao")), termo),
                cb.like(cb.lower(root.get("conteudoOCR")), termo)
            ));
        }
        
        // Aplicar filtro de acesso
        spec = spec.and(filtrarPorNivelAcesso());
        
        return documentoRepository.findAll(spec);
    }
    
    private void validarAcesso(Documento documento, TipoAcessoDocumento tipoAcesso) {
        Usuario usuario = getUsuarioLogado();
        
        // ACE-004: Servidor pode ver seus próprios documentos
        if (documento.getServidor() != null && 
            documento.getServidor().getId().equals(usuario.getServidorId())) {
            return;
        }
        
        // ACE-001: Verificar nível de acesso
        NivelAcessoDocumento nivelUsuario = getNivelAcessoUsuario(usuario);
        if (documento.getNivelAcesso().ordinal() > nivelUsuario.ordinal()) {
            throw new AccessDeniedException("Usuário não tem permissão para acessar este documento");
        }
    }
    
    @Async
    private void processarOCRAsync(Long documentoId) {
        Documento documento = documentoRepository.findById(documentoId).orElseThrow();
        
        try {
            Resource resource = storageService.carregar(documento.getStoragePath());
            String textoOCR = ocrService.extrairTexto(resource.getInputStream());
            
            documento.setConteudoOCR(textoOCR);
            documento.setOcrProcessado(true);
            documentoRepository.save(documento);
        } catch (Exception e) {
            log.error("Erro ao processar OCR do documento {}: {}", documentoId, e.getMessage());
        }
    }
}
```

### 5.2 ProntuarioService
```java
@Service
@Transactional
public class ProntuarioService {
    
    public ProntuarioFuncional criarProntuario(Long servidorId) {
        Servidor servidor = servidorRepository.findById(servidorId).orElseThrow();
        
        // PRO-001: Verificar se já existe
        if (prontuarioRepository.existsByServidorId(servidorId)) {
            throw new BusinessException("Servidor já possui prontuário");
        }
        
        ProntuarioFuncional prontuario = new ProntuarioFuncional();
        prontuario.setServidor(servidor);
        prontuario.setNumeroProntuario(gerarNumeroProntuario());
        prontuario.setSituacao(SituacaoProntuario.ATIVO);
        prontuario.setDataAbertura(LocalDate.now());
        
        prontuario = prontuarioRepository.save(prontuario);
        
        // Criar seções padrão
        criarSecoesPadrao(prontuario);
        
        return prontuario;
    }
    
    private void criarSecoesPadrao(ProntuarioFuncional prontuario) {
        String[] secoesPadrao = {
            "Documentos Pessoais",
            "Admissão",
            "Férias",
            "Licenças",
            "Capacitação",
            "Avaliações",
            "Progressões",
            "Saúde Ocupacional",
            "Processos Administrativos",
            "Outros"
        };
        
        int ordem = 1;
        for (String nomeSecao : secoesPadrao) {
            SecaoProntuario secao = new SecaoProntuario();
            secao.setProntuario(prontuario);
            secao.setNome(nomeSecao);
            secao.setOrdem(ordem++);
            secaoProntuarioRepository.save(secao);
        }
    }
    
    public DocumentoProntuario adicionarDocumento(Long prontuarioId, Long documentoId, Long secaoId) {
        ProntuarioFuncional prontuario = prontuarioRepository.findById(prontuarioId).orElseThrow();
        Documento documento = documentoRepository.findById(documentoId).orElseThrow();
        SecaoProntuario secao = secaoProntuarioRepository.findById(secaoId).orElseThrow();
        
        // Verifica se já está no prontuário
        if (documentoProntuarioRepository.existsByProntuarioAndDocumento(prontuarioId, documentoId)) {
            throw new BusinessException("Documento já está no prontuário");
        }
        
        DocumentoProntuario docProntuario = new DocumentoProntuario();
        docProntuario.setProntuario(prontuario);
        docProntuario.setSecao(secao);
        docProntuario.setDocumento(documento);
        docProntuario.setOrdem(calcularProximaOrdem(secaoId));
        docProntuario.setDataInclusao(LocalDateTime.now());
        
        docProntuario = documentoProntuarioRepository.save(docProntuario);
        
        // Atualiza contadores
        atualizarContadores(prontuario);
        
        return docProntuario;
    }
    
    public ProntuarioFuncional getProntuarioCompleto(Long servidorId) {
        ProntuarioFuncional prontuario = prontuarioRepository.findByServidorId(servidorId)
            .orElseThrow(() -> new BusinessException("Prontuário não encontrado"));
        
        // Carregar seções e documentos
        prontuario.getSecoes().forEach(secao -> {
            secao.getDocumentos().size(); // Force load
        });
        
        return prontuario;
    }
    
    public void verificarDocumentosObrigatorios(Long prontuarioId) {
        ProntuarioFuncional prontuario = prontuarioRepository.findById(prontuarioId).orElseThrow();
        
        List<TipoDocumento> obrigatorios = tipoDocumentoRepository.findObrigatoriosProntuario();
        List<TipoDocumento> faltantes = new ArrayList<>();
        
        for (TipoDocumento tipo : obrigatorios) {
            boolean existe = documentoProntuarioRepository.existsByProntuarioAndTipoDocumento(
                prontuarioId, tipo.getId()
            );
            if (!existe) {
                faltantes.add(tipo);
            }
        }
        
        if (!faltantes.isEmpty()) {
            throw new BusinessException("Documentos obrigatórios faltantes: " + 
                faltantes.stream().map(TipoDocumento::getNome).collect(Collectors.joining(", ")));
        }
    }
}
```

### 5.3 TemporalidadeService
```java
@Service
@Transactional
public class TemporalidadeService {
    
    public List<Documento> listarParaDescarte(LocalDate dataLimite) {
        return documentoRepository.findByDataDescartePrevistaBeforeAndDescartadoFalse(dataLimite);
    }
    
    public ListagemEliminacao gerarListagemEliminacao(LocalDate dataLimite) {
        List<Documento> documentos = listarParaDescarte(dataLimite);
        
        ListagemEliminacao listagem = new ListagemEliminacao();
        listagem.setDataGeracao(LocalDateTime.now());
        listagem.setDataLimite(dataLimite);
        listagem.setTotalDocumentos(documentos.size());
        listagem.setSituacao(SituacaoListagem.AGUARDANDO_APROVACAO);
        
        listagem = listagemRepository.save(listagem);
        
        for (Documento doc : documentos) {
            ItemListagem item = new ItemListagem();
            item.setListagem(listagem);
            item.setDocumento(doc);
            item.setTipoDocumento(doc.getTipoDocumento().getNome());
            item.setDataDocumento(doc.getDataDocumento());
            item.setDestino(doc.getTipoDocumento().getDestinoPosTemporalidade());
            itemListagemRepository.save(item);
        }
        
        return listagem;
    }
    
    public void aprovarEliminacao(Long listagemId, Long aprovadorId) {
        ListagemEliminacao listagem = listagemRepository.findById(listagemId).orElseThrow();
        
        // TMP-003: Registrar aprovação
        listagem.setAprovadoPor(usuarioRepository.findById(aprovadorId).orElseThrow());
        listagem.setDataAprovacao(LocalDateTime.now());
        listagem.setSituacao(SituacaoListagem.APROVADA);
        listagemRepository.save(listagem);
    }
    
    public void executarEliminacao(Long listagemId) {
        ListagemEliminacao listagem = listagemRepository.findById(listagemId).orElseThrow();
        
        if (listagem.getSituacao() != SituacaoListagem.APROVADA) {
            throw new BusinessException("Listagem não está aprovada");
        }
        
        for (ItemListagem item : listagem.getItens()) {
            if (item.getDestino() == DestinoTemporalidade.ELIMINACAO) {
                eliminarDocumento(item.getDocumento());
            }
        }
        
        listagem.setSituacao(SituacaoListagem.EXECUTADA);
        listagem.setDataExecucao(LocalDateTime.now());
        listagemRepository.save(listagem);
    }
    
    private void eliminarDocumento(Documento documento) {
        // PRO-004: Não exclui fisicamente, apenas marca
        documento.setDescartado(true);
        documento.setDataDescarte(LocalDate.now());
        documento.setSituacao(SituacaoDocumento.DESCARTADO);
        documentoRepository.save(documento);
        
        // Remove do storage (opcional)
        // storageService.excluir(documento.getStoragePath());
    }
}
```

### 5.4 AssinaturaDigitalService
```java
@Service
@Transactional
public class AssinaturaDigitalService {
    
    public Documento assinarDocumento(Long documentoId, CertificadoDigital certificado) {
        Documento documento = documentoRepository.findById(documentoId).orElseThrow();
        
        // Carregar arquivo
        Resource resource = storageService.carregar(documento.getStoragePath());
        
        // Assinar
        byte[] documentoAssinado = assinarPDF(resource.getInputStream(), certificado);
        
        // Salvar documento assinado
        String novoPath = storageService.salvar(documentoAssinado, 
            documento.getStoragePath().replace(".pdf", "_assinado.pdf"));
        
        documento.setStoragePath(novoPath);
        documento.setAssinadoDigitalmente(true);
        documento.setDataAssinatura(LocalDateTime.now());
        documento.setCertificadoInfo(extrairInfoCertificado(certificado));
        documento.setHashSHA256(calcularHash(documentoAssinado, "SHA-256"));
        
        return documentoRepository.save(documento);
    }
    
    public boolean validarAssinatura(Long documentoId) {
        Documento documento = documentoRepository.findById(documentoId).orElseThrow();
        
        if (!documento.getAssinadoDigitalmente()) {
            return false;
        }
        
        Resource resource = storageService.carregar(documento.getStoragePath());
        return verificarAssinaturaPDF(resource.getInputStream());
    }
}
```

---

## 6. API REST

### 6.1 Endpoints

```
# Documentos
POST   /api/v1/documentos/upload                         # Upload documento
GET    /api/v1/documentos                                # Lista documentos
GET    /api/v1/documentos/{id}                           # Busca documento
GET    /api/v1/documentos/{id}/download                  # Download
GET    /api/v1/documentos/{id}/visualizar                # Visualizar inline
DELETE /api/v1/documentos/{id}                           # Arquiva documento
POST   /api/v1/documentos/{id}/versao                    # Nova versão
GET    /api/v1/documentos/{id}/versoes                   # Lista versões
POST   /api/v1/documentos/{id}/assinar                   # Assinar digitalmente
GET    /api/v1/documentos/{id}/validar-assinatura        # Validar assinatura

# Tipos de Documento
GET    /api/v1/documentos/tipos                          # Lista tipos
POST   /api/v1/documentos/tipos                          # Cria tipo
PUT    /api/v1/documentos/tipos/{id}                     # Atualiza tipo

# Categorias
GET    /api/v1/documentos/categorias                     # Lista categorias
GET    /api/v1/documentos/categorias/arvore              # Árvore de categorias

# Prontuário
GET    /api/v1/prontuarios                               # Lista prontuários
POST   /api/v1/prontuarios                               # Cria prontuário
GET    /api/v1/prontuarios/{id}                          # Busca prontuário
GET    /api/v1/servidores/{id}/prontuario                # Prontuário do servidor
POST   /api/v1/prontuarios/{id}/documentos               # Adiciona documento
DELETE /api/v1/prontuarios/{id}/documentos/{docId}       # Remove documento
GET    /api/v1/prontuarios/{id}/verificar-obrigatorios   # Verifica obrigatórios
POST   /api/v1/prontuarios/{id}/secoes                   # Cria seção
PUT    /api/v1/prontuarios/{id}/secoes/{secaoId}         # Atualiza seção

# Tags
GET    /api/v1/documentos/tags                           # Lista tags
POST   /api/v1/documentos/tags                           # Cria tag
POST   /api/v1/documentos/{id}/tags                      # Adiciona tags

# Temporalidade
GET    /api/v1/documentos/temporalidade/pendentes        # Documentos para descarte
POST   /api/v1/documentos/temporalidade/listagem         # Gera listagem eliminação
POST   /api/v1/documentos/temporalidade/listagem/{id}/aprovar # Aprova listagem
POST   /api/v1/documentos/temporalidade/listagem/{id}/executar # Executa eliminação

# Busca
GET    /api/v1/documentos/busca                          # Busca avançada
GET    /api/v1/documentos/busca/texto                    # Busca full-text (OCR)

# Por Servidor
GET    /api/v1/servidores/{id}/documentos                # Documentos do servidor
```

---

## 7. RELATÓRIOS

### 7.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| Documentos por Servidor | Lista documentos do servidor | Servidor |
| Documentos por Tipo | Estatísticas por tipo | Período |
| Prontuários Incompletos | Faltando documentos obrigatórios | Tipo documento |
| Documentos a Vencer | Temporalidade próxima | Dias para vencer |
| Acessos a Documentos | Log de acessos | Período, Usuário |
| Armazenamento | Uso de espaço | Período |

---

## 8. INTEGRAÇÕES

### 8.1 Storage
- Local filesystem
- Amazon S3
- Azure Blob Storage
- MinIO (self-hosted)

### 8.2 OCR
- Tesseract OCR
- Google Vision API
- Azure Computer Vision

### 8.3 Assinatura Digital
- ICP-Brasil
- Adobe Sign
- DocuSign

---

## 9. CONSIDERAÇÕES DE IMPLEMENTAÇÃO

### 9.1 Segurança
- Criptografia de arquivos sensíveis
- Controle de acesso por nível
- Logs de auditoria completos
- Scan de antivírus

### 9.2 Performance
- Upload com chunked transfer
- Compressão de imagens
- Cache de miniaturas
- Busca indexada (Elasticsearch)

### 9.3 Backup
- Replicação de storage
- Versionamento de arquivos
- Recuperação de desastres
