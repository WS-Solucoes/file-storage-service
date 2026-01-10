# 🏗️ PLANO DE REFATORAÇÃO DO eRH-SERVICE

## Estrutura Modular e Diagrama de Integração

**Data:** 09 de Janeiro de 2026  
**Versão:** 2.0 - Alinhado com Documentação Técnica  
**Objetivo:** Reorganizar o eRH-Service em módulos funcionais

---

## 0. REFERÊNCIA: DOCUMENTAÇÃO TÉCNICA (PARTE 1-27)

> ⚠️ **IMPORTANTE:** As PARTEs da documentação técnica NÃO seguem uma estrutura linear por módulo.
> Elas documentam aspectos transversais do sistema. O agrupamento abaixo organiza por FUNCIONALIDADE.

### Mapeamento Real das PARTEs

| PARTE | Tema | Tipo |
|-------|------|------|
| **1** | Permissões MBAC + Stakeholders | Transversal |
| **2** | Processamento de Folha (fluxo micro) | Folha |
| **3** | Consignado (funcionalidade faltante) | Folha |
| **4** | Diagrama de Classes (núcleo) | Transversal |
| **5** | Stakeholders por Módulo/Casos de Uso | Transversal |
| **6** | Licenças e Afastamentos | Temporal |
| **7** | Rescisões e Desligamentos | Carreira |
| **8** | Integração eSocial | Obrigações |
| **9** | PCCS e Carreira | Carreira |
| **10** | Aposentadoria e Pensões | Carreira |
| **11** | Portal do Servidor | Apoio |
| **12** | Frequência e Ponto | Temporal |
| **13** | Concursos Públicos | Carreira |
| **14** | Avaliação de Desempenho | Carreira |
| **15** | Saúde Ocupacional (SST) | Temporal |
| **16** | DIRF/Informe Rendimentos | Obrigações |
| **17** | RAIS | Obrigações |
| **18** | SEFIP/GFIP | Obrigações |
| **19** | Benefícios (VA/VT/Auxílios) | Cadastro |
| **20** | Capacitação/Treinamento | Carreira |
| **21** | Cessão/Requisição | Carreira |
| **22** | Recadastramento/Prova de Vida | Cadastro |
| **23** | Gestão Documental (GED) | Apoio |
| **24** | Auditoria e Logs | Core |
| **25** | Notificações e Alertas | Apoio |
| **26** | Dashboards e Indicadores | Apoio |
| **27A/B** | PAD (Processos Disciplinares) | Apoio |

---

## 1. ESTRUTURA DE MÓDULOS PROPOSTA

### 1.1 Arquitetura Multi-Tenant (Gerenciado pelo COMMON)

```
⚠️  O TENANT JÁ É GERENCIADO PELO MÓDULO COMMON - NÃO DUPLICAR

common/src/main/java/ws/common/auth/
├── TenantContext.java          # ThreadLocal com UG, role, módulo
├── JwtFilter.java              # Popula TenantContext do JWT
├── JwtService.java             # Gera JWT com dados de tenant
└── SecurityConfig.java         # Configuração de segurança

eRH-Service APENAS CONSOME:
├── TenantContext.getCurrentUnidadeGestoraId()  # Para filtros
├── TenantContext.getCurrentUnidadeGestoraRole() # Para auditoria
└── UnidadeGestoraRepository (do common)         # Para lookup
```

### 1.2 Visão Geral - Agrupamento por Domínio Funcional

```
eRH-Service/src/main/java/ws/erh/
│
├── 📦 core/                    ← Infraestrutura do serviço
│   ├── config/                 # Configurações Spring (usa common)
│   ├── filter/                 # HibernateFilterAspect (aplica filtros)
│   ├── audit/                  # PARTE 24: Auditoria e Logs
│   ├── exception/              # Tratamento de erros
│   └── security/               # PARTE 1: MBAC (usa common)
│
├── 📦 cadastro/                ← Dados mestres de servidores
│   ├── servidor/               # Servidores (entidade central)
│   ├── dependente/             # Dependentes do servidor
│   ├── departamento/           # Departamentos/Lotações
│   ├── cargo/                  # Cargos/Níveis/CBO
│   ├── vinculo/                # Vínculo Funcional
│   ├── beneficio/              # PARTE 19: VA/VT/Auxílios
│   └── recadastramento/        # PARTE 22: Prova de Vida
│
├── 📦 folha/                   ← Folha de Pagamento
│   ├── rubrica/                # Vantagens/Descontos
│   ├── processamento/          # PARTE 2: Motor de cálculo
│   ├── decimoterceiro/         # 13º Salário
│   ├── consignado/             # PARTE 3: Empréstimos consignados
│   └── rescisao/               # PARTE 7: Verbas rescisórias
│
├── 📦 obrigacoes/              ← Obrigações legais e fiscais
│   ├── esocial/                # PARTE 8: eSocial
│   ├── tce/                    # TCE/SAGRES
│   ├── dirf/                   # PARTE 16: DIRF/Informe Rendimentos
│   ├── rais/                   # PARTE 17: RAIS
│   └── sefip/                  # PARTE 18: SEFIP/GFIP
│
├── 📦 temporal/                ← Gestão de tempo e afastamentos
│   ├── ferias/                 # Férias
│   ├── ponto/                  # PARTE 12: Frequência/REP
│   ├── afastamento/            # PARTE 6: Licenças/Afastamentos
│   └── sst/                    # PARTE 15: Saúde Ocupacional
│
├── 📦 carreira/                ← Evolução funcional
│   ├── concurso/               # PARTE 13: Concursos Públicos
│   ├── capacitacao/            # PARTE 20: Treinamentos/PDI
│   ├── avaliacao/              # PARTE 14: Desempenho/Probatório
│   ├── progressao/             # PARTE 9: PCCS/Progressão
│   ├── aposentadoria/          # PARTE 10: Aposentadoria
│   ├── pensionista/            # PARTE 10: Pensões
│   └── cessao/                 # PARTE 21: Cessão/Requisição
│
├── 📦 apoio/                   ← Apoio e gestão
│   ├── portal/                 # PARTE 11: Portal do Servidor
│   ├── simulacao/              # Simulações de folha
│   ├── relatorio/              # Relatórios Jasper
│   ├── documento/              # PARTE 23: GED
│   ├── notificacao/            # PARTE 25: Alertas
│   ├── dashboard/              # PARTE 26: Indicadores
│   └── pad/                    # PARTE 27: Processos Disciplinares
│
└── 📦 integracao/              ← Integrações externas
    ├── banco/                  # Bancos (consignados)
    └── comum/                  # common-service
```

