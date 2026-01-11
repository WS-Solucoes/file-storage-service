# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 7
## Módulo de Rescisões e Desligamentos

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar todo o processo de desligamento de servidores municipais, incluindo cálculo de verbas rescisórias, controle de documentação e geração de obrigações legais.

### 1.2 Tipos de Desligamento

| Código | Tipo | Aplicável a | Verbas Rescisórias |
|--------|------|-------------|-------------------|
| EXO | Exoneração a Pedido | Efetivo/Comissão | Férias + 13º prop. |
| EXD | Exoneração de Ofício | Comissão | Férias + 13º prop. |
| DEM | Demissão | Efetivo (PAD) | Férias vencidas |
| APO | Aposentadoria | Efetivo | Férias + 13º + LP |
| FAL | Falecimento | Todos | Pensão + verbas |
| TCC | Término Contrato | Temporário | Férias + 13º prop. |
| RES | Rescisão Contrato | Temporário | Proporcional |
| CAS | Cassação | Efetivo | Nenhuma |
| REV | Reversão | Aposentado | - |
| RED | Redistribuição | Efetivo | - (transferência) |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: Desligamento

```java
@Entity
@Table(name = "desligamento")
public class Desligamento extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_desligamento", length = 10)
    private TipoDesligamento tipo;
    
    @Column(name = "data_desligamento", nullable = false)
    private LocalDate dataDesligamento;
    
    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;
    
    @Column(name = "numero_ato", length = 50)
    private String numeroAto; // Decreto/Portaria
    
    @Column(name = "motivo", length = 500)
    private String motivo;
    
    @Column(name = "numero_processo_pad", length = 30)
    private String numeroProcessoPAD; // Para demissão
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoDesligamento situacao;
    
    // Valores calculados
    @Column(name = "valor_ferias_vencidas", precision = 15, scale = 2)
    private BigDecimal valorFeriasVencidas;
    
    @Column(name = "valor_ferias_proporcionais", precision = 15, scale = 2)
    private BigDecimal valorFeriasProporcionais;
    
    @Column(name = "valor_13_proporcional", precision = 15, scale = 2)
    private BigDecimal valor13Proporcional;
    
    @Column(name = "valor_licenca_premio", precision = 15, scale = 2)
    private BigDecimal valorLicencaPremio;
    
    @Column(name = "valor_total_rescisao", precision = 15, scale = 2)
    private BigDecimal valorTotalRescisao;
    
    @Column(name = "data_pagamento")
    private LocalDate dataPagamento;
}
```

### 2.2 Enum TipoDesligamento

```java
public enum TipoDesligamento {
    EXO("Exoneração a Pedido", true, true, true, false),
    EXD("Exoneração de Ofício", true, true, true, false),
    DEM("Demissão", true, false, false, false),
    APO("Aposentadoria", true, true, true, true),
    FAL("Falecimento", true, true, true, true),
    TCC("Término Contrato", true, true, true, false),
    RES("Rescisão Contrato", true, true, false, false),
    CAS("Cassação", false, false, false, false),
    REV("Reversão", false, false, false, false),
    RED("Redistribuição", false, false, false, false);
    
    private final String descricao;
    private final boolean pagaFeriasVencidas;
    private final boolean pagaFeriasProporcionais;
    private final boolean paga13Proporcional;
    private final boolean pagaLicencaPremio;
    
    // Construtor e getters
}
```

### 2.3 Enum SituacaoDesligamento

```java
public enum SituacaoDesligamento {
    RASCUNHO,      // Em preenchimento
    AGUARDANDO,    // Aguardando publicação
    PUBLICADO,     // Ato publicado
    CALCULADO,     // Verbas calculadas
    PAGO,          // Rescisão paga
    CONCLUIDO,     // Processo finalizado
    CANCELADO      // Desligamento cancelado
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Exoneração a Pedido (EXO)

```
REGRA EXO-001: Requisitos
├── Servidor solicita por escrito
├── Não pode haver débito com município
└── Aviso prévio de 30 dias (dispensável)

