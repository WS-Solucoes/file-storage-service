# PLANO DE REFATORAÇÃO E STATUS DO SISTEMA eRH — ATUALIZAÇÃO FEVEREIRO/2026

**Data:** 19 de Fevereiro de 2026  
**Versão:** 3.0 — Varredura Completa de Projeto  
**Autor:** Equipe WS Soluções  
**Escopo:** Backend (eRH-Service) + Frontend (frontend-services) + Migrações + Obrigações

---

## SUMÁRIO EXECUTIVO

O sistema eRH é um módulo de gestão de recursos humanos e folha de pagamento para órgãos públicos municipais, parte do ecossistema WS-Services. Este documento apresenta uma **auditoria completa** do estado atual do projeto, organizando:

1. O que está **implementado e funcional**
2. O que está **parcialmente implementado** (com lacunas)
3. O que **falta ser implementado**, priorizado por impacto
4. **Relatórios** existentes e faltantes
5. **Obrigações legais** (eSocial, TCE, DIRF, RAIS, SEFIP) e gaps de conformidade
6. **TODOs e bugs** pendentes no código
7. **Plano de execução** por sprints

---

## 1. INVENTÁRIO DO PROJETO — NÚMEROS ATUAIS

| Métrica | Backend (eRH-Service) | Frontend (frontend-services) |
|---------|----------------------|------------------------------|
| **Arquivos de código** | 359 Java | ~120+ TSX/TS |
| **Controllers** | 44 | — |
| **Services** | 75 | — |
| **Repositories** | 43 | — |
| **DTOs** | 100 | — |
| **Entities/Models** | 42 | — |
| **Enums** | 10 | — |
| **Páginas/Rotas** | — | ~45 páginas |
| **Relatórios Jasper** | 6 templates .jrxml | — |
| **Migrações SQL** | 12 arquivos | — |
| **Testes unitários** | 2 classes (36 testes) | 0 |
| **Endpoints REST** | ~150+ | — |

---

## 2. FUNCIONALIDADES IMPLEMENTADAS (STATUS: PRONTO)

### 2.1 CORE / INFRAESTRUTURA ✅

| Funcionalidade | Backend | Frontend | Observações |
|---|:---:|:---:|---|
| Multi-tenancy (Hibernate Filters) | ✅ | ✅ | Via `unidade_gestora_id` |
| Autenticação JWT | ✅ | ✅ | Via common-service |
| MBAC (permissões por módulo) | ✅ | ✅ | ADMIN, GESTOR, ANALISTA, USUARIO |
| Sistema de Competência (abrir/fechar) | ✅ | ✅ | CompetenciaController + CompetenciaContext |
| Service Discovery (Eureka) | ✅ | — | Porta 8761 |
| API Gateway | ✅ | ✅ | Roteamento por path |
| Storage abstrato (Local/S3/Azure) | ✅ | — | ArquivoStorageService |
| Dual DataSource (erh + frotas) | ✅ | — | ErhDataSourceConfig |

### 2.2 CADASTROS ✅

| Funcionalidade | Backend | Frontend | Endpoints | Observações |
|---|:---:|:---:|---|---|
| Servidor (pessoa física) | ✅ | ✅ | CRUD `/servidor` | Com foto, endereço, busca CEP |
| Dependentes | ✅ | ✅ | CRUD `/dependente` | Tipos eSocial mapeados |
| Departamentos | ✅ | ✅ | CRUD `/departamento-rh` | — |
| Lotações | ✅ | ✅ | CRUD `/lotacao` | — |
| Cargos | ✅ | ✅ | CRUD `/cargo` | — |
| Níveis | ✅ | ✅ | CRUD `/nivel` | — |
| Ocupação CBO | ✅ | ✅ | CRUD `/ocupacao-cbo` | Tabela CBO 2002 |
| Vínculo Funcional | ✅ | ✅ | CRUD `/vinculo-funcional` | Movimentações, situação ATIVO/INATIVO |
| Vínculo Funcional Det | ✅ | ✅ | CRUD `/vinculo-funcional-det` | Detalhes por competência |
| Legislação (faixas INSS/IRRF) | ✅ | ✅ | CRUD `/legislacao` | Tabelas 2026 migradas |
| Instituto Previdência (RPPS) | ✅ | ✅ | CRUD `/institutos-previdencia` | Logo, ativar/desativar |
| Bancos | ✅ | ✅ | CRUD `/banco` | Tabela CSV pré-carregada |
| Tipo Agente Político | ✅ | ✅ | CRUD `/tipo-agente-politico` | — |

