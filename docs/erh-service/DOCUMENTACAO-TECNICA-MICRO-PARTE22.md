# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 22
## Módulo de Recadastramento e Prova de Vida

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar o processo de recadastramento periódico de servidores ativos, aposentados e pensionistas, incluindo prova de vida, atualização cadastral e validação de dados.

### 1.2 Escopo
- Campanhas de recadastramento
- Prova de vida (presencial e digital)
- Atualização de dados cadastrais
- Validação biométrica
- Controle de dependentes
- Bloqueio por não recadastramento
- Integração com bases externas

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### CampanhaRecadastramento
```java
@Entity
@Table(name = "campanha_recadastramento")
public class CampanhaRecadastramento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(name = "ano_referencia", nullable = false)
    private Integer anoReferencia;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_campanha", nullable = false)
    private TipoCampanha tipoCampanha;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "publico_alvo", nullable = false)
    private PublicoAlvoRecadastramento publicoAlvo;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim", nullable = false)
    private LocalDate dataFim;
    
    @Column(name = "data_limite_regularizacao")
    private LocalDate dataLimiteRegularizacao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoCampanha situacao;
    
    @Column(name = "permite_online")
    private Boolean permiteOnline = true;
    
    @Column(name = "exige_biometria")
    private Boolean exigeBiometria = false;
    
    @Column(name = "exige_foto")
    private Boolean exigeFoto = true;
    
    @Column(name = "atualiza_dependentes")
    private Boolean atualizaDependentes = true;
    
    @Column(name = "dias_bloqueio_apos_prazo")
    private Integer diasBloqueioAposPrazo = 30;
    
    @Column(name = "total_convocados")
    private Integer totalConvocados = 0;
    
    @Column(name = "total_recadastrados")
    private Integer totalRecadastrados = 0;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Column(columnDefinition = "TEXT")
    private String documentosExigidos;
    
    @OneToMany(mappedBy = "campanha", cascade = CascadeType.ALL)
    private List<ConvocacaoRecadastramento> convocacoes = new ArrayList<>();
    
    @OneToMany(mappedBy = "campanha", cascade = CascadeType.ALL)
    private List<LocalRecadastramento> locais = new ArrayList<>();
}
```

#### ConvocacaoRecadastramento
```java
@Entity
@Table(name = "convocacao_recadastramento")
public class ConvocacaoRecadastramento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "campanha_id", nullable = false)
    private CampanhaRecadastramento campanha;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id")
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aposentado_id")
    private Aposentado aposentado;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pensionista_id")
    private Pensionista pensionista;
    
    @Column(name = "mes_aniversario")
    private Integer mesAniversario;
    
    @Column(name = "data_convocacao")
    private LocalDate dataConvocacao;
    
    @Column(name = "data_limite", nullable = false)
    private LocalDate dataLimite;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoConvocacao situacao;
    
    @Column(name = "data_recadastramento")
    private LocalDateTime dataRecadastramento;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "forma_recadastramento")
    private FormaRecadastramento formaRecadastramento;
    
    @ManyToOne
    @JoinColumn(name = "local_id")
    private LocalRecadastramento local;
    
    @Column(name = "notificacao_enviada")
    private Boolean notificacaoEnviada = false;
    
    @Column(name = "data_notificacao")
    private LocalDateTime dataNotificacao;
    
    @Column(name = "codigo_validacao", length = 20)
    private String codigoValidacao;
}
```