REGRA EXO-002: Verbas Devidas
├── Férias vencidas + 1/3
├── Férias proporcionais + 1/3
├── 13º salário proporcional
└── Saldo de salário

REGRA EXO-003: Cálculo Proporcional
├── Férias: (meses trabalhados/12) * remuneração
├── 13º: (meses trabalhados/12) * remuneração
└── Mês com ≥15 dias = mês integral
```

### 3.2 Demissão por PAD (DEM)

```
REGRA DEM-001: Requisitos
├── Conclusão de Processo Administrativo Disciplinar
├── Decisão de autoridade competente
├── Publicação de ato de demissão
└── Trânsito em julgado (recursos esgotados)

REGRA DEM-002: Verbas Devidas
├── Apenas férias vencidas (se houver)
├── NÃO paga férias proporcionais
├── NÃO paga 13º proporcional
└── NÃO paga licença prêmio

REGRA DEM-003: Efeitos
├── Proibição de nova posse por 5 anos
├── Anotação na ficha funcional
└── Comunicação aos órgãos competentes
```

### 3.3 Aposentadoria (APO)

```
REGRA APO-001: Tipos de Aposentadoria
├── Voluntária por tempo de contribuição
├── Voluntária por idade
├── Compulsória (75 anos)
├── Por invalidez permanente
└── Especial (atividades de risco)

REGRA APO-002: Verbas Devidas
├── Férias vencidas + 1/3
├── Férias proporcionais + 1/3
├── 13º salário proporcional
├── Licença prêmio não gozada (em pecúnia)
└── Abono de permanência (se aplicável)

REGRA APO-003: Prazo
├── Publicação da aposentadoria
├── Último dia de exercício
├── Início do benefício no dia seguinte
└── Pagamento verbas em até 10 dias
```

### 3.4 Falecimento (FAL)

```
REGRA FAL-001: Documentação
├── Certidão de óbito
├── Documentos dos dependentes
└── Inventário/Alvará judicial (se necessário)

REGRA FAL-002: Verbas aos Dependentes
├── Férias vencidas + 1/3
├── Férias proporcionais + 1/3
├── 13º salário proporcional
├── Licença prêmio em pecúnia
├── Saldo de salário
└── Pensão por morte (previdência)

REGRA FAL-003: Beneficiários
├── Cônjuge/Companheiro(a)
├── Filhos menores de 21 anos
├── Filhos inválidos (qualquer idade)
├── Pais (se dependiam economicamente)
└── Conforme ordem preferencial
```

---

## 4. CÁLCULO DE VERBAS RESCISÓRIAS

### 4.1 Fórmulas de Cálculo

```java
@Service
public class CalculoRescisaoService {
    
    /**
     * Calcula férias vencidas
     * Um período completo = 30 dias
     */
    public BigDecimal calcularFeriasVencidas(VinculoFuncional vinculo) {
        // Buscar períodos aquisitivos completos não gozados
        List<PeriodoFerias> periodosVencidos = feriasService
            .buscarPeriodosVencidos(vinculo.getId());
        
        BigDecimal remuneracao = vinculo.getRemuneracaoAtual();
        BigDecimal tercoConstitucional = remuneracao
            .divide(BigDecimal.valueOf(3), 2, RoundingMode.HALF_UP);
        
        BigDecimal total = BigDecimal.ZERO;
        for (PeriodoFerias periodo : periodosVencidos) {
            int diasDevidos = periodo.getDiasDireito() - periodo.getDiasGozados();
            BigDecimal valorPeriodo = remuneracao
                .multiply(BigDecimal.valueOf(diasDevidos))
                .divide(BigDecimal.valueOf(30), 2, RoundingMode.HALF_UP);
            BigDecimal terco = valorPeriodo.divide(BigDecimal.valueOf(3), 2, RoundingMode.HALF_UP);
            total = total.add(valorPeriodo).add(terco);
        }
        return total;
    }
    