### 2.3 FOLHA DE PAGAMENTO ✅

| Funcionalidade | Backend | Frontend | Observações |
|---|:---:|:---:|---|
| Rubricas (Vantagem/Desconto) | ✅ | ✅ | CRUD com natureza (V/D), cálculo auto, incidências |
| Grupo de Rubricas | ✅ | ✅ | Agrupamento para relatórios |
| Vínculo-Rubrica (lançamento) | ✅ | ✅ | Fixas/variáveis por vínculo |
| Folha de Pagamento | ✅ | ✅ | CRUD + resumo bruto/líquido/descontos |
| Folha Pagamento Detalhe | ✅ | ✅ | Itens de V/D por servidor |
| Processamento da Folha | ✅ | ✅ | Cálculo automático de INSS/RPPS, IRRF, Sal.Família, Quinquênio |
| 13º Salário | ✅ | ✅ | Adiantamento (50%), Proporcional, Integral. Modos CONJUNTA/SEPARADA |
| Memória de Cálculo 13º | ✅ | ✅ | Auditoria completa com 25+ campos |
| Fechamento de Competência | ✅ | ✅ | Copiar legislação, vantagens, folhas |
| Reabertura de Competência | ✅ | ✅ | Com validação |
| Recálculo de Servidores | ✅ | ✅ | Reprocessamento individual |
| Exportação Bancária | ✅ | ✅ | Registrar/Reverter/Verificar exportação |

### 2.4 GUIA RPPS ✅

| Funcionalidade | Backend | Frontend | Observações |
|---|:---:|:---:|---|
| Geração de Guias por competência | ✅ | ✅ | Cálculo automático: patronal + servidor + suplementar |
| PDF da Guia RPPS | ✅ | ✅ | Jasper com código de barras e linha digitável |
| Registro de Pagamento | ✅ | ✅ | — |
| Cancelamento de Guia | ✅ | ✅ | — |
| Atualização de Vencidas | ✅ | ✅ | — |
| Resumo por Competência | ✅ | ✅ | Totais consolidados |

### 2.5 EXPORTAÇÕES / OBRIGAÇÕES ACESSÓRIAS ✅

| Exportação | Backend | Frontend | Formato | Observações |
|---|:---:|:---:|---|---|
| SAGRES (TCE-PE) | ✅ | ✅ | XML | 6 tipos (servidores, cargos, lotações, vínculos, folha, dependentes) |
| DIRF | ✅ | ✅ | Texto | Strategy pattern com DIRF2019Strategy |
| RAIS | ✅ | ✅ | Texto | Strategy pattern com RAIS2019Strategy |
| SEFIP/GFIP | ✅ | ✅ | Texto | Strategy pattern com SEFIP2019Strategy |
| CNAB (Remessa Bancária) | ⚠️ | ✅ | Texto | **TODO: Implementar geração do arquivo** |
| Guia RPPS | ✅ | ✅ | PDF | Via ModalExportacao |
| Consignações | ❌ | ⚠️ | — | Frontend com UI, backend não implementado |

### 2.6 IMPORTAÇÃO ⚠️

| Funcionalidade | Backend | Frontend | Observações |
|---|:---:|:---:|---|
| Importação SAGRES (servidores) | ⚠️ | ⚠️ | Endpoint existe mas **TODO: Converter DTO para entidade e salvar** |
| Importação SAGRES (streaming) | ⚠️ | — | Parcial |
| Validação de arquivo | ⚠️ | — | **TODO: Implementar validação por tipo** |

### 2.7 TABELAS DE REFERÊNCIA ✅

| Tabela | Backend | Frontend | Quantidade |
|---|:---:|:---:|---|
| Tabelas TCE | ✅ | ✅ | 14 CRUDs completos |
| Tabelas eSocial | ✅ | ✅ | 5 CRUDs completos |
| CSVs Seeders | ✅ | — | 17 arquivos (CBO, Municípios, Bancos, etc.) |

### 2.8 DASHBOARD E RELATÓRIOS ✅

| Funcionalidade | Backend | Frontend | Observações |
|---|:---:|:---:|---|
| Dashboard com cards de resumo | ✅ | ✅ | 6 indicadores + gráficos |
| Dashboard resumo financeiro | ✅ | ✅ | Bruto, Descontos, Líquido, INSS, RPPS, IRRF |
| Aba de relatórios no dashboard | — | ✅ | 12 tipos listados |

---

## 3. RELATÓRIOS — ANÁLISE COMPLETA

### 3.1 Relatórios Implementados (Jasper .jrxml)