#### Recadastramento
```java
@Entity
@Table(name = "recadastramento")
public class Recadastramento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "convocacao_id", nullable = false)
    private ConvocacaoRecadastramento convocacao;
    
    @Column(name = "protocolo", nullable = false, length = 30)
    private String protocolo;
    
    @Column(name = "data_realizacao", nullable = false)
    private LocalDateTime dataRealizacao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "forma_realizacao", nullable = false)
    private FormaRecadastramento formaRealizacao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoRecadastramento situacao;
    
    // Dados Pessoais Atualizados
    @Column(length = 200)
    private String endereco;
    
    @Column(length = 100)
    private String bairro;
    
    @Column(length = 100)
    private String cidade;
    
    @Column(length = 2)
    private String uf;
    
    @Column(length = 10)
    private String cep;
    
    @Column(name = "telefone_fixo", length = 20)
    private String telefoneFixo;
    
    @Column(name = "telefone_celular", length = 20)
    private String telefoneCelular;
    
    @Column(length = 150)
    private String email;
    
    // Estado Civil
    @Enumerated(EnumType.STRING)
    @Column(name = "estado_civil")
    private EstadoCivil estadoCivil;
    
    // Dados Bancários
    @Column(name = "banco_codigo", length = 10)
    private String bancoCodigo;
    
    @Column(name = "agencia", length = 20)
    private String agencia;
    
    @Column(name = "conta", length = 30)
    private String conta;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_conta")
    private TipoConta tipoConta;
    
    // Prova de Vida
    @Column(name = "prova_vida_realizada")
    private Boolean provaVidaRealizada = false;
    
    @Column(name = "data_prova_vida")
    private LocalDateTime dataProvaVida;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_prova_vida")
    private TipoProvaVida tipoProvaVida;
    
    // Biometria
    @Column(name = "biometria_coletada")
    private Boolean biometriaColetada = false;
    
    @Column(name = "hash_biometria", length = 500)
    private String hashBiometria;
    
    // Foto
    @Column(name = "foto_atualizada")
    private Boolean fotoAtualizada = false;
    
    @Column(name = "foto_path", length = 500)
    private String fotoPath;
    
    // Validações
    @Column(name = "validado")
    private Boolean validado = false;
    
    @Column(name = "data_validacao")
    private LocalDateTime dataValidacao;
    
    @ManyToOne
    @JoinColumn(name = "validador_id")
    private Usuario validador;
    
    @Column(name = "observacao_validacao", columnDefinition = "TEXT")
    private String observacaoValidacao;
    
    // Atendimento presencial
    @ManyToOne
    @JoinColumn(name = "atendente_id")
    private Usuario atendente;
    
    @ManyToOne
    @JoinColumn(name = "local_atendimento_id")
    private LocalRecadastramento localAtendimento;
    
    @OneToMany(mappedBy = "recadastramento", cascade = CascadeType.ALL)
    private List<DocumentoRecadastramento> documentos = new ArrayList<>();
    
    @OneToMany(mappedBy = "recadastramento", cascade = CascadeType.ALL)
    private List<DependenteRecadastramento> dependentes = new ArrayList<>();
}
```

#### DependenteRecadastramento
```java
@Entity
@Table(name = "dependente_recadastramento")
public class DependenteRecadastramento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recadastramento_id", nullable = false)
    private Recadastramento recadastramento;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dependente_id")
    private Dependente dependente;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_atualizacao", nullable = false)
    private TipoAtualizacaoDependente tipoAtualizacao;
    
    // Dados para novo dependente ou atualização
    @Column(length = 200)
    private String nome;
    
    @Column(name = "data_nascimento")
    private LocalDate dataNascimento;
    
    @Column(length = 14)
    private String cpf;
    
    @Enumerated(EnumType.STRING)
    private TipoParentesco parentesco;
    
    @Column(name = "documento_comprovacao", length = 500)
    private String documentoComprovacao;
    
    @Column(name = "motivo_exclusao", columnDefinition = "TEXT")
    private String motivoExclusao;
}
```

#### DocumentoRecadastramento
```java
@Entity
@Table(name = "documento_recadastramento")
public class DocumentoRecadastramento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recadastramento_id", nullable = false)
    private Recadastramento recadastramento;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_documento", nullable = false)
    private TipoDocumentoRecadastramento tipoDocumento;
    
    @Column(name = "arquivo_path", nullable = false, length = 500)
    private String arquivoPath;
    
    @Column(name = "nome_arquivo", length = 200)
    private String nomeArquivo;
    
    @Column(name = "tamanho_bytes")
    private Long tamanhoBytes;
    
    @Column(name = "data_upload")
    private LocalDateTime dataUpload;
    
    @Column(name = "validado")
    private Boolean validado = false;
    
    @Column(name = "motivo_rejeicao", columnDefinition = "TEXT")
    private String motivoRejeicao;
}
```

#### LocalRecadastramento
```java
@Entity
@Table(name = "local_recadastramento")
public class LocalRecadastramento {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "campanha_id", nullable = false)
    private CampanhaRecadastramento campanha;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(nullable = false, length = 300)
    private String endereco;
    
    @Column(length = 100)
    private String bairro;
    
    @Column(name = "horario_funcionamento", length = 100)
    private String horarioFuncionamento;
    
    @Column(name = "possui_biometria")
    private Boolean possuiBiometria = false;
    
    @Column(name = "capacidade_diaria")
    private Integer capacidadeDiaria;
    
    @Column(name = "telefone", length = 20)
    private String telefone;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### ProvaVida
```java
@Entity
@Table(name = "prova_vida")
public class ProvaVida {
    
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
    
    @Column(name = "data_realizacao", nullable = false)
    private LocalDateTime dataRealizacao;
    
    @Column(name = "data_validade", nullable = false)
    private LocalDate dataValidade;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_prova", nullable = false)
    private TipoProvaVida tipoProva;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoProvaVida situacao;
    
    // Para prova presencial
    @ManyToOne
    @JoinColumn(name = "local_id")
    private LocalRecadastramento local;
    
