# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 27A
## Módulo de Processos Administrativos Disciplinares (PAD) - Modelo de Dados

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar processos administrativos disciplinares, sindicâncias e aplicação de penalidades, garantindo o devido processo legal e a conformidade com a legislação vigente.

### 1.2 Escopo
- Processos Administrativos Disciplinares (PAD)
- Sindicâncias
- Penalidades e sanções
- Comissões processantes
- Defesa e recursos
- Prescrição
- Acompanhamento processual

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### ProcessoAdministrativo
```java
@Entity
@Table(name = "processo_administrativo", indexes = {
    @Index(name = "idx_processo_numero", columnList = "numero_processo"),
    @Index(name = "idx_processo_servidor", columnList = "servidor_id"),
    @Index(name = "idx_processo_situacao", columnList = "situacao")
})
public class ProcessoAdministrativo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "numero_processo", nullable = false, length = 30, unique = true)
    private String numeroProcesso;
    
    @Column(name = "ano", nullable = false)
    private Integer ano;
    
    @Column(name = "sequencial", nullable = false)
    private Integer sequencial;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_processo", nullable = false)
    private TipoProcessoAdministrativo tipoProcesso;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoProcesso situacao;
    
    @Column(name = "data_abertura", nullable = false)
    private LocalDate dataAbertura;
    
    @Column(name = "data_conhecimento_fato")
    private LocalDate dataConhecimentoFato;
    
    @Column(name = "data_fato")
    private LocalDate dataFato;
    
    @Column(name = "data_prescricao")
    private LocalDate dataPrescricao;
    
    @Column(name = "data_encerramento")
    private LocalDate dataEncerramento;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "portaria_instauracao_id")
    private Documento portariaInstauracao;
    
    @Column(name = "numero_portaria", length = 50)
    private String numeroPortaria;
    
    @Column(name = "data_portaria")
    private LocalDate dataPortaria;
    
    @Column(name = "ementa", columnDefinition = "TEXT")
    private String ementa;
    
    @Column(name = "descricao_fatos", columnDefinition = "TEXT")
    private String descricaoFatos;
    
    @ElementCollection
    @CollectionTable(name = "processo_enquadramento")
    @Column(name = "dispositivo_legal")
    private Set<String> enquadramentoLegal;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comissao_id")
    private ComissaoProcessante comissao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado")
    private ResultadoProcesso resultado;
    
    @Column(name = "fundamentacao_decisao", columnDefinition = "TEXT")
    private String fundamentacaoDecisao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "penalidade_aplicada_id")
    private PenalidadeAplicada penalidadeAplicada;
    
    @Column(name = "prazo_conclusao_dias")
    private Integer prazoConclusaoDias = 60;
    
    @Column(name = "prorrogacoes")
    private Integer prorrogacoes = 0;
    
    @Column(name = "sigiloso")
    private Boolean sigiloso = false;
    
    @Column(name = "prioridade")
    private Boolean prioridade = false;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_origem_id")
    private ProcessoAdministrativo processoOrigem; // Ex: Sindicância que gerou PAD
    
    @OneToMany(mappedBy = "processo", cascade = CascadeType.ALL)
    private List<FaseProcesso> fases;
    
    @OneToMany(mappedBy = "processo", cascade = CascadeType.ALL)
    private List<DocumentoProcesso> documentos;
    
    @OneToMany(mappedBy = "processo", cascade = CascadeType.ALL)
    private List<HistoricoProcesso> historico;
}
```

#### Sindicancia
```java
@Entity
@Table(name = "sindicancia")
public class Sindicancia {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "numero_sindicancia", nullable = false, length = 30, unique = true)
    private String numeroSindicancia;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_sindicancia", nullable = false)
    private TipoSindicancia tipoSindicancia;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_investigado_id")
    private Servidor servidorInvestigado;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoSindicancia situacao;
    
    @Column(name = "data_abertura", nullable = false)
    private LocalDate dataAbertura;
    
    @Column(name = "data_fato")
    private LocalDate dataFato;
    
    @Column(name = "data_conclusao")
    private LocalDate dataConclusao;
    
    @Column(name = "descricao_fatos", columnDefinition = "TEXT")
    private String descricaoFatos;
    
    @Column(name = "objeto_investigacao", columnDefinition = "TEXT")
    private String objetoInvestigacao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sindicante_id")
    private Servidor sindicante;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comissao_id")
    private ComissaoProcessante comissao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado")
    private ResultadoSindicancia resultado;
    
    @Column(name = "conclusao_parecer", columnDefinition = "TEXT")
    private String conclusaoParecer;
    
    @Column(name = "recomendacao", columnDefinition = "TEXT")
    private String recomendacao;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_gerado_id")
    private ProcessoAdministrativo processoGerado;
    
    @Column(name = "prazo_dias")
    private Integer prazoDias = 30;
}
```