---

## 2. DIAGRAMA DE DEPENDÊNCIA ENTRE MÓDULOS

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           DEPENDÊNCIAS DO eRH-SERVICE                            │
└─────────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────┐
                                    │    CORE     │
                                    │ (PARTE 1,24)│
                                    └──────┬──────┘
                                           │
        ┌──────────────────────────────────┼──────────────────────────────────┐
        │                                  │                                  │
        ▼                                  ▼                                  ▼
┌───────────────┐               ┌─────────────────┐               ┌───────────────┐
│   CADASTRO    │               │   OBRIGAÇÕES    │               │     APOIO     │
│ (P19, P22)    │               │ (P8,16,17,18)   │               │(P11,23,25,26) │
└───────┬───────┘               └────────┬────────┘               └───────┬───────┘
        │                                │                                │
        ▼                                ▼                                ▼
┌───────────────┐               ┌─────────────────┐               ┌───────────────┐
│     FOLHA     │◄──────────────│    TEMPORAL     │               │  PAD (P27)    │
│ (P2,3,7)      │               │ (P6,12,15)      │               └───────────────┘
└───────┬───────┘               └─────────────────┘
        │                                ▲
        │                                │
        └────────────────────────────────┤
                                         │
                              ┌──────────┴──────────┐
                              │      CARREIRA       │
                              │ (P7,9,10,13,14,20,21)│
                              └─────────────────────┘
```

### 2.1 Matriz de Dependência Corrigida

| Módulo | PARTEs | Depende de | É usado por |
|--------|--------|-----------|-------------|
| **core** | 1, 24 | common | Todos |
| **cadastro** | 19, 22 | core | folha, obrigações, temporal, carreira, apoio |
| **folha** | 2, 3, 7 | core, cadastro | obrigações, temporal, apoio |
| **obrigações** | 8, 16, 17, 18 | core, cadastro, folha | apoio (relatórios) |
| **temporal** | 6, 12, 15 | core, cadastro, folha | obrigações, carreira |
| **carreira** | 7, 9, 10, 13, 14, 20, 21 | core, cadastro | folha (progressão afeta salário) |
| **apoio** | 11, 23, 25, 26, 27 | core, cadastro, folha | - (final da cadeia) |

---

## 3. MAPEAMENTO: ESTRUTURA ATUAL → NOVA ESTRUTURA

### 3.1 Entidades Existentes (model/)

| Atual | Novo Local | Documentação Relacionada |
|-------|------------|--------------------------|
| `Servidor.java` | `cadastro/servidor/model/` | PARTE 4 (Diagrama Classes) |
| `Funcionario.java` | `cadastro/servidor/model/` | PARTE 4 (Diagrama Classes) |
| `Dependente.java` | `cadastro/dependente/model/` | PARTE 4 (Diagrama Classes) |
| `DepartamentoRH.java` | `cadastro/departamento/model/` | PARTE 4 (Diagrama Classes) |
| `Lotacao.java` | `cadastro/departamento/model/` | PARTE 4 (Diagrama Classes) |
| `Cargo.java`, `Nivel.java` | `cadastro/cargo/model/` | PARTE 9 (PCCS) |
| `OcupacaoCBO.java` | `cadastro/cargo/model/` | PARTE 9 (PCCS) |
| `VinculoFuncional.java` | `cadastro/vinculo/model/` | PARTE 4 (Diagrama Classes) |
| `VinculoFuncionalDet.java` | `cadastro/vinculo/model/` | PARTE 4 (Diagrama Classes) |
| `VantagemDesconto.java` | `folha/rubrica/model/` | PARTE 2 (Processamento) |
| `VantagemDescontoDet.java` | `folha/rubrica/model/` | PARTE 2 (Processamento) |
| `VinculoVantagemDesconto.java` | `folha/rubrica/model/` | PARTE 2 (Processamento) |
| `GrupoVantagemDesconto.java` | `folha/rubrica/model/` | PARTE 2 (Processamento) |
| `FolhaPagamento.java` | `folha/processamento/model/` | PARTE 2 (Processamento) |
| `FolhaPagamentoDet.java` | `folha/processamento/model/` | PARTE 2 (Processamento) |
| `Legislacao.java` | `core/config/model/` | PARTE 2 (Faixas INSS/IRRF) |
| `Esoc*` (5 entidades) | `obrigacoes/esocial/model/` | PARTE 8 (eSocial) |
| `Tce*` (15 entidades) | `obrigacoes/tce/model/` | - |
| `Banco.java` | `integracao/banco/model/` | PARTE 3 (Consignado) |

### 3.2 Controllers Existentes (controller/)

| Atual | Novo Local | Documentação Relacionada |
|-------|------------|--------------------------|
| `ServidorController.java` | `cadastro/servidor/` | PARTE 4 |
| `DependenteController.java` | `cadastro/dependente/` | PARTE 4 |
| `DepartamentoRHController.java` | `cadastro/departamento/` | PARTE 4 |
| `CargoController.java`, `NivelController.java` | `cadastro/cargo/` | PARTE 9 |
| `VinculoFuncionalController.java` | `cadastro/vinculo/` | PARTE 4 |
| `VantagemDescontoController.java` | `folha/rubrica/` | PARTE 2 |
| `ProcessamentoController.java` | `folha/processamento/` | PARTE 2 |
| `FolhaPagamentoController.java` | `folha/processamento/` | PARTE 2 |
| `Esoc*Controller.java` (5) | `obrigacoes/esocial/` | PARTE 8 |
| `Tce*Controller.java` (15) | `obrigacoes/tce/` | - |
| `ExportacaoController.java` | `obrigacoes/` | PARTE 8, 16, 17, 18 |
| `ImportacaoController.java` | `core/` | - |
| `RelatoriosController.java` | `apoio/relatorio/` | - |
| `DashboardController.java` | `apoio/dashboard/` | PARTE 26 |
| `CompetenciaController.java` | `folha/processamento/` | PARTE 2 |
| `BancoController.java` | `integracao/banco/` | PARTE 3 |

---

## 4. FLUXO DE PROCESSAMENTO - FOLHA DE PAGAMENTO

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     FLUXO: PROCESSAMENTO DE FOLHA                               │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ 1.BUSCA  │───►│ 2.CÁLCULO│───►│ 3.DEDUÇÃO│───►│4.PERSIST │───►│5.EXPORT  │
│ VÍNCULOS │    │ RUBRICAS │    │ IRRF/INSS│    │  FOLHA   │    │ TCE/eSoc │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘
     │               │               │               │               │
     ▼               ▼               ▼               ▼               ▼
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│ cadastro/│    │  folha/  │    │  folha/  │    │  folha/  │    │obrigacoes│
│  vinculo │    │  rubrica │    │processam.│    │processam.│    │ tce/esoc │
└──────────┘    └──────────┘    └──────────┘    └──────────┘    └──────────┘

ENTRADAS:
- Competência (mês/ano)
- Unidade Gestora
- Tipo de Folha (NORMAL, COMPLEMENTAR, FERIAS, 13o)

PROCESSAMENTO:
1. Busca vínculos ativos na competência
2. Para cada vínculo:
   a. Carrega rubricas fixas (VinculoVantagemDesconto)
   b. Carrega rubricas variáveis (lançamentos)
   c. Executa fórmulas de cálculo
   d. Calcula base INSS/IRRF/RPPS
   e. Aplica deduções legais
3. Gera FolhaPagamento + FolhaPagamentoDet
4. Fecha competência (se solicitado)

SAÍDAS:
- Folha calculada
- Holerites individuais
- Arquivos TCE/eSocial
```

