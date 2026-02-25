# PLANO DE IMPLEMENTAÇÃO — Férias, Afastamentos, Rescisão, Processos e Portal do Servidor

**Data:** 20 de Fevereiro de 2026  
**Versão:** 3.0  
**Escopo:** 5 módulos novos (Backend + Frontend + Testes + Migrações)  
**Estimativa Total:** ~16-18 semanas (4-5 meses)

---

## STATUS GERAL DE IMPLEMENTAÇÃO

| Fase | Módulo | Status | Backend | Frontend | Relatórios | Testes | Observações |
|:----:|--------|:------:|:-------:|:--------:|:----------:|:------:|-------------|
| 1 | Férias | ✅ CONCLUÍDA | ✅ | ✅ | ✅ 2 JRXMLs | ⚠️ 5 classes (7 erros compilação pre-existentes) | Backend completo, frontend CRUD funcional |
| 2 | Afastamentos | ✅ CONCLUÍDA | ✅ | ✅ | ✅ 2 JRXMLs | ✅ 2 classes | Tudo implementado e integrado |
| 3 | Rescisão | ✅ CONCLUÍDA | ✅ | ✅ | ✅ 2 JRXMLs | ⬜ Testes pendentes | Backend + frontend + JRXML completos |
| 4 | Processos/Workflow | ✅ CONCLUÍDA | ✅ 42 Java | ✅ 6 arquivos | — | ⬜ Testes pendentes | 8 entidades, 10 enums, ~45 endpoints, BUILD SUCCESS |
| 5 | Portal Servidor | ⬜ PENDENTE | ⬜ | ⬜ | — | ⬜ | Depende Fase 4 (pronta). Infraestrutura preparada: `ProcessoCatalogoController`, `visivelPortal` |

### Correções aplicadas (pós Fase 1-2)
- **Relatórios JRXML:** Corrigido padrão visual para seguir FolhaPG (cores literais, `pageHeader` em vez de `title`, group headers com ▸, zebra striping, rodapé wsolucoes.com)
- **UUIDs JRXML:** Corrigido formato UUID inválido em todos os 4 relatórios (JasperReports exige formato 36-char)
- **previdencia.types.ts:** Revertidos campos `percentualMulta`, `percentualJurosMes`, `diasCarenciaMulta` do Instituto Previdência (agora configuráveis em Legislação)

---

## VISÃO GERAL DO PLANO

```
 FASE 1          FASE 2             FASE 3              FASE 4               FASE 5
┌──────────┐   ┌──────────────┐   ┌──────────────┐   ┌───────────────┐   ┌──────────────────┐
│  FÉRIAS   │──▶│ AFASTAMENTOS │──▶│   RESCISÃO   │──▶│  PROCESSOS /  │──▶│ PORTAL SERVIDOR  │
│ ✅ PRONTA  │   │  ✅ PRONTA    │   │  ✅ PRONTA   │   │  WORKFLOW     │   │  (autoatendim.)  │
└──────────┘   └──────────────┘   └──────────────┘   │  ✅ PRONTA    │   │   ⬜ PENDENTE     │
     │                │                  │            └───────────────┘   └──────────────────┘
     ▼                ▼                  ▼                   │                     │
  ✅ OK            ✅ OK              ✅ OK             ✅ OK               Testes E2E +
                                                                            Aceite Final
```

**Relação entre Processos e Portal:**
```
┌─────────────────────────────────────────────────────────────────────┐
│                    MÓDULO DE PROCESSOS (Fase 4)                     │
│                                                                     │
│  LADO RH (funcionários do eRH):                                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │ Configurar   │  │ Avaliar      │  │ Aprovar/Reprovar          │  │
│  │ modelos de   │  │ documentos   │  │ processos e dar           │  │
│  │ processos e  │  │ enviados     │  │ feedback ao               │  │
│  │ docs exigidos│  │              │  │ solicitante               │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
│                                                                     │
│  LADO SERVIDOR (funcionários da prefeitura):                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │ Consultar    │  │ Enviar docs  │  │ Acompanhar status e      │  │
│  │ processos    │  │ exigidos e   │  │ responder feedback        │  │
│  │ disponíveis  │  │ abrir        │  │ do RH                    │  │
│  │              │  │ solicitação  │  │                           │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    PORTAL DO SERVIDOR (Fase 5)                      │
│  Autoatendimento: contracheque, IR, ficha financeira,              │
│  saldo férias, notificações — CONSOME o módulo de processos        │
└─────────────────────────────────────────────────────────────────────┘
```

**Pré-requisitos** (resolver antes de iniciar):
- [ ] Resolver TODO #1: Cópia de vantagens/descontos no fechamento (`ProcessamentoFolhaService.java:2156`)
- [ ] Resolver TODO #8: `isFechada` no `CompetenciaService` (`CompetenciaController.java:116`)
- [ ] Renumerar migrações SQL conflitantes (V002/V004/V005)

---

## FASE 1 — MÓDULO DE FÉRIAS ✅ CONCLUÍDA

### 1.1 Modelo de Dados

#### Entidades a criar no pacote `ws.erh.temporal.ferias`

```java
// ===== PeriodoAquisitivo.java =====
@Entity
@Table(name = "periodo_aquisitivo")
public class PeriodoAquisitivo extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id", nullable = false)
    private VinculoFuncional vinculoFuncional;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;            // Início do período aquisitivo
    
    @Column(name = "data_fim", nullable = false)
    private LocalDate dataFim;               // Fim do período aquisitivo (12 meses)
    
    @Column(name = "dias_direito")
    private Integer diasDireito = 30;        // Dias de direito (padrão 30)
    
    @Column(name = "dias_gozados")
    private Integer diasGozados = 0;         // Dias já gozados
    
    @Column(name = "dias_abono_pecuniario")
    private Integer diasAbonoPecuniario = 0; // Dias convertidos em abono (max 10)
    
    @Column(name = "dias_perdidos")
    private Integer diasPerdidos = 0;        // Dias perdidos por falta/afastamento
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", nullable = false)
    private SituacaoPeriodoAquisitivo situacao; // ABERTO, COMPLETO, VENCIDO, PRESCRITO, INDENIZADO
    
    @Column(name = "data_limite_concessao")
    private LocalDate dataLimiteConcessao;   // dataFim + 12 meses
    
    @Column(name = "data_prescricao")
    private LocalDate dataPrescricao;        // dataFim + 5 anos (CF art. 7º, XXIX)
    
    @Column(name = "observacao")
    private String observacao;
    
    @OneToMany(mappedBy = "periodoAquisitivo", cascade = CascadeType.ALL)
    private List<ConcessaoFerias> concessoes;
}
```

```java
// ===== ConcessaoFerias.java =====
@Entity
@Table(name = "concessao_ferias")
public class ConcessaoFerias extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "periodo_aquisitivo_id", nullable = false)
    private PeriodoAquisitivo periodoAquisitivo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id", nullable = false)
    private VinculoFuncional vinculoFuncional;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;            // Início do gozo
    
    @Column(name = "data_fim", nullable = false)
    private LocalDate dataFim;               // Fim do gozo
    
    @Column(name = "dias_gozo", nullable = false)
    private Integer diasGozo;                // Dias de gozo nesta concessão
    
    @Column(name = "abono_pecuniario")
    private Boolean abonoPecuniario = false; // Converteu 1/3 em dinheiro?
    
    @Column(name = "dias_abono")
    private Integer diasAbono = 0;           // Dias de abono (max 10)
    
    @Column(name = "adiantamento_13")
    private Boolean adiantamento13 = false;  // Solicitou adiantamento do 13º?
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", nullable = false)
    private SituacaoConcessaoFerias situacao; // PROGRAMADA, APROVADA, EM_GOZO, GOZADA, CANCELADA, INTERROMPIDA
    
    @Column(name = "data_pagamento")
    private LocalDate dataPagamento;         // Deve ser até 2 dias antes do início (CLT art. 145)
    
    // === Valores calculados (preenchidos no processamento) ===
    @Column(name = "valor_ferias", precision = 15, scale = 2)
    private BigDecimal valorFerias;
    
    @Column(name = "valor_terco_constitucional", precision = 15, scale = 2)
    private BigDecimal valorTercoConstitucional;   // 1/3 de férias (CF art. 7º, XVII)
    
    @Column(name = "valor_abono_pecuniario", precision = 15, scale = 2)
    private BigDecimal valorAbonoPecuniario;
    
    @Column(name = "valor_terco_abono", precision = 15, scale = 2)
    private BigDecimal valorTercoAbono;            // 1/3 sobre o abono
    
    @Column(name = "valor_adiantamento_13", precision = 15, scale = 2)
    private BigDecimal valorAdiantamento13;
    
    @Column(name = "total_bruto", precision = 15, scale = 2)
    private BigDecimal totalBruto;
    
    @Column(name = "total_descontos", precision = 15, scale = 2)
    private BigDecimal totalDescontos;             // INSS/RPPS + IRRF sobre férias
    
    @Column(name = "total_liquido", precision = 15, scale = 2)
    private BigDecimal totalLiquido;
    
    // === Referência à folha ===
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folha_pagamento_det_id")
    private FolhaPagamentoDet folhaPagamentoDet;   // Link com item da folha
    
    @Column(name = "competencia_pagamento")
    private String competenciaPagamento;           // MM/YYYY da folha onde foi processado
    
    // === Controle ===
    @Column(name = "motivo_cancelamento")
    private String motivoCancelamento;
    
    @Column(name = "data_interrupcao")
    private LocalDate dataInterrupcao;             // Se interrompida (necessidade de serviço)
    
    @Column(name = "motivo_interrupcao")
    private String motivoInterrupcao;
    
    @Column(name = "observacao")
    private String observacao;
}
```

```java
// ===== ProgramacaoFerias.java =====
@Entity
@Table(name = "programacao_ferias")
public class ProgramacaoFerias extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "exercicio", nullable = false)
    private Integer exercicio;               // Ano da programação (ex: 2026)
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "departamento_rh_id")
    private DepartamentoRH departamento;     // Programação por departamento (opcional)
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao")
    private SituacaoProgramacao situacao;     // RASCUNHO, PUBLICADA, FINALIZADA
    
    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;
    
    @OneToMany(mappedBy = "programacaoFerias", cascade = CascadeType.ALL)
    private List<ProgramacaoFeriasItem> itens;
}

// ===== ProgramacaoFeriasItem.java =====
@Entity
@Table(name = "programacao_ferias_item")
public class ProgramacaoFeriasItem extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "programacao_ferias_id")
    private ProgramacaoFerias programacaoFerias;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id", nullable = false)
    private VinculoFuncional vinculoFuncional;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "periodo_aquisitivo_id", nullable = false)
    private PeriodoAquisitivo periodoAquisitivo;
    
    @Column(name = "data_inicio_prevista")
    private LocalDate dataInicioPrevista;
    
    @Column(name = "data_fim_prevista")
    private LocalDate dataFimPrevista;
    
    @Column(name = "dias_previstos")
    private Integer diasPrevistos;
    
    @Column(name = "abono_pecuniario_previsto")
    private Boolean abonoPecuniarioPrevisto = false;
    
    @Column(name = "observacao")
    private String observacao;
}
```

#### Enums

```java
public enum SituacaoPeriodoAquisitivo {
    ABERTO,      // Ainda não completou 12 meses
    COMPLETO,    // 12 meses completos, pode gozar
    VENCIDO,     // Passou do limite de concessão (dobra - art. 137 CLT / estatuto)
    PRESCRITO,   // Passou de 5 anos
    INDENIZADO   // Quitado em rescisão
}

public enum SituacaoConcessaoFerias {
    PROGRAMADA,    // Agendada na programação anual
    APROVADA,      // Aprovada pelo gestor
    EM_GOZO,       // Servidor em férias agora
    GOZADA,        // Completada
    CANCELADA,     // Cancelada antes do início
    INTERROMPIDA   // Interrompida por necessidade de serviço
}

public enum SituacaoProgramacao {
    RASCUNHO,    // Em elaboração
    PUBLICADA,   // Publicada para ciência dos servidores
    FINALIZADA   // Todas as férias do exercício concedidas
}
```

### 1.2 Regras de Negócio (Service Layer)

#### `FeriasService.java` — Regras principais

| Regra | Descrição | Base Legal |
|-------|-----------|------------|
| **Período aquisitivo** | 12 meses de exercício = direito a 30 dias (servidor público) | CF art. 7º, XVII; Estatuto Municipal |
| **1/3 constitucional** | Adicional obrigatório de 1/3 sobre remuneração de férias | CF art. 7º, XVII |
| **Abono pecuniário** | Servidor pode converter até 1/3 (10 dias) em dinheiro | CLT art. 143 (celetistas) / Estatuto |
| **Fracionamento** | Pode fracionar em até 3 períodos (mínimo 14 + 5 + 5 dias) | Reforma Trabalhista / Estatuto Municipal |
| **Limite concessão** | Deve ser concedida dentro de 12 meses após período aquisitivo | CLT art. 134 / Estatuto |
| **Férias vencidas** | Se não concedida no prazo, paga em dobro | CLT art. 137 |
| **Pagamento antecipado** | Pagamento até 2 dias antes do início | CLT art. 145 |
| **Perda de dias** | Mais de 32 faltas no período = perde proporcionalmente | CLT art. 130 |
| **Adiantamento 13º** | Pode solicitar 50% do 13º junto com férias | CLT art. 2º, Lei 4.749/65 |
| **Interrupção** | Férias podem ser interrompidas por necessidade imperiosa de serviço | Estatuto Municipal |

#### Cálculos

```
FÉRIAS NORMAIS:
  Base = Remuneração mensal do servidor (salário + vantagens fixas incidentes)
  Valor Férias = (Base / 30) × Dias de Gozo
  Terço Constitucional = Valor Férias / 3
  
ABONO PECUNIÁRIO:
  Valor Abono = (Base / 30) × Dias de Abono (max 10)
  Terço Abono = Valor Abono / 3

DESCONTOS:
  Base Previdência = Valor Férias + Terço Constitucional (abono é isento)
  INSS/RPPS = calcular conforme faixas da Legislação vigente
  Base IRRF = (Valor Férias + Terço) - INSS/RPPS - Dependentes
  IRRF = calcular conforme faixas da Legislação vigente
  
  ** Abono pecuniário e seu 1/3 são ISENTOS de IRRF (Art. 25 da Lei 7.713/88)

TOTAL:
  Bruto = Férias + Terço + Abono + Terço Abono + Adiant. 13º
  Descontos = INSS/RPPS + IRRF
  Líquido = Bruto - Descontos
```

### 1.3 Endpoints REST

```
POST   /api/v1/ferias/periodos-aquisitivos/gerar/{vinculoFuncionalId}  → Gerar períodos automáticos
GET    /api/v1/ferias/periodos-aquisitivos                             → Listar (paginado, filtros)
GET    /api/v1/ferias/periodos-aquisitivos/{id}                        → Detalhar
GET    /api/v1/ferias/periodos-aquisitivos/vinculo/{vinculoId}         → Por vínculo (saldo)
PUT    /api/v1/ferias/periodos-aquisitivos/{id}                        → Atualizar (dias perdidos, obs)

POST   /api/v1/ferias/concessoes                                       → Conceder férias
GET    /api/v1/ferias/concessoes                                       → Listar (paginado, filtros)
GET    /api/v1/ferias/concessoes/{id}                                  → Detalhar
PUT    /api/v1/ferias/concessoes/{id}                                  → Atualizar
PUT    /api/v1/ferias/concessoes/{id}/aprovar                          → Aprovar concessão
PUT    /api/v1/ferias/concessoes/{id}/cancelar                         → Cancelar
PUT    /api/v1/ferias/concessoes/{id}/interromper                      → Interromper
GET    /api/v1/ferias/concessoes/{id}/recibo                           → PDF do recibo de férias
POST   /api/v1/ferias/concessoes/{id}/calcular                        → Calcular valores (preview)
POST   /api/v1/ferias/concessoes/{id}/processar                       → Processar na folha

POST   /api/v1/ferias/programacao                                      → Criar programação anual
GET    /api/v1/ferias/programacao                                      → Listar programações
GET    /api/v1/ferias/programacao/{id}                                 → Detalhar com itens
PUT    /api/v1/ferias/programacao/{id}                                 → Atualizar
POST   /api/v1/ferias/programacao/{id}/publicar                       → Publicar
POST   /api/v1/ferias/programacao/{id}/itens                          → Adicionar item
PUT    /api/v1/ferias/programacao/itens/{itemId}                       → Atualizar item
DELETE /api/v1/ferias/programacao/itens/{itemId}                       → Remover item

GET    /api/v1/ferias/dashboard                                        → Indicadores (vencidas, a vencer, em gozo)
GET    /api/v1/ferias/relatorio/programacao                            → Relatório de programação anual
GET    /api/v1/ferias/relatorio/controle                               → Relatório de controle de férias
```

### 1.4 Frontend — Páginas e Componentes

#### Novas rotas:

```
/e-RH/ferias/                          → Dashboard de férias (cards: em gozo, vencidas, a vencer)
/e-RH/ferias/concessao/                → Tela de concessão (CRUD + cálculo)
/e-RH/ferias/programacao/              → Programação anual (calendário visual)
/e-RH/ferias/periodos-aquisitivos/     → Consulta de períodos aquisitivos por servidor
```

#### Telas detalhadas:

**1. Dashboard de Férias** (`/e-RH/ferias/`)
- Card: Servidores em gozo de férias (hoje)
- Card: Férias vencidas (urgente — em vermelho)
- Card: Férias a vencer nos próximos 30/60/90 dias
- Card: Programação do mês
- Tabela resumo com servidor, período aquisitivo, dias restantes, situação

