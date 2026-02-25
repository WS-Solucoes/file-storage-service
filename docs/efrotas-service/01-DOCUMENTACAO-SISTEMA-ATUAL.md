# eFrotas — Documentação Completa do Sistema Atual

> **Versão:** 1.0 | **Data:** 23/02/2026 | **Módulo:** eFrotas (Gestão de Frotas Municipais)

---

## Sumário

1. [Visão Geral](#1-visão-geral)
2. [Arquitetura Técnica](#2-arquitetura-técnica)
3. [Backend — Modelos de Dados](#3-backend--modelos-de-dados)
4. [Backend — Enumerações](#4-backend--enumerações)
5. [Backend — API REST (Endpoints)](#5-backend--api-rest-endpoints)
6. [Backend — Relatórios (JasperReports)](#6-backend--relatórios-jasperreports)
7. [Backend — Segurança e Multi-Tenancy](#7-backend--segurança-e-multi-tenancy)
8. [Frontend — Estrutura de Páginas](#8-frontend--estrutura-de-páginas)
9. [Frontend — Componentes Reutilizáveis](#9-frontend--componentes-reutilizáveis)
10. [Frontend — Integração com API](#10-frontend--integração-com-api)
11. [Diagrama de Relacionamentos (ER)](#11-diagrama-de-relacionamentos-er)
12. [Fluxos de Negócio Principais](#12-fluxos-de-negócio-principais)

---

## 1. Visão Geral

O **eFrotas** é um sistema de gestão de frotas municipais desenvolvido como microserviço dentro do ecossistema **WS-Services**. Ele permite que prefeituras e órgãos públicos controlem veículos, motoristas, abastecimentos, manutenções, viagens, multas, inspeções, contratos e transporte escolar.

### Funcionalidades Atuais

| Módulo | Funcionalidades |
|--------|----------------|
| **Cadastros** | Veículos, Motoristas, Combustíveis, Postos, Departamentos, Fornecedores, Contratos, Rotas, Agendamentos |
| **Lançamentos** | Requisição de Abastecimento (com aprovação), Solicitação de Manutenção (com aprovação), Manutenção de Veículos, Diário de Bordo, Multas, Inspeções, Boletim/Notas Fiscais |
| **Transporte Escolar** | Contratos de Transporte Escolar, Rotas Escolares com Percursos |
| **Relatórios PDF** | Veículos, Motoristas, Inspeções, Requisições, Combustíveis (Balanço/Resumo) |
| **Dashboard** | Gráficos de barras, pizza, linha e bolha |
| **Configuração** | Unidades Gestoras, Usuários, Agentes Políticos |

### Stack Tecnológica

| Camada | Tecnologia |
|--------|-----------|
| **Backend** | Java 21, Spring Boot 3.2.5, Spring Data JPA, Hibernate, QueryDSL |
| **Banco de Dados** | PostgreSQL com Hibernate Spatial (JTS) |
| **Relatórios** | JasperReports 7.0.2 |
| **Segurança** | Spring Security + JWT (JJWT 0.11.5) + OAuth2 |
| **Service Discovery** | Netflix Eureka Client |
| **Comunicação** | OpenFeign (inter-serviço) |
| **Frontend** | Next.js (App Router), React, TypeScript, Tailwind CSS, Chart.js |
| **Documentação API** | SpringDoc OpenAPI (Swagger) |
| **Containerização** | Docker |

---

## 2. Arquitetura Técnica

### Microserviço eFrotas

```
┌─────────────────────────────────────────────────────────┐
│                    WS-Services Ecosystem                 │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │  Service      │  │  API         │  │  Frontend    │  │
│  │  Discovery    │  │  Gateway     │  │  (Next.js)   │  │
│  │  (Eureka)     │  │  :8080       │  │  :3000       │  │
│  │  :8761        │  │              │  │              │  │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  │
│         │                  │                  │          │
│         │          ┌───────┴────────┐         │          │
│         ├──────────┤  eFrotas       ├─────────┘          │
│         │          │  Service       │                    │
│         │          │  :8082         │                    │
│         │          └───────┬────────┘                    │
│         │                  │                             │
│         │          ┌───────┴────────┐                    │
│         │          │  PostgreSQL    │                    │
│         │          │  frotas DB     │                    │
│         │          │  :5432         │                    │
│         │          └────────────────┘                    │
│         │                                                │
│         │          ┌────────────────┐                    │
│         ├──────────┤  Common        │                    │
│         │          │  (shared lib)  │                    │
│         │          └────────────────┘                    │
│  └──────┴───────┘                                        │
└─────────────────────────────────────────────────────────┘
```

### Estrutura do Backend

```
eFrotas/src/main/java/ws/efrotas/
├── EFrotasApplication.java          # Main class
├── config/
│   ├── FiltroTenant.java            # Anotação @FiltroTenant
│   ├── TenantControllerAspect.java  # AOP para multi-tenancy
│   └── HibernateConfig.java         # Config Hibernate
├── controller/
│   ├── dto/                         # Request/Response DTOs (~48 classes)
│   ├── AgendamentoController.java
│   ├── CombustivelController.java
│   ├── ContratoController.java
│   ├── ContratoTransporteEscolarController.java
│   ├── DepartamentoController.java
│   ├── FornecedorController.java
│   ├── InspecaoController.java
│   ├── ManutencaoVeiculoController.java
│   ├── MotoristaController.java
│   ├── MultaController.java
│   ├── NotaFiscalController.java
│   ├── PostoCombustivelController.java
│   ├── RelatoriosController.java
│   ├── RequisicaoAbastecimentoController.java
│   ├── RequisicaoController.java
│   ├── RequisicaoManutencaoController.java
│   ├── RotaController.java
│   ├── VeiculoController.java
│   ├── ViagemController.java
│   └── VistoriaController.java
├── facade/
│   └── Facade.java                  # Camada intermediária de negócio
├── model/
│   ├── enums/                       # 8 enums
│   ├── AbstractTenantEntity.java    # Base entity com tenant/soft-delete
│   ├── Agendamento.java
│   ├── Combustivel.java
│   ├── Contrato.java
│   ├── ContratoTransporteEscolar.java
│   ├── Departamento.java
│   ├── Escola.java
│   ├── Fornecedor.java
│   ├── Inspecao.java
│   ├── ItemContrato.java
│   ├── ItemManutencao.java
│   ├── ManutencaoVeiculo.java
│   ├── Motorista.java
│   ├── Multa.java
│   ├── NotaFiscal.java
│   ├── Notificacao.java
│   ├── PercursoRota.java
│   ├── PostoCombustivel.java
│   ├── Requisicao.java
│   ├── RequisicaoAbastecimento.java
│   ├── RequisicaoManutencao.java
│   ├── Responsavel.java
│   ├── Rota.java
│   ├── Veiculo.java
│   ├── Viagem.java
│   └── Vistoria.java
├── repository/                      # 20 JPA repositories
└── service/                         # 20 services + 20 interfaces
```

---

## 3. Backend — Modelos de Dados

### 3.1 Veículo

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador único |
| nome | String | Nome do veículo |
| modelo | String | Modelo do veículo |
| anoModelo | String | Ano/modelo |
| placa | String | Placa do veículo |
| chassi | String | Número do chassi |
| renavam | String | Código RENAVAM |
| cor | String | Cor do veículo |
| litrosKm | String | Consumo litros/km |
| litrosTanque | String | Capacidade do tanque |
| tipoFrota | String | Tipo da frota (proprio/terceirizado) |
| tipoMedia | String | Tipo de média de consumo |
| transporteEscolar | Boolean | Se é usado para transporte escolar |
| destinoPadrao | String | Destino padrão |
| departamento | Departamento | FK – departamento vinculado |
| motorista | Motorista | FK – motorista padrão |
| combustivel | List\<Combustivel\> | ManyToMany – combustíveis aceitos |
| multas | List\<Multa\> | Multas do veículo |

### 3.2 Motorista

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador único |
| nomeMotorista | String | Nome completo |
| cpfMotorista | String | CPF |
| cnhNumero | String | Número da CNH |
| cnhCategoria | String | Categoria da CNH |
| cnhValidade | LocalDate | Data de validade da CNH |
| rg / rgOrgao / rgUf | String | Documento de identidade |
| dtNascimento | LocalDate | Data de nascimento |
| endereco / bairro / cep / municipio / ufEndereco | String | Endereço completo |
| telefone / celular / email | String | Contato |
| padrao | Boolean | Se é motorista padrão |
| multas | List\<Multa\> | Multas vinculadas |

### 3.3 Combustível

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador único |
| descricao | String | Tipo de combustível (Gasolina, Diesel, etc.) |
| valorUnitario | BigDecimal(15,2) | Valor por litro |

### 3.4 Requisição de Abastecimento

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador único |
| codigoRequisicao | String | Código único |
| status | StatusRequisicao | PENDENTE / APROVADA / DESAPROVADA |
| litrosRequisitados | BigDecimal(10,3) | Litros solicitados |
| litrosAbastecidos | BigDecimal(10,3) | Litros efetivamente abastecidos |
| valorAbastecido | BigDecimal(15,2) | Valor total do abastecimento |
| valorLitroAbastecido | BigDecimal(15,2) | Valor por litro |
| kmInicial / kmFinal | BigDecimal(10,1) | Quilometragem |
| cupomFiscal | String | Número do cupom fiscal |
| dtAbastecida | LocalDate | Data do abastecimento |
| dtAprovada | LocalDate | Data de aprovação |
| vinculado | boolean | Se está vinculada a nota fiscal |
| aprovador | Usuario | Quem aprovou |
| combustivel | Combustivel | FK – tipo de combustível |
| veiculo | Veiculo | FK – veículo abastecido |
| motorista | Motorista | FK – motorista |
| postoCombustivel | PostoCombustivel | FK – posto |
| departamento | Departamento | FK – departamento solicitante |

### 3.5 Requisição de Manutenção

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador único |
| codigoRequisicao | String | Código único |
| descricaoRequisicao | String | Descrição do problema |
| tipoRequisicao | String | Tipo da manutenção |
| status | StatusRequisicao | PENDENTE / APROVADA / DESAPROVADA |
| custoEstimado | BigDecimal(15,2) | Custo estimado |
| dtPrevista | LocalDate | Data prevista para execução |
| veiculo | Veiculo | FK – veículo |
| motorista | Motorista | FK – motorista |
| departamento | Departamento | FK – departamento |

### 3.6 Manutenção de Veículo

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador único |
| codigoManutencao | String | Código da manutenção |
| descricaoServico | String | Descrição do serviço |
| dtManutencao | LocalDate | Data da manutenção |
| valorTotal | BigDecimal(15,2) | Valor total |
| cupomFiscal | String | Cupom fiscal |
| itens | List\<ItemManutencao\> | Peças e serviços |
| requisicaoManutencao | RequisicaoManutencao | Requisição vinculada |
| fornecedor | Fornecedor | Oficina/fornecedor |

### 3.7 Item de Manutenção

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| nome | String | Nome do item/peça |
| valor | BigDecimal(15,2) | Valor unitário |
| valorTotal | BigDecimal(15,2) | Valor total (qtd × valor) |
| quantidade | Integer | Quantidade |
| descricao | String | Descrição |
| tipo | TipoItemManutencao | ITEM_UTILIZADO / PECA_SUBSTITUIDA / SERVICO_EXTRA |

### 3.8 Viagem (Diário de Bordo)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| codigoViagem | String | Código da viagem |
| solicitante | String | Quem solicitou |
| origem / destino | String | Locais de partida e chegada |
| pontosPassados | String | Pontos intermediários |
| dtViagem | LocalDate | Data |
| hrInicial / hrFinal | LocalTime | Horários |
| kmInicial / kmFinal | BigDecimal(10,1) | Quilometragem |
| custoEstimado | BigDecimal(15,2) | Custo |
| tipoViajem | String | Tipo da viagem |
| veiculo / motorista / departamento | FK | Relações |
| agendamento | Agendamento | Agendamento vinculado |

### 3.9 Inspeção

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| codigo | String | Código da inspeção |
| dtInspecao | LocalDate | Data |
| quilometragem | BigDecimal(10,1) | Km atual |
| observacao | String | Observações |
| *19 campos de checklist* | String | cor, pneu, documento, limpeza, farois, painel, parabrisa, cinto, cambio, freios, kit, ferramentas, extintor, lataria, oleoMotor, oleoHidraulico, agua, vazamento, ruidos, objetos |
| veiculo / motorista | FK | Relações |

### 3.10 Multa

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| dataInfracao | LocalDate | Data da infração |
| descricao | String | Descrição |
| valor | BigDecimal(15,2) | Valor da multa |
| statusPagamento | StatusPagamento | PENDENTE / PAGA / CANCELADA / EM_RECURSO |
| hora | LocalTime | Hora da infração |
| vencimento | LocalDate | Data de vencimento |
| veiculo / motorista | FK | Relações |

### 3.11 Contrato (Abastecimento)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| numeroContrato | String | Número do contrato |
| dtContrato | LocalDate | Data |
| litros | BigDecimal(10,3) | Litros totais |
| valorTotal | BigDecimal(15,2) | Valor total |
| valorLitro | BigDecimal(15,2) | Valor por litro |
| itensContrato | List\<ItemContrato\> | Itens do contrato (combustível + departamento + litros) |
| postoCombustivel / departamento / combustivel | FK | Relações |

### 3.12 Contrato de Transporte Escolar

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| numeroContrato | String | Número do contrato |
| processoLicitatorio | String | Processo |
| dtInicio / dtFinal | LocalDate | Período |
| objeto | String | Objeto do contrato |
| situacao | StatusContrato | EM_ANDAMENTO / CONCLUIDO / PARALISADO / INTERROMPIDO |
| naturezaFrota | NaturezaFrota | PROPRIA / TERCEIRIZADA |
| tipoPrestacao | TipoPrestacao | MOTORISTA / VEICULO / AMBOS |
| extensaoAnualKm | BigDecimal | Km anual |
| kmNaoPav / kmPav | BigDecimal | Km pavimentado/não-pavimentado |
| qntAlunos / diasLetivos / qntRotas | Integer | Quantidades |
| valorTotal | BigDecimal(15,2) | Valor total |
| fornecedor | Fornecedor | FK |
| veiculos | List\<Veiculo\> | ManyToMany |
| motoristas | List\<Motorista\> | ManyToMany |
| rotas | List\<Rota\> | ManyToMany |
| responsaveis | List\<Responsavel\> | Responsáveis pelo contrato |

### 3.13 Rota

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| codigoRota | String | Código |
| descricao | String | Descrição |
| kmNaoPavimentado / kmPavimentado | Double | Extensão |
| extensaoTotalKm | Double | Total km |
| custoMensalFixo | BigDecimal(15,2) | Custo fixo mensal |
| valorAnoPrevisto | BigDecimal(15,2) | Valor anual previsto |
| percursos | List\<PercursoRota\> | Percursos da rota |
| veiculo | Veiculo | FK |

### 3.14 Percurso de Rota

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | Long | Identificador |
| codigoPercurso | String | Código |
| ida | Boolean | Se é trajeto de ida |
| turno | String | Manhã/Tarde/Noite |
| pontosParada | List\<String\> | Pontos de parada ordenados |
| escolasAtendidas | String | Escolas atendidas |
| kmNaoPavimentado / kmPavimentado | Double | Extensão |
| numeroViagens | Integer | Número de viagens |
| custoFixo / custoVariavel / valorAnoPrevisto | BigDecimal(15,2) | Custos |
| veiculo / motorista | FK | Relações |

### 3.15 Outras Entidades

| Entidade | Descrição |
|----------|-----------|
| **Agendamento** | Agendamento de viagem com data, horário, rota, motorista, veículo |
| **Departamento** | Secretaria/departamento da prefeitura |
| **Fornecedor** | Fornecedor externo (oficinas, peças) — CNPJ único |
| **PostoCombustivel** | Posto de combustível — CNPJ único |
| **Escola** | Escola atendida pelo transporte escolar |
| **NotaFiscal** | Nota fiscal vinculada a requisições de abastecimento |
| **Notificacao** | Notificações de sistema (CNH, Seguro, Manutenção) |
| **Requisicao** | Requisição genérica (legado) |
| **Responsavel** | Responsável por contrato de transporte escolar |
| **Vistoria** | Vistoria de veículo com km inicial/final |

---

## 4. Backend — Enumerações

| Enum | Valores | Uso |
|------|---------|-----|
| **StatusRequisicao** | PENDENTE, APROVADA, DESAPROVADA | Req. Abastecimento e Manutenção |
| **StatusPagamento** | PENDENTE, PAGA, CANCELADA, EM_RECURSO | Multas |
| **StatusContrato** | EM_ANDAMENTO, CONCLUIDO, PARALISADO, INTERROMPIDO | Contratos Transporte Escolar |
| **NaturezaFrota** | PROPRIA, TERCEIRIZADA | Contratos Transporte |
| **TipoPrestacao** | MOTORISTA, VEICULO, AMBOS | Contratos Transporte |
| **TipoItemManutencao** | ITEM_UTILIZADO, PECA_SUBSTITUIDA, SERVICO_EXTRA | Itens de Manutenção |
| **TipoNotificacao** | CNH, SEGURO, MANUTENCAO | Notificações |
| **Turno** | MANHA, TARDE, NOITE | Percursos de Rota |

---

## 5. Backend — API REST (Endpoints)

**Base URL:** `http://localhost:8082/api/v1/`

### 5.1 Padrão CRUD (aplicável a 17 entidades)

| Método | Path | Descrição |
|--------|------|-----------|
| GET | `/{recurso}` | Listar todos (filtro tenant + soft-delete) |
| GET | `/{recurso}/page` | Listagem paginada (QueryDSL + Pageable) |
| GET | `/{recurso}/{id}` | Buscar por ID |
| POST | `/{recurso}` | Criar registro |
| PATCH | `/{recurso}/{id}` | Atualizar parcial (ModelMapper) |
| DELETE | `/{recurso}/{id}` | Soft delete |

### 5.2 Recursos CRUD

| # | Recurso | Path | Endpoints Extras |
|---|---------|------|------------------|
| 1 | Agendamento | `/agendamento` | — |
| 2 | Combustível | `/combustivel` | — |
| 3 | Contrato | `/contrato` | Gerencia itens no PATCH |
| 4 | Contrato Transp. Escolar | `/contratoTransporteEscolar` | Gerencia ManyToMany (rotas, veículos, motoristas) |
| 5 | Departamento | `/departamento` | — |
| 6 | Fornecedor | `/fornecedor` | Filtro por município |
| 7 | Inspeção | `/inspecao` | — |
| 8 | Manutenção Veículo | `/manutencaoVeiculo` | Gerencia itens no PATCH |
| 9 | Motorista | `/motorista` | Filtro por município |
| 10 | Multa | `/multa` | — |
| 11 | Nota Fiscal | `/notaFiscal` | Lógica de vinculação |
| 12 | Posto Combustível | `/postoCombustivel` | Filtro por município |
| 13 | Requisição (legado) | `/requisicao` | — |
| 14 | Req. Abastecimento | `/requisicaoAbastecimento` | `POST /{id}/aprovar` · `POST /{id}/desaprovar` |
| 15 | Req. Manutenção | `/requisicaoManutencao` | `GET /semManutencaoVeiculo` · `POST /{id}/aprovar` · `POST /{id}/desaprovar` |
| 16 | Rota | `/rota` | Sincronização de percursos |
| 17 | Veículo | `/veiculo` | ManyToMany combustível |
| 18 | Viagem | `/viagem` | — |
| 19 | Vistoria | `/vistoria` | — |

### 5.3 Relatórios

| Método | Path | Tipos de Relatório |
|--------|------|--------------------|
| POST | `/relatorio/veiculo` | veiculo, diario, km_rodados, modelodiario, manutencao, notarequisicaomanutencao |
| POST | `/relatorio/motorista` | motorista |
| POST | `/relatorio/inspecao` | inspecao |
| POST | `/relatorio/requisicao` | requisicao_resumo, mapaabastecimento, notarequisicao, requisicao |
| POST | `/relatorio/combustivel` | resumo_combustivel, balanco_combustivel |

**Parâmetros comuns:** título, dataInicial, dataFinal, tipoRelatorio, filtro1-4, parametro1-5, formato, unidadesGestoras.

---

## 6. Backend — Relatórios (JasperReports)

### Templates Disponíveis

| Template | Arquivo | Finalidade |
|----------|---------|-----------|
| Balanço Combustível | `Balanco_combustivel.jrxml` | Balanço de consumo por período |
| Resumo Combustível | `Resumo_combustivel.jrxml` | Resumo de gastos com combustível |
| Diário de Bordo | `diario.jrxml` / `diario2.jrxml` | Registro diário de viagens |
| Modelo Diário | `ModeloDiario.jrxml` | Modelo em branco para preenchimento |
| Inspeção | `Inspecao.jrxml` | Checklist de inspeção veicular |
| Manutenção | `Manutencao.jrxml` | Relatório de manutenções |
| Mapa Abastecimento | `MapaAbastecimento.jrxml` | Mapa consolidado de abastecimentos |
| Motorista | `Motorista.jrxml` | Dados do motorista |
| Nota Requisição | `NotaRequisicao.jrxml` | Nota de requisição de abastecimento |
| Nota Req. Manutenção | `NotaRequisicaoManutencao.jrxml` | Nota de requisição de manutenção |
| Requisição | `Requisicao.jrxml` | Requisição completa |
| Requisição Resumo | `Requisicao_Resumo.jrxml` | Requisição resumida |
| Rotas | `Rotas.jrxml` | Relatório de rotas |
| Veículo | `veiculo.jrxml` | Relatório de veículos |

---

## 7. Backend — Segurança e Multi-Tenancy

### Autenticação

- **JWT** com chaves RSA (PEM) no classpath
- Access token: 15 min (`jwt.access-expiration`)
- Refresh token: 1 dia (`jwt.refresh-expiration`)
- OAuth2 Authorization Server integrado

### Multi-Tenancy

O sistema implementa multi-tenancy via **Hibernate Filters**:

| Filtro | Parâmetro | Função |
|--------|-----------|--------|
| `tenantFilter` | `unidadeGestoraId` | Isola dados por Unidade Gestora |
| `excluidoFilter` | `excluido` | Soft delete (exclusão lógica) |
| `municipioFilter` | `municipio` | Compartilha dados entre UGs do mesmo município |

### Padrão de Filtragem

1. **@FiltroTenant** (anotação customizada) → AOP intercepta e aplica `tenantFilter`
2. Endpoints de consulta habilitam `excluidoFilter` para esconder registros deletados
3. Entidades como Motorista, Fornecedor e PostoCombustivel usam `municipioFilter` para compartilhamento entre UGs

### Roles

| Role | Permissões |
|------|-----------|
| `FROTAS_ADMIN` | Acesso total: configuração, cadastros, lançamentos, relatórios |
| `FROTAS_GESTOR` | Cadastros, lançamentos, relatórios, aprovar/desaprovar requisições |
| `FROTAS_USUARIO` | Lançamentos e visualização de relatórios |

### Auditoria

- Todos os CRUDs usam `@SalvarLog()` para registrar criação, alteração e exclusão
- Campos `dtLog` e `usuarioLog` em todas as entidades

---

## 8. Frontend — Estrutura de Páginas

### Página Pública

| Rota | Descrição |
|------|-----------|
| `/nossos-sistemas/e-Frotas` | Landing page institucional |

### Páginas Autenticadas

#### Dashboard e Acesso

| Rota | Descrição |
|------|-----------|
| `/e-Frotas` | Login |
| `/e-Frotas/dashboard` | Dashboard com gráficos interativos (Chart.js) |
| `/e-Frotas/sair` | Logout |

#### Configuração

| Rota | Descrição |
|------|-----------|
| `/e-Frotas/configuracao/cadastro/unidade-gestora` | CRUD Unidades Gestoras |
| `/e-Frotas/configuracao/cadastro/usuario` | CRUD Usuários com roles |
| `/e-Frotas/configuracao/cadastro/agente-politico` | CRUD Agentes Políticos |

#### Cadastros

| Rota | Descrição |
|------|-----------|
| `/e-Frotas/cadastro/departamento` | CRUD Departamentos |
| `/e-Frotas/cadastro/combustivel` | CRUD Combustíveis |
| `/e-Frotas/cadastro/motorista` | CRUD Motoristas (com busca CEP) |
| `/e-Frotas/cadastro/posto` | CRUD Postos (com consulta CNPJ) |
| `/e-Frotas/cadastro/fornecedor` | CRUD Fornecedores (com consulta CNPJ) |
| `/e-Frotas/cadastro/veiculo` | CRUD Veículos |
| `/e-Frotas/cadastro/contrato` | CRUD Contratos com itens |
| `/e-Frotas/cadastro/rota` | CRUD Rotas |
| `/e-Frotas/cadastro/agendamento` | CRUD Agendamentos |

#### Lançamentos

| Rota | Descrição |
|------|-----------|
| `/e-Frotas/lancamento/requisicao-abastecimento` | Req. Abastecimento com aprovação |
| `/e-Frotas/lancamento/solicitacao-manutencao` | Solicitação Manutenção com aprovação |
| `/e-Frotas/lancamento/manutencao` | Manutenção com itens dinâmicos |
| `/e-Frotas/lancamento/diario-de-bordo` | Diário de Bordo com PDF |
| `/e-Frotas/lancamento/multa` | Registro de Multas |
| `/e-Frotas/lancamento/inspecao` | Inspeção Veicular com PDF |
| `/e-Frotas/lancamento/boletim` | Notas Fiscais |

#### Transporte Escolar

| Rota | Descrição |
|------|-----------|
| `/e-Frotas/transporte-escolar/contrato` | Contratos Transporte Escolar |
| `/e-Frotas/transporte-escolar/rota` | Rotas Escolares com Percursos |

#### Relatórios

| Rota | Descrição |
|------|-----------|
| `/e-Frotas/relatorio/motorista` | Relatório de Motoristas (PDF) |
| `/e-Frotas/relatorio/veiculos` | Relatório de Veículos (PDF) |
| `/e-Frotas/relatorio/combustivel` | Balanço/Resumo Combustível (PDF) |
| `/e-Frotas/relatorio/diario-bordo` | Diário de Bordo (PDF) |

**Total: 25+ páginas funcionais**

---

## 9. Frontend — Componentes Reutilizáveis

| Componente | Função |
|------------|--------|
| `useCrudPage` | Hook central que encapsula toda lógica CRUD |
| `withAuthorization` | HOC de autenticação/autorização |
| `Cabecalho` | Header com breadcrumbs |
| `Tabela/Estrutura` | Tabela com paginação, pesquisa e ações |
| `Cadastro/Estrutura` | Formulário dinâmico baseado em configuração |
| `ModalSelect` | Modal de seleção com filtros |
| `AdicaoItens` | Adição dinâmica de itens em formulários |
| `Login` | Componente de login parametrizado |

### Padrão por Página

Cada entidade segue o padrão de 3 arquivos:
- `page.tsx` — Componente da página
- `*.config.ts` — Configuração de campos, colunas e ações
- `*.types.ts` — Tipos TypeScript

---

## 10. Frontend — Integração com API

| Aspecto | Detalhe |
|---------|---------|
| Função HTTP | `generica()` de `@/api/api` |
| ServiceKey | `'frotas'` |
| Token | `frotas_ws_auth_token` (sessionStorage) |
| Detecção de módulo | `moduleDetector.ts` via URL |
| Relatórios PDF | POST com `responseType: 'arraybuffer'` |

---

## 11. Diagrama de Relacionamentos (ER)

```
┌──────────────────┐      ┌──────────────────┐
│  UnidadeGestora   │──┬──│    Departamento    │
└──────────────────┘  │  └────────┬───────────┘
                      │           │
┌───────────┐         │  ┌────────┴───────────┐
│ Combustivel│─────────┼──│     Veiculo         │──── List<Multa>
└─────┬─────┘         │  └──┬──────┬──────────┘
      │               │     │      │
      │  ┌────────────┼─────┘      │
      │  │            │            │
┌─────┴──┴──────┐    │  ┌─────────┴──────────┐
│  RequisicaoAb  │    │  │    Motorista         │──── List<Multa>
│  astecimento   │    │  └──┬─────────────────┘
│  (status:      │    │     │
│   aprovavel)   │    │     │
└────────────────┘    │  ┌──┴─────────────────┐
                      │  │    Viagem            │
┌────────────────┐    │  │  (Diário de Bordo)  │
│  RequisicaoMan │    │  └────────────────────┘
│  utencao       │    │
│  (status:      │    │  ┌────────────────────┐
│   aprovavel)   │────┤  │  ManutencaoVeiculo  │
└────────────────┘    │  │  ├─ ItemManutencao  │
                      │  └────────────────────┘
┌────────────────┐    │
│   Inspecao      │────┤  ┌────────────────────┐
│ (19 checklist)  │    │  │    Agendamento      │
└────────────────┘    │  └────────────────────┘
                      │
┌────────────────┐    │  ┌────────────────────┐
│  NotaFiscal     │────┤  │    Contrato         │
│  ├─ ReqAbast   │    │  │  ├─ ItemContrato    │
└────────────────┘    │  └────────────────────┘
                      │
┌────────────────┐    │  ┌────────────────────┐
│   Fornecedor    │────┤  │     Rota            │
└────────────────┘    │  │  ├─ PercursoRota    │
                      │  └────────────────────┘
┌────────────────┐    │
│PostoCombustivel │────┤  ┌────────────────────┐
└────────────────┘    │  │ ContratoTranspEsc   │
                      │  │  ├─ Responsavel     │
┌────────────────┐    │  │  ├─ ManyToMany:     │
│    Multa        │────┤  │  │  Veiculo,Moto,  │
└────────────────┘    │  │  │  Rota            │
                      │  └────────────────────┘
┌────────────────┐    │
│  Notificacao    │────┤  ┌────────────────────┐
│ (CNH,Seguro,   │    │  │     Vistoria        │
│  Manutencao)   │────┘  └────────────────────┘
└────────────────┘
```

---

## 12. Fluxos de Negócio Principais

### 12.1 Fluxo de Abastecimento

```
1. Usuário cria Requisição de Abastecimento (status: PENDENTE)
2. Gestor/Admin aprova ou desaprova a requisição
3. Após aprovação, motorista vai ao posto e abastece
4. Usuário registra litros abastecidos, valor, cupom fiscal, km
5. Requisição é vinculada a uma Nota Fiscal
6. Relatórios de balanço/resumo consolidam dados
```

### 12.2 Fluxo de Manutenção

```
1. Usuário cria Requisição de Manutenção (status: PENDENTE)
2. Gestor/Admin aprova ou desaprova
3. Após aprovação, manutenção é executada no fornecedor
4. Usuário registra Manutenção Veicular com itens (peças, serviços)
5. Vincula à requisição aprovada
6. Relatórios consolidam custos de manutenção
```

### 12.3 Fluxo de Viagem

```
1. Solicitante agenda viagem (Agendamento)
2. Veículo e motorista são designados
3. No dia, registra-se a Viagem (km inicial/final, horários)
4. Inspeção pré-viagem pode ser realizada
5. Dados alimentam o Diário de Bordo
```

### 12.4 Fluxo de Transporte Escolar

```
1. Admin registra Contratos de Transporte Escolar (próprio ou terceirizado)
2. Vincula veículos, motoristas, rotas e responsáveis
3. Rotas são detalhadas com percursos (ida/volta, turnos, pontos de parada)
4. Custos são calculados por percurso e rota
5. Relatórios auxiliam na prestação de contas
```

---

> **Nota:** Este documento reflete o estado do sistema em 23/02/2026. O módulo GPS está planejado mas ainda não implementado.
