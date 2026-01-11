# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 9
## Módulo PCCS e Carreira

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar o Plano de Cargos, Carreiras e Salários (PCCS) dos servidores municipais, incluindo progressões horizontais e verticais, enquadramentos e simulações de impacto.

### 1.2 Conceitos Fundamentais

| Conceito | Descrição |
|----------|-----------|
| **Cargo** | Conjunto de atribuições e responsabilidades (ex: Técnico Administrativo) |
| **Carreira** | Agrupamento de cargos com mesma natureza (ex: Carreira Administrativa) |
| **Classe** | Posição horizontal na carreira (ex: A, B, C, D, E) |
| **Nível/Referência** | Posição vertical dentro da classe (ex: 1, 2, 3...) |
| **Progressão Horizontal** | Mudança de classe (mérito/desempenho) |
| **Progressão Vertical** | Mudança de nível (tempo de serviço) |
| **Enquadramento** | Posicionamento inicial do servidor na tabela |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: Carreira

```java
@Entity
@Table(name = "carreira")
public class Carreira extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "codigo", length = 20, unique = true)
    private String codigo;
    
    @Column(name = "nome", length = 100)
    private String nome;
    
    @Column(name = "descricao", length = 500)
    private String descricao;
    
    @Column(name = "lei_criacao", length = 50)
    private String leiCriacao;
    
    @Column(name = "data_vigencia")
    private LocalDate dataVigencia;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoCadastro situacao;
    
    @OneToMany(mappedBy = "carreira", cascade = CascadeType.ALL)
    private List<Classe> classes = new ArrayList<>();
    
    @OneToMany(mappedBy = "carreira")
    private List<Cargo> cargos = new ArrayList<>();
}
```

### 2.2 Entidade: Classe

```java
@Entity
@Table(name = "classe")
public class Classe extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "carreira_id", nullable = false)
    private Carreira carreira;
    
    @Column(name = "codigo", length = 5)
    private String codigo; // A, B, C, D, E
    
    @Column(name = "nome", length = 50)
    private String nome;
    
    @Column(name = "ordem")
    private Integer ordem; // 1, 2, 3...
    
    @Column(name = "percentual_sobre_anterior", precision = 5, scale = 2)
    private BigDecimal percentualSobreAnterior; // Ex: 5% sobre classe anterior
    
    @OneToMany(mappedBy = "classe", cascade = CascadeType.ALL)
    private List<Nivel> niveis = new ArrayList<>();
}
```

### 2.3 Entidade: Nivel

```java
@Entity
@Table(name = "nivel")
public class Nivel extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "classe_id", nullable = false)
    private Classe classe;
    
    @Column(name = "codigo", length = 5)
    private String codigo; // 1, 2, 3, 4...
    
    @Column(name = "ordem")
    private Integer ordem;
    
    @Column(name = "valor_base", precision = 15, scale = 2)
    private BigDecimal valorBase;
    
    @Column(name = "percentual_sobre_anterior", precision = 5, scale = 2)
    private BigDecimal percentualSobreAnterior; // Ex: 3% sobre nível anterior
    
    @Column(name = "tempo_minimo_meses")
    private Integer tempoMinimoMeses; // Meses para progredir
}
```

### 2.4 Entidade: TabelaSalarial

```java
@Entity
@Table(name = "tabela_salarial")
public class TabelaSalarial extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "carreira_id", nullable = false)
    private Carreira carreira;
    
    @Column(name = "vigencia_inicio")
    private LocalDate vigenciaInicio;
    
    @Column(name = "vigencia_fim")
    private LocalDate vigenciaFim;
    
    @Column(name = "lei_reajuste", length = 50)
    private String leiReajuste;
    
    @Column(name = "percentual_reajuste", precision = 5, scale = 2)
    private BigDecimal percentualReajuste;
    
    @OneToMany(mappedBy = "tabelaSalarial", cascade = CascadeType.ALL)
    private List<TabelaSalarialItem> itens = new ArrayList<>();
}
```