**2. Concessão de Férias** (`/e-RH/ferias/concessao/`)
- Tabela com todas as concessões (filtro por situação, servidor, departamento)
- Modal/Formulário de nova concessão:
  - Select: Servidor (com busca) → auto-preenche dados do vínculo
  - Select: Período Aquisitivo (lista os disponíveis com saldo)
  - DatePicker: Data Início / Data Fim (auto-calcula dias)
  - Checkbox: Abono Pecuniário (se sim, campo "dias de abono" — max 10)
  - Checkbox: Adiantamento de 13º Salário
  - **Preview de cálculo** (chama endpoint `/calcular` em tempo real):
    - Remuneração Base
    - Valor Férias
    - 1/3 Constitucional
    - Abono Pecuniário + 1/3 Abono
    - Adiantamento 13º
    - (-) INSS/RPPS
    - (-) IRRF
    - **= Total Líquido**
  - Botão: Salvar como Programada / Aprovar e Processar

**3. Programação Anual** (`/e-RH/ferias/programacao/`)
- Filtro por exercício (ano) e departamento
- Visão de calendário (timeline horizontal, meses nas colunas, servidores nas linhas)
- Drag & drop para ajustar períodos
- Indicação visual de conflitos (sobreposição de servidores do mesmo setor)
- Botão publicar (envia notificação aos servidores)

**4. Períodos Aquisitivos** (`/e-RH/ferias/periodos-aquisitivos/`)
- Tabela por servidor com todos os períodos
- Colunas: Servidor | Período | Direito | Gozado | Saldo | Situação | Ações
- Badges coloridos: COMPLETO(verde), VENCIDO(vermelho), ABERTO(azul)
- Ação: "Conceder Férias" → abre modal de concessão

### 1.5 Migração SQL

```sql
-- V011__modulo_ferias.sql

-- Período Aquisitivo
CREATE TABLE periodo_aquisitivo (
    id BIGSERIAL PRIMARY KEY,
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    dias_direito INTEGER DEFAULT 30,
    dias_gozados INTEGER DEFAULT 0,
    dias_abono_pecuniario INTEGER DEFAULT 0,
    dias_perdidos INTEGER DEFAULT 0,
    situacao VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
    data_limite_concessao DATE,
    data_prescricao DATE,
    observacao TEXT,
    -- Campos tenant
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Concessão de Férias
CREATE TABLE concessao_ferias (
    id BIGSERIAL PRIMARY KEY,
    periodo_aquisitivo_id BIGINT NOT NULL REFERENCES periodo_aquisitivo(id),
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    dias_gozo INTEGER NOT NULL,
    abono_pecuniario BOOLEAN DEFAULT FALSE,
    dias_abono INTEGER DEFAULT 0,
    adiantamento_13 BOOLEAN DEFAULT FALSE,
    situacao VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',
    data_pagamento DATE,
    -- Valores calculados
    valor_ferias NUMERIC(15,2),
    valor_terco_constitucional NUMERIC(15,2),
    valor_abono_pecuniario NUMERIC(15,2),
    valor_terco_abono NUMERIC(15,2),
    valor_adiantamento_13 NUMERIC(15,2),
    total_bruto NUMERIC(15,2),
    total_descontos NUMERIC(15,2),
    total_liquido NUMERIC(15,2),
    -- Referência à folha
    folha_pagamento_det_id BIGINT REFERENCES folhapagamentodet(id),
    competencia_pagamento VARCHAR(7),
    -- Controle
    motivo_cancelamento TEXT,
    data_interrupcao DATE,
    motivo_interrupcao TEXT,
    observacao TEXT,
    -- Campos tenant
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Programação Anual
CREATE TABLE programacao_ferias (
    id BIGSERIAL PRIMARY KEY,
    exercicio INTEGER NOT NULL,
    departamento_rh_id BIGINT REFERENCES departamento_rh(id),
    situacao VARCHAR(20) DEFAULT 'RASCUNHO',
    data_publicacao DATE,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE programacao_ferias_item (
    id BIGSERIAL PRIMARY KEY,
    programacao_ferias_id BIGINT NOT NULL REFERENCES programacao_ferias(id),
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    periodo_aquisitivo_id BIGINT NOT NULL REFERENCES periodo_aquisitivo(id),
    data_inicio_prevista DATE,
    data_fim_prevista DATE,
    dias_previstos INTEGER,
    abono_pecuniario_previsto BOOLEAN DEFAULT FALSE,
    observacao TEXT,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rubricas padrão de férias
INSERT INTO vantagem_desconto (codigo, descricao, natureza, tipo_calculo, incide_inss, incide_irrf, ativo, unidade_gestora_id)
VALUES 
    ('FER', 'Férias', 'V', 'AUTOMATICO', true, true, true, null),
    ('FER13', '1/3 Constitucional de Férias', 'V', 'AUTOMATICO', true, true, true, null),
    ('FERAB', 'Abono Pecuniário de Férias', 'V', 'AUTOMATICO', false, false, true, null),
    ('FERAB13', '1/3 sobre Abono Pecuniário', 'V', 'AUTOMATICO', false, false, true, null);

-- Índices
CREATE INDEX idx_periodo_aquisitivo_vinculo ON periodo_aquisitivo(vinculo_funcional_id);
CREATE INDEX idx_periodo_aquisitivo_situacao ON periodo_aquisitivo(situacao);
CREATE INDEX idx_concessao_ferias_vinculo ON concessao_ferias(vinculo_funcional_id);
CREATE INDEX idx_concessao_ferias_periodo ON concessao_ferias(periodo_aquisitivo_id);
CREATE INDEX idx_concessao_ferias_situacao ON concessao_ferias(situacao);
CREATE INDEX idx_concessao_ferias_datas ON concessao_ferias(data_inicio, data_fim);
CREATE INDEX idx_programacao_ferias_exercicio ON programacao_ferias(exercicio);
```

### 1.6 Testes (Backend)

| Classe de Teste | O que testa | Qtd estimada |
|-----------------|-------------|:---:|
| `PeriodoAquisitivoServiceTest` | Geração automática, cálculo de saldo, situações, perda de dias | 12 |
| `ConcessaoFeriasServiceTest` | Cálculo de valores (1/3, abono, IRRF, INSS), fracionamento, validações | 20 |
| `FeriasCalculoServiceTest` | Cálculo isolado: base, 1/3, abono pecuniário, descontos | 15 |
| `ProgramacaoFeriasServiceTest` | CRUD programação, conflitos, publicação | 8 |
| `FeriasControllerTest` | Endpoints REST (MockMvc) | 10 |
| **Total** | | **~65 testes** |

**Cenários críticos a testar:**
- Férias de 30 dias (caso padrão)
- Férias fracionadas (14 + 10 + 6 dias)
- Com abono pecuniário (20 dias gozo + 10 abono)
- Com adiantamento de 13º
- Servidor RPPS vs RGPS (previdências diferentes)
- Férias vencidas (verificar dobra se aplicável)
- Interrupção de férias (recalcular saldo)
- Perda de dias por faltas (>32 faltas)

### 1.7 Integração com Folha de Pagamento

A integração funciona assim:

```
1. Concessão aprovada (situacao = APROVADA)
      │
      ▼
2. No processamento da folha (ProcessamentoFolhaService):
      │
      ├─ Buscar concessões com competencia_pagamento = competência atual
      │  e situacao IN (APROVADA, EM_GOZO)
      │
      ├─ Para cada concessão:
      │     ├─ Lançar rubrica FER (Férias) = valorFerias
      │     ├─ Lançar rubrica FER13 (1/3 Constitucional) = valorTercoConstitucional
      │     ├─ Se abonoPecuniario:
      │     │     ├─ Lançar rubrica FERAB = valorAbonoPecuniario
      │     │     └─ Lançar rubrica FERAB13 = valorTercoAbono
      │     ├─ Se adiantamento13:
      │     │     └─ Lançar rubrica ADT13 = valorAdiantamento13
      │     ├─ Calcular INSS/RPPS sobre (férias + 1/3)
      │     └─ Calcular IRRF sobre (férias + 1/3 - previdência - dependentes)
      │
      └─ Vincular FolhaPagamentoDet à ConcessaoFerias
```

### 1.8 Checklist de Entrega — Fase 1

```
BACKEND:
  [x] Criar pacote ws.erh.cadastro.ferias (model, dto, repository, service, controller)
  [x] Implementar entidades: PeriodoAquisitivo, ConcessaoFerias, ProgramacaoFerias, ProgramacaoFeriasItem
  [x] Implementar enums: SituacaoPeriodoAquisitivo, SituacaoConcessaoFerias, SituacaoProgramacao
  [x] Implementar FeriasService (regras de negócio, cálculos)
  [x] Implementar FeriasCalculoService (cálculo isolado: base, 1/3, descontos)
  [x] Implementar PeriodoAquisitivoService (geração automática, controle de saldo)
  [x] Implementar ProgramacaoFeriasService (CRUD programação anual)
  [x] Implementar FeriasController (~25 endpoints)
  [x] Integrar com ProcessamentoFolhaService (lançar rubricas de férias na folha)
  [x] Criar migração SQL V011__modulo_ferias.sql
  [x] Criar relatório Jasper: Recibo de Férias (ReciboFerias.jrxml)
  [x] Criar relatório Jasper: Controle de Férias (ControleFerias.jrxml)
  [x] Testes unitários (PeriodoAquisitivoServiceTest, ConcessaoFeriasServiceTest, ProgramacaoFeriasServiceTest, FeriasCalculoServiceTest, FeriasControllerTest)

FRONTEND:
  [x] Criar rota /e-RH/lancamento/ferias/ (CRUD concessão de férias)
  [ ] Criar rota /e-RH/ferias/programacao/ (timeline visual)
  [ ] Criar rota /e-RH/ferias/periodos-aquisitivos/ (consulta de saldos)
  [x] Criar configs: ferias.config.ts (endpoint, colunas, formulário)
  [x] Criar types: ferias.types.ts com mapeamento API↔Form
  [ ] Criar ferias.api.ts (service de API separado)
  [x] Adicionar menu "Férias" no sidebar do e-RH
  [ ] Componente de preview de cálculo de férias (CalcPreviewFerias)
  [ ] Componente de timeline de programação (TimelineFerias)

VALIDAÇÃO:
  [ ] Testar cenários de cálculo com valores reais
  [ ] Validar integração férias → folha de pagamento
  [ ] Testar fracionamento (3 períodos)
  [ ] Testar abono pecuniário + IRRF isento
  [ ] Testar férias vencidas (alerta visual)
  [ ] Validar relatório PDF (recibo de férias)
```

---

## FASE 2 — MÓDULO DE AFASTAMENTOS ✅ CONCLUÍDA

### 2.1 Modelo de Dados

#### Entidades no pacote `ws.erh.temporal.afastamento`

```java
// ===== TipoAfastamento.java =====
@Entity
@Table(name = "tipo_afastamento")
public class TipoAfastamento extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "codigo", nullable = false, unique = true)
    private String codigo;                   // Ex: LIC_SAUDE, LIC_MATERNIDADE
    
    @Column(name = "descricao", nullable = false)
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "categoria")
    private CategoriaAfastamento categoria;  // LICENCA, SUSPENSAO, CESSAO, OUTROS
    
    @Column(name = "dias_limite")
    private Integer diasLimite;              // Máximo de dias (null = ilimitado)
    
    @Column(name = "remunerado")
    private Boolean remunerado = true;       // Mantém remuneração?
    
    @Column(name = "conta_tempo_servico")
    private Boolean contaTempoServico = true;  // Conta para aposentadoria/quinquênio?
    
    @Column(name = "conta_periodo_aquisitivo_ferias")
    private Boolean contaPeriodoAquisitivoFerias = true; // Conta para férias?
    
    @Column(name = "suspende_contrato")
    private Boolean suspendeContrato = false;
    
    @Column(name = "codigo_esocial")
    private String codigoEsocial;            // Código da tabela 18 do eSocial
    
    @Column(name = "codigo_rais")
    private Integer codigoRais;              // Código de afastamento RAIS
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

```java
// ===== Afastamento.java =====
@Entity
@Table(name = "afastamento")
public class Afastamento extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id", nullable = false)
    private VinculoFuncional vinculoFuncional;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_afastamento_id", nullable = false)
    private TipoAfastamento tipoAfastamento;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;               // null = indeterminado
    
    @Column(name = "data_retorno")
    private LocalDate dataRetorno;           // Data efetiva de retorno
    
    @Column(name = "dias_afastamento")
    private Integer diasAfastamento;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", nullable = false)
    private SituacaoAfastamento situacao;    // ATIVO, ENCERRADO, CANCELADO, PRORROGADO
    
    // === Documentação ===
    @Column(name = "numero_documento")
    private String numeroDocumento;          // Nº do atestado/portaria/decreto
    
    @Column(name = "orgao_emissor")
    private String orgaoEmissor;             // Quem emitiu (médico, INSS, etc.)
    
    @Column(name = "cid")
    private String cid;                      // CID-10 (para licenças de saúde)
    
    @Column(name = "crm_medico")
    private String crmMedico;
    
    @Column(name = "nome_medico")
    private String nomeMedico;
    
    // === Impacto financeiro ===
    @Column(name = "remunerado")
    private Boolean remunerado;              // Herda do tipo, mas pode ser sobrescrito
    
    @Column(name = "percentual_remuneracao")
    private BigDecimal percentualRemuneracao; // 100%, 66.67% (2/3), etc.
    
    @Column(name = "responsavel_pagamento")
    @Enumerated(EnumType.STRING)
    private ResponsavelPagamento responsavelPagamento; // ORGAO, INSS, RPPS
    
    @Column(name = "dias_orgao")
    private Integer diasOrgao;               // Primeiros N dias pagos pelo órgão
    
    @Column(name = "dias_previdencia")
    private Integer diasPrevidencia;         // Dias restantes pagos pela previdência
    
    // === eSocial ===
    @Column(name = "enviado_esocial")
    private Boolean enviadoEsocial = false;
    
    @Column(name = "recibo_esocial")
    private String reciboEsocial;            // Recibo do evento S-2230
    
    // === Prorrogação (link para afastamento original) ===
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "afastamento_original_id")
    private Afastamento afastamentoOriginal;
    
    @Column(name = "observacao")
    private String observacao;
}
```

#### Enums

```java
public enum CategoriaAfastamento {
    LICENCA,       // Licenças legais (saúde, maternidade, prêmio, etc.)
    SUSPENSAO,     // Suspensões disciplinares
    CESSAO,        // Cessão/Requisição para outro órgão
    OUTROS         // Outros (serviço militar, mandato eletivo, etc.)
}

public enum SituacaoAfastamento {
    ATIVO,         // Em andamento
    ENCERRADO,     // Finalizado normalmente
    CANCELADO,     // Cancelado
    PRORROGADO     // Prorrogado (novo registro vinculado)
}

public enum ResponsavelPagamento {
    ORGAO,         // Órgão empregador paga
    INSS,          // INSS paga (auxílio-doença após 15 dias)
    RPPS           // Regime Próprio paga
}
```

### 2.2 Tipos de Afastamento (Seed)

| Código | Descrição | Remunerado | Conta Tempo | Conta Férias | Limite | eSocial |
|--------|-----------|:---:|:---:|:---:|:---:|:---:|
| `LIC_SAUDE` | Licença para Tratamento de Saúde | Sim | Sim | Sim* | 24m | 01 |
| `LIC_MATERNIDADE` | Licença Maternidade | Sim | Sim | Sim | 120-180d | 17 |
| `LIC_PATERNIDADE` | Licença Paternidade | Sim | Sim | Sim | 5-20d | 19 |
| `LIC_ACIDENTE` | Licença por Acidente em Serviço | Sim | Sim | Sim | s/lim | 01 |
| `LIC_PREMIO` | Licença Prêmio | Sim | Não | Não | 90d | 21 |
| `LIC_INTERESSE` | Licença para Interesse Particular | Não | Não | Não | 24m | 15 |
| `LIC_CAPACITACAO` | Licença para Capacitação | Sim | Sim | Sim | 90d | 21 |
| `LIC_LUTO` | Licença por Falecimento (Nojo) | Sim | Sim | Sim | 8d | 19 |
| `LIC_CASAMENTO` | Licença Casamento (Gala) | Sim | Sim | Sim | 8d | 19 |
| `SUSP_DISCIPLINAR` | Suspensão Disciplinar | Não | Não | Não* | 90d | 24 |
| `CESSAO` | Cessão para Outro Órgão | Variável | Sim | Variável | s/lim | 14 |
| `SVC_MILITAR` | Serviço Militar Obrigatório | Sim | Sim | Não | 12m | 05 |
| `MANDATO_ELETIVO` | Exercício de Mandato Eletivo | Não | Sim | Não | 4a | 16 |

*Regras específicas por estatuto municipal

### 2.3 Endpoints REST

```
-- TipoAfastamento (configuração)
GET    /api/v1/afastamento/tipos                                → Listar tipos
POST   /api/v1/afastamento/tipos                                → Criar tipo
PUT    /api/v1/afastamento/tipos/{id}                           → Atualizar tipo

-- Afastamento (operacional)
POST   /api/v1/afastamento                                      → Registrar afastamento
GET    /api/v1/afastamento                                      → Listar (paginado, filtros)
GET    /api/v1/afastamento/{id}                                 → Detalhar
PUT    /api/v1/afastamento/{id}                                 → Atualizar
PUT    /api/v1/afastamento/{id}/encerrar                        → Encerrar (registrar retorno)
PUT    /api/v1/afastamento/{id}/cancelar                        → Cancelar
POST   /api/v1/afastamento/{id}/prorrogar                       → Prorrogar (cria novo vinculado)
GET    /api/v1/afastamento/vinculo/{vinculoId}                  → Histórico por vínculo
GET    /api/v1/afastamento/vigentes                             → Afastamentos ativos hoje
GET    /api/v1/afastamento/vigentes/{competencia}               → Afastamentos na competência

-- Dashboard / Relatórios
GET    /api/v1/afastamento/dashboard                            → Indicadores
GET    /api/v1/afastamento/relatorio                            → Relatório (filtros: período, tipo, depto)
```

### 2.4 Impacto na Folha

```
No processamento da folha:
  1. Buscar afastamentos ATIVOS na competência
  2. Para cada servidor afastado:
     a. Se remunerado = true e responsavel = ORGAO:
        → Mantém remuneração normal (100% ou percentual)
        → Se percentual < 100%: reduz rubricas proporcionalmente
     b. Se remunerado = true e responsavel = INSS/RPPS:
        → Zera remuneração a partir do dia que previdência assume
        → Ex: Licença saúde > 15 dias → órgão paga 15, INSS paga o resto
     c. Se remunerado = false:
        → Suspende todas as rubricas (exceto rubricas com incide_afastamento = true)
  3. Registrar na FolhaPagamentoDet a referência ao afastamento
  4. Impacto no período aquisitivo de férias:
     → Se !contaPeriodoAquisitivoFerias: pausar contagem