---

## 5. ESTRUTURA INTERNA DE CADA MÓDULO

### 5.1 Padrão de Estrutura

```
cadastro/servidor/
├── model/
│   ├── Servidor.java              # Entidade JPA
│   └── enums/                     # Enums do domínio
├── repository/
│   └── ServidorRepository.java    # Interface JPA
├── service/
│   ├── ServidorService.java       # Interface
│   └── ServidorServiceImpl.java   # Implementação
├── dto/
│   ├── request/
│   │   └── ServidorRequest.java
│   └── response/
│       └── ServidorResponse.java
├── mapper/
│   └── ServidorMapper.java        # Entity ↔ DTO
└── controller/
    └── ServidorController.java    # API REST
```

### 5.2 Exemplo: Módulo Servidor (PARTE 2)

```java
// cadastro/servidor/model/Servidor.java
@Entity
@Table(name = "servidor")
@Filter(name = "tenantFilter")
public class Servidor extends AbstractTenantEntity {
    private Long id;
    private String nome;
    private String cpf;
    private LocalDate dataNascimento;
    // ... demais campos
}

// cadastro/servidor/service/ServidorService.java
public interface ServidorService {
    ServidorResponse criar(ServidorRequest request);
    ServidorResponse atualizar(Long id, ServidorRequest request);
    ServidorResponse buscarPorId(Long id);
    Page<ServidorResponse> listar(Predicate predicate, Pageable pageable);
    void excluir(Long id);
}

// cadastro/servidor/controller/ServidorController.java
@RestController
@RequestMapping("/api/v1/servidores")
public class ServidorController {
    @GetMapping
    @PostMapping
    @PutMapping("/{id}")
    @DeleteMapping("/{id}")
}
```

---

## 6. ORDEM DE PRIORIDADE E SEQUÊNCIA DE DESENVOLVIMENTO

### 6.1 Critérios de Priorização

| Critério | Peso | Descrição |
|----------|------|-----------|
| **Dependência** | 40% | Módulos base DEVEM ser implementados antes dos dependentes |
| **Valor Operacional** | 30% | Impacto direto na operação diária do RH |
| **Complexidade** | 20% | Módulos simples primeiro para validar arquitetura |
| **Risco** | 10% | Funcionalidades críticas que precisam de mais testes |

### 6.2 Matriz de Prioridade Detalhada

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    MATRIZ DE PRIORIDADE POR MÓDULO                              │
└─────────────────────────────────────────────────────────────────────────────────┘

PRIORIDADE 0 - BLOQUEANTE (pré-requisito para todos)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo          │ Motivo                              │ Dependências │ Status   │
├─────────────────┼─────────────────────────────────────┼──────────────┼──────────┤
│ core/config     │ Configurações Spring Boot           │ common       │ EXISTENTE│
│ core/filter     │ HibernateFilterAspect (tenant)      │ common       │ EXISTENTE│
│ core/exception  │ GlobalExceptionHandler              │ -            │ A FAZER  │
│ core/audit      │ Auditoria (PARTE 24)                │ core/config  │ A FAZER  │
└─────────────────┴─────────────────────────────────────┴──────────────┴──────────┘

PRIORIDADE 1 - CRÍTICA (base de dados mestre)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo                │ Motivo                         │ Dependências │ Status   │
├───────────────────────┼────────────────────────────────┼──────────────┼──────────┤
│ cadastro/servidor     │ Entidade central do sistema    │ core         │ EXISTENTE│
│ cadastro/dependente   │ Dependentes para cálculos      │ servidor     │ EXISTENTE│
│ cadastro/departamento │ Estrutura organizacional       │ core         │ EXISTENTE│
│ cadastro/cargo        │ Cargos/Níveis para vínculo     │ core         │ EXISTENTE│
│ cadastro/vinculo      │ Relação servidor-cargo-lotação │ servidor,    │ EXISTENTE│
│                       │                                │ cargo, depto │          │
└───────────────────────┴────────────────────────────────┴──────────────┴──────────┘

