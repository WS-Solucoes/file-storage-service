# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 13
## Módulo de Concursos Públicos

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar todo o ciclo de concursos públicos municipais, desde a publicação do edital até a posse dos candidatos aprovados.

### 1.2 Funcionalidades Principais

| Funcionalidade | Descrição |
|----------------|-----------|
| **Gestão de Editais** | Cadastro, publicação, retificações |
| **Cargos/Vagas** | Definição de vagas por cargo e lotação |
| **Candidatos** | Inscrição, documentação, isenções |
| **Provas/Etapas** | Notas, classificação por etapa |
| **Classificação Final** | Resultado, recursos, homologação |
| **Nomeação** | Convocação, documentação, posse |
| **Validade** | Controle de prazo do concurso |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: Concurso

```java
@Entity
@Table(name = "concurso")
public class Concurso extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "numero", length = 20)
    private String numero; // Ex: "001/2026"
    
    @Column(name = "ano")
    private Integer ano;
    
    @Column(name = "descricao", length = 500)
    private String descricao;
    
    @Column(name = "edital_numero", length = 50)
    private String editalNumero;
    
    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;
    
    @Column(name = "data_inscricao_inicio")
    private LocalDate dataInscricaoInicio;
    
    @Column(name = "data_inscricao_fim")
    private LocalDate dataInscricaoFim;
    
    @Column(name = "data_prova")
    private LocalDate dataProva;
    
    @Column(name = "data_homologacao")
    private LocalDate dataHomologacao;
    
    @Column(name = "data_validade")
    private LocalDate dataValidade; // 2 anos + prorrogação
    
    @Column(name = "prorrogado")
    private Boolean prorrogado = false;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoConcurso situacao;
    
    @Column(name = "banca_organizadora", length = 200)
    private String bancaOrganizadora;
    
    @Column(name = "valor_inscricao")
    private BigDecimal valorInscricao;
    
    @OneToMany(mappedBy = "concurso", cascade = CascadeType.ALL)
    private List<ConcursoVaga> vagas = new ArrayList<>();
    
    @OneToMany(mappedBy = "concurso", cascade = CascadeType.ALL)
    private List<ConcursoEtapa> etapas = new ArrayList<>();
}
```

### 2.2 Entidade: ConcursoVaga

```java
@Entity
@Table(name = "concurso_vaga")
public class ConcursoVaga extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concurso_id", nullable = false)
    private Concurso concurso;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cargo_id", nullable = false)
    private Cargo cargo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "lotacao_id")
    private Lotacao lotacao; // Opcional: vaga específica para lotação
    
    @Column(name = "vagas_ampla")
    private Integer vagasAmpla; // Ampla concorrência
    
    @Column(name = "vagas_pcd")
    private Integer vagasPCD; // Pessoas com deficiência
    
    @Column(name = "vagas_negros")
    private Integer vagasNegros; // Cotas raciais
    
    @Column(name = "vagas_total")
    private Integer vagasTotal;
    
    @Column(name = "cadastro_reserva")
    private Boolean cadastroReserva = false;
    
    @Column(name = "requisitos", length = 1000)
    private String requisitos;
    
    @Column(name = "atribuicoes", length = 2000)
    private String atribuicoes;
    
    @Column(name = "remuneracao_inicial")
    private BigDecimal remuneracaoInicial;
    
    @Column(name = "carga_horaria")
    private Integer cargaHoraria;
}
```

### 2.3 Entidade: ConcursoCandidato

```java
@Entity
@Table(name = "concurso_candidato")
public class ConcursoCandidato extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concurso_id", nullable = false)
    private Concurso concurso;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vaga_id", nullable = false)
    private ConcursoVaga vaga;
    
    @Column(name = "inscricao", length = 20)
    private String inscricao; // Número de inscrição
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "rg", length = 20)
    private String rg;
    
    @Column(name = "data_nascimento")
    private LocalDate dataNascimento;
    
    @Column(name = "email", length = 200)
    private String email;
    
    @Column(name = "telefone", length = 20)
    private String telefone;
    
    @Embedded
    private Endereco endereco;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_cota", length = 20)
    private TipoCota tipoCota; // AMPLA, PCD, NEGRO
    
    @Column(name = "pcd")
    private Boolean pcd = false;
    
    @Column(name = "descricao_deficiencia", length = 500)
    private String descricaoDeficiencia;
    
    @Column(name = "isencao_solicitada")
    private Boolean isencaoSolicitada = false;
    
    @Column(name = "isencao_aprovada")
    private Boolean isencaoAprovada = false;
    
    @Column(name = "pagamento_confirmado")
    private Boolean pagamentoConfirmado = false;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoCandidato situacao;
    
    // Resultado Final
    @Column(name = "nota_final")
    private BigDecimal notaFinal;
    
    @Column(name = "classificacao_geral")
    private Integer classificacaoGeral;
    
    @Column(name = "classificacao_cota")
    private Integer classificacaoCota;
    
    @Column(name = "aprovado")
    private Boolean aprovado = false;
    
    @Column(name = "eliminado")
    private Boolean eliminado = false;
    
    @Column(name = "motivo_eliminacao", length = 500)
    private String motivoEliminacao;
    
    @OneToMany(mappedBy = "candidato", cascade = CascadeType.ALL)
    private List<ConcursoNota> notas = new ArrayList<>();
}
```