### 2.5 Entidade: TabelaSalarialItem

```java
@Entity
@Table(name = "tabela_salarial_item")
public class TabelaSalarialItem extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tabela_salarial_id", nullable = false)
    private TabelaSalarial tabelaSalarial;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "classe_id", nullable = false)
    private Classe classe;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nivel_id", nullable = false)
    private Nivel nivel;
    
    @Column(name = "valor", precision = 15, scale = 2)
    private BigDecimal valor;
}
```

### 2.6 Entidade: Progressao

```java
@Entity
@Table(name = "progressao")
public class Progressao extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 20)
    private TipoProgressao tipo; // HORIZONTAL, VERTICAL
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "classe_origem_id")
    private Classe classeOrigem;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nivel_origem_id")
    private Nivel nivelOrigem;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "classe_destino_id")
    private Classe classeDestino;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "nivel_destino_id")
    private Nivel nivelDestino;
    
    @Column(name = "valor_anterior", precision = 15, scale = 2)
    private BigDecimal valorAnterior;
    
    @Column(name = "valor_novo", precision = 15, scale = 2)
    private BigDecimal valorNovo;
    
    @Column(name = "data_efeito")
    private LocalDate dataEfeito;
    
    @Column(name = "numero_ato", length = 50)
    private String numeroAto;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoProgressao situacao;
    
    @Column(name = "motivo", length = 500)
    private String motivo;
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Progressão Vertical (Tempo de Serviço)

```
REGRA PV-001: Requisitos
├── Tempo mínimo no nível atual (ex: 36 meses)
├── Não ter penalidade disciplinar no período
├── Estar em efetivo exercício
└── Avaliação de desempenho satisfatória

REGRA PV-002: Cálculo Automático
├── Data base: data do último enquadramento/progressão
├── Verificar tempo transcorrido
├── Se atingiu tempo mínimo → elegível
└── Processar em lote (mês específico)

REGRA PV-003: Efeitos Financeiros
├── Novo valor = valor do próximo nível
├── Retroativo à data de direito
├── Diferenças calculadas automaticamente
└── Impacto em 13º, férias, etc.
```

### 3.2 Progressão Horizontal (Mérito)

```
REGRA PH-001: Requisitos
├── Tempo mínimo na classe atual (ex: 60 meses)
├── Avaliação de desempenho ≥ nota mínima
├── Participação em capacitação
├── Não ter penalidade no período
└── Disponibilidade orçamentária

REGRA PH-002: Processo de Avaliação
├── Comissão de avaliação analisa
├── Pontuação por critérios definidos
├── Ranking de servidores elegíveis
├── Aprovação conforme vagas disponíveis
└── Publicação de resultado

REGRA PH-003: Efeitos
├── Mudança de classe (A→B, B→C, etc.)
├── Retorno ao nível inicial da nova classe
├── Novo valor conforme tabela salarial
└── Contagem de tempo reinicia para próxima
```

### 3.3 Tabela Salarial

```
ESTRUTURA EXEMPLO - CARREIRA ADMINISTRATIVA:

