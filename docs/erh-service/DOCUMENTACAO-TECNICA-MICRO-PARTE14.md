# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 14
## Módulo de Avaliação de Desempenho

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar avaliações de desempenho dos servidores municipais, incluindo estágio probatório (obrigatório para efetivos) e avaliações periódicas para progressão na carreira.

### 1.2 Tipos de Avaliação

| Tipo | Periodicidade | Finalidade |
|------|---------------|------------|
| **Estágio Probatório** | Semestral (3 anos) | Confirmação no cargo |
| **Avaliação Periódica** | Anual | Progressão por mérito |
| **Avaliação Especial** | Sob demanda | Processos específicos |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: CicloAvaliacao

```java
@Entity
@Table(name = "ciclo_avaliacao")
public class CicloAvaliacao extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "nome", length = 100)
    private String nome; // Ex: "Avaliação 2026"
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoAvaliacao tipo;
    
    @Column(name = "ano_referencia")
    private Integer anoReferencia;
    
    @Column(name = "data_inicio")
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "data_limite_autoavaliacao")
    private LocalDate dataLimiteAutoavaliacao;
    
    @Column(name = "data_limite_chefia")
    private LocalDate dataLimiteChefia;
    
    @Column(name = "data_limite_recursos")
    private LocalDate dataLimiteRecursos;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoCiclo situacao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "formulario_id")
    private FormularioAvaliacao formulario;
    
    @Column(name = "nota_minima_aprovacao")
    private BigDecimal notaMinimaAprovacao; // Ex: 70%
}
```

### 2.2 Entidade: FormularioAvaliacao

```java
@Entity
@Table(name = "formulario_avaliacao")
public class FormularioAvaliacao extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "nome", length = 100)
    private String nome;
    
    @Column(name = "descricao", length = 500)
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoAvaliacao tipo;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @Column(name = "versao")
    private Integer versao;
    
    @OneToMany(mappedBy = "formulario", cascade = CascadeType.ALL)
    @OrderBy("ordem")
    private List<FatorAvaliacao> fatores = new ArrayList<>();
}
```

### 2.3 Entidade: FatorAvaliacao

```java
@Entity
@Table(name = "fator_avaliacao")
public class FatorAvaliacao extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "formulario_id", nullable = false)
    private FormularioAvaliacao formulario;
    
    @Column(name = "ordem")
    private Integer ordem;
    
    @Column(name = "codigo", length = 10)
    private String codigo; // Ex: "F01"
    
    @Column(name = "nome", length = 100)
    private String nome; // Ex: "Assiduidade"
    
    @Column(name = "descricao", length = 500)
    private String descricao;
    
    @Column(name = "peso")
    private BigDecimal peso; // Ex: 0.15 (15%)
    
    @Column(name = "nota_maxima")
    private Integer notaMaxima; // Ex: 10
    
    @Column(name = "obrigatorio")
    private Boolean obrigatorio = true;
    
    @OneToMany(mappedBy = "fator", cascade = CascadeType.ALL)
    @OrderBy("valor DESC")
    private List<CriterioAvaliacao> criterios = new ArrayList<>();
}
```

### 2.4 Entidade: CriterioAvaliacao

```java
@Entity
@Table(name = "criterio_avaliacao")
public class CriterioAvaliacao extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fator_id", nullable = false)
    private FatorAvaliacao fator;
    
    @Column(name = "valor")
    private Integer valor; // Ex: 10, 8, 6, 4, 2
    
    @Column(name = "descricao", length = 500)
    private String descricao; // Ex: "Excelente - sempre presente"
    
    @Column(name = "conceito", length = 20)
    private String conceito; // Ex: "EXCELENTE", "BOM", "REGULAR"
}
```

### 2.5 Entidade: Avaliacao