### 2.4 Entidade: ConcursoEtapa

```java
@Entity
@Table(name = "concurso_etapa")
public class ConcursoEtapa extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concurso_id", nullable = false)
    private Concurso concurso;
    
    @Column(name = "ordem")
    private Integer ordem;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoEtapaConcurso tipo;
    
    @Column(name = "nome", length = 100)
    private String nome;
    
    @Column(name = "peso")
    private BigDecimal peso; // Peso na nota final
    
    @Column(name = "nota_minima")
    private BigDecimal notaMinima; // Nota de corte
    
    @Column(name = "nota_maxima")
    private BigDecimal notaMaxima;
    
    @Column(name = "eliminatoria")
    private Boolean eliminatoria = false;
    
    @Column(name = "classificatoria")
    private Boolean classificatoria = true;
    
    @Column(name = "data_realizacao")
    private LocalDate dataRealizacao;
    
    @Column(name = "data_resultado")
    private LocalDate dataResultado;
}
```

### 2.5 Entidade: ConcursoNota

```java
@Entity
@Table(name = "concurso_nota")
public class ConcursoNota extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "candidato_id", nullable = false)
    private ConcursoCandidato candidato;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "etapa_id", nullable = false)
    private ConcursoEtapa etapa;
    
    @Column(name = "nota_bruta")
    private BigDecimal notaBruta;
    
    @Column(name = "nota_ponderada")
    private BigDecimal notaPonderada; // nota * peso
    
    @Column(name = "presente")
    private Boolean presente = true;
    
    @Column(name = "eliminado_etapa")
    private Boolean eliminadoEtapa = false;
    
    @Column(name = "observacao", length = 500)
    private String observacao;
}
```

### 2.6 Entidade: Nomeacao

```java
@Entity
@Table(name = "nomeacao")
public class Nomeacao extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "candidato_id", nullable = false)
    private ConcursoCandidato candidato;
    
    @Column(name = "numero_decreto", length = 50)
    private String numeroDecreto;
    
    @Column(name = "data_decreto")
    private LocalDate dataDecreto;
    
    @Column(name = "data_publicacao_doe")
    private LocalDate dataPublicacaoDOE;
    
    @Column(name = "prazo_posse")
    private LocalDate prazoPosse; // 30 dias após publicação
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoNomeacao situacao;
    
    @Column(name = "data_apresentacao")
    private LocalDate dataApresentacao;
    
    @Column(name = "data_posse")
    private LocalDate dataPosse;
    
    @Column(name = "data_exercicio")
    private LocalDate dataExercicio;
    
    @Column(name = "documentacao_completa")
    private Boolean documentacaoCompleta = false;
    
    @Column(name = "exame_admissional_ok")
    private Boolean exameAdmissionalOk = false;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id")
    private VinculoFuncional vinculo; // Vínculo criado após posse
    
    @Column(name = "motivo_desistencia", length = 500)
    private String motivoDesistencia;
    
    @OneToMany(mappedBy = "nomeacao", cascade = CascadeType.ALL)
    private List<NomeacaoDocumento> documentos = new ArrayList<>();
}
```

### 2.7 Enums