| # | Relatório | Template | Endpoint | Frontend | Parâmetros |
|---|---|---|---|:---:|---|
| 1 | **Folha Analítica (Completa)** | `FolhaPG.jrxml` (564 linhas) | `POST /relatorio/folha-completa` | ✅ | UG, competência, lotação, cargo, formato |
| 2 | **Folha Sintética (Resumo)** | `FolhaPGResumo.jrxml` (402 linhas) | `POST /relatorio/folha-resumo` | ✅ | UG, período, formato |
| 3 | **Demonstrativo / Contracheque** | `DemonstrativoPG.jrxml` (705 linhas) | `POST /relatorio/demonstrativo` | ✅ | Servidor, competência |
| 4 | **Ficha Financeira Anual** | `FichaFinanceira.jrxml` (813 linhas) | `POST /relatorio/ficha-financeira` | ✅ | Servidor, período, landscape |
| 5 | **Comprovante de Rendimentos (IR)** | `ComprovanteIR.jrxml` (416 linhas) | `POST /relatorio/comprovante-ir` | ✅ | Servidor, ano, temas dinâmicos |
| 6 | **Guia RPPS** | `GuiaRPPS.jrxml` (440 linhas) | `GET /guias-rpps/{id}/pdf` | ✅ | Instituto, banco, valores |

**Características comuns:** temas dinâmicos (cores da UG), logo da entidade, cabeçalho/rodapé configuráveis, filtros por `unidadeGestoraIds`.

### 3.2 Relatórios FALTANTES (Críticos para Operação Municipal)

| # | Relatório | Prioridade | Impacto | Descrição |
|---|---|:---:|:---:|---|
| 1 | **Relatório de Servidores por Lotação** | ALTA | ALTO | Lista de servidores por departamento/lotação com cargo, matrícula, situação |
| 2 | **Relatório de Servidores por Cargo** | ALTA | ALTO | Quantitativo e nominativo por cargo/nível CBO |
| 3 | **Resumo Geral da Folha por Rubrica** | ALTA | ALTO | Total por rubrica (todas V/D), essencial para contabilidade |
| 4 | **Relatório de Líquido por Banco** | ALTA | ALTO | Totais por banco para conferência da remessa CNAB |
| 5 | **Relatório de Contribuições Previdenciárias** | ALTA | ALTO | Detalhamento INSS/RPPS por servidor e totais para conferência com guias |
| 6 | **Relatório de IRRF** | ALTA | ALTO | Detalhamento do IR retido por servidor, base de cálculo, faixas |
| 7 | **Relatório de Dependentes** | MÉDIA | MÉDIO | Lista de dependentes por servidor com tipo/parentesco |
| 8 | **Relatório de 13º Salário** | ALTA | ALTO | Memória de cálculo consolidada do 13º com base, parcela, descontos |
| 9 | **Relatório de Quinquênio/ATS** | MÉDIA | MÉDIO | Servidores com adicionais por tempo de serviço |
| 10 | **Relatório de Férias (quando implementado)** | MÉDIA | ALTO | Programação, concessão, saldo de férias |
| 11 | **Relatório de Evolução da Folha** | MÉDIA | MÉDIO | Comparativo mensal/anual da folha (gráfico/tabela) |
| 12 | **Relatório de Margem Consignável** | MÉDIA | MÉDIO | Margem disponível para empréstimos (30% do líquido) |
| 13 | **Relatório para TCE (Prestação de Contas)** | ALTA | ALTO | Resumo de conferência pré-exportação SAGRES |
| 14 | **Relatório de Previdência** | ALTA | ALTO | Resumo mensal de contribuições patronal/servidor/suplementar |
| 15 | **Relatório de Salário Família** | BAIXA | BAIXO | Servidores beneficiários e valores por dependente |

### 3.3 Relatórios de Conferência (Para Auditoria/Compliance)

| # | Relatório | Prioridade | Descrição |
|---|---|:---:|---|
| 16 | **Relatório de Diferenças** | ALTA | Comparativo entre a folha atual e anterior (novos, excluídos, alterados) |
| 17 | **Relatório de Lançamentos Manuais** | MÉDIA | Registros inseridos manualmente (não calculados automaticamente) |
| 18 | **Relatório de Reprocessamentos** | MÉDIA | Log de folhas reprocessadas e motivos |
| 19 | **Mapa de Conciliação Bancária** | ALTA | Cruzamento entre valores exportados (CNAB) e líquidos da folha |

---

## 4. OBRIGAÇÕES LEGAIS — DIRETRIZES eSocial E PRESTAÇÃO DE CONTAS