#### ComissaoProcessante
```java
@Entity
@Table(name = "comissao_processante")
public class ComissaoProcessante {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "numero_portaria", nullable = false, length = 50)
    private String numeroPortaria;
    
    @Column(name = "data_portaria", nullable = false)
    private LocalDate dataPortaria;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoComissao tipoComissao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoComissao situacao;
    
    @OneToMany(mappedBy = "comissao", cascade = CascadeType.ALL)
    private List<MembroComissao> membros;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id")
    private ProcessoAdministrativo processo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sindicancia_id")
    private Sindicancia sindicancia;
    
    @Column(name = "observacoes", columnDefinition = "TEXT")
    private String observacoes;
}
```

#### MembroComissao
```java
@Entity
@Table(name = "membro_comissao")
public class MembroComissao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "comissao_id", nullable = false)
    private ComissaoProcessante comissao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FuncaoMembro funcao;
    
    @Column(name = "data_designacao", nullable = false)
    private LocalDate dataDesignacao;
    
    @Column(name = "data_substituicao")
    private LocalDate dataSubstituicao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "substituto_id")
    private Servidor substituto;
    
    @Column(name = "motivo_substituicao", length = 500)
    private String motivoSubstituicao;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### FaseProcesso
```java
@Entity
@Table(name = "fase_processo")
public class FaseProcesso {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id", nullable = false)
    private ProcessoAdministrativo processo;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoFaseProcesso fase;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "prazo_dias")
    private Integer prazoDias;
    
    @Column(name = "prazo_final")
    private LocalDate prazoFinal;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoFase situacao;
    
    @Column(name = "observacoes", columnDefinition = "TEXT")
    private String observacoes;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "responsavel_id")
    private Servidor responsavel;
}
```

#### Penalidade
```java
@Entity
@Table(name = "penalidade")
public class Penalidade {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoPenalidade tipo;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Column(name = "fundamentacao_legal", length = 500)
    private String fundamentacaoLegal;
    
    @Column(name = "prazo_prescricao_anos")
    private Integer prazoPrescricaoAnos;
    
    @Column(name = "duracao_minima_dias")
    private Integer duracaoMinimaDias;
    
    @Column(name = "duracao_maxima_dias")
    private Integer duracaoMaximaDias;
    
    @Column(name = "gera_anotacao_assentamento")
    private Boolean geraAnotacaoAssentamento = true;
    
    @Column(name = "impede_progressao")
    private Boolean impedeProgressao = false;
    
