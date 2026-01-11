# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 10
## Módulo de Aposentadoria e Pensões

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar os processos de aposentadoria de servidores e concessão de pensões por morte, conforme EC 103/2019 e legislação municipal.

### 1.2 Tipos de Aposentadoria (EC 103/2019)

| Tipo | Requisitos | Proventos |
|------|------------|-----------|
| **Voluntária** | Idade + Tempo Contrib. | Média ou integralidade |
| **Compulsória** | 75 anos | Proporcional |
| **Invalidez** | Incapacidade permanente | Proporcional/Integral |
| **Especial** | Atividade de risco | Regras específicas |

### 1.3 Regras de Transição EC 103/2019

| Regra | Aplicável a | Requisitos |
|-------|-------------|------------|
| **Pedágio 50%** | Próximos de aposentar | +50% tempo faltante |
| **Pedágio 100%** | Ingresso até 2003 | +100% tempo + idade |
| **Pontos** | Geral | Idade + Tempo = pontos |
| **Idade Mínima** | Geral | Idade progressiva |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: Aposentadoria

```java
@Entity
@Table(name = "aposentadoria")
public class Aposentadoria extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoAposentadoria tipo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "regra_transicao", length = 30)
    private RegraTransicao regraTransicao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoAposentadoria situacao;
    
    // Datas
    @Column(name = "data_protocolo")
    private LocalDate dataProtocolo;
    
    @Column(name = "data_concessao")
    private LocalDate dataConcessao;
    
    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;
    
    @Column(name = "data_vigencia")
    private LocalDate dataVigencia;
    
    // Valores
    @Column(name = "media_contribuicoes", precision = 15, scale = 2)
    private BigDecimal mediaContribuicoes;
    
    @Column(name = "valor_provento", precision = 15, scale = 2)
    private BigDecimal valorProvento;
    
    @Column(name = "coeficiente", precision = 5, scale = 4)
    private BigDecimal coeficiente; // 0.60 a 1.00
    
    // Tempo de contribuição
    @Column(name = "tempo_total_dias")
    private Integer tempoTotalDias;
    
    @Column(name = "tempo_cargo_dias")
    private Integer tempoCargoAtualDias;
    
    @Column(name = "tempo_servico_publico_dias")
    private Integer tempoServicoPublicoDias;
    
    // Documentação
    @Column(name = "numero_processo", length = 30)
    private String numeroProcesso;
    
    @Column(name = "numero_portaria", length = 50)
    private String numeroPortaria;
    
    // Averbações consideradas
    @OneToMany(mappedBy = "aposentadoria")
    private List<AverbacaoTempo> averbacoes = new ArrayList<>();
}
```

### 2.2 Entidade: AverbacaoTempo

```java
@Entity
@Table(name = "averbacao_tempo")
public class AverbacaoTempo extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aposentadoria_id")
    private Aposentadoria aposentadoria;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_tempo", length = 30)
    private TipoTempo tipoTempo; // FEDERAL, ESTADUAL, MUNICIPAL, PRIVADO, MILITAR
    
    @Column(name = "empregador", length = 200)
    private String empregador;
    
    @Column(name = "cnpj_empregador", length = 18)
    private String cnpjEmpregador;
    
    @Column(name = "data_inicio")
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "dias_averbados")
    private Integer diasAverbados;
    
    @Column(name = "numero_ctc", length = 50)
    private String numeroCTC; // Certidão Tempo Contribuição
    
    @Column(name = "data_emissao_ctc")
    private LocalDate dataEmissaoCTC;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoAverbacao situacao;
}
```

### 2.3 Entidade: Pensao

```java
@Entity
@Table(name = "pensao")
public class Pensao extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id")
    private Servidor servidorFalecido;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "aposentadoria_id")
    private Aposentadoria aposentadoriaOrigem; // Se já era aposentado
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoPensao situacao;
    
    // Datas
    @Column(name = "data_obito")
    private LocalDate dataObito;
    
    @Column(name = "data_concessao")
    private LocalDate dataConcessao;
    
    // Valores
    @Column(name = "valor_integral", precision = 15, scale = 2)
    private BigDecimal valorIntegral;
    
    @Column(name = "valor_cota_familiar", precision = 15, scale = 2)
    private BigDecimal valorCotaFamiliar; // 50% + 10% por dependente
    
    // Beneficiários
    @OneToMany(mappedBy = "pensao", cascade = CascadeType.ALL)
    private List<PensaoBeneficiario> beneficiarios = new ArrayList<>();
}
```