PRIORIDADE 2 - ALTA (operação diária de folha)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo                │ Motivo                         │ Dependências │ Status   │
├───────────────────────┼────────────────────────────────┼──────────────┼──────────┤
│ folha/rubrica         │ Vantagens/Descontos            │ vinculo      │ EXISTENTE│
│ folha/processamento   │ Motor de cálculo (PARTE 2)     │ rubrica      │ EXISTENTE│
│ folha/decimoterceiro  │ 13º salário                    │ processamento│ A FAZER  │
│ folha/rescisao        │ Verbas rescisórias (PARTE 7)   │ processamento│ A FAZER  │
└───────────────────────┴────────────────────────────────┴──────────────┴──────────┘

PRIORIDADE 3 - MÉDIA-ALTA (obrigações legais com prazo)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo                │ Motivo                         │ Dependências │ Status   │
├───────────────────────┼────────────────────────────────┼──────────────┼──────────┤
│ obrigacoes/tce        │ TCE/SAGRES (obrigatório mensal)│ processamento│ EXISTENTE│
│ obrigacoes/esocial    │ eSocial (PARTE 8)              │ processamento│ PARCIAL  │
│ obrigacoes/dirf       │ DIRF (PARTE 16) - anual        │ processamento│ A FAZER  │
│ obrigacoes/rais       │ RAIS (PARTE 17) - anual        │ processamento│ A FAZER  │
│ obrigacoes/sefip      │ SEFIP (PARTE 18) - mensal      │ processamento│ A FAZER  │
└───────────────────────┴────────────────────────────────┴──────────────┴──────────┘

PRIORIDADE 4 - MÉDIA (gestão de tempo e afastamentos)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo                │ Motivo                         │ Dependências │ Status   │
├───────────────────────┼────────────────────────────────┼──────────────┼──────────┤
│ temporal/ferias       │ Impacto na folha               │ vinculo,     │ A FAZER  │
│                       │                                │ processamento│          │
│ temporal/afastamento  │ Licenças (PARTE 6)             │ vinculo      │ A FAZER  │
│ temporal/ponto        │ Frequência (PARTE 12)          │ vinculo      │ A FAZER  │
│ temporal/sst          │ Saúde Ocupacional (PARTE 15)   │ vinculo      │ A FAZER  │
└───────────────────────┴────────────────────────────────┴──────────────┴──────────┘

PRIORIDADE 5 - MÉDIA-BAIXA (evolução funcional)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo                │ Motivo                         │ Dependências │ Status   │
├───────────────────────┼────────────────────────────────┼──────────────┼──────────┤
│ carreira/progressao   │ Afeta salário (PARTE 9)        │ cargo, folha │ A FAZER  │
│ carreira/avaliacao    │ Desempenho (PARTE 14)          │ servidor     │ A FAZER  │
│ carreira/concurso     │ Concursos (PARTE 13)           │ cargo        │ A FAZER  │
│ carreira/capacitacao  │ Treinamentos (PARTE 20)        │ servidor     │ A FAZER  │
│ carreira/aposentadoria│ Aposentadoria (PARTE 10)       │ vinculo,     │ A FAZER  │
│                       │                                │ processamento│          │
│ carreira/cessao       │ Cessão/Requisição (PARTE 21)   │ vinculo      │ A FAZER  │
└───────────────────────┴────────────────────────────────┴──────────────┴──────────┘