```java
@Entity
@Table(name = "avaliacao")
public class Avaliacao extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ciclo_id", nullable = false)
    private CicloAvaliacao ciclo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avaliador_id")
    private VinculoFuncional avaliador; // Chefia imediata
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoAvaliacao tipo;
    
    // Para estágio probatório
    @Column(name = "periodo_estagio")
    private Integer periodoEstagio; // 1, 2, 3, 4, 5, 6 (semestres)
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoAvaliacao situacao;
    
    // Notas
    @Column(name = "nota_autoavaliacao")
    private BigDecimal notaAutoavaliacao;
    
    @Column(name = "nota_chefia")
    private BigDecimal notaChefia;
    
    @Column(name = "nota_final")
    private BigDecimal notaFinal;
    
    @Column(name = "conceito_final", length = 20)
    private String conceitoFinal;
    
    // Datas
    @Column(name = "data_autoavaliacao")
    private LocalDateTime dataAutoavaliacao;
    
    @Column(name = "data_avaliacao_chefia")
    private LocalDateTime dataAvaliacaoChefia;
    
    @Column(name = "data_ciencia")
    private LocalDateTime dataCiencia; // Servidor tomou ciência
    
    // Resultado
    @Column(name = "aprovado")
    private Boolean aprovado;
    
    @Column(name = "gera_progressao")
    private Boolean geraProgressao = false;
    
    // Recurso
    @Column(name = "recurso")
    private Boolean recurso = false;
    
    @Column(name = "justificativa_recurso", length = 2000)
    private String justificativaRecurso;
    
    @Column(name = "parecer_recurso", length = 2000)
    private String parecerRecurso;
    
    @Column(name = "recurso_deferido")
    private Boolean recursoDeferido;
    
    @OneToMany(mappedBy = "avaliacao", cascade = CascadeType.ALL)
    private List<AvaliacaoResposta> respostas = new ArrayList<>();
}
```

### 2.6 Entidade: AvaliacaoResposta

```java
@Entity
@Table(name = "avaliacao_resposta")
public class AvaliacaoResposta extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "avaliacao_id", nullable = false)
    private Avaliacao avaliacao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "fator_id", nullable = false)
    private FatorAvaliacao fator;
    
    // Autoavaliação
    @Column(name = "nota_auto")
    private Integer notaAuto;
    
    @Column(name = "justificativa_auto", length = 1000)
    private String justificativaAuto;
    
    // Avaliação da chefia
    @Column(name = "nota_chefia")
    private Integer notaChefia;
    
    @Column(name = "justificativa_chefia", length = 1000)
    private String justificativaChefia;
    
    // Nota final do fator
    @Column(name = "nota_final")
    private BigDecimal notaFinal;
}
```

### 2.7 Entidade: EstágioProbatório

```java
@Entity
@Table(name = "estagio_probatorio")
public class EstagioProbatorio extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Column(name = "data_inicio")
    private LocalDate dataInicio; // Data do exercício
    
    @Column(name = "data_previsao_fim")
    private LocalDate dataPrevisaoFim; // 3 anos após início
    
    @Column(name = "data_fim_efetiva")
    private LocalDate dataFimEfetiva;
    
    @Column(name = "dias_suspensao")
    private Integer diasSuspensao = 0; // Licenças que suspendem
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoEstagioProbatorio situacao;
    
    @Column(name = "media_avaliacoes")
    private BigDecimal mediaAvaliacoes;
    
    @Column(name = "aprovado")
    private Boolean aprovado;
    
    @Column(name = "data_homologacao")
    private LocalDate dataHomologacao;
    
    @Column(name = "numero_portaria", length = 50)
    private String numeroPortaria;
    
    @OneToMany(mappedBy = "estagioProbatorio")
    private List<Avaliacao> avaliacoes = new ArrayList<>();
}
```

### 2.8 Enums

