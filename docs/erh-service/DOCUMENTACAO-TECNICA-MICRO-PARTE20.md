# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 20
## Módulo de Capacitação e Treinamento

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar o desenvolvimento profissional dos servidores através de programas de capacitação, treinamentos, cursos, certificações e planos de desenvolvimento individual (PDI).

### 1.2 Escopo
- Cadastro de programas de capacitação
- Gestão de cursos e turmas
- Inscrições e participações
- Controle de certificados
- Licença capacitação
- PDI (Plano de Desenvolvimento Individual)
- Trilhas de aprendizagem
- Avaliação de efetividade

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### ProgramaCapacitacao
```java
@Entity
@Table(name = "programa_capacitacao")
public class ProgramaCapacitacao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Column(name = "ano_exercicio", nullable = false)
    private Integer anoExercicio;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoPrograma situacao;
    
    @Column(name = "data_inicio")
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "orcamento_previsto", precision = 15, scale = 2)
    private BigDecimal orcamentoPrevisto;
    
    @Column(name = "orcamento_executado", precision = 15, scale = 2)
    private BigDecimal orcamentoExecutado;
    
    @ManyToOne
    @JoinColumn(name = "secretaria_id")
    private Secretaria secretaria;
    
    @Column(name = "publico_alvo", columnDefinition = "TEXT")
    private String publicoAlvo;
    
    @OneToMany(mappedBy = "programa", cascade = CascadeType.ALL)
    private List<Curso> cursos = new ArrayList<>();
}
```

#### Curso
```java
@Entity
@Table(name = "curso")
public class Curso {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String ementa;
    
    @Column(columnDefinition = "TEXT")
    private String objetivos;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_curso", nullable = false)
    private TipoCurso tipoCurso;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ModalidadeCurso modalidade;
    
    @Column(name = "carga_horaria", nullable = false)
    private Integer cargaHoraria;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_curso")
    private NivelCurso nivelCurso;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "programa_id")
    private ProgramaCapacitacao programa;
    
    @ManyToOne
    @JoinColumn(name = "area_conhecimento_id")
    private AreaConhecimento areaConhecimento;
    
    @Column(name = "vagas_por_turma")
    private Integer vagasPorTurma;
    
    @Column(name = "frequencia_minima", precision = 5, scale = 2)
    private BigDecimal frequenciaMinima = new BigDecimal("75.00");
    
    @Column(name = "nota_minima", precision = 5, scale = 2)
    private BigDecimal notaMinima;
    
    @Column(name = "possui_avaliacao")
    private Boolean possuiAvaliacao = false;
    
    @Column(name = "certificado_automatico")
    private Boolean certificadoAutomatico = true;
    
    @Column(name = "custo_estimado", precision = 10, scale = 2)
    private BigDecimal custoEstimado;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @ManyToMany
    @JoinTable(name = "curso_competencia",
        joinColumns = @JoinColumn(name = "curso_id"),
        inverseJoinColumns = @JoinColumn(name = "competencia_id"))
    private Set<Competencia> competenciasDesenvolvidas = new HashSet<>();
    
    @OneToMany(mappedBy = "curso", cascade = CascadeType.ALL)
    private List<Turma> turmas = new ArrayList<>();
    
    @OneToMany(mappedBy = "curso", cascade = CascadeType.ALL)
    private List<PreRequisitoCurso> preRequisitos = new ArrayList<>();
}
```

#### Turma
```java
@Entity
@Table(name = "turma")
public class Turma {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "curso_id", nullable = false)
    private Curso curso;
    
    @Column(nullable = false, length = 50)
    private String codigo;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim", nullable = false)
    private LocalDate dataFim;
    
    @Column(name = "horario_inicio")
    private LocalTime horarioInicio;
    
    @Column(name = "horario_fim")
    private LocalTime horarioFim;
    
    @Column(name = "dias_semana", length = 50)
    private String diasSemana; // "SEG,QUA,SEX"
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoTurma situacao;
    
    @Column(name = "vagas_total", nullable = false)
    private Integer vagasTotal;
    
    @Column(name = "vagas_disponiveis")
    private Integer vagasDisponiveis;
    
    @Column(length = 200)
    private String local;
    
    @Column(name = "link_online", length = 500)
    private String linkOnline;
    
    @ManyToOne
    @JoinColumn(name = "instrutor_id")
    private Instrutor instrutor;
    
    @ManyToOne
    @JoinColumn(name = "instituicao_id")
    private InstituicaoEnsino instituicao;
    
    @Column(name = "custo_real", precision = 10, scale = 2)
    private BigDecimal custoReal;
    
    @OneToMany(mappedBy = "turma", cascade = CascadeType.ALL)
    private List<Inscricao> inscricoes = new ArrayList<>();
    
    @OneToMany(mappedBy = "turma", cascade = CascadeType.ALL)
    private List<AulaTurma> aulas = new ArrayList<>();
}
```