    /**
     * Calcula férias proporcionais
     * Proporcional ao tempo trabalhado no período aquisitivo atual
     */
    public BigDecimal calcularFeriasProporcionais(
            VinculoFuncional vinculo, 
            LocalDate dataDesligamento) {
        
        PeriodoFerias periodoAtual = feriasService
            .buscarPeriodoAquisitivoAtual(vinculo.getId());
        
        // Meses trabalhados no período atual
        int meses = calcularMesesTrabalhados(
            periodoAtual.getDataInicio(), 
            dataDesligamento);
        
        // Proporção: meses/12 * remuneração
        BigDecimal remuneracao = vinculo.getRemuneracaoAtual();
        BigDecimal proporcao = BigDecimal.valueOf(meses)
            .divide(BigDecimal.valueOf(12), 4, RoundingMode.HALF_UP);
        
        BigDecimal ferias = remuneracao.multiply(proporcao)
            .setScale(2, RoundingMode.HALF_UP);
        BigDecimal terco = ferias.divide(BigDecimal.valueOf(3), 2, RoundingMode.HALF_UP);
        
        return ferias.add(terco);
    }
    
    /**
     * Calcula 13º proporcional
     */
    public BigDecimal calcular13Proporcional(
            VinculoFuncional vinculo, 
            LocalDate dataDesligamento) {
        
        int meses = calcularMesesTrabalhados(
            LocalDate.of(dataDesligamento.getYear(), 1, 1),
            dataDesligamento);
        
        BigDecimal remuneracao = vinculo.getRemuneracaoAtual();
        
        return remuneracao
            .multiply(BigDecimal.valueOf(meses))
            .divide(BigDecimal.valueOf(12), 2, RoundingMode.HALF_UP);
    }
    
    /**
     * Calcula licença prêmio em pecúnia
     */
    public BigDecimal calcularLicencaPremio(VinculoFuncional vinculo) {
        LicencaPremioSaldo saldo = licencaPremioService
            .calcularSaldo(vinculo.getId());
        
        // Cada período = 90 dias = 3 meses de remuneração
        BigDecimal remuneracao = vinculo.getRemuneracaoAtual();
        int diasDevidos = saldo.getDiasDisponiveis();
        
        return remuneracao
            .multiply(BigDecimal.valueOf(diasDevidos))
            .divide(BigDecimal.valueOf(30), 2, RoundingMode.HALF_UP);
    }
    
    /**
     * Meses trabalhados (≥15 dias = mês completo)
     */
    private int calcularMesesTrabalhados(LocalDate inicio, LocalDate fim) {
        int meses = 0;
        LocalDate data = inicio;
        
        while (!data.isAfter(fim)) {
            LocalDate fimMes = data.withDayOfMonth(data.lengthOfMonth());
            LocalDate dataFim = fimMes.isAfter(fim) ? fim : fimMes;
            
            int diasNoMes = (int) ChronoUnit.DAYS.between(data, dataFim) + 1;
            if (diasNoMes >= 15) {
                meses++;
            }
            
            data = fimMes.plusDays(1);
        }
        return meses;
    }
}
```

### 4.2 Exemplo de Cálculo Completo

```
SERVIDOR: João da Silva
TIPO: Exoneração a Pedido
DATA ADMISSÃO: 01/03/2020
DATA DESLIGAMENTO: 15/08/2025
REMUNERAÇÃO: R$ 5.000,00

