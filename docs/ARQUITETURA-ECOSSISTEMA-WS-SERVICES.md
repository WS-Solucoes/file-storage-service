# 🏛️ Arquitetura do Ecossistema WS-Services

## Plataforma de Gestão Pública Municipal

---

## 📋 Sumário

1. [Visão Geral do Ecossistema](#1-visão-geral-do-ecossistema)
2. [Serviços da Plataforma](#2-serviços-da-plataforma)
3. [Arquitetura Técnica](#3-arquitetura-técnica)
4. [Módulo Common (Compartilhado)](#4-módulo-common-compartilhado)
5. [eRH-Service - Recursos Humanos](#5-erh-service---recursos-humanos)
6. [eFrotas - Gestão de Frotas](#6-efrotas---gestão-de-frotas)
7. [Serviços Planejados](#7-serviços-planejados)
8. [Frontend Unificado](#8-frontend-unificado)
9. [Infraestrutura](#9-infraestrutura)
10. [Roadmap de Implementação](#10-roadmap-de-implementação)

---

## 1. Visão Geral do Ecossistema

### 1.1 Propósito

O **WS-Services** é uma plataforma integrada de sistemas para **gestão pública municipal**, projetada para atender múltiplas secretarias e departamentos de prefeituras e órgãos públicos.

### 1.2 Conceito Central

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        WS-SERVICES - ECOSSISTEMA                            │
│                    Plataforma de Gestão Pública Municipal                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │             │  │             │  │             │  │             │        │
│  │   e-RH      │  │  e-Frotas   │  │ Patrimônio  │  │Contabilidade│        │
│  │  (ATIVO)    │  │  (ATIVO)    │  │ (PLANEJADO) │  │ (PLANEJADO) │        │
│  │             │  │             │  │             │  │             │        │
│  │ Recursos    │  │ Gestão de   │  │ Controle de │  │ Gestão      │        │
│  │ Humanos     │  │ Frotas      │  │ Bens        │  │ Contábil    │        │
│  │             │  │             │  │             │  │             │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
│         │                │                │                │               │
│         └────────────────┴────────────────┴────────────────┘               │
│                                   │                                        │
│                          ┌────────┴────────┐                               │
│                          │     COMMON      │                               │
│                          │  (Módulo Base)  │                               │
│                          │                 │                               │
│                          │ • Autenticação  │                               │
│                          │ • Multi-tenant  │                               │
│                          │ • Unid. Gestora │                               │
│                          │ • Usuários      │                               │
│                          │ • Logs          │                               │
│                          └─────────────────┘                               │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                          FRONTEND UNIFICADO                                 │
│                        (frontend-services)                                  │
│                                                                             │
│                    Portal único para todos os serviços                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 Princípios Arquiteturais

| Princípio | Descrição |
|-----------|-----------|
| **Multi-tenant** | Cada município/órgão é um tenant isolado com dados segregados |
| **Multi-ente** | Suporte a múltiplas Unidades Gestoras por tenant |
| **Microserviços** | Serviços independentes com responsabilidades bem definidas |
| **API First** | Backend expõe APIs REST consumidas pelo frontend |
| **Módulo Comum** | Funcionalidades compartilhadas centralizadas no `common` |
| **Conformidade** | Integração com TCE (Tribunal de Contas) e eSocial |

---

## 2. Serviços da Plataforma

### 2.1 Matriz de Serviços

| Serviço | Status | Descrição | Secretaria |
|---------|--------|-----------|------------|
| **eRH-Service** | ✅ Em Desenvolvimento | Gestão de Recursos Humanos | Administração |
| **eFrotas** | ✅ Estrutura Criada | Gestão de Frotas e Veículos | Transporte |
| **Patrimônio** | 📋 Planejado | Controle de Bens Patrimoniais | Administração |
| **Contabilidade** | 📋 Planejado | Gestão Contábil e Financeira | Fazenda |
| **Licitações** | 📋 Futuro | Gestão de Compras e Contratos | Compras |
| **Protocolo** | 📋 Futuro | Gestão de Documentos | Administração |

### 2.2 Estrutura do Monorepo

```
WS-Services/
├── pom.xml                      # POM pai do projeto
│
├── common/                      # 🔧 Módulo compartilhado
│   ├── pom.xml
│   └── src/main/java/ws/common/
│       ├── auth/                # Autenticação JWT
│       ├── config/              # Configurações base
│       ├── controller/          # Controllers base
│       ├── model/               # Entidades compartilhadas
│       ├── repository/          # Repositórios base
│       └── service/             # Serviços base
│
├── eRH-Service/                 # 👥 Recursos Humanos (FOCO ATUAL)
│   ├── pom.xml
│   └── src/main/java/ws/erh/
│       ├── config/
│       ├── controller/
│       ├── dto/
│       ├── model/
│       │   ├── execucao/        # Entidades de execução (servidor, folha)
│       │   ├── config/          # Classes base abstratas
│       │   └── (tabelas TCE/eSocial)
│       ├── repository/
│       ├── service/
│       └── facade/
│
├── eFrotas/                     # 🚗 Gestão de Frotas
│   ├── pom.xml
│   └── src/main/java/ws/efrotas/
│       ├── config/
│       ├── controller/
│       ├── model/
│       ├── repository/
│       └── service/
│
├── service-discovery/           # 🔍 Eureka Server
├── api-gateway/                 # 🚪 Gateway de API
│
├── frontend-services/           # 🖥️ Frontend Next.js Unificado
│   └── src/
│       ├── app/
│       │   └── (private)/
│       │       ├── e-RH/        # Interface do eRH
│       │       └── e-Frotas/    # Interface do eFrotas
│       ├── components/
│       ├── contexts/
│       └── hooks/
│
└── deploy/                      # 🐳 Configurações Docker
```

---

## 3. Arquitetura Técnica

### 3.1 Stack Tecnológico

#### Backend
| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| Java | 21 LTS | Linguagem principal |
| Spring Boot | 3.2.5 | Framework base |
| Spring Cloud | 2023.0.0 | Microserviços |
| Spring Security | 6.x | Autenticação/Autorização |
| Hibernate | 6.x | ORM com filtros multi-tenant |
| PostgreSQL | 15+ | Banco de dados |

#### Frontend
| Tecnologia | Versão | Propósito |
|------------|--------|-----------|
| Next.js | 14.x | Framework React |
| TypeScript | 5.x | Tipagem estática |
| Tailwind CSS | 3.x | Estilização |
| React Query | 5.x | Cache e estado servidor |

### 3.2 Arquitetura de Microserviços

```
                           ┌─────────────────────┐
                           │    CLIENTE          │
                           │  (Browser/Mobile)   │
                           └──────────┬──────────┘
                                      │
                                      ▼
                           ┌─────────────────────┐
                           │   API GATEWAY       │
                           │   (Spring Cloud)    │
                           │   :8080             │
                           └──────────┬──────────┘
                                      │
              ┌───────────────────────┼───────────────────────┐
              │                       │                       │
              ▼                       ▼                       ▼
    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
    │   eRH-Service   │    │    eFrotas      │    │   (Futuros)     │
    │   :8001         │    │    :8002        │    │   :800X         │
    └────────┬────────┘    └────────┬────────┘    └────────┬────────┘
             │                      │                      │
             └──────────────────────┼──────────────────────┘
                                    │
                           ┌────────┴────────┐
                           │   SERVICE       │
                           │   DISCOVERY     │
                           │   (Eureka)      │
                           │   :8761         │
                           └────────┬────────┘
                                    │
                           ┌────────┴────────┐
                           │   PostgreSQL    │
                           │   :5432         │
                           │                 │
                           │ ┌─────────────┐ │
                           │ │  Schema A   │ │  ← Tenant A
                           │ ├─────────────┤ │
                           │ │  Schema B   │ │  ← Tenant B
                           │ ├─────────────┤ │
                           │ │  Schema C   │ │  ← Tenant C
                           │ └─────────────┘ │
                           └─────────────────┘
```

### 3.3 Estratégia Multi-Tenant

```java
// Filtro Hibernate aplicado em todas as entidades
@FilterDef(name = "tenantFilter", parameters = @ParamDef(name = "tenantId", type = Long.class))
@Filter(name = "tenantFilter", condition = "unidade_gestora_id = :tenantId")
public abstract class AbstractTenantEntity {
    @ManyToOne
    @JoinColumn(name = "unidade_gestora_id")
    private UnidadeGestora unidadeGestora;
}
```

**Fluxo de Isolamento:**
1. Usuário faz login → JWT contém `unidadeGestoraId`
2. Request chega ao serviço → Interceptor extrai tenant do token
3. Filtro Hibernate é ativado → `WHERE unidade_gestora_id = ?`
4. Dados retornados são apenas do tenant do usuário

---

## 4. Módulo Common (Compartilhado)

### 4.1 Responsabilidades

O módulo `common` centraliza funcionalidades utilizadas por **todos** os serviços:

```
common/
└── src/main/java/ws/common/
    ├── auth/                    # Autenticação
    │   ├── JwtTokenProvider     # Geração/validação JWT
    │   ├── JwtAuthFilter        # Filtro de autenticação
    │   └── SecurityConfig       # Configuração Spring Security
    │
    ├── model/                   # Entidades Compartilhadas
    │   ├── UnidadeGestora       # Tenant principal
    │   ├── Usuario              # Usuários do sistema
    │   ├── UsuarioPermissao     # Permissões (RBAC)
    │   ├── AgentePolitico       # Prefeito, Secretários
    │   ├── GestorOrdenador      # Gestores de despesa
    │   ├── Municipio            # Tabela de municípios
    │   ├── Endereco             # Embeddable de endereço
    │   ├── Log                  # Auditoria de ações
    │   └── LogAuthentication    # Logs de autenticação
    │
    ├── service/                 # Serviços Base
    │   ├── UnidadeGestoraService
    │   ├── UsuarioService
    │   └── LogService
    │
    └── config/                  # Configurações
        ├── TenantContext        # Contexto do tenant atual
        └── AuditingConfig       # Auditoria automática
```

### 4.2 Entidades Compartilhadas

#### UnidadeGestora (Tenant)
```java
@Entity
public class UnidadeGestora {
    private Long id;
    private String codigo;           // "001", "002"
    private String nome;             // "Prefeitura de X"
    private String cnpj;
    private String codigoTCE;        // Código no Tribunal de Contas
    private Municipio municipio;
    private Endereco endereco;
    private Boolean ativo;
    // Configurações específicas
    private String logoUrl;
    private String themeConfig;      // JSON de customização visual
}
```

#### Usuario (Autenticação)
```java
@Entity
public class Usuario {
    private Long id;
    private String login;
    private String senha;            // BCrypt encoded
    private String nome;
    private String email;
    private Boolean ativo;
    private UnidadeGestora unidadeGestora;
    private List<UsuarioPermissao> permissoes;
}
```

---

## 5. eRH-Service - Recursos Humanos

### 5.1 Visão Geral

O **eRH-Service** é o serviço de **Gestão de Recursos Humanos**, atualmente em desenvolvimento ativo. Gerencia todo o ciclo de vida do servidor público municipal.

> ⚠️ **Nota:** O tenant (multi-tenancy) é gerenciado pelo módulo **common** via `TenantContext`. O eRH-Service apenas consome essa funcionalidade.

### 5.2 Estrutura Modular Proposta

```
eRH-Service/src/main/java/ws/erh/
│
├── 📦 core/                    ← Configurações e base
│   ├── config/                 # Configurações Spring
│   ├── filter/                 # HibernateFilterAspect (filtros tenant)
│   ├── audit/                  # Auditoria (PARTE 24)
│   └── exception/              # GlobalExceptionHandler
│
├── 📦 cadastro/                ← Dados mestres (PARTES 2-6)
│   ├── servidor/               # Servidores públicos
│   ├── dependente/             # Dependentes
│   ├── departamento/           # Departamentos/Lotações
│   ├── cargo/                  # Cargos/Níveis/CBO
│   └── vinculo/                # Vínculo Funcional
│
├── 📦 folha/                   ← Folha de Pagamento (PARTES 7-10)
│   ├── rubrica/                # Vantagens/Descontos
│   ├── processamento/          # Motor de cálculo
│   ├── decimoterceiro/         # 13º Salário
│   └── consignado/             # Empréstimos consignados
│
├── 📦 obrigacoes/              ← Obrigações legais (PARTES 11-13)
│   ├── esocial/                # eSocial (5 tabelas)
│   ├── tce/                    # TCE (15 tabelas)
│   └── federal/                # SEFIP/DIRF/RAIS
│
├── 📦 temporal/                ← Gestão de tempo (PARTES 14-16)
│   ├── ferias/                 # Férias
│   ├── ponto/                  # Ponto eletrônico
│   └── afastamento/            # Licenças/Afastamentos
│
├── 📦 carreira/                ← Evolução funcional (PARTES 17-21)
│   ├── concurso/               # Concursos públicos
│   ├── capacitacao/            # Treinamentos
│   ├── avaliacao/              # Avaliação de desempenho
│   ├── progressao/             # Progressão funcional
│   └── pensionista/            # Pensionistas
│
├── 📦 apoio/                   ← Apoio e gestão (PARTES 22-27)
│   ├── simulacao/              # Simulações de folha
│   ├── relatorio/              # Relatórios Jasper
│   ├── notificacao/            # Alertas do sistema
│   ├── dashboard/              # Indicadores
│   └── pad/                    # Processos disciplinares
│
└── 📦 integracao/              ← Integrações externas
    ├── banco/                  # Bancos (consignados)
    └── comum/                  # common-service
```

### 5.3 Dependência entre Módulos

```
                                    ┌─────────┐
                                    │  CORE   │ ← usa common/auth/TenantContext
                                    └────┬────┘
                                         │
              ┌──────────────────────────┼──────────────────────────┐
              │                          │                          │
              ▼                          ▼                          ▼
     ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
     │    CADASTRO     │      │   OBRIGAÇÕES    │      │     APOIO       │
     │  (PARTES 2-6)   │      │  (PARTES 11-13) │      │  (PARTES 22-27) │
     └────────┬────────┘      └────────┬────────┘      └────────┬────────┘
              │                        │                        │
              ▼                        ▼                        │
     ┌─────────────────┐      ┌─────────────────┐              │
     │     FOLHA       │◄─────│    TEMPORAL     │              │
     │  (PARTES 7-10)  │      │  (PARTES 14-16) │              │
     └────────┬────────┘      └─────────────────┘              │
              │                        ▲                        │
              │                        │                        │
              └────────────────────────┴────────────────────────┘
```

### 5.4 Status de Implementação

| Módulo | Entidades | Controllers | Status |
|--------|-----------|-------------|--------|
| **cadastro/servidor** | `Servidor`, `Funcionario` | ✅ | Em uso |
| **cadastro/dependente** | `Dependente` | ✅ | Em uso |
| **cadastro/departamento** | `DepartamentoRH`, `Lotacao` | ✅ | Em uso |
| **cadastro/cargo** | `Cargo`, `Nivel`, `OcupacaoCBO` | ✅ | Em uso |
| **cadastro/vinculo** | `VinculoFuncional`, `VinculoFuncionalDet` | ✅ | Em uso |
| **folha/rubrica** | `VantagemDesconto*`, `VinculoVantagemDesconto` | ✅ | Em uso |
| **folha/processamento** | `FolhaPagamento`, `FolhaPagamentoDet` | ✅ | Em uso |
| **obrigacoes/tce** | 15 entidades `Tce*` | ✅ | Em uso |
| **obrigacoes/esocial** | 5 entidades `Esoc*` | ✅ | Em uso |
| **temporal/ferias** | - | 📋 | Planejado |
| **temporal/ponto** | - | 📋 | Planejado |
| **carreira/*** | - | 📋 | Planejado |
| **apoio/*** | - | 📋 | Planejado |

### 5.5 Padrão de Estrutura por Módulo

```
cadastro/servidor/
├── model/
│   └── Servidor.java              # Entidade JPA
├── repository/
│   └── ServidorRepository.java    # Interface JPA
├── service/
│   ├── ServidorService.java       # Interface
│   └── ServidorServiceImpl.java   # Implementação
├── dto/
│   ├── request/ServidorRequest.java
│   └── response/ServidorResponse.java
├── mapper/
│   └── ServidorMapper.java        # Entity ↔ DTO
└── controller/
    └── ServidorController.java    # API REST
```

### 5.6 Modelo de Dados Principal

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        MODELO DE DADOS - eRH                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                           ┌─────────────────┐                               │
│                           │    SERVIDOR     │                               │
│                           │ ─────────────── │                               │
│                           │ id              │                               │
│                           │ cpf             │                               │
│                           │ nome            │                               │
│                           │ dataNascimento  │                               │
│                           │ endereco        │                               │
│                           │ contatos        │                               │
│                           │ documentos      │                               │
│                           │ dadosBancarios  │                               │
│                           └────────┬────────┘                               │
│                                    │                                        │
│                                    │ 1:N                                    │
│                                    ▼                                        │
│  ┌──────────────┐         ┌────────────────────┐         ┌──────────────┐  │
│  │  DEPENDENTE  │◄────────│  VINCULO_FUNCIONAL │────────►│    CARGO     │  │
│  │ ──────────── │   N:1   │ ────────────────── │   N:1   │ ──────────── │  │
│  │ id           │         │ id                 │         │ id           │  │
│  │ nome         │         │ matricula          │         │ descricao    │  │
│  │ cpf          │         │ dataAdmissao       │         │ cbo          │  │
│  │ parentesco   │         │ ativo              │         │ requisitos   │  │
│  │ nascimento   │         └─────────┬──────────┘         └──────────────┘  │
│  │ irrf/salFam  │                   │                                      │
│  └──────────────┘                   │ 1:N (histórico)                      │
│                                     ▼                                       │
│                          ┌──────────────────────┐                           │
│                          │ VINCULO_FUNCIONAL_DET│                           │
│                          │ ──────────────────── │                           │
│                          │ id                   │                           │
│                          │ dataMovimento        │──────►┌──────────────┐   │
│                          │ tipoMovimentacao     │       │   LOTAÇÃO    │   │
│                          │ cargo                │       │ ──────────── │   │
│                          │ lotacao              │       │ id           │   │
│                          │ nivel                │──────►│ descricao    │   │
│                          │ salarioBase          │       │ código       │   │
│                          │ regimeTrabalho       │       └──────────────┘   │
│                          │ regimePrevidencia    │                           │
│                          │ fonteRecurso         │──────►┌──────────────┐   │
│                          └──────────┬───────────┘       │    NÍVEL     │   │
│                                     │                   │ ──────────── │   │
│                                     │ 1:N               │ id           │   │
│                                     ▼                   │ classe       │   │
│                          ┌──────────────────────┐       │ referência   │   │
│                          │   FOLHA_PAGAMENTO    │       │ valor        │   │
│                          │ ──────────────────── │       └──────────────┘   │
│                          │ id                   │                           │
│                          │ mes                  │                           │
│                          │ exercicio            │                           │
│                          │ tipoFolha            │                           │
│                          │ vinculoFuncionalDet  │                           │
│                          │ salarioBase          │                           │
│                          │ totalBruto           │                           │
│                          │ totalDesconto        │                           │
│                          │ totalLiquido         │                           │
│                          └──────────┬───────────┘                           │
│                                     │                                       │
│                                     │ 1:N                                   │
│                                     ▼                                       │
│                          ┌──────────────────────┐       ┌──────────────┐   │
│                          │  FOLHA_PAGAMENTO_DET │──────►│ VANTAGEM_    │   │
│                          │ ──────────────────── │       │ DESCONTO     │   │
│                          │ id                   │       │ ──────────── │   │
│                          │ vantagemDesconto     │       │ id           │   │
│                          │ natureza (V/D)       │       │ descricao    │   │
│                          │ valor                │       │ natureza     │   │
│                          │ parcelas             │       │ tipoCalculo  │   │
│                          │ referencia           │       │ incidências  │   │
│                          └──────────────────────┘       └──────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. eFrotas - Gestão de Frotas

### 6.1 Visão Geral

O **eFrotas** gerencia a frota de veículos do município, incluindo transporte escolar.

### 6.2 Entidades Implementadas

```
eFrotas/
└── src/main/java/ws/efrotas/model/
    ├── Veiculo.java             # ✅ Veículos da frota
    ├── Motorista.java           # ✅ Motoristas habilitados
    ├── Viagem.java              # ✅ Registro de viagens
    ├── Rota.java                # ✅ Rotas pré-definidas
    ├── PercursoRota.java        # ✅ Pontos da rota
    │
    ├── Combustivel.java         # ✅ Tipos de combustível
    ├── PostoCombustivel.java    # ✅ Postos credenciados
    ├── RequisicaoAbastecimento  # ✅ Pedidos de abastecimento
    │
    ├── ManutencaoVeiculo.java   # ✅ Manutenções realizadas
    ├── ItemManutencao.java      # ✅ Itens da manutenção
    ├── RequisicaoManutencao     # ✅ Pedidos de manutenção
    │
    ├── Contrato.java            # ✅ Contratos de locação/serviço
    ├── ItemContrato.java        # ✅ Itens do contrato
    ├── ContratoTransporteEscolar# ✅ Contratos específicos
    │
    ├── Fornecedor.java          # ✅ Fornecedores
    ├── Escola.java              # ✅ Escolas atendidas
    ├── Departamento.java        # ✅ Departamentos
    │
    ├── Inspecao.java            # ✅ Inspeções veiculares
    ├── Vistoria.java            # ✅ Vistorias
    ├── Multa.java               # ✅ Multas de trânsito
    │
    ├── Requisicao.java          # ✅ Requisições gerais
    ├── Agendamento.java         # ✅ Agendamentos de veículos
    ├── Notificacao.java         # ✅ Alertas e notificações
    ├── NotaFiscal.java          # ✅ Notas fiscais
    └── Responsavel.java         # ✅ Responsáveis
```

### 6.3 Módulos do eFrotas

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          eFrotas - Módulos                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 🚗 FROTA                                                             │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Veículos         │ Cadastro de veículos da frota                 │   │
│  │ ✅ Motoristas       │ Motoristas habilitados                        │   │
│  │ ✅ Departamentos    │ Secretarias e setores                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ ⛽ ABASTECIMENTO                                                     │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Postos           │ Postos credenciados                           │   │
│  │ ✅ Combustíveis     │ Tipos (gasolina, diesel, etanol)              │   │
│  │ ✅ Requisições      │ Solicitações de abastecimento                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 🔧 MANUTENÇÃO                                                        │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Manutenções      │ Registro de serviços                          │   │
│  │ ✅ Requisições      │ Solicitações de manutenção                    │   │
│  │ ✅ Inspeções        │ Inspeções periódicas                          │   │
│  │ ✅ Vistorias        │ Vistorias obrigatórias                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 🚌 TRANSPORTE ESCOLAR                                                │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Rotas            │ Rotas de transporte escolar                   │   │
│  │ ✅ Escolas          │ Escolas atendidas                             │   │
│  │ ✅ Contratos        │ Contratos de transporte                       │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ 📋 CONTROLE                                                          │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Viagens          │ Registro de deslocamentos                     │   │
│  │ ✅ Agendamentos     │ Reserva de veículos                           │   │
│  │ ✅ Multas           │ Controle de infrações                         │   │
│  │ ✅ Fornecedores     │ Prestadores de serviço                        │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. Serviços Planejados

### 7.1 Patrimônio-Service

**Propósito:** Controle de bens patrimoniais móveis e imóveis do município.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Patrimônio-Service (Planejado)                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📦 CADASTRO                   │  📋 MOVIMENTAÇÃO                           │
│  ─────────────                 │  ───────────────                           │
│  • Bem Patrimonial             │  • Transferência                           │
│  • Categoria                   │  • Baixa                                   │
│  • Subcategoria                │  • Reavaliação                             │
│  • Localização                 │  • Depreciação                             │
│  • Responsável                 │  • Inventário                              │
│                                │                                            │
│  🏷️ TOMBAMENTO                 │  📊 RELATÓRIOS                             │
│  ────────────                  │  ────────────                              │
│  • Número de Tombamento        │  • Inventário Geral                        │
│  • Etiquetas/QR Code           │  • Bens por Localização                    │
│  • Fotos do Bem                │  • Bens por Responsável                    │
│  • Documentação                │  • Depreciação Acumulada                   │
│                                │  • Exportação TCE                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.2 Contabilidade-Service

**Propósito:** Gestão contábil e financeira do ente público.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     Contabilidade-Service (Planejado)                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  📖 PLANO DE CONTAS            │  💰 EXECUÇÃO ORÇAMENTÁRIA                  │
│  ──────────────────            │  ─────────────────────────                 │
│  • PCASP                       │  • Empenho                                 │
│  • Natureza da Despesa         │  • Liquidação                              │
│  • Fonte de Recursos           │  • Pagamento                               │
│  • Elemento de Despesa         │  • Anulações                               │
│                                │                                            │
│  📋 ORÇAMENTO                  │  📊 RELATÓRIOS                             │
│  ────────────                  │  ────────────                              │
│  • LOA                         │  • Balanço Patrimonial                     │
│  • Créditos Adicionais         │  • Demonstração Variações                  │
│  • Dotações                    │  • Fluxo de Caixa                          │
│  • Reserva                     │  • RREO / RGF                              │
│                                │  • Exportação SICONFI                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.3 Outros Serviços Futuros

| Serviço | Descrição | Integrações |
|---------|-----------|-------------|
| **Licitações** | Gestão de processos licitatórios | Contabilidade, Portal Transparência |
| **Protocolo** | Controle de documentos e processos | Todos os módulos |
| **Almoxarifado** | Controle de estoque | Patrimônio, Licitações |
| **Tributos** | Gestão tributária municipal | Contabilidade |
| **Portal Transparência** | Publicação de dados abertos | Todos os módulos |

---

## 8. Frontend Unificado

### 8.1 Arquitetura do Frontend

```
frontend-services/
└── src/
    ├── app/
    │   ├── (public)/                    # Rotas públicas
    │   │   └── login/
    │   │
    │   └── (private)/                   # Rotas autenticadas
    │       ├── layout.tsx               # Layout com menu lateral
    │       │
    │       ├── e-RH/                    # ✅ IMPLEMENTADO
    │       │   ├── dashboard/
    │       │   ├── cadastro/
    │       │   │   ├── servidor/        # ✅ Tipos + Config + Página
    │       │   │   ├── cargo/           # ✅ Tipos + Config + Página
    │       │   │   ├── lotacao/         # ✅ Tipos + Config + Página
    │       │   │   ├── nivel/           # ✅ Tipos + Config + Página
    │       │   │   ├── legislacao/      # ✅ Tipos + Config + Página
    │       │   │   └── vantagemdesconto/# ✅ Tipos + Config + Página
    │       │   │
    │       │   ├── lancamento/
    │       │   │   ├── vinculo-funcional/# ✅ Tipos + Config + Página
    │       │   │   └── folha-pagamento/ # ✅ Tipos + Config + Página
    │       │   │
    │       │   ├── processamento/       # 📋 Estrutura básica
    │       │   │
    │       │   ├── configuracao/
    │       │   │   ├── tabela-tce/      # ✅ 15 sub-módulos
    │       │   │   ├── tabela-esocial/  # ✅ 5 sub-módulos
    │       │   │   ├── unidade-gestora/ # ✅ Implementado
    │       │   │   ├── usuario/         # ✅ Implementado
    │       │   │   ├── agente-politico/ # ✅ Implementado
    │       │   │   └── grupo-vantagem-desconto/
    │       │   │
    │       │   └── relatorio/
    │       │       └── folha/           # 📋 Estrutura básica
    │       │
    │       └── e-Frotas/                # 📋 Estrutura básica
    │
    ├── components/                      # Componentes reutilizáveis
    │   ├── ui/                          # Primitivos (Button, Input, etc)
    │   └── forms/                       # Formulários genéricos
    │
    ├── contexts/                        # Estado global
    │   ├── AuthContext.tsx              # ✅ Autenticação
    │   ├── CompetenciaContext.tsx       # ✅ Mês/Ano atual
    │   ├── UnidadeGestoraContext.tsx    # ✅ Tenant atual
    │   ├── MenuContext.tsx              # ✅ Menu lateral
    │   └── ThemeContext.tsx             # ✅ Tema visual
    │
    ├── hooks/                           # Hooks customizados
    │   ├── useApi.ts                    # ✅ Chamadas HTTP
    │   ├── useRoles.ts                  # ✅ Verificação de permissões
    │   ├── useDebounce.ts               # ✅ Debounce
    │   └── useFormValidation.ts         # ✅ Validação de formulários
    │
    ├── types/                           # Tipagens TypeScript
    │   ├── servidor.types.ts            # ✅ 50+ campos
    │   ├── vinculoFuncional.types.ts    # ✅ Com histórico
    │   ├── folhaPagamento.types.ts      # ✅ Com detalhes
    │   └── ...
    │
    └── api/                             # Camada de API
        └── api.ts                       # Cliente HTTP configurado
```

### 8.2 Tipagem Frontend - Servidor

```typescript
// servidor.types.ts - Exemplo da implementação
export type ServidorForm = {
  id?: number;
  
  // Dados Pessoais
  cpf: string;
  nome: string;
  dataNascimento: string;
  sexo: string;
  municipioId?: string;
  
  // Contato
  telefone: string;
  celular: string;
  email: string;
  
  // Endereço
  enderecoCep: string;
  enderecoLogradouro: string;
  enderecoNumero: string;
  enderecoBairro: string;
  enderecoComplemento: string;
  
  // Filiação
  paiNome: string;
  paiCpf: string;
  maeNome: string;
  maeCpf: string;
  
  // Documentos
  rg: string;
  rgOrgao: string;
  rgUf: string;
  rgDataEmissao: string;
  tituloEleitor: string;
  tituloZona: string;
  tituloSecao: string;
  pis: string;
  pasep: string;
  nit: string;
  sus: string;
  ctps: string;
  ctpsSerie: string;
  ctpsUf: string;
  
  // Dados Bancários
  bancoId?: string;
  agencia: string;
  contaCorrente: string;
  
  // Referências TCE
  tceEscolaridadeId?: string;
  tceEstadoCivilId?: string;
  
  // Dependentes
  dependentes: DependenteForm[];
};
```

### 8.3 Contextos Implementados

#### CompetenciaContext
Gerencia o mês/ano de trabalho atual (competência):
- Armazena `{mes: number, ano: number}`
- Verifica se competência está aberta/fechada
- Persiste em `sessionStorage`

#### UnidadeGestoraContext
Gerencia o tenant atual:
- Armazena dados da UG selecionada
- Aplica tema customizado da UG
- Persiste em `localStorage`

---

## 9. Infraestrutura

### 9.1 Docker Compose

```yaml
# docker-compose.yml
services:
  # Banco de Dados
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: ws_services
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  
  # Service Discovery
  eureka:
    build: ./service-discovery
    ports:
      - "8761:8761"
  
  # API Gateway
  gateway:
    build: ./api-gateway
    ports:
      - "8080:8080"
    depends_on:
      - eureka
  
  # Serviços
  erh-service:
    build: ./eRH-Service
    environment:
      SPRING_PROFILES_ACTIVE: docker
    depends_on:
      - postgres
      - eureka
  
  efrotas:
    build: ./eFrotas
    environment:
      SPRING_PROFILES_ACTIVE: docker
    depends_on:
      - postgres
      - eureka
  
  # Frontend
  frontend:
    build: ./frontend-services
    ports:
      - "3000:3000"
    depends_on:
      - gateway
```

### 9.2 Ambientes

| Ambiente | Descrição | URL |
|----------|-----------|-----|
| **Development** | Desenvolvimento local | localhost:3000 |
| **Staging** | Homologação | staging.wsservices.com.br |
| **Production** | Produção | app.wsservices.com.br |

---

## 10. Roadmap de Implementação

### 10.1 Status Atual

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          STATUS DE IMPLEMENTAÇÃO                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  LEGENDA:  ✅ Completo   🔄 Em Andamento   📋 Planejado   ⏸️ Pausado        │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ INFRAESTRUTURA                                                       │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Estrutura do Monorepo                                            │   │
│  │ ✅ Módulo Common                                                     │   │
│  │ ✅ Service Discovery (Eureka)                                        │   │
│  │ ✅ API Gateway                                                       │   │
│  │ ✅ Autenticação JWT                                                  │   │
│  │ ✅ Multi-tenant com Hibernate Filters                                │   │
│  │ 🔄 Docker Compose (dev/prod)                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ eRH-SERVICE (FOCO ATUAL)                                             │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ Backend:                                                             │   │
│  │ ✅ Entidades de Execução (Servidor, Vínculo, Folha)                  │   │
│  │ ✅ Tabelas TCE (15 tabelas)                                          │   │
│  │ ✅ Tabelas eSocial (5 tabelas)                                       │   │
│  │ 🔄 APIs REST                                                         │   │
│  │ 📋 Motor de Cálculo de Folha                                         │   │
│  │ 📋 Geração de Relatórios                                             │   │
│  │ 📋 Exportação TCE/eSocial                                            │   │
│  │                                                                      │   │
│  │ Frontend:                                                            │   │
│  │ ✅ Módulo Cadastro (6 sub-módulos)                                   │   │
│  │ ✅ Módulo Lançamento (2 sub-módulos)                                 │   │
│  │ ✅ Módulo Configuração (Tabelas TCE/eSocial)                         │   │
│  │ 🔄 Módulo Processamento                                              │   │
│  │ 📋 Módulo Relatório                                                  │   │
│  │ 📋 Dashboard                                                         │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ eFROTAS                                                              │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ ✅ Entidades (26 classes)                                            │   │
│  │ ⏸️ APIs REST                                                         │   │
│  │ 📋 Frontend                                                          │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ SERVIÇOS FUTUROS                                                     │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │ 📋 Patrimônio-Service                                                │   │
│  │ 📋 Contabilidade-Service                                             │   │
│  │ 📋 Licitações-Service                                                │   │
│  │ 📋 Protocolo-Service                                                 │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 10.2 Próximos Passos (eRH)

| Fase | Objetivo | Prazo |
|------|----------|-------|
| **1** | Completar APIs REST de Cadastro | 2 semanas |
| **2** | Implementar Motor de Cálculo | 4 semanas |
| **3** | Integração Frontend-Backend | 2 semanas |
| **4** | Módulo de Processamento | 3 semanas |
| **5** | Relatórios e Exportações | 3 semanas |
| **6** | Testes e Homologação | 2 semanas |

### 10.3 Visão de Longo Prazo

```
2024 Q4:  eRH-Service MVP (Cadastro + Folha básica)
          │
2025 Q1:  eRH-Service Completo (TCE + eSocial)
          ├── eFrotas MVP
          │
2025 Q2:  Patrimônio-Service
          ├── eFrotas Completo
          │
2025 Q3:  Contabilidade-Service
          │
2025 Q4:  Integrações entre módulos
          ├── Portal Transparência
```

---

## Conclusão

O **WS-Services** é uma plataforma ambiciosa e bem estruturada para gestão pública municipal. Com a arquitetura de microserviços e o módulo comum compartilhado, novos serviços podem ser adicionados de forma incremental, aproveitando:

- ✅ Autenticação centralizada
- ✅ Multi-tenant já implementado
- ✅ Frontend unificado com rotas por serviço
- ✅ Padrões de código estabelecidos
- ✅ Conformidade com órgãos reguladores (TCE, eSocial)

O foco atual no **eRH-Service** estabelece as bases para os demais serviços, criando um ecossistema completo de gestão municipal.

---

**Documento:** ARQUITETURA-ECOSSISTEMA-WS-SERVICES.md  
**Versão:** 1.0  
**Data:** Janeiro 2025  
**Autor:** Equipe WS-Services