```java
public enum SituacaoConcurso {
    RASCUNHO,           // Em elaboração
    PUBLICADO,          // Edital publicado
    INSCRICOES_ABERTAS, // Período de inscrição
    INSCRICOES_ENCERRADAS,
    EM_ANDAMENTO,       // Provas em andamento
    RESULTADO_PARCIAL,
    HOMOLOGADO,         // Resultado final homologado
    EM_VALIDADE,        // Dentro do prazo
    PRORROGADO,         // Prazo prorrogado
    EXPIRADO,           // Validade expirada
    CANCELADO
}

public enum SituacaoCandidato {
    INSCRITO,
    AGUARDANDO_PAGAMENTO,
    INSCRICAO_CONFIRMADA,
    ELIMINADO,
    APROVADO_CLASSIFICADO,
    APROVADO_CADASTRO_RESERVA,
    NOMEADO,
    EMPOSSADO,
    DESISTENTE
}

public enum TipoEtapaConcurso {
    PROVA_OBJETIVA,
    PROVA_DISSERTATIVA,
    PROVA_PRATICA,
    PROVA_TITULOS,
    PROVA_FISICA,
    AVALIACAO_PSICOLOGICA,
    INVESTIGACAO_SOCIAL,
    CURSO_FORMACAO,
    ENTREVISTA
}

public enum TipoCota {
    AMPLA,      // Ampla concorrência
    PCD,        // Pessoa com deficiência
    NEGRO       // Cotas raciais
}

public enum SituacaoNomeacao {
    CONVOCADO,          // Aguardando apresentação
    EM_ANALISE,         // Documentação em análise
    APTO,               // Aprovado para posse
    EMPOSSADO,          // Tomou posse
    EM_EXERCICIO,       // Em exercício
    NAO_COMPARECEU,     // Não se apresentou
    DESISTENTE,         // Desistiu formalmente
    TORNADO_SEM_EFEITO  // Nomeação tornada sem efeito
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Vagas e Cotas

```
REGRA CV-001: Reserva PCD
├── Mínimo 5% das vagas para PCD (Lei 8.112/90)
├── Arredondar para cima se fração ≥ 0,5
├── Ex: 10 vagas = 1 PCD (5%)
└── Ex: 21 vagas = 2 PCD (9,5% → arredonda)

REGRA CV-002: Cotas Raciais
├── 20% das vagas para negros/pardos
├── Conforme legislação municipal
└── Autodeclaração + verificação

REGRA CV-003: Cadastro Reserva
├── Aprovados além do número de vagas
├── Podem ser convocados dentro da validade
└── Ordem de classificação mantida
```

### 3.2 Classificação

```
REGRA CL-001: Cálculo Nota Final
├── Nota Final = Σ(nota_etapa × peso_etapa)
├── Apenas etapas classificatórias
└── Arredondar 2 casas decimais

REGRA CL-002: Critérios de Desempate
├── 1º Maior idade (Lei 10.741/2003 - Estatuto Idoso)
├── 2º Maior nota prova objetiva
├── 3º Maior nota prova dissertativa
├── 4º Maior tempo experiência (se títulos)
└── 5º Sorteio público

REGRA CL-003: Eliminação
├── Nota < mínima em etapa eliminatória = eliminado
├── Ausência em prova = eliminado
├── Fraude comprovada = eliminado
└── Não apresentar documentação = eliminado
```

### 3.3 Nomeação e Posse

```
REGRA NP-001: Prazo Posse
├── 30 dias a partir da publicação
├── Pode ser prorrogado a pedido (mais 30 dias)
├── Não comparecimento = torna sem efeito
└── Convoca próximo classificado

REGRA NP-002: Documentos Obrigatórios
├── RG, CPF, Título Eleitor
├── Certidão de Quitação Eleitoral
├── Certificado Reservista (masculino)
├── Comprovante Escolaridade/Requisitos
├── Certidões Negativas (federal, estadual, municipal)
├── Exame Admissional (ASO)
├── Declaração de Bens
└── Declaração de Acumulação de Cargos

