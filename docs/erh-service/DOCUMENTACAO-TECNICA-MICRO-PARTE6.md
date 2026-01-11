# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 6
## Módulo de Licenças e Afastamentos

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar todos os tipos de licenças e afastamentos de servidores municipais, controlando períodos, impactos na folha de pagamento e obrigações legais.

### 1.2 Tipos de Afastamentos Suportados

| Código | Tipo | Dias Máx | Remuneração | Base Legal |
|--------|------|----------|-------------|------------|
| LM | Licença Médica | 15/INSS | 100% até 15d | Art. 59 Lei 8.213/91 |
| LMA | Licença Maternidade | 120-180 | 100% | Art. 7º CF/88 |
| LPA | Licença Paternidade | 5-20 | 100% | Art. 10 ADCT |
| LP | Licença Prêmio | 90 | 100% | Estatuto Municipal |
| LTS | Licença Tratamento Saúde | Variável | % tabela | Estatuto |
| LAF | Licença Acomp. Familiar | 30-60 | 0-100% | Estatuto |
| LNR | Licença Nupcial | 8 | 100% | Estatuto |
| LNJ | Licença Nojo | 8 | 100% | Estatuto |
| LSR | Licença Serviço Militar | Variável | 0% | Lei 4.375/64 |
| LAC | Afastamento Acidente | Até alta | 100% | Lei 8.213/91 |
| SUS | Suspensão Disciplinar | Até 90 | 0% | Estatuto |
| FAL | Falta Justificada | 1 | 100% | Estatuto |
| FAI | Falta Injustificada | 1 | 0% | Estatuto |

---

## 2. MODELO DE DADOS

### 2.1 Entidade Principal: Afastamento

```java
@Entity
@Table(name = "afastamento")
public class Afastamento extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_afastamento", length = 10)
    private TipoAfastamento tipo;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "dias")
    private Integer dias;
    
    @Column(name = "cid", length = 10)
    private String cid; // CID-10 para licenças médicas
    
    @Column(name = "numero_processo", length = 30)
    private String numeroProcesso;
    
    @Column(name = "numero_beneficio_inss", length = 20)
    private String numeroBeneficioINSS;
    
    @Column(name = "data_pericia")
    private LocalDate dataPericia;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoAfastamento situacao; // ATIVO, ENCERRADO, PRORROGADO
    
    @Column(name = "percentual_remuneracao")
    private BigDecimal percentualRemuneracao; // 0 a 100
    
    @Column(name = "observacao", length = 500)
    private String observacao;
    
    // Campos de auditoria
    @Column(name = "usuario_cadastro_id")
    private Long usuarioCadastroId;
    
    @Column(name = "data_cadastro")
    private LocalDateTime dataCadastro;
}
```

### 2.2 Enum TipoAfastamento

```java
public enum TipoAfastamento {
    LM("Licença Médica", 15, true, BigDecimal.valueOf(100)),
    LMA("Licença Maternidade", 180, false, BigDecimal.valueOf(100)),
    LPA("Licença Paternidade", 20, false, BigDecimal.valueOf(100)),
    LP("Licença Prêmio", 90, false, BigDecimal.valueOf(100)),
    LTS("Licença Tratamento Saúde", 730, true, BigDecimal.valueOf(100)),
    LAF("Licença Acomp. Familiar", 60, true, BigDecimal.valueOf(66.67)),
    LNR("Licença Nupcial", 8, false, BigDecimal.valueOf(100)),
    LNJ("Licença Nojo", 8, false, BigDecimal.valueOf(100)),
    LSR("Licença Serviço Militar", 365, false, BigDecimal.ZERO),
    LAC("Afastamento Acidente", 730, true, BigDecimal.valueOf(100)),
    SUS("Suspensão Disciplinar", 90, false, BigDecimal.ZERO),
    FAL("Falta Justificada", 1, false, BigDecimal.valueOf(100)),
    FAI("Falta Injustificada", 1, false, BigDecimal.ZERO);
    
    private final String descricao;
    private final int diasMaximo;
    private final boolean exigePericia;
    private final BigDecimal percentualPadrao;
    
    // Construtor e getters
}
```

### 2.3 Enum SituacaoAfastamento

```java
public enum SituacaoAfastamento {
    SOLICITADO,    // Aguardando aprovação
    ATIVO,         // Em vigor
    PRORROGADO,    // Estendido com nova data fim
    ENCERRADO,     // Concluído normalmente
    CANCELADO,     // Cancelado antes do término
    CONVERTIDO_INSS // Passou responsabilidade ao INSS
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Licença Médica (LM)

```
REGRA LM-001: Responsabilidade do Pagamento
├── Dias 1-15: Município paga 100%
├── Dia 16+: INSS assume (auxílio-doença)
└── Servidor deve solicitar benefício INSS