### 4.1 eSocial — Cronograma para Órgãos Públicos (Grupo 4)

Os órgãos públicos municipais estão enquadrados no **GRUPO 4** do eSocial. Conforme o cronograma oficial (Portaria Conjunta SERFB/SEPRT/ME nº 71/2021):

| Fase | Eventos | Vigente desde | Status no WS-eRH |
|---|---|---|---|
| **1ª Fase** | Tabelas (S-1000 a S-1080) — Cadastro do empregador e tabelas | **21/07/2021** | ⚠️ PARCIAL — tabelas de referência existem mas **não há geração de XML** |
| **2ª Fase** | Não-Periódicos (S-2190 a S-2420) — Admissões, afastamentos, desligamentos | **22/11/2021** | ❌ NÃO IMPLEMENTADO |
| **3ª Fase** | Periódicos (S-1200 a S-1299) — Folha de pagamento | **22/08/2022** | ❌ NÃO IMPLEMENTADO |
| **4ª Fase** | SST (S-2210, S-2220, S-2240) — Saúde e Segurança do Trabalho | **01/01/2023** | ❌ NÃO IMPLEMENTADO |

**Substituição da GFIP:** Desde **Outubro/2022**, o eSocial substituiu a GFIP para recolhimento de Contribuições Previdenciárias de órgãos públicos.

### 4.2 Eventos eSocial Obrigatórios — O Que Precisa Ser Implementado

#### Fase 1 — Eventos de Tabela (PARCIAL)

| Evento | Descrição | Status | O que falta |
|---|---|---|---|
| **S-1000** | Informações do Empregador/Contribuinte | ❌ | Geração de XML com dados da UG |
| **S-1005** | Tabela de Estabelecimentos | ❌ | — |
| **S-1010** | Tabela de Rubricas | ⚠️ | Temos as rubricas, falta mapear p/ eSocial (NatRubrica) e gerar XML |
| **S-1020** | Tabela de Lotações Tributárias | ❌ | — |
| **S-1035** | Tabela de Carreiras Públicas | ❌ | Órgãos públicos obrigatório |
| **S-1040** | Tabela de Funções/Cargos | ⚠️ | Temos CBO, falta exportar XML |
| **S-1050** | Tabela de Horários/Turnos | ❌ | — |
| **S-1070** | Tabela de Processos Administrativos/Judiciais | ❌ | — |

#### Fase 2 — Eventos Não-Periódicos (NÃO IMPLEMENTADO)

| Evento | Descrição | Dependência |
|---|---|---|
| **S-2190** | Registro Preliminar de Trabalhador | Módulo Admissão |
| **S-2200** | Cadastramento Inicial / Admissão do Trabalhador | Vínculo Funcional + dados eSocial |
| **S-2205** | Alteração de Dados Cadastrais | Servidor + Vínculo |
| **S-2206** | Alteração de Contrato de Trabalho | Vínculo Funcional Det |
| **S-2230** | Afastamento Temporário | **Módulo Afastamento (não existe)** |
| **S-2298** | Reintegração/Exercício | Vínculo Funcional |
| **S-2299** | Desligamento | **Módulo Rescisão (não existe)** |
| **S-2300** | Trabalhador sem Vínculo (Início) | Tipos especiais de vínculo |
| **S-2306** | Trabalhador sem Vínculo (Alteração) | — |
| **S-2399** | Trabalhador sem Vínculo (Término) | — |
| **S-2416** | Cadastro de Benefícios Previdenciários - RPPS | Aposentadoria/Pensões |
| **S-2418** | Reativação de Benefício Previdenciário - RPPS | Aposentadoria/Pensões |
| **S-2420** | Cessação de Benefício Previdenciário - RPPS | Aposentadoria/Pensões |

#### Fase 3 — Eventos Periódicos (NÃO IMPLEMENTADO)

| Evento | Descrição | Dependência |
|---|---|---|
| **S-1200** | Remuneração do Trabalhador vinculado ao RGPS | Folha + Rubricas mapeadas |
| **S-1202** | Remuneração de servidor vinculado a RPPS | Folha + RPPS (maioria dos municípios) |
| **S-1207** | Benefícios Previdenciários - RPPS | Aposentados e Pensionistas |
| **S-1210** | Pagamentos de Rendimentos do Trabalho | Folha processada |
| **S-1260** | Comercialização da Produção Rural PF | N/A para município |
| **S-1270** | Contratação de Trabalhadores Avulsos | Raro |
| **S-1280** | Informações Complementares aos Eventos Periódicos | Complementar |
| **S-1298** | Reabertura dos Eventos Periódicos | Controle de competência |
| **S-1299** | Fechamento dos Eventos Periódicos | Fechamento da competência |