┌─────────────────────────────────────────────────────────┐
│           TABELA SALARIAL - CARREIRA ADMIN              │
├──────────┬─────────┬─────────┬─────────┬─────────┬──────┤
│ Nível    │ CLASSE A│ CLASSE B│ CLASSE C│ CLASSE D│CL. E │
├──────────┼─────────┼─────────┼─────────┼─────────┼──────┤
│ 1        │ 2.500,00│ 2.625,00│ 2.756,25│ 2.894,06│3.038 │
│ 2        │ 2.575,00│ 2.703,75│ 2.838,94│ 2.980,89│3.130 │
│ 3        │ 2.652,25│ 2.784,86│ 2.924,11│ 3.070,31│3.224 │
│ 4        │ 2.731,82│ 2.868,41│ 3.011,83│ 3.162,42│3.321 │
│ 5        │ 2.813,77│ 2.954,46│ 3.102,18│ 3.257,29│3.420 │
│ 6        │ 2.898,19│ 3.043,09│ 3.195,25│ 3.355,01│3.523 │
│ 7        │ 2.985,13│ 3.134,39│ 3.291,11│ 3.455,66│3.628 │
│ 8        │ 3.074,69│ 3.228,42│ 3.389,84│ 3.559,33│3.737 │
├──────────┼─────────┼─────────┼─────────┼─────────┼──────┤
│ Reajuste │  +5%    │   +5%   │   +5%   │   +5%   │ +5%  │
│ entre    │ classe  │ classe  │ classe  │ classe  │classe│
│ classes  │ anterior│ anterior│ anterior│ anterior│ ant. │
├──────────┼─────────┴─────────┴─────────┴─────────┴──────┤
│ Reajuste │       +3% entre níveis                       │
│ níveis   │                                              │
└──────────┴──────────────────────────────────────────────┘
```

---

## 4. FLUXOS DE PROCESSOS

### 4.1 Fluxo: Progressão Vertical Automática

```
┌─────────────────────────────────────────────────────────┐
│            PROGRESSÃO VERTICAL AUTOMÁTICA               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [1] IDENTIFICAR ELEGÍVEIS                              │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Buscar servidores onde:             │               │
│  │ - tempo_no_nivel >= tempo_minimo    │               │
│  │ - situacao = ATIVO                  │               │
│  │ - nivel_atual < nivel_maximo        │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [2] VALIDAR REQUISITOS                                │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Para cada elegível verificar:       │               │
│  │ - Sem penalidade disciplinar        │               │
│  │ - Avaliação desempenho OK           │               │
│  │ - Em efetivo exercício              │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│         ┌───────────┴───────────┐                      │
│         │                       │                       │
│         ▼                       ▼                       │
│  ┌───────────┐          ┌───────────┐                  │
│  │ APROVADO  │          │ REJEITADO │                  │
│  └─────┬─────┘          │ Motivo    │                  │
│        │                └───────────┘                  │
│        ▼                                               │
│  [3] GERAR PROGRESSÃO                                  │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ Criar registro Progressao:          │              │
│  │ - tipo = VERTICAL                   │              │
│  │ - nivel_origem → nivel_destino      │              │
│  │ - valor_anterior → valor_novo       │              │
│  │ - situacao = PENDENTE               │              │
│  └──────────────────┬──────────────────┘              │
│                     │                                  │
│                     ▼                                  │
│  [4] APROVAR E EFETIVAR                               │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ Atualizar VinculoFuncionalDet:      │              │
│  │ - nivel_id = nivel_destino          │              │
│  │ - salario_base = valor_novo         │              │
│  │ Progressao.situacao = EFETIVADA     │              │
│  └─────────────────────────────────────┘              │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 4.2 Fluxo: Enquadramento Inicial

```
┌─────────────────────────────────────────────────────────┐
│               ENQUADRAMENTO INICIAL                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Admissão do Servidor]                                │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Identificar:                        │               │
│  │ - Cargo do servidor                 │               │
│  │ - Carreira vinculada ao cargo       │               │
│  │ - Formação/Titulação do servidor    │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  ┌─────────────────────────────────────┐               │
│  │ Determinar posição inicial:         │               │
│  │ - Classe A (entrada padrão)         │               │
│  │ - Nível 1 (inicial)                 │               │
│  │                                      │               │
│  │ OU conforme lei:                    │               │
│  │ - Nível diferenciado por titulação  │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  ┌─────────────────────────────────────┐               │
│  │ Criar VinculoFuncionalDet:          │               │
│  │ - classe_id = classe inicial        │               │
│  │ - nivel_id = nível inicial          │               │
│  │ - salario_base = valor da tabela    │               │
│  │ - data_enquadramento = admissão     │               │
│  └─────────────────────────────────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 5. SERVIÇOS E MÉTODOS

### 5.1 PCCSService

```java
@Service
@Transactional
public class PCCSService extends AbstractTenantService {
    