#### Inscricao
```java
@Entity
@Table(name = "inscricao")
public class Inscricao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turma_id", nullable = false)
    private Turma turma;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Column(name = "data_inscricao", nullable = false)
    private LocalDateTime dataInscricao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoInscricao situacao;
    
    @Column(name = "data_aprovacao")
    private LocalDateTime dataAprovacao;
    
    @ManyToOne
    @JoinColumn(name = "aprovador_id")
    private Usuario aprovador;
    
    @Column(name = "justificativa_inscricao", columnDefinition = "TEXT")
    private String justificativaInscricao;
    
    @Column(name = "motivo_reprovacao", columnDefinition = "TEXT")
    private String motivoReprovacao;
    
    @Column(name = "nota_final", precision = 5, scale = 2)
    private BigDecimal notaFinal;
    
    @Column(name = "frequencia_percentual", precision = 5, scale = 2)
    private BigDecimal frequenciaPercentual;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado_final")
    private ResultadoCurso resultadoFinal;
    
    @Column(name = "certificado_emitido")
    private Boolean certificadoEmitido = false;
    
    @Column(name = "data_emissao_certificado")
    private LocalDate dataEmissaoCertificado;
    
    @Column(name = "numero_certificado", length = 50)
    private String numeroCertificado;
    
    @OneToMany(mappedBy = "inscricao", cascade = CascadeType.ALL)
    private List<FrequenciaAula> frequencias = new ArrayList<>();
}
```

#### AulaTurma
```java
@Entity
@Table(name = "aula_turma")
public class AulaTurma {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "turma_id", nullable = false)
    private Turma turma;
    
    @Column(name = "data_aula", nullable = false)
    private LocalDate dataAula;
    
    @Column(name = "horario_inicio")
    private LocalTime horarioInicio;
    
    @Column(name = "horario_fim")
    private LocalTime horarioFim;
    
    @Column(name = "carga_horaria")
    private Integer cargaHoraria;
    
    @Column(length = 200)
    private String conteudo;
    
    @Column(name = "aula_realizada")
    private Boolean aulaRealizada = false;
    
    @Column(columnDefinition = "TEXT")
    private String observacao;
}
```

#### FrequenciaAula
```java
@Entity
@Table(name = "frequencia_aula")
public class FrequenciaAula {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inscricao_id", nullable = false)
    private Inscricao inscricao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aula_id", nullable = false)
    private AulaTurma aula;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoFrequencia situacao;
    
    @Column(columnDefinition = "TEXT")
    private String justificativa;
}
```

#### Certificado
```java
@Entity
@Table(name = "certificado")
public class Certificado {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Column(nullable = false, length = 50)
    private String numero;
    
    @Column(name = "nome_curso", nullable = false, length = 200)
    private String nomeCurso;
    
    @ManyToOne
    @JoinColumn(name = "inscricao_id")
    private Inscricao inscricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "origem_certificado", nullable = false)
    private OrigemCertificado origemCertificado;
    
    @Column(name = "instituicao", length = 200)
    private String instituicao;
    
    @Column(name = "carga_horaria", nullable = false)
    private Integer cargaHoraria;
    
    @Column(name = "data_conclusao", nullable = false)
    private LocalDate dataConclusao;
    
    @Column(name = "data_emissao")
    private LocalDate dataEmissao;
    
    @Column(name = "nota", precision = 5, scale = 2)
    private BigDecimal nota;
    
    @ManyToOne
    @JoinColumn(name = "area_conhecimento_id")
    private AreaConhecimento areaConhecimento;
    
    @Column(name = "codigo_validacao", length = 100)
    private String codigoValidacao;
    
    @Column(name = "arquivo_path", length = 500)
    private String arquivoPath;
    
    @Column(name = "validado")
    private Boolean validado = false;
    
    @Column(name = "data_validacao")
    private LocalDateTime dataValidacao;
    
    @ManyToOne
    @JoinColumn(name = "validador_id")
    private Usuario validador;
}
```

#### LicencaCapacitacao
```java
@Entity
@Table(name = "licenca_capacitacao")
public class LicencaCapacitacao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim", nullable = false)
    private LocalDate dataFim;
    
    @Column(name = "dias_solicitados", nullable = false)
    private Integer diasSolicitados;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoLicencaCapacitacao situacao;
    
    @Column(name = "nome_curso", nullable = false, length = 200)
    private String nomeCurso;
    
    @Column(name = "instituicao", length = 200)
    private String instituicao;
    
    @Column(name = "objetivo", columnDefinition = "TEXT")
    private String objetivo;
    
    @Column(name = "relevancia_funcao", columnDefinition = "TEXT")
    private String relevanciaFuncao;
    
    @Column(name = "numero_processo", length = 50)
    private String numeroProcesso;
    
    @Column(name = "data_solicitacao")
    private LocalDate dataSolicitacao;
    
    @Column(name = "data_aprovacao")
    private LocalDate dataAprovacao;
    
    @ManyToOne
    @JoinColumn(name = "aprovador_id")
    private Usuario aprovador;
    
    @Column(name = "parecer", columnDefinition = "TEXT")
    private String parecer;
    
    @Column(name = "comprovante_conclusao")
    private Boolean comprovanteConclusao = false;
    
    @Column(name = "data_comprovacao")
    private LocalDate dataComprovacao;
}
```