    @ManyToOne
    @JoinColumn(name = "atendente_id")
    private Usuario atendente;
    
    // Para prova digital
    @Column(name = "dispositivo", length = 200)
    private String dispositivo;
    
    @Column(name = "ip_acesso", length = 50)
    private String ipAcesso;
    
    @Column(name = "latitude", precision = 10, scale = 7)
    private BigDecimal latitude;
    
    @Column(name = "longitude", precision = 10, scale = 7)
    private BigDecimal longitude;
    
    // Biometria facial
    @Column(name = "foto_prova_path", length = 500)
    private String fotoProvaPath;
    
    @Column(name = "score_facial", precision = 5, scale = 2)
    private BigDecimal scoreFacial;
    
    @Column(name = "liveness_check")
    private Boolean livenessCheck;
    
    // Assinatura digital
    @Column(name = "hash_assinatura", length = 500)
    private String hashAssinatura;
    
    @Column(columnDefinition = "TEXT")
    private String observacao;
}
```

#### BloqueioRecadastramento
```java
@Entity
@Table(name = "bloqueio_recadastramento")
public class BloqueioRecadastramento {
    
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
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "campanha_id")
    private CampanhaRecadastramento campanha;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_bloqueio", nullable = false)
    private TipoBloqueioRecadastramento tipoBloqueio;
    
    @Column(name = "data_bloqueio", nullable = false)
    private LocalDate dataBloqueio;
    
    @Column(name = "data_desbloqueio")
    private LocalDate dataDesbloqueio;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoBloqueio situacao;
    
    @Column(name = "bloqueia_pagamento")
    private Boolean bloqueiaPagamento = true;
    
    @Column(columnDefinition = "TEXT")
    private String motivo;
    
    @Column(name = "motivo_desbloqueio", columnDefinition = "TEXT")
    private String motivoDesbloqueio;
    
    @ManyToOne
    @JoinColumn(name = "desbloqueado_por")
    private Usuario desbloqueadoPor;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum TipoCampanha {
    RECADASTRAMENTO_GERAL("Recadastramento Geral"),
    PROVA_VIDA_ANUAL("Prova de Vida Anual"),
    ATUALIZACAO_CADASTRAL("Atualização Cadastral"),
    RECADASTRAMENTO_ANIVERSARIO("Recadastramento por Aniversário");
}

public enum PublicoAlvoRecadastramento {
    SERVIDORES_ATIVOS("Servidores Ativos"),
    APOSENTADOS("Aposentados"),
    PENSIONISTAS("Pensionistas"),
    APOSENTADOS_PENSIONISTAS("Aposentados e Pensionistas"),
    TODOS("Todos");
}

public enum SituacaoCampanha {
    PLANEJADA("Planejada"),
    ATIVA("Ativa"),
    ENCERRADA("Encerrada"),
    CANCELADA("Cancelada");
}

public enum SituacaoConvocacao {
    CONVOCADO("Convocado"),
    NOTIFICADO("Notificado"),
    AGENDADO("Agendado"),
    RECADASTRADO("Recadastrado"),
    PENDENTE("Pendente"),
    BLOQUEADO("Bloqueado");
}

public enum FormaRecadastramento {
    PRESENCIAL("Presencial"),
    ONLINE("Online"),
    APLICATIVO("Aplicativo Mobile");
}

public enum SituacaoRecadastramento {
    EM_PREENCHIMENTO("Em Preenchimento"),
    AGUARDANDO_DOCUMENTOS("Aguardando Documentos"),
    EM_ANALISE("Em Análise"),
    APROVADO("Aprovado"),
    REJEITADO("Rejeitado"),
    COMPLEMENTAR("Complementação Necessária");
}

public enum TipoProvaVida {
    PRESENCIAL("Presencial"),
    BIOMETRIA_FACIAL("Biometria Facial"),
    BIOMETRIA_DIGITAL("Biometria Digital"),
    APLICATIVO("Aplicativo Gov.br"),
    CERTIFICADO_DIGITAL("Certificado Digital");
}

public enum SituacaoProvaVida {
    REALIZADA("Realizada"),
    VALIDADA("Validada"),
    REJEITADA("Rejeitada"),
    EXPIRADA("Expirada");
}

public enum TipoAtualizacaoDependente {
    INCLUSAO("Inclusão"),
    ATUALIZACAO("Atualização"),
    EXCLUSAO("Exclusão"),
    CONFIRMACAO("Confirmação");
}