PRIORIDADE 6 - BAIXA (apoio e complementares)
═══════════════════════════════════════════════════════════════════════════════════
│ Módulo                │ Motivo                         │ Dependências │ Status   │
├───────────────────────┼────────────────────────────────┼──────────────┼──────────┤
│ cadastro/beneficio    │ VA/VT/Auxílios (PARTE 19)      │ servidor     │ A FAZER  │
│ cadastro/recadastram. │ Prova de Vida (PARTE 22)       │ servidor     │ A FAZER  │
│ folha/consignado      │ Empréstimos (PARTE 3)          │ processamento│ A FAZER  │
│ apoio/relatorio       │ Jasper Reports                 │ todos        │ A FAZER  │
│ apoio/dashboard       │ Indicadores (PARTE 26)         │ todos        │ A FAZER  │
│ apoio/notificacao     │ Alertas (PARTE 25)             │ core         │ A FAZER  │
│ apoio/simulacao       │ Simulações de folha            │ processamento│ A FAZER  │
│ apoio/documento       │ GED (PARTE 23)                 │ servidor     │ A FAZER  │
│ apoio/portal          │ Portal Servidor (PARTE 11)     │ todos        │ A FAZER  │
│ apoio/pad             │ PAD (PARTE 27)                 │ servidor     │ A FAZER  │
└───────────────────────┴────────────────────────────────┴──────────────┴──────────┘
```

### 6.3 Sequência de Desenvolvimento (Sprints)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│              SEQUÊNCIA DETALHADA DE DESENVOLVIMENTO - 16 SEMANAS                │
└─────────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 1: FUNDAÇÃO (Semanas 1-2) - PRIORIDADE 0
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 1.1 (Semana 1)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► core/exception/GlobalExceptionHandler.java                                │
 │   - Criar tratamento padronizado de erros                                   │
 │   - ErrorResponse DTO padronizado                                           │
 │   - Mapear exceções → HTTP status codes                                     │
 │                                                                             │
 │ ► core/audit/ (PARTE 24)                                                    │
 │   - AuditLog entity                                                         │
 │   - AuditListener (Hibernate EntityListener)                                │
 │   - Integrar com TenantContext do common                                    │
 │                                                                             │
 │ ENTREGÁVEL: Infraestrutura de erros + auditoria funcionando                 │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 1.2 (Semana 2)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► Eliminar reflexão em AbstractTenantService                                │
 │   - Criar interface TenantAware                                             │
 │   - Entidades implementam TenantAware                                       │
 │   - Remover Method.invoke()                                                 │
 │                                                                             │
 │ ► Padronizar estrutura de DTOs                                              │
 │   - Criar padrão dto/request/ e dto/response/                               │
 │   - Adicionar @Valid em todos os requests                                   │
 │                                                                             │
 │ ENTREGÁVEL: Base técnica limpa para refatoração                             │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 2: CADASTROS BASE (Semanas 3-4) - PRIORIDADE 1
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 2.1 (Semana 3)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► cadastro/servidor/ (reorganizar existente)                                │
 │   - Mover Servidor.java, Funcionario.java para model/                       │
 │   - Criar ServidorRequest, ServidorResponse DTOs                            │
 │   - Criar ServidorMapper (MapStruct)                                        │
 │   - Refatorar ServidorService → interface + impl                            │
 │                                                                             │
 │ ► cadastro/dependente/ (reorganizar existente)                              │
 │   - Mover Dependente.java para model/                                       │
 │   - Criar DTOs e Mapper                                                     │
 │                                                                             │
 │ ENTREGÁVEL: Módulos servidor e dependente na nova estrutura                 │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 2.2 (Semana 4)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► cadastro/departamento/ (reorganizar existente)                            │
 │   - Mover DepartamentoRH.java, Lotacao.java para model/                     │
 │   - Criar DTOs e Mapper                                                     │
 │                                                                             │
 │ ► cadastro/cargo/ (reorganizar existente)                                   │
 │   - Mover Cargo.java, Nivel.java, OcupacaoCBO.java para model/              │
 │   - Criar DTOs e Mapper                                                     │
 │                                                                             │
 │ ► cadastro/vinculo/ (reorganizar existente)                                 │
 │   - Mover VinculoFuncional*.java para model/                                │
 │   - Criar DTOs e Mapper                                                     │
 │                                                                             │
 │ ENTREGÁVEL: Todos os cadastros base na nova estrutura                       │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 3: FOLHA DE PAGAMENTO (Semanas 5-7) - PRIORIDADE 2
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 3.1 (Semana 5)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► folha/rubrica/ (reorganizar existente)                                    │
 │   - Mover VantagemDesconto*.java, GrupoVantagemDesconto.java                │
 │   - Mover VinculoVantagemDesconto.java                                      │
 │   - Criar DTOs e Mapper                                                     │
 │   - Extrair RubricaFacade de Facade.java                                    │
 │                                                                             │
 │ ENTREGÁVEL: Gestão de rubricas independente                                 │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 3.2 (Semana 6)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► folha/processamento/ (reorganizar + refatorar)                            │
 │   - Mover FolhaPagamento*.java para model/                                  │
 │   - Mover Legislacao.java para core/config/model/                           │
 │   - Extrair FolhaFacade de Facade.java                                      │
 │   - Refatorar motor de cálculo (ProcessamentoFolhaService)                  │
 │                                                                             │
 │ ENTREGÁVEL: Processamento de folha modularizado                             │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 3.3 (Semana 7)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► folha/decimoterceiro/ (NOVO)                                              │
 │   - Criar serviço de cálculo de 13º                                         │
 │   - Integrar com processamento                                              │
 │                                                                             │
 │ ► folha/rescisao/ (NOVO - PARTE 7)                                          │
 │   - Criar entidade Desligamento                                             │
 │   - Criar serviço de cálculo de rescisão                                    │
 │                                                                             │
 │ ► ELIMINAR Facade.java (1382 linhas)                                        │
 │   - Quebrar em facades especializados                                       │
 │   - Validar que nenhum controller usa Facade diretamente                    │
 │                                                                             │
 │ ENTREGÁVEL: Folha completa + Facade eliminado                               │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 4: OBRIGAÇÕES LEGAIS (Semanas 8-9) - PRIORIDADE 3
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 4.1 (Semana 8)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► obrigacoes/tce/ (reorganizar existente)                                   │
 │   - Mover 15 entidades Tce*.java para model/                                │
 │   - Consolidar controllers em TceController.java                            │
 │   - Criar serviço de geração de arquivos                                    │
 │                                                                             │
 │ ► obrigacoes/esocial/ (reorganizar + expandir - PARTE 8)                    │
 │   - Mover 5 entidades Esoc*.java para model/                                │
 │   - Implementar geração de eventos S-1200, S-1210                           │
 │                                                                             │
 │ ENTREGÁVEL: Exportação TCE e eSocial funcionando                            │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 4.2 (Semana 9)                                                       │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► obrigacoes/dirf/ (NOVO - PARTE 16)                                        │
 │   - Criar entidade DIRF                                                     │
 │   - Criar geração de Informe de Rendimentos                                 │
 │                                                                             │
 │ ► obrigacoes/rais/ (NOVO - PARTE 17)                                        │
 │   - Criar entidade RAIS                                                     │
 │   - Criar geração de arquivo RAIS                                           │
 │                                                                             │
 │ ► obrigacoes/sefip/ (NOVO - PARTE 18)                                       │
 │   - Criar entidade SEFIP                                                    │
 │   - Criar geração de arquivo GFIP                                           │
 │                                                                             │
 │ ENTREGÁVEL: Todas as obrigações federais implementadas                      │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 5: GESTÃO TEMPORAL (Semanas 10-11) - PRIORIDADE 4
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 5.1 (Semana 10)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► temporal/ferias/ (NOVO)                                                   │
 │   - Criar entidades Ferias, PeriodoAquisitivo                               │
 │   - Criar serviço de programação de férias                                  │
 │   - Integrar com folha/processamento                                        │
 │                                                                             │
 │ ► temporal/afastamento/ (NOVO - PARTE 6)                                    │
 │   - Criar entidade Afastamento                                              │
 │   - Implementar tipos de licença                                            │
 │   - Integrar com folha/processamento                                        │
 │                                                                             │
 │ ENTREGÁVEL: Férias e afastamentos com impacto em folha                      │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 5.2 (Semana 11)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► temporal/ponto/ (NOVO - PARTE 12)                                         │
 │   - Criar entidades EscalaTrabalho, RegistroPonto                           │
 │   - Criar serviço de tratamento de ponto                                    │
 │   - Preparar integração com REP (futura)                                    │
 │                                                                             │
 │ ► temporal/sst/ (NOVO - PARTE 15)                                           │
 │   - Criar entidades ExameOcupacional, ASO                                   │
 │   - Criar serviço de controle de exames                                     │
 │                                                                             │
 │ ENTREGÁVEL: Gestão temporal completa                                        │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 6: CARREIRA (Semanas 12-13) - PRIORIDADE 5
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 6.1 (Semana 12)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► carreira/progressao/ (NOVO - PARTE 9)                                     │
 │   - Criar entidades Carreira, Progressao                                    │
 │   - Implementar progressão horizontal/vertical                              │
 │   - Integrar com cargo/nivel                                                │
 │                                                                             │
 │ ► carreira/avaliacao/ (NOVO - PARTE 14)                                     │
 │   - Criar entidades CicloAvaliacao, Avaliacao                               │
 │   - Implementar avaliação de desempenho                                     │
 │   - Implementar estágio probatório                                          │
 │                                                                             │
 │ ENTREGÁVEL: Sistema de progressão e avaliação                               │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 6.2 (Semana 13)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► carreira/concurso/ (NOVO - PARTE 13)                                      │
 │   - Criar entidades Concurso, VagaConcurso, Candidato                       │
 │   - Criar serviço de gestão de concursos                                    │
 │                                                                             │
 │ ► carreira/aposentadoria/ (NOVO - PARTE 10)                                 │
 │   - Criar entidades Aposentadoria, Pensao                                   │
 │   - Implementar regras EC 103/2019                                          │
 │                                                                             │
 │ ► carreira/capacitacao/ (NOVO - PARTE 20)                                   │
 │   - Criar entidades ProgramaCapacitacao, Curso                              │
 │                                                                             │
 │ ► carreira/cessao/ (NOVO - PARTE 21)                                        │
 │   - Criar entidade Cessao                                                   │
 │                                                                             │
 │ ENTREGÁVEL: Gestão de carreira completa                                     │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 7: APOIO E COMPLEMENTARES (Semanas 14-15) - PRIORIDADE 6
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 7.1 (Semana 14)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► cadastro/beneficio/ (NOVO - PARTE 19)                                     │
 │   - Criar entidades TipoBeneficio, BeneficioServidor                        │
 │   - Integrar com folha/processamento                                        │
 │                                                                             │
 │ ► folha/consignado/ (NOVO - PARTE 3)                                        │
 │   - Criar entidades ConvenioConsignataria, Emprestimo                       │
 │   - Criar serviço de margem consignável                                     │
 │   - Integrar com folha/processamento                                        │
 │                                                                             │
 │ ► apoio/relatorio/                                                          │
 │   - Organizar relatórios Jasper existentes                                  │
 │   - Criar serviço de geração de relatórios                                  │
 │                                                                             │
 │ ENTREGÁVEL: Benefícios, consignado e relatórios                             │
 └─────────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 7.2 (Semana 15)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► apoio/dashboard/ (NOVO - PARTE 26)                                        │
 │   - Criar endpoints de indicadores                                          │
 │   - Criar serviço de agregação de dados                                     │
 │                                                                             │
 │ ► apoio/notificacao/ (NOVO - PARTE 25)                                      │
 │   - Criar entidade Notificacao                                              │
 │   - Criar serviço de envio (email, sistema)                                 │
 │                                                                             │
 │ ► apoio/documento/ (NOVO - PARTE 23)                                        │
 │   - Criar entidade Documento                                                │
 │   - Criar serviço de upload/storage                                         │
 │                                                                             │
 │ ► apoio/simulacao/                                                          │
 │   - Criar serviço de simulação de folha                                     │
 │                                                                             │
 │ ► cadastro/recadastramento/ (NOVO - PARTE 22)                               │
 │   - Criar entidades CampanhaRecadastramento                                 │
 │                                                                             │
 │ ► apoio/portal/ (NOVO - PARTE 11)                                           │
 │   - Criar endpoints de autoatendimento                                      │
 │                                                                             │
 │ ► apoio/pad/ (NOVO - PARTE 27)                                              │
 │   - Criar entidades ProcessoAdministrativo                                  │
 │                                                                             │
 │ ENTREGÁVEL: Todos os módulos de apoio                                       │
 └─────────────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════════════
 FASE 8: VALIDAÇÃO E FINALIZAÇÃO (Semana 16)
══════════════════════════════════════════════════════════════════════════════════

 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ SPRINT 8.1 (Semana 16)                                                      │
 ├─────────────────────────────────────────────────────────────────────────────┤
 │ ► Testes de integração entre módulos                                        │
 │   - Testar fluxo completo de processamento de folha                         │
 │   - Testar exportação TCE/eSocial                                           │
 │   - Testar impacto de férias/afastamentos na folha                          │
 │                                                                             │
 │ ► Validação de fluxos E2E                                                   │
 │   - Validar com dados reais de produção (anonimizados)                      │
 │   - Comparar resultados antes/depois da refatoração                         │
 │                                                                             │
 │ ► Documentação                                                              │
 │   - Atualizar OpenAPI/Swagger                                               │
 │   - Documentar breaking changes                                             │
 │   - Criar guia de migração                                                  │
 │                                                                             │
 │ ENTREGÁVEL: Sistema validado e documentado                                  │
 └─────────────────────────────────────────────────────────────────────────────┘
```