```

### 2.5 Frontend

```
/e-RH/afastamento/                     → Dashboard + lista de afastamentos ativos
/e-RH/afastamento/registro/            → Registro/edição de afastamento
/e-RH/configuracao/tipo-afastamento/   → CRUD de tipos de afastamento
```

**Tela principal:** Tabela com filtros (servidor, tipo, situação, período) + ações (encerrar, prorrogar, cancelar). Modal de registro com campos condicionais (CID e CRM aparecem só para licençça de saúde).

### 2.6 Checklist de Entrega — Fase 2

```
BACKEND:
  [x] Criar pacote ws.erh.cadastro.afastamento (model, dto, repository, service, controller)
  [x] Implementar entidades: Afastamento, TipoAfastamento
  [x] Implementar enums: CategoriaAfastamento, SituacaoAfastamento, ResponsavelPagamento
  [x] Implementar AfastamentoService (regras, impacto folha, prorrogação)
  [x] Implementar TipoAfastamentoService (CRUD + validações)
  [x] Implementar AfastamentoController (~15 endpoints)
  [x] Integrar com ProcessamentoFolhaService (suspensão/redução de rubricas)
  [x] Integrar com PeriodoAquisitivoService (pausar contagem de férias)
  [x] Criar migração SQL V012__modulo_afastamento.sql
  [x] Seed de tipos de afastamento (13 tipos)
  [x] Testes unitários (TipoAfastamentoServiceTest + AfastamentoServiceTest)
  [x] Registrar serviços no Facade.java
  [x] Criar RelatorioAfastamentos.jrxml (listagem por lotação)
  [x] Criar ComprovanteAfastamento.jrxml (comprovante individual)

FRONTEND:
  [x] Criar rota /e-RH/lancamento/afastamento/ (CRUD + lista)
  [x] Criar afastamento.types.ts + afastamento.config.ts
  [x] Criar rota /e-RH/configuracao/tipo-afastamento/
  [x] Criar tipoAfastamento.types.ts + tipoAfastamento.config.ts
  [x] Adicionar menu "Afastamentos" no sidebar (Lançamentos + Configuração)

VALIDAÇÃO:
  [ ] Testar licença de saúde (15 dias órgão + INSS)
  [ ] Testar licença maternidade (120/180 dias)
  [ ] Testar afastamento não remunerado → impacto na folha
  [ ] Testar prorrogação (vinculação)
  [ ] Testar impacto no período aquisitivo de férias
  [ ] Validar códigos eSocial para S-2230
```

---

## FASE 3 — MÓDULO DE RESCISÃO / DESLIGAMENTO ✅ CONCLUÍDA

### 3.1 Modelo de Dados

#### Entidades no pacote `ws.erh.carreira.rescisao`

```java
// ===== MotivoDesligamento.java =====
@Entity
@Table(name = "motivo_desligamento")
public class MotivoDesligamento extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "codigo", nullable = false, unique = true)
    private String codigo;
    
    @Column(name = "descricao", nullable = false)
    private String descricao;
    
    @Column(name = "codigo_esocial")
    private String codigoEsocial;            // Tabela 19 eSocial
    
    @Column(name = "codigo_rais")
    private Integer codigoRais;              // Código RAIS
    
    @Column(name = "codigo_tce")
    private String codigoTce;               // Código TCE-PE
    
    @Column(name = "tipo_rescisao")
    @Enumerated(EnumType.STRING)
    private TipoRescisao tipoRescisao;       // VOLUNTARIA, INVOLUNTARIA, TERMINO_CONTRATO, etc.
    
    @Column(name = "gera_ferias_proporcionais")
    private Boolean geraFeriasProporcionais = true;
    
    @Column(name = "gera_13_proporcional")
    private Boolean gera13Proporcional = true;
    
    @Column(name = "gera_ferias_vencidas")
    private Boolean geraFeriasVencidas = true;
    
    @Column(name = "gera_aviso_previo")
    private Boolean geraAvisoPrevio = false;  // Normalmente não para servidor público
    
    @Column(name = "gera_multa_fgts")
    private Boolean geraMultaFgts = false;    // Não aplicável para estatutários
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

```java
// ===== Rescisao.java =====
@Entity
@Table(name = "rescisao")
public class Rescisao extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id", nullable = false)
    private VinculoFuncional vinculoFuncional;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "motivo_desligamento_id", nullable = false)
    private MotivoDesligamento motivoDesligamento;
    
    @Column(name = "data_desligamento", nullable = false)
    private LocalDate dataDesligamento;
    
    @Column(name = "data_aviso_previo")
    private LocalDate dataAvisoPrevio;       // Se aplicável
    
    @Column(name = "numero_ato")
    private String numeroAto;               // Nº da portaria/decreto de exoneração
    
    @Column(name = "data_publicacao_ato")
    private LocalDate dataPublicacaoAto;     // Data de publicação no DO
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", nullable = false)
    private SituacaoRescisao situacao;       // RASCUNHO, CALCULADA, HOMOLOGADA, PAGA, CANCELADA
    
    // === Verbas Rescisórias Calculadas ===
    @Column(name = "saldo_salario", precision = 15, scale = 2)
    private BigDecimal saldoSalario;                // Dias trabalhados no mês
    
    @Column(name = "dias_saldo_salario")
    private Integer diasSaldoSalario;
    
    @Column(name = "ferias_vencidas", precision = 15, scale = 2)
    private BigDecimal feriasVencidas;               // Períodos completos não gozados
    
    @Column(name = "terco_ferias_vencidas", precision = 15, scale = 2)
    private BigDecimal tercoFeriasVencidas;
    
    @Column(name = "ferias_proporcionais", precision = 15, scale = 2)
    private BigDecimal feriasProporcionais;           // Proporcional do período em curso
    
    @Column(name = "terco_ferias_proporcionais", precision = 15, scale = 2)
    private BigDecimal tercoFeriasProporcionais;
    
    @Column(name = "meses_ferias_proporcionais")
    private Integer mesesFeriasProporcionais;         // Avos de férias (x/12)
    
    @Column(name = "decimo_terceiro_proporcional", precision = 15, scale = 2)
    private BigDecimal decimoTerceiroProporcional;    // x/12 do 13º
    
    @Column(name = "meses_13_proporcional")
    private Integer meses13Proporcional;              // Avos de 13º
    
    @Column(name = "decimo_terceiro_integral", precision = 15, scale = 2)
    private BigDecimal decimoTerceiroIntegral;        // Se desligou após dez, paga integral
    
    @Column(name = "aviso_previo_indenizado", precision = 15, scale = 2)
    private BigDecimal avisoPrevioIndenizado;         // Se aplicável (celetista)
    
    @Column(name = "outras_vantagens", precision = 15, scale = 2)
    private BigDecimal outrasVantagens;               // Outras vantagens a pagar
    
    @Column(name = "descricao_outras_vantagens")
    private String descricaoOutrasVantagens;
    
    // === Descontos ===
    @Column(name = "desconto_inss_rpps", precision = 15, scale = 2)
    private BigDecimal descontoInssRpps;
    
    @Column(name = "desconto_irrf", precision = 15, scale = 2)
    private BigDecimal descontoIrrf;
    
    @Column(name = "desconto_adiantamento_13", precision = 15, scale = 2)
    private BigDecimal descontoAdiantamento13;        // Devolver adiantamento recebido
    
    @Column(name = "desconto_faltas", precision = 15, scale = 2)
    private BigDecimal descontoFaltas;
    
    @Column(name = "outros_descontos", precision = 15, scale = 2)
    private BigDecimal outrosDescontos;
    
    @Column(name = "descricao_outros_descontos")
    private String descricaoOutrosDescontos;
    
    // === Totais ===
    @Column(name = "total_bruto", precision = 15, scale = 2)
    private BigDecimal totalBruto;
    
    @Column(name = "total_descontos", precision = 15, scale = 2)
    private BigDecimal totalDescontos;
    
    @Column(name = "total_liquido", precision = 15, scale = 2)
    private BigDecimal totalLiquido;
    
    // === Referências ===
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "folha_pagamento_id")
    private FolhaPagamento folhaPagamento;   // Folha rescisória
    
    @Column(name = "competencia_pagamento")
    private String competenciaPagamento;
    
    // === eSocial ===
    @Column(name = "enviado_esocial")
    private Boolean enviadoEsocial = false;
    
    @Column(name = "recibo_esocial")
    private String reciboEsocial;            // Recibo do evento S-2299
    
    // === Documentação ===
    @Column(name = "data_homologacao")
    private LocalDate dataHomologacao;
    
    @Column(name = "observacao")
    private String observacao;
}
```

#### Enums

```java
public enum TipoRescisao {
    EXONERACAO_PEDIDO,         // Exoneração a pedido do servidor
    EXONERACAO_OFICIO,         // Exoneração de ofício (não aprovação em estágio probatório)
    DEMISSAO,                  // Demissão por justa causa (PAD)
    APOSENTADORIA,             // Aposentadoria (compulsória, voluntária, invalidez)
    FALECIMENTO,               // Óbito do servidor
    TERMINO_CONTRATO,          // Fim de contrato temporário
    CASSACAO,                  // Cassação de aposentadoria
    DESTITUICAO_CARGO,         // Destituição de cargo em comissão
    VACANCIA_POSSE_OUTRO,      // Vacância por posse em outro cargo inacumulável
    READAPTACAO,               // Readaptação (não é desligamento, mas muda status)
    OUTROS                     // Outros motivos
}

public enum SituacaoRescisao {
    RASCUNHO,      // Em preenchimento
    CALCULADA,     // Valores calculados (preview)
    HOMOLOGADA,    // Homologada (conferida e assinada)
    PAGA,          // Verbas pagas ao servidor
    CANCELADA      // Cancelada/Revertida
}
```

### 3.2 Regras de Negócio

#### Cálculo Rescisório

```
SALDO DE SALÁRIO:
  Dias trabalhados = dataDesligamento.getDayOfMonth()
  Saldo = (Remuneração / 30) × Dias trabalhados

FÉRIAS VENCIDAS (períodos completos não gozados):
  Para cada PeriodoAquisitivo com situacao IN (COMPLETO, VENCIDO):
    Saldo = diasDireito - diasGozados - diasAbonoPecuniario
    Valor = (Remuneração / 30) × Saldo
    Terço = Valor / 3
  → Indenizar todos os períodos

FÉRIAS PROPORCIONAIS (período em curso):
  Meses = meses completos desde início do período aquisitivo até desligamento
  Se Meses ≥ 1:
    Avos = Meses / 12
    Valor = Remuneração × Avos
    Terço = Valor / 3
  *Observação: Se trabalhou > 14 dias no mês, conta como mês completo

13º PROPORCIONAL:
  Meses = meses trabalhados no ano até o desligamento
  Se Meses ≥ 1:
    Valor = (Remuneração / 12) × Meses
    (-) Adiantamento 13º já recebido
  *Nota: Se trabalhou > 14 dias no mês, conta como mês completo

DESCONTOS:
  INSS/RPPS sobre saldo de salário + 13º proporcional
  IRRF sobre total tributável
  Devolver adiantamento de 13º recebido (se houver)
  Devolver férias gozadas a maior (se houver — raro)
  Descontar faltas não justificadas
  Descontar consignações pendentes (se motivo permitir)

TOTAL:
  Bruto = Saldo + Férias Vencidas + 1/3 Vencidas + Férias Proporcionais 
        + 1/3 Proporcionais + 13º Proporcional + Outras Vantagens
  Descontos = INSS + IRRF + Adiant.13 + Faltas + Consignações + Outros
  Líquido = Bruto - Descontos
```

#### Fluxo do Processo

```
1. INICIAR RESCISÃO
   ├─ Informar: Servidor, Data Desligamento, Motivo, Nº do Ato
   ├─ Validar: Servidor ativo? Tem afastamento ativo? Tem férias em gozo?
   │     └─ Se em férias: interromper férias automaticamente
   └─ Criar registro com situacao = RASCUNHO

2. CALCULAR
   ├─ Buscar remuneração vigente (vantagens fixas)
   ├─ Calcular saldo de salário
   ├─ Buscar períodos aquisitivos → calcular férias (vencidas + proporcionais)
   ├─ Calcular 13º proporcional
   ├─ Aplicar descontos (INSS, IRRF, adiantamentos)
   └─ Atualizar situacao = CALCULADA

3. HOMOLOGAR
   ├─ Conferência pelo RH
   ├─ Gerar TRCT (Termo de Rescisão) em PDF
   └─ Atualizar situacao = HOMOLOGADA

4. PROCESSAR NA FOLHA
   ├─ Criar folha rescisória (tipo = RESCISORIA)
   ├─ Lançar rubricas: saldo salário, férias, 1/3, 13º, descontos
   └─ Atualizar situacao = PAGA

5. FINALIZAR
   ├─ Atualizar VinculoFuncional: situacao = DESLIGADO, dataDesligamento
   ├─ Encerrar afastamentos ativos (se houver)
   ├─ Encerrar períodos aquisitivos = INDENIZADO
   ├─ Preparar dados para eSocial S-2299
   └─ Atualizar RAIS (campos de desligamento)
```

### 3.3 Endpoints REST

```
-- Motivo de Desligamento (configuração)
GET    /api/v1/rescisao/motivos                                → Listar motivos
POST   /api/v1/rescisao/motivos                                → Criar motivo
PUT    /api/v1/rescisao/motivos/{id}                           → Atualizar motivo

-- Rescisão (operacional)
POST   /api/v1/rescisao                                        → Iniciar rescisão
GET    /api/v1/rescisao                                        → Listar (paginado, filtros)
GET    /api/v1/rescisao/{id}                                   → Detalhar
PUT    /api/v1/rescisao/{id}                                   → Atualizar dados
POST   /api/v1/rescisao/{id}/calcular                          → Calcular verbas (preview)
POST   /api/v1/rescisao/{id}/homologar                         → Homologar
POST   /api/v1/rescisao/{id}/processar                         → Processar na folha
PUT    /api/v1/rescisao/{id}/cancelar                          → Cancelar (reverter)
GET    /api/v1/rescisao/{id}/trct                              → Gerar TRCT em PDF
GET    /api/v1/rescisao/{id}/demonstrativo                     → Demonstrativo rescisório PDF
GET    /api/v1/rescisao/vinculo/{vinculoId}                    → Histórico por vínculo

-- Dashboard
GET    /api/v1/rescisao/dashboard                              → Indicadores (desligamentos por mês/motivo)
GET    /api/v1/rescisao/relatorio                              → Relatório de desligamentos
```

### 3.4 Frontend

```
/e-RH/rescisao/                                → Lista de rescisões + dashboard
/e-RH/rescisao/nova/                           → Formulário de nova rescisão (wizard)
/e-RH/rescisao/{id}/                           → Detalhe da rescisão (cálculo, homologação)
/e-RH/configuracao/motivo-desligamento/        → CRUD de motivos
```

**Tela de Nova Rescisão (Wizard 4 etapas):**

```
Etapa 1: DADOS DO DESLIGAMENTO
  ├─ Select: Servidor (com busca por nome/matrícula)
  ├─   → Exibe ficha resumo (cargo, lotação, admissão, tempo de serviço)
  ├─ Select: Motivo do Desligamento
  ├─ DatePicker: Data de Desligamento
  ├─ Input: Nº do Ato (Portaria/Decreto)
  └─ DatePicker: Data de Publicação do Ato

Etapa 2: CÁLCULO RESCISÓRIO (automático)
  ├─ Card: Saldo de Salário (X dias × R$ Y/dia)
  ├─ Card: Férias Vencidas (N períodos × R$ + 1/3)
  ├─ Card: Férias Proporcionais (X/12 avos × R$ + 1/3)
  ├─ Card: 13º Proporcional (X/12 avos × R$)
  ├─ Card: Descontos (INSS, IRRF, Adiant.13)
  ├─ Separador
  ├─ TOTAL BRUTO: R$ XXXX
  ├─ TOTAL DESCONTOS: R$ XXXX
  └─ ═══ TOTAL LÍQUIDO: R$ XXXX ═══

Etapa 3: CONFERÊNCIA E HOMOLOGAÇÃO
  ├─ Resumo completo (somente leitura)
  ├─ Checklist de verificação do RH
  ├─ Campo: Observações
  └─ Botão: Homologar

Etapa 4: DOCUMENTOS
  ├─ Botão: Baixar TRCT (PDF)
  ├─ Botão: Baixar Demonstrativo Rescisório (PDF)
  ├─ Botão: Processar na Folha (lança rubricas rescisórias)
  └─ Status: eSocial S-2299 (preparado / enviado)
```

### 3.5 Migração SQL

