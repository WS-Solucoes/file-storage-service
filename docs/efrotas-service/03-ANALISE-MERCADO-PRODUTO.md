# eFrotas — Análise de Mercado e Estratégia de Produto

> **Versão:** 1.0 | **Data:** 23/02/2026 | **Objetivo:** Posicionar o eFrotas como solução líder para gestão de frotas municipais no Brasil

---

## Sumário

1. [Panorama do Mercado](#1-panorama-do-mercado)
2. [Análise Competitiva](#2-análise-competitiva)
3. [Diferenciais Competitivos do eFrotas](#3-diferenciais-competitivos-do-efrotas)
4. [Público-Alvo e Personas](#4-público-alvo-e-personas)
5. [Funcionalidades por Plano Comercial](#5-funcionalidades-por-plano-comercial)
6. [Requisitos para Tribunal de Contas por Estado](#6-requisitos-para-tribunal-de-contas-por-estado)
7. [Proposta de Novos Módulos Detalhados](#7-proposta-de-novos-módulos-detalhados)
8. [Modelagem de Dados — Novas Entidades](#8-modelagem-de-dados--novas-entidades)
9. [Arquitetura de Referência — Sistema Completo](#9-arquitetura-de-referência--sistema-completo)
10. [API Pública para Integrações](#10-api-pública-para-integrações)
11. [Métricas de Sucesso (OKRs)](#11-métricas-de-sucesso-okrs)
12. [Estratégia de Go-to-Market](#12-estratégia-de-go-to-market)

---

## 1. Panorama do Mercado

### Tamanho do Mercado

| Dado | Valor | Fonte |
|------|-------|-------|
| Municípios no Brasil | 5.570 | IBGE |
| Municípios com frotas significativas (>10 veículos) | ~4.500 | Estimativa |
| Gasto médio anual com frota por município (até 50 mil hab.) | R$ 500 mil - R$ 2 milhões | TCE-SP |
| Gasto médio anual com frota por município (50-200 mil hab.) | R$ 2 milhões - R$ 10 milhões | TCE-SP |
| Mercado endereçável (SaaS gestão de frotas públicas) | R$ 200 - 500 milhões/ano | Estimativa |

### Dores do Mercado Público

| Dor | Frequência | Impacto |
|-----|-----------|---------|
| Desperdício de combustível (fraudes, desvio) | Muito comum | Financeiro direto |
| Manutenção corretiva (reativa) cara | Universal | Custo operacional 3-5x maior |
| Falta de controle de quilometragem | Muito comum | Impossibilita auditoria |
| Multas não rastreadas a motoristas | Comum | Perda financeira |
| CNHs vencidas | Comum | Risco jurídico |
| Prestação de contas ao TC manual | Universal | Retrabalho e erros |
| Sem visibilidade real da frota | Comum | Decisões sem dados |
| Uso particular de veículos públicos | Muito comum | Risco político e legal |

---

## 2. Análise Competitiva

### Comparativo de Funcionalidades

| Funcionalidade | **eFrotas (Atual)** | **eFrotas (Proposto)** | Concorrente A (genérico) | Concorrente B (governo) |
|---------------|:---:|:---:|:---:|:---:|
| Multi-tenant (multimunicipal) | ✅ | ✅ | ❌ | ✅ |
| Cadastro de frota completo | ✅ | ✅ | ✅ | ✅ |
| Requisição com aprovação | ✅ | ✅ | ❌ | ❌ |
| Transporte escolar | ✅ | ✅ | ❌ | 🟡 |
| Relatórios PDF | ✅ | ✅ | ✅ | ✅ |
| Cálculo consumo automático | ❌ | ✅ | 🟡 | ❌ |
| Manutenção preventiva | ❌ | ✅ | ✅ | ❌ |
| Saldo de contrato em tempo real | ❌ | ✅ | ❌ | ❌ |
| Detecção de anomalias | ❌ | ✅ | ❌ | ❌ |
| GPS/Telemetria | ❌ | ✅ | ✅ | ❌ |
| App Mobile | ❌ | ✅ | ✅ | ❌ |
| Relatórios para TC | 🟡 | ✅ | ❌ | 🟡 |
| Exportação SAGRES/SICOM | ❌ | ✅ | ❌ | ❌ |
| Gestão de pneus | ❌ | ✅ | ❌ | ❌ |
| TCO por veículo | ❌ | ✅ | ❌ | ❌ |
| Dashboard inteligente | 🟡 | ✅ | 🟡 | ❌ |
| Integração ANP | ❌ | ✅ | ❌ | ❌ |
| LGPD compliance | ❌ | ✅ | ❌ | ❌ |
| Notificações automáticas | ❌ | ✅ | 🟡 | ❌ |
| Gestão seguros/sinistros | ❌ | ✅ | ❌ | ❌ |
| Auditoria completa | 🟡 | ✅ | ❌ | ❌ |

### Vantagem Competitiva por Segmento

| Segmento | Principal dor | Diferencial eFrotas |
|----------|---------------|-------------------|
| Municípios pequenos (<20k hab.) | Custo e simplicidade | SaaS acessível + multi-tenant |
| Municípios médios (20-100k) | Prestação de contas ao TC | Relatórios formatados por estado |
| Municípios grandes (100k+) | Gestão complexa + redução de custos | TCO + anomalias + GPS |
| Câmaras municipais | Controle básico de poucos veículos | Plano simplificado |
| Autarquias | Integração com prefeitura | Multi-tenant com UGs |

---

## 3. Diferenciais Competitivos do eFrotas

### Top 5 Diferenciais de Mercado

| # | Diferencial | Por que é único |
|---|------------|-----------------|
| 1 | **Compliance nativo para Tribunal de Contas** | Relatórios formatados por TCE estadual (SAGRES, SICOM, etc.) |
| 2 | **Multi-tenant real por município** | Uma instalação serve todas as secretarias e autarquias |
| 3 | **Fluxo de aprovação integrado** | Requisições passam por aprovação antes de usar recurso público |
| 4 | **Detecção de anomalias de combustível** | Inteligência para identificar desvios e fraudes |
| 5 | **TCO (Total Cost of Ownership)** | Apoio à decisão: manter vs renovar veículo |

### Proposta de Valor

```
"O eFrotas é o único sistema de gestão de frotas desenvolvido
especificamente para o setor público brasileiro, com relatórios
prontos para o Tribunal de Contas, controle de combustível com
detecção de anomalias e workflow de aprovação integrado —
reduzindo custos operacionais em até 30% e eliminando o
retrabalho na prestação de contas."
```

---

## 4. Público-Alvo e Personas

### Persona 1 — Secretário de Administração

| Aspecto | Detalhe |
|---------|---------|
| **Nome** | Carlos, 48 anos |
| **Cargo** | Secretário Municipal de Administração |
| **Dor** | "Não sei quanto estamos gastando com a frota. O TC cobra relatórios que levo semanas para montar manualmente." |
| **Necessidade** | Dashboard executivo + relatórios prontos para TC |
| **Decisão** | Aprovador do orçamento para sistema |

### Persona 2 — Gestor de Frota

| Aspecto | Detalhe |
|---------|---------|
| **Nome** | Maria, 35 anos |
| **Cargo** | Coordenadora de Transporte |
| **Dor** | "Controlo tudo em planilhas Excel. Motoristas não devolvem relatórios. Não consigo prever manutenções." |
| **Necessidade** | Sistema online + manutenção preventiva + notificações |
| **Decisão** | Usuário principal e influenciador |

### Persona 3 — Motorista

| Aspecto | Detalhe |
|---------|---------|
| **Nome** | João, 42 anos |
| **Cargo** | Motorista da Secretaria de Saúde |
| **Dor** | "Tenho que preencher formulários em papel. Às vezes esqueço de anotar km." |
| **Necessidade** | App mobile simples e rápido |
| **Decisão** | Usuário final |

### Persona 4 — Controlador Interno / Auditor

| Aspecto | Detalhe |
|---------|---------|
| **Nome** | Ana, 32 anos |
| **Cargo** | Controladora Interna |
| **Dor** | "Preciso auditar combustível mas os dados são inconsistentes. Não consigo cruzar informações." |
| **Necessidade** | Relatórios de auditoria + trail de alterações + anomalias |
| **Decisão** | Influenciador técnico |

---

## 5. Funcionalidades por Plano Comercial

### Plano Essencial

**Target:** Municípios < 20k habitantes, Câmaras, pequenas autarquias
**Veículos:** Até 30

| Módulo | Funcionalidades |
|--------|----------------|
| Cadastros | Veículos, Motoristas, Combustíveis, Postos, Departamentos |
| Abastecimento | Requisições com aprovação + controle de consumo |
| Manutenção | Corretiva + requisições |
| Viagens | Diário de bordo |
| Multas | Registro e controle |
| Relatórios | 5 relatórios básicos (PDF) |
| Notificações | CNH e contratos vencendo |
| Dashboard | Básico (4 gráficos) |
| Suporte | Email |

### Plano Profissional

**Target:** Municípios 20-100k habitantes
**Veículos:** Até 150

| Módulo | Funcionalidades |
|--------|----------------|
| *Tudo do Essencial +* | - |
| Manutenção preventiva | Planos de manutenção + agendamento automático |
| Consumo inteligente | Cálculo consumo médio + histórico + ranking |
| Transporte escolar | Contratos, rotas, percursos, custos |
| Contratos | Saldo em tempo real + alertas |
| Relatórios TC | 12 relatórios formatados + exportação XLSX/CSV |
| Dashboard avançado | KPIs + comparativos + tendências |
| Notificações | Todos os tipos + email automático |
| Seguros | Gestão básica de seguros |
| Pneus | Controle básico |
| Suporte | Email + telefone |

### Plano Enterprise

**Target:** Municípios > 100k habitantes, capitais, consórcios
**Veículos:** Ilimitado

| Módulo | Funcionalidades |
|--------|----------------|
| *Tudo do Profissional +* | - |
| GPS/Telemetria | Rastreamento em tempo real + histórico |
| App Mobile | Android e iOS para motoristas |
| Anomalias | Detecção automática de fraudes |
| TCO | Total Cost of Ownership por veículo |
| Integrações | ANP, DETRAN, TC estadual |
| Auditoria | Trail completo + relatórios de auditoria |
| API pública | Integração com outros sistemas |
| LGPD | Compliance completo |
| Multi-site | Vários municípios em consórcio |
| Suporte | Dedicado + implantação presencial |

---

## 6. Requisitos para Tribunal de Contas por Estado

### Mapeamento de Sistemas TC Estaduais

| Estado | Sistema TC | Formato | Relatórios Específicos |
|--------|-----------|---------|----------------------|
| **PB** | SAGRES | XML | Despesas com combustível, manutenção, frota |
| **MG** | SICOM | XML/CSV | Patrimônio móvel, despesas por fonte |
| **SP** | AUDESP | XML | Patrimônio, despesas, contratos |
| **BA** | SAFEWEB | XML | Frota, combustível, manutenção |
| **PE** | SAGRES-PE | XML | Similar ao PB |
| **CE** | SIM | CSV | Simplificado |
| **PR** | SIM-AM | XML | Veículos patrimoniados |
| **RS** | LICITACON | XML | Contratos, licitações |
| **SC** | e-Sfinge | XML | Patrimônio, contratos |
| **GO** | GEO-Obras | XML/CSV | Simplificado |

### Módulo de Exportação por TC

```java
public interface ExportadorTC {
    byte[] exportar(RelatorioTCRequest request);
    String getSistemaTC();         // SAGRES, SICOM, AUDESP...
    String getEstado();            // PB, MG, SP...
    String getFormato();           // XML, CSV
    String getVersaoLayout();      // v2024.1
}

// Implementações por estado
@Service("sagres-pb") public class ExportadorSAGRES_PB implements ExportadorTC { ... }
@Service("sicom-mg") public class ExportadorSICOM_MG implements ExportadorTC { ... }
@Service("audesp-sp") public class ExportadorAUDESP_SP implements ExportadorTC { ... }
```

**Configuração por UG:**

```java
@Entity
public class ConfiguracaoTC extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String estado;
    private String sistemaTC;
    private String versaoLayout;
    
    // Dados do órgão para cabeçalho
    private String codigoOrgaoTC;
    private String nomeOrgaoTC;
    private String codigoUnidadeGestora;
}
```

---

## 7. Proposta de Novos Módulos Detalhados

### 7.1 Módulo de Orçamento e Custos

```java
@Entity
public class OrcamentoFrota extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Integer ano;
    
    @Enumerated(EnumType.STRING)
    private CategoriaOrcamento categoria; // COMBUSTIVEL, MANUTENCAO, PNEUS, 
                                           // SEGURO, MULTAS, AQUISICAO, OUTROS
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorPrevisto;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorRealizado;     // calculado automaticamente
    
    @ManyToOne
    private Departamento departamento;     // orçamento por secretaria
    
    // Dot. Orçamentária
    private String funcional;              // ex: 26.122.0001.2050
    private String fonteRecurso;           // ex: 100
    private String elementoDespesa;        // ex: 3.3.90.30 (material consumo)
    private String naturezaDespesa;
}
```

#### Relatório Previsto vs Realizado

```
┌───────────────────────────────────────────────────────────────────┐
│  ORÇAMENTO DE FROTA — 2026                                        │
│  Prefeitura Municipal de Exemplo                                  │
├──────────────────┬──────────────┬──────────────┬─────────────────┤
│  Categoria       │  Previsto    │  Realizado   │  % Execução     │
├──────────────────┼──────────────┼──────────────┼─────────────────┤
│  Combustível     │  R$ 500.000  │  R$ 387.450  │  77,5%  ⬛⬛⬛⬛░ │
│  Manutenção      │  R$ 200.000  │  R$ 178.320  │  89,2%  ⬛⬛⬛⬛░ │
│  Pneus           │  R$ 50.000   │  R$ 62.100   │  124,2% ⬛⬛⬛⬛⬛ │ ⚠️
│  Seguros         │  R$ 80.000   │  R$ 75.000   │  93,8%  ⬛⬛⬛⬛░ │
│  Multas          │  R$ 10.000   │  R$ 15.800   │  158,0% ⬛⬛⬛⬛⬛ │ 🔴
├──────────────────┼──────────────┼──────────────┼─────────────────┤
│  TOTAL           │  R$ 840.000  │  R$ 718.670  │  85,6%          │
└──────────────────┴──────────────┴──────────────┴─────────────────┘
```

### 7.2 Módulo de Reserva de Veículos

```java
@Entity
public class ReservaVeiculo extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private Veiculo veiculo;
    
    @ManyToOne
    private Motorista motorista;
    
    @ManyToOne
    private Departamento departamentoSolicitante;
    
    private String solicitante;
    private String finalidade;
    private String destino;
    
    private LocalDateTime dataHoraInicio;
    private LocalDateTime dataHoraFim;
    
    @Enumerated(EnumType.STRING)
    private StatusReserva status; // SOLICITADA, CONFIRMADA, EM_USO, 
                                   // CONCLUIDA, CANCELADA
    
    private String observacao;
}
```

**Regras de negócio:**
- Verificar conflito de horário antes de confirmar
- Motorista só pode ter uma reserva ativa por vez
- Veículo não pode ser reservado se em manutenção
- Gestor aprova reservas (workflow)
- Reserva vira Viagem automaticamente ao check-in

### 7.3 Módulo de Abastecimento Interno (Bomba Própria)

Para municípios que possuem bomba de combustível própria:

```java
@Entity
public class BombaCombustivel extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String codigo;
    private String localizacao;
    
    @ManyToOne
    private Combustivel combustivel;
    
    @Column(precision = 10, scale = 3)
    private BigDecimal capacidadeLitros;
    
    @Column(precision = 10, scale = 3)
    private BigDecimal saldoAtual;
    
    private LocalDate dataUltimaCalibracao;
}
```

```java
@Entity  
public class LeituraBomba extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne
    private BombaCombustivel bomba;
    
    private LocalDateTime dataHora;
    
    @Column(precision = 10, scale = 3)
    private BigDecimal leituraAnterior;
    
    @Column(precision = 10, scale = 3)
    private BigDecimal leituraAtual;
    
    @Column(precision = 10, scale = 3)
    private BigDecimal litrosConsumidos; // calculado
    
    @ManyToOne
    private RequisicaoAbastecimento requisicao;
}
```

### 7.4 Módulo de Indicadores LEI 14.133/2021

Nova Lei de Licitações exige:

```java
@Entity
public class ProcessoCompra extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String numeroProcesso;
    private String modalidade;       // PREGAO, DISPENSA, INEXIGIBILIDADE
    private String objetoResumo;
    private LocalDate dataAbertura;
    private LocalDate dataHomologacao;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorEstimado;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal valorContratado;
    
    @Column(precision = 15, scale = 2)
    private BigDecimal economiaLicitacao; // estimado - contratado
    
    @ManyToOne
    private Contrato contrato;
    
    private String linkPNCP;        // Portal Nacional de Contratações
}
```

---

## 8. Modelagem de Dados — Novas Entidades (Resumo)

### Diagrama de Novas Entidades

```
NOVAS ENTIDADES (a implementar)
═══════════════════════════════

Combustível Avançado:
├── HistoricoConsumo
├── AlertaAnomalia  
├── BombaCombustivel
└── LeituraBomba

Manutenção Preventiva:
├── PlanoManutencao
├── AgendaManutencao
└── CategoriaManutencao (enum)

Documentação:
├── DocumentoVeiculo
├── ExameMotorista
└── StatusCNH (enum)

Patrimônio:
├── Pneu
├── MovimentacaoPneu
└── PatrimonioVeiculo

GPS:
├── PosicaoGPS
├── EventoGPS
├── CercaVirtual
└── RotaOtimizada

Financeiro:
├── OrcamentoFrota
├── SeguroVeiculo
├── Sinistro
└── ProcessoCompra

Operacional:
├── ReservaVeiculo
├── RegraNotificacao
└── ConfiguracaoTC

Auditoria:
└── AuditLog
```

### Contagem Total

| Categoria | Existentes | Novas | Total |
|-----------|-----------|-------|-------|
| Entidades de modelo | 26 | 19 | 45 |
| Enums | 8 | 12+ | 20+ |
| Controllers | 20 | 8-10 | 28-30 |
| Services | 20 | 12-15 | 32-35 |
| Relatórios Jasper | 14 | 12+ | 26+ |

---

## 9. Arquitetura de Referência — Sistema Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENTES                                  │
│                                                                  │
│  ┌─────────┐  ┌─────────┐  ┌────────────┐  ┌──────────────┐   │
│  │ Web App │  │ Mobile  │  │ Integrações│  │ TC Estadual  │   │
│  │ Next.js │  │ React   │  │ API REST   │  │ XML Export   │   │
│  │         │  │ Native  │  │            │  │              │   │
│  └────┬────┘  └────┬────┘  └─────┬──────┘  └──────┬───────┘   │
│       │             │             │                 │            │
│  ┌────┴─────────────┴─────────────┴─────────────────┴───────┐   │
│  │                    API GATEWAY (8080)                      │   │
│  │                    Rate Limiting + Auth                    │   │
│  └──────────────────────┬───────────────────────────────────┘   │
│                          │                                       │
│  ┌───────────────────────┴──────────────────────────────────┐   │
│  │                 eFrotas Service (8082)                     │   │
│  │                                                           │   │
│  │  ┌──────────┐ ┌───────────┐ ┌────────────┐ ┌──────────┐ │   │
│  │  │Controller│ │  Service  │ │  Scheduler │ │ Exporter │ │   │
│  │  │  Layer   │→│  Layer    │→│  (Jobs)    │ │ (TC/PDF) │ │   │
│  │  └──────────┘ └─────┬─────┘ └────────────┘ └──────────┘ │   │
│  │                      │                                    │   │
│  │  ┌──────────────────┴───────────────────────────────────┐│   │
│  │  │              Repository Layer (JPA)                   ││   │
│  │  └──────────────────┬───────────────────────────────────┘│   │
│  └──────────────────────┼───────────────────────────────────┘   │
│                          │                                       │
│  ┌───────────┐  ┌───────┴────────┐  ┌──────────┐  ┌─────────┐ │
│  │ Eureka    │  │  PostgreSQL    │  │  Redis   │  │ MinIO/  │ │
│  │ Discovery │  │  + PostGIS     │  │  Cache   │  │ S3      │ │
│  │           │  │                │  │  + Queue │  │ Files   │ │
│  └───────────┘  └────────────────┘  └──────────┘  └─────────┘ │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Integrações Externas                    │   │
│  │  ┌─────┐  ┌───────┐  ┌──────┐  ┌───────┐  ┌─────────┐  │   │
│  │  │ ANP │  │DETRAN │  │ IBGE │  │Google │  │Firebase │  │   │
│  │  │     │  │       │  │      │  │ Maps  │  │  Push   │  │   │
│  │  └─────┘  └───────┘  └──────┘  └───────┘  └─────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 10. API Pública para Integrações

### Endpoints Públicos (autenticados via API Key)

```yaml
# Dados de frota
GET  /api/public/v1/veiculos                    → Lista de veículos
GET  /api/public/v1/veiculos/{placa}            → Veículo por placa
GET  /api/public/v1/veiculos/{id}/consumo       → Histórico de consumo

# Abastecimentos
GET  /api/public/v1/abastecimentos              → Abastecimentos por período
POST /api/public/v1/abastecimentos/webhook      → Webhook para registro externo

# Relatórios
GET  /api/public/v1/relatorios/inventario       → Inventário de frota
GET  /api/public/v1/relatorios/custos           → Custos consolidados
GET  /api/public/v1/relatorios/tc/{estado}      → Relatório TC formatado

# GPS (para integração com rastreadores)
POST /api/public/v1/gps/posicao                 → Registrar posição
POST /api/public/v1/gps/posicao/batch           → Registrar lote de posições
GET  /api/public/v1/gps/veiculo/{id}/ultima     → Última posição

# Webhooks (recebimento)
POST /api/public/v1/webhooks/multa              → Receber multa (DETRAN)
POST /api/public/v1/webhooks/abastecimento      → Receber abastecimento (posto)
```

### Autenticação da API Pública

```java
@Entity
public class ApiKey extends AbstractTenantEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private String nome;
    private String chave;               // UUID gerado
    private String secreto;             // hash bcrypt
    private Boolean ativo = true;
    private LocalDate dataExpiracao;
    
    @ElementCollection
    private List<String> permissoes;    // READ_VEICULOS, WRITE_GPS, etc.
    
    @ElementCollection
    private List<String> ipsPermitidos; // whitelist de IPs
    
    private Integer limiteRequisicoes;  // por hora
}
```

---

## 11. Métricas de Sucesso (OKRs)

### OKR 1 — Redução de Custos Operacionais

| Resultado-Chave | Meta | Medição |
|-----------------|------|---------|
| Redução de gasto com combustível | 15-25% | Comparativo antes/depois |
| Redução de manutenção corretiva | 40% | Preventiva / (Preventiva + Corretiva) |
| Redução de tempo em prestação de contas | 80% | Horas gastas antes/depois |
| Detecção de anomalias de combustível | >90% dos desvios | Anomalias detectadas vs confirmadas |

### OKR 2 — Adoção e Engajamento

| Resultado-Chave | Meta | Medição |
|-----------------|------|---------|
| Municípios ativos | 50 no primeiro ano | Contas ativas |
| Usuários diários ativos | 70% dos cadastrados | DAU/MAU |
| Relatórios gerados/mês por município | >10 | Contagem |
| NPS (Net Promoter Score) | >70 | Pesquisa trimestral |

### OKR 3 — Compliance

| Resultado-Chave | Meta | Medição |
|-----------------|------|---------|
| Municípios sem ressalvas do TC | 80% dos clientes | Relatório TC |
| Exportações para TC geradas automaticamente | 100% | Automação |
| Veículos com documentação em dia | >95% | Dashboard |
| Motoristas com CNH válida | 100% | Bloqueio automático |

---

## 12. Estratégia de Go-to-Market

### Fase 1 — MVP Validado (Meses 1-3)

| Ação | Detalhes |
|------|---------|
| Clientes piloto | 3-5 municípios parceiros (gratuitos em troca de feedback) |
| Foco | Plano Essencial + Relatórios TC do estado piloto |
| Canal | Venda direta + associações de municípios |
| Pricing | Gratuito para pilotos |

### Fase 2 — Comercialização (Meses 4-8)

| Ação | Detalhes |
|------|---------|
| Lançamento | Planos Essencial e Profissional |
| Canais | Conta digital + feiras de gestão pública (CNM, FAMUP, etc.) |
| Pricing | R$ 3-8/veículo/mês (Essencial) · R$ 8-15/veículo/mês (Profissional) |
| Meta | 20 municípios pagantes |

### Fase 3 — Escala (Meses 9-18)

| Ação | Detalhes |
|------|---------|
| Lançamento | Plano Enterprise + App Mobile + GPS |
| Canais | Parcerias com empresas de TI que atendem prefeituras |
| Pricing | R$ 15-30/veículo/mês (Enterprise) + implantação |
| Meta | 100+ municípios |

### Modelo de Receita

| Receita | Tipo | Estimativa |
|---------|------|-----------|
| Assinatura mensal SaaS | Recorrente | R$ 3-30/veículo/mês |
| Implantação e treinamento | Única | R$ 2.000 - 15.000 por município |
| Customização | Sob demanda | R$ 150-250/hora |
| Suporte premium | Recorrente | 10-20% do valor da assinatura |
| Integrações (GPS hardware) | Comissão | 5-10% do hardware |

### Projeção de Receita (Conservadora)

| Período | Municípios | Veículos (média 30) | MRR | ARR |
|---------|-----------|---------------------|-----|-----|
| Mês 6 | 10 | 300 | R$ 3.000 | R$ 36.000 |
| Mês 12 | 30 | 900 | R$ 11.700 | R$ 140.400 |
| Mês 18 | 80 | 2.400 | R$ 36.000 | R$ 432.000 |
| Mês 24 | 150 | 4.500 | R$ 76.500 | R$ 918.000 |

---

## Conclusão

O eFrotas já possui uma base sólida com cadastros completos, fluxos de aprovação, transporte escolar e relatórios PDF. Com as melhorias propostas neste documento — especialmente **automação de combustível**, **manutenção preventiva**, **relatórios para TC** e **detecção de anomalias** — o sistema se posiciona como a solução mais completa do mercado brasileiro para gestão de frotas municipais.

O investimento estimado de 30-42 semanas de desenvolvimento tem potencial de retorno já no primeiro ano de comercialização, com a vantagem competitiva de ser o único sistema desenhado nativamente para as exigências do setor público brasileiro.

---

> **Documentos relacionados:**
> - [01-DOCUMENTACAO-SISTEMA-ATUAL.md](01-DOCUMENTACAO-SISTEMA-ATUAL.md) — Estado atual do sistema
> - [02-PLANO-APRIMORAMENTO-AUTOMACAO.md](02-PLANO-APRIMORAMENTO-AUTOMACAO.md) — Detalhamento técnico das melhorias