```java
public enum TipoAvaliacao {
    ESTAGIO_PROBATORIO,
    PERIODICA_ANUAL,
    ESPECIAL
}

public enum SituacaoAvaliacao {
    PENDENTE,           // Aguardando início
    AUTOAVALIACAO,      // Servidor preenchendo
    AVALIACAO_CHEFIA,   // Chefia avaliando
    CIENCIA,            // Aguardando ciência do servidor
    RECURSO,            // Em recurso
    FINALIZADA          // Concluída
}

public enum SituacaoEstagioProbatorio {
    EM_ANDAMENTO,
    SUSPENSO,           // Licença que suspende
    APROVADO,
    REPROVADO,
    EXONERADO           // Exonerado durante estágio
}

public enum SituacaoCiclo {
    PLANEJADO,
    ABERTO,
    AUTOAVALIACAO,
    AVALIACAO_CHEFIA,
    RECURSOS,
    ENCERRADO
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Estágio Probatório

```
REGRA EP-001: Duração
├── 3 anos de efetivo exercício
├── Licenças > 30 dias suspendem contagem
├── Férias não suspendem
└── Afastamento sem remuneração suspende

REGRA EP-002: Avaliações Obrigatórias
├── 6 avaliações semestrais
├── 1ª avaliação: 6 meses após exercício
├── Última avaliação: até 30 dias antes do fim
└── Média das 6 avaliações

REGRA EP-003: Aprovação
├── Média ≥ 70% → Aprovado
├── Média < 70% → Exoneração
├── Emitir portaria de homologação
└── Após aprovação: servidor estável

REGRA EP-004: Reprovação
├── Notificar servidor com antecedência
├── Direito a defesa prévia
├── Processo administrativo se necessário
└── Exoneração por insuficiência de desempenho
```

### 3.2 Avaliação Periódica

```
REGRA AP-001: Elegibilidade
├── Servidor estável (pós estágio)
├── Mínimo 6 meses na lotação atual
├── Sem penalidades vigentes
└── Sem licença > 180 dias no ano

REGRA AP-002: Composição da Nota
├── Autoavaliação: 30%
├── Avaliação chefia: 70%
├── Ou conforme definido no formulário
└── Nota final = (auto × 0.3) + (chefia × 0.7)

REGRA AP-003: Progressão por Mérito
├── Média ≥ 80% últimas 3 avaliações
├── Interstício mínimo cumprido
├── Sem penalidade no período
└── Disponibilidade orçamentária
```

### 3.3 Cálculo de Notas

```
CÁLCULO NOTA FINAL:

1. Para cada fator:
   nota_fator = nota_dada × peso_fator

2. Soma dos fatores:
   total_avaliacao = Σ(nota_fator)

3. Normalizar para 100:
   nota_percentual = (total_avaliacao / max_possivel) × 100

4. Compor autoavaliação + chefia:
   nota_final = (nota_auto × peso_auto) + (nota_chefia × peso_chefia)

EXEMPLO:
├── Fator Assiduidade (peso 0.20): nota 8 → 8 × 0.20 = 1.6
├── Fator Produtividade (peso 0.25): nota 9 → 9 × 0.25 = 2.25
├── Fator Qualidade (peso 0.25): nota 7 → 7 × 0.25 = 1.75
├── Fator Iniciativa (peso 0.15): nota 8 → 8 × 0.15 = 1.2
├── Fator Relacionamento (peso 0.15): nota 9 → 9 × 0.15 = 1.35
├── Total: 8.15 de 10 = 81.5%
```

---

## 4. FLUXO DE AVALIAÇÃO

```
┌─────────────────────────────────────────────────────────────┐
│                   FLUXO DE AVALIAÇÃO                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────┐                   │
│  │ 1. RH ABRE CICLO DE AVALIAÇÃO       │                   │
│  │    - Define período                  │                   │
│  │    - Define formulário               │                   │
│  │    - Gera avaliações                 │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 2. AUTOAVALIAÇÃO                    │                   │
│  │    - Servidor acessa portal         │                   │
│  │    - Preenche formulário            │                   │
│  │    - Prazo: X dias                  │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 3. AVALIAÇÃO DA CHEFIA              │                   │
│  │    - Chefia acessa sistema          │                   │
│  │    - Vê autoavaliação               │                   │
│  │    - Preenche sua avaliação         │                   │
│  │    - Prazo: Y dias                  │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 4. CIÊNCIA DO SERVIDOR              │                   │
│  │    - Sistema notifica servidor      │                   │
│  │    - Servidor visualiza resultado   │                   │
│  │    - Registra ciência               │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│         ┌───────────┴───────────┐                          │
│         │                       │                           │
│         ▼                       ▼                           │
│  ┌───────────┐          ┌───────────┐                      │
│  │ CONCORDA  │          │ DISCORDA  │                      │
│  └─────┬─────┘          └─────┬─────┘                      │
│        │                      │                            │
│        │                      ▼                            │
│        │          ┌─────────────────────────────┐          │
│        │          │ 5. RECURSO                  │          │
│        │          │    - Prazo: Z dias          │          │
│        │          │    - Justificativa          │          │
│        │          └──────────────┬──────────────┘          │
│        │                         │                         │
│        │                         ▼                         │
│        │          ┌─────────────────────────────┐          │
│        │          │ 6. COMISSÃO ANALISA         │          │
│        │          │    - Defere ou indefere     │          │
│        │          └──────────────┬──────────────┘          │
│        │                         │                         │
│        └────────────┬────────────┘                         │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 7. FINALIZAÇÃO                      │                   │
│  │    - Nota final calculada           │                   │
│  │    - Conceito atribuído             │                   │
│  │    - Gera progressão (se aplicável) │                   │
│  └─────────────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. FATORES DE AVALIAÇÃO PADRÃO