```sql
-- V013__modulo_rescisao.sql

CREATE TABLE motivo_desligamento (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    descricao VARCHAR(200) NOT NULL,
    codigo_esocial VARCHAR(10),
    codigo_rais INTEGER,
    codigo_tce VARCHAR(10),
    tipo_rescisao VARCHAR(30),
    gera_ferias_proporcionais BOOLEAN DEFAULT TRUE,
    gera_13_proporcional BOOLEAN DEFAULT TRUE,
    gera_ferias_vencidas BOOLEAN DEFAULT TRUE,
    gera_aviso_previo BOOLEAN DEFAULT FALSE,
    gera_multa_fgts BOOLEAN DEFAULT FALSE,
    ativo BOOLEAN DEFAULT TRUE,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rescisao (
    id BIGSERIAL PRIMARY KEY,
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    motivo_desligamento_id BIGINT NOT NULL REFERENCES motivo_desligamento(id),
    data_desligamento DATE NOT NULL,
    data_aviso_previo DATE,
    numero_ato VARCHAR(50),
    data_publicacao_ato DATE,
    situacao VARCHAR(20) NOT NULL DEFAULT 'RASCUNHO',
    -- Verbas
    saldo_salario NUMERIC(15,2),
    dias_saldo_salario INTEGER,
    ferias_vencidas NUMERIC(15,2),
    terco_ferias_vencidas NUMERIC(15,2),
    ferias_proporcionais NUMERIC(15,2),
    terco_ferias_proporcionais NUMERIC(15,2),
    meses_ferias_proporcionais INTEGER,
    decimo_terceiro_proporcional NUMERIC(15,2),
    meses_13_proporcional INTEGER,
    decimo_terceiro_integral NUMERIC(15,2),
    aviso_previo_indenizado NUMERIC(15,2),
    outras_vantagens NUMERIC(15,2),
    descricao_outras_vantagens TEXT,
    -- Descontos
    desconto_inss_rpps NUMERIC(15,2),
    desconto_irrf NUMERIC(15,2),
    desconto_adiantamento_13 NUMERIC(15,2),
    desconto_faltas NUMERIC(15,2),
    outros_descontos NUMERIC(15,2),
    descricao_outros_descontos TEXT,
    -- Totais
    total_bruto NUMERIC(15,2),
    total_descontos NUMERIC(15,2),
    total_liquido NUMERIC(15,2),
    -- Referências
    folha_pagamento_id BIGINT REFERENCES folhapagamento(id),
    competencia_pagamento VARCHAR(7),
    -- eSocial
    enviado_esocial BOOLEAN DEFAULT FALSE,
    recibo_esocial VARCHAR(100),
    -- Documentação
    data_homologacao DATE,
    observacao TEXT,
    -- Tenant
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed de motivos
INSERT INTO motivo_desligamento (codigo, descricao, tipo_rescisao, codigo_esocial, gera_ferias_proporcionais, gera_13_proporcional) VALUES
    ('EXON_PEDIDO', 'Exoneração a Pedido', 'EXONERACAO_PEDIDO', '07', true, true),
    ('EXON_OFICIO', 'Exoneração de Ofício', 'EXONERACAO_OFICIO', '07', true, true),
    ('DEMISSAO', 'Demissão por Justa Causa', 'DEMISSAO', '02', false, false),
    ('APOSENT_VOLUNT', 'Aposentadoria Voluntária', 'APOSENTADORIA', '34', true, true),
    ('APOSENT_COMPULS', 'Aposentadoria Compulsória', 'APOSENTADORIA', '35', true, true),
    ('APOSENT_INVALID', 'Aposentadoria por Invalidez', 'APOSENTADORIA', '36', true, true),
    ('FALECIMENTO', 'Falecimento', 'FALECIMENTO', '10', true, true),
    ('TERM_CONTRATO', 'Término de Contrato Temporário', 'TERMINO_CONTRATO', '04', true, true),
    ('CASSACAO', 'Cassação de Aposentadoria', 'CASSACAO', '17', false, false),
    ('DESTIT_CC', 'Destituição de Cargo em Comissão', 'DESTITUICAO_CARGO', '07', true, true),
    ('VACANCIA', 'Vacância por Posse em Outro Cargo', 'VACANCIA_POSSE_OUTRO', '33', true, true);

-- Índices
CREATE INDEX idx_rescisao_vinculo ON rescisao(vinculo_funcional_id);
CREATE INDEX idx_rescisao_data ON rescisao(data_desligamento);
CREATE INDEX idx_rescisao_situacao ON rescisao(situacao);

-- Adicionar campo na tabela de folha para tipo de folha rescisória
ALTER TABLE folhapagamento ADD COLUMN IF NOT EXISTS tipo_folha VARCHAR(20) DEFAULT 'NORMAL';
-- Valores: NORMAL, COMPLEMENTAR, RESCISORIA, FERIAS
```

### 3.6 Checklist de Entrega — Fase 3

```
BACKEND:
  [x] Criar pacote ws.erh.carreira.rescisao
  [x] Implementar entidades: Rescisao, MotivoDesligamento
  [x] Implementar enums: TipoRescisao, SituacaoRescisao
  [x] Implementar RescisaoService (cálculo rescisório completo)
  [ ] Implementar RescisaoCalculoService (cálculo isolado de cada verba) — embutido no RescisaoService
  [x] Implementar integração: encerrar férias, afastamentos, períodos aquisitivos
  [x] Implementar integração: atualizar VinculoFuncional (DESLIGADO)
  [x] Implementar RescisaoController (~15 endpoints)
  [x] Criar migração SQL V013__modulo_rescisao.sql
  [x] Seed de 11 motivos de desligamento
  [x] Criar relatório Jasper: TRCT (TermoRescisao.jrxml)
  [x] Criar relatório Jasper: Demonstrativo Rescisório (DemonstrativoRescisao.jrxml)
  [ ] 50+ testes unitários — PENDENTE

FRONTEND:
  [x] Criar rota /e-RH/lancamento/rescisao/ (CRUD + lista)
  [ ] Criar rota /e-RH/rescisao/nova/ (wizard 4 etapas) — usando CRUD padrão por enquanto
  [ ] Criar rota /e-RH/rescisao/{id}/ (detalhe) — usando CRUD padrão
  [x] Criar rota /e-RH/configuracao/motivo-desligamento/
  [x] Criar configs, types (rescisao.config.ts, rescisao.types.ts, motivoDesligamento.config.ts, motivoDesligamento.types.ts)
  [ ] Componente wizard de rescisão (4 etapas com stepper) — PENDENTE
  [ ] Componente de preview de cálculo rescisório — PENDENTE
  [x] Adicionar menu "Rescisão" no sidebar

VALIDAÇÃO:
  [ ] Testar exoneração a pedido (caso mais comum)
  [ ] Testar término de contrato temporário
  [ ] Testar aposentadoria (não paga férias proporcionais em alguns estatutos)
  [ ] Testar demissão por justa causa (sem férias/13º proporcionais)
  [ ] Testar falecimento (verbas vão para dependentes)
  [ ] Testar servidor com férias vencidas (indenizar corretamente)
  [ ] Testar desconto de adiantamento de 13º
  [ ] Validar TRCT PDF
  [ ] Validar integração com folha rescisória
```

---

## FASE 4 — MÓDULO DE PROCESSOS / WORKFLOW (3 semanas)

> **Pré-requisito:** Fases 1-3 completas e testadas  
> **Objetivo:** Permitir que o RH configure tipos de processos (férias, afastamentos, licenças, etc.) com documentos exigidos, e que os servidores da prefeitura abram processos online com envio de documentos, acompanhamento e troca de mensagens com o RH — eliminando a necessidade de atendimento presencial.

### 4.1 Conceito e Fluxo

```
┌───────────────────────────────────────────────────────────────────────────┐
│                        FLUXO DO MÓDULO DE PROCESSOS                       │
│                                                                           │
│  ① RH CONFIGURA (uma vez)                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ Modelo de Processo: "Solicitação de Férias"                         │  │
│  │ ├─ Descrição e instruções para o servidor                           │  │
│  │ ├─ Documentos exigidos:                                             │  │
│  │ │   ├─ Requerimento de férias assinado (PDF) — OBRIGATÓRIO          │  │
│  │ │   └─ Comprovante de não débito (PDF) — OPCIONAL                   │  │
│  │ ├─ Etapas do workflow:                                              │  │
│  │ │   ├─ 1. Envio de documentos (servidor)                           │  │
│  │ │   ├─ 2. Análise documental (RH)                                  │  │
│  │ │   ├─ 3. Aprovação da chefia                                      │  │
│  │ │   └─ 4. Publicação/Conclusão                                     │  │
│  │ └─ Categoria: FERIAS                                                │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                              │                                            │
│                              ▼                                            │
│  ② SERVIDOR ABRE PROCESSO                                                │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ → Consulta processos disponíveis (catálogo)                         │  │
│  │ → Vê detalhes: o que é, quais docs precisa, prazos                 │  │
│  │ → Abre processo: preenche dados + faz upload dos documentos         │  │
│  │ → Recebe protocolo: PROC-2026-0001                                  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                              │                                            │
│                              ▼                                            │
│  ③ RH AVALIA                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ → Recebe notificação de novo processo                               │  │
│  │ → Abre processo, visualiza documentos enviados                      │  │
│  │ → Opções:                                                           │  │
│  │   ├─ ✅ Documentos OK → Avança etapa                                │  │
│  │   ├─ ⚠️ Falta documento → Solicita complementação (mensagem)       │  │
│  │   └─ ❌ Reprovar → Indefere com justificativa                      │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                              │                                            │
│                              ▼                                            │
│  ④ TROCA DE MENSAGENS (ida-e-volta)                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ RH: "Falta o comprovante de não débito. Favor anexar."              │  │
│  │ Servidor: "Segue em anexo." [📎 comprovante.pdf]                    │  │
│  │ RH: "Documentação completa. Processo aprovado."                     │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                              │                                            │
│                              ▼                                            │
│  ⑤ CONCLUSÃO (com integração opcional)                                   │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │ Se categoria = FERIAS → Pode gerar ConcessaoFerias automaticamente  │  │
│  │ Se categoria = AFASTAMENTO → Pode gerar Afastamento automaticamente │  │
│  │ Se categoria = GENERICO → Apenas marca como concluído               │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Modelo de Dados

#### Entidades no pacote `ws.erh.processo`

```java
// ===== ProcessoModelo.java =====
// Template configurado pelo RH: define que tipo de processo pode ser aberto
@Entity
@Table(name = "processo_modelo")
public class ProcessoModelo extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "codigo", nullable = false, unique = true)
    private String codigo;                       // Ex: "PROC_FERIAS", "PROC_AFASTAMENTO"
    
    @Column(name = "nome", nullable = false)
    private String nome;                         // Ex: "Solicitação de Férias"
    
    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;                    // Descrição detalhada para o servidor
    
    @Column(name = "instrucoes", columnDefinition = "TEXT")
    private String instrucoes;                   // Passo-a-passo de como solicitar
    
    @Enumerated(EnumType.STRING)
    @Column(name = "categoria", nullable = false)
    private CategoriaProcesso categoria;         // FERIAS, AFASTAMENTO, LICENCA, RESCISAO, CADASTRAL, OUTROS
    
    @Column(name = "icone")
    private String icone;                        // Ícone para exibir no catálogo (ex: "vacation", "medical")
    
    @Column(name = "cor")
    private String cor;                          // Cor do card no catálogo (hex)
    
    @Column(name = "prazo_atendimento_dias")
    private Integer prazoAtendimentoDias;         // SLA: prazo máximo para o RH atender (dias úteis)
    
    @Column(name = "requer_aprovacao_chefia")
    private Boolean requerAprovacaoChefia = false; // Precisa de aprovação do chefe imediato?
    
    @Column(name = "gera_acao_automatica")
    private Boolean geraAcaoAutomatica = false;   // Ao aprovar, gera registro no módulo (férias, afastamento)?
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @Column(name = "visivel_portal")
    private Boolean visivelPortal = true;         // Aparece no catálogo do portal do servidor?
    
    @Column(name = "ordem_exibicao")
    private Integer ordemExibicao = 0;
    
    @OneToMany(mappedBy = "processoModelo", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("ordem ASC")
    private List<ProcessoDocumentoModelo> documentosExigidos;
    
    @OneToMany(mappedBy = "processoModelo", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("ordem ASC")
    private List<ProcessoEtapaModelo> etapas;
    
    @OneToMany(mappedBy = "processoModelo", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ProcessoCampoModelo> camposAdicionais;  // Campos dinâmicos do formulário
}
```

```java
// ===== ProcessoDocumentoModelo.java =====
// Define quais documentos são exigidos para determinado tipo de processo
@Entity
@Table(name = "processo_documento_modelo")
public class ProcessoDocumentoModelo extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_modelo_id", nullable = false)
    private ProcessoModelo processoModelo;
    
    @Column(name = "nome", nullable = false)
    private String nome;                         // Ex: "Requerimento de Férias"
    
    @Column(name = "descricao")
    private String descricao;                    // Instruções sobre o documento
    
    @Column(name = "obrigatorio")
    private Boolean obrigatorio = true;
    
    @Column(name = "tipos_permitidos")
    private String tiposPermitidos;              // "pdf,jpg,png" — extensões aceitas
    
    @Column(name = "tamanho_maximo_mb")
    private Integer tamanhoMaximoMb = 10;        // Tamanho máximo do arquivo em MB
    
    @Column(name = "modelo_url")
    private String modeloUrl;                    // URL para download de modelo/template do documento
    
    @Column(name = "ordem")
    private Integer ordem = 0;
}
```

```java
// ===== ProcessoEtapaModelo.java =====
// Define as etapas do workflow para um tipo de processo
@Entity
@Table(name = "processo_etapa_modelo")
public class ProcessoEtapaModelo extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_modelo_id", nullable = false)
    private ProcessoModelo processoModelo;
    
    @Column(name = "nome", nullable = false)
    private String nome;                         // Ex: "Envio de Documentos", "Análise RH"
    
    @Column(name = "descricao")
    private String descricao;
    
    @Column(name = "ordem", nullable = false)
    private Integer ordem;                       // 1, 2, 3...
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_responsavel", nullable = false)
    private TipoResponsavel tipoResponsavel;     // SERVIDOR, RH, CHEFIA
    
    @Column(name = "acao_automatica")
    private String acaoAutomatica;               // Ação ao concluir esta etapa (ex: "GERAR_FERIAS")
    
    @Column(name = "prazo_dias")
    private Integer prazoDias;                   // Prazo para concluir esta etapa
}
```

```java
// ===== ProcessoCampoModelo.java =====
// Campos dinâmicos que o servidor precisa preencher ao abrir o processo
@Entity
@Table(name = "processo_campo_modelo")
public class ProcessoCampoModelo extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_modelo_id", nullable = false)
    private ProcessoModelo processoModelo;
    
    @Column(name = "nome_campo", nullable = false)
    private String nomeCampo;                    // Chave: "data_inicio_ferias"
    
    @Column(name = "label", nullable = false)
    private String label;                        // Exibição: "Data de início das férias"
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_campo", nullable = false)
    private TipoCampo tipoCampo;                 // TEXT, NUMBER, DATE, SELECT, BOOLEAN, TEXTAREA
    
    @Column(name = "obrigatorio")
    private Boolean obrigatorio = true;
    
    @Column(name = "opcoes_select")
    private String opcoesSelect;                 // JSON: ["10 dias", "15 dias", "20 dias", "30 dias"]
    
    @Column(name = "placeholder")
    private String placeholder;
    
    @Column(name = "ajuda")
    private String ajuda;                        // Texto de ajuda contextual
    
    @Column(name = "ordem")
    private Integer ordem = 0;
}
```

```java
// ===== Processo.java =====
// Instância de um processo aberto por um servidor
@Entity
@Table(name = "processo")
public class Processo extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "protocolo", nullable = false, unique = true)
    private String protocolo;                    // Ex: "PROC-2026-000001" (gerado automaticamente)
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_modelo_id", nullable = false)
    private ProcessoModelo processoModelo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;                   // Quem abriu o processo
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id")
    private VinculoFuncional vinculoFuncional;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", nullable = false)
    private SituacaoProcesso situacao;
    
    @Column(name = "etapa_atual")
    private Integer etapaAtual = 1;              // Em qual etapa do workflow está
    
    @Column(name = "data_abertura", nullable = false)
    private LocalDateTime dataAbertura;
    
    @Column(name = "data_ultima_atualizacao")
    private LocalDateTime dataUltimaAtualizacao;
    
    @Column(name = "data_conclusao")
    private LocalDateTime dataConclusao;
    
    @Column(name = "prazo_limite")
    private LocalDate prazoLimite;               // dataAbertura + prazoAtendimentoDias
    
    // === Atribuição ===
    @Column(name = "atribuido_para")
    private String atribuidoPara;                // Usuário RH responsável (pode ser null = fila geral)
    
    @Column(name = "departamento_atribuido")
    private String departamentoAtribuido;
    
    // === Dados do formulário preenchido pelo servidor ===
    @Column(name = "dados_formulario", columnDefinition = "JSONB")
    private String dadosFormulario;              // JSON com respostas dos campos dinâmicos
    
    @Column(name = "observacao_servidor", columnDefinition = "TEXT")
    private String observacaoServidor;           // Observação livre do servidor ao abrir
    
    // === Resultado ===
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado")
    private ResultadoProcesso resultado;         // DEFERIDO, INDEFERIDO, ARQUIVADO (apenas quando concluído)
    
    @Column(name = "justificativa_resultado", columnDefinition = "TEXT")
    private String justificativaResultado;
    
    // === Integração com módulos operacionais ===
    @Column(name = "referencia_tipo")
    private String referenciaTipo;               // "CONCESSAO_FERIAS", "AFASTAMENTO", "RESCISAO"
    
    @Column(name = "referencia_id")
    private Long referenciaId;                   // ID do registro gerado automaticamente
    
    @Enumerated(EnumType.STRING)
    @Column(name = "prioridade")
    private Prioridade prioridade;
    
    // === Relacionamentos ===
    @OneToMany(mappedBy = "processo", cascade = CascadeType.ALL)
    @OrderBy("dataEnvio ASC")
    private List<ProcessoDocumento> documentos;
    
    @OneToMany(mappedBy = "processo", cascade = CascadeType.ALL)
    @OrderBy("dataHora ASC")
    private List<ProcessoMensagem> mensagens;
    
    @OneToMany(mappedBy = "processo", cascade = CascadeType.ALL)
    @OrderBy("dataHora ASC")
    private List<ProcessoHistorico> historico;
}
```

```java
// ===== ProcessoDocumento.java =====
// Documento enviado pelo servidor (ou pelo RH)
@Entity
@Table(name = "processo_documento")
public class ProcessoDocumento extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id", nullable = false)
    private Processo processo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "documento_modelo_id")
    private ProcessoDocumentoModelo documentoModelo;  // Qual documento exigido atende (null = doc avulso)
    
    @Column(name = "nome_arquivo", nullable = false)
    private String nomeArquivo;                  // Nome original do arquivo
    
    @Column(name = "caminho_storage", nullable = false)
    private String caminhoStorage;               // Caminho no ArquivoStorageService
    
    @Column(name = "tipo_arquivo")
    private String tipoArquivo;                  // MIME type
    
    @Column(name = "tamanho_bytes")
    private Long tamanhoBytes;
    
    @Column(name = "data_envio", nullable = false)
    private LocalDateTime dataEnvio;
    
    @Column(name = "enviado_por", nullable = false)
    private String enviadoPor;                   // "SERVIDOR" ou username do RH
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao")
    private SituacaoDocumento situacao;           // PENDENTE, ACEITO, RECUSADO
    
    @Column(name = "motivo_recusa")
    private String motivoRecusa;                 // Se recusado, por quê
    
    @Column(name = "avaliado_por")
    private String avaliadoPor;                  // Usuário RH que avaliou
    
    @Column(name = "data_avaliacao")
    private LocalDateTime dataAvaliacao;
}
```

```java
// ===== ProcessoMensagem.java =====
// Mensagens entre servidor e RH (chat/timeline do processo)
@Entity
@Table(name = "processo_mensagem")
public class ProcessoMensagem extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id", nullable = false)
    private Processo processo;
    
    @Column(name = "autor", nullable = false)
    private String autor;                        // Nome de quem enviou
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_autor", nullable = false)
    private TipoAutor tipoAutor;                 // SERVIDOR, RH, CHEFIA, SISTEMA
    
    @Column(name = "mensagem", columnDefinition = "TEXT", nullable = false)
    private String mensagem;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @Column(name = "lida")
    private Boolean lida = false;
    
    @Column(name = "data_leitura")
    private LocalDateTime dataLeitura;
    
    // Mensagem pode ter um anexo
    @Column(name = "anexo_nome")
    private String anexoNome;
    
    @Column(name = "anexo_caminho")
    private String anexoCaminho;
    
    @Column(name = "anexo_tipo")
    private String anexoTipo;
}
```

```java
// ===== ProcessoHistorico.java =====
// Log de auditoria de tudo que aconteceu no processo
@Entity
@Table(name = "processo_historico")
public class ProcessoHistorico extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "processo_id", nullable = false)
    private Processo processo;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "acao", nullable = false)
    private AcaoProcesso acao;
    
    @Column(name = "situacao_anterior")
    private String situacaoAnterior;
    
    @Column(name = "situacao_nova")
    private String situacaoNova;
    
    @Column(name = "etapa_anterior")
    private Integer etapaAnterior;
    
    @Column(name = "etapa_nova")
    private Integer etapaNova;
    
    @Column(name = "usuario", nullable = false)
    private String usuario;
    
    @Column(name = "tipo_usuario")
    @Enumerated(EnumType.STRING)
    private TipoAutor tipoUsuario;
    
    @Column(name = "descricao")
    private String descricao;                    // Descrição legível da ação
    
    @Column(name = "dados_extras", columnDefinition = "JSONB")
    private String dadosExtras;                  // Dados adicionais da ação (json)
}
```

### 4.3 Enums

```java
public enum CategoriaProcesso {
    FERIAS("Férias"),
    AFASTAMENTO("Afastamento / Licença"),
    LICENCA("Licença Específica"),
    RESCISAO("Desligamento / Exoneração"),
    CADASTRAL("Atualização Cadastral"),
    FINANCEIRO("Assunto Financeiro"),
    DOCUMENTAL("Solicitação de Documento"),
    OUTROS("Outros");
    