#### PDI (Plano de Desenvolvimento Individual)
```java
@Entity
@Table(name = "pdi")
public class PDI {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Column(name = "ano_exercicio", nullable = false)
    private Integer anoExercicio;
    
    @Column(name = "data_elaboracao")
    private LocalDate dataElaboracao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoPDI situacao;
    
    @Column(name = "objetivos_carreira", columnDefinition = "TEXT")
    private String objetivosCarreira;
    
    @Column(name = "pontos_fortes", columnDefinition = "TEXT")
    private String pontosFortes;
    
    @Column(name = "pontos_melhoria", columnDefinition = "TEXT")
    private String pontosMelhoria;
    
    @ManyToOne
    @JoinColumn(name = "chefia_id")
    private Servidor chefia;
    
    @Column(name = "data_aprovacao_chefia")
    private LocalDate dataAprovacaoChefia;
    
    @Column(name = "observacoes_chefia", columnDefinition = "TEXT")
    private String observacoesChefia;
    
    @OneToMany(mappedBy = "pdi", cascade = CascadeType.ALL)
    private List<AcaoPDI> acoes = new ArrayList<>();
}
```

#### AcaoPDI
```java
@Entity
@Table(name = "acao_pdi")
public class AcaoPDI {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pdi_id", nullable = false)
    private PDI pdi;
    
    @Column(nullable = false, length = 200)
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_acao", nullable = false)
    private TipoAcaoPDI tipoAcao;
    
    @ManyToOne
    @JoinColumn(name = "competencia_id")
    private Competencia competenciaAlvo;
    
    @Column(name = "prazo_inicio")
    private LocalDate prazoInicio;
    
    @Column(name = "prazo_fim")
    private LocalDate prazoFim;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoAcaoPDI situacao;
    
    @Column(name = "percentual_conclusao")
    private Integer percentualConclusao = 0;
    
    @Column(name = "resultado_obtido", columnDefinition = "TEXT")
    private String resultadoObtido;
    
    @ManyToOne
    @JoinColumn(name = "curso_id")
    private Curso cursoVinculado;
    
    @ManyToOne
    @JoinColumn(name = "inscricao_id")
    private Inscricao inscricaoVinculada;
}
```

#### Competencia
```java
@Entity
@Table(name = "competencia")
public class Competencia {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_competencia", nullable = false)
    private TipoCompetencia tipoCompetencia;
    
    @ManyToOne
    @JoinColumn(name = "area_conhecimento_id")
    private AreaConhecimento areaConhecimento;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### TrilhaAprendizagem
```java
@Entity
@Table(name = "trilha_aprendizagem")
public class TrilhaAprendizagem {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "nivel_trilha")
    private NivelTrilha nivelTrilha;
    
    @Column(name = "carga_horaria_total")
    private Integer cargaHorariaTotal;
    
    @ManyToOne
    @JoinColumn(name = "cargo_id")
    private Cargo cargoAlvo;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @OneToMany(mappedBy = "trilha", cascade = CascadeType.ALL)
    @OrderBy("ordem")
    private List<EtapaTrilha> etapas = new ArrayList<>();
}
```

#### EtapaTrilha
```java
@Entity
@Table(name = "etapa_trilha")
public class EtapaTrilha {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "trilha_id", nullable = false)
    private TrilhaAprendizagem trilha;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "curso_id", nullable = false)
    private Curso curso;
    
    @Column(nullable = false)
    private Integer ordem;
    
    @Column(name = "obrigatoria")
    private Boolean obrigatoria = true;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum SituacaoPrograma {
    PLANEJADO("Planejado"),
    EM_EXECUCAO("Em Execução"),
    CONCLUIDO("Concluído"),
    CANCELADO("Cancelado");
}

public enum TipoCurso {
    FORMACAO("Formação"),
    APERFEICOAMENTO("Aperfeiçoamento"),
    ATUALIZACAO("Atualização"),
    ESPECIALIZACAO("Especialização"),
    WORKSHOP("Workshop"),
    SEMINARIO("Seminário"),
    PALESTRA("Palestra"),
    CONGRESSO("Congresso");
}

public enum ModalidadeCurso {
    PRESENCIAL("Presencial"),
    EAD("EAD - Educação a Distância"),
    HIBRIDO("Híbrido"),
    AO_VIVO_ONLINE("Ao Vivo Online");
}

public enum NivelCurso {
    BASICO("Básico"),
    INTERMEDIARIO("Intermediário"),
    AVANCADO("Avançado"),
    ESPECIALIZACAO("Especialização");
}

public enum SituacaoTurma {
    PROGRAMADA("Programada"),
    INSCRICOES_ABERTAS("Inscrições Abertas"),
    INSCRICOES_ENCERRADAS("Inscrições Encerradas"),
    EM_ANDAMENTO("Em Andamento"),
    CONCLUIDA("Concluída"),
    CANCELADA("Cancelada");
}

public enum SituacaoInscricao {
    SOLICITADA("Solicitada"),
    APROVADA("Aprovada"),
    REJEITADA("Rejeitada"),
    CANCELADA("Cancelada"),
    EM_CURSO("Em Curso"),
    CONCLUIDA("Concluída"),
    DESISTENTE("Desistente"),
    REPROVADA("Reprovada");
}