┌──────────────────────────────────────────────────────────┐
│              CÁLCULO VERBAS RESCISÓRIAS                  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│ 1. FÉRIAS VENCIDAS                                       │
│    Períodos: 2020/2021, 2021/2022, 2022/2023, 2023/2024 │
│    Gozados: 2020/2021, 2021/2022                        │
│    Vencidos: 2 períodos = 60 dias                       │
│    Valor: 5.000 * (60/30) = R$ 10.000,00               │
│    Terço: R$ 3.333,33                                   │
│    TOTAL FÉRIAS VENCIDAS: R$ 13.333,33                  │
│                                                          │
│ 2. FÉRIAS PROPORCIONAIS                                  │
│    Período: 01/03/2024 a 15/08/2025                     │
│    Meses trabalhados: 17 meses = 12 (teto)              │
│    Valor: 5.000 * (5/12) = R$ 2.083,33                  │
│    (5 meses em 2025: mar, abr, mai, jun, jul, ago)      │
│    Terço: R$ 694,44                                     │
│    TOTAL FÉRIAS PROPORCIONAIS: R$ 2.777,77              │
│                                                          │
│ 3. 13º PROPORCIONAL                                      │
│    Meses em 2025: jan-ago = 8 meses                     │
│    Valor: 5.000 * (8/12) = R$ 3.333,33                  │
│                                                          │
│ 4. SALDO DE SALÁRIO                                      │
│    Dias trabalhados agosto: 15 dias                     │
│    Valor: 5.000 * (15/31) = R$ 2.419,35                 │
│                                                          │
├──────────────────────────────────────────────────────────┤
│ TOTAL BRUTO: R$ 21.863,78                                │
├──────────────────────────────────────────────────────────┤
│ DESCONTOS:                                               │
│ - IRRF sobre 13º: R$ 0,00 (isento)                      │
│ - IRRF sobre férias: R$ 0,00 (isento)                   │
│ - Previdência: proporcional                             │
├──────────────────────────────────────────────────────────┤
│ TOTAL LÍQUIDO: R$ 21.xxx,xx                             │
└──────────────────────────────────────────────────────────┘
```

---

## 5. FLUXO DO PROCESSO

### 5.1 Fluxo: Desligamento

```
┌─────────────────────────────────────────────────────────┐
│                PROCESSO DE DESLIGAMENTO                 │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [1] INICIAR DESLIGAMENTO                              │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐                                        │
│  │ Selecionar  │                                        │
│  │ Servidor    │                                        │
│  └──────┬──────┘                                        │
│         │                                               │
│         ▼                                               │
│  ┌─────────────┐    ┌──────────────────┐               │
│  │ Informar    │───►│ Validar          │               │
│  │ Tipo        │    │ Requisitos       │               │
│  └─────────────┘    └────────┬─────────┘               │
│                              │                          │
│                   ┌──────────┴──────────┐              │
│                   │                     │               │
│                   ▼                     ▼               │
│            ┌───────────┐         ┌───────────┐         │
│            │ PAD?      │         │ Voluntário│         │
│            │ Informar  │         │ Pedido    │         │
│            │ Processo  │         │ Escrito   │         │
│            └─────┬─────┘         └─────┬─────┘         │
│                  │                     │                │
│                  └──────────┬──────────┘               │
│                             │                          │
│                             ▼                          │
│  [2] PREPARAR DOCUMENTAÇÃO                             │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ Gerar documentos:                   │              │
│  │ - Portaria/Decreto                  │              │
│  │ - Termo de Rescisão                 │              │
│  │ - Ficha Funcional atualizada        │              │
│  └──────────────────┬──────────────────┘              │
│                     │                                  │
│                     ▼                                  │
│  [3] CALCULAR VERBAS                                   │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ CalculoRescisaoService              │              │
│  │ - Férias vencidas                   │              │
│  │ - Férias proporcionais              │              │
│  │ - 13º proporcional                  │              │
│  │ - Licença prêmio                    │              │
│  │ - Descontos                         │              │
│  └──────────────────┬──────────────────┘              │
│                     │                                  │
│                     ▼                                  │
│  [4] PUBLICAR ATO                                      │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ Status: PUBLICADO                   │              │
│  │ Data publicação: xx/xx/xxxx         │              │
│  └──────────────────┬──────────────────┘              │
│                     │                                  │
│                     ▼                                  │
│  [5] EFETUAR PAGAMENTO                                 │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ Gerar folha rescisória              │              │
│  │ Status: PAGO                        │              │
│  └──────────────────┬──────────────────┘              │
│                     │                                  │
│                     ▼                                  │
│  [6] FINALIZAR                                         │
│       │                                                │
│       ▼                                                │
│  ┌─────────────────────────────────────┐              │
│  │ - Inativar vínculo                  │              │
│  │ - Gerar eventos eSocial             │              │
│  │ - Atualizar RAIS/DIRF               │              │
│  │ - Status: CONCLUIDO                 │              │
│  └─────────────────────────────────────┘              │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 6. SERVIÇOS E MÉTODOS

### 6.1 DesligamentoService