    private final String descricao;
}

public enum SituacaoProcesso {
    RASCUNHO,             // Servidor começou mas não enviou
    ABERTO,               // Enviado, aguardando atendimento do RH
    EM_ANALISE,           // RH está analisando os documentos
    PENDENTE_DOCUMENTACAO,// RH pediu documentos complementares ao servidor
    AGUARDANDO_CHEFIA,    // Aguardando aprovação da chefia imediata
    DEFERIDO,             // Aprovado pelo RH
    INDEFERIDO,           // Negado pelo RH (com justificativa)
    EM_EXECUCAO,          // Aprovado e sendo executado no módulo operacional
    CONCLUIDO,            // Processo finalizado
    CANCELADO,            // Cancelado pelo servidor ou RH
    ARQUIVADO             // Arquivado por inatividade
}

public enum SituacaoDocumento {
    PENDENTE,     // Enviado, aguardando avaliação
    ACEITO,       // Documento aceito pelo RH
    RECUSADO      // Documento recusado (precisa reenviar)
}

public enum TipoResponsavel {
    SERVIDOR,     // Servidor precisa agir nesta etapa
    RH,           // RH precisa agir
    CHEFIA        // Chefia imediata precisa agir
}

public enum TipoAutor {
    SERVIDOR,     // Mensagem/ação do servidor
    RH,           // Mensagem/ação do funcionário do RH
    CHEFIA,       // Mensagem/ação da chefia
    SISTEMA       // Mensagem automática do sistema
}

public enum TipoCampo {
    TEXT,         // Campo de texto simples
    NUMBER,       // Campo numérico
    DATE,         // Seletor de data
    SELECT,       // Dropdown (opções definidas em opcoesSelect)
    BOOLEAN,      // Checkbox sim/não
    TEXTAREA      // Texto longo (multilinha)
}

public enum ResultadoProcesso {
    DEFERIDO,     // Solicitação aceita
    INDEFERIDO,   // Solicitação negada
    ARQUIVADO     // Arquivado sem decisão (inatividade, desistência)
}

public enum AcaoProcesso {
    CRIADO,                   // Processo aberto
    DOCUMENTO_ENVIADO,        // Servidor enviou documento
    DOCUMENTO_ACEITO,         // RH aceitou documento
    DOCUMENTO_RECUSADO,       // RH recusou documento
    MENSAGEM_SERVIDOR,        // Servidor enviou mensagem
    MENSAGEM_RH,              // RH enviou mensagem
    MENSAGEM_CHEFIA,          // Chefia enviou mensagem
    SOLICITADO_COMPLEMENTO,   // RH pediu documentação complementar
    ATRIBUIDO,                // Processo atribuído a um analista
    ETAPA_AVANCADA,           // Avançou para próxima etapa
    APROVADO_CHEFIA,          // Chefia aprovou
    REPROVADO_CHEFIA,         // Chefia reprovou
    DEFERIDO,                 // Processo deferido pelo RH
    INDEFERIDO,               // Processo indeferido pelo RH
    ACAO_EXECUTADA,           // Ação operacional executada (ex: férias registradas)
    CONCLUIDO,                // Processo concluído
    CANCELADO,                // Cancelado
    REABERTO,                 // Reaberto após cancelamento/arquivo
    ARQUIVADO                 // Arquivado por inatividade
}

public enum Prioridade {
    BAIXA, NORMAL, ALTA, URGENTE
}
```

### 4.4 Regras de Negócio

#### Geração de Protocolo
```
Formato: PROC-{ANO}-{SEQUENCIAL:6 dígitos}
Exemplo: PROC-2026-000001, PROC-2026-000002

Sequencial reinicia a cada ano.
Gerado atomicamente (SELECT nextval ou @SequenceGenerator).
```

#### Validações ao Abrir Processo
```
1. Servidor possui vínculo ativo? → Se não, bloqueia
2. Modelo de processo está ativo? → Se não, bloqueia
3. Já existe processo ABERTO/EM_ANALISE do mesmo tipo para este servidor? → Alerta
4. Todos os campos obrigatórios do formulário preenchidos?
5. Todos os documentos obrigatórios enviados?
6. Arquivos dentro dos limites (tipo/tamanho)?
7. Se férias: servidor tem saldo no período aquisitivo?
8. Se afastamento: servidor não está em outro afastamento ativo?
```

#### Workflow de Etapas
```
Para cada etapa definida no ProcessoEtapaModelo:
  1. O sistema verifica quem é o responsável (SERVIDOR, RH, CHEFIA)
  2. Somente o responsável pode avançar a etapa
  3. Ao avançar a etapa:
     a. Registra no ProcessoHistorico
     b. Envia notificação ao responsável da próxima etapa
     c. Se era última etapa → marca como DEFERIDO ou CONCLUIDO
     d. Se etapa tem acaoAutomatica:
        - "GERAR_FERIAS" → cria ConcessaoFerias com dados do formulário
        - "GERAR_AFASTAMENTO" → cria Afastamento com dados do formulário
        - null → apenas avança
```

#### SLA e Alertas
```
- Cada modelo tem prazoAtendimentoDias
- prazoLimite = dataAbertura + prazoAtendimentoDias (dias úteis)
- Se hoje > prazoLimite e situacao IN (ABERTO, EM_ANALISE):
  → Marcado como "ATRASADO" no painel RH (badge vermelho)
  → Alerta para o gestor
- Processos PENDENTE_DOCUMENTACAO por mais de 30 dias → auto-ARQUIVAR
```

#### Integração com Módulos Operacionais
```java
// Quando processo é DEFERIDO e geraAcaoAutomatica = true:
switch (processoModelo.getCategoria()) {
    case FERIAS:
        // Lê dadosFormulario: {data_inicio, data_fim, abono_pecuniario, adiantamento_13}
        // Chama FeriasService.concederFerias() com os dados
        // Salva referenciaTipo = "CONCESSAO_FERIAS", referenciaId = concessao.id
        break;
    case AFASTAMENTO:
        // Lê dadosFormulario: {tipo_afastamento_id, data_inicio, data_fim, cid}
        // Chama AfastamentoService.registrar() com os dados
        // Salva referenciaTipo = "AFASTAMENTO", referenciaId = afastamento.id
        break;
    case CADASTRAL:
        // Lê dadosFormulario: {endereco_novo, telefone_novo, banco_novo}
        // Gera solicitação de atualização (manual pelo RH ou automática)
        break;
    default:
        // Apenas conclui o processo
        break;
}
```

### 4.5 Endpoints REST

#### Modelos de Processo (lado RH — configuração)

```
POST   /api/v1/processos/modelos                                → Criar modelo de processo
GET    /api/v1/processos/modelos                                → Listar modelos (paginado, filtros)
GET    /api/v1/processos/modelos/{id}                           → Detalhar modelo (com docs e etapas)
PUT    /api/v1/processos/modelos/{id}                           → Atualizar modelo
PUT    /api/v1/processos/modelos/{id}/ativar                    → Ativar/desativar modelo
DELETE /api/v1/processos/modelos/{id}                           → Excluir modelo (soft delete)

-- Documentos exigidos do modelo
POST   /api/v1/processos/modelos/{id}/documentos                → Adicionar documento exigido
PUT    /api/v1/processos/modelos/{id}/documentos/{docId}        → Atualizar documento exigido
DELETE /api/v1/processos/modelos/{id}/documentos/{docId}        → Remover documento exigido

-- Etapas do modelo
POST   /api/v1/processos/modelos/{id}/etapas                    → Adicionar etapa
PUT    /api/v1/processos/modelos/{id}/etapas/{etapaId}          → Atualizar etapa
DELETE /api/v1/processos/modelos/{id}/etapas/{etapaId}          → Remover etapa
PUT    /api/v1/processos/modelos/{id}/etapas/reordenar          → Reordenar etapas

-- Campos dinâmicos do modelo
POST   /api/v1/processos/modelos/{id}/campos                    → Adicionar campo
PUT    /api/v1/processos/modelos/{id}/campos/{campoId}          → Atualizar campo
DELETE /api/v1/processos/modelos/{id}/campos/{campoId}          → Remover campo
```

#### Catálogo (lado servidor — consulta pública)

```
GET    /api/v1/processos/catalogo                               → Listar processos disponíveis (ativo + visivelPortal)
GET    /api/v1/processos/catalogo/{modeloId}                    → Ver detalhes do processo (docs exigidos, campos, instruções)
GET    /api/v1/processos/catalogo/{modeloId}/modelo-documento/{docModeloId}/download  → Baixar template de documento
```

#### Processos (operacional — servidor abre, RH gerencia)

```
-- Servidor abre e acompanha
POST   /api/v1/processos                                        → Abrir processo (com dados + documentos)
GET    /api/v1/processos/meus                                   → Meus processos (servidor logado)
GET    /api/v1/processos/{id}                                   → Detalhar processo (mensagens, docs, histórico)
PUT    /api/v1/processos/{id}/cancelar                          → Cancelar processo

-- Upload de documentos
POST   /api/v1/processos/{id}/documentos                        → Enviar novo documento (upload)
GET    /api/v1/processos/{id}/documentos/{docId}/download       → Baixar documento
DELETE /api/v1/processos/{id}/documentos/{docId}                → Remover documento (se permitido)

-- Mensagens (chat)
POST   /api/v1/processos/{id}/mensagens                         → Enviar mensagem
GET    /api/v1/processos/{id}/mensagens                         → Listar mensagens do processo
PUT    /api/v1/processos/{id}/mensagens/marcar-lidas            → Marcar mensagens como lidas

-- Histórico (timeline de auditoria)
GET    /api/v1/processos/{id}/historico                         → Timeline completa do processo
```

#### Gestão de Processos (lado RH — painel de atendimento)

```
GET    /api/v1/processos/gestao                                 → Listar todos os processos (filtros: situacao, categoria, servidor, atribuido)
GET    /api/v1/processos/gestao/dashboard                       → Dashboard: abertos, em análise, atrasados, por categoria
GET    /api/v1/processos/gestao/fila                            → Fila de processos não atribuídos
PUT    /api/v1/processos/gestao/{id}/atribuir                   → Atribuir processo a um analista
PUT    /api/v1/processos/gestao/{id}/iniciar-analise            → Iniciar análise (muda status para EM_ANALISE)

-- Avaliação de documentos
PUT    /api/v1/processos/gestao/{id}/documentos/{docId}/aceitar  → Aceitar documento
PUT    /api/v1/processos/gestao/{id}/documentos/{docId}/recusar  → Recusar documento (com motivo)

-- Ações no workflow
PUT    /api/v1/processos/gestao/{id}/solicitar-complemento      → Pedir documentação complementar (mensagem obrigatória)
PUT    /api/v1/processos/gestao/{id}/avancar-etapa              → Avançar para próxima etapa
PUT    /api/v1/processos/gestao/{id}/deferir                    → Deferir processo
PUT    /api/v1/processos/gestao/{id}/indeferir                  → Indeferir processo (justificativa obrigatória)
PUT    /api/v1/processos/gestao/{id}/arquivar                   → Arquivar processo
PUT    /api/v1/processos/gestao/{id}/reabrir                    → Reabrir processo arquivado/cancelado

-- Relatórios
GET    /api/v1/processos/gestao/relatorio                       → Relatório de processos (filtros: período, tipo, situação)
GET    /api/v1/processos/gestao/relatorio/sla                   → Relatório de SLA (tempo médio, atrasados)
```

### 4.6 Frontend — Páginas e Componentes

#### Rotas — Lado RH (funcionários do eRH)

```
/e-RH/processos/                              → Dashboard de processos (KPIs + fila + atrasados)
/e-RH/processos/fila/                         → Fila de atendimento (processos não atribuídos)
/e-RH/processos/meus-atendimentos/           → Processos atribuídos ao analista logado
/e-RH/processos/{id}/                         → Detalhe do processo (docs + mensagens + ações)

/e-RH/configuracao/modelos-processo/          → CRUD de modelos de processo
/e-RH/configuracao/modelos-processo/{id}/     → Editar modelo (docs, etapas, campos)
```

#### Rotas — Lado Servidor (funcionários da prefeitura)

> Estas rotas serão incorporadas ao Portal (Fase 5), mas já funcionam standalone na Fase 4 via autenticação padrão ou via portal.

```
/e-RH/processos/catalogo/                    → Catálogo de processos disponíveis (cards visuais)
/e-RH/processos/catalogo/{modeloId}/         → Detalhe do processo (o que é, docs necessários, instruções)
/e-RH/processos/abrir/{modeloId}/            → Formulário para abrir processo (campos + upload)
/e-RH/processos/meus/                        → Meus processos (servidor logado)
/e-RH/processos/meus/{id}/                   → Acompanhar processo (timeline + chat + docs)
```

#### Telas Detalhadas

**1. Catálogo de Processos** (`/e-RH/processos/catalogo/`)

```
┌─────────────────────────────────────────────────────────────┐
│  📋 Processos Disponíveis                                    │
│  Escolha o tipo de solicitação que deseja fazer              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │ 🏖️              │  │ 🏥              │  │ 📋              │ │
│  │ FÉRIAS          │  │ LICENÇA SAÚDE  │  │ LICENÇA PRÊMIO │ │
│  │                 │  │                │  │                 │ │
│  │ Solicitar       │  │ Solicitar      │  │ Solicitar       │ │
│  │ férias com      │  │ licença para   │  │ licença prêmio  │ │
│  │ período e docs  │  │ tratamento     │  │ por assiduidade │ │
│  │                 │  │                │  │                 │ │
│  │ 📎 2 documentos │  │ 📎 3 documentos│  │ 📎 1 documento  │ │
│  │ ⏱️ SLA: 5 dias  │  │ ⏱️ SLA: 3 dias │  │ ⏱️ SLA: 10 dias │ │
│  │                 │  │                │  │                 │ │
│  │ [Ver Detalhes]  │  │ [Ver Detalhes] │  │ [Ver Detalhes]  │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
│                                                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │
│  │ 🏠              │  │ 📄              │  │ 🔄             │ │
│  │ ATUALIZAÇÃO     │  │ CERTIDÃO       │  │ AVERBAÇÃO      │ │
│  │ CADASTRAL       │  │ TEMPO SERVIÇO  │  │ TEMPO SERVIÇO  │ │
│  │                 │  │                │  │                 │ │
│  │ Atualizar       │  │ Solicitar      │  │ Averbar tempo   │ │
│  │ endereço, tel,  │  │ certidão de    │  │ de serviço de   │ │
│  │ dados bancários │  │ tempo serviço  │  │ outro órgão     │ │
│  │                 │  │                │  │                 │ │
│  │ 📎 1 documento  │  │ 📎 0 documentos│  │ 📎 2 documentos │ │
│  │ [Ver Detalhes]  │  │ [Ver Detalhes] │  │ [Ver Detalhes]  │ │
│  └────────────────┘  └────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

**2. Detalhe do Processo (antes de abrir)** (`/e-RH/processos/catalogo/{id}/`)

