# eFrotas — Plano de Aprimoramento e Automação

> **Versão:** 1.0 | **Data:** 23/02/2026 | **Objetivo:** Transformar o eFrotas em um sistema completo e competitivo para gestão de frotas municipais, pronto para mercado

---

## Sumário

1. [Diagnóstico do Sistema Atual](#1-diagnóstico-do-sistema-atual)
2. [Módulo 1 — Automação de Controle de Combustível](#2-módulo-1--automação-de-controle-de-combustível)
3. [Módulo 2 — Automação de Manutenção Preventiva e Corretiva](#3-módulo-2--automação-de-manutenção-preventiva-e-corretiva)
4. [Módulo 3 — Gestão Inteligente de Rotas e GPS](#4-módulo-3--gestão-inteligente-de-rotas-e-gps)
5. [Módulo 4 — Gestão de CNH e Documentação](#5-módulo-4--gestão-de-cnh-e-documentação)
6. [Módulo 5 — Controle de Pneus e Patrimônio](#6-módulo-5--controle-de-pneus-e-patrimônio)
7. [Módulo 6 — Dashboard Inteligente e KPIs](#7-módulo-6--dashboard-inteligente-e-kpis)
8. [Módulo 7 — Relatórios para Tribunal de Contas](#8-módulo-7--relatórios-para-tribunal-de-contas)
9. [Módulo 8 — Notificações e Alertas Automáticos](#9-módulo-8--notificações-e-alertas-automáticos)
10. [Módulo 9 — App Mobile para Motoristas](#10-módulo-9--app-mobile-para-motoristas)
11. [Módulo 10 — Integrações Externas](#11-módulo-10--integrações-externas)
12. [Módulo 11 — Auditoria e Compliance](#12-módulo-11--auditoria-e-compliance)
13. [Módulo 12 — Gestão de Seguros e Sinistros](#13-módulo-12--gestão-de-seguros-e-sinistros)
14. [Correções e Melhorias Técnicas Imediatas](#14-correções-e-melhorias-técnicas-imediatas)
15. [Roadmap de Implementação](#15-roadmap-de-implementação)
16. [Estimativa de Esforço](#16-estimativa-de-esforço)

---

## 1. Diagnóstico do Sistema Atual

### Pontos Fortes ✅

| Aspecto | Avaliação |
|---------|-----------|
| Arquitetura multi-tenant | Excelente — permite atender múltiplos municípios com isolamento de dados |
| Soft delete | Implementado em todas as entidades — rastreabilidade total |
| Fluxo de aprovação | Requisições de abastecimento e manutenção com workflow de aprovação |
| Relatórios PDF | 14 templates JasperReports para diversas necessidades |
| Transporte escolar | Módulo completo com contratos, rotas, percursos e custos |
| Frontend padronizado | Hook `useCrudPage` reduz código duplicado significativamente |
| Auditoria | `@SalvarLog` em todos os endpoints de escrita |

### Lacunas e Oportunidades 🔴

| # | Lacuna | Impacto | Prioridade |
|---|--------|---------|-----------|
| 1 | Sem manutenção preventiva automática | Veículos quebram sem aviso — custo alto | 🔴 Alta |
| 2 | Sem controle real de km/consumo médio | Impossível detectar fraudes em combustível | 🔴 Alta |
| 3 | Sem GPS/telemetria | Não há controle de uso real dos veículos | 🟡 Média |
| 4 | Sem alertas automáticos | CNHs vencem, seguros expiram, manutenções atrasam | 🔴 Alta |
| 5 | Sem controle de pneus | Pneus são um dos maiores custos operacionais | 🟡 Média |
| 6 | Relatórios para TC incompletos | Tribunal de Contas exige dados específicos | 🔴 Alta |
| 7 | Sem gestão de seguros/sinistros | Lacuna operacional importante | 🟡 Média |
| 8 | Dashboard básico | Falta KPIs estratégicos e comparativos | 🟡 Média |
| 9 | Sem app mobile | Motoristas não conseguem registrar dados em campo | 🟡 Média |
| 10 | Sem integração com sistemas externos | ANP, DETRAN, IBGE, etc. | 🟢 Baixa |
| 11 | Typo no endpoint vistoria (bistoria) | Bug funcional | 🔴 Alta |
| 12 | Campos tipo String para dados estruturados | tipoFrota, litrosKm devem ser Enum/Numeric | 🟡 Média |

---

## 2. Módulo 1 — Automação de Controle de Combustível

### 2.1 Cálculo Automático de Consumo Médio

**Problema atual:** O campo `litrosKm` do veículo é do tipo String e preenchido manualmente.

**Solução proposta:**

#### Backend

```java
// Nova entidade: HistoricoConsumo
@Entity
public class HistoricoConsumo extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    private Veiculo veiculo;
    
    private LocalDate data;
    private BigDecimal kmAnterior;        // km no abastecimento anterior
    private BigDecimal kmAtual;           // km neste abastecimento
    private BigDecimal kmPercorridos;     // calculado: kmAtual - kmAnterior
    private BigDecimal litrosAbastecidos;
    private BigDecimal consumoMedio;      // calculado: kmPercorridos / litros
    private BigDecimal custoKm;           // calculado: valorTotal / kmPercorridos
    
    @ManyToOne
    private RequisicaoAbastecimento requisicao;  // origem dos dados
}
```

#### Automações

| Automação | Trigger | Ação |
|-----------|---------|------|
| Calcular consumo | Ao concluir abastecimento (km final preenchido) | Calcular km/l automaticamente |
| Média móvel | A cada novo abastecimento | Atualizar média móvel de 5 abastecimentos |
| Alerta de desvio | Consumo > 20% acima da média | Gerar notificação de consumo anormal |
| Ranking veículos | Diário (agendado) | Ordenar veículos por eficiência |

### 2.2 Controle de Saldo de Contrato

**Problema atual:** Contratos registram litros totais mas não controlam saldo em tempo real.

```java
// Novo campo no Contrato
@Column(precision = 10, scale = 3)
private BigDecimal litrosConsumidos = BigDecimal.ZERO;

@Column(precision = 10, scale = 3)
private BigDecimal saldoLitros; // calculado: litros - litrosConsumidos

@Column(precision = 15, scale = 2)
private BigDecimal valorConsumido = BigDecimal.ZERO;

@Column(precision = 15, scale = 2)
private BigDecimal saldoValor; // calculado: valorTotal - valorConsumido
```

#### Automações

| Automação | Trigger | Ação |
|-----------|---------|------|
| Debitar contrato | Abastecimento concluído | Reduzir saldo de litros e valor |
| Alerta 20% restante | Saldo < 20% | Notificar gestor sobre contrato esgotando |
| Alerta 5% restante | Saldo < 5% | Notificar admin com urgência |
| Bloquear requisição | Saldo = 0 | Impedir novas requisições naquele contrato |
| Relatório mensal | Dia 1 de cada mês | Gerar balanço automático por contrato |

### 2.3 Detecção de Anomalias de Combustível

```java
// Novo Service: AnomaliaCombustivelService
public class AnomaliaCombustivelService {
    
    /**
     * Detecta: abastecimento acima do tanque, consumo fora do padrão,
     * abastecimentos muito frequentes, km incompatível
     */
    public List<AlertaAnomalia> verificarAnomalias(RequisicaoAbastecimento req) {
        // 1. Litros > capacidade do tanque
        // 2. Consumo médio < 50% ou > 150% da média histórica
        // 3. Dois abastecimentos no mesmo dia
        // 4. km final < km inicial
        // 5. km percorrido incompatível com litros
    }
}
```

#### Novo Modelo: AlertaAnomalia

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| tipoAnomalia | Enum | EXCESSO_LITROS, CONSUMO_ANORMAL, FREQUENCIA_ALTA, KM_INCOMPATIVEL |
| gravidade | Enum | BAIXA, MEDIA, ALTA, CRITICA |
| descricao | String | Descrição automática |
| requisicaoAbastecimento | FK | Req. que gerou o alerta |
| veiculo / motorista | FK | Envolvidos |
| resolvido | Boolean | Se já foi analisado |
| resolucaoDescricao | String | Descrição da resolução |
| resolvidoPor | Usuario | Quem analisou |

---

## 3. Módulo 2 — Automação de Manutenção Preventiva e Corretiva

### 3.1 Plano de Manutenção Preventiva

**Problema atual:** A manutenção é apenas corretiva. Não há agendamento automático.

```java
@Entity
public class PlanoManutencao extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String nome;               // Ex: "Troca de óleo"
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    private TipoIntervalo tipoIntervalo;  // KM, DIAS, AMBOS
    
    private Integer intervaloKm;           // A cada X km
    private Integer intervaloDias;         // A cada X dias
    
    @Enumerated(EnumType.STRING)
    private CategoriaManutencao categoria; // MOTOR, FREIOS, PNEUS, ELETRICA, etc.
    
    @Column(precision = 15, scale = 2)
    private BigDecimal custoEstimado;
    
    private Boolean ativo = true;
    
    @ManyToMany
    private List<Veiculo> veiculosAplicaveis;  // Quais veículos seguem este plano
}
```

```java
@Entity
public class AgendaManutencao extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private PlanoManutencao plano;
    
    @ManyToOne
    private Veiculo veiculo;
    
    private LocalDate dataPrevista;
    private BigDecimal kmPrevisto;
    
    @Enumerated(EnumType.STRING)
    private StatusAgenda status; // PENDENTE, EXECUTADA, ATRASADA, CANCELADA
    
    private LocalDate dataExecutada;
    private BigDecimal kmExecutado;
    
    @OneToOne
    private ManutencaoVeiculo manutencaoRealizada;
}
```

```java
public enum CategoriaManutencao {
    MOTOR("Motor e Filtros"),
    FREIOS("Sistema de Freios"),
    PNEUS("Pneus e Rodas"),
    ELETRICA("Sistema Elétrico"),
    SUSPENSAO("Suspensão"),
    TRANSMISSAO("Transmissão"),
    ARREFECIMENTO("Arrefecimento"),
    LATARIA("Lataria e Pintura"),
    REVISAO_GERAL("Revisão Geral"),
    OUTRO("Outro");
}
```

#### Automações

| Automação | Trigger | Ação |
|-----------|---------|------|
| Verificar km | A cada registro de viagem/abastecimento | Checar se algum plano atingiu intervalo de km |
| Verificar data | Job diário (00:01) | Checar planos com intervalo de dias |
| Gerar agenda | Quando plano é atingido | Criar registro em AgendaManutencao |
| Notificar 7 dias antes | Job diário | Alertar gestor sobre manutenções agendadas |
| Marcar atrasada | Data prevista < hoje e status PENDENTE | Mudar para ATRASADA e notificar admin |
| Gerar próxima | Manutenção concluída | Calcular e agendar próxima manutenção |

### 3.2 Histórico Completo por Veículo

```java
// Novo endpoint: GET /api/v1/veiculo/{id}/historico-manutencao
public class HistoricoManutencaoResponse {
    private Long veiculoId;
    private String placa;
    private BigDecimal custoTotalManutencao;
    private BigDecimal custoMedioMensal;
    private Integer totalManutencoes;
    private Integer manutencoesPendentes;
    private List<ManutencaoVeiculoResponse> manutencoes;
    private List<AgendaManutencaoResponse> agendasFuturas;
    private List<AgendaManutencaoResponse> agendasAtrasadas;
}
```

### 3.3 TCO — Total Cost of Ownership

```java
// Novo endpoint: GET /api/v1/veiculo/{id}/tco
public class TCOResponse {
    private Long veiculoId;
    private String placa;
    private BigDecimal custoAquisicao;
    private BigDecimal custoCombustivelTotal;
    private BigDecimal custoManutencaoTotal;
    private BigDecimal custoMultasTotal;
    private BigDecimal custoSeguroTotal;
    private BigDecimal custoPneusTotal;
    private BigDecimal custoTotalOperacional;    // soma de todos acima
    private BigDecimal custoKmRodado;            // custoTotal / kmRodados
    private BigDecimal depreciacao;
    private Integer kmTotalRodados;
    private Map<String, BigDecimal> custosMensais; // últimos 12 meses
}
```

---

## 4. Módulo 3 — Gestão Inteligente de Rotas e GPS

### 4.1 Rastreamento em Tempo Real

**Status atual:** Menu GPS desabilitado, sem implementação.

#### Modelo de Dados

```java
@Entity
public class PosicaoGPS extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Veiculo veiculo;
    
    private LocalDateTime dataHora;
    private Double latitude;
    private Double longitude;
    private Double velocidade;       // km/h
    private Double altitude;
    private Boolean ignicaoLigada;
    private String endereco;         // geocodificação reversa
    
    @Column(columnDefinition = "geometry(Point,4326)")
    private Point localizacao;       // PostGIS
}
```

```java
@Entity
public class EventoGPS extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Veiculo veiculo;
    
    @Enumerated(EnumType.STRING)
    private TipoEventoGPS tipo;  // EXCESSO_VELOCIDADE, FREIADA_BRUSCA, 
                                  // DESVIO_ROTA, PARADA_NAO_AUTORIZADA,
                                  // IGNICAO_LIGADA_PARADO, CERCA_VIRTUAL
    
    private LocalDateTime dataHora;
    private Double latitude;
    private Double longitude;
    private String descricao;
    private Boolean analisado;
}
```

#### Funcionalidades

| Feature | Descrição |
|---------|-----------|
| **Mapa em tempo real** | Visualizar todos os veículos da frota no mapa |
| **Histórico de percurso** | Replay do trajeto de um veículo em período |
| **Cercas virtuais** | Definir áreas permitidas/proibidas no mapa |
| **Alertas de velocidade** | Configurar limite por via/zona |
| **Desvio de rota** | Alertar quando veículo sai do trajeto planejado |
| **Tempo parado** | Detectar veículos parados com motor ligado |
| **Relatório de percurso** | Km reais vs km declarados |

### 4.2 Otimização de Rotas

```java
@Entity
public class RotaOtimizada extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Rota rotaOriginal;
    
    private Double distanciaOriginalKm;
    private Double distanciaOtimizadaKm;
    private Double economiaKm;            // percentual
    private Integer tempoEstimadoMin;
    private LocalDate dataCalculo;
    
    @Column(columnDefinition = "geometry(LineString,4326)")
    private LineString percursoOtimizado;  // PostGIS
    
    @ElementCollection
    @OrderColumn
    private List<String> pontosOrdemOtimizada;
}
```

---

## 5. Módulo 4 — Gestão de CNH e Documentação

### 5.1 Controle de Documentos de Veículos

```java
@Entity
public class DocumentoVeiculo extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Veiculo veiculo;
    
    @Enumerated(EnumType.STRING)
    private TipoDocumentoVeiculo tipo; // CRLV, IPVA, SEGURO, LICENCIAMENTO, 
                                        // LAUDO_VISTORIA, AUTORIZACAO_TRANSPORTE
    
    private String numero;
    private LocalDate dataEmissao;
    private LocalDate dataVencimento;
    private String arquivo;             // URL do arquivo digitalizado
    
    @Enumerated(EnumType.STRING)
    private StatusDocumento status;     // VIGENTE, VENCIDO, PENDENTE
    
    private Integer diasParaVencer;     // calculado automaticamente
}
```

### 5.2 Controle de CNH Avançado

```java
// Adicionar campos ao Motorista
private Integer pontosCarteira = 0;
private LocalDate dataUltimaInfracao;

@Enumerated(EnumType.STRING)
private StatusCNH statusCNH; // ATIVA, SUSPENSA, CASSADA, VENCIDA

@OneToMany(mappedBy = "motorista")
private List<ExameMotorista> exames;
```

```java
@Entity
public class ExameMotorista extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Motorista motorista;
    
    @Enumerated(EnumType.STRING)
    private TipoExame tipo; // TOXICOLOGICO, APTIDAO_FISICA, APTIDAO_MENTAL
    
    private LocalDate dataRealizacao;
    private LocalDate dataValidade;
    private String resultado;        // APTO, INAPTO
    private String laboratorio;
    private String arquivo;          // URL laudo digitalizado
}
```

#### Automações

| Automação | Trigger | Ação |
|-----------|---------|------|
| CNH 30 dias | Job diário | Notificar motorista e gestor |
| CNH 7 dias | Job diário | Notificar com urgência |
| CNH vencida | Job diário | Bloquear motorista de novas viagens |
| Exame toxicológico | Job diário | Alertar 60 dias antes do vencimento |
| Pontuação acumulada | A cada multa registrada | Somar pontos e alertar se > 20 |
| CRLV/IPVA vencendo | Job diário | Alertar 30, 15 e 7 dias antes |

---

## 6. Módulo 5 — Controle de Pneus e Patrimônio

### 6.1 Gestão de Pneus

```java
@Entity
public class Pneu extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String codigoPneu;
    private String marca;
    private String modelo;
    private String medida;              // Ex: 195/65 R15
    private String dot;                 // Código DOT (data fabricação)
    
    @ManyToOne
    private Veiculo veiculoAtual;       // null se em estoque
    
    private String posicaoAtual;        // DD, DE, TD, TE, ESTEPE
    private LocalDate dataInstalacao;
    private BigDecimal kmInstalacao;
    private BigDecimal kmAtual;
    
    @Enumerated(EnumType.STRING)
    private StatusPneu status;          // EM_USO, ESTOQUE, RECAPAGEM, DESCARTADO
    
    private Integer recapagens = 0;
    private Integer limiteSulcoMm;
    private Integer sulcoAtualMm;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorCompra;
    
    @OneToMany(mappedBy = "pneu")
    private List<MovimentacaoPneu> movimentacoes;
}
```

```java
@Entity
public class MovimentacaoPneu extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Pneu pneu;
    
    @Enumerated(EnumType.STRING)
    private TipoMovimentacaoPneu tipo; // INSTALACAO, REMOCAO, RODIZIO, 
                                        // RECAPAGEM, DESCARTE, COMPRA
    
    @ManyToOne
    private Veiculo veiculoOrigem;
    @ManyToOne
    private Veiculo veiculoDestino;
    
    private String posicaoOrigem;
    private String posicaoDestino;
    private BigDecimal kmMovimentacao;
    private LocalDate data;
    private Integer sulcoMm;           // Medição no momento
    private String observacao;
}
```

### 6.2 Controle de Patrimônio (Acessórios/Equipamentos)

```java
@Entity
public class PatrimonioVeiculo extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Veiculo veiculo;
    
    private String codigo;
    private String descricao;
    private String numeroPatrimonio;
    
    @Enumerated(EnumType.STRING)
    private TipoPatrimonio tipo; // GPS_RASTREADOR, RADIO, EXTINTOR, 
                                  // MACACO, TRIANGULO, CHAVE_RODA, ESTEPE
    
    private LocalDate dataInstalacao;
    private LocalDate dataValidade;      // para extintor, etc.
    private String estado;               // BOM, REGULAR, RUIM
}
```

---

## 7. Módulo 6 — Dashboard Inteligente e KPIs

### 7.1 KPIs Estratégicos

**Problema atual:** Dashboard básico com apenas 4 gráficos genéricos.

**KPIs propostos:**

#### Painéis do Dashboard

| Painel | KPIs | Visualização |
|--------|------|-------------|
| **Resumo Geral** | Total veículos, ativos, em manutenção, parados | Cards com ícones |
| **Combustível** | Custo total mês, litros consumidos, custo médio/km, variação vs mês anterior | Cards + gráfico linha 12 meses |
| **Manutenção** | Custo total mês, manutenções pendentes, atrasadas, custo preventivo vs corretivo | Cards + gráfico pizza |
| **Eficiência** | km/l médio por veículo, ranking top 5 eficientes/ineficientes | Gráfico barras horizontal |
| **Multas** | Total multas mês, valor acumulado, motoristas com mais infrações | Cards + tabela top 5 |
| **Documentação** | CNHs vencendo 30 dias, CRLVs pendentes, seguros vencendo | Semáforo (verde/amarelo/vermelho) |
| **Contratos** | Saldo de contratos, contratos vencendo, consumo vs previsto | Gráfico gauge |
| **Anomalias** | Alertas não analisados, anomalias por tipo, tendência | Cards com gravidade |

#### Endpoint de Dashboard

```java
// GET /api/v1/dashboard/resumo
public class DashboardResumoResponse {
    // Frota
    private Integer totalVeiculos;
    private Integer veiculosAtivos;
    private Integer veiculosEmManutencao;
    private Integer veiculosParados;
    
    // Combustível (mês atual)
    private BigDecimal custoCombustivelMes;
    private BigDecimal litrosConsumidosMes;
    private BigDecimal custoMedioKm;
    private BigDecimal variacaoMesAnterior; // percentual
    
    // Manutenção
    private BigDecimal custoManutencaoMes;
    private Integer manutencoesPendentes;
    private Integer manutencoesAtrasadas;
    private BigDecimal percentualPreventiva;
    
    // Multas
    private Integer multasMes;
    private BigDecimal valorMultasMes;
    
    // Documentação
    private Integer cnhsVencendo30Dias;
    private Integer crlvsPendentes;
    private Integer segurosVencendo;
    
    // Alertas
    private Integer alertasNaoAnalisados;
    private Integer anomaliasCriticas;
}
```

```java
// GET /api/v1/dashboard/combustivel-mensal?meses=12
public class CombustivelMensalResponse {
    private List<DadoMensal> dadosMensais; // mês, litros, valor, custoKm
}

// GET /api/v1/dashboard/ranking-veiculos?tipo=eficiencia&limite=10
public class RankingVeiculoResponse {
    private List<VeiculoRanking> ranking; // placa, modelo, kmL, custoKm
}

// GET /api/v1/dashboard/mapa-calor-custos
public class MapaCalorCustosResponse {
    private Map<String, Map<String, BigDecimal>> custosPorDeptPorMes;
}
```

### 7.2 Comparativos e Tendências

| Comparativo | Descrição |
|-------------|-----------|
| Mês vs mês anterior | Variação percentual de todos os indicadores |
| Mês vs mesmo mês ano anterior | Sazonalidade |
| Departamento vs departamento | Qual secretaria gasta mais |
| Veículo vs média da frota | Veículos fora da curva |
| Previsto vs realizado | Orçamento vs gasto real |
| Próprio vs terceirizado | Custo-benefício da frota |

---

## 8. Módulo 7 — Relatórios para Tribunal de Contas

### 8.1 Relatórios Obrigatórios

Baseado nas exigências dos Tribunais de Contas Estaduais (TCE), o sistema deve gerar:

| # | Relatório | Descrição | Periodicidade |
|---|-----------|-----------|---------------|
| 1 | **Inventário de Frota** | Lista completa com placa, chassi, renavam, ano, valor, estado | Anual |
| 2 | **Mapa de Abastecimento Consolidado** | Todos os abastecimentos por veículo/período | Mensal |
| 3 | **Demonstrativo de Despesas com Combustível** | Gastos por fonte/elemento de despesa | Mensal |
| 4 | **Demonstrativo de Despesas com Manutenção** | Gastos por veículo e fornecedor | Mensal |
| 5 | **Controle de Quilometragem** | Km rodados por veículo/mês | Mensal |
| 6 | **Relatório de Multas** | Multas por veículo com status de pagamento | Mensal |
| 7 | **Relatório de Contratos de Transporte Escolar** | Dados completos dos contratos per PNATE | Semestral |
| 8 | **Balanço Físico-Financeiro de Combustível** | Litros comprados vs consumidos, estoque | Mensal |
| 9 | **Relatório de Motoristas e CNHs** | Motoristas, categorias, validades | Trimestral |
| 10 | **Demonstrativo de Custo Operacional** | TCO por veículo para análise de substituição | Anual |
| 11 | **Relatório de Rotas Escolares** | Rotas com custos, km, alunos atendidos | Semestral |
| 12 | **Comparativo Frota Própria vs Terceirizada** | Custo-benefício por modalidade | Anual |

### 8.2 Formato de Exportação

| Formato | Uso |
|---------|-----|
| **PDF** (existente) | Impressão e arquivo |
| **CSV** (novo) | Importação em outros sistemas |
| **XLSX** (novo) | Análises em Excel |
| **XML** (novo) | Integração com SAGRES/SICOM* |
| **JSON** (novo) | API para outros sistemas |

*SAGRES = Sistema de Acompanhamento da Gestão dos Recursos da Sociedade (PB)
*SICOM = Sistema Informatizado de Contas dos Municípios (MG)

### 8.3 Layout para Prestação de Contas

```java
// Novo endpoint: POST /api/v1/relatorio/tribunal-contas
public class RelatorioTCRequest {
    private String tipoRelatorio;    // INVENTARIO, MAPA_ABASTECIMENTO, etc.
    private LocalDate dataInicial;
    private LocalDate dataFinal;
    private String formato;          // PDF, CSV, XLSX, XML
    private List<Long> unidadesGestoras;
    private Boolean incluirSubtotais;
    private Boolean incluirAssinaturas;  // campos de assinatura
    private String responsavelNome;
    private String responsavelCargo;
    private String responsavelMatricula;
}
```

#### Campos de Assinatura nos Relatórios

Todos os relatórios para TC devem incluir:
- Local e data
- Nome, cargo e CPF do responsável
- Nome, cargo e CPF do ordenador de despesas
- Código de verificação digital (hash MD5 do relatório)

---

## 9. Módulo 8 — Notificações e Alertas Automáticos

### 9.1 Sistema de Notificações Completo

**Problema atual:** Modelo `Notificacao` existe mas não há automação.

#### Novos Tipos de Notificação

```java
public enum TipoNotificacao {
    // Existentes
    CNH, SEGURO, MANUTENCAO,
    
    // Novos
    CNH_30_DIAS,
    CNH_7_DIAS,
    CNH_VENCIDA,
    EXAME_TOXICOLOGICO,
    CRLV_VENCENDO,
    IPVA_VENCENDO,
    SEGURO_VENCENDO,
    CONTRATO_ESGOTANDO,
    CONTRATO_VENCENDO,
    MANUTENCAO_AGENDADA,
    MANUTENCAO_ATRASADA,
    PNEU_DESGASTE,
    ANOMALIA_COMBUSTIVEL,
    MULTA_VENCENDO,
    VEICULO_PARADO_LONGO,
    GPS_SEM_SINAL,
    EXCESSO_VELOCIDADE,
    DESVIO_ROTA
}
```

### 9.2 Motor de Regras

```java
@Entity
public class RegraNotificacao extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Enumerated(EnumType.STRING)
    private TipoNotificacao tipo;
    
    private String descricao;
    private Boolean ativo = true;
    
    private Integer diasAntecedencia;     // para alertas de vencimento
    private BigDecimal percentualLimite;  // para alertas de consumo
    
    @Enumerated(EnumType.STRING)
    private CanalNotificacao canal;       // SISTEMA, EMAIL, SMS, PUSH, TODOS
    
    private String destinatariosRoles;    // FROTAS_ADMIN,FROTAS_GESTOR
    
    private String cronExpression;        // para jobs agendados: "0 0 7 * * ?" = todo dia 7h
}
```

### 9.3 Implementação com Spring Scheduler

```java
@Component
@EnableScheduling
public class NotificacaoScheduler {
    
    @Scheduled(cron = "0 0 7 * * ?")  // Todo dia às 7h
    public void verificarCNHs() {
        // Buscar motoristas com CNH vencendo em 30, 7, 0 dias
        // Gerar notificações
    }
    
    @Scheduled(cron = "0 0 7 * * ?")
    public void verificarDocumentosVeiculos() {
        // CRLV, IPVA, Seguro, Licenciamento
    }
    
    @Scheduled(cron = "0 0 7 * * ?")
    public void verificarManutencoesAgendadas() {
        // Planos de manutenção preventiva
    }
    
    @Scheduled(cron = "0 0 8 1 * ?")  // Dia 1 de cada mês às 8h
    public void verificarContratos() {
        // Saldo de contratos
    }
    
    @Scheduled(cron = "0 0 7 * * MON")  // Toda segunda às 7h
    public void resumoSemanal() {
        // Resumo consolidado com pendências
    }
}
```

### 9.4 Canais de Entrega

| Canal | Implementação | Prioridade |
|-------|--------------|-----------|
| **Sistema (in-app)** | Notificação persistida no banco, exibida no frontend | 🔴 P1 |
| **Email** | Spring Mail + template HTML | 🔴 P1 |
| **Push (mobile)** | Firebase Cloud Messaging | 🟡 P2 |
| **SMS** | API Twilio ou similar | 🟢 P3 |

---

## 10. Módulo 9 — App Mobile para Motoristas

### 10.1 Funcionalidades Mobile

| Feature | Descrição |
|---------|-----------|
| **Check-in/Check-out** | Motorista inicia e encerra viagem com km |
| **Inspeção rápida** | Checklist simplificado com fotos |
| **Registrar abastecimento** | Foto do cupom fiscal + dados |
| **Registrar incidente** | Avarias, acidentes, problemas |
| **Consultar agenda** | Viagens e manutenções agendadas |
| **GPS tracking** | Enviar posição em background |
| **Notificações push** | Receber alertas e lembretes |
| **Assinatura digital** | Assinar diário de bordo digitalmente |
| **Modo offline** | Funcionar sem internet, sincronizar depois |

### 10.2 Stack Sugerida

| Tecnologia | Justificativa |
|-----------|---------------|
| **React Native** ou **Flutter** | Compartilhar código iOS/Android |
| **AsyncStorage/SQLite** | Modo offline |
| **Firebase** | Push notifications |
| **Background Location** | GPS tracking |
| **Câmera nativa** | Fotos de cupom, avarias |

### 10.3 Endpoints Mobile

```
POST /api/v1/mobile/checkin     → { veiculoId, kmInicial, latitude, longitude }
POST /api/v1/mobile/checkout    → { viagemId, kmFinal, latitude, longitude }
POST /api/v1/mobile/inspecao    → { veiculoId, checklist, fotos[] }
POST /api/v1/mobile/abastecimento → { veiculoId, litros, valor, fotoCupom }
POST /api/v1/mobile/incidente   → { veiculoId, descricao, fotos[], lat, lng }
GET  /api/v1/mobile/agenda      → viagens e manutenções do dia
POST /api/v1/mobile/posicao     → { veiculoId, lat, lng, vel, timestamp }
GET  /api/v1/mobile/notificacoes → notificações pendentes
POST /api/v1/mobile/sync        → sincronizar dados offline
```

---

## 11. Módulo 10 — Integrações Externas

### 11.1 Integrações Propostas

| Sistema | API | Dados | Prioridade |
|---------|-----|-------|-----------|
| **ANP** (Agência Nacional do Petróleo) | REST | Preços médios de combustível por região | 🟡 Média |
| **DETRAN** (via webservice estado) | SOAP/REST | Consulta multas, CNH, débitos | 🟡 Média |
| **IBGE** | REST | Códigos de município, UF | 🟢 Baixa |
| **ViaCEP** | REST (já usado) | Busca de endereço por CEP | ✅ Existente |
| **ReceitaWS** | REST (já usado) | Consulta CNPJ | ✅ Existente |
| **Google Maps/OpenStreetMap** | REST | Geocodificação, rotas, distâncias | 🟡 Média |
| **Sistemas TC Estaduais** | XML/CSV | Exportação SAGRES, SICOM, SICAP | 🔴 Alta |

### 11.2 Integração com Preços ANP

```java
@Service
public class ANPIntegrationService {
    
    /**
     * Busca preço médio semanal de combustível na região
     * e compara com preço pago nos abastecimentos
     */
    public ComparacaoPrecoResponse compararPrecos(Long unidadeGestoraId, String combustivel) {
        // 1. Buscar preço ANP da semana
        // 2. Calcular média paga pela UG
        // 3. Retornar comparativo (% acima/abaixo do mercado)
    }
}
```

---

## 12. Módulo 11 — Auditoria e Compliance

### 12.1 Trail de Auditoria Completo

```java
@Entity
public class AuditLog extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String entidade;          // Veiculo, Motorista, etc.
    private Long entidadeId;
    
    @Enumerated(EnumType.STRING)
    private TipoAcao acao;           // CRIAR, ALTERAR, EXCLUIR, APROVAR, VISUALIZAR
    
    private String campoAlterado;
    private String valorAnterior;
    private String valorNovo;
    
    private LocalDateTime dataHora;
    
    @ManyToOne
    private Usuario usuario;
    
    private String ipAcesso;
    private String userAgent;
}
```

### 12.2 Compliance Municipal

| Exigência Legal | Implementação | Status |
|----------------|--------------|--------|
| Lei de Licitações (14.133/2021) | Vincular abastecimentos a contratos licitados | 🟡 Parcial |
| PNATE (Transporte Escolar) | Módulo transporte escolar com custos | ✅ Existente |
| Lei de Responsabilidade Fiscal | Relatórios de gasto vs orçamento | 🔴 Novo |
| Código de Trânsito (CTB) | Controle de CNH, multas, documentação | 🟡 Parcial |
| LGPD | Proteção de dados pessoais (CPF, CNH) | 🔴 Novo |

### 12.3 LGPD — Proteção de Dados

| Ação | Implementação |
|------|--------------|
| Consentimento | Termo de aceite no cadastro de motoristas |
| Minimização | Coletar apenas dados necessários |
| Portabilidade | Endpoint de exportação de dados pessoais |
| Exclusão | Right to be forgotten (soft delete já existente + rotina de anonimização) |
| Log de acesso | Registrar quem acessou dados sensíveis |
| Criptografia | Criptografar CPF, CNH no banco |

---

## 13. Módulo 12 — Gestão de Seguros e Sinistros

### 13.1 Modelo de Dados

```java
@Entity
public class SeguroVeiculo extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Veiculo veiculo;
    
    private String seguradora;
    private String apolice;
    private LocalDate dataInicio;
    private LocalDate dataFim;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorPremio;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorFranquia;
    
    private String coberturas;         // JSON ou texto
    
    @Enumerated(EnumType.STRING)
    private StatusSeguro status;       // VIGENTE, VENCIDO, CANCELADO
}
```

```java
@Entity
public class Sinistro extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private SeguroVeiculo seguro;
    
    @ManyToOne
    private Veiculo veiculo;
    
    @ManyToOne
    private Motorista motorista;
    
    private LocalDateTime dataHoraOcorrencia;
    private String local;
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    private TipoSinistro tipo;        // COLISAO, FURTO, ROUBO, INCENDIO, 
                                       // ALAGAMENTO, QUEDA_ARVORE, DANO_TERCEIRO
    
    private String boletimOcorrencia;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorEstimadoDano;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorIndenizado;
    
    @Enumerated(EnumType.STRING)
    private StatusSinistro status;     // REGISTRADO, EM_ANALISE, APROVADO, 
                                       // NEGADO, INDENIZADO
}
```

---

## 14. Correções e Melhorias Técnicas Imediatas

### 14.1 Bugs a Corrigir

| # | Bug | Local | Correção |
|---|-----|-------|----------|
| 1 | Path de DELETE da Vistoria é `bistoria/{id}` | VistoriaController.java | Corrigir para `vistoria/{id}` |
| 2 | Campos String que deveriam ser tipados | Veiculo.litrosKm, litrosTanque | Converter para BigDecimal |
| 3 | tipoFrota é String | Veiculo.java | Criar enum TipoFrota (PROPRIO, TERCEIRIZADO, CEDIDO) |
| 4 | Viagem.tipoViajem (typo) | Viagem.java | Manter campo por compatibilidade, criar alias |

### 14.2 Melhorias de Código

| # | Melhoria | Impacto |
|---|----------|---------|
| 1 | Migrar lógica de Controllers para Services | Melhor testabilidade |
| 2 | Adicionar validações Bean Validation nos DTOs | Integridade de dados |
| 3 | Implementar paginação em todos os endpoints de lista | Performance |
| 4 | Adicionar cache (Spring Cache / Redis) | Performance em consultas frequentes |
| 5 | Implementar batch processing para relatórios grandes | Performance |
| 6 | Testes unitários e de integração | Qualidade |
| 7 | Documentação OpenAPI com exemplos | Dev experience |
| 8 | Rate limiting nos endpoints públicos | Segurança |

### 14.3 Melhorias de Infraestrutura

| # | Melhoria | Descrição |
|---|----------|-----------|
| 1 | Flyway/Liquibase | Migrations versionadas do banco |
| 2 | Redis para cache e sessões | Performance |
| 3 | MinIO/S3 para arquivos | Armazenamento de fotos, documentos |
| 4 | RabbitMQ para notificações | Desacoplamento |
| 5 | Elasticsearch para busca | Busca full-text em logs e relatórios |
| 6 | Prometheus + Grafana | Monitoramento |

---

## 15. Roadmap de Implementação

### Fase 1 — Fundação (4-6 semanas)

| Sprint | Entrega |
|--------|---------|
| Sprint 1 | Correção de bugs + Melhorias técnicas imediatas |
| Sprint 2 | Cálculo automático de consumo médio + Saldo de contrato |
| Sprint 3 | Sistema de notificações automáticas (CNH, contratos, manutenção) |

### Fase 2 — Manutenção Inteligente (4-6 semanas)

| Sprint | Entrega |
|--------|---------|
| Sprint 4 | Planos de manutenção preventiva + Agenda automática |
| Sprint 5 | Gestão de CNH e documentação veicular |
| Sprint 6 | Dashboard inteligente com KPIs |

### Fase 3 — Compliance (4-6 semanas)

| Sprint | Entrega |
|--------|---------|
| Sprint 7 | Relatórios para Tribunal de Contas (12 relatórios) |
| Sprint 8 | Exportação CSV/XLSX/XML + Assinaturas |
| Sprint 9 | Auditoria completa + LGPD |

### Fase 4 — Avançado (6-8 semanas)

| Sprint | Entrega |
|--------|---------|
| Sprint 10 | Detecção de anomalias de combustível + Alertas |
| Sprint 11 | Gestão de pneus e patrimônio |
| Sprint 12 | Gestão de seguros e sinistros |
| Sprint 13 | TCO por veículo |

### Fase 5 — GPS e Mobile (8-10 semanas)

| Sprint | Entrega |
|--------|---------|
| Sprint 14-15 | App Mobile (check-in, inspeção, abastecimento) |
| Sprint 16-17 | GPS e rastreamento em tempo real |
| Sprint 18 | Cercas virtuais + Alertas GPS |
| Sprint 19 | Otimização de rotas |

### Fase 6 — Integrações (4-6 semanas)

| Sprint | Entrega |
|--------|---------|
| Sprint 20 | Integração ANP + DETRAN |
| Sprint 21 | Integração com sistemas TC estaduais |
| Sprint 22 | API pública para integrações de terceiros |

---

## 16. Estimativa de Esforço

| Fase | Duração | Story Points (est.) | Prioridade |
|------|---------|--------------------:|-----------|
| Fase 1 — Fundação | 4-6 sem | 80-100 | 🔴 Crítica |
| Fase 2 — Manutenção Inteligente | 4-6 sem | 90-120 | 🔴 Crítica |
| Fase 3 — Compliance | 4-6 sem | 100-130 | 🔴 Crítica |
| Fase 4 — Avançado | 6-8 sem | 120-150 | 🟡 Alta |
| Fase 5 — GPS e Mobile | 8-10 sem | 180-220 | 🟡 Alta |
| Fase 6 — Integrações | 4-6 sem | 60-80 | 🟢 Média |
| **Total** | **30-42 sem** | **630-800** | — |

### Priorização por Impacto de Mercado

```
┌──────────────────────────────────────────────────────────┐
│  ALTO IMPACTO / BAIXO ESFORÇO (FAZER PRIMEIRO)          │
│                                                           │
│  ✅ Notificações automáticas                              │
│  ✅ Controle saldo de contrato                            │
│  ✅ Cálculo consumo médio                                 │
│  ✅ Correção de bugs                                      │
├──────────────────────────────────────────────────────────┤
│  ALTO IMPACTO / ALTO ESFORÇO (PLANEJAR BEM)             │
│                                                           │
│  ⚡ Relatórios para Tribunal de Contas                    │
│  ⚡ Manutenção preventiva automática                      │
│  ⚡ Dashboard inteligente com KPIs                        │
│  ⚡ App Mobile                                            │
├──────────────────────────────────────────────────────────┤
│  BAIXO IMPACTO / BAIXO ESFORÇO (OPORTUNIDADE)           │
│                                                           │
│  📋 Melhorias técnicas (cache, testes)                    │
│  📋 Integração ANP                                        │
│  📋 Exportação CSV/XLSX                                   │
├──────────────────────────────────────────────────────────┤
│  BAIXO IMPACTO / ALTO ESFORÇO (AVALIAR)                 │
│                                                           │
│  ❓ GPS/Telemetria                                        │
│  ❓ Otimização de rotas                                   │
│  ❓ Integração DETRAN                                     │
└──────────────────────────────────────────────────────────┘
```

---

> **Próximos passos:** Consultar o documento [03-ANALISE-MERCADO-PRODUTO.md](03-ANALISE-MERCADO-PRODUTO.md) para a estratégia de produto e posicionamento de mercado.