REGRA LM-002: Perícia Médica
├── Obrigatória para licenças > 3 dias
├── Pode ser dispensada por atestado médico ≤ 3 dias
└── Junta Médica para > 15 dias consecutivos

REGRA LM-003: Prorrogação
├── Mesmo CID em 60 dias = continuação (soma dias)
├── CID diferente = nova licença
└── Atinge 15 dias acumulados = encaminha INSS
```

### 3.2 Licença Maternidade (LMA)

```
REGRA LMA-001: Duração
├── Padrão: 120 dias
├── Empresa Cidadã: +60 dias (180 total)
├── Parto antecipado: não reduz período
└── Natimorto/aborto: conforme laudo médico

REGRA LMA-002: Início
├── A partir 28 dias antes parto
├── Data do parto
└── Data da adoção/guarda judicial

REGRA LMA-003: Impacto na Folha
├── Salário integral mantido
├── 13º proporcional garantido
├── Férias: período aquisitivo conta normal
└── FGTS: depósito normal (se aplicável)
```

### 3.3 Licença Prêmio (LP)

```
REGRA LP-001: Aquisição
├── A cada 5 anos de efetivo exercício
├── Servidor efetivo/estável
└── Sem faltas injustificadas no período

REGRA LP-002: Gozo
├── 3 meses corridos OU
├── 3 períodos de 1 mês OU
├── Conversão em pecúnia (se previsto)
└── Não acumula mais de 2 períodos

REGRA LP-003: Interrupções que Suspendem Contagem
├── Licença sem remuneração
├── Suspensão disciplinar
├── Falta injustificada
└── Licença para tratar interesse particular
```

---

## 4. FLUXO DE PROCESSOS

### 4.1 Fluxo: Solicitar Afastamento

```
┌─────────────────────────────────────────────────────────┐
│                 SOLICITAR AFASTAMENTO                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Servidor/RH]                                          │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐                                        │
│  │ Preencher   │                                        │
│  │ Formulário  │                                        │
│  └──────┬──────┘                                        │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐    ┌──────────────┐                   │
│  │ Validar     │───►│ Documentação │                   │
│  │ Tipo        │    │ Necessária?  │                   │
│  └─────────────┘    └──────┬───────┘                   │
│                            │                            │
│              ┌─────────────┴─────────────┐             │
│              │                           │              │
│              ▼                           ▼              │
│       ┌───────────┐              ┌───────────┐         │
│       │ Atestado  │              │ Certidão  │         │
│       │ Médico    │              │ Casamento │         │
│       │ CID-10    │              │ Óbito     │         │
│       └─────┬─────┘              └─────┬─────┘         │
│             │                          │               │
│             └──────────┬───────────────┘               │
│                        ▼                               │
│                 ┌─────────────┐                        │
│                 │ Criar       │                        │
│                 │ Afastamento │                        │
│                 │ SOLICITADO  │                        │
│                 └──────┬──────┘                        │
│                        │                               │
│                        ▼                               │
│                 ┌─────────────┐                        │
│                 │ Aprovação   │                        │
│                 │ RH/Chefia   │                        │
│                 └──────┬──────┘                        │
│                        │                               │
│           ┌────────────┴────────────┐                  │
│           │                         │                  │
│           ▼                         ▼                  │
│    ┌───────────┐            ┌───────────┐             │
│    │ APROVADO  │            │ REJEITADO │             │
│    │ Status:   │            │ Notifica  │             │
│    │ ATIVO     │            │ Servidor  │             │
│    └───────────┘            └───────────┘             │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 4.2 Fluxo: Impacto na Folha

```
┌─────────────────────────────────────────────────────────┐
│           PROCESSAR AFASTAMENTOS NA FOLHA               │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ProcessamentoFolhaService.processarServidor()          │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────┐                               │
│  │ Buscar Afastamentos │                               │
│  │ Ativos no Período   │                               │
│  └──────────┬──────────┘                               │
│             │                                          │
│             ▼                                          │
│  ┌─────────────────────┐                               │
│  │ Para cada           │                               │
│  │ Afastamento:        │                               │
│  └──────────┬──────────┘                               │
│             │                                          │
│             ▼                                          │
│  ┌─────────────────────┐                               │
│  │ Calcular dias no    │                               │
│  │ mês de referência   │                               │
│  └──────────┬──────────┘                               │
│             │                                          │
│             ▼                                          │
│  ┌─────────────────────────────────────────┐           │
│  │ Aplicar Percentual de Remuneração       │           │
│  │                                         │           │
│  │ diasAfastado = calcularDiasNoMes()      │           │
│  │ diasUteis = getDiasUteisMes()           │           │
│  │                                         │           │
│  │ if (tipo.percentual < 100) {            │           │
│  │   valorDesconto = salarioBase *         │           │
│  │     (diasAfastado/diasUteis) *          │           │
│  │     (1 - percentual/100)                │           │
│  │   criarRubricaDesconto(A50, valor)      │           │
│  │ }                                       │           │
│  └──────────┬──────────────────────────────┘           │
│             │                                          │
│             ▼                                          │
│  ┌─────────────────────┐                               │
│  │ Gerar Rubrica       │                               │
│  │ Informativa (A51)   │                               │
│  │ "Afastamento: XX d" │                               │
│  └─────────────────────┘                               │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 5. SERVIÇOS E MÉTODOS

### 5.1 AfastamentoService

```java
@Service
@Transactional
public class AfastamentoService extends AbstractTenantService {
    