public enum ResultadoCurso {
    APROVADO("Aprovado"),
    REPROVADO_FREQUENCIA("Reprovado por Frequência"),
    REPROVADO_NOTA("Reprovado por Nota"),
    DESISTENTE("Desistente"),
    PENDENTE("Pendente");
}

public enum SituacaoFrequencia {
    PRESENTE("Presente"),
    AUSENTE("Ausente"),
    JUSTIFICADO("Justificado");
}

public enum OrigemCertificado {
    INTERNO("Curso Interno"),
    EXTERNO("Curso Externo"),
    GRADUACAO("Graduação"),
    POS_GRADUACAO("Pós-Graduação"),
    MESTRADO("Mestrado"),
    DOUTORADO("Doutorado");
}

public enum SituacaoLicencaCapacitacao {
    SOLICITADA("Solicitada"),
    EM_ANALISE("Em Análise"),
    APROVADA("Aprovada"),
    INDEFERIDA("Indeferida"),
    EM_GOZO("Em Gozo"),
    CONCLUIDA("Concluída"),
    CANCELADA("Cancelada");
}

public enum SituacaoPDI {
    RASCUNHO("Rascunho"),
    AGUARDANDO_APROVACAO("Aguardando Aprovação"),
    APROVADO("Aprovado"),
    EM_EXECUCAO("Em Execução"),
    CONCLUIDO("Concluído");
}

public enum TipoAcaoPDI {
    CURSO_INTERNO("Curso Interno"),
    CURSO_EXTERNO("Curso Externo"),
    MENTORIA("Mentoria"),
    COACHING("Coaching"),
    LEITURA("Leitura"),
    PROJETO("Projeto Prático"),
    RODIZIO("Rodízio de Função"),
    OUTRO("Outro");
}

public enum SituacaoAcaoPDI {
    PLANEJADA("Planejada"),
    EM_ANDAMENTO("Em Andamento"),
    CONCLUIDA("Concluída"),
    CANCELADA("Cancelada");
}

public enum TipoCompetencia {
    TECNICA("Técnica"),
    COMPORTAMENTAL("Comportamental"),
    GERENCIAL("Gerencial");
}