    // === CARREIRA ===
    public Carreira criarCarreira(CarreiraRequest request);
    public List<Carreira> listarCarreiras();
    public Carreira buscarCarreira(Long id);
    
    // === CLASSE ===
    public Classe adicionarClasse(Long carreiraId, ClasseRequest request);
    public List<Classe> listarClasses(Long carreiraId);
    
    // === NÍVEL ===
    public Nivel adicionarNivel(Long classeId, NivelRequest request);
    public List<Nivel> listarNiveis(Long classeId);
    
    // === TABELA SALARIAL ===
    public TabelaSalarial criarTabelaSalarial(TabelaSalarialRequest request);
    public TabelaSalarial aplicarReajuste(Long tabelaId, BigDecimal percentual);
    public BigDecimal buscarValor(Long carreiraId, Long classeId, Long nivelId);
    
    // === PROGRESSÃO ===
    public List<VinculoFuncional> buscarElegiveisProgressaoVertical();
    public List<VinculoFuncional> buscarElegiveisProgressaoHorizontal();
    public Progressao gerarProgressao(Long vinculoId, TipoProgressao tipo);
    public Progressao aprovarProgressao(Long progressaoId, String numeroAto);
    public void processarProgressoesEmLote(List<Long> progressaoIds);
    
    // === ENQUADRAMENTO ===
    public void enquadrarServidor(Long vinculoId, Long classeId, Long nivelId);
    
    // === SIMULAÇÃO ===
    public SimulacaoReajuste simularReajuste(Long carreiraId, BigDecimal percentual);
    public BigDecimal calcularImpactoOrcamentario(Long carreiraId, BigDecimal percentual);
}
```

### 5.2 ProgressaoService

```java
@Service
public class ProgressaoService {
    
    /**
     * Verificar elegibilidade para progressão vertical
     */
    public ElegibilidadeResult verificarElegibilidadeVertical(Long vinculoId) {
        VinculoFuncional vinculo = vinculoRepository.findById(vinculoId)
            .orElseThrow();
        VinculoFuncionalDet detalhe = vinculo.getDetalheAtual();
        
        ElegibilidadeResult result = new ElegibilidadeResult();
        
        // 1. Verificar se está no nível máximo
        Nivel nivelAtual = detalhe.getNivel();
        Nivel proximoNivel = nivelRepository
            .findByClasseAndOrdem(nivelAtual.getClasse(), nivelAtual.getOrdem() + 1)
            .orElse(null);
        
        if (proximoNivel == null) {
            result.addImpedimento("Servidor já está no nível máximo da classe");
            return result;
        }
        
        // 2. Verificar tempo no nível
        long mesesNoNivel = ChronoUnit.MONTHS.between(
            detalhe.getDataEnquadramento(), LocalDate.now());
        
        if (mesesNoNivel < nivelAtual.getTempoMinimoMeses()) {
            result.addImpedimento(String.format(
                "Tempo insuficiente: %d de %d meses", 
                mesesNoNivel, nivelAtual.getTempoMinimoMeses()));
        }
        
        // 3. Verificar penalidades
        List<Penalidade> penalidades = penalidadeRepository
            .findByVinculoAndPeriodo(vinculoId, 
                detalhe.getDataEnquadramento(), LocalDate.now());
        
        if (!penalidades.isEmpty()) {
            result.addImpedimento("Possui penalidade disciplinar no período");
        }
        
        // 4. Verificar avaliação de desempenho
        AvaliacaoDesempenho avaliacao = avaliacaoRepository
            .findUltimaByVinculo(vinculoId);
        
        if (avaliacao == null || avaliacao.getNota().compareTo(NOTA_MINIMA) < 0) {
            result.addImpedimento("Avaliação de desempenho insuficiente");
        }
        
        result.setElegivel(result.getImpedimentos().isEmpty());
        result.setProximoNivel(proximoNivel);
        
        return result;
    }
    