REGRA NP-003: Validade Concurso
├── 2 anos da homologação
├── Pode ser prorrogado uma vez por igual período
├── Após validade: não pode mais nomear
└── 30 dias antes: alerta automático
```

---

## 4. FLUXO DO PROCESSO

```
┌─────────────────────────────────────────────────────────────┐
│                 CICLO DO CONCURSO PÚBLICO                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐                                            │
│  │ 1. CRIAÇÃO  │                                            │
│  │   EDITAL    │                                            │
│  └──────┬──────┘                                            │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────────────────────────────┐                   │
│  │ 2. DEFINIÇÃO DE VAGAS               │                   │
│  │    - Cargos e quantidade            │                   │
│  │    - Requisitos                     │                   │
│  │    - Cotas (PCD, racial)            │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 3. PUBLICAÇÃO                       │                   │
│  │    - DOE/DOM                        │                   │
│  │    - Site oficial                   │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 4. INSCRIÇÕES                       │                   │
│  │    - Online/presencial              │                   │
│  │    - Isenções                       │                   │
│  │    - Pagamento taxa                 │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 5. PROVAS/ETAPAS                    │                   │
│  │    - Prova objetiva                 │                   │
│  │    - Prova dissertativa             │                   │
│  │    - Prova prática                  │                   │
│  │    - Prova de títulos               │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 6. CLASSIFICAÇÃO                    │                   │
│  │    - Cálculo notas                  │                   │
│  │    - Aplicar desempate              │                   │
│  │    - Separar por cota               │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 7. HOMOLOGAÇÃO                      │                   │
│  │    - Publicar resultado             │                   │
│  │    - Prazo recursos                 │                   │
│  │    - Resultado definitivo           │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 8. NOMEAÇÕES (durante validade)     │                   │
│  │    - Decreto de nomeação            │                   │
│  │    - Convocação                     │                   │
│  │    - Análise documentos             │                   │
│  │    - Exame admissional              │                   │
│  │    - Posse                          │                   │
│  │    - Exercício                      │                   │
│  └─────────────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. SERVIÇOS PRINCIPAIS

### 5.1 ConcursoService

```java
@Service
@Transactional
public class ConcursoService extends AbstractTenantService {
    
    /**
     * Calcular classificação de um concurso
     */
    public void calcularClassificacao(Long concursoId) {
        Concurso concurso = concursoRepository.findById(concursoId).orElseThrow();
        
        // Buscar candidatos não eliminados
        List<ConcursoCandidato> candidatos = candidatoRepository
            .findByConcursoAndEliminadoFalse(concursoId);
        
        // Calcular nota final de cada um
        for (ConcursoCandidato candidato : candidatos) {
            BigDecimal notaFinal = calcularNotaFinal(candidato);
            candidato.setNotaFinal(notaFinal);
            
            // Verificar se atingiu nota mínima
            if (notaFinal.compareTo(concurso.getNotaMinimaAprovacao()) >= 0) {
                candidato.setAprovado(true);
            }
        }
        
        // Ordenar por nota (desempate por idade)
        candidatos.sort((c1, c2) -> {
            int cmp = c2.getNotaFinal().compareTo(c1.getNotaFinal());
            if (cmp == 0) {
                // Maior idade primeiro (Estatuto Idoso)
                return c1.getDataNascimento().compareTo(c2.getDataNascimento());
            }
            return cmp;
        });
        
        // Atribuir classificação geral
        int posicao = 1;
        for (ConcursoCandidato candidato : candidatos) {
            if (candidato.getAprovado()) {
                candidato.setClassificacaoGeral(posicao++);
            }
        }
        
        // Calcular classificação por cota
        calcularClassificacaoPorCota(candidatos, TipoCota.PCD);
        calcularClassificacaoPorCota(candidatos, TipoCota.NEGRO);
        
        candidatoRepository.saveAll(candidatos);
    }
    
    /**
     * Calcular nota final do candidato
     */
    private BigDecimal calcularNotaFinal(ConcursoCandidato candidato) {
        return candidato.getNotas().stream()
            .filter(n -> n.getEtapa().getClassificatoria())
            .map(ConcursoNota::getNotaPonderada)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }
}
```

### 5.2 NomeacaoService