### 5.1 Estágio Probatório (Lei 8.112/90)

| Código | Fator | Peso | Descrição |
|--------|-------|------|-----------|
| F01 | **Assiduidade** | 20% | Frequência e pontualidade |
| F02 | **Disciplina** | 20% | Cumprimento de normas |
| F03 | **Capacidade de Iniciativa** | 15% | Proatividade |
| F04 | **Produtividade** | 25% | Volume e qualidade do trabalho |
| F05 | **Responsabilidade** | 20% | Comprometimento com resultados |

### 5.2 Avaliação Periódica

| Código | Fator | Peso | Descrição |
|--------|-------|------|-----------|
| F01 | **Qualidade do Trabalho** | 20% | Precisão, organização |
| F02 | **Produtividade** | 20% | Cumprimento de metas |
| F03 | **Conhecimento** | 15% | Domínio técnico |
| F04 | **Relacionamento** | 15% | Trabalho em equipe |
| F05 | **Iniciativa** | 15% | Inovação, melhorias |
| F06 | **Comprometimento** | 15% | Engajamento institucional |

---

## 6. SERVIÇOS PRINCIPAIS

### 6.1 AvaliacaoService

```java
@Service
@Transactional
public class AvaliacaoService extends AbstractTenantService {
    
    /**
     * Gerar avaliações do ciclo
     */
    public void gerarAvaliacoesCiclo(Long cicloId) {
        CicloAvaliacao ciclo = cicloRepository.findById(cicloId).orElseThrow();
        
        // Buscar servidores elegíveis
        List<VinculoFuncional> vinculos = buscarVinculosElegiveis(ciclo);
        
        for (VinculoFuncional vinculo : vinculos) {
            // Verificar se já existe avaliação
            if (avaliacaoRepository.existsByCicloAndVinculo(cicloId, vinculo.getId())) {
                continue;
            }
            
            Avaliacao avaliacao = new Avaliacao();
            avaliacao.setCiclo(ciclo);
            avaliacao.setVinculo(vinculo);
            avaliacao.setTipo(ciclo.getTipo());
            avaliacao.setSituacao(SituacaoAvaliacao.PENDENTE);
            
            // Identificar chefia imediata
            VinculoFuncional chefia = buscarChefiaImediata(vinculo);
            avaliacao.setAvaliador(chefia);
            
            // Criar respostas vazias para cada fator
            for (FatorAvaliacao fator : ciclo.getFormulario().getFatores()) {
                AvaliacaoResposta resposta = new AvaliacaoResposta();
                resposta.setAvaliacao(avaliacao);
                resposta.setFator(fator);
                avaliacao.getRespostas().add(resposta);
            }
            
            avaliacaoRepository.save(avaliacao);
        }
        
        ciclo.setSituacao(SituacaoCiclo.ABERTO);
    }
    
    /**
     * Servidor preenche autoavaliação
     */
    public void preencherAutoavaliacao(Long avaliacaoId, List<RespostaDTO> respostas) {
        Avaliacao avaliacao = avaliacaoRepository.findById(avaliacaoId).orElseThrow();
        
        // Validar situação
        if (avaliacao.getSituacao() != SituacaoAvaliacao.PENDENTE &&
            avaliacao.getSituacao() != SituacaoAvaliacao.AUTOAVALIACAO) {
            throw new BusinessException("Avaliação não está em fase de autoavaliação");
        }
        
        // Preencher respostas
        for (RespostaDTO dto : respostas) {
            AvaliacaoResposta resposta = avaliacao.getRespostas().stream()
                .filter(r -> r.getFator().getId().equals(dto.getFatorId()))
                .findFirst()
                .orElseThrow();
            
            resposta.setNotaAuto(dto.getNota());
            resposta.setJustificativaAuto(dto.getJustificativa());
        }
        
        // Calcular nota da autoavaliação
        BigDecimal notaAuto = calcularNota(avaliacao.getRespostas(), true);
        avaliacao.setNotaAutoavaliacao(notaAuto);
        avaliacao.setDataAutoavaliacao(LocalDateTime.now());
        avaliacao.setSituacao(SituacaoAvaliacao.AVALIACAO_CHEFIA);
    }
    
    /**
     * Chefia preenche avaliação
     */
    public void preencherAvaliacaoChefia(Long avaliacaoId, List<RespostaDTO> respostas) {
        Avaliacao avaliacao = avaliacaoRepository.findById(avaliacaoId).orElseThrow();
        
        // Preencher respostas da chefia
        for (RespostaDTO dto : respostas) {
            AvaliacaoResposta resposta = avaliacao.getRespostas().stream()
                .filter(r -> r.getFator().getId().equals(dto.getFatorId()))
                .findFirst()
                .orElseThrow();
            
            resposta.setNotaChefia(dto.getNota());
            resposta.setJustificativaChefia(dto.getJustificativa());
            
            // Calcular nota final do fator
            resposta.setNotaFinal(calcularNotaFinalFator(resposta));
        }
        
        // Calcular notas finais
        BigDecimal notaChefia = calcularNota(avaliacao.getRespostas(), false);
        avaliacao.setNotaChefia(notaChefia);
        avaliacao.setDataAvaliacaoChefia(LocalDateTime.now());
        
        // Calcular nota final composta
        BigDecimal notaFinal = calcularNotaFinalComposta(avaliacao);
        avaliacao.setNotaFinal(notaFinal);
        avaliacao.setConceitoFinal(determinarConceito(notaFinal));
        avaliacao.setAprovado(notaFinal.compareTo(
            avaliacao.getCiclo().getNotaMinimaAprovacao()) >= 0);
        
        avaliacao.setSituacao(SituacaoAvaliacao.CIENCIA);
        
        // Notificar servidor
        notificacaoService.notificarResultadoAvaliacao(avaliacao);
    }
    
    /**
     * Calcular nota final composta
     */
    private BigDecimal calcularNotaFinalComposta(Avaliacao avaliacao) {
        // Peso padrão: 30% auto, 70% chefia
        BigDecimal pesoAuto = new BigDecimal("0.30");
        BigDecimal pesoChefia = new BigDecimal("0.70");
        
        return avaliacao.getNotaAutoavaliacao().multiply(pesoAuto)
            .add(avaliacao.getNotaChefia().multiply(pesoChefia))
            .setScale(2, RoundingMode.HALF_UP);
    }
}
```