```
┌─────────────────────────────────────────────────────────────┐
│  🏖️ Solicitação de Férias                                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  📝 DESCRIÇÃO                                                │
│  Utilize este processo para solicitar o gozo de férias.     │
│  Após aprovação, as férias serão registradas automaticamente │
│  na sua ficha funcional.                                     │
│                                                              │
│  📋 INSTRUÇÕES                                               │
│  1. Preencha as datas de início e fim das férias            │
│  2. Indique se deseja abono pecuniário (converter 10 dias)  │
│  3. Indique se deseja adiantamento do 13º salário           │
│  4. Anexe o requerimento de férias assinado (modelo abaixo) │
│  5. Anexe comprovante de não débito (se disponível)          │
│                                                              │
│  📎 DOCUMENTOS NECESSÁRIOS                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ ① Requerimento de Férias (OBRIGATÓRIO)                │  │
│  │    Formulário padrão preenchido e assinado             │  │
│  │    Tipos aceitos: PDF  |  Máximo: 10 MB                │  │
│  │    📥 [Baixar modelo do requerimento]                   │  │
│  ├───────────────────────────────────────────────────────┤  │
│  │ ② Comprovante de Não Débito (OPCIONAL)                 │  │
│  │    Declaração de que não há pendências                  │  │
│  │    Tipos aceitos: PDF, JPG  |  Máximo: 5 MB            │  │
│  └───────────────────────────────────────────────────────┘  │
│                                                              │
│  ⏱️ PRAZO DE ATENDIMENTO: 5 dias úteis                       │
│  📌 ETAPAS: Envio → Análise RH → Aprovação Chefia → Conclusão│
│                                                              │
│       [🚀 Abrir Solicitação]                                 │
└─────────────────────────────────────────────────────────────┘
```

**3. Formulário de Abertura** (`/e-RH/processos/abrir/{modeloId}/`)

```
┌─────────────────────────────────────────────────────────────┐
│  🏖️ Nova Solicitação: Férias                                 │
│  Preencha os dados e anexe os documentos necessários        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  SEUS DADOS (preenchido automaticamente)                    │
│  Nome: João da Silva Santos                                  │
│  Matrícula: 12345  |  Cargo: Auxiliar Administrativo        │
│  Lotação: Secretaria de Administração                       │
│                                                              │
│  ─────────────────────────────────────────────────────       │
│                                                              │
│  DADOS DA SOLICITAÇÃO (campos dinâmicos do modelo)          │
│                                                              │
│  Data de Início *        Data de Fim *         Dias         │
│  ┌──────────────┐       ┌──────────────┐     ┌─────┐       │
│  │ 15/03/2026   │       │ 29/03/2026   │     │ 15  │       │
│  └──────────────┘       └──────────────┘     └─────┘       │
│                                                              │
│  ☐ Abono Pecuniário (converter 10 dias em dinheiro)         │
│  ☐ Adiantamento de 13º Salário                              │
│                                                              │
│  Observações                                                │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Solicito férias conforme programação anual...        │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ─────────────────────────────────────────────────────       │
│                                                              │
│  DOCUMENTOS                                                  │
│                                                              │
│  ① Requerimento de Férias * (OBRIGATÓRIO)                   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  📎 requerimento_ferias_joao.pdf (245 KB)       [🗑] │   │
│  │     ✅ Arquivo enviado com sucesso                    │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  ② Comprovante de Não Débito (OPCIONAL)                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  [📤 Clique para enviar ou arraste o arquivo aqui]    │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│        [Salvar Rascunho]    [🚀 Enviar Solicitação]         │
└─────────────────────────────────────────────────────────────┘
```

**4. Acompanhamento do Processo** (`/e-RH/processos/meus/{id}/`)

```
┌─────────────────────────────────────────────────────────────┐
│  Processo PROC-2026-000042 — Solicitação de Férias          │
│  Status: ⚠️ PENDENTE DOCUMENTAÇÃO                           │
├───────────────────────────────┬──────────────────────────────┤
│  TIMELINE                     │  DOCUMENTOS                  │
│                               │                              │
│  ● 20/02 09:30                │  ① Requerimento de Férias    │
│  │ Processo aberto por        │     📎 requerimento.pdf      │
│  │ João da Silva              │     ❌ RECUSADO              │
│  │                            │     "Faltou assinatura"      │
│  ● 20/02 14:15                │                              │
│  │ 🧑‍💼 Maria (RH):            │     📎 requerimento_v2.pdf  │
│  │ "Requerimento sem          │     ⏳ PENDENTE avaliação    │
│  │  assinatura. Favor         │                              │
│  │  reenviar assinado."       │  ② Comprovante (OPCIONAL)   │
│  │                            │     📎 comprovante.pdf       │
│  ● 20/02 16:40                │     ✅ ACEITO               │
│  │ 👤 João da Silva:          │                              │
│  │ "Segue documento corrigido │  ─────────────────────       │
│  │  com assinatura."          │  PROGRESSO DAS ETAPAS        │
│  │ 📎 requerimento_v2.pdf     │                              │
│  │                            │  ● Envio Docs ─ ✅ Concluída │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─   │  ● Análise RH ─ 🔄 Atual    │
│                               │  ○ Aprov.Chefia ─ Pendente  │
│  ENVIAR MENSAGEM              │  ○ Conclusão ─ Pendente     │
│  ┌──────────────────────┐    │                              │
│  │ Digite sua mensagem..│    │                              │
│  └──────────────────────┘    │                              │
│  [📎 Anexar] [📤 Enviar]     │                              │
└───────────────────────────────┴──────────────────────────────┘
```

**5. Painel de Gestão RH** (`/e-RH/processos/`)

```
┌─────────────────────────────────────────────────────────────┐
│  📋 Gestão de Processos                                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐         │
│  │  12  │  │   5  │  │   3  │  │  ⚠️2  │  │  127 │         │
│  │Abertos│  │Análise│  │Pend. │  │Atras.│  │Total │         │
│  │      │  │      │  │ Doc  │  │      │  │ mês  │         │
│  └──────┘  └──────┘  └──────┘  └──────┘  └──────┘         │
│                                                              │
│  FILTROS: [Situação ▼] [Categoria ▼] [Analista ▼] [🔍]     │
│                                                              │
│  ┌───┬─────────┬──────────┬────────────┬────────┬─────────┐ │
│  │🔴│PROC-042 │ João     │ Férias     │PEND.DOC│ 20/02   │ │
│  │  │         │ Silva    │            │        │ Maria   │ │
│  ├───┼─────────┼──────────┼────────────┼────────┼─────────┤ │
│  │🟡│PROC-041 │ Ana      │ Licença    │ABERTO  │ 20/02   │ │
│  │  │         │ Costa    │ Saúde      │        │ — (fila)│ │
│  ├───┼─────────┼──────────┼────────────┼────────┼─────────┤ │
│  │🟢│PROC-040 │ Pedro    │ Atualiz.   │EM ANÁLI│ 19/02   │ │
│  │  │         │ Souza    │ Cadastral  │SE      │ Maria   │ │
│  └───┴─────────┴──────────┴────────────┴────────┴─────────┘ │
│                                                              │
│  🔴 = Atrasado (passou SLA)  🟡 = Na fila  🟢 = Em andamento│
└─────────────────────────────────────────────────────────────┘
```

**6. Configuração de Modelos** (`/e-RH/configuracao/modelos-processo/`)

```
Tela com 3 abas (tabs):

[Informações Gerais] [Documentos Exigidos] [Etapas do Workflow] [Campos do Formulário]

Informações Gerais:
  - Nome, Código, Descrição, Instruções (rich text)
  - Categoria (select), Ícone, Cor
  - SLA (dias úteis), Requer aprovação chefia, Gera ação automática
  - Ativo, Visível no portal

Documentos Exigidos (tabela editável inline):
  | # | Nome | Descrição | Obrigatório | Tipos | Max MB | Modelo (upload) |
  | 1 | Requerimento | Formulário... | ✅ | pdf | 10 | 📎 modelo.pdf |
  | 2 | Comprovante  | Declaração... | ☐  | pdf,jpg | 5 | — |
  [+ Adicionar Documento]

Etapas do Workflow (drag & drop sortable):
  | # | Nome | Responsável | Ação Automática | Prazo |
  | 1 | Envio de Documentos | SERVIDOR | — | — |
  | 2 | Análise Documental  | RH       | — | 3 dias |
  | 3 | Aprovação Chefia     | CHEFIA   | — | 5 dias |
  | 4 | Conclusão            | RH       | GERAR_FERIAS | — |
  [+ Adicionar Etapa]

Campos do Formulário (drag & drop sortable):
  | # | Campo | Label | Tipo | Obrigatório | Opções |
  | 1 | data_inicio | Data de Início | DATE | ✅ | — |
  | 2 | data_fim | Data de Fim | DATE | ✅ | — |
  | 3 | abono_pecuniario | Abono Pecuniário | BOOLEAN | ☐ | — |
  | 4 | adiantamento_13 | Adiantamento 13º | BOOLEAN | ☐ | — |
  [+ Adicionar Campo]
```

### 4.7 Migração SQL

```sql
-- V013__modulo_processos.sql (renumerado: rescisão ficou como V013, processos V014)

-- Modelo de Processo (template configurado pelo RH)
CREATE TABLE processo_modelo (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    instrucoes TEXT,
    categoria VARCHAR(30) NOT NULL,
    icone VARCHAR(50),
    cor VARCHAR(7),
    prazo_atendimento_dias INTEGER,
    requer_aprovacao_chefia BOOLEAN DEFAULT FALSE,
    gera_acao_automatica BOOLEAN DEFAULT FALSE,
    ativo BOOLEAN DEFAULT TRUE,
    visivel_portal BOOLEAN DEFAULT TRUE,
    ordem_exibicao INTEGER DEFAULT 0,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_processo_modelo_codigo UNIQUE (codigo, unidade_gestora_id)
);

-- Documentos exigidos por modelo
CREATE TABLE processo_documento_modelo (
    id BIGSERIAL PRIMARY KEY,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    obrigatorio BOOLEAN DEFAULT TRUE,
    tipos_permitidos VARCHAR(100) DEFAULT 'pdf',
    tamanho_maximo_mb INTEGER DEFAULT 10,
    modelo_url VARCHAR(500),
    ordem INTEGER DEFAULT 0,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Etapas do workflow por modelo
CREATE TABLE processo_etapa_modelo (
    id BIGSERIAL PRIMARY KEY,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id) ON DELETE CASCADE,
    nome VARCHAR(200) NOT NULL,
    descricao TEXT,
    ordem INTEGER NOT NULL,
    tipo_responsavel VARCHAR(20) NOT NULL,
    acao_automatica VARCHAR(50),
    prazo_dias INTEGER,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Campos dinâmicos do formulário por modelo
CREATE TABLE processo_campo_modelo (
    id BIGSERIAL PRIMARY KEY,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id) ON DELETE CASCADE,
    nome_campo VARCHAR(100) NOT NULL,
    label VARCHAR(200) NOT NULL,
    tipo_campo VARCHAR(20) NOT NULL,
    obrigatorio BOOLEAN DEFAULT TRUE,
    opcoes_select TEXT,
    placeholder VARCHAR(200),
    ajuda TEXT,
    ordem INTEGER DEFAULT 0,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Processo (instância aberta por um servidor)
CREATE TABLE processo (
    id BIGSERIAL PRIMARY KEY,
    protocolo VARCHAR(20) NOT NULL UNIQUE,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id),
    servidor_id BIGINT NOT NULL REFERENCES servidor(id),
    vinculo_funcional_id BIGINT REFERENCES vinculo_funcional(id),
    situacao VARCHAR(30) NOT NULL DEFAULT 'ABERTO',
    etapa_atual INTEGER DEFAULT 1,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_ultima_atualizacao TIMESTAMP,
    data_conclusao TIMESTAMP,
    prazo_limite DATE,
    atribuido_para VARCHAR(100),
    departamento_atribuido VARCHAR(200),
    dados_formulario JSONB,
    observacao_servidor TEXT,
    resultado VARCHAR(20),
    justificativa_resultado TEXT,
    referencia_tipo VARCHAR(50),
    referencia_id BIGINT,
    prioridade VARCHAR(20) DEFAULT 'NORMAL',
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Documentos enviados (servidor ou RH)
CREATE TABLE processo_documento (
    id BIGSERIAL PRIMARY KEY,
    processo_id BIGINT NOT NULL REFERENCES processo(id),
    documento_modelo_id BIGINT REFERENCES processo_documento_modelo(id),
    nome_arquivo VARCHAR(500) NOT NULL,
    caminho_storage VARCHAR(1000) NOT NULL,
    tipo_arquivo VARCHAR(100),
    tamanho_bytes BIGINT,
    data_envio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    enviado_por VARCHAR(100) NOT NULL,
    situacao VARCHAR(20) DEFAULT 'PENDENTE',
    motivo_recusa TEXT,
    avaliado_por VARCHAR(100),
    data_avaliacao TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Mensagens (chat entre servidor e RH)
CREATE TABLE processo_mensagem (
    id BIGSERIAL PRIMARY KEY,
    processo_id BIGINT NOT NULL REFERENCES processo(id),
    autor VARCHAR(200) NOT NULL,
    tipo_autor VARCHAR(20) NOT NULL,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    lida BOOLEAN DEFAULT FALSE,
    data_leitura TIMESTAMP,
    anexo_nome VARCHAR(500),
    anexo_caminho VARCHAR(1000),
    anexo_tipo VARCHAR(100),
    unidade_gestora_id BIGINT,
    usuario_log VARCHAR(100),
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Histórico (auditoria)
CREATE TABLE processo_historico (
    id BIGSERIAL PRIMARY KEY,
    processo_id BIGINT NOT NULL REFERENCES processo(id),
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    acao VARCHAR(50) NOT NULL,
    situacao_anterior VARCHAR(30),
    situacao_nova VARCHAR(30),
    etapa_anterior INTEGER,
    etapa_nova INTEGER,
    usuario VARCHAR(200) NOT NULL,
    tipo_usuario VARCHAR(20),
    descricao TEXT,
    dados_extras JSONB,
    unidade_gestora_id BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Sequência para protocolo
CREATE SEQUENCE IF NOT EXISTS seq_processo_protocolo START WITH 1 INCREMENT BY 1;

-- Índices
CREATE INDEX idx_processo_protocolo ON processo(protocolo);
CREATE INDEX idx_processo_servidor ON processo(servidor_id);
CREATE INDEX idx_processo_modelo ON processo(processo_modelo_id);
CREATE INDEX idx_processo_situacao ON processo(situacao);
CREATE INDEX idx_processo_atribuido ON processo(atribuido_para);
CREATE INDEX idx_processo_prazo ON processo(prazo_limite);
CREATE INDEX idx_processo_data_abertura ON processo(data_abertura);
CREATE INDEX idx_processo_documento_processo ON processo_documento(processo_id);
CREATE INDEX idx_processo_documento_situacao ON processo_documento(situacao);
CREATE INDEX idx_processo_mensagem_processo ON processo_mensagem(processo_id);
CREATE INDEX idx_processo_mensagem_lida ON processo_mensagem(processo_id, lida);
CREATE INDEX idx_processo_historico_processo ON processo_historico(processo_id);

-- ============================================================
-- SEED: Modelos de processo padrão
-- ============================================================

-- 1. Solicitação de Férias
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica) VALUES
('PROC_FERIAS', 'Solicitação de Férias', 
 'Utilize este processo para solicitar o gozo de férias regulamentares. Após aprovação, as férias serão registradas automaticamente na sua ficha funcional.',
 E'1. Verifique seu saldo de férias antes de solicitar\n2. Preencha as datas de início e fim desejadas\n3. Indique se deseja abono pecuniário (vender 10 dias)\n4. Indique se deseja adiantamento do 13º salário\n5. Anexe o requerimento de férias assinado\n6. Aguarde a análise do RH e aprovação da chefia',
 'FERIAS', 'vacation', '#4CAF50', 5, true, true);

-- Documentos de Férias
INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'Requerimento de Férias', 'Formulário padrão de requerimento de férias preenchido e assinado pelo servidor', true, 'pdf', 10, 1),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'Comprovante de Não Débito', 'Declaração de que não há pendências ou débitos com o órgão', false, 'pdf,jpg,png', 5, 2);

-- Etapas de Férias
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, acao_automatica, prazo_dias) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'Envio de Documentos', 'Servidor envia os documentos exigidos', 1, 'SERVIDOR', null, null),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'Análise Documental', 'RH verifica se a documentação está completa e correta', 2, 'RH', null, 3),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'Aprovação da Chefia', 'Chefe imediato aprova ou nega a solicitação', 3, 'CHEFIA', null, 5),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'Conclusão', 'RH finaliza o processo e registra as férias', 4, 'RH', 'GERAR_FERIAS', null);

-- Campos de Férias
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'data_inicio', 'Data de Início das Férias', 'DATE', true, '', 'Data em que deseja iniciar o período de férias', 1),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'data_fim', 'Data de Fim das Férias', 'DATE', true, '', 'Data de término do período de férias', 2),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'abono_pecuniario', 'Deseja Abono Pecuniário?', 'BOOLEAN', false, '', 'Converter até 10 dias de férias em dinheiro', 3),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS'), 'adiantamento_13', 'Deseja Adiantamento do 13º?', 'BOOLEAN', false, '', 'Receber 50% do 13º salário junto com as férias', 4);

-- 2. Licença para Tratamento de Saúde
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica) VALUES
('PROC_LIC_SAUDE', 'Licença para Tratamento de Saúde',
 'Solicite licença médica para tratamento de saúde, mediante apresentação de atestado ou laudo médico.',
 E'1. Obtenha o atestado médico com CID e período de afastamento\n2. Preencha os dados do afastamento\n3. Anexe o atestado médico original (digitalizado)\n4. Se superior a 15 dias, será necessário perícia médica',
 'AFASTAMENTO', 'medical', '#F44336', 3, false, true);

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'Atestado Médico', 'Atestado médico original com CID, período de afastamento e assinatura do médico com CRM', true, 'pdf,jpg,png', 10, 1),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'Laudo Médico Complementar', 'Se disponível, anexar laudo médico detalhado', false, 'pdf', 10, 2),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'Exames Complementares', 'Resultados de exames que embasam o diagnóstico', false, 'pdf,jpg,png', 20, 3);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, acao_automatica, prazo_dias) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'Envio de Documentos', 'Servidor envia atestado e documentação médica', 1, 'SERVIDOR', null, null),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'Análise e Validação', 'RH analisa a documentação médica', 2, 'RH', null, 2),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'Registro do Afastamento', 'RH registra o afastamento no sistema', 3, 'RH', 'GERAR_AFASTAMENTO', null);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'data_inicio', 'Data de Início do Afastamento', 'DATE', true, '', 'Data indicada no atestado médico', 1),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'data_fim', 'Data de Fim do Afastamento', 'DATE', true, '', 'Data final indicada no atestado', 2),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'cid', 'CID-10', 'TEXT', true, 'Ex: J11', 'Código Internacional de Doenças constante no atestado', 3),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'crm_medico', 'CRM do Médico', 'TEXT', true, 'Ex: CRM-PE 12345', 'CRM do médico que emitiu o atestado', 4),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE'), 'nome_medico', 'Nome do Médico', 'TEXT', true, '', 'Nome completo do médico', 5);

-- 3. Licença Maternidade
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica) VALUES
('PROC_LIC_MATERNIDADE', 'Licença Maternidade',
 'Solicite licença maternidade de 120 ou 180 dias (empresa cidadã). Direito garantido pela Constituição Federal.',
 E'1. Apresentar atestado médico ou certidão de nascimento\n2. A licença pode iniciar até 28 dias antes do parto\n3. Prorrogação de 60 dias se o município aderiu ao Empresa Cidadã',
 'AFASTAMENTO', 'child', '#E91E63', 2, false, true);

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE'), 'Atestado Médico ou Certidão de Nascimento', 'Atestado médico com previsão de parto ou certidão de nascimento da criança', true, 'pdf,jpg,png', 10, 1);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, acao_automatica, prazo_dias) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE'), 'Envio de Documentos', 'Servidora envia documentação', 1, 'SERVIDOR', null, null),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE'), 'Análise e Registro', 'RH analisa e registra o afastamento', 2, 'RH', 'GERAR_AFASTAMENTO', 2);

-- 4. Atualização Cadastral
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica) VALUES
('PROC_ATUALIZACAO_CADASTRAL', 'Atualização de Dados Cadastrais',
 'Solicite atualização de endereço, telefone, email, dados bancários ou outros dados pessoais.',
 E'1. Informe quais dados deseja alterar\n2. Anexe comprovante da alteração (ex: comprovante de residência, documento bancário)\n3. Aguarde a atualização pelo RH',
 'CADASTRAL', 'edit', '#2196F3', 5, false, false);

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL'), 'Comprovante de Alteração', 'Comprovante de endereço, documento bancário ou outro documento que comprove a alteração solicitada', true, 'pdf,jpg,png', 10, 1);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, acao_automatica, prazo_dias) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL'), 'Envio de Documentos', 'Servidor envia documentação comprobatória', 1, 'SERVIDOR', null, null),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL'), 'Análise e Atualização', 'RH verifica e atualiza os dados no sistema', 2, 'RH', null, 5);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, opcoes_select, ajuda, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL'), 'tipo_alteracao', 'O que deseja alterar?', 'SELECT', true, '["Endereço","Telefone","E-mail","Dados Bancários","Estado Civil","Dependentes","Outros"]', 'Selecione o tipo de dado que deseja atualizar', 1),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL'), 'descricao_alteracao', 'Descreva a alteração', 'TEXTAREA', true, 'Descreva detalhadamente o que precisa ser alterado...', 'Informe os dados atuais e os novos dados', 2);

-- 5. Certidão de Tempo de Serviço
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica) VALUES
('PROC_CERTIDAO_TEMPO', 'Certidão de Tempo de Serviço',
 'Solicite a emissão de certidão de tempo de serviço para fins de aposentadoria, averbação ou comprovação.',
 E'1. Informe a finalidade da certidão\n2. Não é necessário anexar documentos\n3. A certidão será emitida pelo RH em até 10 dias úteis',
 'DOCUMENTAL', 'document', '#9C27B0', 10, false, false);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, acao_automatica, prazo_dias) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO'), 'Solicitação', 'Servidor faz a solicitação', 1, 'SERVIDOR', null, null),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO'), 'Emissão da Certidão', 'RH emite a certidão e disponibiliza', 2, 'RH', null, 10);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, opcoes_select, ajuda, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO'), 'finalidade', 'Finalidade da Certidão', 'SELECT', true, '["Aposentadoria","Averbação em outro órgão","Comprovação de vínculo","Outros"]', 'Para qual fim será utilizada a certidão', 1),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO'), 'observacao', 'Observações', 'TEXTAREA', false, 'Informações adicionais...', 'Informe detalhes que possam ajudar na emissão', 2);

-- 6. Licença Prêmio
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica) VALUES
('PROC_LIC_PREMIO', 'Licença Prêmio por Assiduidade',
 'Solicite a concessão de licença prêmio por assiduidade. Direito adquirido a cada 5 anos de efetivo exercício sem faltas injustificadas.',
 E'1. Verifique se você completou o período de 5 anos\n2. Preencha o período desejado (até 90 dias)\n3. Anexe o requerimento assinado\n4. Aguarde aprovação da chefia e do RH',
 'LICENCA', 'award', '#FF9800', 10, true, true);

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO'), 'Requerimento de Licença Prêmio', 'Requerimento preenchido e assinado solicitando a licença prêmio', true, 'pdf', 10, 1);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, acao_automatica, prazo_dias) VALUES
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO'), 'Envio de Documentos', 'Servidor envia requerimento', 1, 'SERVIDOR', null, null),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO'), 'Verificação de Direito', 'RH verifica se o servidor completou o período de 5 anos e não possui faltas', 2, 'RH', null, 5),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO'), 'Aprovação da Chefia', 'Chefe imediato aprova o período', 3, 'CHEFIA', null, 5),
((SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO'), 'Concessão', 'RH publica a portaria e registra o afastamento', 4, 'RH', 'GERAR_AFASTAMENTO', null);
```