```java
@Service
@Transactional
public class NomeacaoService extends AbstractTenantService {
    
    /**
     * Criar nomeação para candidato
     */
    public Nomeacao nomear(NomeacaoRequest request) {
        ConcursoCandidato candidato = candidatoRepository
            .findById(request.getCandidatoId())
            .orElseThrow();
        
        // Validar situação
        if (candidato.getSituacao() != SituacaoCandidato.APROVADO_CLASSIFICADO) {
            throw new BusinessException("Candidato não está apto para nomeação");
        }
        
        // Verificar validade do concurso
        Concurso concurso = candidato.getConcurso();
        if (LocalDate.now().isAfter(concurso.getDataValidade())) {
            throw new BusinessException("Concurso fora da validade");
        }
        
        // Verificar vagas disponíveis
        verificarVagasDisponiveis(candidato.getVaga());
        
        Nomeacao nomeacao = new Nomeacao();
        nomeacao.setCandidato(candidato);
        nomeacao.setNumeroDecreto(request.getNumeroDecreto());
        nomeacao.setDataDecreto(request.getDataDecreto());
        nomeacao.setDataPublicacaoDOE(request.getDataPublicacao());
        nomeacao.setPrazoPosse(request.getDataPublicacao().plusDays(30));
        nomeacao.setSituacao(SituacaoNomeacao.CONVOCADO);
        
        // Atualizar situação do candidato
        candidato.setSituacao(SituacaoCandidato.NOMEADO);
        
        return nomeacaoRepository.save(nomeacao);
    }
    
    /**
     * Registrar posse do nomeado
     */
    public VinculoFuncional registrarPosse(Long nomeacaoId, PosseRequest request) {
        Nomeacao nomeacao = nomeacaoRepository.findById(nomeacaoId).orElseThrow();
        
        // Validar documentação
        if (!nomeacao.getDocumentacaoCompleta()) {
            throw new BusinessException("Documentação incompleta");
        }
        if (!nomeacao.getExameAdmissionalOk()) {
            throw new BusinessException("Exame admissional não realizado/aprovado");
        }
        
        // Criar servidor (se não existir)
        Servidor servidor = criarOuBuscarServidor(nomeacao.getCandidato());
        
        // Criar vínculo funcional
        VinculoFuncional vinculo = vinculoService.criarVinculoEfetivo(
            servidor,
            nomeacao.getCandidato().getVaga().getCargo(),
            request.getLotacao(),
            request.getDataPosse()
        );
        
        // Atualizar nomeação
        nomeacao.setDataPosse(request.getDataPosse());
        nomeacao.setDataExercicio(request.getDataExercicio());
        nomeacao.setSituacao(SituacaoNomeacao.EM_EXERCICIO);
        nomeacao.setVinculo(vinculo);
        
        // Atualizar candidato
        nomeacao.getCandidato().setSituacao(SituacaoCandidato.EMPOSSADO);
        
        return vinculo;
    }
}
```

---

## 6. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| **Concurso** |||
| GET | `/api/concursos` | Listar concursos | ANALISTA+ |
| POST | `/api/concursos` | Criar concurso | ADMIN |
| GET | `/api/concursos/{id}` | Detalhe concurso | ANALISTA+ |
| PUT | `/api/concursos/{id}` | Atualizar | ADMIN |
| POST | `/api/concursos/{id}/publicar` | Publicar edital | ADMIN |
| POST | `/api/concursos/{id}/homologar` | Homologar resultado | ADMIN |
| POST | `/api/concursos/{id}/prorrogar` | Prorrogar validade | ADMIN |
| **Vagas** |||
| GET | `/api/concursos/{id}/vagas` | Listar vagas | ANALISTA+ |
| POST | `/api/concursos/{id}/vagas` | Adicionar vaga | ADMIN |
| **Candidatos** |||
| GET | `/api/concursos/{id}/candidatos` | Listar candidatos | ANALISTA+ |
| POST | `/api/concursos/{id}/candidatos` | Inscrever candidato | ANALISTA+ |
| GET | `/api/candidatos/{id}` | Detalhe candidato | ANALISTA+ |
| **Notas** |||
| POST | `/api/candidatos/{id}/notas` | Lançar nota | GESTOR+ |
| PUT | `/api/notas/{id}` | Ajustar nota | GESTOR+ |
| **Classificação** |||
| POST | `/api/concursos/{id}/calcular-classificacao` | Calcular | GESTOR+ |
| GET | `/api/concursos/{id}/classificacao` | Ver resultado | PUBLICO |
| **Nomeação** |||
| POST | `/api/nomeacoes` | Criar nomeação | ADMIN |
| PUT | `/api/nomeacoes/{id}/documentos` | Enviar docs | ANALISTA+ |
| POST | `/api/nomeacoes/{id}/posse` | Registrar posse | ADMIN |
| PUT | `/api/nomeacoes/{id}/desistencia` | Registrar desistência | ADMIN |

---

## 7. RELATÓRIOS

| Relatório | Descrição |
|-----------|-----------|
| **Edital** | Documento oficial do concurso |
| **Lista de Inscritos** | Candidatos por cargo |
| **Gabarito** | Gabarito das provas |
| **Resultado Parcial** | Por etapa |
| **Classificação Final** | Resultado homologado |
| **Convocados** | Lista de nomeados |
| **Validade** | Concursos a vencer |

---