### 6.2 EstagioProbatorioService

```java
@Service
public class EstagioProbatorioService {
    
    /**
     * Iniciar estágio probatório
     */
    public EstagioProbatorio iniciar(VinculoFuncional vinculo) {
        EstagioProbatorio estagio = new EstagioProbatorio();
        estagio.setVinculo(vinculo);
        estagio.setDataInicio(vinculo.getDataExercicio());
        estagio.setDataPrevisaoFim(vinculo.getDataExercicio().plusYears(3));
        estagio.setSituacao(SituacaoEstagioProbatorio.EM_ANDAMENTO);
        
        return estagioProbatorioRepository.save(estagio);
    }
    
    /**
     * Verificar conclusão do estágio
     */
    @Scheduled(cron = "0 0 6 * * *") // Todo dia às 6h
    public void verificarConclusoes() {
        LocalDate hoje = LocalDate.now();
        
        // Buscar estágios próximos do fim
        List<EstagioProbatorio> estagios = repository
            .findByDataPrevisaoFimBeforeAndSituacao(
                hoje.plusDays(30), 
                SituacaoEstagioProbatorio.EM_ANDAMENTO);
        
        for (EstagioProbatorio estagio : estagios) {
            // Verificar se todas as 6 avaliações foram realizadas
            long qtdAvaliacoes = avaliacaoRepository
                .countByVinculoAndTipo(estagio.getVinculo().getId(), 
                    TipoAvaliacao.ESTAGIO_PROBATORIO);
            
            if (qtdAvaliacoes < 6) {
                // Alertar RH sobre avaliações pendentes
                notificacaoService.alertarAvaliacaoPendente(estagio);
                continue;
            }
            
            // Calcular média das avaliações
            BigDecimal media = avaliacaoRepository
                .calcularMediaEstagioProbatorio(estagio.getVinculo().getId());
            estagio.setMediaAvaliacoes(media);
            
            // Verificar aprovação
            if (media.compareTo(new BigDecimal("70")) >= 0) {
                aprovarEstagio(estagio);
            } else {
                notificacaoService.alertarReprovacaoIminente(estagio);
            }
        }
    }
    
    /**
     * Aprovar estágio probatório
     */
    public void aprovarEstagio(EstagioProbatorio estagio) {
        estagio.setAprovado(true);
        estagio.setDataFimEfetiva(LocalDate.now());
        estagio.setSituacao(SituacaoEstagioProbatorio.APROVADO);
        
        // Atualizar vínculo para estável
        VinculoFuncional vinculo = estagio.getVinculo();
        vinculo.setEstavel(true);
        
        // Gerar portaria de homologação
        String portaria = gerarPortariaHomologacao(estagio);
        estagio.setNumeroPortaria(portaria);
        estagio.setDataHomologacao(LocalDate.now());
    }
}
```