### 2.4 Entidade: PensaoBeneficiario

```java
@Entity
@Table(name = "pensao_beneficiario")
public class PensaoBeneficiario extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "pensao_id", nullable = false)
    private Pensao pensao;
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "data_nascimento")
    private LocalDate dataNascimento;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_beneficiario", length = 30)
    private TipoBeneficiario tipo; // CONJUGE, FILHO, PAI, MAE
    
    @Column(name = "percentual_cota", precision = 5, scale = 2)
    private BigDecimal percentualCota;
    
    @Column(name = "valor_cota", precision = 15, scale = 2)
    private BigDecimal valorCota;
    
    @Column(name = "data_inicio")
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim; // Quando perde direito
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoBeneficiario situacao;
}
```

### 2.5 Enums

```java
public enum TipoAposentadoria {
    VOLUNTARIA_TEMPO,    // Tempo de contribuição
    VOLUNTARIA_IDADE,    // Por idade
    COMPULSORIA,         // 75 anos
    INVALIDEZ,           // Incapacidade permanente
    ESPECIAL             // Atividades de risco
}

public enum RegraTransicao {
    NENHUMA,            // Novas regras diretas
    PEDAGIO_50,         // Pedágio 50%
    PEDAGIO_100,        // Pedágio 100%
    PONTOS,             // Regra de pontos
    IDADE_MINIMA,       // Idade mínima progressiva
    DIREITO_ADQUIRIDO   // Antes da EC 103/2019
}

public enum TipoBeneficiario {
    CONJUGE,
    COMPANHEIRO,
    FILHO_MENOR,
    FILHO_INVALIDO,
    PAI,
    MAE,
    IRMAO_MENOR,
    IRMAO_INVALIDO
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Aposentadoria Voluntária (EC 103/2019)

```
REGRA AV-001: Requisitos Homens
├── Idade mínima: 65 anos
├── Tempo contribuição: 25 anos
├── Tempo serviço público: 10 anos
└── Tempo no cargo: 5 anos

REGRA AV-002: Requisitos Mulheres
├── Idade mínima: 62 anos
├── Tempo contribuição: 25 anos
├── Tempo serviço público: 10 anos
└── Tempo no cargo: 5 anos

REGRA AV-003: Cálculo dos Proventos
├── Base: Média de todas contribuições desde 07/1994
├── Coeficiente: 60% + 2% por ano que exceder:
│   - Homens: 20 anos de contribuição
│   - Mulheres: 15 anos de contribuição
└── Provento = Média × Coeficiente

EXEMPLO:
├── Servidor com 35 anos de contribuição
├── Média contribuições: R$ 8.000,00
├── Anos excedentes (H): 35 - 20 = 15 anos
├── Coeficiente: 60% + (15 × 2%) = 90%
└── Provento: R$ 8.000 × 0,90 = R$ 7.200,00
```

### 3.2 Regra de Transição - Pedágio 50%

```
REGRA P50-001: Elegibilidade
├── Servidor estava a 2 anos ou menos de aposentar em 13/11/2019
└── Completou os requisitos antigos até 31/12/2021

REGRA P50-002: Requisitos Homens
├── Idade: não exigida (regra antiga)
├── Tempo contribuição: 35 anos
├── Pedágio: +50% do tempo que faltava em 13/11/2019
└── Tempo serviço público e cargo: mantido

REGRA P50-003: Cálculo
├── Provento = Média × Fator Previdenciário
└── Sem limite de teto

EXEMPLO:
├── Em 13/11/2019 faltavam 2 anos para os 35
├── Pedágio: 2 × 50% = 1 ano
├── Total: 35 + 1 = 36 anos necessários
```

### 3.3 Regra de Transição - Pontos

```
REGRA PT-001: Requisitos
├── Homens: 61 anos idade + 35 contrib = 96 pontos (2019)
├── Mulheres: 56 anos idade + 30 contrib = 86 pontos (2019)
└── Acrescenta 1 ponto por ano até limite

REGRA PT-002: Progressão Pontos
├── 2019: H=96, M=86
├── 2020: H=97, M=87
├── 2021: H=98, M=88
├── ...
├── Limite H: 105 pontos (2028)
└── Limite M: 100 pontos (2033)

REGRA PT-003: Cálculo
├── Provento = Média × Coeficiente
├── Coeficiente: 60% + 2%/ano excedente
└── Limitado ao teto RPPS se não integralidade
```

### 3.4 Aposentadoria Compulsória

```
REGRA AC-001: Requisitos
├── Idade: 75 anos
└── Automática, independente de tempo