public enum NivelTrilha {
    INICIANTE("Iniciante"),
    PROFISSIONAL("Profissional"),
    ESPECIALISTA("Especialista"),
    LIDERANCA("Liderança");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Inscrições

| Código | Regra | Descrição |
|--------|-------|-----------|
| INS-001 | Elegibilidade | Apenas servidores ativos podem se inscrever |
| INS-002 | Duplicidade | Não permite inscrição duplicada na mesma turma |
| INS-003 | Conflito Horário | Verifica conflito com outras turmas |
| INS-004 | Pré-requisitos | Valida conclusão de cursos pré-requisitos |
| INS-005 | Vagas | Não permite inscrição se não houver vagas |
| INS-006 | Aprovação Chefia | Cursos em horário de trabalho exigem aprovação |

### 4.2 Frequência e Aprovação

| Código | Regra | Descrição |
|--------|-------|-----------|
| FRQ-001 | Mínima | Frequência mínima de 75% para aprovação |
| FRQ-002 | Justificativa | Ausências podem ser justificadas |
| FRQ-003 | Nota Mínima | Quando há avaliação, nota mínima de 7,0 |
| FRQ-004 | Certificado | Certificado apenas para aprovados |

### 4.3 Licença Capacitação

| Código | Regra | Descrição |
|--------|-------|-----------|
| LIC-001 | Direito | Após 5 anos de efetivo exercício, direito a 3 meses |
| LIC-002 | Fracionamento | Pode ser fracionada em até 6 períodos |
| LIC-003 | Período Mínimo | Cada período mínimo de 15 dias |
| LIC-004 | Relevância | Curso deve ser relevante para as atribuições |
| LIC-005 | Comprovação | Deve comprovar conclusão ao retornar |
| LIC-006 | Permanência | Deve permanecer no cargo por período igual ao da licença |

### 4.4 PDI

| Código | Regra | Descrição |
|--------|-------|-----------|
| PDI-001 | Anual | Um PDI por servidor por ano |
| PDI-002 | Aprovação | PDI deve ser aprovado pela chefia |
| PDI-003 | Mínimo Ações | Mínimo de 2 ações de desenvolvimento |
| PDI-004 | Acompanhamento | Acompanhamento semestral obrigatório |

---

## 5. SERVIÇOS

### 5.1 CursoService
```java
@Service
@Transactional
public class CursoService {
    
    public Curso criarCurso(CursoDTO dto) {
        Curso curso = new Curso();
        curso.setNome(dto.getNome());
        curso.setEmenta(dto.getEmenta());
        curso.setTipoCurso(dto.getTipoCurso());
        curso.setModalidade(dto.getModalidade());
        curso.setCargaHoraria(dto.getCargaHoraria());
        curso.setNivelCurso(dto.getNivelCurso());
        curso.setFrequenciaMinima(dto.getFrequenciaMinima());
        curso.setPossuiAvaliacao(dto.getPossuiAvaliacao());
        curso.setNotaMinima(dto.getNotaMinima());
        
        if (dto.getProgramaId() != null) {
            curso.setPrograma(programaRepository.findById(dto.getProgramaId()).orElseThrow());
        }
        
        return cursoRepository.save(curso);
    }
    
    public Turma criarTurma(Long cursoId, TurmaDTO dto) {
        Curso curso = cursoRepository.findById(cursoId).orElseThrow();
        
        Turma turma = new Turma();
        turma.setCurso(curso);
        turma.setCodigo(gerarCodigoTurma(curso));
        turma.setDataInicio(dto.getDataInicio());
        turma.setDataFim(dto.getDataFim());
        turma.setVagasTotal(dto.getVagasTotal());
        turma.setVagasDisponiveis(dto.getVagasTotal());
        turma.setLocal(dto.getLocal());
        turma.setSituacao(SituacaoTurma.PROGRAMADA);
        
        // Gera aulas automaticamente
        turma = turmaRepository.save(turma);
        gerarAulasTurma(turma);
        
        return turma;
    }
    
    private void gerarAulasTurma(Turma turma) {
        LocalDate data = turma.getDataInicio();
        int cargaHorariaRestante = turma.getCurso().getCargaHoraria();
        int cargaHorariaDiaria = calcularCargaHorariaDiaria(turma);
        
        while (data.isBefore(turma.getDataFim()) || data.isEqual(turma.getDataFim())) {
            if (isDiaAula(data, turma.getDiasSemana()) && cargaHorariaRestante > 0) {
                AulaTurma aula = new AulaTurma();
                aula.setTurma(turma);
                aula.setDataAula(data);
                aula.setHorarioInicio(turma.getHorarioInicio());
                aula.setHorarioFim(turma.getHorarioFim());
                aula.setCargaHoraria(Math.min(cargaHorariaDiaria, cargaHorariaRestante));
                aulaRepository.save(aula);
                cargaHorariaRestante -= cargaHorariaDiaria;
            }
            data = data.plusDays(1);
        }
    }
}
```

### 5.2 InscricaoService
```java
@Service
@Transactional
public class InscricaoService {
    
    public Inscricao inscrever(InscricaoDTO dto) {
        Servidor servidor = servidorRepository.findById(dto.getServidorId()).orElseThrow();
        Turma turma = turmaRepository.findById(dto.getTurmaId()).orElseThrow();
        
        // Validações (INS-001 a INS-006)
        validarElegibilidade(servidor);
        validarDuplicidade(servidor.getId(), turma.getId());
        validarVagas(turma);
        validarPreRequisitos(servidor, turma.getCurso());
        validarConflitoHorario(servidor, turma);
        
        Inscricao inscricao = new Inscricao();
        inscricao.setTurma(turma);
        inscricao.setServidor(servidor);
        inscricao.setDataInscricao(LocalDateTime.now());
        inscricao.setSituacao(SituacaoInscricao.SOLICITADA);
        inscricao.setJustificativaInscricao(dto.getJustificativa());
        
        // Atualiza vagas
        turma.setVagasDisponiveis(turma.getVagasDisponiveis() - 1);
        turmaRepository.save(turma);
        
        return inscricaoRepository.save(inscricao);
    }
    
    public void aprovarInscricao(Long inscricaoId, Long aprovadorId) {
        Inscricao inscricao = inscricaoRepository.findById(inscricaoId).orElseThrow();
        inscricao.setSituacao(SituacaoInscricao.APROVADA);
        inscricao.setDataAprovacao(LocalDateTime.now());
        inscricao.setAprovador(usuarioRepository.findById(aprovadorId).orElseThrow());
        inscricaoRepository.save(inscricao);
        
        // Gera frequências para as aulas
        gerarFrequenciasAulas(inscricao);
    }
    
    public void rejeitarInscricao(Long inscricaoId, String motivo) {
        Inscricao inscricao = inscricaoRepository.findById(inscricaoId).orElseThrow();
        inscricao.setSituacao(SituacaoInscricao.REJEITADA);
        inscricao.setMotivoReprovacao(motivo);
        inscricaoRepository.save(inscricao);
        
        // Libera vaga
        Turma turma = inscricao.getTurma();
        turma.setVagasDisponiveis(turma.getVagasDisponiveis() + 1);
        turmaRepository.save(turma);
    }
    
    private void validarPreRequisitos(Servidor servidor, Curso curso) {
        for (PreRequisitoCurso preReq : curso.getPreRequisitos()) {
            boolean concluiu = certificadoRepository.existsByServidorAndCurso(
                servidor.getId(), preReq.getCursoRequisito().getId()
            );
            if (preReq.isObrigatorio() && !concluiu) {
                throw new BusinessException(
                    "Pré-requisito não atendido: " + preReq.getCursoRequisito().getNome()
                );
            }
        }
    }
}
```

### 5.3 FrequenciaService
```java
@Service
@Transactional
public class FrequenciaService {
    
    public void registrarFrequencia(Long aulaId, List<FrequenciaDTO> frequencias) {
        AulaTurma aula = aulaRepository.findById(aulaId).orElseThrow();
        aula.setAulaRealizada(true);
        aulaRepository.save(aula);
        
        for (FrequenciaDTO dto : frequencias) {
            FrequenciaAula freq = frequenciaRepository
                .findByInscricaoIdAndAulaId(dto.getInscricaoId(), aulaId)
                .orElseThrow();
            
            freq.setSituacao(dto.getSituacao());
            freq.setJustificativa(dto.getJustificativa());
            frequenciaRepository.save(freq);
        }
        
        // Atualiza percentual de frequência das inscrições
        atualizarFrequenciaInscricoes(aula.getTurma().getId());
    }
    
    public BigDecimal calcularPercentualFrequencia(Long inscricaoId) {
        List<FrequenciaAula> frequencias = frequenciaRepository.findByInscricaoId(inscricaoId);
        
        long totalAulas = frequencias.stream()
            .filter(f -> f.getAula().getAulaRealizada())
            .count();
        
        if (totalAulas == 0) return BigDecimal.ZERO;
        
        long presencas = frequencias.stream()
            .filter(f -> f.getAula().getAulaRealizada())
            .filter(f -> f.getSituacao() == SituacaoFrequencia.PRESENTE || 
                        f.getSituacao() == SituacaoFrequencia.JUSTIFICADO)
            .count();
        
        return new BigDecimal(presencas * 100)
            .divide(new BigDecimal(totalAulas), 2, RoundingMode.HALF_UP);
    }
}
```

### 5.4 CertificadoService
```java
@Service
@Transactional
public class CertificadoService {
    
    public Certificado emitirCertificado(Long inscricaoId) {
        Inscricao inscricao = inscricaoRepository.findById(inscricaoId).orElseThrow();
        
        // Valida se pode emitir
        validarAprovacao(inscricao);
        
        Certificado certificado = new Certificado();
        certificado.setServidor(inscricao.getServidor());
        certificado.setInscricao(inscricao);
        certificado.setNomeCurso(inscricao.getTurma().getCurso().getNome());
        certificado.setCargaHoraria(inscricao.getTurma().getCurso().getCargaHoraria());
        certificado.setDataConclusao(inscricao.getTurma().getDataFim());
        certificado.setDataEmissao(LocalDate.now());
        certificado.setNota(inscricao.getNotaFinal());
        certificado.setOrigemCertificado(OrigemCertificado.INTERNO);
        certificado.setNumero(gerarNumeroCertificado());
        certificado.setCodigoValidacao(gerarCodigoValidacao());
        certificado.setValidado(true);
        
        certificado = certificadoRepository.save(certificado);
        
        // Atualiza inscrição
        inscricao.setCertificadoEmitido(true);
        inscricao.setDataEmissaoCertificado(LocalDate.now());
        inscricao.setNumeroCertificado(certificado.getNumero());
        inscricaoRepository.save(inscricao);
        
        return certificado;
    }
    
    public Certificado cadastrarCertificadoExterno(CertificadoExternoDTO dto) {
        Certificado certificado = new Certificado();
        certificado.setServidor(servidorRepository.findById(dto.getServidorId()).orElseThrow());
        certificado.setNomeCurso(dto.getNomeCurso());
        certificado.setInstituicao(dto.getInstituicao());
        certificado.setCargaHoraria(dto.getCargaHoraria());
        certificado.setDataConclusao(dto.getDataConclusao());
        certificado.setNota(dto.getNota());
        certificado.setOrigemCertificado(dto.getOrigem());
        certificado.setNumero(gerarNumeroCertificado());
        certificado.setValidado(false); // Precisa validação do RH
        
        return certificadoRepository.save(certificado);
    }
    
    private void validarAprovacao(Inscricao inscricao) {
        if (inscricao.getResultadoFinal() != ResultadoCurso.APROVADO) {
            throw new BusinessException("Servidor não foi aprovado no curso");
        }
        if (inscricao.getCertificadoEmitido()) {
            throw new BusinessException("Certificado já foi emitido");
        }
    }
}
```

### 5.5 LicencaCapacitacaoService
```java
@Service
@Transactional
public class LicencaCapacitacaoService {
    
    private static final int ANOS_PARA_DIREITO = 5;
    private static final int MESES_TOTAL = 3;
    private static final int DIAS_MINIMO_PERIODO = 15;
    
    public LicencaCapacitacao solicitar(LicencaCapacitacaoDTO dto) {
        Servidor servidor = servidorRepository.findById(dto.getServidorId()).orElseThrow();
        
        // Validações (LIC-001 a LIC-006)
        validarDireitoLicenca(servidor);
        validarSaldoDisponivel(servidor, dto.getDiasSolicitados());
        validarPeriodoMinimo(dto.getDiasSolicitados());
        
        LicencaCapacitacao licenca = new LicencaCapacitacao();
        licenca.setServidor(servidor);
        licenca.setDataInicio(dto.getDataInicio());
        licenca.setDataFim(dto.getDataFim());
        licenca.setDiasSolicitados(dto.getDiasSolicitados());
        licenca.setNomeCurso(dto.getNomeCurso());
        licenca.setInstituicao(dto.getInstituicao());
        licenca.setObjetivo(dto.getObjetivo());
        licenca.setRelevanciaFuncao(dto.getRelevanciaFuncao());
        licenca.setSituacao(SituacaoLicencaCapacitacao.SOLICITADA);
        licenca.setDataSolicitacao(LocalDate.now());
        
        return licencaRepository.save(licenca);
    }
    
    public int calcularSaldoDias(Long servidorId) {
        // Total de dias de direito: 3 meses = 90 dias
        int diasTotal = MESES_TOTAL * 30;
        
        // Dias já utilizados
        int diasUtilizados = licencaRepository.sumDiasUtilizados(servidorId);
        
        return diasTotal - diasUtilizados;
    }
    
    private void validarDireitoLicenca(Servidor servidor) {
        // LIC-001: Após 5 anos de efetivo exercício
        long anosServico = ChronoUnit.YEARS.between(
            servidor.getDataAdmissao(), LocalDate.now()
        );
        
        if (anosServico < ANOS_PARA_DIREITO) {
            throw new BusinessException(
                "Servidor ainda não completou " + ANOS_PARA_DIREITO + " anos de efetivo exercício"
            );
        }
    }
    
    private void validarPeriodoMinimo(int dias) {
        // LIC-003: Período mínimo de 15 dias
        if (dias < DIAS_MINIMO_PERIODO) {
            throw new BusinessException(
                "Período mínimo de licença é de " + DIAS_MINIMO_PERIODO + " dias"
            );
        }
    }
}
```

### 5.6 PDIService
```java
@Service
@Transactional
public class PDIService {
    
    public PDI criarPDI(PDIDTO dto) {
        Servidor servidor = servidorRepository.findById(dto.getServidorId()).orElseThrow();
        
        // PDI-001: Um PDI por servidor por ano
        if (pdiRepository.existsByServidorAndAno(servidor.getId(), dto.getAnoExercicio())) {
            throw new BusinessException("Servidor já possui PDI para este ano");
        }
        
        PDI pdi = new PDI();
        pdi.setServidor(servidor);
        pdi.setAnoExercicio(dto.getAnoExercicio());
        pdi.setDataElaboracao(LocalDate.now());
        pdi.setSituacao(SituacaoPDI.RASCUNHO);
        pdi.setObjetivosCarreira(dto.getObjetivosCarreira());
        pdi.setPontosFortes(dto.getPontosFortes());
        pdi.setPontosMelhoria(dto.getPontosMelhoria());
        
        // PDI-003: Mínimo de 2 ações
        if (dto.getAcoes().size() < 2) {
            throw new BusinessException("PDI deve conter no mínimo 2 ações de desenvolvimento");
        }
        
        pdi = pdiRepository.save(pdi);
        
        for (AcaoPDIDTO acaoDto : dto.getAcoes()) {
            AcaoPDI acao = new AcaoPDI();
            acao.setPdi(pdi);
            acao.setDescricao(acaoDto.getDescricao());
            acao.setTipoAcao(acaoDto.getTipoAcao());
            acao.setPrazoInicio(acaoDto.getPrazoInicio());
            acao.setPrazoFim(acaoDto.getPrazoFim());
            acao.setSituacao(SituacaoAcaoPDI.PLANEJADA);
            acaoPDIRepository.save(acao);
        }
        
        return pdi;
    }
    
    public void submeterAprovacao(Long pdiId) {
        PDI pdi = pdiRepository.findById(pdiId).orElseThrow();
        pdi.setSituacao(SituacaoPDI.AGUARDANDO_APROVACAO);
        pdiRepository.save(pdi);
    }
    
    public void aprovarPDI(Long pdiId, Long chefiaId, String observacoes) {
        PDI pdi = pdiRepository.findById(pdiId).orElseThrow();
        pdi.setChefia(servidorRepository.findById(chefiaId).orElseThrow());
        pdi.setDataAprovacaoChefia(LocalDate.now());
        pdi.setObservacoesChefia(observacoes);
        pdi.setSituacao(SituacaoPDI.APROVADO);
        pdiRepository.save(pdi);
    }
}
```

---

## 6. API REST

### 6.1 Endpoints

```
# Programas de Capacitação
GET    /api/v1/capacitacao/programas                     # Lista programas
POST   /api/v1/capacitacao/programas                     # Cria programa
GET    /api/v1/capacitacao/programas/{id}                # Busca programa

# Cursos
GET    /api/v1/capacitacao/cursos                        # Lista cursos
POST   /api/v1/capacitacao/cursos                        # Cria curso
GET    /api/v1/capacitacao/cursos/{id}                   # Busca curso
PUT    /api/v1/capacitacao/cursos/{id}                   # Atualiza curso

# Turmas
GET    /api/v1/capacitacao/cursos/{cursoId}/turmas       # Lista turmas do curso
POST   /api/v1/capacitacao/cursos/{cursoId}/turmas       # Cria turma
GET    /api/v1/capacitacao/turmas/{id}                   # Busca turma
PUT    /api/v1/capacitacao/turmas/{id}                   # Atualiza turma
POST   /api/v1/capacitacao/turmas/{id}/abrir-inscricoes  # Abre inscrições
POST   /api/v1/capacitacao/turmas/{id}/iniciar           # Inicia turma
POST   /api/v1/capacitacao/turmas/{id}/encerrar          # Encerra turma

# Inscrições
GET    /api/v1/capacitacao/turmas/{turmaId}/inscricoes   # Lista inscrições da turma
POST   /api/v1/capacitacao/inscricoes                    # Realiza inscrição
GET    /api/v1/capacitacao/inscricoes/{id}               # Busca inscrição
POST   /api/v1/capacitacao/inscricoes/{id}/aprovar       # Aprova inscrição
POST   /api/v1/capacitacao/inscricoes/{id}/rejeitar      # Rejeita inscrição
POST   /api/v1/capacitacao/inscricoes/{id}/cancelar      # Cancela inscrição

# Frequência
GET    /api/v1/capacitacao/turmas/{turmaId}/aulas        # Lista aulas
POST   /api/v1/capacitacao/aulas/{aulaId}/frequencia     # Registra frequência
GET    /api/v1/capacitacao/inscricoes/{id}/frequencia    # Consulta frequência

# Avaliação e Resultado
POST   /api/v1/capacitacao/inscricoes/{id}/nota          # Registra nota
POST   /api/v1/capacitacao/inscricoes/{id}/finalizar     # Finaliza resultado

# Certificados
GET    /api/v1/capacitacao/certificados                  # Lista certificados
POST   /api/v1/capacitacao/inscricoes/{id}/certificado   # Emite certificado
POST   /api/v1/capacitacao/certificados/externo          # Cadastra certificado externo
GET    /api/v1/capacitacao/certificados/{id}             # Busca certificado
GET    /api/v1/capacitacao/certificados/validar/{codigo} # Valida certificado

# Licença Capacitação
GET    /api/v1/capacitacao/licencas                      # Lista licenças
POST   /api/v1/capacitacao/licencas                      # Solicita licença
GET    /api/v1/capacitacao/licencas/{id}                 # Busca licença
POST   /api/v1/capacitacao/licencas/{id}/aprovar         # Aprova licença
POST   /api/v1/capacitacao/licencas/{id}/indeferir       # Indefere licença
GET    /api/v1/servidores/{id}/licenca-capacitacao/saldo # Saldo de dias

# PDI
GET    /api/v1/capacitacao/pdi                           # Lista PDIs
POST   /api/v1/capacitacao/pdi                           # Cria PDI
GET    /api/v1/capacitacao/pdi/{id}                      # Busca PDI
PUT    /api/v1/capacitacao/pdi/{id}                      # Atualiza PDI
POST   /api/v1/capacitacao/pdi/{id}/submeter             # Submete para aprovação
POST   /api/v1/capacitacao/pdi/{id}/aprovar              # Aprova PDI
POST   /api/v1/capacitacao/pdi/{id}/acoes/{acaoId}/atualizar # Atualiza ação

# Trilhas
GET    /api/v1/capacitacao/trilhas                       # Lista trilhas
GET    /api/v1/capacitacao/trilhas/{id}                  # Busca trilha
GET    /api/v1/servidores/{id}/trilhas/progresso         # Progresso nas trilhas

# Por Servidor
GET    /api/v1/servidores/{id}/capacitacao/historico     # Histórico completo
GET    /api/v1/servidores/{id}/capacitacao/inscricoes    # Inscrições do servidor
GET    /api/v1/servidores/{id}/capacitacao/certificados  # Certificados do servidor
GET    /api/v1/servidores/{id}/capacitacao/pdi           # PDIs do servidor
```

---

## 7. RELATÓRIOS

### 7.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| Participações por Curso | Lista participantes e resultados | Curso, Turma, Período |
| Capacitações por Servidor | Histórico individual | Servidor, Período |
| Horas de Capacitação | Total de horas por servidor/secretaria | Período, Secretaria |
| Cursos Realizados | Cursos concluídos no período | Período, Programa |
| Taxa de Aprovação | Percentual aprovação por curso | Curso, Período |
| Certificados Emitidos | Listagem de certificados | Período, Tipo |
| Licenças Capacitação | Licenças concedidas | Período, Situação |
| Execução Orçamentária | Orçamento x Executado | Programa, Período |
| Competências Desenvolvidas | Competências por servidor | Servidor, Período |

---

## 8. INTEGRAÇÕES

### 8.1 Folha de Pagamento
- Registra afastamento para licença capacitação
- Mantém remuneração durante licença

### 8.2 Avaliação de Desempenho
- Vincula capacitações ao PDI
- Considera participações na avaliação

### 8.3 Progressão na Carreira
- Considera certificados para progressão
- Valida requisitos de capacitação

---

## 9. CONSIDERAÇÕES DE IMPLEMENTAÇÃO

### 9.1 Notificações
- Abertura de inscrições em cursos
- Aprovação/rejeição de inscrição
- Lembretes de início de turma
- Vencimento de licença capacitação

### 9.2 Processos Automáticos
- Calcular frequência após registro de presença
- Verificar aprovação ao encerrar turma
- Emitir certificado automaticamente (se configurado)
- Fechar PDI ao final do ano