---

## 7. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| **Ciclo** |||
| GET | `/api/avaliacoes/ciclos` | Listar ciclos | ANALISTA+ |
| POST | `/api/avaliacoes/ciclos` | Criar ciclo | ADMIN |
| POST | `/api/avaliacoes/ciclos/{id}/gerar` | Gerar avaliações | ADMIN |
| PUT | `/api/avaliacoes/ciclos/{id}/abrir` | Abrir ciclo | ADMIN |
| **Formulário** |||
| GET | `/api/avaliacoes/formularios` | Listar formulários | ANALISTA+ |
| POST | `/api/avaliacoes/formularios` | Criar formulário | ADMIN |
| **Avaliação** |||
| GET | `/api/avaliacoes/minhas` | Minhas avaliações | USUARIO |
| GET | `/api/avaliacoes/equipe` | Avaliações da equipe | GESTOR+ |
| PUT | `/api/avaliacoes/{id}/autoavaliacao` | Preencher auto | USUARIO |
| PUT | `/api/avaliacoes/{id}/chefia` | Avaliar subordinado | GESTOR+ |
| PUT | `/api/avaliacoes/{id}/ciencia` | Registrar ciência | USUARIO |
| POST | `/api/avaliacoes/{id}/recurso` | Abrir recurso | USUARIO |
| PUT | `/api/avaliacoes/{id}/recurso/julgar` | Julgar recurso | ADMIN |
| **Estágio Probatório** |||
| GET | `/api/estagio-probatorio/{vinculoId}` | Consultar estágio | ANALISTA+ |
| POST | `/api/estagio-probatorio/{id}/aprovar` | Aprovar estágio | ADMIN |
| POST | `/api/estagio-probatorio/{id}/suspender` | Suspender contagem | ADMIN |

---