### 4.8 Testes

| Classe de Teste | O que testa | Qtd estimada |
|-----------------|-------------|:---:|
| `ProcessoModeloServiceTest` | CRUD de modelos, validações, ativação/desativação | 10 |
| `ProcessoServiceTest` | Abrir processo, validar campos/docs, gerar protocolo | 18 |
| `ProcessoWorkflowServiceTest` | Avanço de etapas, transições de situação, SLA | 15 |
| `ProcessoDocumentoServiceTest` | Upload, download, aceitar/recusar documento | 10 |
| `ProcessoMensagemServiceTest` | Envio de mensagens, marcar lida, anexos | 8 |
| `ProcessoIntegracaoServiceTest` | Integração: deferir férias → gera ConcessaoFerias | 12 |
| `ProcessoControllerTest` | Endpoints REST (MockMvc) | 15 |
| `ProcessoGestaoControllerTest` | Endpoints de gestão RH | 12 |
| **Total** | | **~100 testes** |

**Cenários críticos:**
- Abrir processo com todos os docs obrigatórios presentes → sucesso
- Abrir processo sem doc obrigatório → erro de validação
- RH recusa documento → situação muda para PENDENTE_DOCUMENTACAO
- Servidor reenvia documento → volta para EM_ANALISE
- Deferir processo de férias → ConcessaoFerias criada automaticamente
- Processo ultrapassa SLA → marcado como atrasado
- Processo inativo por 30 dias → auto-arquivado
- Mensagem enviada pelo RH → notificação para servidor
- Cancelamento pelo servidor → só se não estiver DEFERIDO/CONCLUIDO

### 4.9 Checklist de Entrega — Fase 4

```
BACKEND:
  [x] Criar pacote ws.erh.processo (modelo, instancia, documento, mensagem, historico)
  [x] Implementar 8 entidades JPA: ProcessoModelo, ProcessoDocumentoModelo, 
      ProcessoEtapaModelo, ProcessoCampoModelo, Processo, ProcessoDocumento, 
      ProcessoMensagem, ProcessoHistorico
  [x] Implementar 10 enums (9 enums + AcaoProcesso com 24 valores)
  [x] Implementar ProcessoModeloService (CRUD modelos, docs, etapas, campos)
  [x] Implementar ProcessoService (abrir, cancelar, consultar)
  [x] Implementar ProcessoWorkflowService (avançar etapas, transições, SLA) — embutido no ProcessoGestaoService
  [x] Implementar ProcessoDocumentoService (upload/download via ArquivoStorageService)
  [x] Implementar ProcessoMensagemService (chat com notificações)
  [x] Implementar ProcessoGestaoService (atribuir, analisar, deferir, indeferir)
  [x] Implementar ProcessoIntegracaoService (vincula com FeriasService, AfastamentoService)
  [x] Implementar geração de protocolo (PROC-YYYY-NNNNNN)
  [ ] Implementar auto-arquivamento por inatividade (scheduled task) — PENDENTE
  [x] Criar ProcessoModeloController, ProcessoCatalogoController, 
      ProcessoController, ProcessoGestaoController (~45 endpoints)
  [x] Criar migração SQL V014__modulo_processos.sql + seed de 6 modelos
  [ ] 100+ testes unitários — PENDENTE

FRONTEND — CATÁLOGO E ABERTURA (servidor):
  [ ] Criar /e-RH/processos/catalogo/ (cards visuais por categoria) — PENDENTE (Fase 5)
  [ ] Criar /e-RH/processos/catalogo/{id}/ (detalhes + docs exigidos + instruções)  — PENDENTE (Fase 5)
  [ ] Criar /e-RH/processos/abrir/{id}/ (formulário dinâmico + upload) — PENDENTE (Fase 5)
  [ ] Criar /e-RH/processos/meus/ (meus processos com filtros) — PENDENTE (Fase 5)
  [ ] Criar /e-RH/processos/meus/{id}/ (timeline + chat + docs + etapas) — PENDENTE (Fase 5)
  [ ] Componente de upload com drag & drop e preview — PENDENTE (Fase 5)
  [ ] Componente de chat/mensagens (ProcessoChat) — PENDENTE (Fase 5)
  [ ] Componente de timeline de etapas (ProcessoTimeline) — PENDENTE (Fase 5)
  [ ] Componente de formulário dinâmico (DynamicForm) baseado nos campos do modelo — PENDENTE (Fase 5)

FRONTEND — GESTÃO RH:
  [x] Criar /e-RH/lancamento/processos/ (gestão + lista com ações de workflow)
  [ ] Criar /e-RH/processos/{id}/ (detalhe + avaliar docs + mensagens + ações) — PENDENTE
  [ ] Criar /e-RH/processos/fila/ (processos não atribuídos) — PENDENTE
  [ ] Criar /e-RH/processos/meus-atendimentos/ (atribuídos ao analista logado) — PENDENTE
  [x] Criar /e-RH/lancamento/processos/modelos/ (CRUD de modelos)
  [ ] Criar /e-RH/configuracao/modelos-processo/{id}/ (editar docs, etapas, campos) — PENDENTE
  [ ] Badge de processos pendentes no sidebar — PENDENTE
  [x] Filtros via tabela com dropdown actions (12 ações incluindo workflow)

VALIDAÇÃO:
  [ ] Testar CRUD completo de modelo de processo
  [ ] Testar abertura com formulário dinâmico + upload
  [ ] Testar recusa de documento + reenvio pelo servidor
  [ ] Testar workflow completo: abrir → analisar → deferir → executar (férias)
  [ ] Testar troca de mensagens (chat ida e volta)
  [ ] Testar SLA (processo atrasado aparece no dashboard)
  [ ] Testar auto-arquivamento por inatividade
  [ ] Testar integração: processo de licença saúde → gera Afastamento
  [ ] Testar que servidor só vê seus processos
```

---

## FASE 5 — PORTAL DO SERVIDOR / AUTOATENDIMENTO (4 semanas)

> **Pré-requisito:** Fases 1-4 completas e testadas  
> **Objetivo:** Fornecer um portal web mobile-first onde os servidores da prefeitura acessam dados pessoais, contracheques, informes de rendimentos, saldo de férias, e utilizam o Módulo de Processos (Fase 4) para abrir solicitações — tudo com autenticação própria por CPF.

### 5.1 Arquitetura

O portal é uma **nova seção do frontend** com autenticação por CPF + senha do servidor (não é o login de RH). O backend adiciona endpoints sob `/api/v1/portal/` com segurança diferenciada (role `SERVIDOR`).

> **IMPORTANTE:** O Portal **NÃO** reimplementa lógica de solicitações/processos. Ele consome diretamente o **Módulo de Processos** (Fase 4) para abertura de solicitações, upload de documentos e acompanhamento. A entidade `PortalSolicitacao` abaixo é legada e **será substituída** pelas tabelas `processo` e `processo_mensagem` da Fase 4.

```
ARQUITETURA:
                                                              
  ┌──────────────────┐       ┌────────────────┐       ┌──────────────┐
  │  Frontend Portal  │──────▶│  API Gateway   │──────▶│ eRH-Service  │
  │ /e-RH/portal/*    │  JWT  │  (porta 8080)  │       │ (porta 8083) │
  │  role: SERVIDOR   │       │                │       │              │
  └──────────────────┘       └────────────────┘       │  /api/v1/    │
                                                       │   portal/*   │
  ┌──────────────────┐                                 │              │
  │  Frontend RH      │                                │  @PreAuth    │
  │ /e-RH/* (existente)│──────────────────────────────▶│  SERVIDOR    │
  │  role: ADMIN/      │                               │              │
  │  GESTOR/ANALISTA   │                               └──────────────┘
  └──────────────────┘
```

### 5.2 Funcionalidades do Portal

| Módulo | Funcionalidade | Prioridade | Dependência |
|--------|---------------|:---:|:---:|
| **Dados Pessoais** | Visualizar ficha funcional completa | ALTA | Servidor+Vínculo existente |
| **Contracheque** | Visualizar/baixar demonstrativo de pagamento | ALTA | FolhaPagamento existente |
| **Informe IR** | Visualizar/baixar comprovante de rendimentos | ALTA | Relatório existente |
| **Ficha Financeira** | Visualizar/baixar ficha financeira anual | ALTA | Relatório existente |
| **Férias** | Consultar saldo + solicitar férias | ALTA | **Fase 1** |
| **Afastamentos** | Consultar histórico de afastamentos | MÉDIA | **Fase 2** |
| **Atualização Cadastral** | Solicitar atualização de dados (endereço, telefone, banco) | ALTA | — |
| **Processos** | Abrir/acompanhar processos via Módulo de Processos (Fase 4) | ALTA | **Fase 4** |
| **Dependentes** | Consultar dependentes cadastrados | MÉDIA | Dependente existente |
| **Margem Consignável** | Consultar margem disponível | BAIXA | Folha existente |
| **Notificações** | Receber avisos (férias a vencer, documentos disponíveis) | MÉDIA | — |

### 5.3 Modelo de Dados — Notificações e Credenciais

> **Nota:** As entidades `PortalSolicitacao` e `PortalSolicitacaoHistorico` não serão mais criadas. O Portal utilizará as tabelas `processo`, `processo_mensagem` e `processo_documento` do Módulo de Processos (Fase 4). Mantém-se apenas `PortalCredencial` (login) e `PortalNotificacao`.

#### Entidades REMOVIDAS (substituídas pela Fase 4)

As seguintes entidades eram originalmente planejadas mas foram **substituídas** pelo Módulo de Processos:

```java
// ===== PortalSolicitacao.java =====
@Entity
@Table(name = "portal_solicitacao")
public class PortalSolicitacao extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_funcional_id")
    private VinculoFuncional vinculoFuncional;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", nullable = false)
    private TipoSolicitacao tipo;
    
    @Column(name = "titulo", nullable = false)
    private String titulo;
    
    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", nullable = false)
    private SituacaoSolicitacao situacao;
    
    @Column(name = "data_abertura", nullable = false)
    private LocalDateTime dataAbertura;
    
    @Column(name = "data_atendimento")
    private LocalDateTime dataAtendimento;
    
    @Column(name = "data_conclusao")
    private LocalDateTime dataConclusao;
    
    @Column(name = "atendente")
    private String atendente;                 // Usuário RH que atendeu
    
    @Column(name = "resposta", columnDefinition = "TEXT")
    private String resposta;
    
    @Column(name = "prioridade")
    @Enumerated(EnumType.STRING)
    private Prioridade prioridade;            // BAIXA, NORMAL, ALTA, URGENTE
    
    // === Dados específicos (JSON flexível) ===
    @Column(name = "dados_solicitacao", columnDefinition = "JSONB")
    private String dadosSolicitacao;          // Ex: {"enderecoNovo": {...}, "bancoNovo": {...}}
    
    @OneToMany(mappedBy = "solicitacao", cascade = CascadeType.ALL)
    private List<PortalSolicitacaoHistorico> historico;
}

// ===== PortalSolicitacaoHistorico.java =====
@Entity
@Table(name = "portal_solicitacao_historico")
public class PortalSolicitacaoHistorico {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "solicitacao_id", nullable = false)
    private PortalSolicitacao solicitacao;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @Column(name = "situacao_anterior")
    @Enumerated(EnumType.STRING)
    private SituacaoSolicitacao situacaoAnterior;
    
    @Column(name = "situacao_nova")
    @Enumerated(EnumType.STRING)
    private SituacaoSolicitacao situacaoNova;
    
    @Column(name = "usuario")
    private String usuario;
    
    @Column(name = "observacao", columnDefinition = "TEXT")
    private String observacao;
}

// ===== PortalNotificacao.java =====
@Entity
@Table(name = "portal_notificacao")
public class PortalNotificacao extends AbstractTenantEntity {
    
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Column(name = "titulo", nullable = false)
    private String titulo;
    
    @Column(name = "mensagem", columnDefinition = "TEXT")
    private String mensagem;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo")
    private TipoNotificacao tipo;             // INFO, ALERTA, DOCUMENTO, SOLICITACAO
    
    @Column(name = "lida")
    private Boolean lida = false;
    
    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;
    
    @Column(name = "link")
    private String link;                      // Deep link para ação (ex: /portal/ferias)
}
```