REGRA AC-002: Cálculo
├── Provento = Média × (Tempo Contrib / 25 anos)
├── Mínimo: 1 salário mínimo
└── Máximo: Teto RPPS ou última remuneração

EXEMPLO:
├── Servidor com 20 anos de contribuição
├── Média: R$ 10.000,00
├── Coeficiente: 20/25 = 0,80 (80%)
└── Provento: R$ 10.000 × 0,80 = R$ 8.000,00
```

### 3.5 Pensão por Morte (EC 103/2019)

```
REGRA PM-001: Valor Base
├── Se servidor ativo: Valor aposentadoria que teria direito
└── Se aposentado: Valor do benefício

REGRA PM-002: Cota Familiar
├── Base: 50% do valor base
├── + 10% por dependente, até 100%
└── Cota individual = Total / nº dependentes

REGRA PM-003: Duração
├── Cônjuge < 22 anos: 3 anos
├── Cônjuge 22-27 anos: 6 anos
├── Cônjuge 28-30 anos: 10 anos
├── Cônjuge 31-41 anos: 15 anos
├── Cônjuge 42-44 anos: 20 anos
├── Cônjuge ≥ 45 anos: vitalícia
├── Filho: até 21 anos (ou 24 se universitário)
└── Filho inválido: vitalícia

EXEMPLO:
├── Servidor falecido recebia R$ 6.000,00
├── Dependentes: esposa (50 anos) + 2 filhos (15 e 18 anos)
├── Cota familiar: 50% + (3 × 10%) = 80%
├── Valor total: R$ 6.000 × 80% = R$ 4.800,00
├── Por dependente: R$ 4.800 / 3 = R$ 1.600,00
└── Quando filhos completarem 21: reversão para esposa
```

---

## 4. CÁLCULOS

### 4.1 Serviço de Cálculo de Aposentadoria

```java
@Service
public class CalculoAposentadoriaService {
    
    /**
     * Calcular média das contribuições
     */
    public BigDecimal calcularMediaContribuicoes(Long servidorId) {
        // Buscar todas as remunerações desde 07/1994
        List<RemuneracaoHistorico> historico = remuneracaoRepository
            .findByServidorFromData(servidorId, LocalDate.of(1994, 7, 1));
        
        // Atualizar valores pelo índice (INPC ou similar)
        List<BigDecimal> valoresAtualizados = historico.stream()
            .map(r -> atualizarPeloIndice(r.getValor(), r.getCompetencia()))
            .collect(Collectors.toList());
        
        // Calcular média de todas (ou 80% maiores, conforme regra)
        BigDecimal soma = valoresAtualizados.stream()
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        return soma.divide(BigDecimal.valueOf(valoresAtualizados.size()), 
            2, RoundingMode.HALF_UP);
    }
    
    /**
     * Calcular coeficiente de cálculo
     */
    public BigDecimal calcularCoeficiente(Integer anosContribuicao, Sexo sexo) {
        int anosExcedentes;
        
        if (sexo == Sexo.MASCULINO) {
            anosExcedentes = Math.max(0, anosContribuicao - 20);
        } else {
            anosExcedentes = Math.max(0, anosContribuicao - 15);
        }
        
        // 60% base + 2% por ano excedente
        BigDecimal coeficiente = BigDecimal.valueOf(0.60)
            .add(BigDecimal.valueOf(anosExcedentes * 0.02));
        
        // Limitar a 100%
        return coeficiente.min(BigDecimal.ONE);
    }
    
    /**
     * Calcular tempo total de contribuição
     */
    public TempoContribuicao calcularTempoTotal(Long servidorId) {
        // Tempo no cargo atual
        VinculoFuncional vinculo = vinculoRepository
            .findAtivoByServidor(servidorId);
        int diasCargoAtual = calcularDias(vinculo.getDataAdmissao(), LocalDate.now());
        
        // Tempo averbado
        List<AverbacaoTempo> averbacoes = averbacaoRepository
            .findByServidorAndSituacao(servidorId, SituacaoAverbacao.APROVADA);
        int diasAverbados = averbacoes.stream()
            .mapToInt(AverbacaoTempo::getDiasAverbados)
            .sum();
        
        // Total
        int totalDias = diasCargoAtual + diasAverbados;
        
        return new TempoContribuicao(
            diasCargoAtual,
            diasAverbados,
            totalDias,
            totalDias / 365, // Anos
            (totalDias % 365) / 30, // Meses
            totalDias % 30 // Dias
        );
    }
    