### 6.4 Diagrama de Dependências para Sequenciamento

```
                                    SEQUÊNCIA DE IMPLEMENTAÇÃO
═══════════════════════════════════════════════════════════════════════════════════

Semana:  1    2    3    4    5    6    7    8    9   10   11   12   13   14   15   16
         │    │    │    │    │    │    │    │    │    │    │    │    │    │    │    │
         ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼
         
    ┌─────────┐
    │  CORE   │ ◄─── PRIORIDADE 0 (bloqueante)
    └────┬────┘
         │
         ├────────────────────────┐
         ▼                        ▼
    ┌─────────┐             ┌─────────┐
    │CADASTRO │             │CADASTRO │ ◄─── PRIORIDADE 1
    │servidor │             │cargo    │
    └────┬────┘             └────┬────┘
         │                       │
         └───────────┬───────────┘
                     ▼
              ┌─────────────┐
              │  CADASTRO   │
              │  vinculo    │
              └──────┬──────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
    ┌─────────┐             ┌─────────┐
    │  FOLHA  │             │  FOLHA  │ ◄─── PRIORIDADE 2
    │ rubrica │             │processam│
    └────┬────┘             └────┬────┘
         │                       │
         └───────────┬───────────┘
                     │
    ┌────────────────┼────────────────┐
    ▼                ▼                ▼
┌───────┐      ┌─────────┐      ┌─────────┐
│  TCE  │      │ eSocial │      │  DIRF   │ ◄─── PRIORIDADE 3
└───────┘      └─────────┘      │RAIS/SEF │
                                └─────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
    ┌─────────┐             ┌─────────┐
    │ FÉRIAS  │             │ PONTO   │ ◄─── PRIORIDADE 4
    │AFASTAM. │             │  SST    │
    └────┬────┘             └─────────┘
         │
         ▼
    ┌─────────────┐
    │  CARREIRA   │ ◄─── PRIORIDADE 5
    │progressão   │
    │avaliação    │
    │concurso     │
    │aposentadoria│
    └──────┬──────┘
           │
           ▼
    ┌─────────────┐
    │   APOIO     │ ◄─── PRIORIDADE 6
    │consignado   │
    │dashboard    │
    │portal       │
    │PAD          │
    └─────────────┘
```