    // Criar novo afastamento
    public Afastamento criar(AfastamentoRequest request);
    
    // Aprovar afastamento solicitado
    public Afastamento aprovar(Long id, Long aprovadorId);
    
    // Rejeitar afastamento
    public Afastamento rejeitar(Long id, String motivo);
    
    // Prorrogar afastamento existente
    public Afastamento prorrogar(Long id, LocalDate novaDataFim);
    
    // Encerrar afastamento antecipadamente
    public Afastamento encerrar(Long id, LocalDate dataRetorno);
    
    // Converter para benefício INSS
    public Afastamento converterParaINSS(Long id, String numeroBeneficio);
    
    // Buscar afastamentos ativos de um vínculo
    public List<Afastamento> buscarAtivos(Long vinculoId);
    
    // Buscar afastamentos no período (para folha)
    public List<Afastamento> buscarPorPeriodo(
        Long vinculoId, LocalDate inicio, LocalDate fim);
    
    // Calcular dias afastados no mês
    public int calcularDiasNoMes(Afastamento afast, YearMonth mes);
    
    // Verificar se pode tirar licença prêmio
    public boolean verificarDireitoLicencaPremio(Long vinculoId);
    
    // Calcular saldo licença prêmio
    public LicencaPremioSaldo calcularSaldoLP(Long vinculoId);
}
```

### 5.2 Métodos de Cálculo

```java
// Calcular dias de afastamento no mês
public int calcularDiasNoMes(Afastamento afast, YearMonth competencia) {
    LocalDate inicioMes = competencia.atDay(1);
    LocalDate fimMes = competencia.atEndOfMonth();
    
    LocalDate inicioCalc = afast.getDataInicio().isBefore(inicioMes) 
        ? inicioMes : afast.getDataInicio();
    
    LocalDate fimCalc = (afast.getDataFim() == null || 
                         afast.getDataFim().isAfter(fimMes))
        ? fimMes : afast.getDataFim();
    
    return (int) ChronoUnit.DAYS.between(inicioCalc, fimCalc) + 1;
}