#### Fase 4 — SST (NÃO IMPLEMENTADO)

| Evento | Descrição | Dependência |
|---|---|---|
| **S-2210** | CAT (Comunicação de Acidente de Trabalho) | Módulo SST (PARTE 15) |
| **S-2220** | Monitoramento da Saúde do Trabalhador (ASO) | Módulo SST |
| **S-2240** | Condições Ambientais do Trabalho (PPP) | Módulo SST |

### 4.3 Prestação de Contas — TCE (SAGRES)

| Item | Status | Observações |
|---|---|---|
| Exportação de Servidores | ✅ | XML validado |
| Exportação de Cargos | ✅ | XML validado |
| Exportação de Lotações | ✅ | XML validado |
| Exportação de Vínculos | ✅ | XML validado |
| Exportação da Folha | ✅ | XML validado |
| Exportação de Dependentes | ✅ | XML validado |
| 14 Tabelas de Referência TCE | ✅ | CRUDs completos |
| Relatório de Conferência Pré-Exportação | ❌ | **Faltando** — essencial para consistência |
| Validação de Consistência | ❌ | Verificar regras do SAGRES antes de exportar |

### 4.4 Outras Obrigações Acessórias

| Obrigação | Status | Observações |
|---|---|---|
| **DIRF (Declaração IR Retido na Fonte)** | ✅ | Strategy DIRF2019 implementada. **Atenção:** DIRF foi extinta a partir do ano-calendário 2025 (IN RFB 2.181/2024), substituída pela EFD-Reinf |
| **EFD-Reinf** | ❌ | **Nova obrigação** que substitui a DIRF. Precisa ser implementada |
| **RAIS** | ✅ | Strategy RAIS2019 implementada. **Atenção:** RAIS está sendo gradativamente substituída pelo eSocial |
| **SEFIP/GFIP** | ✅ | Strategy SEFIP2019 implementada. **Atenção:** Já substituída pelo eSocial/DCTFWeb para órgãos públicos desde Out/2022 |
| **DCTFWeb** | ❌ | **Nova obrigação** — substitui GFIP para contribuições previdenciárias |
| **CNAB (Remessa Bancária)** | ⚠️ | Preview implementado, **geração de arquivo pendente** (TODO no código) |

---

## 5. FUNCIONALIDADES NÃO IMPLEMENTADAS — PRIORIZAÇÃO POR IMPACTO

### PRIORIDADE CRÍTICA (Impacto Legal/Operacional Imediato)

| # | Funcionalidade | PARTE | Justificativa | Esforço |
|---|---|:---:|---|:---:|
| 1 | **Eventos eSocial — Fase 1 (Tabelas)** | 8 | Obrigatório desde Jul/2021. Multas por descumprimento | GRANDE |
| 2 | **Eventos eSocial — Fase 3 (Periódicos S-1200/S-1202/S-1210)** | 8 | Obrigatório desde Ago/2022. Folha de pagamento já existe, falta gerar XML | GRANDE |
| 3 | **EFD-Reinf** | — | Substitui DIRF a partir de 2025. Obrigatório para IR retido | MÉDIO |
| 4 | **DCTFWeb** | — | Substitui GFIP/SEFIP desde Out/2022 para órgãos públicos | MÉDIO |
| 5 | **Módulo de Férias** | 14 | Impacto direto na folha (1/3, abono), obrigatório p/ eSocial | GRANDE |
| 6 | **Módulo de Afastamentos** | 6 | Necessário para eSocial S-2230 e controle operacional | MÉDIO |

### PRIORIDADE ALTA (Impacto Operacional Significativo)

| # | Funcionalidade | PARTE | Justificativa | Esforço |
|---|---|:---:|---|:---:|
| 7 | **Módulo de Rescisão/Desligamento** | 7 | Cálculo rescisório, TRCT, eSocial S-2299 | GRANDE |
| 8 | **Geração de CNAB** | — | Arquivo de remessa bancária para pagamento da folha | MÉDIO |
| 9 | **Relatórios faltantes (itens 1-6 da seção 3.2)** | 23 | Essenciais para operação diária | MÉDIO |
| 10 | **Consignações** | 3 | Empréstimos em folha, margem consignável | MÉDIO |
| 11 | **Eventos eSocial — Fase 2 (Não-Periódicos S-2200/S-2230/S-2299)** | 8 | Obrigatório desde Nov/2021 | GRANDE |
| 12 | **Importação SAGRES completa** | — | TODO no código: converter DTO para entidade | PEQUENO |