    @Column(name = "periodo_impedimento_meses")
    private Integer periodoImpedimentoMeses;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### PenalidadeAplicada
```java
@Entity
@Table(name = "penalidade_aplicada")
public class PenalidadeAplicada {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "penalidade_id", nullable = false)
    private Penalidade penalidade;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id")
    private ProcessoAdministrativo processo;
    
    @Column(name = "data_aplicacao", nullable = false)
    private LocalDate dataAplicacao;
    
    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;
    
    @Column(name = "data_inicio_efeitos")
    private LocalDate dataInicioEfeitos;
    
    @Column(name = "data_fim_efeitos")
    private LocalDate dataFimEfeitos;
    
    @Column(name = "duracao_dias")
    private Integer duracaoDias;
    
    @Column(name = "fundamentacao", columnDefinition = "TEXT")
    private String fundamentacao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoPenalidade situacao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "portaria_id")
    private Documento portaria;
    
    @Column(name = "numero_portaria", length = 50)
    private String numeroPortaria;
    
    @Column(name = "data_cancelamento")
    private LocalDate dataCancelamento;
    
    @Column(name = "motivo_cancelamento", columnDefinition = "TEXT")
    private String motivoCancelamento;
    
    @Column(name = "registrado_ficha_funcional")
    private Boolean registradoFichaFuncional = false;
}
```

#### DefesaProcesso
```java
@Entity
@Table(name = "defesa_processo")
public class DefesaProcesso {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id", nullable = false)
    private ProcessoAdministrativo processo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_defesa", nullable = false)
    private TipoDefesa tipoDefesa;
    
    @Column(name = "data_protocolo", nullable = false)
    private LocalDateTime dataProtocolo;
    
    @Column(name = "numero_protocolo", length = 50)
    private String numeroProtocolo;
    
    @Column(name = "conteudo", columnDefinition = "TEXT")
    private String conteudo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "advogado_id")
    private Advogado advogado;
    
    @Column(name = "prazo_concedido")
    private LocalDate prazoConcedido;
    
    @Column(name = "tempestiva")
    private Boolean tempestiva = true;
    
    @OneToMany(mappedBy = "defesa", cascade = CascadeType.ALL)
    private List<DocumentoDefesa> documentos;
    
    @Column(name = "analisada")
    private Boolean analisada = false;
    
    @Column(name = "parecer_analise", columnDefinition = "TEXT")
    private String parecerAnalise;
}
```

#### RecursoAdministrativo
```java
@Entity
@Table(name = "recurso_administrativo")
public class RecursoAdministrativo {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id", nullable = false)
    private ProcessoAdministrativo processo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "penalidade_aplicada_id")
    private PenalidadeAplicada penalidadeAplicada;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_recurso", nullable = false)
    private TipoRecurso tipoRecurso;
    
    @Column(name = "data_protocolo", nullable = false)
    private LocalDateTime dataProtocolo;
    
    @Column(name = "numero_protocolo", length = 50)
    private String numeroProtocolo;
    
    @Column(name = "fundamentacao", columnDefinition = "TEXT")
    private String fundamentacao;
    
    @Column(name = "pedido", columnDefinition = "TEXT")
    private String pedido;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoRecurso situacao;
    
    @Column(name = "data_julgamento")
    private LocalDate dataJulgamento;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado")
    private ResultadoRecurso resultado;
    
    @Column(name = "fundamentacao_decisao", columnDefinition = "TEXT")
    private String fundamentacaoDecisao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "julgado_por")
    private Usuario julgadoPor;
    
    @Column(name = "instancia")
    private Integer instancia = 1;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum TipoProcessoAdministrativo {
    PAD("Processo Administrativo Disciplinar"),
    PAD_SUMARIO("PAD Sumário"),
    PAD_RITO_ORDINARIO("PAD Rito Ordinário");
}

public enum TipoSindicancia {
    INVESTIGATIVA("Sindicância Investigativa"),
    ACUSATORIA("Sindicância Acusatória"),
    PATRIMONIAL("Sindicância Patrimonial");
}

public enum SituacaoProcesso {
    INSTAURADO("Instaurado"),
    EM_INSTRUCAO("Em Instrução"),
    CITACAO("Citação"),
    DEFESA("Defesa"),
    RELATORIO("Relatório"),
    JULGAMENTO("Julgamento"),
    RECURSO("Recurso"),
    ARQUIVADO("Arquivado"),
    CONCLUIDO("Concluído"),
    PRESCRITO("Prescrito"),
    SUSPENSO("Suspenso");
}

public enum SituacaoSindicancia {
    ABERTA("Aberta"),
    EM_ANDAMENTO("Em Andamento"),
    CONCLUIDA("Concluída"),
    ARQUIVADA("Arquivada");
}

public enum ResultadoProcesso {
    ABSOLVICAO("Absolvição"),
    APLICACAO_PENALIDADE("Aplicação de Penalidade"),
    ARQUIVAMENTO("Arquivamento"),
    PRESCRICAO("Prescrição"),
    ANULACAO("Anulação");
}

public enum ResultadoSindicancia {
    ARQUIVAMENTO("Arquivamento"),
    INSTAURACAO_PAD("Instauração de PAD"),
    APLICACAO_ADVERTENCIA("Aplicação de Advertência"),
    OUTROS("Outros Encaminhamentos");
}

public enum TipoComissao {
    PERMANENTE("Comissão Permanente"),
    ESPECIAL("Comissão Especial"),
    SINDICANTE("Sindicante Individual");
}

public enum SituacaoComissao {
    ATIVA("Ativa"),
    CONCLUIDA("Concluída"),
    DISSOLVIDA("Dissolvida");
}

public enum FuncaoMembro {
    PRESIDENTE("Presidente"),
    MEMBRO("Membro"),
    SECRETARIO("Secretário"),
    SINDICANTE("Sindicante");
}

public enum TipoFaseProcesso {
    INSTAURACAO("Instauração"),
    CITACAO("Citação"),
    INSTRUCAO("Instrução"),
    INDICIAMENTO("Indiciamento"),
    DEFESA_ESCRITA("Defesa Escrita"),
    RELATORIO("Relatório"),
    JULGAMENTO("Julgamento"),
    RECURSO("Recurso"),
    CUMPRIMENTO("Cumprimento de Decisão");
}

public enum SituacaoFase {
    PENDENTE("Pendente"),
    EM_ANDAMENTO("Em Andamento"),
    CONCLUIDA("Concluída"),
    CANCELADA("Cancelada");
}

public enum TipoPenalidade {
    ADVERTENCIA("Advertência"),
    SUSPENSAO("Suspensão"),
    DEMISSAO("Demissão"),
    CASSACAO_APOSENTADORIA("Cassação de Aposentadoria"),
    DESTITUICAO_CARGO("Destituição de Cargo em Comissão");
}

public enum SituacaoPenalidade {
    APLICADA("Aplicada"),
    CUMPRIDA("Cumprida"),
    CANCELADA("Cancelada"),
    SUSPENSA("Suspensa"),
    EM_RECURSO("Em Recurso");
}

public enum TipoDefesa {
    DEFESA_PREVIA("Defesa Prévia"),
    DEFESA_ESCRITA("Defesa Escrita"),
    ALEGACOES_FINAIS("Alegações Finais"),
    MEMORIAL("Memorial");
}

public enum TipoRecurso {
    PEDIDO_RECONSIDERACAO("Pedido de Reconsideração"),
    RECURSO_HIERARQUICO("Recurso Hierárquico"),
    REVISAO("Revisão");
}

public enum SituacaoRecurso {
    PROTOCOLADO("Protocolado"),
    EM_ANALISE("Em Análise"),
    JULGADO("Julgado");
}

public enum ResultadoRecurso {
    PROVIDO("Provido"),
    PARCIALMENTE_PROVIDO("Parcialmente Provido"),
    IMPROVIDO("Improvido"),
    NAO_CONHECIDO("Não Conhecido");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Processos Administrativos

| Código | Regra | Descrição |
|--------|-------|-----------|
| PAD-001 | Prazo | PAD ordinário: 60 dias + 60 prorrogação |
| PAD-002 | Prazo Sumário | PAD sumário: 30 dias + 15 prorrogação |
| PAD-003 | Comissão | Mínimo 3 membros estáveis, presidente mais antigo |
| PAD-004 | Impedimento | Membro não pode ter parentesco com acusado |
| PAD-005 | Citação | Acusado deve ser citado em até 3 dias |
| PAD-006 | Defesa | Prazo defesa: 10 dias (prorrogável) |

### 4.2 Prescrição

| Código | Regra | Descrição |
|--------|-------|-----------|
| PRESC-001 | Advertência | Prescreve em 180 dias |
| PRESC-002 | Suspensão | Prescreve em 2 anos |
| PRESC-003 | Demissão | Prescreve em 5 anos |
| PRESC-004 | Marco | Conta da data do conhecimento do fato |
| PRESC-005 | Interrupção | Instauração interrompe prescrição |

### 4.3 Penalidades

| Código | Regra | Descrição |
|--------|-------|-----------|
| PEN-001 | Advertência | Máximo 30 dias para cumprir |
| PEN-002 | Suspensão | Máximo 90 dias |
| PEN-003 | Demissão | Vedado novo cargo por 5 anos |
| PEN-004 | Registro | Toda penalidade registra em ficha funcional |
| PEN-005 | Efeitos | Suspensão: perda remuneração proporcional |

### 4.4 Recursos

| Código | Regra | Descrição |
|--------|-------|-----------|
| REC-001 | Prazo | 10 dias da ciência da decisão |
| REC-002 | Reconsideração | À mesma autoridade que decidiu |
| REC-003 | Hierárquico | À autoridade superior |
| REC-004 | Revisão | A qualquer tempo, fatos novos |
| REC-005 | Efeito | Recurso não tem efeito suspensivo |