    /**
     * Verificar elegibilidade
     */
    public ElegibilidadeAposentadoria verificarElegibilidade(Long servidorId) {
        Servidor servidor = servidorRepository.findById(servidorId).orElseThrow();
        TempoContribuicao tempo = calcularTempoTotal(servidorId);
        int idade = calcularIdade(servidor.getDataNascimento());
        
        ElegibilidadeAposentadoria result = new ElegibilidadeAposentadoria();
        result.setIdadeAtual(idade);
        result.setTempoContribuicao(tempo);
        
        // Verificar cada regra
        verificarRegraComum(result, servidor, tempo, idade);
        verificarRegraPedagio50(result, servidor, tempo, idade);
        verificarRegraPedagio100(result, servidor, tempo, idade);
        verificarRegraPontos(result, servidor, tempo, idade);
        
        return result;
    }
    
    /**
     * Simular aposentadoria
     */
    public SimulacaoAposentadoria simular(Long servidorId, TipoAposentadoria tipo,
                                          RegraTransicao regra) {
        BigDecimal media = calcularMediaContribuicoes(servidorId);
        TempoContribuicao tempo = calcularTempoTotal(servidorId);
        Servidor servidor = servidorRepository.findById(servidorId).orElseThrow();
        
        BigDecimal coeficiente = calcularCoeficiente(
            tempo.getAnosCompletos(), servidor.getSexo());
        
        BigDecimal proventoCalculado = media.multiply(coeficiente)
            .setScale(2, RoundingMode.HALF_UP);
        
        // Aplicar teto se necessário
        BigDecimal teto = configuracaoService.getTetoRPPS();
        BigDecimal proventoFinal = proventoCalculado.min(teto);
        
        return new SimulacaoAposentadoria(
            media,
            coeficiente,
            proventoCalculado,
            proventoFinal,
            tempo
        );
    }
}
```

### 4.2 Serviço de Cálculo de Pensão

```java
@Service
public class CalculoPensaoService {
    
    /**
     * Calcular valor da pensão
     */
    public CalculoPensao calcular(Long servidorId, List<DependenteDTO> dependentes) {
        // Determinar valor base
        BigDecimal valorBase;
        
        Aposentadoria aposentadoria = aposentadoriaRepository
            .findByServidorId(servidorId).orElse(null);
        
        if (aposentadoria != null) {
            // Já era aposentado
            valorBase = aposentadoria.getValorProvento();
        } else {
            // Era ativo - simular aposentadoria
            SimulacaoAposentadoria sim = aposentadoriaService
                .simular(servidorId, TipoAposentadoria.VOLUNTARIA_TEMPO, null);
            valorBase = sim.getProventoFinal();
        }
        
        // Calcular cota familiar
        int numDependentes = dependentes.size();
        BigDecimal percentualCota = BigDecimal.valueOf(0.50)
            .add(BigDecimal.valueOf(numDependentes * 0.10));
        percentualCota = percentualCota.min(BigDecimal.ONE); // Máx 100%
        
        BigDecimal valorTotal = valorBase.multiply(percentualCota);
        BigDecimal valorPorDependente = valorTotal
            .divide(BigDecimal.valueOf(numDependentes), 2, RoundingMode.HALF_UP);
        
        // Calcular duração para cada dependente
        List<CotaPensao> cotas = dependentes.stream()
            .map(d -> {
                CotaPensao cota = new CotaPensao();
                cota.setNome(d.getNome());
                cota.setTipo(d.getTipo());
                cota.setValor(valorPorDependente);
                cota.setDuracaoAnos(calcularDuracaoPensao(d));
                return cota;
            })
            .collect(Collectors.toList());
        
        return new CalculoPensao(valorBase, percentualCota, valorTotal, cotas);
    }
    