### PRIORIDADE MÉDIA (Melhoria Operacional)

| # | Funcionalidade | PARTE | Justificativa | Esforço |
|---|---|:---:|---|:---:|
| 13 | **Aposentadoria e Pensões** | 10 | EC 103/2019, RPPS, eSocial S-2416/S-2420 | GRANDE |
| 14 | **PCCS (Plano de Cargos)** | 9 | Progressão funcional, impacta salário | GRANDE |
| 15 | **Simulador de Contribuições RPPS** | — | Link órfão no frontend (precisa implementar) | PEQUENO |
| 16 | **Relatórios de Previdência** | — | Link órfão no frontend (precisa implementar) | MÉDIO |
| 17 | **Testes unitários (cobertura)** | — | Apenas 2 classes de teste. Risco de regressão alto | MÉDIO |
| 18 | **Eventos eSocial — Fase 4 (SST)** | 15 | Saúde e Segurança obrigatório desde Jan/2023 | GRANDE |
| 19 | **Frequência/Ponto** | 12 | Controle de jornada, REP | GRANDE |

### PRIORIDADE BAIXA (Valor Agregado, Não Urgente)

| # | Funcionalidade | PARTE | Esforço |
|---|---|:---:|:---:|
| 20 | Portal do Servidor (autoserviço) | 11 | GRANDE |
| 21 | Avaliação de Desempenho | 14 | GRANDE |
| 22 | Capacitação e Treinamento | 20 | MÉDIO |
| 23 | Cessão/Requisição de Servidores | 21 | MÉDIO |
| 24 | Recadastramento/Prova de Vida | 22 | PEQUENO |
| 25 | Gestão Documental (GED) | 23 | GRANDE |
| 26 | Notificações e Alertas | 25 | MÉDIO |
| 27 | Concursos Públicos | 13 | GRANDE |
| 28 | PAD (Processos Disciplinares) | 27 | GRANDE |
| 29 | Benefícios (VA/VT/Auxílios) | 19 | MÉDIO |
| 30 | Auditoria e Logs | 24 | MÉDIO |

---

## 6. TODOs E BUGS PENDENTES NO CÓDIGO

### 6.1 TODOs no Backend (11 itens)

| # | Arquivo | Linha | TODO | Criticidade |
|---|---|:---:|---|:---:|
| 1 | `ProcessamentoFolhaService.java` | 2156 | Implementar cópia de vantagens/descontos | ALTA |
| 2 | `ProcessamentoController.java` | 231 | Obter usuário logado do contexto de segurança | MÉDIA |
| 3 | `ExportacaoController.java` | 472 | Calcular valor total do líquido a pagar | ALTA |
| 4 | `ExportacaoController.java` | 497 | **Implementar geração de arquivo CNAB** | ALTA |
| 5 | `ImportacaoController.java` | 124 | Implementar validação por tipo | MÉDIA |
| 6 | `SagresImportService.java` | 210 | Converter DTO para entidade e salvar | MÉDIA |
| 7 | `Facade.java` | 218 | Adicionar setUsuarioLog na entidade Funcionario | BAIXA |
| 8 | `CompetenciaController.java` | 116 | Implementar isFechada no CompetenciaService | ALTA |
| 9 | `GuiaRppsPdfService.java` | 666 | Buscar dados da Unidade Gestora | MÉDIA |
| 10 | `DashboardService.java` | 343 | Implementar campo quando adicionado ao modelo | BAIXA |
| 11 | `DashboardService.java` | 349 | Implementar campo quando adicionado ao modelo | BAIXA |

### 6.2 Bugs Corrigidos Nesta Revisão

| Bug | Arquivo | Correção |
|---|---|---|
| Endpoint `GET /memoria-calculo-13/{id}` buscava por `folhaPagamentoId` | `ProcessamentoController.java` | Corrigido para usar `findById()` |

### 6.3 Alertas de Infraestrutura

| Alerta | Descrição | Ação |
|---|---|---|
| **Migrações SQL com numeração conflitante** | Múltiplos arquivos V002, V004, V005 | Renumerar se Flyway for adotado |
| **common/README.md vazio** | Sem documentação do módulo compartilhado | Documentar |
| **Cobertura de testes < 1%** | Apenas 36 testes em 2 classes | Priorizar testes em folha e processamento |

---

## 7. PLANO DE EXECUÇÃO — SPRINTS SUGERIDOS