```java
@Service
@Transactional
public class DesligamentoService extends AbstractTenantService {
    
    // Criar desligamento
    public Desligamento criar(DesligamentoRequest request);
    
    // Calcular verbas rescisórias
    public Desligamento calcularVerbas(Long id);
    
    // Publicar ato de desligamento
    public Desligamento publicar(Long id, String numeroAto, LocalDate dataPublicacao);
    
    // Efetuar pagamento das verbas
    public Desligamento efetuarPagamento(Long id, LocalDate dataPagamento);
    
    // Finalizar processo
    public Desligamento finalizar(Long id);
    
    // Cancelar desligamento
    public Desligamento cancelar(Long id, String motivo);
    
    // Gerar termo de rescisão
    public byte[] gerarTermoRescisao(Long id);
    
    // Buscar por vínculo
    public Optional<Desligamento> buscarPorVinculo(Long vinculoId);
    
    // Listar pendentes de pagamento
    public List<Desligamento> listarPendentesPagamento();
}
```

---

## 7. ENDPOINTS DA API

### 7.1 DesligamentoController

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| POST | `/api/desligamentos` | Criar desligamento | GESTOR+ |
| GET | `/api/desligamentos/{id}` | Buscar por ID | ANALISTA+ |
| PUT | `/api/desligamentos/{id}/calcular` | Calcular verbas | GESTOR+ |
| PUT | `/api/desligamentos/{id}/publicar` | Publicar ato | GESTOR+ |
| PUT | `/api/desligamentos/{id}/pagar` | Efetuar pagamento | GESTOR+ |
| PUT | `/api/desligamentos/{id}/finalizar` | Finalizar | GESTOR+ |
| DELETE | `/api/desligamentos/{id}` | Cancelar | ADMIN |
| GET | `/api/desligamentos/{id}/termo` | Gerar termo PDF | ANALISTA+ |

---

## 8. INTEGRAÇÃO eSocial

### 8.1 Eventos de Desligamento

| Evento | Descrição | Prazo |
|--------|-----------|-------|
| S-2299 | Desligamento | Até 10º dia mês seguinte |
| S-2298 | Reintegração | Quando aplicável |
| S-1200 | Remuneração (última) | Mês do desligamento |

### 8.2 Código S-2299

```java
public EsocialEvento gerarS2299(Desligamento deslig) {
    S2299 evento = new S2299();
    evento.setIdEvento(gerarIdEvento());
    evento.setCpf(deslig.getVinculo().getServidor().getCpf());
    evento.setMatricula(deslig.getVinculo().getMatricula());
    evento.setDataDesligamento(deslig.getDataDesligamento());
    evento.setMotivoDesligamento(mapearMotivo(deslig.getTipo()));
    
    // Verbas rescisórias
    if (deslig.getTipo().isPagaFeriasVencidas()) {
        evento.addVerba("1000", "FERIAS_VENCIDAS", 
            deslig.getValorFeriasVencidas());
    }
    // ... outras verbas
    
    return evento;
}
```

---

## 9. DOCUMENTOS GERADOS

### 9.1 Lista de Documentos

| Documento | Formato | Obrigatório |
|-----------|---------|-------------|
| Portaria/Decreto de Desligamento | PDF | Sim |
| Termo de Rescisão | PDF | Sim |
| Demonstrativo de Verbas | PDF | Sim |
| Ficha Funcional Atualizada | PDF | Não |
| Certidão de Tempo de Serviço | PDF | Se solicitado |

---

## 10. STAKEHOLDERS E PERMISSÕES

### 10.1 Matriz de Responsabilidades

| Ação | ANALISTA | GESTOR | ADMIN |
|------|----------|--------|-------|
| Visualizar desligamentos | ✅ | ✅ | ✅ |
| Criar desligamento | ❌ | ✅ | ✅ |
| Calcular verbas | ❌ | ✅ | ✅ |
| Publicar ato | ❌ | ✅ | ✅ |
| Efetuar pagamento | ❌ | ✅ | ✅ |
| Cancelar desligamento | ❌ | ❌ | ✅ |

---

**Próximo Documento:** PARTE 8 - Integração eSocial