public enum TipoDocumentoRecadastramento {
    RG("RG"),
    CPF("CPF"),
    COMPROVANTE_RESIDENCIA("Comprovante de Residência"),
    CERTIDAO_CASAMENTO("Certidão de Casamento"),
    CERTIDAO_NASCIMENTO("Certidão de Nascimento"),
    DECLARACAO_ESCOLAR("Declaração Escolar"),
    LAUDO_MEDICO("Laudo Médico"),
    FOTO_3X4("Foto 3x4"),
    SELFIE("Selfie com Documento"),
    OUTROS("Outros");
}

public enum TipoBloqueioRecadastramento {
    NAO_RECADASTRAMENTO("Não Recadastramento"),
    PROVA_VIDA_PENDENTE("Prova de Vida Pendente"),
    DOCUMENTACAO_IRREGULAR("Documentação Irregular"),
    INCONSISTENCIA_CADASTRAL("Inconsistência Cadastral");
}

public enum SituacaoBloqueio {
    ATIVO("Ativo"),
    LIBERADO("Liberado");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Campanha de Recadastramento

| Código | Regra | Descrição |
|--------|-------|-----------|
| CAM-001 | Anual | Mínimo uma campanha por ano para aposentados/pensionistas |
| CAM-002 | Prazo | Prazo mínimo de 30 dias para recadastramento |
| CAM-003 | Antecedência | Convocação com 15 dias de antecedência |
| CAM-004 | Regularização | Período de regularização após prazo final |

### 4.2 Recadastramento

| Código | Regra | Descrição |
|--------|-------|-----------|
| REC-001 | Obrigatório | Todos os convocados devem recadastrar |
| REC-002 | Documentos | Documentos obrigatórios conforme campanha |
| REC-003 | Foto | Foto atualizada obrigatória |
| REC-004 | Dependentes | Atualizar situação de dependentes |
| REC-005 | Validação | Recadastramento sujeito a validação |

### 4.3 Prova de Vida

| Código | Regra | Descrição |
|--------|-------|-----------|
| PV-001 | Periodicidade | Anual para aposentados e pensionistas |
| PV-002 | Aniversário | Preferencialmente no mês de aniversário |
| PV-003 | Validade | Válida por 12 meses |
| PV-004 | Biometria | Biometria facial com liveness detection |
| PV-005 | Score Mínimo | Score mínimo de 85% para validação facial |

### 4.4 Bloqueio

| Código | Regra | Descrição |
|--------|-------|-----------|
| BLQ-001 | Automático | Bloqueio automático após prazo + carência |
| BLQ-002 | Pagamento | Bloqueio pode suspender pagamento |
| BLQ-003 | Notificação | Notificar antes de bloquear |
| BLQ-004 | Desbloqueio | Desbloqueio imediato após regularização |

---

## 5. SERVIÇOS

### 5.1 CampanhaRecadastramentoService
```java
@Service
@Transactional
public class CampanhaRecadastramentoService {
    
    public CampanhaRecadastramento criarCampanha(CampanhaDTO dto) {
        CampanhaRecadastramento campanha = new CampanhaRecadastramento();
        campanha.setNome(dto.getNome());
        campanha.setAnoReferencia(dto.getAnoReferencia());
        campanha.setTipoCampanha(dto.getTipoCampanha());
        campanha.setPublicoAlvo(dto.getPublicoAlvo());
        campanha.setDataInicio(dto.getDataInicio());
        campanha.setDataFim(dto.getDataFim());
        campanha.setDataLimiteRegularizacao(dto.getDataLimiteRegularizacao());
        campanha.setSituacao(SituacaoCampanha.PLANEJADA);
        campanha.setPermiteOnline(dto.getPermiteOnline());
        campanha.setExigeBiometria(dto.getExigeBiometria());
        campanha.setExigeFoto(dto.getExigeFoto());
        campanha.setDocumentosExigidos(dto.getDocumentosExigidos());
        
        return campanhaRepository.save(campanha);
    }
    
    public void iniciarCampanha(Long campanhaId) {
        CampanhaRecadastramento campanha = campanhaRepository.findById(campanhaId).orElseThrow();
        
        if (campanha.getSituacao() != SituacaoCampanha.PLANEJADA) {
            throw new BusinessException("Campanha não está em status planejado");
        }
        
        // Gera convocações conforme público-alvo
        List<ConvocacaoRecadastramento> convocacoes = gerarConvocacoes(campanha);
        
        campanha.setSituacao(SituacaoCampanha.ATIVA);
        campanha.setTotalConvocados(convocacoes.size());
        campanhaRepository.save(campanha);
        
        // Envia notificações
        notificarConvocados(convocacoes);
    }
    
    private List<ConvocacaoRecadastramento> gerarConvocacoes(CampanhaRecadastramento campanha) {
        List<ConvocacaoRecadastramento> convocacoes = new ArrayList<>();
        
        switch (campanha.getPublicoAlvo()) {
            case SERVIDORES_ATIVOS:
                convocacoes.addAll(convocarServidoresAtivos(campanha));
                break;
            case APOSENTADOS:
                convocacoes.addAll(convocarAposentados(campanha));
                break;
            case PENSIONISTAS:
                convocacoes.addAll(convocarPensionistas(campanha));
                break;
            case APOSENTADOS_PENSIONISTAS:
                convocacoes.addAll(convocarAposentados(campanha));
                convocacoes.addAll(convocarPensionistas(campanha));
                break;
            case TODOS:
                convocacoes.addAll(convocarServidoresAtivos(campanha));
                convocacoes.addAll(convocarAposentados(campanha));
                convocacoes.addAll(convocarPensionistas(campanha));
                break;
        }
        
        return convocacoes;
    }
    
    private List<ConvocacaoRecadastramento> convocarAposentados(CampanhaRecadastramento campanha) {
        List<Aposentado> aposentados = aposentadoRepository.findAtivos();
        List<ConvocacaoRecadastramento> convocacoes = new ArrayList<>();
        
        for (Aposentado aposentado : aposentados) {
            ConvocacaoRecadastramento convocacao = new ConvocacaoRecadastramento();
            convocacao.setCampanha(campanha);
            convocacao.setAposentado(aposentado);
            convocacao.setMesAniversario(aposentado.getDataNascimento().getMonthValue());
            convocacao.setDataConvocacao(LocalDate.now());
            
            // Define data limite conforme mês de aniversário
            convocacao.setDataLimite(calcularDataLimite(campanha, aposentado.getDataNascimento().getMonthValue()));
            convocacao.setSituacao(SituacaoConvocacao.CONVOCADO);
            convocacao.setCodigoValidacao(gerarCodigoValidacao());
            
            convocacoes.add(convocacaoRepository.save(convocacao));
        }
        
        return convocacoes;
    }
}
```

### 5.2 RecadastramentoService
```java
@Service
@Transactional
public class RecadastramentoService {
    
    public Recadastramento iniciarRecadastramento(Long convocacaoId) {
        ConvocacaoRecadastramento convocacao = convocacaoRepository.findById(convocacaoId).orElseThrow();
        
        // Verifica se já existe recadastramento em andamento
        if (recadastramentoRepository.existsEmAndamentoPorConvocacao(convocacaoId)) {
            return recadastramentoRepository.findByConvocacaoId(convocacaoId).get();
        }
        
        Recadastramento recadastramento = new Recadastramento();
        recadastramento.setConvocacao(convocacao);
        recadastramento.setProtocolo(gerarProtocolo());
        recadastramento.setDataRealizacao(LocalDateTime.now());
        recadastramento.setSituacao(SituacaoRecadastramento.EM_PREENCHIMENTO);
        
        return recadastramentoRepository.save(recadastramento);
    }
    
    public Recadastramento atualizarDados(Long recadastramentoId, DadosRecadastramentoDTO dto) {
        Recadastramento recadastramento = recadastramentoRepository.findById(recadastramentoId).orElseThrow();
        
        // Atualiza dados pessoais
        recadastramento.setEndereco(dto.getEndereco());
        recadastramento.setBairro(dto.getBairro());
        recadastramento.setCidade(dto.getCidade());
        recadastramento.setUf(dto.getUf());
        recadastramento.setCep(dto.getCep());
        recadastramento.setTelefoneFixo(dto.getTelefoneFixo());
        recadastramento.setTelefoneCelular(dto.getTelefoneCelular());
        recadastramento.setEmail(dto.getEmail());
        recadastramento.setEstadoCivil(dto.getEstadoCivil());
        
        // Atualiza dados bancários
        recadastramento.setBancoCodigo(dto.getBancoCodigo());
        recadastramento.setAgencia(dto.getAgencia());
        recadastramento.setConta(dto.getConta());
        recadastramento.setTipoConta(dto.getTipoConta());
        
        return recadastramentoRepository.save(recadastramento);
    }
    
    public void finalizarRecadastramento(Long recadastramentoId, FormaRecadastramento forma) {
        Recadastramento recadastramento = recadastramentoRepository.findById(recadastramentoId).orElseThrow();
        CampanhaRecadastramento campanha = recadastramento.getConvocacao().getCampanha();
        
        // Validações
        validarDocumentosObrigatorios(recadastramento, campanha);
        validarFoto(recadastramento, campanha);
        validarProvaVida(recadastramento, campanha);
        
        recadastramento.setFormaRealizacao(forma);
        recadastramento.setSituacao(SituacaoRecadastramento.EM_ANALISE);
        recadastramentoRepository.save(recadastramento);
        
        // Atualiza convocação
        ConvocacaoRecadastramento convocacao = recadastramento.getConvocacao();
        convocacao.setSituacao(SituacaoConvocacao.RECADASTRADO);
        convocacao.setDataRecadastramento(LocalDateTime.now());
        convocacao.setFormaRecadastramento(forma);
        convocacaoRepository.save(convocacao);
    }
    
    public void validarRecadastramento(Long recadastramentoId, boolean aprovado, String observacao) {
        Recadastramento recadastramento = recadastramentoRepository.findById(recadastramentoId).orElseThrow();
        
        recadastramento.setValidado(aprovado);
        recadastramento.setDataValidacao(LocalDateTime.now());
        recadastramento.setValidador(getUsuarioLogado());
        recadastramento.setObservacaoValidacao(observacao);
        
        if (aprovado) {
            recadastramento.setSituacao(SituacaoRecadastramento.APROVADO);
            
            // Atualiza cadastro do beneficiário
            atualizarCadastro(recadastramento);
            
            // Remove bloqueio se existir
            removerBloqueio(recadastramento);
            
            // Atualiza estatísticas da campanha
            atualizarEstatisticasCampanha(recadastramento.getConvocacao().getCampanha());
        } else {
            recadastramento.setSituacao(SituacaoRecadastramento.REJEITADO);
        }
        
        recadastramentoRepository.save(recadastramento);
    }
    
    private void atualizarCadastro(Recadastramento recadastramento) {
        ConvocacaoRecadastramento convocacao = recadastramento.getConvocacao();
        
        if (convocacao.getServidor() != null) {
            atualizarCadastroServidor(convocacao.getServidor(), recadastramento);
        } else if (convocacao.getAposentado() != null) {
            atualizarCadastroAposentado(convocacao.getAposentado(), recadastramento);
        } else if (convocacao.getPensionista() != null) {
            atualizarCadastroPensionista(convocacao.getPensionista(), recadastramento);
        }
        
        // Atualiza dependentes
        atualizarDependentes(recadastramento);
    }
}
```

### 5.3 ProvaVidaService
```java
@Service
@Transactional
public class ProvaVidaService {
    
    @Autowired
    private BiometriaFacialService biometriaService;
    
    public ProvaVida realizarProvaVidaPresencial(ProvaVidaPresencialDTO dto) {
        ProvaVida provaVida = new ProvaVida();
        
        if (dto.getServidorId() != null) {
            provaVida.setServidor(servidorRepository.findById(dto.getServidorId()).orElseThrow());
        } else if (dto.getAposentadoId() != null) {
            provaVida.setAposentado(aposentadoRepository.findById(dto.getAposentadoId()).orElseThrow());
        } else if (dto.getPensionistaId() != null) {
            provaVida.setPensionista(pensionistaRepository.findById(dto.getPensionistaId()).orElseThrow());
        }
        
        provaVida.setDataRealizacao(LocalDateTime.now());
        provaVida.setDataValidade(LocalDate.now().plusYears(1));
        provaVida.setTipoProva(TipoProvaVida.PRESENCIAL);
        provaVida.setSituacao(SituacaoProvaVida.VALIDADA);
        provaVida.setLocal(localRepository.findById(dto.getLocalId()).orElseThrow());
        provaVida.setAtendente(getUsuarioLogado());
        
        return provaVidaRepository.save(provaVida);
    }
    
    public ProvaVida realizarProvaVidaBiometrica(ProvaVidaBiometricaDTO dto) {
        // Valida biometria facial
        ResultadoBiometria resultado = biometriaService.validarFace(
            dto.getFotoCapturada(),
            dto.getFotoReferencia(),
            dto.getLivenessData()
        );
        
        if (!resultado.isValido()) {
            throw new BusinessException("Biometria facial não validada: " + resultado.getMensagem());
        }
        
        // PV-005: Score mínimo de 85%
        if (resultado.getScore().compareTo(new BigDecimal("85")) < 0) {
            throw new BusinessException("Score de reconhecimento facial abaixo do mínimo (85%)");
        }
        
        ProvaVida provaVida = new ProvaVida();
        
        if (dto.getAposentadoId() != null) {
            provaVida.setAposentado(aposentadoRepository.findById(dto.getAposentadoId()).orElseThrow());
        } else if (dto.getPensionistaId() != null) {
            provaVida.setPensionista(pensionistaRepository.findById(dto.getPensionistaId()).orElseThrow());
        }
        
        provaVida.setDataRealizacao(LocalDateTime.now());
        provaVida.setDataValidade(LocalDate.now().plusYears(1));
        provaVida.setTipoProva(TipoProvaVida.BIOMETRIA_FACIAL);
        provaVida.setSituacao(SituacaoProvaVida.VALIDADA);
        provaVida.setDispositivo(dto.getDispositivo());
        provaVida.setIpAcesso(dto.getIpAcesso());
        provaVida.setLatitude(dto.getLatitude());
        provaVida.setLongitude(dto.getLongitude());
        provaVida.setFotoProvaPath(salvarFoto(dto.getFotoCapturada()));
        provaVida.setScoreFacial(resultado.getScore());
        provaVida.setLivenessCheck(resultado.isLivenessOk());
        
        return provaVidaRepository.save(provaVida);
    }
    
    public boolean verificarProvaVidaValida(Long pessoaId, TipoPessoa tipoPessoa) {
        LocalDate dataLimite = LocalDate.now().minusYears(1);
        
        switch (tipoPessoa) {
            case SERVIDOR:
                return provaVidaRepository.existsValidaPorServidor(pessoaId, dataLimite);
            case APOSENTADO:
                return provaVidaRepository.existsValidaPorAposentado(pessoaId, dataLimite);
            case PENSIONISTA:
                return provaVidaRepository.existsValidaPorPensionista(pessoaId, dataLimite);
            default:
                return false;
        }
    }
}
```

### 5.4 BloqueioRecadastramentoService
```java
@Service
@Transactional
public class BloqueioRecadastramentoService {
    
    @Scheduled(cron = "0 0 6 * * *") // Executa diariamente às 6h
    public void processarBloqueiosAutomaticos() {
        // Busca campanhas ativas com prazo vencido
        List<CampanhaRecadastramento> campanhas = campanhaRepository
            .findAtivasComPrazoVencido(LocalDate.now());
        
        for (CampanhaRecadastramento campanha : campanhas) {
            LocalDate dataLimiteBloqueio = campanha.getDataLimiteRegularizacao() != null
                ? campanha.getDataLimiteRegularizacao()
                : campanha.getDataFim().plusDays(campanha.getDiasBloqueioAposPrazo());
            
            if (LocalDate.now().isAfter(dataLimiteBloqueio)) {
                processarBloqueiosCampanha(campanha);
            }
        }
    }
    
    private void processarBloqueiosCampanha(CampanhaRecadastramento campanha) {
        List<ConvocacaoRecadastramento> pendentes = convocacaoRepository
            .findPendentesPorCampanha(campanha.getId());
        
        for (ConvocacaoRecadastramento convocacao : pendentes) {
            // Verifica se já não está bloqueado
            if (!existeBloqueioAtivo(convocacao)) {
                // Envia última notificação antes de bloquear
                if (!convocacao.getNotificacaoEnviada()) {
                    notificarAntesBloquear(convocacao);
                    convocacao.setNotificacaoEnviada(true);
                    convocacao.setDataNotificacao(LocalDateTime.now());
                    convocacaoRepository.save(convocacao);
                } else {
                    // Bloqueia
                    bloquear(convocacao, TipoBloqueioRecadastramento.NAO_RECADASTRAMENTO);
                }
            }
        }
    }
    
    public BloqueioRecadastramento bloquear(ConvocacaoRecadastramento convocacao, 
                                            TipoBloqueioRecadastramento tipo) {
        BloqueioRecadastramento bloqueio = new BloqueioRecadastramento();
        bloqueio.setCampanha(convocacao.getCampanha());
        bloqueio.setTipoBloqueio(tipo);
        bloqueio.setDataBloqueio(LocalDate.now());
        bloqueio.setSituacao(SituacaoBloqueio.ATIVO);
        bloqueio.setBloqueiaPagamento(true);
        bloqueio.setMotivo("Não realizou recadastramento no prazo - Campanha: " + 
                          convocacao.getCampanha().getNome());
        
        if (convocacao.getServidor() != null) {
            bloqueio.setServidor(convocacao.getServidor());
        } else if (convocacao.getAposentado() != null) {
            bloqueio.setAposentado(convocacao.getAposentado());
        } else if (convocacao.getPensionista() != null) {
            bloqueio.setPensionista(convocacao.getPensionista());
        }
        
        bloqueio = bloqueioRepository.save(bloqueio);
        
        // Atualiza situação da convocação
        convocacao.setSituacao(SituacaoConvocacao.BLOQUEADO);
        convocacaoRepository.save(convocacao);
        
        // Notifica bloqueio
        notificarBloqueio(bloqueio);
        
        return bloqueio;
    }
    
    public void desbloquear(Long bloqueioId, String motivo) {
        BloqueioRecadastramento bloqueio = bloqueioRepository.findById(bloqueioId).orElseThrow();
        
        bloqueio.setSituacao(SituacaoBloqueio.LIBERADO);
        bloqueio.setDataDesbloqueio(LocalDate.now());
        bloqueio.setMotivoDesbloqueio(motivo);
        bloqueio.setDesbloqueadoPor(getUsuarioLogado());
        
        bloqueioRepository.save(bloqueio);
        
        // Notifica desbloqueio
        notificarDesbloqueio(bloqueio);
    }
}
```

---

## 6. API REST

### 6.1 Endpoints

```
# Campanhas
GET    /api/v1/recadastramento/campanhas                 # Lista campanhas
POST   /api/v1/recadastramento/campanhas                 # Cria campanha
GET    /api/v1/recadastramento/campanhas/{id}            # Busca campanha
PUT    /api/v1/recadastramento/campanhas/{id}            # Atualiza campanha
POST   /api/v1/recadastramento/campanhas/{id}/iniciar    # Inicia campanha
POST   /api/v1/recadastramento/campanhas/{id}/encerrar   # Encerra campanha
GET    /api/v1/recadastramento/campanhas/{id}/estatisticas # Estatísticas

# Convocações
GET    /api/v1/recadastramento/convocacoes               # Lista convocações
GET    /api/v1/recadastramento/convocacoes/{id}          # Busca convocação
GET    /api/v1/recadastramento/convocacoes/pendentes     # Convocações pendentes
POST   /api/v1/recadastramento/convocacoes/{id}/notificar # Renotifica

# Recadastramento
GET    /api/v1/recadastramento/{id}                      # Busca recadastramento
POST   /api/v1/recadastramento/iniciar/{convocacaoId}    # Inicia recadastramento
PUT    /api/v1/recadastramento/{id}/dados                # Atualiza dados
POST   /api/v1/recadastramento/{id}/documentos           # Upload documento
DELETE /api/v1/recadastramento/{id}/documentos/{docId}   # Remove documento
POST   /api/v1/recadastramento/{id}/dependentes          # Atualiza dependentes
POST   /api/v1/recadastramento/{id}/finalizar            # Finaliza
POST   /api/v1/recadastramento/{id}/validar              # Valida (RH)

# Prova de Vida
GET    /api/v1/prova-vida                                # Lista provas de vida
POST   /api/v1/prova-vida/presencial                     # Registra presencial
POST   /api/v1/prova-vida/biometrica                     # Registra biométrica
GET    /api/v1/prova-vida/{id}                           # Busca prova
GET    /api/v1/prova-vida/verificar/{tipo}/{pessoaId}    # Verifica validade

# Bloqueios
GET    /api/v1/recadastramento/bloqueios                 # Lista bloqueios
GET    /api/v1/recadastramento/bloqueios/{id}            # Busca bloqueio
POST   /api/v1/recadastramento/bloqueios/{id}/desbloquear # Desbloqueia

# Locais
GET    /api/v1/recadastramento/locais                    # Lista locais
POST   /api/v1/recadastramento/locais                    # Cadastra local
PUT    /api/v1/recadastramento/locais/{id}               # Atualiza local

# Portal do Servidor/Aposentado
GET    /api/v1/recadastramento/minha-situacao            # Situação do logado
GET    /api/v1/recadastramento/minhas-convocacoes        # Convocações do logado
POST   /api/v1/recadastramento/validar-codigo            # Valida código acesso
```

---

## 7. RELATÓRIOS

### 7.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| Situação Campanha | Recadastrados x Pendentes | Campanha |
| Pendentes de Recadastramento | Lista não recadastrados | Campanha, Secretaria |
| Bloqueados | Servidores/Aposentados bloqueados | Campanha, Tipo bloqueio |
| Provas de Vida | Realizadas no período | Período, Tipo prova |
| Vencimento Prova Vida | Provas a vencer | Dias para vencer |
| Recadastramentos Realizados | Por período e forma | Período, Forma |
| Atualizações Cadastrais | Alterações realizadas | Campanha |
| Dependentes Atualizados | Inclusões/Exclusões | Campanha |

---

## 8. INTEGRAÇÕES

### 8.1 Gov.br
- Integração com prova de vida via aplicativo Gov.br
- Validação de identidade digital

### 8.2 Bases Externas
- Consulta CPF na Receita Federal
- Validação de óbito (SISOBI/SIRC)
- Consulta endereço por CEP (Correios)

### 8.3 Folha de Pagamento
- Bloquear pagamento por não recadastramento
- Liberar pagamento após regularização

---

## 9. CONSIDERAÇÕES DE IMPLEMENTAÇÃO

### 9.1 Segurança
- Código de validação único por convocação
- Validação biométrica com liveness detection
- Logs de todas as operações

### 9.2 Acessibilidade
- Opção de atendimento presencial
- Suporte a procurador legal
- Adaptações para PCD

### 9.3 Notificações
- E-mail de convocação
- SMS de lembrete
- Push notification no app
- Carta registrada para bloqueio