#### Enums do Portal

```java
public enum TipoSolicitacao {
    FERIAS("Solicitação de Férias"),
    LICENCA("Solicitação de Licença"),
    ATUALIZACAO_CADASTRAL("Atualização Cadastral"),
    ATUALIZACAO_DADOS_BANCARIOS("Atualização de Dados Bancários"),
    DECLARACAO("Solicitação de Declaração"),
    CERTIDAO_TEMPO_SERVICO("Certidão de Tempo de Serviço"),
    AVERBACAO("Averbação de Tempo de Serviço"),
    AUXILIO("Solicitação de Auxílio"),
    RECLAMACAO("Reclamação/Ouvidoria"),
    OUTROS("Outros");
    
    private final String descricao;
}

public enum SituacaoSolicitacao {
    ABERTA,            // Recém aberta pelo servidor
    EM_ANALISE,        // RH está analisando
    PENDENTE_DOCUMENTO,// Aguardando documento do servidor
    APROVADA,          // Aprovada
    REJEITADA,         // Rejeitada (com justificativa)
    CONCLUIDA,         // Concluída/Atendida
    CANCELADA          // Cancelada pelo servidor
}

public enum Prioridade {
    BAIXA, NORMAL, ALTA, URGENTE
}

public enum TipoNotificacao {
    INFO,          // Informativo geral
    ALERTA,        // Alerta (férias a vencer, etc.)
    DOCUMENTO,     // Documento disponível (contracheque, IR)
    SOLICITACAO    // Atualização de solicitação
}
```

### 5.4 Endpoints REST — Portal do Servidor

> **Nota:** Os endpoints de Solicitações foram substituídos pelo Módulo de Processos (Fase 4). O Portal consome `/api/v1/processos/catalogo/*` e `/api/v1/processos/meus/*` diretamente.

```
-- Autenticação do Portal
POST   /api/v1/portal/auth/login                     → Login por CPF + senha
POST   /api/v1/portal/auth/primeiro-acesso            → Primeiro acesso (definir senha)
POST   /api/v1/portal/auth/recuperar-senha            → Recuperar senha (email do servidor)
PUT    /api/v1/portal/auth/alterar-senha               → Alterar senha

-- Dados Pessoais
GET    /api/v1/portal/meus-dados                       → Ficha funcional completa
GET    /api/v1/portal/meus-dados/dependentes           → Dependentes cadastrados
GET    /api/v1/portal/meus-dados/vinculos              → Vínculos funcionais

-- Contracheque
GET    /api/v1/portal/contracheque                     → Listar competências disponíveis
GET    /api/v1/portal/contracheque/{competencia}       → Detalhes do contracheque
GET    /api/v1/portal/contracheque/{competencia}/pdf   → Download PDF

-- Férias
GET    /api/v1/portal/ferias/saldo                     → Saldo de férias (períodos aquisitivos)
GET    /api/v1/portal/ferias/historico                  → Histórico de férias gozadas
POST   /api/v1/portal/ferias/solicitar                 → Solicitar férias (abre solicitação)

-- Afastamentos  
GET    /api/v1/portal/afastamentos                     → Histórico de afastamentos

-- Informe de Rendimentos
GET    /api/v1/portal/rendimentos                      → Listar anos disponíveis
GET    /api/v1/portal/rendimentos/{ano}/pdf            → Download informe IR PDF

-- Ficha Financeira
GET    /api/v1/portal/ficha-financeira/{ano}           → Ficha financeira anual
GET    /api/v1/portal/ficha-financeira/{ano}/pdf       → Download PDF

-- Margem Consignável
GET    /api/v1/portal/margem-consignavel               → Consultar margem

-- Processos (consome endpoints da Fase 4)
-- O Portal redireciona para as rotas do Módulo de Processos:
-- GET  /api/v1/processos/catalogo           → Catálogo de processos disponíveis
-- GET  /api/v1/processos/meus               → Meus processos
-- POST /api/v1/processos                    → Abrir novo processo
-- GET  /api/v1/processos/{id}               → Detalhe + mensagens + docs
-- POST /api/v1/processos/{id}/mensagens     → Enviar mensagem

-- Notificações
GET    /api/v1/portal/notificacoes                     → Listar notificações
PUT    /api/v1/portal/notificacoes/{id}/lida           → Marcar como lida
GET    /api/v1/portal/notificacoes/nao-lidas           → Contagem de não lidas

-- Gestão de Processos (lado RH) → já implementada na Fase 4
-- Usar endpoints de /api/v1/processos/gestao/* da Fase 4
```

### 5.5 Frontend — Portal do Servidor

#### Novas rotas:

```
/e-RH/portal/                              → Página de login do portal (CPF + senha)
/e-RH/portal/home/                         → Home do servidor (cards resumo)
/e-RH/portal/meus-dados/                   → Ficha funcional (somente leitura)
/e-RH/portal/contracheque/                 → Lista de contracheques + visualização/download
/e-RH/portal/ferias/                       → Saldo de férias + histórico + botão solicitar
/e-RH/portal/afastamentos/                 → Histórico de afastamentos
/e-RH/portal/rendimentos/                  → Informe de rendimentos por ano
/e-RH/portal/ficha-financeira/             → Ficha financeira anual
/e-RH/portal/processos/                    → Catálogo de processos (cards visuais — consome Fase 4)
/e-RH/portal/processos/abrir/{id}/         → Abrir novo processo (formulário dinâmico — Fase 4)
/e-RH/portal/processos/meus/              → Meus processos (lista com status)
/e-RH/portal/processos/meus/{id}/         → Acompanhar processo (timeline + chat — Fase 4)
/e-RH/portal/notificacoes/                 → Central de notificações
/e-RH/portal/alterar-senha/               → Alterar senha

-- No lado RH (gestão de processos — já implementada na Fase 4)
-- Utiliza /e-RH/processos/ e /e-RH/processos/{id}/ da Fase 4
```

#### Design do Portal

**Identidade visual diferenciada:** O portal do servidor terá um layout mais simples e amigável (mobile-first) comparado ao módulo RH. Cores mais suaves, linguagem acessível.

```
┌─────────────────────────────────────────────────────────────┐
│  🏛️  Portal do Servidor           [🔔 3]  [👤 João Silva] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ 💰       │  │ 🏖️       │  │ 📄       │  │ 📝       │   │
│  │Contrache-│  │ Minhas   │  │ Informe  │  │ Solici-  │   │
│  │que       │  │ Férias   │  │ de IR    │  │ tações   │   │
│  │ FEV/2026 │  │ 15 dias  │  │ 2025     │  │ 2 aberta │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ 📋       │  │ 👨‍👩‍👧‍👦       │  │ 💳       │  │ 📊       │   │
│  │ Meus     │  │ Dependen-│  │ Dados    │  │ Ficha    │   │
│  │ Dados    │  │ tes      │  │ Bancários│  │Financeira│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                             │
│  📣 AVISOS                                                  │
│  ├─ ⚠️ Suas férias vencem em 45 dias (período 2024/2025)   │
│  ├─ 📄 Contracheque de JAN/2026 disponível                 │
│  └─ ✅ Sua solicitação #1234 foi concluída                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Gestão de solicitações (lado RH):**

```
┌─────────────────────────────────────────────────────────────┐
│  📋 Gestão de Solicitações                   [Filtros ▼]    │
├──────────┬──────────┬──────────┬──────────┬─────────────────┤
│ ABERTAS  │ EM ANÁLISE│ PENDENTES │ RESOLVIDAS│              │
│   (8)    │    (3)   │    (2)   │   (45)   │                │
├──────────┼──────────┴──────────┴──────────┘                │
│ #1301    │  Tipo: Férias                                    │
│ João     │  Data: 18/02/2026                                │
│ Silva    │  "Solicito férias de 15 dias a partir de..."     │
│ 🔴 ALTA  │  [Atender] [Ver Detalhes]                       │
├──────────┤                                                  │
│ #1300    │  Tipo: Atualização Cadastral                     │
│ Maria    │  Data: 17/02/2026                                │
│ Santos   │  "Solicito alteração de endereço..."             │
│ 🟡 NORMAL│  [Atender] [Ver Detalhes]                       │
└──────────┴──────────────────────────────────────────────────┘
```

### 5.6 Segurança do Portal

```java
// SecurityConfig — adicionar regras para portal
@Configuration
public class SecurityConfig {
    
    // Endpoints do portal: autenticação separada
    // O servidor faz login com CPF + senha, recebe JWT com role SERVIDOR
    // O JWT contém: servidorId, vinculoFuncionalId, unidadeGestoraId
    
    // Aspect de segurança: servidor só acessa SEUS dados
    @Aspect
    @Component
    public class PortalSecurityAspect {
        
        @Before("@annotation(PortalEndpoint)")
        public void verificarAcessoServidor(JoinPoint jp) {
            Long servidorIdLogado = SecurityUtils.getServidorId();
            // Garantir que o servidor logado só consulta/modifica seus próprios dados
            // Qualquer tentativa de acessar dados de outro servidor → 403 Forbidden
        }
    }
}
```

### 5.7 Migração SQL

```sql
-- V015__portal_servidor.sql (V014 agora é o Módulo de Processos)

-- Credenciais do portal (autenticação separada)
CREATE TABLE portal_credencial (
    id BIGSERIAL PRIMARY KEY,
    servidor_id BIGINT NOT NULL UNIQUE REFERENCES servidor(id),
    cpf VARCHAR(11) NOT NULL UNIQUE,
    senha_hash VARCHAR(255),
    primeiro_acesso BOOLEAN DEFAULT TRUE,
    ativo BOOLEAN DEFAULT TRUE,
    tentativas_login INTEGER DEFAULT 0,
    bloqueado_ate TIMESTAMP,
    ultimo_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- NOTA: Tabelas portal_solicitacao e portal_solicitacao_historico REMOVIDAS
-- O Portal usa as tabelas do Módulo de Processos (V014) para solicitações.

-- Notificações
CREATE TABLE portal_notificacao (
    id BIGSERIAL PRIMARY KEY,
    servidor_id BIGINT NOT NULL REFERENCES servidor(id),
    titulo VARCHAR(200) NOT NULL,
    mensagem TEXT,
    tipo VARCHAR(20) DEFAULT 'INFO',
    lida BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    link VARCHAR(500),
    unidade_gestora_id BIGINT,
    excluido BOOLEAN DEFAULT FALSE
);

-- Índices
CREATE INDEX idx_portal_notificacao_servidor ON portal_notificacao(servidor_id);
CREATE INDEX idx_portal_notificacao_lida ON portal_notificacao(servidor_id, lida);
CREATE INDEX idx_portal_credencial_cpf ON portal_credencial(cpf);
```

### 5.8 Checklist de Entrega — Fase 5

```
BACKEND:
  [ ] Criar pacote ws.erh.portal (auth, notificacao, consulta)
  [ ] Implementar PortalAuthService (login CPF, primeiro acesso, recuperação)
  [ ] Implementar PortalConsultaService (contracheque, férias, afastamentos, rendimentos)
  [ ] Implementar PortalNotificacaoService (criar, listar, marcar lida)
  [ ] Implementar PortalSecurityAspect (servidor só acessa seus dados)
  [ ] Implementar auto-geração de notificações (contracheque disponível, férias a vencer)
  [ ] Controllers: PortalAuthController, PortalController
  [ ] Integrar com ProcessoService (Fase 4) para solicitações dentro do portal
  [ ] Criar migração SQL V015__portal_servidor.sql
  [ ] 40+ testes unitários

FRONTEND — PORTAL:
  [ ] Criar layout do portal (PortalLayout - mobile-first, simples)
  [ ] Criar /e-RH/portal/ (login CPF + senha)
  [ ] Criar /e-RH/portal/home/ (dashboard com cards)
  [ ] Criar /e-RH/portal/meus-dados/ (ficha funcional read-only)
  [ ] Criar /e-RH/portal/contracheque/ (lista + visualização + download PDF)
  [ ] Criar /e-RH/portal/ferias/ (saldo + histórico + link para abrir processo)
  [ ] Criar /e-RH/portal/afastamentos/ (histórico read-only)
  [ ] Criar /e-RH/portal/rendimentos/ (download informe IR por ano)
  [ ] Criar /e-RH/portal/ficha-financeira/ (download por ano)
  [ ] Criar /e-RH/portal/processos/ (catálogo de processos — consome Fase 4)
  [ ] Criar /e-RH/portal/processos/abrir/{id}/ (formulário dinâmico — Fase 4)
  [ ] Criar /e-RH/portal/processos/meus/ (meus processos — Fase 4)
  [ ] Criar /e-RH/portal/processos/meus/{id}/ (acompanhar — Fase 4)
  [ ] Criar /e-RH/portal/notificacoes/ (lista com badges)
  [ ] Criar /e-RH/portal/alterar-senha/
  [ ] Implementar PortalContext (autenticação separada)
  [ ] Reutilizar componentes da Fase 4: ProcessoTimeline, ProcessoChat, DynamicForm

VALIDAÇÃO:
  [ ] Testar login CPF + primeiro acesso
  [ ] Testar que servidor só vê seus dados (segurança)
  [ ] Testar download de contracheque PDF
  [ ] Testar abertura de processo de férias direto do portal
  [ ] Testar acompanhamento de processo com chat e docs
  [ ] Testar notificações automáticas
  [ ] Testar responsividade mobile
  [ ] Testar bloqueio por tentativas de login
```

---

## CRONOGRAMA CONSOLIDADO

```
SEMANA  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18
        ├──────────┤
        │ FASE 1   │  Módulo de Férias
        │ Backend  │  (3 semanas)
        │+Frontend │
        │+Testes   │
                    ├───────┤
                    │FASE 2 │  Módulo de Afastamentos
                    │       │  (2 semanas)
                    │       │
                             ├──────────┤
                             │  FASE 3  │  Módulo de Rescisão
                             │          │  (3 semanas)
                             │          │
                                         ├── VALIDAÇÃO ──┤
                                         │Integrada(1sem)│  Testar os 3 módulos juntos
                                         │               │  + Integração com folha
                                                          ├──────────┤
                                                          │ FASE 4   │ Módulo de Processos
                                                          │ Workflow  │ (3 semanas)
                                                          │+Catálogo │
                                                          │+Chat     │
                                                                       ├──────────────────┤
                                                                       │     FASE 5       │
                                                                       │  Portal Servidor │
                                                                       │   (4 semanas)    │
                                                                       │  Consome Fase 4  │
```

### Marcos (Milestones)

| Marco | Semana | Entregável |
|-------|:------:|------------|
| **M1** | 3 | Módulo Férias funcional (backend + frontend + testes) |
| **M2** | 5 | Módulo Afastamentos funcional |
| **M3** | 8 | Módulo Rescisão funcional |
| **M4** | 9 | Validação integrada dos 3 módulos |
| **M5** | 10 | Módulo de Processos — CRUD de modelos + catálogo + abertura |
| **M6** | 12 | Módulo de Processos — Workflow completo + chat + integração |
| **M7** | 13 | Portal do Servidor — Autenticação + Dados Pessoais + Contracheque |
| **M8** | 15 | Portal — Processos integrados + Férias + Notificações |
| **M9** | 18 | Portal completo + Aceite Final |

---

## MÉTRICAS DE SUCESSO

| Métrica | Meta |
|---------|------|
| Cobertura de testes (novos módulos) | > 70% |
| Endpoints REST implementados | +130 novos endpoints (~85 Fases 1-3, ~45 Fase 4, +15 Portal) |
| Páginas frontend | +35 novas páginas (~20 Fases 1-3, ~10 Fase 4, ~15 Portal) |
| Relatórios Jasper novos | +4 (Recibo Férias, Controle Férias, TRCT, Demonstrativo Rescisão) |
| Migrações SQL | +5 (V011 a V015) |
| Testes unitários novos | +315 (~215 Fases 1-3, ~100 Fase 4 Processos) |
| Tempo de processamento férias na folha | < 5s por lote |
| Compatibilidade eSocial | S-2230, S-2299 preparados |
| SLA de processos | Dashboard com % dentro do prazo |
| Processos online | Eliminar 80% dos atendimentos presenciais |

---

## RISCOS E MITIGAÇÕES

| Risco | Impacto | Probabilidade | Mitigação |
|-------|:-------:|:-------------:|-----------|
| Estatuto municipal varia por cidade | ALTO | ALTA | Parametrizar regras no MotivoDesligamento e TipoAfastamento |
| Cálculos de férias/rescisão incorretos | ALTO | MÉDIA | Testes com valores reais de prefeituras parceiras |
| Integração com folha quebra processamento existente | ALTO | MÉDIA | Testes de regressão no ProcessamentoFolhaService |
| Performance do portal com muitos servidores | MÉDIO | BAIXA | Paginação, cache, índices otimizados |
| Segurança do portal (vazamento de dados) | ALTO | BAIXA | Aspect de segurança, testes de penetração, auditoria |

---

## ORDEM DE IMPLEMENTAÇÃO SUGERIDA (DENTRO DE CADA FASE)

### Para cada fase, seguir esta sequência:

```
1. Migração SQL (criar tabelas)
2. Entidades JPA + Enums
3. DTOs (Request + Response)
4. Repositories  
5. Service (regras de negócio + cálculos)
6. Controller (endpoints REST)
7. Testes unitários (service + controller)
8. Integração com módulos existentes (folha, vínculo)
9. Frontend: config.ts + types.ts + api.ts
10. Frontend: páginas (tabela + formulário)
11. Frontend: componentes especiais (preview cálculo, timeline, wizard)
12. Testes de integração (frontend ↔ backend)
13. Relatórios Jasper
14. Documentação da API (Swagger annotations)
```

---

*Documento gerado em 20/02/2026 como planejamento para implementação dos módulos Férias, Afastamentos, Rescisão, Processos/Workflow e Portal do Servidor no sistema eRH. Atualizado para incluir o Módulo de Processos como Fase 4, permitindo abertura e acompanhamento de solicitações online.*