    private Integer calcularDuracaoPensao(DependenteDTO dependente) {
        if (dependente.getTipo() == TipoBeneficiario.CONJUGE ||
            dependente.getTipo() == TipoBeneficiario.COMPANHEIRO) {
            
            int idade = calcularIdade(dependente.getDataNascimento());
            
            if (idade < 22) return 3;
            if (idade <= 27) return 6;
            if (idade <= 30) return 10;
            if (idade <= 41) return 15;
            if (idade <= 44) return 20;
            return null; // Vitalícia
        }
        
        if (dependente.getTipo() == TipoBeneficiario.FILHO_MENOR) {
            int idade = calcularIdade(dependente.getDataNascimento());
            return 21 - idade;
        }
        
        if (dependente.getTipo() == TipoBeneficiario.FILHO_INVALIDO) {
            return null; // Vitalícia
        }
        
        return null;
    }
}
```

---

## 5. FLUXOS DE PROCESSOS

### 5.1 Fluxo: Processo de Aposentadoria

```
┌─────────────────────────────────────────────────────────┐
│            PROCESSO DE APOSENTADORIA                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [1] PROTOCOLO                                          │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Servidor solicita aposentadoria     │               │
│  │ - Preenche requerimento             │               │
│  │ - Anexa documentos                  │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [2] ANÁLISE DOCUMENTAL                                │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ RH verifica:                        │               │
│  │ - Documentos pessoais               │               │
│  │ - CTCs (averbações)                 │               │
│  │ - Ficha funcional                   │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [3] CONTAGEM DE TEMPO                                 │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Sistema calcula:                    │               │
│  │ - Tempo no cargo atual              │               │
│  │ - Tempo de serviço público          │               │
│  │ - Tempo averbado                    │               │
│  │ - Tempo total de contribuição       │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [4] VERIFICAR ELEGIBILIDADE                           │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Verificar qual regra se aplica:     │               │
│  │ - Regra comum EC 103/2019           │               │
│  │ - Regra de transição                │               │
│  │ - Direito adquirido                 │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [5] CALCULAR PROVENTOS                                │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ - Calcular média contribuições      │               │
│  │ - Aplicar coeficiente               │               │
│  │ - Verificar teto                    │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [6] PARECER JURÍDICO                                  │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Procuradoria analisa legalidade     │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  [7] CONCESSÃO                                         │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ - Publicar portaria                 │               │
│  │ - Gerar evento eSocial              │               │
│  │ - Inativar vínculo                  │               │
│  │ - Iniciar pagamento de proventos    │               │
│  └─────────────────────────────────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 6. SERVIÇOS E MÉTODOS

### 6.1 AposentadoriaService

```java
@Service
@Transactional
public class AposentadoriaService extends AbstractTenantService {
    
    // Criar solicitação
    public Aposentadoria solicitar(AposentadoriaRequest request);
    
    // Calcular elegibilidade
    public ElegibilidadeAposentadoria verificarElegibilidade(Long servidorId);
    
    // Simular proventos
    public SimulacaoAposentadoria simular(Long servidorId, TipoAposentadoria tipo);
    
    // Calcular tempo de contribuição
    public TempoContribuicao calcularTempo(Long servidorId);
    
    // Conceder aposentadoria
    public Aposentadoria conceder(Long id, String numeroPortaria, LocalDate dataConcessao);
    
    // Indeferir
    public Aposentadoria indeferir(Long id, String motivo);
}
```

### 6.2 PensaoService

```java
@Service
@Transactional  
public class PensaoService extends AbstractTenantService {
    
    // Criar pensão
    public Pensao criar(PensaoRequest request);
    
    // Calcular cotas
    public CalculoPensao calcular(Long servidorId, List<DependenteDTO> dependentes);
    
    // Adicionar beneficiário
    public PensaoBeneficiario adicionarBeneficiario(Long pensaoId, BeneficiarioRequest request);
    
    // Cessar cota (quando perde direito)
    public void cessarCota(Long beneficiarioId, LocalDate dataCessacao, String motivo);
    
    // Reverter cotas
    public void reverterCotas(Long pensaoId);
}
```

---

## 7. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| POST | `/api/aposentadorias/solicitar` | Nova solicitação | ANALISTA+ |
| GET | `/api/aposentadorias/{id}` | Buscar | ANALISTA+ |
| GET | `/api/aposentadorias/elegibilidade/{servidorId}` | Verificar | USUARIO+ |
| POST | `/api/aposentadorias/simular` | Simular | USUARIO+ |
| PUT | `/api/aposentadorias/{id}/conceder` | Conceder | GESTOR+ |
| POST | `/api/pensoes` | Criar pensão | GESTOR+ |
| POST | `/api/pensoes/{id}/beneficiarios` | Add beneficiário | GESTOR+ |
| GET | `/api/averbacoes/servidor/{id}` | Listar averbações | ANALISTA+ |
| POST | `/api/averbacoes` | Nova averbação | ANALISTA+ |

---

**Próximo Documento:** PARTE 11 - Portal do Servidor