---

## 7. PROBLEMAS ATUAIS E SOLUÇÕES

### 7.1 Problemas Identificados

| # | Problema | Arquivo | Impacto |
|---|----------|---------|---------|
| 1 | **God Class** | `Facade.java` (1382 linhas) | Manutenibilidade crítica |
| 2 | **Reflexão** | `AbstractTenantService.java` | Performance e debug |
| 3 | **DTOs inconsistentes** | `controller/dto/` | Difícil manutenção |
| 4 | **Sem validação** | Request DTOs | Dados inválidos |
| 5 | **Sem exception handler** | Controllers | Respostas inconsistentes |

### 7.2 Soluções Propostas

**P1: Quebrar Facade.java**
```
Facade.java (1382 linhas) → 
├── ServidorFacade.java
├── VinculoFuncionalFacade.java
├── FolhaPagamentoFacade.java
├── DependenteFacade.java
├── RubricaFacade.java
└── RelatorioFacade.java
```

**P2: Eliminar Reflexão**
```java
// ANTES (AbstractTenantService.java)
entity.getClass().getMethod("setUnidadeGestora"...).invoke(...)

// DEPOIS (usando interface)
public interface TenantAware {
    void setUnidadeGestoraId(Long id);
    void setUsuarioId(Long id);
}
// Entity implementa TenantAware
entity.setUnidadeGestoraId(ugId);
```

**P3: Padronizar DTOs**
```
Cada módulo terá:
├── dto/request/   # Entrada (com @Valid)
└── dto/response/  # Saída (imutável)
```

**P4: Adicionar Validação**
```java
public class ServidorRequest {
    @NotBlank @Size(max = 200) String nome;
    @NotBlank @CPF String cpf;
    @NotNull @Past LocalDate dataNascimento;
}
```

**P5: GlobalExceptionHandler**
```java
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(EntityNotFoundException.class) → 404
    @ExceptionHandler(BusinessException.class) → 422
    @ExceptionHandler(MethodArgumentNotValidException.class) → 400
}
```

---

## 8. INTEGRAÇÕES ENTRE MÓDULOS

### 8.1 Diagrama de Comunicação

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                       COMUNICAÇÃO ENTRE MÓDULOS                                 │
└─────────────────────────────────────────────────────────────────────────────────┘

                    LEITURA (consulta)          ESCRITA (altera)
                    ─────────────────          ────────────────

    cadastro.servidor ◄──────────────── folha.processamento
         │                                      │
         │                                      │
         ▼                                      ▼
    cadastro.vinculo ◄──────────────── folha.rubrica
         │                                      │
         │                                      │
         ▼                                      ▼
    obrigacoes.tce ◄───────────────── folha.processamento
         │
         │
         ▼
    obrigacoes.esocial


REGRAS:
1. Módulos de nível inferior NÃO importam módulos de nível superior
2. Comunicação entre módulos via interfaces (não implementações)
3. Módulo folha é o "hub" central que usa dados de todos os cadastros
```

### 8.2 Interfaces de Comunicação

```java
// cadastro/servidor/service/ServidorService.java
// Interface pública usada por outros módulos
public interface ServidorService {
    Servidor findById(Long id);
    List<Servidor> findAllAtivos(Long unidadeGestoraId);
}

