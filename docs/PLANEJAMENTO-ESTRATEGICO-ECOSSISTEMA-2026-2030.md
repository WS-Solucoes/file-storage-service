# Planejamento Estratégico — Ecossistema WS-Services 2026–2030

## Plataforma SaaS de Gestão Pública Municipal

**Versão:** 4.0 — Completa com Justificativas + Ecossistema + Microserviços  
**Data:** Março 2026  
**Horizonte:** 2026–2030  

---

## Sumário

1. [Diagnóstico da Arquitetura Atual](#1-diagnóstico-da-arquitetura-atual)
2. [Justificativas das Escolhas Arquiteturais](#2-justificativas-das-escolhas-arquiteturais)
3. [Mapeamento Completo de Sistemas de Gestão Pública Municipal](#3-mapeamento-completo-de-sistemas-de-gestão-pública-municipal)
4. [Detalhamento de Cada Módulo e seus Microserviços](#4-detalhamento-de-cada-módulo-e-seus-microserviços)
5. [Modelo de Comercialização por Módulo/Serviço](#5-modelo-de-comercialização-por-móduloserviço)
6. [Arquitetura Alvo do Ecossistema (Blueprint Técnico)](#6-arquitetura-alvo-do-ecossistema-blueprint-técnico)
7. [Estratégia de Dados e Integração](#7-estratégia-de-dados-e-integração)
8. [Análise Competitiva](#8-análise-competitiva)
9. [Roadmap de Implementação 2026–2030](#9-roadmap-de-implementação-20262030)
10. [Infraestrutura e DevOps](#10-infraestrutura-e-devops)
11. [Governança, Compliance e Segurança](#11-governança-compliance-e-segurança)
12. [Riscos e Mitigações](#12-riscos-e-mitigações)
13. [Métricas de Sucesso](#13-métricas-de-sucesso)
14. [Próximos Passos Imediatos](#14-próximos-passos-imediatos)

---

## 1. Diagnóstico da Arquitetura Atual

### 1.1 Estado Atual — Março 2026

```
┌─────────────────────────────────────────────────────────────────────┐
│                     ESTADO ATUAL — MARÇO 2026                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  INFRAESTRUTURA (✅ Funcional)                                      │
│  ├── Service Discovery (Eureka)        :9876                        │
│  ├── API Gateway (Spring Cloud)        :9080                        │
│  ├── Frontend Next.js Unificado        :9300                        │
│  └── PostgreSQL                        :5432                        │
│                                                                     │
│  SERVIÇOS DE NEGÓCIO                                                │
│  ├── common-service   (✅ Em uso)      :9081  — Auth, Multi-tenant  │
│  ├── erh-service      (🔄 Ativo)       :9083  — RH + Folha         │
│  └── frotas-service   (⏸ Pausado)      :9082  — Frotas             │
│                                                                     │
│  FRONTEND                                                           │
│  ├── /e-RH/     (🔄 Em desenvolvimento ativo)                       │
│  └── /e-Frotas/ (📋 Estrutura básica)                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 1.2 Pontos Fortes

| # | Decisão | Por que é boa |
|---|---------|---------------|
| 1 | **Monorepo com serviços independentes** | Facilita refactoring, deploy granular e shared code |
| 2 | **Módulo common centralizado** | Evita duplicação de auth, multi-tenancy, entidades base |
| 3 | **Multi-tenant via Hibernate Filters** | Isolamento de dados sem múltiplos bancos — escalável e simples |
| 4 | **API Gateway com roteamento por prefixo** | `/frotas/**`, `/erh/**` — limpo e extensível |
| 5 | **Frontend unificado** | Experiência única para o servidor público, evita múltiplos logins |
| 6 | **Stack moderna** | Java 21 LTS + Spring Boot 3.2 + Next.js 14 + TypeScript |
| 7 | **Conformidade regulatória desde o início** | Tabelas TCE e eSocial já modeladas |
| 8 | **Estrutura modular no eRH** | `cadastro/`, `folha/`, `obrigacoes/` — pode evoluir para serviços |

### 1.3 Pontos que Precisam Evoluir

| # | Problema | Impacto | Recomendação |
|---|----------|---------|--------------|
| 1 | Banco único compartilhado | Acoplamento de dados entre serviços | Database-per-Service |
| 2 | Eureka em modo manutenção | Risco futuro de suporte | Planejar migração |
| 3 | Sem Message Broker | Apenas comunicação síncrona | Adicionar RabbitMQ |
| 4 | Sem Config Server | Configs duplicadas | Spring Cloud Config |
| 5 | Sem Circuit Breaker | Falha em cascata | Resilience4j |
| 6 | Sem observabilidade | Sem métricas/tracing | OpenTelemetry + Grafana |
| 7 | Sem CI/CD | Deploy manual | GitHub Actions |
| 8 | JWT keys em classpath | Risco de segurança | Vault ou Config Server |

---

## 2. Justificativas das Escolhas Arquiteturais

> **Este capítulo justifica CADA decisão tecnológica** com vantagens, desvantagens, alternativas descartadas e fundamentação baseada em padrões da indústria (microservices.io, Chris Richardson) e pesquisa de mercado.

---

### 2.1 Microserviços vs. Monolito — Por que Microserviços?

**Decisão:** Arquitetura de microserviços modulares, com decomposição por capacidade de negócio (Bounded Context — DDD).

**Fundamentação:** Segundo Chris Richardson (microservices.io), o padrão *Decompose by Business Capability* define que cada serviço deve corresponder a uma capacidade de negócio — algo que a organização FAZ para gerar valor. No contexto de gestão pública municipal, cada secretaria é um Bounded Context natural:

- Recursos Humanos → `erh-service`
- Frotas → `frotas-service`
- Contabilidade → `contabilidade-service`

**Princípios aplicados (microservices.io):**
- **Single Responsibility Principle (SRP):** Cada serviço tem UMA razão para mudar.
- **Common Closure Principle (CCP):** Classes que mudam pela mesma razão ficam no mesmo pacote/serviço.
- **"Two-pizza team" (6-10 pessoas):** Cada serviço deve ser mantido por uma equipe pequena e autônoma.

| Critério | Monolito | Microserviços | Justificativa da Escolha |
|----------|----------|---------------|--------------------------|
| **Deploy** | Tudo junto — risco de indisponibilidade total | Independente por serviço | ✅ Prefeituras não podem ficar sem folha porque o módulo de frotas atualizou |
| **Escalabilidade** | Escala vertical (máquina maior) | Escala horizontal (mais instâncias) | ✅ Folha tem picos mensais — escala só o erh-service |
| **Tecnologia** | Uma stack para tudo | Polyglot (Java backend, Node integrações) | ✅ Flexibilidade futura sem reescrever tudo |
| **Complexidade operacional** | Simples de gerenciar | Requer Service Discovery, Gateway, Config | ⚠️ Trade-off aceito — infraestrutura já pronta |
| **Resiliência** | Uma falha derruba tudo | Falha isolada (com Circuit Breaker) | ✅ Essencial para SaaS multi-tenant com SLA |
| **Equipe** | Todos no mesmo código | Times autônomos por domínio | ✅ Cada time cuida de um serviço |
| **Transações** | ACID simples | Saga Pattern (compensação) | ⚠️ Trade-off mitigado com RabbitMQ + Saga |
| **Time-to-market** | Mais rápido para MVP | Mais lento para setup inicial | ⚠️ Setup já feito — investimento paga em 5 anos |

**Alternativa descartada — Monolito Modular:**
- Prefeituras compram módulos diferentes (uma quer só RH, outra quer tudo). Monolito forçaria deploy de código não utilizado. Concorrentes (Betha, IPM) já migraram para Cloud-native.

**Alternativa descartada — Serverless / FaaS:**
- Folha de pagamento é processamento batch pesado (minutos). Cold starts de Lambda inaceitáveis. Prefeituras exigem dados em território nacional — serverless cria dependência de cloud provider. Custo imprevisível.

---

### 2.2 Java 21 LTS + Spring Boot 3.2

| Critério | Java 21 + Spring Boot | .NET 8 | Go | Node.js/NestJS |
|----------|----------------------|--------|------|----------------|
| **Ecossistema enterprise** | ★★★★★ Maior do mundo | ★★★★☆ | ★★★☆☆ | ★★★☆☆ |
| **Mão de obra no Brasil** | ★★★★★ Grande oferta | ★★★★☆ | ★★☆☆☆ Escassa | ★★★★☆ |
| **Performance** | ★★★★☆ Virtual Threads | ★★★★☆ | ★★★★★ | ★★★☆☆ |
| **Spring Cloud** | ★★★★★ Nativo | ❌ | ❌ | ❌ |
| **Hibernate/JPA** | ★★★★★ | EF Core ★★★★☆ | ORMs fracos | Prisma ★★★☆☆ |
| **Segurança** | ★★★★★ Spring Security | ★★★★☆ | Básico | Passport.js ★★★☆☆ |
| **LTS** | Java 21 até 2028+ | .NET 8 até 2026 | Sem LTS formal | Node 20 até 2026 |

**Por que Java 21:** Virtual Threads (Project Loom), Pattern Matching + Records, ZGC (pausas < 1ms), LTS até 2028+.

---

### 2.3 Spring Cloud Gateway

| Critério | Spring Cloud Gateway | Kong | Traefik | Nginx |
|----------|---------------------|------|---------|-------|
| **Integração Spring** | ★★★★★ Nativo | ★★☆☆☆ | ★★☆☆☆ | ★☆☆☆☆ |
| **Service Discovery** | ★★★★★ Eureka nativo | ★★★☆☆ | ★★★★☆ | ★☆☆☆☆ |
| **Circuit Breaker** | ★★★★★ Resilience4j | ★★★★☆ | ★★☆☆☆ | ❌ |
| **Auth Filter** | ★★★★★ Spring Security | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ |
| **Performance** | ★★★★☆ Reactive/Netty | ★★★★★ | ★★★★★ | ★★★★★ |

**Vence por:** Homogeneidade Java, integração Eureka nativa, filtros customizáveis na linguagem da equipe.

---

### 2.4 Eureka — Service Discovery

| Critério | Eureka | Consul | K8s DNS | etcd |
|----------|--------|--------|---------|------|
| **Integração Spring** | ★★★★★ | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ |
| **Setup** | ★★★★★ 1 jar | ★★★☆☆ | ★★★★★ Built-in | ★★★☆☆ |
| **Manutenção ativa** | ⚠️ Modo manutenção | ★★★★★ | ★★★★★ | ★★★★★ |
| **Requer K8s?** | Não | Não | **Sim** | Não |

**Plano de migração:** 2026: Eureka → 2027: Avaliar Consul → 2028+: K8s DNS nativo.

---

### 2.5 PostgreSQL

| Critério | PostgreSQL | MySQL | Oracle | SQL Server | MongoDB |
|----------|-----------|-------|--------|------------|---------|
| **Custo** | **$0** | $0 | $$$$$ | $$$$ | $0 |
| **JSONB** | ★★★★★ Nativo, indexável | ★★★☆☆ | ★★★★☆ | ★★★★☆ | ★★★★★ |
| **Compliance público** | ★★★★★ Sem lock-in | ★★★★★ | ⚠️ Lock-in | ⚠️ Lock-in | ★★★★☆ |
| **Multi-tenant schemas** | ★★★★★ Nativo | ★★★★☆ | ★★★★★ | ★★★★☆ | ★★★★☆ |
| **PostGIS** | ★★★★★ | ★★☆☆☆ | ★★★★☆ | ★★★☆☆ | ★★★☆☆ |

**Vence por:** $0 licença (essencial em licitação pública), JSONB (layouts TCE variáveis), PostGIS (eFrotas, eTributos, eObras), schemas nativos para multi-tenant.

---

### 2.6 Database-per-Service (Schema-per-Service)

| Aspecto | Banco Compartilhado (atual) | Database-per-Service (alvo) |
|---------|---------------------------|---------------------------|
| **JOINs entre domínios** | ✅ Fácil | ❌ API Composition |
| **Transações ACID** | ✅ Simples | ⚠️ Saga Pattern |
| **Acoplamento** | ❌ Alto | ✅ Zero |
| **Deploy independente** | ⚠️ Parcial | ✅ Total |
| **Escalabilidade** | ❌ Um gargalo | ✅ Escala independente |

**Implementação:** Schema-per-Service no mesmo PostgreSQL Server.

---

### 2.7 RabbitMQ vs. Kafka

| Critério | RabbitMQ | Apache Kafka | Amazon SQS | Redis Streams |
|----------|----------|-------------|------------|---------------|
| **Modelo** | Message Queue (push) | Event Log (pull) | Queue | Log |
| **Complexidade** | ★★★★☆ Moderada | ★★☆☆☆ Alta | ★★★★★ | ★★★★☆ |
| **Throughput** | 10K-50K msg/s | 100K-1M+ msg/s | Variável | 50K msg/s |
| **RAM mínima** | 256MB-1GB | 2GB+ (x3 brokers) | N/A | Variável |
| **Spring AMQP** | ★★★★★ Nativo | ★★★★☆ | ★★★☆☆ | ★★★☆☆ |
| **Dead Letter Queue** | ★★★★★ Nativo | Manual | ★★★★☆ | Manual |

**Vence por:** Volume adequado (eventos mensais, não real-time), DLQ nativo, 256MB RAM, Spring AMQP first-class.

---

### 2.8 Saga Pattern — Transações Distribuídas

Exemplo concreto:
```
SAGA: Processamento de Folha → Empenho Contábil

1. [erh-service]     → Calcula folha        → Salva em erh_db
2. [erh-service]     → Publica: folha.processada
3. [contab-service]  → Recebe evento         → Gera empenho em contab_db
4. [contab-service]  → Publica: empenho.criado
5. [erh-service]     → Marca folha como "empenhada"

SE FALHAR no passo 3:
3a. [contab-service] → Publica: empenho.falhou
4a. [erh-service]    → Marca folha "pendente_empenho"
5a. [notification]   → Notifica gestor
```

---

### 2.9 Multi-Tenancy

| Estratégia | Isolamento | Complexidade | Custo | Quando |
|------------|-----------|-------------|-------|--------|
| **Discriminator Column (atual)** | Lógico (WHERE) | ★★★★★ Simples | ★★★★★ Baixo | < 200 tenants |
| **Schema-per-Tenant** | Schema isolado | ★★★☆☆ Média | ★★★★☆ | 200-1.000 |
| **Database-per-Tenant** | Total | ★★☆☆☆ Alta | ★★☆☆☆ Alto | > 1.000 |

Evolução: 2026: Discriminator → 2027-2028: Schema-per-Tenant → 2029+: Database-per-Tenant.

---

### 2.10 Next.js 14 + TypeScript

| Critério | Next.js 14 | Angular 17 | Vue 3 + Nuxt | Blazor |
|----------|-----------|------------|-------------|--------|
| **SSR + SSG** | ★★★★★ | ★★★☆☆ | ★★★★☆ | ★★★☆☆ |
| **React ecosystem** | ★★★★★ | ❌ | ★★★★☆ | ❌ |
| **Mão de obra BR** | ★★★★★ | ★★★★☆ | ★★★☆☆ | ★★☆☆☆ |
| **SEO** | ★★★★★ | ★★★☆☆ | ★★★★☆ | ★★☆☆☆ |

**Vence por:** Portal de Transparência (SSG/CDN), Portal do Servidor (SSR seguro), Admin (SPA React), mão de obra abundante no Brasil.

---

### 2.11 JWT com RSA

| Aspecto | JWT HMAC | JWT RSA ✅ | OAuth2/Keycloak | Sessions |
|---------|----------|-----------|----------------|----------|
| **Validação distribuída** | ❌ Todos precisam do secret | ✅ Só chave pública | ✅ | ❌ Sticky |
| **Se comprometido** | ⚠️ Forja tokens | ✅ Não forja | ✅ | ★★★★☆ |
| **Performance** | ★★★★★ | ★★★★☆ | ★★★☆☆ (roundtrip) | ★★★★★ |

---

### 2.12 Resumo: Matriz de 15 Decisões Arquiteturais

| # | Decisão | Escolha | Principal Alternativa | Por que a escolha vence |
|:-:|---------|---------|----------------------|------------------------|
| 1 | Arquitetura | Microserviços | Monolito modular | Módulos vendáveis, escala independente |
| 2 | Linguagem | Java 21 LTS | .NET 8 / Go | Spring Cloud, mão de obra BR, Virtual Threads |
| 3 | Framework | Spring Boot 3.2 | Quarkus / Micronaut | Maior ecossistema, Spring Cloud nativo |
| 4 | API Gateway | Spring Cloud GW | Kong / Traefik | Homogeneidade Java, integração Eureka |
| 5 | Service Discovery | Eureka → K8s DNS | Consul | Simples, já implementado |
| 6 | Banco de Dados | PostgreSQL | MySQL / Oracle | $0, JSONB, PostGIS, schemas nativos |
| 7 | Dados pattern | DB-per-Service | Shared Database | Loose coupling, deploy independente |
| 8 | Message Broker | RabbitMQ | Kafka | Volume adequado, baixo custo, Spring AMQP |
| 9 | Transações dist. | Saga | 2PC | 2PC inviável em microserviços |
| 10 | Multi-tenancy | Discriminator → Schema | DB-per-tenant | Custo mínimo < 200 tenants |
| 11 | Frontend | Next.js 14 + TS | Angular / Blazor | SSR+SSG, React, mão de obra BR |
| 12 | Auth | JWT RSA | Keycloak | Simples, zero roundtrip, seguro |
| 13 | Observability | OTel + Grafana | Datadog / New Relic | $0, vendor-neutral, CNCF |
| 14 | CI/CD | GitHub Actions | GitLab CI / Jenkins | Integrado ao repo, free tier |
| 15 | Container Orch. | Docker Compose → K8s | Swarm / ECS | Simplicidade agora, K8s quando necessário |

---

## 3. Mapeamento Completo de Sistemas de Gestão Pública Municipal

### 3.1 Contexto: Estrutura de um Município Brasileiro

A gestão pública municipal brasileira é regida por legislações federais, estaduais e municipais e envolve **secretarias, departamentos e autarquias**. O Brasil possui **5.571 municípios** (IBGE), cada um com Lei Orgânica própria que define sua organização política, limitada pela Constituição Federal de 1988.

**Competências municipais (CF/88, Art. 30):**
- Legislar sobre assuntos de interesse local
- Prestar serviços públicos essenciais (saúde, educação, transporte, urbanismo)
- Administrar pessoal, patrimônio e finanças
- Arrecadar tributos (IPTU, ISS, ITBI, taxas)
- Prestar contas aos Tribunais de Contas

**Secretarias típicas de um município:**

| Secretaria | Sistemas Necessários | Base Legal |
|------------|---------------------|------------|
| **Administração/RH** | eRH, eFolha, ePatrimônio, eProtocolo, eAlmoxarifado | CLT, Lei 8.112, eSocial |
| **Fazenda/Finanças** | eContábil, eTributos, eNFSe, eFiscal | LRF (LC 101/2000), SICONFI, STN |
| **Compras/Licitações** | eLicit, eContratos | Lei 14.133/2021, PNCP |
| **Transporte** | eFrotas | Decreto interno |
| **Obras/Infraestrutura** | eObras | Lei 8.666/93, TCE |
| **Saúde** | eSaúde | SUS (Lei 8.080/90), e-SUS, CNES |
| **Educação** | eEducação | LDB (Lei 9.394/96), FUNDEB, Censo Escolar |
| **Assistência Social** | eAssistência | SUAS (Lei 8.742/93), CadÚnico, MDS |
| **Meio Ambiente** | eMeioAmbiente | CONAMA, Código Florestal |
| **Planejamento Urbano** | eUrbano | Estatuto da Cidade (Lei 10.257/01) |
| **Agricultura** | eAgro | Lei Complementar municipal |
| **Comunicação** | ePortal | LAI (Lei 12.527/11) |
| **Gabinete/Executivo** | eGabinete | Lei Orgânica Municipal |
| **Câmara Municipal** | eCâmara | Regimento Interno |

### 3.2 Obrigações Legais que EXIGEM Sistemas Informatizados

| Obrigação | Órgão Fiscalizador | Prazo | Módulos Impactados | Penalidade |
|-----------|-------------------|-------|-----------------------|------------|
| **eSocial** | Governo Federal / RFB | Mensal | eRH, eFolha | Multas trabalhistas |
| **SICONFI** | Tesouro Nacional (STN) | Bimestral/Semestral | eContábil | Suspensão transferências |
| **RREO** | STN / TCE | Bimestral | eContábil | Rejeição contas |
| **RGF** | STN / TCE | Quadrimestral | eContábil, eRH (pessoal) | Rejeição contas |
| **AUDESP / SAGRES / TCE** | TCE Estadual | Mensal/Anual | TODOS (fiscal) | Reprovação contas |
| **PNCP** | Gov. Federal | Cada licitação | eLicit, eContratos | Nulidade da licitação |
| **LAI (Transparência)** | CGU | Permanente | eTransparência | Responsabilização |
| **e-SUS AB** | DataSUS / MS | Mensal | eSaúde | Perda repasses SUS |
| **Censo Escolar** | INEP / MEC | Anual | eEducação | Perda FUNDEB |
| **CadÚnico** | MDS | Permanente | eAssistência | Perda repasses SUAS |
| **Padrão Nacional NFSe** | RFB / ABRASF | Permanente | eNFSe | Irregularidade fiscal |
| **RAIS / DIRF / SEFIP** | RFB / MTE | Anual | eRH, eFolha | Multas |
| **LRF (Responsabilidade Fiscal)** | STN / TCE | Permanente | eContábil, eRH | Crime de responsabilidade |

### 3.3 Matriz Completa de Sistemas por Secretaria

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                    ECOSSISTEMA COMPLETO DE GESTÃO PÚBLICA MUNICIPAL                      │
│                          (~25 Módulos Principais / ~80+ Microserviços)                   │
├──────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                          │
│  ══════════════════════════════════════════════════════════════════════════════            │
│  TIER 1 — CORE (Obrigatórios para qualquer município)                                   │
│  ══════════════════════════════════════════════════════════════════════════════            │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 1. eRH             │  │ 2. eFolha          │  │ 3. eContábil       │                  │
│  │ Recursos Humanos   │  │ Folha Pagamento    │  │ Contabilidade      │                  │
│  │ ✅ EM ANDAMENTO     │  │ ✅ EM ANDAMENTO     │  │ 📋 PLANEJADO       │                  │
│  │ Sec: Administração │  │ (parte do eRH)     │  │ Sec: Fazenda       │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 4. eLicit          │  │ 5. eTributos       │  │ 6. ePatrimônio     │                  │
│  │ Compras/Licitações │  │ Tributos Municipal │  │ Bens Patrimoniais  │                  │
│  │ 📋 PLANEJADO       │  │ 📋 PLANEJADO       │  │ 📋 PLANEJADO       │                  │
│  │ Sec: Compras       │  │ Sec: Fazenda       │  │ Sec: Administração │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐                                          │
│  │ 7. eProtocolo      │  │ 8. eTransparência  │                                          │
│  │ Gestão Documentos  │  │ Portal Acesso Info │                                          │
│  │ 📋 PLANEJADO       │  │ 📋 PLANEJADO       │                                          │
│  │ Sec: Administração │  │ OBRIGATÓRIO (LAI)  │                                          │
│  └────────────────────┘  └────────────────────┘                                          │
│                                                                                          │
│  ══════════════════════════════════════════════════════════════════════════════            │
│  TIER 2 — OPERACIONAL (Necessários para operação eficiente)                              │
│  ══════════════════════════════════════════════════════════════════════════════            │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 9. eFrotas         │  │ 10. eAlmoxarifado  │  │ 11. eContratos     │                  │
│  │ Gestão de Frotas   │  │ Controle Estoque   │  │ Gestão Contratos   │                  │
│  │ ✅ EM ANDAMENTO     │  │ 📋 PLANEJADO       │  │ 📋 PLANEJADO       │                  │
│  │ Sec: Transporte    │  │ Sec: Administração │  │ Sec: Administração │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 12. eObras         │  │ 13. eFiscal        │  │ 14. eNFSe          │                  │
│  │ Obras Públicas     │  │ Fiscaliz. Tribut.  │  │ Nota Fiscal Eletr  │                  │
│  │ 📋 FUTURO          │  │ 📋 FUTURO          │  │ 📋 FUTURO          │                  │
│  │ Sec: Obras         │  │ Sec: Fazenda       │  │ Sec: Fazenda       │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ══════════════════════════════════════════════════════════════════════════════            │
│  TIER 3 — SETORIAL (Secretarias/Áreas específicas)                                       │
│  ══════════════════════════════════════════════════════════════════════════════            │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 15. eSaúde         │  │ 16. eEducação      │  │ 17. eAssistência   │                  │
│  │ Gestão de Saúde    │  │ Gestão Educacional │  │ Assistência Social │                  │
│  │ 📋 FUTURO          │  │ 📋 FUTURO          │  │ 📋 FUTURO          │                  │
│  │ Sec: Saúde         │  │ Sec: Educação      │  │ Sec: Assist.Social │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 18. eMeioAmbiente  │  │ 19. eUrbano        │  │ 20. eAgro          │                  │
│  │ Licenças Ambientais│  │ Plan. Urbano       │  │ Agricultura        │                  │
│  │ 📋 FUTURO          │  │ 📋 FUTURO          │  │ 📋 FUTURO          │                  │
│  │ Sec: Meio Ambiente │  │ Sec: Planejamento  │  │ Sec: Agricultura   │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ══════════════════════════════════════════════════════════════════════════════            │
│  TIER 4 — CIDADÃO & TRANSPARÊNCIA                                                        │
│  ══════════════════════════════════════════════════════════════════════════════            │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐                  │
│  │ 21. ePortal        │  │ 22. eOuvidoria     │  │ 23. eCidadão       │                  │
│  │ Site Institucional │  │ Ouvidoria/SAC      │  │ App do Cidadão     │                  │
│  │ 📋 FUTURO          │  │ 📋 FUTURO          │  │ 📋 FUTURO          │                  │
│  │ Comunicação        │  │ Cidadão            │  │ Cidadão            │                  │
│  └────────────────────┘  └────────────────────┘  └────────────────────┘                  │
│                                                                                          │
│  ┌────────────────────┐  ┌────────────────────┐                                          │
│  │ 24. eCâmara        │  │ 25. eGabinete      │                                          │
│  │ Câmara Municipal   │  │ Gestão Gabinete    │                                          │
│  │ 📋 FUTURO          │  │ 📋 FUTURO          │                                          │
│  │ Legislativo        │  │ Executivo          │                                          │
│  └────────────────────┘  └────────────────────┘                                          │
│                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

### 3.4 Prioridade por Obrigação Legal + Demanda de Mercado

| Prio | Módulo | Obrigação Legal | Demanda Mercado | Justificativa |
|:---:|--------|----------------|:-:|---|
| **P0** | eRH + eFolha | eSocial, TCE, RAIS, DIRF, SEFIP | ★★★★★ | Todo município tem servidor. Obrigação mensal. |
| **P0** | eContábil | SICONFI/STN, LRF, TCE, RREO, RGF | ★★★★★ | Sem contabilidade = suspensão transferências |
| **P1** | eLicit | Lei 14.133/21, PNCP | ★★★★★ | Toda compra pública exige licitação |
| **P1** | eTributos + eNFSe | CTN, Padrão Nacional NFSe, ABRASF | ★★★★★ | Receita própria = autonomia financeira |
| **P1** | eTransparência | LAI (Lei 12.527/11) | ★★★★☆ | Obrigatório por lei federal para TODOS |
| **P2** | ePatrimônio | TCE envio anual | ★★★★☆ | Controle de bens = prestação de contas |
| **P2** | eFrotas | ROI direto em combustível | ★★★★☆ | Economia comprovada 15-30% |
| **P2** | eContratos | Lei 14.133/21, TCE | ★★★★☆ | Gestão de vigência e aditivos |
| **P2** | eProtocolo | Decreto interno | ★★★☆☆ | Rastreabilidade de documentos |
| **P2** | eAlmoxarifado | TCE (inventário anual) | ★★★☆☆ | Controle de estoque público |
| **P3** | eSaúde | e-SUS AB, CNES, DataSUS | ★★★★☆ | Repasses SUS vinculados a envio |
| **P3** | eEducação | Censo Escolar, FUNDEB, PNAE | ★★★★☆ | Repasses MEC vinculados |
| **P3** | eAssistência | SUAS, CadÚnico, MDS | ★★★☆☆ | Repasses FNAS vinculados |
| **P4** | eObras | TCE (obras em andamento) | ★★★☆☆ | Fiscalização e medições |
| **P4** | eFiscal | CTN, processo administrativo | ★★★☆☆ | Autos de infração |
| **P4** | eMeioAmbiente | CONAMA, licenciamento | ★★☆☆☆ | Municípios maiores |
| **P4** | eUrbano | Estatuto da Cidade | ★★☆☆☆ | Alvarás e habite-se |
| **P5** | eAgro | LC municipal | ★★☆☆☆ | Municípios rurais |
| **P5** | eOuvidoria | LAI | ★★☆☆☆ | Complemento ao eTransparência |
| **P5** | eCidadão | Modernização | ★★★☆☆ | Diferencial competitivo |
| **P5** | ePortal | LAI (site institucional) | ★★☆☆☆ | CMS municipal |
| **P5** | eCâmara | Regimento Interno | ★★☆☆☆ | Legislativo separado |
| **P5** | eGabinete | Gestão interna | ★☆☆☆☆ | Oficialização de demandas |

---

## 4. Detalhamento de Cada Módulo e seus Microserviços

> Cada módulo é decomposto em **microserviços** que podem ser desenvolvidos e **comercializados separadamente**.

---

### MÓDULO 1: eRH — Recursos Humanos (✅ EM ANDAMENTO)

**Secretaria:** Administração/RH  
**Obrigações legais:** eSocial, TCE, RAIS, DIRF, SEFIP, CAGED  
**Base legal:** CLT, Lei 8.112/90 (RJU), Lei 8.666/93 (patrimônio), LC 101/2000 (LRF — limite pessoal)

**Justificativa:** TODO município brasileiro é obrigado pelo eSocial a reportar movimentações de pessoal eletronicamente ao Governo Federal. Desde 2022, órgãos públicos municipais estão na 4ª fase do eSocial (eventos SST). Sem sistema informatizado é impossível cumprir os prazos.

| # | Microserviço | Descrição | Comercializ. Separada? | Base Legal |
|---|---|---|---|---|
| 1.1 | **Cadastro de Pessoal** | Servidores, dependentes, documentos, dados bancários | Base obrigatória | eSocial S-2200 |
| 1.2 | **Cargos e Carreiras** | Cargos, CBO, níveis, classes, referências, plano carreira | Base obrigatória | TCE (quadro pessoal) |
| 1.3 | **Estrutura Organizacional** | Departamentos, lotações, organograma | Base obrigatória | Lei Orgânica |
| 1.4 | **Vínculo Funcional** | Vínculos, movimentações, histórico funcional | Base obrigatória | eSocial S-2206 |
| 1.5 | **Folha de Pagamento** | Processamento, rubricas, memória cálculo, 13° salário | ✅ Sim (eFolha) | eSocial S-1200/S-1210 |
| 1.6 | **Férias** | Período aquisitivo, programação, concessão, cálculo | ✅ Sim | CLT Art. 129-153 |
| 1.7 | **Afastamentos** | Licenças, atestados, afastamentos legais | ✅ Sim | eSocial S-2230 |
| 1.8 | **Rescisão** | Desligamentos, cálculos rescisórios, TRCT | ✅ Sim | eSocial S-2299/S-2399 |
| 1.9 | **Previdência (RPPS/RGPS)** | Instituto, guias, contribuições, aposentadoria | ✅ Sim | EC 103/2019 (Reforma) |
| 1.10 | **Obrigações Acessórias** | eSocial, TCE, RAIS, DIRF, SEFIP, SAGRES | ✅ Sim | Legislação federal |
| 1.11 | **Consignados** | Empréstimos, margem consignável, convênios | ✅ Sim | Lei 10.820/03 |
| 1.12 | **Concursos** | Editais, inscrições, classificação, nomeação | ✅ Sim | CF/88 Art. 37 |
| 1.13 | **Avaliação de Desempenho** | Formulários, ciclos, metas, resultados | ✅ Sim | EC 19/98 |
| 1.14 | **Capacitação** | Treinamentos, certificações, registros | ✅ Sim | Decreto 9.991/19 |
| 1.15 | **Portal do Servidor** | Autoatendimento, contracheque, férias, dados | ✅ Sim | Modernização |
| 1.16 | **Processos Administrativos** | PAD, sindicância, workflows | ✅ Sim | Lei 8.112 Art. 148 |
| 1.17 | **Ponto Eletrônico** | Marcação, apuração, banco de horas | ✅ Sim (Premium) | Portaria MTE 671/21 |
| 1.18 | **Saúde Ocupacional** | ASO, PCMSO, PPRA, laudos | ✅ Sim | eSocial S-2220 (NR-7) |
| 1.19 | **Contracheque Digital** | PDF, envio email, assinatura digital | Incluso no Portal | LAI / Transparência |

> **Status atual:** 1.1–1.10, 1.15, 1.16 já possuem entidades/controllers. 1.11–1.14, 1.17–1.18 são planejados.

---

### MÓDULO 2: eFolha — Folha de Pagamento (✅ Integrado no eRH)

**Nota:** Embora hoje dentro do eRH, a Folha pode ser extraída como módulo independente para venda separada a municípios que já possuem RH de outro fornecedor.

**Obrigações legais:** eSocial S-1200 (remuneração), S-1210 (pagamentos), S-1299 (fechamento), S-5001/S-5002 (totalizadores). Envio **obrigatório mensal** ao Governo Federal.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 2.1 | **Motor de Cálculo** | Engine de processamento com regras parametrizáveis | CLT + Estatutos |
| 2.2 | **Rubricas** | Cadastro de vantagens/descontos, incidências, fórmulas | eSocial tabela 03 |
| 2.3 | **Processamento Mensal** | Folha normal, complementar, suplementar | eSocial S-1200 |
| 2.4 | **13° Salário** | 1ª e 2ª parcelas, memória de cálculo | CF/88 Art. 7°, VIII |
| 2.5 | **Férias (cálculo)** | Cálculo de férias, antecipação, abono | CLT Art. 129-153 |
| 2.6 | **Rescisão (cálculo)** | Cálculos rescisórios, verbas | CLT Art. 477 |
| 2.7 | **IRRF Progressivo** | Cálculo com faixas, deduções, isenções | RFB IN 1500/14 |
| 2.8 | **RPPS/INSS** | Contribuições previdenciárias, alíquotas progressivas | EC 103/2019 |
| 2.9 | **Exportação Bancária** | CNAB 240/400, remessas, retornos | FEBRABAN |
| 2.10 | **Relatórios de Folha** | Resumo, analítico, comparativo, por lotação | TCE |

---

### MÓDULO 3: eFrotas — Gestão de Frotas (✅ EM ANDAMENTO)

**Secretaria:** Transporte / Administração  
**Justificativa:** Gasto com frota é tipicamente 3-8% do orçamento municipal. Sistema de controle reduz 15-30% do custo com combustível. ROI em 3-6 meses.

| # | Microserviço | Descrição | Comercializ. Separada? |
|---|---|---|---|
| 3.1 | **Cadastro de Frota** | Veículos, motoristas, documentação | Base obrigatória |
| 3.2 | **Abastecimento** | Postos, combustíveis, requisições, controle km | ✅ Sim |
| 3.3 | **Manutenção** | Preventiva, corretiva, peças, oficinas | ✅ Sim |
| 3.4 | **Viagens e Deslocamentos** | Diário de bordo, quilometragem, rotas | ✅ Sim |
| 3.5 | **Transporte Escolar** | Rotas escolares, alunos, contratos, fiscalização | ✅ Sim (Premium) |
| 3.6 | **Contratos e Locação** | Veículos locados, terceirizados | ✅ Sim |
| 3.7 | **Multas e Infrações** | Controle de multas, responsabilização, recurso | ✅ Sim |
| 3.8 | **Inspeções e Vistorias** | Checklist, agendamento, conformidade | ✅ Sim |
| 3.9 | **Agendamento** | Reserva de veículos, aprovações | Incluso na base |
| 3.10 | **Relatórios e BI** | Custo/km, consumo, TCO, dashboards | ✅ Sim |

---

### MÓDULO 4: eContábil — Contabilidade Pública (📋 PLANEJADO)

**Secretaria:** Fazenda / Finanças  
**Obrigações legais:** SICONFI (STN), RREO (bimestral), RGF (quadrimestral), LRF (LC 101/2000), SIAFIC (Decreto 10.540/20), MCASP (Manual de Contabilidade Aplicada ao Setor Público)

**Justificativa:** O SICONFI é o sistema do Tesouro Nacional para envio obrigatório de dados contábeis. Município que não envia tem **transferências voluntárias suspensas** (FPM, convênios). O Decreto 10.540/2020 (SIAFIC) obriga todos os municípios a ter sistema único de contabilidade integrado até 2024.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 4.1 | **Plano de Contas (PCASP)** | Estrutura contábil conforme STN | MCASP 9ª ed. |
| 4.2 | **Execução Orçamentária** | Empenho, liquidação, pagamento, anulações | Lei 4.320/64 |
| 4.3 | **Receita** | Previsão, arrecadação, classificação | LOA |
| 4.4 | **Orçamento (LOA/LDO/PPA)** | Planejamento orçamentário plurianual | CF/88 Art. 165 |
| 4.5 | **Créditos Adicionais** | Suplementar, especial, extraordinário | Lei 4.320 Art. 40-46 |
| 4.6 | **Tesouraria** | Contas bancárias, conciliação, fluxo caixa | LRF Art. 50 |
| 4.7 | **Restos a Pagar** | Processados e não processados | Lei 4.320 Art. 36 |
| 4.8 | **Prestação de Contas** | RREO, RGF, balanços, SICONFI | LRF Art. 52-55 |
| 4.9 | **Diário e Razão** | Livros contábeis obrigatórios | Lei 4.320 Art. 93-100 |
| 4.10 | **Convênios** | Transferências, prestação de contas | Decreto 6.170/07 |

---

### MÓDULO 5: eLicit — Compras e Licitações (📋 PLANEJADO)

**Secretaria:** Compras / Administração  
**Obrigações legais:** Lei 14.133/2021 (Nova Lei de Licitações), PNCP (Portal Nacional de Contratações Públicas)

**Justificativa:** A Lei 14.133/2021 obriga TODOS os entes públicos a publicarem no PNCP editais, atas e contratos. O PNCP é administrado pelo Comitê Gestor da Rede Nacional de Contratações Públicas e garante centralização de dados de todas as contratações (União, Estados e Municípios). Sistemas devem integrar-se via API REST ao PNCP.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 5.1 | **Catálogo de Itens** | Materiais, serviços, CATMAT/CATSER | PNCP |
| 5.2 | **Requisições de Compra** | Solicitações, aprovações, workflows | Lei 14.133 Art. 18 |
| 5.3 | **Processos Licitatórios** | Pregão, concorrência, dispensa, inexigibilidade | Lei 14.133 Art. 28 |
| 5.4 | **Pregão Eletrônico** | Integração PNCP, lances, adjudicação | Lei 14.133 Art. 6° |
| 5.5 | **Atas de Registro de Preço** | SRP, adesão, gerenciamento | Lei 14.133 Art. 82-86 |
| 5.6 | **Contratos** | Gestão de contratos, aditivos, fiscalização | Lei 14.133 Art. 89-154 |
| 5.7 | **Fornecedores** | Cadastro, habilitação, certidões, sanções | SICAF, CEIS, CNEP |
| 5.8 | **Cotação de Preços** | Pesquisa de mercado, banco de preços | Lei 14.133 Art. 23 |
| 5.9 | **Integração PNCP** | Portal Nacional de Contratações Públicas | Lei 14.133 Art. 174 |
| 5.10 | **Relatórios** | Economicidade, tempo médio, ranking | TCE |

---

### MÓDULO 6: eTributos — Tributos Municipais (📋 PLANEJADO)

**Secretaria:** Fazenda / Receita  
**Obrigações legais:** CTN (Código Tributário Nacional), Lei Orgânica Municipal, Código Tributário Municipal

**Justificativa:** Tributos próprios (IPTU, ISS, ITBI) representam a receita própria do município. IPTU é a principal receita tributária de municípios pequenos. ISS é fundamental em municípios com setor de serviços. Padrão Nacional da NFS-e foi instituído pela RFB com layout ABRASF, exigindo integração.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 6.1 | **IPTU** | Cadastro imobiliário, lançamento, cálculo, DAM | CTN Art. 32-34 |
| 6.2 | **ISS** | Imposto sobre serviços, alíquotas, retenção | LC 116/2003 |
| 6.3 | **ITBI** | Transmissão de bens imóveis, avaliação, guia | CTN Art. 35-42 |
| 6.4 | **Taxas e Contribuições** | Taxa de lixo, iluminação, melhorias | CTN Art. 77-82 |
| 6.5 | **Dívida Ativa** | Inscrição, controle, protesto, parcelamento | CTN Art. 201-204 |
| 6.6 | **Arrecadação** | Guias (DAM/DUAM), baixa, conciliação | Código Tributário Municipal |
| 6.7 | **Fiscalização Tributária** | Auto de infração, processos fiscais | CTN Art. 194-200 |
| 6.8 | **NFS-e** | Emissão, consulta, relatórios, ABRASF | Padrão Nacional NFSe (RFB) |
| 6.9 | **Simples Nacional** | DAS, PGDAS-D, DASN, controle | LC 123/2006 |
| 6.10 | **Cadastro Econômico** | Empresas, MEI, autônomos, CNAE | Código Tributário Municipal |

---

### MÓDULO 7: ePatrimônio — Bens Patrimoniais (📋 PLANEJADO)

**Secretaria:** Administração / Patrimônio  
**Obrigações legais:** TCE (envio anual de inventário), MCASP (depreciação/amortização obrigatória), NBCASPs

**Justificativa:** Desde a convergência às normas internacionais de contabilidade pública (IPSAS/NBCASPs), municípios são obrigados a depreciar bens e manter registros analíticos. TCE exige inventário anual.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 7.1 | **Cadastro de Bens** | Móveis, imóveis, veículos, intangíveis | MCASP / NBCASPs |
| 7.2 | **Tombamento** | Numeração, etiquetas, QR Code, fotos | Decreto interno |
| 7.3 | **Movimentação** | Transferências entre setores/responsáveis | Decreto interno |
| 7.4 | **Inventário** | Conferência, levantamento, comissão | TCE (anual) |
| 7.5 | **Depreciação/Amortização** | Cálculo automático conforme PCASP | NBC T 16.9 |
| 7.6 | **Baixa** | Doação, leilão, inservibilidade, sinistro | Lei 14.133 Art. 76 |
| 7.7 | **Imóveis** | Terrenos, prédios, cessões, ocupações | Código Civil |
| 7.8 | **Relatórios TCE** | Exportações obrigatórias para Tribunal | Resolução TCE |

---

### MÓDULO 8: eProtocolo — Gestão de Documentos (📋 PLANEJADO)

**Justificativa:** Tramitação de processos administrativos é obrigatória. Digitalização reduz papel e permite rastreamento. Assinatura digital via Gov.br (ICP-Brasil) é reconhecida legalmente (MP 2.200-2/2001).

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 8.1 | **Protocolo Geral** | Abertura, tramitação, arquivamento | Lei 9.784/99 |
| 8.2 | **Workflow de Documentos** | Fluxos configuráveis de aprovação | Decreto interno |
| 8.3 | **GED (Gestão Eletrônica)** | Digitalização, OCR, indexação | Decreto 10.278/20 |
| 8.4 | **Assinatura Digital** | Integração Gov.br, ICP-Brasil, carimbo tempo | MP 2.200-2/2001 |
| 8.5 | **Diário Oficial** | Publicação, edições, consulta pública | Lei Orgânica |

---

### MÓDULO 9: eTransparência — Portal de Transparência (📋 PLANEJADO)

**OBRIGATÓRIO:** Lei 12.527/2011 (LAI — Lei de Acesso à Informação) — Todo município DEVE ter portal de transparência ativa.

**Justificativa:** A LAI obriga todos os entes públicos a publicar informações de interesse coletivo independentemente de solicitação. O descumprimento configura infração administrativa (Art. 33). O TCE de cada estado fiscaliza a existência e completude do portal.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 9.1 | **Portal Público** | Site de transparência com busca | LAI Art. 8° |
| 9.2 | **Receitas e Despesas** | Dados orçamentários em tempo real | LRF Art. 48 |
| 9.3 | **Pessoal** | Remuneração de servidores | LAI + STF RE 652.777 |
| 9.4 | **Licitações e Contratos** | Processos e contratos publicados | Lei 14.133 + LAI |
| 9.5 | **LAI (e-SIC)** | Pedidos de acesso à informação | LAI Art. 10-14 |
| 9.6 | **Dados Abertos** | API pública, formatos CSV/JSON/XML | Decreto 8.777/16 |

---

### MÓDULO 10: eAlmoxarifado — Controle de Estoque (📋 PLANEJADO)

**Justificativa:** TCE exige controle de entrada/saída de materiais. Sem sistema, município não comprova uso regular dos materiais adquiridos via licitação.

| # | Microserviço | Descrição |
|---|---|---|
| 10.1 | **Cadastro de Materiais** | Catálogo, unidades, grupos |
| 10.2 | **Entrada** | Notas fiscais, conferência, lançamento |
| 10.3 | **Saída** | Requisições, distribuição por setor |
| 10.4 | **Inventário** | Contagem, ajustes, valoração |
| 10.5 | **Ponto de Pedido** | Estoque mínimo, alertas automáticos |

---

### MÓDULO 11: eContratos — Gestão de Contratos (📋 PLANEJADO)

**Obrigações legais:** Lei 14.133/2021. O PNCP exige publicação de contratos e alterações. O governo federal mantém o sistema Contratos Gov.br integrado ao PNCP.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 11.1 | **Cadastro de Contratos** | Dados, vigência, valores, partes | Lei 14.133 Art. 89 |
| 11.2 | **Aditivos** | Prorrogação, acréscimo, supressão, reequilíbrio | Lei 14.133 Art. 124 |
| 11.3 | **Fiscalização** | Fiscal do contrato, medições, ateste | Lei 14.133 Art. 117 |
| 11.4 | **Garantias** | Caução, seguro, fiança | Lei 14.133 Art. 96-102 |
| 11.5 | **Penalidades** | Advertência, multa, suspensão, inidoneidade | Lei 14.133 Art. 155-163 |
| 11.6 | **Alertas** | Vencimento, renovação, aditivos necessários | Gestão |

---

### MÓDULO 12: eObras — Obras Públicas (📋 FUTURO)

**Secretaria:** Obras / Infraestrutura  
**Obrigações legais:** TCE (acompanhamento de obras), Lei 14.133/2021. O governo federal mantém o Sistema de Acompanhamento de Obras (CIPI) integrado ao PNCP.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 12.1 | **Cadastro de Obras** | Projeto, localização, responsáveis | Lei 14.133 Art. 46 |
| 12.2 | **Orçamento de Obra** | BDI, composições, SINAPI, planilha | SINAPI/CAIXA |
| 12.3 | **Medições** | Cronograma, boletins, % executado | Lei 14.133 Art. 46 §3° |
| 12.4 | **Fiscalização** | Diário de obra, apontamentos, fotos | CONFEA/CREA |
| 12.5 | **Acompanhamento** | Timeline, geolocalização, dashboard | TCE |

---

### MÓDULO 13: eSaúde — Gestão de Saúde (📋 FUTURO)

**Secretaria:** Saúde  
**Obrigações legais:** SUS (Lei 8.080/90), e-SUS AB (Atenção Básica), CNES, BPA, SIGTAP

**Justificativa:** O Ministério da Saúde exige envio mensal de dados ao DataSUS via e-SUS AB. Municípios que não enviam perdem repasses fundo a fundo (PAB fixo + variável). O e-SUS AB é obrigatório para unidades de atenção básica desde 2018.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 13.1 | **Prontuário Eletrônico (PEP)** | Prontuário digital do paciente | Resolução CFM 1.638/02 |
| 13.2 | **Agendamento** | Marcação de consultas, fila de espera | PNAB |
| 13.3 | **Farmácia** | Controle de medicamentos, dispensação | RENAME, Portaria MS |
| 13.4 | **Regulação** | Regulação de leitos, TFD, procedimentos | Portaria MS 399/06 |
| 13.5 | **Vigilância Sanitária** | Licenças, inspeções, autuações | Lei 9.782/99 |
| 13.6 | **e-SUS AB** | Atenção Básica, ACS, CDS, PEC | Portaria MS 1.412/13 |
| 13.7 | **Vacinação** | Campanhas, caderneta, rede frio | PNI / SI-PNI |
| 13.8 | **Faturamento SUS** | BPA, AIH, APAC, SIA | SUS / DataSUS |

---

### MÓDULO 14: eEducação — Gestão Educacional (📋 FUTURO)

**Secretaria:** Educação  
**Obrigações legais:** LDB (Lei 9.394/96), Censo Escolar (INEP), FUNDEB (EC 108/2020), PNAE, PDDE

**Justificativa:** O Censo Escolar é base para cálculo dos coeficientes de distribuição do FUNDEB — maior transferência educacional do país. Dado incorreto = perda de recursos. PNAE (merenda escolar) exige controle de estoque e nutrição.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 14.1 | **Matrícula Online** | Inscrição, sorteio, remanejamento | LDB Art. 5° |
| 14.2 | **Gestão Escolar** | Alunos, turmas, professores, calendário | LDB Art. 24 |
| 14.3 | **Diário de Classe** | Frequência, notas, conteúdo | LDB Art. 24, V |
| 14.4 | **Merenda Escolar (PNAE)** | Cardápio, estoque, nutrição | Lei 11.947/09 |
| 14.5 | **Transporte Escolar** | ⚡ Integração com eFrotas (3.5) | PNATE |
| 14.6 | **Censo Escolar** | Exportação para INEP | Decreto 6.425/08 |
| 14.7 | **FUNDEB** | Controle de recursos, prestação | EC 108/2020 |
| 14.8 | **Boletim Online** | Portal do aluno/responsável | Modernização |

---

### MÓDULO 15: eAssistência — Assistência Social (📋 FUTURO)

**Secretaria:** Assistência Social  
**Obrigações legais:** SUAS (Lei 8.742/93 — LOAS), CadÚnico, CRAS, CREAS, MDS

**Justificativa:** O SUAS é o sistema descentralizado e participativo que organiza a assistência social no Brasil. O governo federal (MDS) repassa recursos via Fundo Nacional de Assistência Social (FNAS) condicionados ao registro no Censo SUAS e manutenção de dados no CadÚnico. CRAS e CREAS são equipamentos obrigatórios em municípios acima de 20 mil habitantes.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 15.1 | **Cadastro de Famílias** | CadÚnico integrado, NIS | Decreto 6.135/07 |
| 15.2 | **Benefícios** | Programas municipais, BPC, auxílios | LOAS Art. 20-21 |
| 15.3 | **CRAS/CREAS** | Atendimentos, encaminhamentos, PAIF/PAEFI | PNAS 2004 |
| 15.4 | **Conselhos Tutelares** | Atendimentos, medidas protetivas | ECA (Lei 8.069/90) |
| 15.5 | **Programas Sociais** | Cadastro, elegibilidade, acompanhamento | Lei municipal |

---

### MÓDULO 16: eMeioAmbiente — Meio Ambiente (📋 FUTURO)

**Obrigações legais:** CONAMA, Código Florestal (Lei 12.651/12), licenciamento ambiental municipal (LC 140/2011)

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 16.1 | **Licenciamento Ambiental** | LP, LI, LO, condicionantes | LC 140/2011 |
| 16.2 | **Fiscalização** | Denúncias, autos, multas | Lei 9.605/98 |
| 16.3 | **Árvores Urbanas** | Supressão, poda, compensação | Lei municipal |
| 16.4 | **Coleta Seletiva** | Rotas, cooperativas, indicadores | PNRS (Lei 12.305/10) |

---

### MÓDULO 17: eUrbano — Planejamento Urbano (📋 FUTURO)

**Obrigações legais:** Estatuto da Cidade (Lei 10.257/01) — Plano Diretor obrigatório para municípios > 20 mil hab.

| # | Microserviço | Descrição | Base Legal |
|---|---|---|---|
| 17.1 | **Alvará** | Construção, funcionamento, sanitário | Código de Obras |
| 17.2 | **Habite-se** | Auto de conclusão, vistorias | Código de Obras |
| 17.3 | **Posturas** | Fiscalização urbana, notificações | Código de Posturas |
| 17.4 | **Geoprocessamento** | Mapas, lotes, zoneamento, SIG (PostGIS) | Plano Diretor |

---

### MÓDULOS 18–25: Demais Sistemas

| Módulo | Secretaria | Microserviços Principais | Base Legal |
|---|---|---|---|
| **18. eAgro** | Agricultura | Cadastro rural, assistência técnica, feiras, inspeção animal/vegetal | Lei municipal |
| **19. eOuvidoria** | Cidadão | Registro, SLA, categorização, relatórios, integração e-SIC | LAI Art. 10 |
| **20. eCidadão (App)** | Cidadão | Serviços online, protocolo digital, 2ª via, agenda, mapa da cidade | Modernização |
| **21. ePortal** | Comunicação | CMS, notícias, agenda, servidores, legislação, diário oficial | LAI Art. 8° |
| **22. eCâmara** | Legislativo | Projetos de lei, votação, pauta, atas, transmissão ao vivo | Regimento Interno |
| **23. eGabinete** | Executivo | Agenda, demandas, indicações, ofícios, despachos | Lei Orgânica |
| **24. eFiscal** | Fazenda | Autos de infração tributários, processos fiscais, julgamento | CTN Art. 194-200 |
| **25. eNFSe** | Fazenda | Emissão NFS-e, consulta, livro eletrônico, substituição | Padrão Nacional NFSe |

---

## 5. Modelo de Comercialização por Módulo/Serviço

### 5.1 Estratégia de Precificação

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                    MODELO DE NEGÓCIO — SaaS POR MÓDULO                       │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PLANO BASE (obrigatório para qualquer módulo):                              │
│  ┌────────────────────────────────────────────────────────────┐              │
│  │  ✅ Common (Auth, Multi-tenant, Auditoria)                 │              │
│  │  ✅ API Gateway                                            │              │
│  │  ✅ Frontend Shell (menu, tema, login)                     │              │
│  │  ✅ Portal de Transparência (básico — obrigatório por lei) │              │
│  │  📊 Dashboard gerencial                                    │              │
│  └────────────────────────────────────────────────────────────┘              │
│                                                                              │
│  MÓDULOS CONTRATÁVEIS (individualmente ou em pacotes):                       │
│  ┌───────────────────────────────────────────────────────────┐               │
│  │                                                           │               │
│  │  PACOTE ADMINISTRAÇÃO    │  PACOTE FAZENDA                │               │
│  │  ─────────────────────── │  ──────────────────            │               │
│  │  • eRH (base)            │  • eContábil                   │               │
│  │  • eFolha                │  • eTributos                   │               │
│  │  • ePatrimônio           │  • eNFSe                       │               │
│  │  • eProtocolo            │  • eFiscal                     │               │
│  │  • eAlmoxarifado         │  • eArrecadação                │               │
│  │                          │                                │               │
│  │  PACOTE OPERACIONAL      │  PACOTE SOCIAL                 │               │
│  │  ─────────────────────── │  ──────────────────            │               │
│  │  • eFrotas               │  • eSaúde                      │               │
│  │  • eObras                │  • eEducação                   │               │
│  │  • eContratos            │  • eAssistência                │               │
│  │  • eLicit                │  • eMeioAmbiente               │               │
│  │                          │                                │               │
│  │  PACOTE CIDADÃO          │  ADD-ONS PREMIUM               │               │
│  │  ─────────────────────── │  ──────────────────            │               │
│  │  • eCidadão (App)        │  • Ponto Eletrônico            │               │
│  │  • eOuvidoria            │  • Transp. Escolar             │               │
│  │  • ePortal               │  • Pregão Eletrônico           │               │
│  │  • eTransparência (full) │  • BI/Analytics                │               │
│  │                          │  • App Mobile Custom           │               │
│  └───────────────────────────────────────────────────────────┘               │
│                                                                              │
│  FAIXAS DE PREÇO (por módulo, baseado em habitantes):                        │
│  ┌───────────────────────────────────────────────────────────┐               │
│  │  Até 10k hab        │  Módulo a partir de R$ 500/mês      │               │
│  │  10k-50k hab        │  Módulo a partir de R$ 1.200/mês    │               │
│  │  50k-100k hab       │  Módulo a partir de R$ 2.500/mês    │               │
│  │  100k-500k hab      │  Módulo a partir de R$ 5.000/mês    │               │
│  │  500k+ hab          │  Negociação personalizada            │               │
│  └───────────────────────────────────────────────────────────┘               │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Feature Flags para Licenciamento

```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresModule {
    String value(); // ex: "ERH_FERIAS"
}

@Aspect @Component
public class ModuleLicenseAspect {
    @Around("@annotation(req)")
    public Object check(ProceedingJoinPoint jp, RequiresModule req) {
        if (!licenseService.isEnabled(getCurrentTenant(), req.value()))
            throw new ModuleNotLicensedException(req.value());
        return jp.proceed();
    }
}
```

### 5.3 Licenciamento SQL

```sql
CREATE TABLE tenant_module_license (
    id BIGSERIAL PRIMARY KEY,
    unidade_gestora_id BIGINT REFERENCES unidade_gestora(id),
    module_code VARCHAR(50) NOT NULL,   -- ex: 'ERH_FERIAS', 'FROTAS_MANUTENCAO'
    enabled BOOLEAN DEFAULT FALSE,
    start_date DATE NOT NULL,
    end_date DATE,
    max_users INTEGER,
    UNIQUE(unidade_gestora_id, module_code)
);
```

---

## 6. Arquitetura Alvo do Ecossistema (Blueprint Técnico)

### 6.1 Visão da Arquitetura Completa (2028+)

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                          │
│                              CLIENTES                                                    │
│          ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐                      │
│          │  Browser  │   │  Mobile  │   │  Desktop │   │ APIs Ext │                      │
│          └────┬─────┘   └────┬─────┘   └────┬─────┘   └────┬─────┘                      │
│               │              │              │              │                              │
│          ┌────▼──────────────▼──────────────▼──────────────▼─────┐                       │
│          │                   CDN / WAF / DDoS                     │                       │
│          │               (Cloudflare / AWS Shield)                │                       │
│          └──────────────────────┬────────────────────────────────┘                       │
│                                 │                                                        │
│  ┌──────────────────────────────▼──────────────────────────────────────┐                 │
│  │                       INGRESS / LOAD BALANCER                       │                 │
│  │                     (Traefik / Nginx / K8s Ingress)                 │                 │
│  └──────────┬──────────────────────────────────────────┬──────────────┘                 │
│             │                                          │                                 │
│   ┌─────────▼─────────┐                     ┌──────────▼──────────┐                     │
│   │  FRONTEND SHELL   │                     │    API GATEWAY      │                     │
│   │  (Next.js / MFE)  │                     │  (Spring Cloud GW)  │                     │
│   │                   │                     │                     │                     │
│   │ ┌──────┐ ┌──────┐ │                     │ • Rate Limiting     │                     │
│   │ │eRH UI│ │eFrot│ │                     │ • Auth Forwarding   │                     │
│   │ │      │ │as UI│ │                     │ • Circuit Breaker   │                     │
│   │ ├──────┤ ├──────┤ │                     │ • Request Logging   │                     │
│   │ │eCont │ │eLici│ │                     │ • API Versioning    │                     │
│   │ │ab UI │ │t UI │ │                     │ • CORS              │                     │
│   │ └──────┘ └──────┘ │                     └──────────┬──────────┘                     │
│   └───────────────────┘                                │                                 │
│                                                        │                                 │
│   ┌────────────────────────────────────────────────────▼─────────────────────────────┐  │
│   │                          SERVICE MESH / DISCOVERY                                 │  │
│   │                      (Eureka / Consul / K8s Services)                             │  │
│   └────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┬─────────────┘  │
│        │      │      │      │      │      │      │      │      │      │                  │
│   ┌────▼──┐┌──▼───┐┌─▼────┐┌▼─────┐┌▼─────┐┌▼─────┐┌▼─────┐┌▼─────┐┌▼─────┐           │
│   │Common ││eRH   ││eFolha││eFrota││eContab││eLicit││eTribu││ePatri││eProto│...        │
│   │Service││Servic││Servi ││s Serv││il Serv││Servi ││tos Se││mônio ││colo  │           │
│   │       ││e     ││ce    ││ice   ││ice    ││ce    ││rvice ││Servic││Servi │           │
│   └───┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘└──┬───┘           │
│       │       │       │       │       │       │       │       │       │                  │
│   ┌───▼───────▼───────▼───────▼───────▼───────▼───────▼───────▼───────▼──────────────┐  │
│   │                           MESSAGE BROKER                                          │  │
│   │                       (RabbitMQ ou Apache Kafka)                                  │  │
│   │                                                                                   │  │
│   │  Exchanges:  ws.rh  |  ws.frotas  |  ws.contabil  |  ws.licit  |  ws.geral       │  │
│   └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                          │
│   ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│   │                           CAMADA DE DADOS                                         │  │
│   │                                                                                   │  │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌─────────────────┐  │  │
│   │  │PostgreSQL│  │  Redis   │  │MinIO/S3  │  │Elasticsearch│  │  TimescaleDB   │  │  │
│   │  │(schemas) │  │(cache/   │  │(arquivos/│  │(search/     │  │  (métricas/    │  │  │
│   │  │          │  │ sessão)  │  │ docs)    │  │  logs)      │  │   séries)      │  │  │
│   │  └──────────┘  └──────────┘  └──────────┘  └────────────┘  └─────────────────┘  │  │
│   └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                          │
│   ┌──────────────────────────────────────────────────────────────────────────────────┐  │
│   │                         OBSERVABILIDADE                                           │  │
│   │                                                                                   │  │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐   │  │
│   │  │Prometheus│  │ Grafana  │  │  Loki    │  │  Tempo   │  │  AlertManager    │   │  │
│   │  │(métricas)│  │(dashbord)│  │  (logs)  │  │ (traces) │  │  (alertas)       │   │  │
│   │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘   │  │
│   └──────────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                          │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Serviços de Infraestrutura (Core)

| Serviço | Porta | Descrição | Status |
|---------|:-----:|-----------|--------|
| **Service Discovery** | 9876 | Registro e descoberta de serviços (Eureka) | ✅ Funcional |
| **API Gateway** | 9080 | Roteamento, auth, rate-limit, circuit breaker | ✅ Funcional |
| **Common Service** | 9081 | Auth JWT, RBAC, multi-tenancy, entidades base | ✅ Funcional |
| **Notification Service** | 9084 | Email, SMS, push, WhatsApp | 📋 Planejado |
| **File Storage Service** | 9085 | Upload/download MinIO/S3, assinatura digital | 📋 Planejado |
| **Report Service** | 9086 | Geração PDF/Excel (JasperReports/OpenPDF) | 📋 Planejado |
| **Audit Service** | 9087 | Trilha de auditoria imutável | 📋 Planejado |
| **Integration Service** | 9088 | Adaptadores: eSocial, SICONFI, PNCP, e-SUS | 📋 Planejado |

---

## 7. Estratégia de Dados e Integração

### 7.1 Schema-per-Service

```
PostgreSQL Server (srv752535.hstgr.cloud:5432)
├── Schema: common    → common-service
├── Schema: erh       → erh-service (✅ já existe)
├── Schema: frotas    → frotas-service
├── Schema: contabil  → contabilidade-service
├── Schema: licit     → licitacao-service
├── Schema: tributos  → tributos-service
├── Schema: patrimonio → patrimonio-service
├── Schema: protocolo → protocolo-service
└── Schema: (outros)  → conforme novos módulos
```

**Regra:** Um serviço NUNCA acessa banco de outro. Sempre via API ou Evento.

### 7.2 Grafo de Dependências — Integrações via Eventos

```
                         ┌──────────────┐
                         │   COMMON     │
                         │ (Base p/tudo)│
                         └──────┬───────┘
                                │
        ┌───────────┬───────────┼───────────┬───────────┬──────────┐
        │           │           │           │           │          │
   ┌────▼────┐ ┌────▼────┐ ┌───▼───┐ ┌─────▼────┐ ┌───▼────┐ ┌──▼───┐
   │  eRH    │ │eFrotas  │ │eContab│ │eLicitação│ │eTributo│ │eProto│
   │/eFolha  │ │         │ │       │ │          │ │        │ │colo  │
   └──┬───┬──┘ └──┬──┬───┘ └─┬──┬──┘ └──┬───┬──┘ └──┬──┬──┘ └──┬───┘
      │   │       │  │       │  │       │   │       │  │       │
      │   │       │  │       │  │       │   │       │  │       │
      │   ▼       │  │       │  ▼       │   ▼       │  │       │
      │  ┌────────┘  │       │ ┌────────┘  ┌────────┘  │       │
      │  │           │       │ │           │           │       │
      ▼  ▼           ▼       ▼ ▼           ▼           ▼       │
   ┌──────────────────────────────────────────────────────────────┐
   │              BARRAMENTO DE EVENTOS (RabbitMQ)                │
   └──────────────────────────────────────────────────────────────┘
      │           │           │           │           │          │
      ▼           ▼           ▼           ▼           ▼          ▼
   ┌──────┐  ┌───────┐  ┌────────┐  ┌────────┐  ┌───────┐  ┌───────┐
   │ePatri│  │eAlmox │  │eObras  │  │eContra │  │eNFSe  │  │eTransp│
   │mônio │  │arifado│  │        │  │tos     │  │       │  │arência│
   └──────┘  └───────┘  └────────┘  └────────┘  └───────┘  └───────┘
```

### 7.3 Eventos Principais entre Módulos

| Evento | Produtor | Consumidores | Tipo |
|---|---|---|---|
| `servidor.admitido` | eRH | eFolha, eProtocolo, Portal Servidor | Domain Event |
| `servidor.desligado` | eRH | eFolha, ePatrimônio (baixa responsável), eFrotas (revoga motorista) | Domain Event |
| `folha.processada` | eFolha | eContábil (empenho automático), eTransparência, Portal Servidor | Integration Event |
| `empenho.emitido` | eContábil | eLicit (vincula processo), eContratos | Integration Event |
| `licitacao.homologada` | eLicit | eContratos (gera contrato), eAlmoxarifado (ARP) | Domain Event |
| `contrato.vencendo` | eContratos | eNotificação, eLicit (nova licitação) | Alert Event |
| `patrimonio.transferido` | ePatrimônio | eProtocolo (termo), eRH (novo responsável) | Domain Event |
| `veiculo.manutencao` | eFrotas | eAlmoxarifado (peças), eContratos (oficina) | Integration Event |
| `tributo.arrecadado` | eTributos | eContábil (receita), eTransparência | Integration Event |
| `obra.medicao` | eObras | eContábil (liquidação), eContratos | Integration Event |

### 7.4 Multi-Tenancy Evolution

```
2026: Discriminator Column  (< 50 tenants)
2027: Schema-per-Tenant     (50-200 tenants)
2029: Database-per-Tenant   (> 500 / SLA enterprise)
```

---

## 8. Análise Competitiva

### 8.1 Pesquisa de Mercado

| Aspecto | **IPM Sistemas** | **Betha Sistemas** | **WS-Services** |
|---------|-----------------|-------------------|----------------|
| **Clientes** | 850+ municípios, 5 estados | Centenas de municípios | Fase inicial |
| **Modelo** | Cloud + On-premise | SaaS Cloud | SaaS Cloud nativo |
| **Stack** | Proprietária | Proprietária (migrada p/ cloud) | Open Source (Java + Next.js) |
| **Módulos** | Prefeitura, Saúde, Educação, Social, Fintech | Contábil, Contratos, Arrecadação, Pessoal, NoPaper, Educação, Saúde | eRH, eFrotas + planejados |
| **IA** | ✅ Assistente IA | ✅ ML, IoT, Big Data, AI | 📋 Roadmap 2030 |
| **UX** | Legada (modernizando) | Em transição | **✅ Moderna desde o dia 1** |
| **Preço** | $$$ | $$$ | $$ (competitivo para pequenos) |

### 8.2 Vantagem Competitiva

| Vantagem | Detalhe |
|----------|---------|
| **Cloud-native desde o dia 1** | Concorrentes migraram legado — carregam tech debt |
| **UX moderna** | Servidores públicos acostumados com UIs dos anos 2000 |
| **Preço agressivo** | Sem Oracle/Microsoft → 30-50% menos para municípios pequenos |
| **Modularidade real** | Feature flags → prefeitura compra só o que precisa |
| **Open standards** | PostgreSQL, Spring Boot, OpenAPI → sem vendor lock-in |
| **API-first** | Toda funcionalidade via REST documentada → integrações fáceis |

### 8.3 Ameaças e Respostas

| Ameaça | Resposta |
|--------|---------|
| IPM com 850+ clientes e presença em 5 estados | Focar em municípios < 50k hab. que não podem pagar IPM |
| Betha oferece IA/IoT/ML | Ganhar no básico bem feito. IA é roadmap 2030 |
| Equipes de vendas nacionais dos concorrentes | Canal de parceiros (contadores, consultores) até ter equipe própria |
| Governo Federal pode criar sistema público gratuito | Foco em experiência e suporte — sistemas públicos são genéricos demais |

---

## 9. Roadmap de Implementação 2026–2030

```
2026 ─── FUNDAÇÃO E PRIMEIROS CLIENTES
├── Q1 ✅ ATUAL: eRH Folha (13º, Férias, Rescisão, RPPS) + Separar DBs + CI/CD
├── Q2: TCE + eSocial funcional + Portal Servidor v1 + eFrotas APIs + RabbitMQ
│       🎯 MARCO: Primeiro cliente piloto
├── Q3: Férias/Afastamentos completo + eTransparência v1 + Observabilidade
└── Q4: eContábil início + Integração eRH↔eContábil (Saga: folha→empenho)
        🎯 MARCO: 3-5 clientes pagantes

2027 ─── EXPANSÃO CORE
├── H1: eContábil completa (PCASP, LOA, SICONFI) + eLicit (Lei 14.133) + Integração PNCP
├── H2: ePatrimônio + eAlmoxarifado + eContratos + eTributos início
└── 🎯 MARCO: 10-15 clientes, MRR R$ 50K+

2028 ─── RECEITA/TRIBUTOS + CIDADÃO
├── H1: eTributos (IPTU/ISS/ITBI/Dívida Ativa) + eNFSe (Padrão Nacional) + Portal Cidadão
├── H2: eProtocolo + Integração bancária (FEBRABAN/PIX) + eContratos completo
└── 🎯 MARCO: 30-50 clientes, MRR R$ 200K+

2029 ─── VERTICAIS SETORIAIS
├── H1: eSaúde (e-SUS AB, prontuário, farmácia) + eEducação (Censo, FUNDEB, PNAE)
├── H2: eAssistência (SUAS, CadÚnico) + eObras + eMeioAmbiente + App Mobile (eCidadão)
└── 🎯 MARCO: 80-100 clientes, MRR R$ 500K+

2030 ─── IA + ESCALA + MARKETPLACE
├── H1: Assistente IA, Chatbot, Detecção de anomalias, NLP para documentos
├── H2: eOuvidoria + eCâmara + eGabinete + eUrbano + eAgro + Marketplace de integrações
└── 🎯 MARCO: 200+ clientes, MRR R$ 1M+
```

---

## 10. Infraestrutura e DevOps

### 10.1 Evolução por Estágio

| Fase | Infra | Custo/mês | Justificativa |
|------|-------|-----------|---------------|
| **2026 H1** | Docker Compose + 1 VPS 16GB | R$ 300-600 | K8s para 3 serviços é overengineering |
| **2026 H2** | 2-3 VPS + Swarm + Redis + RabbitMQ | R$ 1.500-3.000 | Redundância com clientes pagantes |
| **2027** | AWS ECS/Swarm + RDS + ElastiCache | R$ 3.000-8.000 | Managed services reduzem operação |
| **2028+** | Kubernetes (EKS/AKS) | R$ 5.000-15.000 | Auto-scaling para > 30 clientes |

### 10.2 CI/CD Pipeline

```
Push → GitHub Actions → Build (Maven) → Test → SonarQube → Docker Build → Registry → Deploy
                                                     │
                                            ┌────────▼────────┐
                                            │  staging (auto)  │
                                            │  prod (manual)   │
                                            └─────────────────┘
```

---

## 11. Governança, Compliance e Segurança

### 11.1 Compliance por Módulo

| Regulação | Órgão | Módulos | Status |
|-----------|-------|---------|--------|
| eSocial | RFB / MTE | eRH, eFolha | 🔄 Em implementação |
| TCE (AUDESP/SAGRES) | TCE Estadual | eRH, eContab, ePatrim, eLicit | 🔄 Parcial |
| SICONFI | STN (Tesouro Nacional) | eContábil | 📋 Planejado |
| PNCP | Gov Federal | eLicit, eContratos | 📋 Planejado |
| LAI | CGU | eTransparência | 📋 Planejado |
| e-SUS AB | DataSUS / MS | eSaúde | 📋 Futuro |
| Censo Escolar | INEP / MEC | eEducação | 📋 Futuro |
| SUAS / CadÚnico | MDS | eAssistência | 📋 Futuro |
| LGPD | ANPD | TODOS | ⚠️ Pendente |

### 11.2 Segurança

```
✅ JWT RSA (chave pública/privada)
✅ RBAC (Role-Based Access Control)
✅ Multi-tenant isolation (Hibernate Filters)
📋 Refresh tokens + rotação de chaves (Q2 2026)
📋 MFA — Autenticação multifator (Q3 2026)
📋 HTTPS TLS 1.3 + WAF
📋 Criptografia dados sensíveis em repouso (AES-256)
📋 Trilha de auditoria completa (Audit Service)
📋 Pentest anual
📋 LGPD — consentimento, portabilidade, eliminação
```

---

## 12. Riscos e Mitigações

| # | Risco | Prob. | Impacto | Mitigação |
|:-:|-------|:---:|:---:|---------|
| 1 | Complexidade excessiva — 25 módulos | Alta | Crítico | Foco no roadmap. Novo módulo **só com cliente pagante** |
| 2 | Falta de equipe | Alta | Crítico | Contratar incremental. IA para acelerar código |
| 3 | Concorrência (IPM 850+, Betha) | Alta | Alto | UX moderna, preço agressivo, municípios < 50k hab. |
| 4 | Mudanças regulatórias frequentes | Média | Alto | Integration-service com adaptadores plugáveis |
| 5 | Cash flow antes de receita | Alta | Crítico | Vender eRH + eFolha ASAP — produto mínimo viável |
| 6 | Escopo creep (querer fazer tudo de uma vez) | Alta | Alto | TIER 1 antes de TIER 2. P0 antes de P1 |
| 7 | Vendor lock-in cloud | Média | Médio | Docker + PostgreSQL — portável para qualquer cloud |
| 8 | Vazamento de dados multi-tenant | Baixa | Crítico | Testes automatizados com 2+ tenants, auditoria |

---

## 13. Métricas de Sucesso

### 13.1 Métricas de Negócio

| Fase | Clientes | MRR | Módulos Prontos |
|------|:---:|:---:|:---:|
| 2026 H1 | 1 piloto | Validação | eRH + eFolha |
| 2026 H2 | 3-5 | R$ 15K+ | + eFrotas + eTransparência |
| 2027 | 10-15 | R$ 50K+ | + eContábil + eLicit |
| 2028 | 30-50 | R$ 200K+ | + eTributos + eNFSe |
| 2029 | 80-100 | R$ 500K+ | + eSaúde + eEducação |
| 2030 | 200+ | R$ 1M+ | Ecossistema completo |

### 13.2 Métricas Técnicas

| Métrica | 2026 | 2028 | 2030 |
|---------|:---:|:---:|:---:|
| Uptime | 99% | 99.5% | 99.9% |
| Response p95 | < 2s | < 500ms | < 200ms |
| Test coverage | 40% | 70% | 85% |
| Deploy frequency | Semanal | Diário | Múltiplos/dia |
| MTTR (recuperação) | < 4h | < 1h | < 15min |
| Microserviços em produção | 3-5 | 15-20 | 30+ |

---

## 14. Próximos Passos Imediatos (Março–Abril 2026)

```
SEMANA 1-2:
├── [ ] Motor de cálculo INSS/IRRF + RPPS progressivo
├── [ ] Separar common schema do banco frotas
├── [ ] Setup GitHub Actions (build + test + SonarQube)
└── [ ] Criar tenant_module_license (Feature Flags)

SEMANA 3-4:
├── [ ] 13º salário (1ª e 2ª parcela)
├── [ ] Férias (pecuniário + abono + cálculos)
├── [ ] Redis no docker-compose (cache + rate limit)
└── [ ] RabbitMQ no docker-compose (primeiros eventos)

SEMANA 5-6:
├── [ ] Rescisão (verbas rescisórias completas)
├── [ ] Exportação TCE (1 layout do estado alvo)
├── [ ] Portal do Servidor v1 (contracheque + dados)
└── [ ] OpenAPI 3.0 documentation completa

SEMANA 7-8:
├── [ ] Testes de integração (cenários de folha completa)
├── [ ] Ambiente staging/demo (Docker Compose prod)
├── [ ] Material comercial (slides, demo, proposta)
└── [ ] Primeiro contato com prefeitura piloto
```

---

## Resumo Executivo

O **WS-Services** é uma plataforma SaaS de gestão pública municipal que planeja cobrir **25 módulos** com **80+ microserviços**, atendendo todas as secretarias de uma prefeitura brasileira.

**Decisões arquiteturais justificadas (Cap. 2):**
1. **Microserviços** — prefeituras compram módulos separados, escala independente (SRP/DDD)
2. **Java 21** — Virtual Threads, Spring Cloud, devs abundantes no Brasil
3. **PostgreSQL** — $0 licença (licitação pública), JSONB, PostGIS, schemas nativos
4. **RabbitMQ > Kafka** — volume adequado para governo municipal
5. **Eureka → K8s** — funciona agora, migração planejada
6. **Saga Pattern** — resolve transações distribuídas (folha → empenho contábil)

**Ecossistema mapeado com base legal (Cap. 3-4):**
- **TIER 1 (Core):** eRH, eFolha, eContábil, eLicit, eTributos, ePatrimônio, eProtocolo, eTransparência
- **TIER 2 (Operacional):** eFrotas, eAlmoxarifado, eContratos, eObras, eFiscal, eNFSe
- **TIER 3 (Setorial):** eSaúde, eEducação, eAssistência, eMeioAmbiente, eUrbano, eAgro
- **TIER 4 (Cidadão):** ePortal, eOuvidoria, eCidadão, eCâmara, eGabinete

**Obrigações legais mapeadas:** eSocial, SICONFI, TCE (AUDESP/SAGRES), PNCP (Lei 14.133/21), LAI (Lei 12.527/11), e-SUS AB, Censo Escolar, SUAS/CadÚnico, LGPD.

**Comercialização:** SaaS modular por faixa populacional (R$ 500–5.000/módulo/mês) em pacotes: Administração, Fazenda, Operacional, Social, Cidadão.

**Concorrentes:** IPM (850+ municípios) e Betha — ambos migraram legado para cloud. WS-Services é cloud-native desde o dia 1.

**Projeção 2030: 200+ prefeituras, R$ 1M+/mês MRR.**

---

*Documento vivo — Março/2026. Revisão trimestral.*  
*Fontes: microservices.io (Chris Richardson), CF/88, Lei 14.133/2021, PNCP (gov.br/pncp), LAI (Lei 12.527/11), LRF (LC 101/2000), eSocial (gov.br/esocial), SICONFI (STN), SUAS (gov.br/mds), LDB, CTN, MCASP 9ª ed., IPM Sistemas, Betha Sistemas.*