// Calcular desconto por afastamento sem remuneração
public BigDecimal calcularDesconto(
    Afastamento afast, 
    BigDecimal salarioBase, 
    YearMonth competencia
) {
    int diasAfastado = calcularDiasNoMes(afast, competencia);
    int diasMes = competencia.lengthOfMonth();
    
    BigDecimal percentualDesconto = BigDecimal.valueOf(100)
        .subtract(afast.getPercentualRemuneracao())
        .divide(BigDecimal.valueOf(100));
    
    return salarioBase
        .multiply(BigDecimal.valueOf(diasAfastado))
        .divide(BigDecimal.valueOf(diasMes), 2, RoundingMode.HALF_UP)
        .multiply(percentualDesconto);
}
```

---

## 6. ENDPOINTS DA API

### 6.1 AfastamentoController

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| POST | `/api/afastamentos` | Criar afastamento | ANALISTA+ |
| GET | `/api/afastamentos/{id}` | Buscar por ID | USUARIO+ |
| GET | `/api/afastamentos/vinculo/{vinculoId}` | Listar por vínculo | USUARIO+ |
| GET | `/api/afastamentos/ativos` | Listar ativos | ANALISTA+ |
| PUT | `/api/afastamentos/{id}/aprovar` | Aprovar | GESTOR+ |
| PUT | `/api/afastamentos/{id}/rejeitar` | Rejeitar | GESTOR+ |
| PUT | `/api/afastamentos/{id}/prorrogar` | Prorrogar | ANALISTA+ |
| PUT | `/api/afastamentos/{id}/encerrar` | Encerrar | ANALISTA+ |
| GET | `/api/afastamentos/licenca-premio/{vinculoId}` | Saldo LP | USUARIO+ |

---

## 7. INTEGRAÇÃO COM FOLHA

### 7.1 Rubricas Relacionadas

| Código | Rubrica | Tipo | Descrição |
|--------|---------|------|-----------|
| A50 | DESC_AFASTAMENTO | D | Desconto por afastamento s/ remuneração |
| A51 | INFO_AFASTAMENTO | I | Informativo dias afastados |
| A52 | SAL_MATERNIDADE | P | Salário Maternidade |
| A53 | AUX_DOENCA | P | Auxílio-doença (até 15 dias) |

### 7.2 Código de Integração

```java
// Em ProcessamentoFolhaService
private void processarAfastamentos(FolhaPagamentoDet det, 
                                   VinculoFuncional vinculo,
                                   YearMonth competencia) {
    List<Afastamento> afastamentos = afastamentoService
        .buscarPorPeriodo(vinculo.getId(), 
                         competencia.atDay(1), 
                         competencia.atEndOfMonth());
    
    int totalDiasAfastado = 0;
    BigDecimal totalDesconto = BigDecimal.ZERO;
    
    for (Afastamento afast : afastamentos) {
        int dias = afastamentoService.calcularDiasNoMes(afast, competencia);
        totalDiasAfastado += dias;
        
        if (afast.getPercentualRemuneracao()
                 .compareTo(BigDecimal.valueOf(100)) < 0) {
            BigDecimal desconto = afastamentoService
                .calcularDesconto(afast, det.getSalarioBase(), competencia);
            totalDesconto = totalDesconto.add(desconto);
        }
    }
    
    // Criar rubrica de desconto se houver
    if (totalDesconto.compareTo(BigDecimal.ZERO) > 0) {
        criarRubricaDesconto(det, "A50", totalDesconto);
    }
    
    // Criar rubrica informativa
    if (totalDiasAfastado > 0) {
        criarRubricaInformativa(det, "A51", 
            "Afastamento: " + totalDiasAfastado + " dia(s)");
    }
}
```

---

## 8. VALIDAÇÕES

### 8.1 Validações de Criação

```java
public void validarCriacaoAfastamento(AfastamentoRequest request) {
    // V1: Vínculo deve estar ativo
    VinculoFuncional vinculo = vinculoRepository
        .findById(request.getVinculoId())
        .orElseThrow();
    if (vinculo.getSituacao() != SituacaoCadastro.ATIVO) {
        throw new BusinessException("Vínculo não está ativo");
    }
    
    // V2: Data início não pode ser futura > 30 dias
    if (request.getDataInicio().isAfter(LocalDate.now().plusDays(30))) {
        throw new BusinessException("Data início muito distante");
    }
    
    // V3: Verificar sobreposição de períodos
    List<Afastamento> existentes = repository
        .findByVinculoAndPeriodo(request.getVinculoId(),
                                 request.getDataInicio(),
                                 request.getDataFim());
    if (!existentes.isEmpty()) {
        throw new BusinessException("Existe afastamento no período");
    }
    
    // V4: Validações específicas por tipo
    validarPorTipo(request);
}

private void validarPorTipo(AfastamentoRequest request) {
    switch (request.getTipo()) {
        case LM -> {
            if (request.getCid() == null) {
                throw new BusinessException("CID obrigatório para licença médica");
            }
        }
        case LMA -> {
            // Verificar se não há outra licença maternidade ativa
        }
        case LP -> {
            if (!verificarDireitoLicencaPremio(request.getVinculoId())) {
                throw new BusinessException("Servidor não tem direito a LP");
            }
        }
    }
}
```

---

## 9. RELATÓRIOS

### 9.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| REL_AFASTAMENTOS_PERIODO | Afastamentos no período | dataInicio, dataFim, tipo |
| REL_LICENCAS_VENCER | Licenças a vencer | dias |
| REL_SALDO_LP | Saldo de Licença Prêmio | - |
| REL_AFASTADOS_ATUAL | Servidores afastados hoje | - |

---

## 10. STAKEHOLDERS E PERMISSÕES

### 10.1 Matriz de Responsabilidades

| Ação | USUARIO | ANALISTA | GESTOR | ADMIN |
|------|---------|----------|--------|-------|
| Visualizar próprios afastamentos | ✅ | ✅ | ✅ | ✅ |
| Solicitar afastamento | ❌ | ✅ | ✅ | ✅ |
| Aprovar/Rejeitar | ❌ | ❌ | ✅ | ✅ |
| Prorrogar/Encerrar | ❌ | ✅ | ✅ | ✅ |
| Converter p/ INSS | ❌ | ✅ | ✅ | ✅ |
| Configurar tipos | ❌ | ❌ | ❌ | ✅ |

---

**Próximo Documento:** PARTE 7 - Rescisões e Desligamentos