// folha/processamento/service/ProcessamentoService.java
// Injeta a interface, não a implementação
@Service
public class ProcessamentoServiceImpl {
    private final ServidorService servidorService;
    private final VinculoService vinculoService;
    private final RubricaService rubricaService;
}
```

---

## 9. CHECKLIST DE MIGRAÇÃO POR MÓDULO

> **Nota:** Os checklists abaixo indicam as PARTEs da documentação técnica **relacionadas** a cada módulo,
> não uma correspondência 1:1 (já que as PARTEs documentam aspectos transversais).

### ☐ CORE (PARTEs 1, 24)
- [ ] Mover `config/` para `core/config/`
- [ ] Mover `HibernateFilterAspect.java` para `core/filter/`
- [ ] Criar `core/exception/GlobalExceptionHandler.java`
- [ ] Implementar `core/audit/` (PARTE 24: Auditoria e Logs)
- [ ] ~~Criar tenant~~ (Já existe no common - apenas consumir)

### ☐ CADASTRO/SERVIDOR (PARTE 4 - Diagrama Classes)
- [ ] Mover `Servidor.java` para `cadastro/servidor/model/`
- [ ] Mover `Funcionario.java` para `cadastro/servidor/model/`
- [ ] Criar `ServidorRequest.java` com validações
- [ ] Criar `ServidorResponse.java`
- [ ] Criar `ServidorMapper.java`
- [ ] Refatorar `ServidorService.java`
- [ ] Mover `ServidorController.java`

### ☐ CADASTRO/DEPENDENTE (PARTE 4 - Diagrama Classes)
- [ ] Mover `Dependente.java` para `cadastro/dependente/model/`
- [ ] Criar DTOs e Mapper
- [ ] Refatorar Service e Controller

### ☐ CADASTRO/DEPARTAMENTO (PARTE 4 - Diagrama Classes)
- [ ] Mover `DepartamentoRH.java` e `Lotacao.java`
- [ ] Criar DTOs e Mapper
- [ ] Refatorar Service e Controller

### ☐ CADASTRO/CARGO (PARTE 9 - PCCS)
- [ ] Mover `Cargo.java`, `Nivel.java`, `OcupacaoCBO.java`
- [ ] Criar DTOs e Mapper
- [ ] Refatorar Service e Controller

### ☐ CADASTRO/VINCULO (PARTE 4 - Diagrama Classes)
- [ ] Mover `VinculoFuncional.java` e `VinculoFuncionalDet.java`
- [ ] Criar DTOs e Mapper
- [ ] Refatorar Service e Controller

### ☐ CADASTRO/BENEFICIO (PARTE 19 - Benefícios)
- [ ] Criar entidades para VA/VT/Auxílios
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CADASTRO/RECADASTRAMENTO (PARTE 22 - Prova de Vida)
- [ ] Criar entidades de recadastramento
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ FOLHA/RUBRICA (PARTE 2 - Processamento)
- [ ] Mover `VantagemDesconto*.java` e `VinculoVantagemDesconto.java`
- [ ] Criar DTOs e Mapper
- [ ] Criar `RubricaFacade.java` (extrair de Facade)

### ☐ FOLHA/PROCESSAMENTO (PARTE 2 - Processamento)
- [ ] Mover `FolhaPagamento*.java`
- [ ] Criar `FolhaFacade.java` (extrair de Facade)
- [ ] Manter motor de cálculo (ProcessamentoFolhaService)

### ☐ FOLHA/CONSIGNADO (PARTE 3 - Consignado)
- [ ] Criar entidades de consignado (ConvenioConsignataria, etc.)
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ FOLHA/RESCISAO (PARTE 7 - Rescisões)
- [ ] Criar entidades de desligamento
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ OBRIGAÇÕES/ESOCIAL (PARTE 8)
- [ ] Mover 5 entidades `Esoc*.java`
- [ ] Mover 5 controllers `Esoc*Controller.java`
- [ ] Implementar geração de eventos S-1200, S-1210, etc.

### ☐ OBRIGAÇÕES/TCE
- [ ] Mover 15 entidades `Tce*.java`
- [ ] Mover 15 controllers `Tce*Controller.java`
- [ ] Consolidar serviços

### ☐ OBRIGAÇÕES/DIRF (PARTE 16)
- [ ] Criar entidades DIRF
- [ ] Criar geração de informe de rendimentos

### ☐ OBRIGAÇÕES/RAIS (PARTE 17)
- [ ] Criar entidades RAIS
- [ ] Criar geração de arquivo RAIS

### ☐ OBRIGAÇÕES/SEFIP (PARTE 18)
- [ ] Criar entidades SEFIP
- [ ] Criar geração de arquivo GFIP

### ☐ TEMPORAL/AFASTAMENTO (PARTE 6 - Licenças)
- [ ] Criar entidades de afastamento
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ TEMPORAL/PONTO (PARTE 12 - Frequência)
- [ ] Criar entidades de ponto/frequência
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ TEMPORAL/SST (PARTE 15 - Saúde Ocupacional)
- [ ] Criar entidades ASO/PCMSO
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CARREIRA/CONCURSO (PARTE 13)
- [ ] Criar entidades de concurso
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CARREIRA/AVALIACAO (PARTE 14)
- [ ] Criar entidades de avaliação de desempenho
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CARREIRA/PROGRESSAO (PARTE 9 - PCCS)
- [ ] Criar entidades de progressão
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CARREIRA/APOSENTADORIA (PARTE 10)
- [ ] Criar entidades de aposentadoria
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CARREIRA/CAPACITACAO (PARTE 20)
- [ ] Criar entidades de capacitação
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ CARREIRA/CESSAO (PARTE 21)
- [ ] Criar entidades de cessão/requisição
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ APOIO/PORTAL (PARTE 11 - Portal do Servidor)
- [ ] Criar endpoints de autoatendimento
- [ ] Integrar com autenticação

### ☐ APOIO/DOCUMENTO (PARTE 23 - GED)
- [ ] Criar entidades de documento
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ APOIO/NOTIFICACAO (PARTE 25)
- [ ] Criar entidades de notificação
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ APOIO/DASHBOARD (PARTE 26)
- [ ] Criar entidades de dashboard
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

### ☐ APOIO/PAD (PARTE 27A/B)
- [ ] Criar entidades de processo administrativo
- [ ] Criar DTOs e Mapper
- [ ] Criar Service e Controller

---

## 10. MÉTRICAS DE SUCESSO

| Métrica | Antes | Depois | Meta |
|---------|-------|--------|------|
| Linhas do Facade.java | 1382 | < 100 | Eliminar |
| Uso de Reflexão | Sim | Não | Zero |
| % DTOs com validação | ~10% | 100% | 100% |
| Cobertura de testes | ~5% | > 60% | 80% |
| Módulos organizados | 0 | 8 | 8 |

---

**Documento:** PLANO-REFATORACAO-ERH-SERVICE.md  
**Versão:** 2.1  
**Última atualização:** 09 de Janeiro de 2026  
**Changelog:**
- v2.1: Adicionada ordem de prioridade detalhada (seção 6)
- v2.0: Corrigido mapeamento das PARTEs da documentação técnica