    /**
     * Calcular diferenças salariais retroativas
     */
    public BigDecimal calcularDiferencas(Progressao progressao) {
        LocalDate dataEfeito = progressao.getDataEfeito();
        LocalDate hoje = LocalDate.now();
        
        BigDecimal diferenca = progressao.getValorNovo()
            .subtract(progressao.getValorAnterior());
        
        // Calcular meses de retroativo
        long meses = ChronoUnit.MONTHS.between(dataEfeito, hoje);
        
        // Diferença mensal * meses
        BigDecimal totalRetroativo = diferenca.multiply(BigDecimal.valueOf(meses));
        
        // Adicionar impacto em 13º proporcional
        BigDecimal impacto13 = diferenca
            .multiply(BigDecimal.valueOf(dataEfeito.getMonthValue()))
            .divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
        
        return totalRetroativo.add(impacto13);
    }
}
```

---

## 6. ENDPOINTS DA API

### 6.1 CarreiraController

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| POST | `/api/carreiras` | Criar carreira | ADMIN |
| GET | `/api/carreiras` | Listar carreiras | USUARIO+ |
| GET | `/api/carreiras/{id}` | Buscar carreira | USUARIO+ |
| POST | `/api/carreiras/{id}/classes` | Adicionar classe | ADMIN |
| GET | `/api/carreiras/{id}/tabela-salarial` | Ver tabela | USUARIO+ |

### 6.2 ProgressaoController

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/api/progressoes/elegiveis/vertical` | Listar elegíveis PV | GESTOR+ |
| GET | `/api/progressoes/elegiveis/horizontal` | Listar elegíveis PH | GESTOR+ |
| POST | `/api/progressoes/gerar` | Gerar progressão | GESTOR+ |
| PUT | `/api/progressoes/{id}/aprovar` | Aprovar progressão | GESTOR+ |
| POST | `/api/progressoes/processar-lote` | Processar em lote | ADMIN |
| GET | `/api/progressoes/servidor/{vinculoId}` | Histórico servidor | USUARIO+ |

### 6.3 SimulacaoController

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| POST | `/api/simulacao/reajuste` | Simular reajuste | GESTOR+ |
| POST | `/api/simulacao/impacto` | Calcular impacto | GESTOR+ |

---

## 7. RELATÓRIOS

### 7.1 Relatórios Disponíveis

| Relatório | Descrição |
|-----------|-----------|
| Tabela Salarial Completa | Todas as classes e níveis |
| Servidores por Classe/Nível | Distribuição atual |
| Elegíveis Progressão Vertical | Próximos a progredir |
| Elegíveis Progressão Horizontal | Candidatos ao mérito |
| Histórico de Progressões | Por servidor ou período |
| Impacto Orçamentário | Simulação de reajuste |

---

## 8. INTEGRAÇÃO COM FOLHA

### 8.1 Atualização Automática

```java
// Quando progressão é efetivada
@EventListener
public void onProgressaoEfetivada(ProgressaoEfetivadaEvent event) {
    Progressao progressao = event.getProgressao();
    VinculoFuncional vinculo = progressao.getVinculo();
    
    // Atualizar detalhe do vínculo
    VinculoFuncionalDet detalhe = vinculo.getDetalheAtual();
    detalhe.setNivel(progressao.getNivelDestino());
    detalhe.setClasse(progressao.getClasseDestino());
    detalhe.setSalarioBase(progressao.getValorNovo());
    detalhe.setDataEnquadramento(progressao.getDataEfeito());
    
    vinculoDetRepository.save(detalhe);
    
    // Se houver retroativo, gerar rubrica
    if (progressao.getDataEfeito().isBefore(LocalDate.now())) {
        BigDecimal diferenca = progressaoService
            .calcularDiferencas(progressao);
        
        // Criar lançamento de diferença
        lancamentoService.criarLancamento(
            vinculo.getId(),
            "DIFERENCA_PROGRESSAO",
            diferenca,
            "Diferença progressão " + progressao.getTipo());
    }
}
```

---

**Próximo Documento:** PARTE 10 - Aposentadoria e Pensões