### Sprint 1 (2 semanas) — Correção de Gaps Críticos
- [ ] Resolver TODOs de criticidade ALTA (CNAB, isFechada, cópia de vantagens)
- [ ] Implementar relatórios faltantes 1-6 (Servidores por Lotação/Cargo, Resumo por Rubrica, Líquido por Banco, Contribuições, IRRF)
- [ ] Implementar Relatório de 13º Salário (#8)
- [ ] Implementar Relatório de Previdência (#14) — resolver link órfão
- [ ] Aumentar cobertura de testes (ProcessamentoFolhaService, FolhaPagamentoService)

### Sprint 2 (3 semanas) — Módulo de Férias
- [ ] Criar entidades: `PeriodoAquisitivo`, `ConcessaoFerias`
- [ ] Implementar cálculo de férias: 1/3 constitucional, abono pecuniário
- [ ] Integrar com folha (rubrica de férias, cálculo proporcional)
- [ ] Criar tela frontend para programação e concessão
- [ ] Criar relatório de férias

### Sprint 3 (2 semanas) — Módulo de Afastamentos
- [ ] Criar entidades: `Afastamento`, `TipoAfastamento` (13 tipos: licença saúde, maternidade, etc.)
- [ ] Impacto na folha: suspensão/redução de rubricas durante afastamento
- [ ] Tela frontend de registro e consulta
- [ ] Preparar dados para eSocial S-2230

### Sprint 4 (2 semanas) — Módulo de Rescisão/Desligamento
- [ ] Criar entidades: `Rescisao`, `TipoDesligamento`
- [ ] Cálculo rescisório: saldo salário, férias proporcionais, 13º proporcional
- [ ] Tela frontend com formulário de desligamento
- [ ] Preparar dados para eSocial S-2299

### Sprint 5 (4 semanas) — eSocial Fase 1 + 3 (Tabelas + Periódicos)
- [ ] Implementar geração de XML conforme leiautes v.S-1.2
- [ ] S-1000, S-1005, S-1010, S-1020, S-1035, S-1040, S-1070
- [ ] S-1200/S-1202 (Remuneração RGPS/RPPS)
- [ ] S-1210 (Pagamentos)
- [ ] S-1298/S-1299 (Reabertura/Fechamento)
- [ ] Comunicação com ambiente de produção restrita (homologação)
- [ ] Implementar certificado digital A1/A3

### Sprint 6 (3 semanas) — eSocial Fase 2 (Não-Periódicos)
- [ ] S-2200 (Admissão/Cadastramento Inicial)
- [ ] S-2205/S-2206 (Alterações cadastrais/contratuais)
- [ ] S-2230 (Afastamentos — depende Sprint 3)
- [ ] S-2299 (Desligamento — depende Sprint 4)
- [ ] S-2416/S-2418/S-2420 (Benefícios RPPS)

### Sprint 7 (2 semanas) — EFD-Reinf + DCTFWeb
- [ ] EFD-Reinf (substitui DIRF): R-1000, R-4010, R-4020, R-4040, R-4099
- [ ] DCTFWeb (substitui GFIP/SEFIP): integração com dados do eSocial
- [ ] Descontinuar exportação DIRF e SEFIP (manter legado para anos anteriores)

### Sprint 8 (2 semanas) — Consignações + CNAB
- [ ] Implementar módulo de consignações (empréstimos em folha)
- [ ] Completar geração do arquivo CNAB 240/400
- [ ] Relatório de margem consignável
- [ ] Relatório de conciliação bancária

### Sprint 9 (3 semanas) — Relatórios e Auditoria
- [ ] Relatórios restantes (7-19 da seção 3.2)
- [ ] Relatórios de conferência (16-19 da seção 3.3)
- [ ] Sistema de log de auditoria
- [ ] Relatório de conferência pré-exportação TCE

### Sprint 10 (3 semanas) — eSocial SST + Módulos Complementares
- [ ] Eventos SST: S-2210, S-2220, S-2240
- [ ] PCCS / Progressão Funcional
- [ ] Aposentadoria / Pensões

---

## 8. ARQUITETURA DE MÓDULOS — ESTADO ATUAL vs PROPOSTA

### 8.1 Estrutura Atual (Real)

```
ws.erh/
├── apoio/           ✅ dashboard, relatorio, tabela
├── cadastro/        ✅ cargo, departamento, dependente, previdencia, servidor, vinculo
├── core/            ✅ base, competencia, config, enums, exception, seeder, storage, tenant
├── dto/             ✅ relatorios
├── facade/          ✅ Facade.java
├── folha/           ✅ calculo, execucao, processamento, rubrica
├── integracao/      ✅ banco
├── model/           ✅ apoio, cadastro, core, folha, integracao, obrigacoes
├── obrigacoes/      ✅ dirf, esocial, rais, sagres, sefip, tce, exportacao, importacao
└── util/            ✅ ReportThemeColors, SecurityUtils
```

### 8.2 Módulos Que Precisam Ser Criados

```
ws.erh/
├── temporal/        ❌ CRIAR
│   ├── ferias/      ❌ (Sprint 2)
│   ├── afastamento/ ❌ (Sprint 3)
│   ├── ponto/       ❌ (Sprint 9+)
│   └── sst/         ❌ (Sprint 10)
├── carreira/        ❌ CRIAR
│   ├── rescisao/    ❌ (Sprint 4) — atualmente "desligamento" via VinculoFuncional
│   ├── progressao/  ❌ (Sprint 10)
│   ├── aposentadoria/ ❌ (Sprint 10)
│   └── concurso/    ❌ (futuro)
├── folha/
│   └── consignado/  ❌ CRIAR (Sprint 8)
└── obrigacoes/
    ├── esocial/     ⚠️ EXPANDIR — adicionar geração de eventos XML (Sprint 5-6)
    ├── reinf/       ❌ CRIAR (Sprint 7) — EFD-Reinf
    └── dctweb/      ❌ CRIAR (Sprint 7) — DCTFWeb
```

---

## 9. MATRIZ DE CONFORMIDADE LEGAL

| Obrigação Legal | Prazo Original | Status | Risco |
|---|---|---|---|
| eSocial Fase 1 (Tabelas) | Jul/2021 | ⚠️ Tabelas existem, falta XML | ALTO — em atraso |
| eSocial Fase 2 (Não-Periódicos) | Nov/2021 | ❌ Não implementado | ALTO — em atraso |
| eSocial Fase 3 (Periódicos/Folha) | Ago/2022 | ❌ Não implementado | CRÍTICO — em atraso |
| eSocial Fase 4 (SST) | Jan/2023 | ❌ Não implementado | ALTO — em atraso |
| Substituição GFIP por DCTFWeb | Out/2022 | ❌ Não implementado | ALTO — mantém SEFIP como paliativo |
| Extinção DIRF → EFD-Reinf | Ano-calendário 2025 | ❌ Não implementado | ALTO — DIRF implementada mas obsoleta |
| SAGRES (TCE-PE) | Mensal | ✅ Implementado | OK |
| RAIS | Anual | ✅ Implementado | OK (em processo de substituição pelo eSocial) |
| Guia RPPS | Mensal | ✅ Implementado | OK |

---

## 10. MÉTRICAS DE QUALIDADE E RECOMENDAÇÕES

### 10.1 Cobertura de Testes

| Módulo | Testes | Cobertura Estimada | Meta |
|---|:---:|:---:|:---:|
| `folha.calculo` | 1 classe | ~15% | 80% |
| `folha.processamento` | 1 classe (34 testes) | ~25% | 80% |
| `cadastro.*` | 0 | 0% | 60% |
| `obrigacoes.*` | 0 | 0% | 70% |
| `core.*` | 0 | 0% | 50% |
| **TOTAL** | **36 testes** | **< 1%** | **> 50%** |

### 10.2 Recomendações Técnicas

1. **Testar antes de expandir** — Priorizar testes no ProcessamentoFolhaService (3000+ linhas, risco alto)
2. **Renumerar migrações** — Resolver conflitos V002/V004/V005 para compatibilidade Flyway
3. **Documentar common** — README.md vazio, módulo compartilhado crítico
4. **Resolver TODOs de segurança** — Usuário logado no ProcessamentoController (linha 231)
5. **Modularizar ProcessamentoFolhaService** — 3000+ linhas, extrair para classes especializadas
6. **Implementar validação pré-exportação** — Relatório de consistência antes de enviar SAGRES/eSocial
7. **Atualizar strategies de exportação** — DIRF2019/RAIS2019/SEFIP2019 estão com sufixo "2019" — considerar versionamento dinâmico

---

## CHANGELOG DESTE DOCUMENTO

| Data | Versão | Alteração |
|---|---|---|
| 09/01/2026 | 2.0 | Plano original criado |
| 19/02/2026 | 3.0 | **Varredura completa** — 359 arquivos Java, 45 páginas frontend auditados. Adicionadas seções: inventário numérico, relatórios completos (19 faltantes), eSocial 4 fases com eventos detalhados, EFD-Reinf/DCTFWeb, matriz de conformidade legal, plano de 10 sprints, bugs/TODOs, métricas de qualidade |
