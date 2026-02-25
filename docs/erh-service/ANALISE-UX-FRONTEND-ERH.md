# Análise UX Completa — Frontend eRH

> **Versão:** 1.0 | **Data:** Fevereiro 2026  
> **Foco:** Simplicidade, Autonomia e Automação para Servidores Públicos Municipais  
> **Stack:** Next.js 14-15 App Router · React 19 · TypeScript 5 · TailwindCSS 4 · MUI · Chart.js

---

## Sumário Executivo

O módulo frontend do eRH é um sistema de gestão de recursos humanos para prefeituras municipais, construído sobre uma arquitetura **config-driven** com CRUD genérico (`useCrudPage` + `CrudPageWrapper`). A análise identificou **43 pontos de melhoria** distribuídos em 10 heurísticas de Nielsen, com foco especial nas necessidades de servidores públicos municipais que lidam com folha de pagamento, cadastros de pessoal e obrigações legais mensais.

### Métricas-Chave

| Métrica | Valor Atual | Meta Ideal |
|---------|-------------|------------|
| Cliques para processar folha | 5 | 3 |
| Cliques para cadastrar servidor | 39+ | 15-20 |
| Cliques para gerar relatório | 4-6 | 2-3 |
| Campos no formulário mais complexo (Legislação) | ~90 | ~15 (auto-preenchidos) |
| Profundidade máxima do menu | 3 níveis | 2 níveis |
| Cobertura de HelpTooltip nos formulários | ~20% | 80%+ |
| Validação inline nos forms | 0% | 100% |
| Cache/memoização nas APIs | 0 | Todas GET |
| Relatórios disponíveis | 5 tipos | 19 tipos |
| Acessibilidade WCAG 2.1 AA | ~30% | 100% |

---

## 1. Arquitetura Frontend

### 1.1 Estrutura de Módulos

```
src/
├── app/(private)/e-RH/
│   ├── dashboard/              # Dashboard personalizável (800 linhas)
│   ├── processamento/          # Folha + 13º + Competência (1085 linhas)
│   ├── cadastro/
│   │   ├── servidor/           # Dados pessoais + dependentes
│   │   ├── legislacao/         # ~90 campos, 7 abas (1214 linhas config)
│   │   ├── cargo/              # CRUD simples
│   │   ├── lotacao/            # CRUD simples
│   │   ├── nivel/              # CRUD simples
│   │   ├── vantagemdesconto/   # Rubricas (vantagens/descontos)
│   │   └── previdencia/
│   │       └── instituto/      # Instituto de Previdência
│   ├── lancamento/
│   │   ├── vinculo-funcional/  # Vínculo + Movimentações + Rubricas
│   │   └── folha-pagamento/    # Visualização individual de servidor
│   ├── configuracao/
│   │   ├── usuario/            # Gestão de usuários
│   │   └── unidade-gestora/    # Configuração da entidade
│   ├── relatorio/              # Central de Relatórios (5 tipos)
│   │   └── folha/              # Sub-relatórios de folha
│   └── sair/                   # Logout
├── components/ui/
│   ├── inputs/                 # 20+ componentes de input
│   │   ├── MovimentacaoVinculo.tsx    # 1426 linhas - MAIS COMPLEXO
│   │   ├── VantagensDescontos.tsx     # 625 linhas
│   │   ├── DetalheVantagemDesconto.tsx # Inline CRUD de rubricas
│   │   ├── ComboboxInput.tsx          # Select com busca
│   │   ├── BooleanInput.tsx           # Toggle Sim/Não
│   │   └── ...15 outros
│   ├── HelpTooltip/            # Tooltip de ajuda contextual
│   ├── FieldLabel/             # Label com integração de help
│   ├── FieldError/             # Mensagem de erro de campo
│   ├── Modal/                  # Modal genérico
│   ├── Tabs/                   # Abas acessíveis
│   ├── Pagination/             # Paginação
│   └── ...7 outros
├── contexts/
│   ├── AuthContext.tsx          # JWT, roles, login/logout
│   ├── CompetenciaContext.tsx   # Mês/Ano de trabalho (260 linhas)
│   ├── UnidadeGestoraContext.tsx # Multi-tenant
│   ├── ThemeContext.tsx         # Temas dinâmicos
│   └── MenuContext.tsx          # Estado do menu lateral
├── features/
│   ├── crud/
│   │   ├── useCrudPage.ts      # Hook genérico CRUD (586 linhas)
│   │   └── CrudPageWrapper.tsx # Layout wrapper (175 linhas)
│   └── e-RH/processamento/
│       ├── processamento.api.ts    # 26 funções API
│       └── processamento.types.ts  # 416 linhas, 20+ interfaces
├── hooks/                      # Hooks customizados
├── lib/helpers/
│   └── validationUtils.ts      # 12 validadores (CPF, CNPJ, etc.)
└── api/
    └── api.tsx                 # Camada genérica HTTP + interceptors
```

### 1.2 Padrão Config-Driven

O sistema usa um padrão declarativo onde cada entidade CRUD é definida por 3 arquivos:

```
[entidade].config.ts  → Campos, abas, validações, help texts, grid layout
[entidade].types.ts   → Interfaces TypeScript
page.tsx              → Página usando CrudPageWrapper + useCrudPage
```

**Vantagem:** Consistência total entre formulários. Adicionar campo = 1 entrada no config.
**Limitação:** Formulários complexos (Legislação, Vínculo) extrapolam o padrão config e precisam de lógica customizada.

### 1.3 Contextos React (5)

| Contexto | Responsabilidade | Persistência | Impacto UX |
|----------|-----------------|--------------|------------|
| `AuthContext` | JWT, roles, login/logout | localStorage | Controle de acesso por role |
| `CompetenciaContext` | Mês/Ano de trabalho | sessionStorage + localStorage | **CRÍTICO** — define escopo de todos os dados |
| `UnidadeGestoraContext` | Multi-tenant (prefeitura) | sessionStorage | Filtragem global de dados |
| `ThemeContext` | Cores, modo claro/escuro | MUI | Personalização visual |
| `MenuContext` | Sidebar aberta/fechada | Estado local | Navegação |

---

## 2. Mapa de Fluxos Implementados

### 2.1 Jornada: Processar Folha de Pagamento

```
┌─────────────────────────────────────────────────────────────────┐
│  Login → Selecionar Competência → Menu "Processamento"          │
│     ↓                                                           │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Tab "Folha de Pagamento"                                │    │
│  │  ┌─────────┐  ┌──────────────┐  ┌───────────────────┐  │    │
│  │  │ QuickStats│  │ Status Badge │  │ InfoBox com regras│  │    │
│  │  └─────────┘  └──────────────┘  └───────────────────┘  │    │
│  │        ↓                                                 │    │
│  │  [Processar Folha] → ConfirmDialog → ProgressBar         │    │
│  │        ↓                                                 │    │
│  │  ResultadoProcessamento (sucesso/parcial/erro)           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Tab "13º Salário"                                       │    │
│  │  Selecionar parcela (Adiantamento/Proporcional/Integral) │    │
│  │  → [Processar 13º] → ConfirmDialog → ProgressBar        │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Tab "Gerenciar Competência"                             │    │
│  │  [Fechar Competência] / [Reabrir] + regras de bloqueio   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Tab "Exportação de Dados"                               │    │
│  │  ModalExportacao (CNAB/Guia RPPS/SAGRES/DIRF/RAIS/SEFIP)│    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

| Etapa | Cliques | API Calls | Observação |
|-------|---------|-----------|------------|
| Navegar ao Processamento | 2 | 0 | Menu nível 2 |
| Validar Competência | 0 (auto) | 2 | `validarCompetencia` + `verificarExportacaoBancaria` |
| Clicar "Processar" | 1 | 0 | — |
| Confirmar diálogo | 1 | 0 | Prevenção de ação acidental |
| Aguardar processamento | 0 | 1 | Barra de progresso **simulada** |
| Visualizar resultado | 0 | 0 | Inline |
| **TOTAL** | **5** | **3** | |

### 2.2 Jornada: Cadastrar Servidor + Vínculo

```
┌────────────────────────────────────────────────────────────────┐
│  1. Cadastrar Servidor (Menu → Cadastros → Servidores)         │
│     ┌──────────────────────────────────────────────────────┐   │
│     │  Tab 1: Dados Pessoais (~20 campos)                   │   │
│     │  CPF, Nome, Endereço, Celular, Escolaridade, etc.     │   │
│     ├──────────────────────────────────────────────────────┤   │
│     │  Tab 2: Dados Bancários + Documentos (~15 campos)     │   │
│     │  Banco, Agência, Conta, RG, PIS, CTPS, etc.          │   │
│     ├──────────────────────────────────────────────────────┤   │
│     │  Tab 3: Dependentes (sub-form inline, variável)       │   │
│     │  5 campos por dependente                              │   │
│     └──────────────────────────────────────────────────────┘   │
│     [Salvar] → 1 API call → Toast sucesso                      │
│                                                                 │
│  2. Criar Vínculo (Menu → Lançamentos → Vínculo Funcional)     │
│     ┌──────────────────────────────────────────────────────┐   │
│     │  Selecionar servidor → Dados do vínculo               │   │
│     │  ↓                                                     │   │
│     │  MovimentacaoVinculo (1426 linhas!)                    │   │
│     │  ┌────────────────────────────────────────────────┐   │   │
│     │  │  Timeline horizontal de movimentações           │   │   │
│     │  │  → Formulário de movimentação (~25 campos)      │   │   │
│     │  │    → Sub-form de rubricas (vantagens/descontos) │   │   │
│     │  │      → 12 campos por rubrica                    │   │   │
│     │  └────────────────────────────────────────────────┘   │   │
│     └──────────────────────────────────────────────────────┘   │
│     [Salvar] → N API calls (vínculo + rubricas)                │
└────────────────────────────────────────────────────────────────┘
```

| Etapa | Interações | Campos | Pain Point |
|-------|-----------|--------|------------|
| Cadastrar servidor | ~39+ | 35+ | Sem indicação de prioridade, sem busca CEP |
| Criar vínculo | ~30+ | 25+ | 3 níveis de formulário aninhado |
| Adicionar rubricas | ~15/rubrica | 12 | Toggle "Nao" sem acento |
| **TOTAL** | **84+** | **72+** | |

### 2.3 Jornada: Configurar Legislação

```
┌───────────────────────────────────────────────────────────┐
│  Menu → Cadastros → Legislação → [Novo]                    │
│                                                             │
│  7 Abas × total ~90 campos:                                │
│  ┌─────────┬──────────────────────────────────────────┐    │
│  │  Geral  │  Competência, Salário Mínimo (3 campos)  │    │
│  ├─────────┼──────────────────────────────────────────┤    │
│  │  RPPS   │  Modo cálculo + 8 faixas progressivas    │    │
│  │         │  = 35+ campos (32 só de faixas)           │    │
│  ├─────────┼──────────────────────────────────────────┤    │
│  │ Guia    │  Configuração de guias RPPS (9 campos)    │    │
│  │ RPPS    │                                           │    │
│  ├─────────┼──────────────────────────────────────────┤    │
│  │  INSS   │  Faixas progressivas (17 campos)          │    │
│  ├─────────┼──────────────────────────────────────────┤    │
│  │  IRRF   │  Faixas + deduções (19 campos)            │    │
│  ├─────────┼──────────────────────────────────────────┤    │
│  │ Benefí- │  Salário Família + configs (9 campos)     │    │
│  │ cios    │                                           │    │
│  ├─────────┼──────────────────────────────────────────┤    │
│  │  13º    │  Configurações de 13º salário             │    │
│  └─────────┴──────────────────────────────────────────┘    │
│                                                             │
│  ⚠️  Todos os valores devem ser digitados manualmente!      │
│  Não há preenchimento automático com tabela federal.        │
└───────────────────────────────────────────────────────────┘
```

### 2.4 Jornada: Gerar Relatório

```
┌──────────────────────────────────────────────────┐
│  Menu → Central de Relatórios                     │
│                                                    │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐          │
│  │  Folha  │  │ Resumida │  │Holerite │          │
│  │  PG     │  │          │  │         │          │
│  └────┬────┘  └────┬────┘  └────┬────┘          │
│       ↓             ↓            ↓                │
│  Modal com filtros → Competência + Lotação/Cargo  │
│       ↓                                           │
│  [Gerar] → PDF download                           │
│                                                    │
│  ✅ Cards visuais com ícone e descrição            │
│  ✅ Instrução "Como usar" (4 passos)               │
│  ❌ Sem favoritos/recentes                         │
│  ❌ Sem preview antes do download                  │
└──────────────────────────────────────────────────┘
```

### 2.5 Dashboard Personalizável

```
┌──────────────────────────────────────────────────────────────┐
│  15 widgets configuráveis:                                    │
│                                                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐        │
│  │Competênc.│ │Servidores│ │ Vínculos │ │  Folha   │        │
│  │  📅      │ │  👥 123  │ │  📋 156  │ │ R$ 1.2M  │        │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘        │
│                                                                │
│  ┌────────────────────┐ ┌────────────────────┐               │
│  │ 📊 Vínculos/Tipo   │ │ 🍩 Composição Folha│               │
│  │  (Bar Chart)       │ │  (Doughnut Chart)  │               │
│  └────────────────────┘ └────────────────────┘               │
│                                                                │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │ Lotações │ │  Cargos  │ │Dependents│                      │
│  │ (bars)   │ │ (bars)   │ │  👶 45   │                      │
│  └──────────┘ └──────────┘ └──────────┘                      │
│                                                                │
│  ✅ Persistência em localStorage                               │
│  ✅ Grid auto-fit responsivo                                   │
│  ✅ Valores monetários compactos (R$ 1.5M)                     │
│  ✅ Formatação pt-BR (Intl.NumberFormat)                       │
└──────────────────────────────────────────────────────────────┘
```

---

## 3. Análise Heurística de Nielsen

### H1 — Visibilidade do Status do Sistema

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 1.1 | Barra de progresso do processamento é **simulada** (`setInterval` de 800ms) — não reflete progresso real | **Alta** | processamento/page.tsx | Implementar WebSocket/SSE para progresso real servidor-por-servidor |
| 1.2 | Sem indicação de quantos servidores estão na fila de processamento | **Média** | processamento/page.tsx | Mostrar "Processando X de Y servidores" com progresso real |
| 1.3 | `StatusBadge` da competência usa cores sem texto redundante para daltônicos | **Média** | processamento/page.tsx | Adicionar ícone (✓/⚠/✕) junto à cor |
| 1.4 | Loading states separados (isLoading, isSaving, isDeleting) — bom | **✅ OK** | useCrudPage.ts | Manter |
| 1.5 | Toast de sucesso pós-save com SweetAlert — visível e claro | **✅ OK** | useCrudPage.ts | Manter |
| 1.6 | QuickStats no processamento (servidores ativos, folhas processadas) | **✅ OK** | processamento/page.tsx | Manter |

**Nota para servidores municipais:** O processamento de folha é a tarefa mais crítica e ansiogênica. Uma barra falsa aumenta incerteza. Com WebSocket, o servidor vê em tempo real: "Processando Maria Silva (34/200)..."

---

### H2 — Compatibilidade entre Sistema e Mundo Real

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 2.1 | Conceito de "Competência" (MM/AAAA) pode confundir — não é linguagem do dia-a-dia | **Média** | CompetenciaContext.tsx | Exibir como "Folha de Janeiro/2026" em vez de "Competência 01/2026" |
| 2.2 | Tradução de erros técnicos para português funcional | **✅ OK** | processamento/page.tsx (`traduzirErro`) | Expandir para todas as páginas |
| 2.3 | Labels de status em português com cores semânticas (Verde=Aberta, Vermelha=Fechada) | **✅ OK** | processamento.types.ts | Manter |
| 2.4 | Menu usa terminologia técnica de RH (Lotação, Vínculo Funcional, Rubrica) | **Baixa** | eRhConfig.ts | Adicionar subtítulo explicativo: "Lotação (Setor de trabalho)" |
| 2.5 | Tooltips de ajuda com referências legais (EC 103/2019, Lei 4.090/62) | **✅ OK** | legislacao.config.ts | Expandir cobertura de ~20% para 80%+ |
| 2.6 | Formatação monetária BR (Intl.NumberFormat pt-BR) | **✅ OK** | dashboard/page.tsx | Manter |

**Nota para servidores municipais:** Um servidor da prefeitura de cidade pequena pode não saber o que é "RPPS progressivo" ou "alíquota patronal". Subtítulos explicativos e um glossário integrado reduziriam drasticamente as chamadas de suporte.

---

### H3 — Controle e Liberdade do Usuário

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 3.1 | **Sem Undo/Redo** em nenhum formulário | **Alta** | Global | Implementar Ctrl+Z com histórico de estados no `useCrudPage` |
| 3.2 | Confirmação antes de deletar e antes de fechar competência | **✅ OK** | useCrudPage.ts, processamento | Manter |
| 3.3 | `AbortController` permite cancelar processamento em andamento | **✅ OK** | processamento/page.tsx | Manter |
| 3.4 | Sem "Rascunho" — formulário fechado = dados perdidos | **Alta** | Global | Salvar rascunhos em localStorage com auto-restore |
| 3.5 | Reabrir competência disponível (com confirmação) | **✅ OK** | processamento/page.tsx | Manter |
| 3.6 | Sem botão "Voltar" ou breadcrumb funcional em todas as páginas | **Média** | CrudPageWrapper.tsx | O `Cabecalho` tem breadcrumb — verificar se é clicável |

**Nota para servidores municipais:** Um servidor preenchendo cadastro de 35 campos que fecha a aba acidentalmente perde tudo. Auto-save de rascunho é essencial.

---

### H4 — Consistência e Padrões

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 4.1 | Padrão config-driven consistente para todos os CRUDs simples | **✅ OK** | *.config.ts | Manter |
| 4.2 | Erro exibido ora via `toast.error` ora via `Swal.fire` — inconsistente | **Média** | useCrudPage.ts vs processamento | Padronizar: Toast para feedback rápido, Swal para confirmações |
| 4.3 | Toggle "Sim/Nao" (sem acento) em `DetalheVantagemDesconto` | **Baixa** | DetalheVantagemDesconto.tsx | Corrigir para "Sim/Não" |
| 4.4 | Aliases deprecated mantidos para retrocompatibilidade (`totalProcessados`, `totalSucesso`) | **Baixa** | processamento.types.ts | Remover em próxima major version |
| 4.5 | Variáveis bilíngues (pt/en): `dadosTabela`/`tableData` — confuso para manutenção | **Média** | useCrudPage.ts | Padronizar em português (código BR) |
| 4.6 | Todos os forms usam grid de 6 colunas via config | **✅ OK** | *.config.ts | Manter |
| 4.7 | SweetAlert com `confirmButtonColor` extraído de CSS var `--theme-primary` | **✅ OK** | CompetenciaContext.tsx | Manter |

---

### H5 — Prevenção de Erros

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 5.1 | **Legislação sem pré-preenchimento** — ~90 campos digitados manualmente com valores que são públicos (tabela IRRF, INSS federal) | **Crítica** | legislacao.config.ts | Botão "Carregar Tabela Federal 2026" que preenche ~60 campos |
| 5.2 | Validação sequencial via toast (1 erro por vez) | **Alta** | DetalheVantagemDesconto.tsx | Validação inline com highlight de TODOS os campos inválidos |
| 5.3 | Bloqueio de processamento quando dados bancários exportados | **✅ OK** | processamento/page.tsx | Manter — com mensagem explicativa |
| 5.4 | Validação de competência com 5 cenários (futuro, sem folha, fechada, etc.) | **✅ OK** | CompetenciaContext.tsx | Manter |
| 5.5 | `obrigatorioCondicional` no MovimentacaoVinculo (campo obrigatório depende de outro) | **✅ OK** | MovimentacaoVinculo.tsx | Manter |
| 5.6 | Ao mudar natureza para PROVENTO, auto-seta incidências corretas | **✅ OK** | DetalheVantagemDesconto.tsx | Expandir para mais campos |
| 5.7 | Sem validação de faixa para alíquotas (0-100%) na legislação | **Média** | legislacao.config.ts | Adicionar `min: 0, max: 100` nas configs |
| 5.8 | `validationUtils.ts` não tem validação de competência (YYYY-MM) nem valores monetários | **Média** | validationUtils.ts | Adicionar `isCompetencia()` e `isMonetario()` |
| 5.9 | Sem confirmação ao sair de formulário com dados não salvos | **Alta** | Global | Implementar `beforeunload` + prompt de navegação |

**Nota para servidores municipais:** O item 5.1 é o mais impactante. Servidores municipais digitam manualmente tabelas federais que mudam 1x/ano. Um botão de auto-preenchimento economizaria ~30 minutos por competência, eliminando erros de digitação que causam cálculos incorretos de IRRF/INSS.

---

### H6 — Reconhecimento em vez de Recordação

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 6.1 | **Sem templates de relatórios** — servidor que gera mesmos filtros todo mês precisa refazer | **Alta** | relatorio/page.tsx | Salvar "Meus Relatórios Favoritos" com filtros pré-configurados |
| 6.2 | Sem "Último processamento" no QuickStats (data + hora) | **Média** | processamento/page.tsx | QuickStats já mostra — verificar se inclui data/hora |
| 6.3 | Dashboard com widgets personalizáveis e persistência | **✅ OK** | dashboard/page.tsx | Manter |
| 6.4 | Seletor de competência sempre visível na sidebar | **✅ OK** | Sidebar.tsx | Manter |
| 6.5 | Placeholders com exemplos reais (Ex: "1.518,00", "7,50%") | **✅ OK** | legislacao.config.ts | Expandir para todos os campos numéricos |
| 6.6 | **15 sub-itens em Tabelas TCE** enterrados em 3 níveis | **Média** | eRhConfig.ts | Agrupar por frequência de uso ou criar "Favoritos" |
| 6.7 | Sem histórico de ações recentes | **Alta** | Global | Implementar "Ações Recentes" no dashboard |

**Nota para servidores municipais:** Servidores repetem as mesmas tarefas todo mês. "Favoritos" + "Ações Recentes" transformam ~6 cliques em 1 clique para tarefas rotineiras.

---

### H7 — Flexibilidade e Eficiência de Uso

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 7.1 | **Sem atalhos de teclado** (exceto Ctrl+P e Ctrl+F no processamento) | **Alta** | Global | Implementar: Ctrl+S (salvar), Ctrl+N (novo), Ctrl+F (buscar), Ctrl+P (processar) |
| 7.2 | Sem busca global ("Command Palette") | **Alta** | Global | Barra de busca universal: "processar folha", "cadastrar servidor", "relatório holerite" |
| 7.3 | Dashboard personalizável com drag não implementado | **Média** | dashboard/page.tsx | Toggles existem — considerar drag & drop futuro |
| 7.4 | Processamento sem batch scheduling (agendar para horário específico) | **Média** | processamento/page.tsx | "Processar automaticamente dia 25 às 18h" |
| 7.5 | Sem acesso rápido a um servidor específico (busca por CPF no header) | **Alta** | Global | Campo de busca rápida no header: "Buscar servidor por CPF ou nome" |
| 7.6 | "Copiar legislação da competência anterior" existe no backend mas não está no frontend | **Alta** | legislacao.config.ts | Botão "Copiar da Competência Anterior" que chama flag `copiarLegislacao` |

**Nota para servidores municipais:** Atalhos e busca universal são diferenciais enormes para usuários que processam folha de 200+ servidores mensalmente.

---

### H8 — Design Estético e Minimalista

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 8.1 | Dashboard bem organizado com gradientes e badges | **✅ OK** | dashboard/page.tsx | Manter |
| 8.2 | Formulário de Legislação com ~90 campos é intimidador mesmo com abas | **Alta** | legislacao.config.ts | Progressive disclosure: mostrar apenas campos alterados vs. competência anterior |
| 8.3 | MovimentacaoVinculo exibe tudo de uma vez (1426 linhas de UI) | **Alta** | MovimentacaoVinculo.tsx | Wizard step-by-step: Dados básicos → Regime → Rubricas |
| 8.4 | Tab 2 do Servidor mistura "Dados Bancários" com "Documentos Pessoais" | **Média** | servidor.config.ts | Separar em 2 abas distintas |
| 8.5 | InfoBox com instruções claras por tab no processamento | **✅ OK** | processamento/page.tsx | Expandir para todas as páginas |
| 8.6 | Cards de relatório com ícone + descrição curta | **✅ OK** | relatorio/page.tsx | Manter |
| 8.7 | Seções informativas com emojis (📋, 📊, ⚠️) na Legislação | **✅ OK** | legislacao.config.ts | Manter — ajuda na orientação visual |

---

### H9 — Ajudar Usuários a Reconhecer, Diagnosticar e Recuperar-se de Erros

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 9.1 | `traduzirErro()` converte erros técnicos para português | **✅ OK** | processamento/page.tsx | Expandir para camada global (`api.tsx`) |
| 9.2 | `collectApiErrorMessages()` extrai mensagens de 5 formatos de erro | **✅ OK** | api.tsx | Usar consistentemente em todo o frontend |
| 9.3 | `generica()` retorna `error.response` silenciosamente sem feedback visual | **Crítica** | api.tsx | Interceptor global com toast para erros 4xx/5xx |
| 9.4 | Erro 401 comentado no interceptor — potencial falha silenciosa | **Alta** | api.tsx | Implementar redirect para login com mensagem "Sessão expirada" |
| 9.5 | Erros de processamento mostram lista de servidores que falharam | **✅ OK** | processamento/page.tsx | Adicionar ação "Reprocessar apenas falhas" |
| 9.6 | Empty states com ícone Inbox + texto explicativo no dashboard | **✅ OK** | dashboard/page.tsx | Expandir para todas as listagens |
| 9.7 | Dashboard tem estado de erro com SVG + "Tentar novamente" | **✅ OK** | dashboard/page.tsx | Expandir para todas as páginas |

---

### H10 — Ajuda e Documentação

| # | Achado | Severidade | Local | Recomendação |
|---|--------|-----------|-------|-------------|
| 10.1 | HelpTooltip com design profissional (gradiente, seta, reposicionamento) | **✅ OK** | HelpTooltip.tsx | Manter |
| 10.2 | **Apenas ~20% dos campos** têm tooltip de ajuda | **Alta** | *.config.ts | Expandir para 80%+ com descrição em linguagem simples |
| 10.3 | Seção de ajuda expandível com FAQ no processamento | **✅ OK** | processamento/page.tsx | Replicar em todas as páginas |
| 10.4 | Instrução "Como usar" (4 passos) na página de relatórios | **✅ OK** | relatorio/page.tsx | Replicar em todas as páginas |
| 10.5 | **Sem glossário integrado** — termos como "RPPS", "IRRF", "rubrica" sem explicação acessível | **Alta** | Global | Glossário no footer da sidebar com busca |
| 10.6 | **Sem tour/onboarding** para primeiro acesso | **Alta** | Global | Implementar tour guiado: "Bem-vindo ao eRH! Primeiro, configure sua Unidade Gestora..." |
| 10.7 | HelpTooltip com `tabIndex={-1}` — inacessível via teclado | **Alta** | HelpTooltip.tsx | Mudar para `tabIndex={0}` |
| 10.8 | Link "Ajuda" no footer da sidebar — destino desconhecido | **Média** | Sidebar.tsx | Direcionar para documentação/FAQ contextual |

---

## 4. Análise de Acessibilidade (WCAG 2.1 AA)

### 4.1 Conformidade Atual

| Critério WCAG | Status | Detalhes |
|--------------|--------|---------|
| **1.1.1 Conteúdo não textual** | ⚠️ Parcial | Gráficos Chart.js sem alt text; SVGs com `title` parcial |
| **1.3.1 Informação e relações** | ⚠️ Parcial | Labels semânticos nos inputs base; falta `fieldset`/`legend` nos grupos |
| **1.4.1 Uso de cor** | ❌ Falha | Status badges dependem apenas de cor (sem ícone redundante) |
| **1.4.3 Contraste** | ⚠️ Não testado | Temas dinâmicos — necessita verificação por tema |
| **2.1.1 Teclado** | ❌ Falha | Sidebar sem keyboard nav; Timeline sem keyboard nav; HelpTooltip inacessível |
| **2.4.1 Blocos bypass** | ❌ Falha | Sem skip links; sem landmarks (`role="navigation"`, `role="main"`) |
| **2.4.3 Ordem de foco** | ⚠️ Parcial | Forms base OK; modals customizados sem focus trap |
| **2.4.6 Cabeçalhos** | ⚠️ Parcial | H1 no título de página; inconsistente em sub-seções |
| **3.3.1 Identificação do erro** | ⚠️ Parcial | Toast identifica erros mas não vincula ao campo específico |
| **3.3.3 Sugestão de erro** | ❌ Falha | Erros não sugerem correção (ex: "CPF inválido" sem formato esperado) |
| **4.1.2 Nome, Função, Valor** | ⚠️ Parcial | Componentes base com aria; componentes customizados sem |

### 4.2 Gaps Críticos de Acessibilidade

| Prioridade | Componente | Gap | Correção |
|-----------|-----------|-----|---------|
| **P0** | Sidebar.tsx | Sem `role="navigation"`, sem keyboard navigation | Adicionar `role`, `aria-label`, `onKeyDown` handlers |
| **P0** | HelpTooltip.tsx | `tabIndex={-1}` impede acesso via Tab | Mudar para `tabIndex={0}` |
| **P1** | MovimentacaoVinculo.tsx | Timeline sem keyboard nav, sem `aria-expanded` nos collapses | Implementar arrow key navigation, aria states |
| **P1** | processamento/page.tsx | StatusBadge sem indicador textual para daltônicos | Adicionar ícone (✓/⚠/✕) |
| **P1** | dashboard/page.tsx | Gráficos Chart.js sem `aria-label` ou tabela alternativa | Tabela de dados acessível como fallback |
| **P2** | DetalheVantagemDesconto.tsx | Toggle "Sim/Nao" sem `role="switch"` nem `aria-checked` | Implementar switch pattern ARIA |
| **P2** | Global | Sem skip links no layout | Adicionar "Pular para conteúdo principal" |
| **P2** | CrudPageWrapper.tsx | Sem landmarks semânticos | Adicionar `<main>`, `<nav>`, `<aside>` |

---

## 5. Oportunidades de Automação

As oportunidades são classificadas pelo impacto direto na rotina do servidor público municipal.

### 5.1 Automação de Alto Impacto

| # | Oportunidade | Economia/Mês | Esforço Dev | ROI |
|---|-------------|-------------|-------------|-----|
| **A1** | **Auto-preenchimento de Legislação** — Botão "Carregar Tabela Federal 2026" que preenche IRRF, INSS, RPPS com valores vigentes do governo federal | ~30 min/competência eliminando ~60 campos manuais | 3-5 dias | **Altíssimo** |
| **A2** | **Copiar Legislação da Competência Anterior** — O backend já tem flag `copiarLegislacao` mas o frontend não expõe | ~15 min/mês | 1 dia | **Altíssimo** |
| **A3** | **Processamento com WebSocket** — Progresso real servidor-por-servidor substituindo barra simulada | Reduz ansiedade + permite pausar/retomar | 5-8 dias | **Alto** |
| **A4** | **Busca CEP integrada** (ViaCEP API) no cadastro de servidor — auto-preencher endereço | ~5 min × N cadastros | 1 dia | **Alto** |
| **A5** | **Endpoint `/processamento/pre-check`** unificando `validarCompetencia` + `verificarExportacaoBancaria` | 1 roundtrip × N processamentos | 2 dias | **Médio** |

### 5.2 Automação de Médio Impacto

| # | Oportunidade | Economia/Mês | Esforço Dev |
|---|-------------|-------------|-------------|
| **A6** | **Templates de Relatórios Favoritos** — Salvar filtros recorrentes com 1 clique | 3-4 cliques/relatório × repetições mensais | 2-3 dias |
| **A7** | **Validação Inline** em todos os formulários — highlight de todos campos inválidos em vez de toast sequencial | Reduz ciclos de correção (estimado 50%) | 3-5 dias |
| **A8** | **Auto-save de Rascunho** em localStorage com restore automático | Elimina re-digitação após fechamento acidental | 2-3 dias |
| **A9** | **Busca Global (Command Palette)** — `Ctrl+K` para acessar qualquer função | Reduz navegação de 3-4 cliques para 1 | 3-5 dias |
| **A10** | **Ações Recentes** no dashboard — lista das últimas 10 ações com re-execução | 2-3 cliques/ação recorrente | 2 dias |

### 5.3 Automação de Longo Prazo

| # | Oportunidade | Impacto | Esforço Dev |
|---|-------------|---------|-------------|
| **A11** | **Agendamento de Processamento** — "Processar automaticamente dia 25 às 18h" | Elimina necessidade de presença no momento do processamento | 10-15 dias |
| **A12** | **Detecção de Anomalias** — Alertar quando folha difere >10% da anterior | Prevenção de erros em massa | 5-8 dias |
| **A13** | **Importação em Lote** — CSV/Excel para carga inicial de servidores e vínculos | Elimina cadastro individual de 200+ servidores na implantação | 8-12 dias |
| **A14** | **eSocial Automático** — Queue de eventos com envio programado aos prazos legais | Conformidade legal sem intervenção manual | 20-30 dias |
| **A15** | **Dashboard Inteligente** — Alertas proativos ("Faltam 3 dias para fechar a competência") | Autonomia total do servidor | 5 dias |

---

## 6. Complexidade por Componente

### 6.1 Mapa de Calor de Complexidade

```
                        Complexidade de Código
                   Baixa ◄──────────────────► Extrema

MovimentacaoVinculo  ████████████████████████████████ 1426 linhas
legislacao.config    ██████████████████████████████   1214 linhas
ModalExportacao      █████████████████████████████    1277 linhas
processamento/page   ████████████████████████████     1085 linhas
dashboard/page       ██████████████████████           800  linhas
VantagensDescontos   ████████████████                 625  linhas
useCrudPage          █████████████                    586  linhas
processamento.types  ██████████                       416  linhas
CompetenciaContext   ██████                           260  linhas
servidor/page        █████                            208  linhas
CrudPageWrapper      ████                             175  linhas
Sidebar              ███                              135  linhas
```

### 6.2 Avaliação de Risco UX por Página

| Página | Complexidade | Frequência de Uso | Risco UX | Ação Prioritária |
|--------|-------------|-------------------|---------|-----------------|
| **Processamento** | Muito Alta | Mensal (obrigatório) | 🔴 Alto | WebSocket, pre-check endpoint |
| **Legislação** | Muito Alta | Mensal/Anual | 🔴 Alto | Auto-preenchimento, copiar anterior |
| **Vínculo Funcional** | Extrema | Admissões/Mudanças | 🔴 Alto | Wizard step-by-step, simplificar |
| **Dashboard** | Alta | Diário | 🟡 Médio | Alertas proativos, ações recentes |
| **Servidor** | Média | Admissões | 🟡 Médio | Busca CEP, rascunho, indicar prioridade |
| **Relatórios** | Baixa | Mensal | 🟢 Baixo | Templates favoritos |
| **Cadastros CRUD** | Baixa | Eventual | 🟢 Baixo | Manter padrão atual |

---

## 7. Estratégias de Melhoria

### 7.1 Sprint 1 — Quick Wins (1-2 semanas)

**Tema: Eliminar fricção imediata**

| # | Tarefa | Impacto | Esforço |
|---|--------|---------|---------|
| 1 | **Copiar legislação da competência anterior** (frontend p/ flag backend) | Crítico | 1 dia |
| 2 | **Corrigir "Nao" → "Não"** em DetalheVantagemDesconto | Baixo | 1 hora |
| 3 | **HelpTooltip `tabIndex={0}`** para acessibilidade via teclado | Médio | 1 hora |
| 4 | **Sidebar `role="navigation"` + `aria-label`** | Médio | 2 horas |
| 5 | **Interceptor global de erros** em `api.tsx` com toast para 4xx/5xx | Alto | 1 dia |
| 6 | **Expandir tooltips de ajuda** de 20% para 50% dos campos | Alto | 2-3 dias |
| 7 | **Validação de faixa** (0-100%) para alíquotas na legislação | Médio | 2 horas |
| 8 | **StatusBadge com ícone** redundante para daltônicos | Médio | 2 horas |

### 7.2 Sprint 2 — Automação Core (2-3 semanas)

**Tema: Reduzir trabalho manual repetitivo**

| # | Tarefa | Impacto | Esforço |
|---|--------|---------|---------|
| 1 | **Auto-preenchimento de Legislação** com tabela federal vigente | Crítico | 3-5 dias |
| 2 | **Busca CEP** (ViaCEP) no cadastro de servidor | Alto | 1 dia |
| 3 | **Validação inline** com highlight de campos inválidos (substituir toast sequencial) | Alto | 3-5 dias |
| 4 | **Auto-save de rascunho** em localStorage para formulários grandes | Alto | 2-3 dias |
| 5 | **Prompt "Dados não salvos"** ao navegar com formulário sujo | Alto | 1 dia |

### 7.3 Sprint 3 — Experiência Avançada (3-4 semanas)

**Tema: Autonomia e eficiência para usuários recorrentes**

| # | Tarefa | Impacto | Esforço |
|---|--------|---------|---------|
| 1 | **WebSocket para processamento real** servidor-por-servidor | Alto | 5-8 dias |
| 2 | **Busca Global (Command Palette)** com Ctrl+K | Alto | 3-5 dias |
| 3 | **Templates de relatórios favoritos** | Médio | 2-3 dias |
| 4 | **Ações recentes** no dashboard | Médio | 2 dias |
| 5 | **Tour/onboarding** para primeiro acesso | Médio | 3-5 dias |
| 6 | **Glossário integrado** de termos RH/previdenciários | Médio | 2-3 dias |

### 7.4 Sprint 4 — Refinamento e Acessibilidade (2-3 semanas)

**Tema: Conformidade e inclusão**

| # | Tarefa | Impacto | Esforço |
|---|--------|---------|---------|
| 1 | **Keyboard navigation** completa (Sidebar, Timeline, Modals) | Alto | 3-5 dias |
| 2 | **Focus trap** em todos os modais e dialogs | Médio | 2 dias |
| 3 | **Skip links** no layout | Médio | 1 dia |
| 4 | **Tabela alternativa** para gráficos Chart.js | Médio | 2 dias |
| 5 | **Landmarks semânticos** (`<main>`, `<nav>`, `<aside>`) | Médio | 1 dia |
| 6 | **Testes de contraste** por tema | Médio | 2 dias |
| 7 | **aria-live** para feedback dinâmico | Médio | 2 dias |

---

## 8. Simplificação dos Fluxos Complexos

### 8.1 Proposta: Wizard para Vínculo Funcional

**Antes (atual):** Tudo em uma tela com 3 níveis de formulário aninhado (1426 linhas)

**Depois (proposto):**

```
┌─────────────────────────────────────────────────────────────┐
│  Passo 1/4: Dados Básicos         [━━━━░░░░░░░░]  25%      │
│                                                              │
│  Servidor: [Buscar por CPF ou nome...        🔍]            │
│  Data de admissão: [DD/MM/AAAA]                             │
│  Regime jurídico: (●) Estatutário (○) CLT (○) Comissionado │
│                                                              │
│                              [Voltar]  [Próximo →]          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Passo 2/4: Cargo e Lotação       [━━━━━━━░░░░░]  50%      │
│                                                              │
│  Cargo: [Selecionar...           ▼]                         │
│  Lotação: [Selecionar...         ▼]                         │
│  Nível: [Auto-preenchido por cargo]                         │
│  Carga horária: [Auto-preenchido por cargo]                 │
│                                                              │
│                              [← Voltar]  [Próximo →]        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Passo 3/4: Regime Previdenciário  [━━━━━━━━━░░░]  75%      │
│                                                              │
│  Previdência: (●) RPPS (○) INSS                            │
│  Instituto: [Auto-selecionado se 1 só] ▼                    │
│  Matrícula: [Gerada automaticamente]                        │
│                                                              │
│                              [← Voltar]  [Próximo →]        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  Passo 4/4: Rubricas (Opcional)    [━━━━━━━━━━━━]  100%     │
│                                                              │
│  📋 Rubricas padrão do cargo foram adicionadas automati-    │
│     camente. Revise ou adicione outras.                     │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ ✓ Vencimento Base    R$ 1.518,00   Fixa  Automático │   │
│  │ ✓ RPPS Servidor      -              Fixa  Automático │   │
│  │ ✓ IRRF               -              Fixa  Automático │   │
│  │ + Adicionar rubrica                                   │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│                              [← Voltar]  [✓ Salvar]        │
└─────────────────────────────────────────────────────────────┘
```

**Benefícios:**
- De **84+ interações** para **~20 interações**
- Auto-preenchimento de campos derivados (nível, carga horária, matrícula)
- Rubricas padrão do cargo adicionadas automaticamente
- Progresso visual claro (25% → 50% → 75% → 100%)

### 8.2 Proposta: Legislação com Progressive Disclosure

**Antes:** 90 campos visíveis em 7 abas

**Depois:**

```
┌──────────────────────────────────────────────────────────────┐
│  Legislação — Competência 01/2026                            │
│                                                               │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ ⚡ Ação Rápida                                          │ │
│  │ [Copiar da competência anterior (12/2025)]              │ │
│  │ [Carregar tabela federal vigente 2026]                  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  📊 Resumo (campos alterados vs. competência anterior):      │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ RPPS: Alíquota 14% → 14%  (sem alteração)    [Editar]  │ │
│  │ INSS: Faixas atualizadas ⚠️ 3 alterações    [Editar]  │ │
│  │ IRRF: Sem alteração                          [Editar]  │ │
│  │ Sal. Família: Sem alteração                  [Editar]  │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                               │
│  💡 Apenas campos que mudaram estão destacados.              │
│     Campos iguais à competência anterior estão recolhidos.   │
│                                                               │
│                                    [Salvar Legislação]       │
└──────────────────────────────────────────────────────────────┘
```

**Benefícios:**
- De **~90 campos manuais** para **~5 cliques** (copiar + revisar diferenças)
- Destaque visual apenas do que mudou
- Botão de carga federal elimina digitação de tabelas públicas

### 8.3 Proposta: Processamento com Progresso Real

```
┌──────────────────────────────────────────────────────────────┐
│  Processando Folha de Pagamento — 01/2026                    │
│                                                               │
│  ████████████████████████░░░░░░░░  156/200 servidores (78%) │
│                                                               │
│  ⏱️ Tempo estimado: ~2 min restantes                         │
│  ✅ 154 processados com sucesso                               │
│  ⚠️  2 com avisos                                             │
│  ❌  0 com erro                                               │
│                                                               │
│  Último processado: Maria da Silva (CPF ***456)   ✅          │
│  Atual: João Santos (CPF ***789)                  ⏳          │
│                                                               │
│                                           [Cancelar]         │
└──────────────────────────────────────────────────────────────┘
```

---

## 9. Componentes UI — Pontos Fortes

É importante registrar os padrões positivos já implementados que devem ser mantidos e replicados:

| Componente | Padrão Positivo | Onde Replicar |
|-----------|----------------|--------------|
| **Config-driven forms** | Uma entrada no config = campo completo com label, validação, help, grid | Manter para todos os CRUDs |
| **CompetenciaContext** | 5 cenários de validação com mensagens contextuais | Modelo para outros contextos |
| **traduzirErro()** | Erros técnicos → linguagem do usuário | Expandir para camada global |
| **InfoBox por tab** | Instruções claras antes de cada ação | Replicar em todas as páginas |
| **Dashboard personaliz.** | Widgets toggle + persistência localStorage | Modelo para preferências |
| **Auto-incidência** | Ao selecionar PROVENTO, incidências auto-setadas | Expandir auto-fill p/ mais campos |
| **StatusBadge** | Labels em português + cores semânticas | Adicionar ícone redundante |
| **Formatação pt-BR** | `Intl.NumberFormat`, datas, moeda | Verificar consistência global |
| **Cards de relatório** | Visual com ícone + descrição + "Como usar" | Manter |
| **SweetAlert temática** | `confirmButtonColor` do CSS theme var | Manter |
| **Refs anti-duplicação** | `initialLoadDoneRef`, `opcoesCarregadasRef` | Padrão para todos os hooks |
| **Empty states** | Ícone + texto explicativo | Replicar em todas as listagens |

---

## 10. Matriz de Priorização (Impacto × Esforço)

```
                        IMPACTO
                   Baixo ◄──────────────────► Alto
          ┌─────────────────────────────────────────┐
    Baixo │  Corrigir "Nao"→"Não"   │  Copiar         │
          │  StatusBadge c/ ícone   │  Legislação     │
          │  HelpTooltip tabIndex   │  Anterior (A2)  │
          │  Sidebar role="nav"     │                 │
   E      │  Validação faixas       │  Busca CEP (A4) │
   S      ├─────────────────────────┼─────────────────┤
   F      │  Glossário              │  Auto-preencher │
   O      │  Templates relatórios   │  Legislação (A1)│
   R      │  Ações recentes         │  Validação      │
   Ç      │                         │  Inline (A7)    │
   O      │                         │  Auto-save (A8) │
          ├─────────────────────────┼─────────────────┤
          │  Tour/Onboarding        │  WebSocket (A3) │
    Alto  │  Atalhos teclado        │  Busca Global   │
          │  Keyboard nav completa  │  Wizard Vínculo │
          │  Drag & Drop Dashboard  │  Import CSV     │
          │                         │  eSocial Auto   │
          └─────────────────────────────────────────────┘
```

**Leitura:** O quadrante superior-direito (Alto Impacto, Baixo Esforço) contém as prioridades absolutas:
1. **Copiar Legislação Anterior** — 1 dia de dev, elimina 15 min/mês
2. **Busca CEP** — 1 dia, elimina 5 campos × N cadastros
3. **Auto-preenchimento de Legislação** — 3-5 dias, elimina 30 min/competência

---

## 11. Alinhamento com Plano de Refatoração

Esta análise UX complementa o [PLANO-REFATORACAO-ATUALIZADO-2026-02.md](PLANO-REFATORACAO-ATUALIZADO-2026-02.md) com foco no frontend:

| Sprint do Plano | Melhoria UX Correspondente |
|----------------|---------------------------|
| Sprint 1 (Estabilidade) | Interceptor global de erros, validação inline, auto-save |
| Sprint 2 (Cadastros) | Busca CEP, wizard vínculo, tooltips expandidos |
| Sprint 3 (Cálculos) | Auto-preenchimento legislação, copiar competência anterior |
| Sprint 4 (Processamento) | WebSocket progresso real, pre-check endpoint |
| Sprint 5 (Relatórios) | Templates favoritos, preview PDF, 19 relatórios |
| Sprint 6 (eSocial) | Alertas proativos, queue automática, dashboard inteligente |
| Sprint 7 (Acessibilidade) | WCAG 2.1 AA completo, keyboard nav, landmarks |
| Sprint 8 (Automação) | Command palette, ações recentes, agendamento |

---

## 12. Conclusão

### Diagnóstico Geral

O frontend do eRH possui uma **arquitetura sólida** (config-driven, CRUD genérico, contextos bem encapsulados) mas sofre de **automação insuficiente** e **feedback inadequado** — os dois maiores problemas para o público-alvo de servidores públicos municipais.

### Os 3 Pilares para o Servidor Municipal

| Pilar | Estado Atual | Visão Futura |
|-------|-------------|-------------|
| **Simplicidade** | Formulários densos (90 campos na legislação, 3 níveis no vínculo), menu profundo (3 níveis, 35+ itens) | Wizard step-by-step, progressive disclosure, menu flat com favoritos |
| **Autonomia** | ~20% dos campos com ajuda, sem glossário, sem tour, sem templates de relatórios | 80%+ de cobertura de ajuda, glossário integrado, tour de onboarding, templates salvos |
| **Automação** | Digitação manual de tabelas federais, sem busca CEP, barra de progresso simulada, sem agendamento | Auto-preenchimento federal, CEP integrado, WebSocket real, processamento agendado |

### Próximo Passo Imediato

Implementar as **8 tarefas do Sprint 1 (Quick Wins)** listadas na seção 7.1 — são melhorias de **1-2 semanas** que resolvem os problemas mais visíveis com mínimo esforço de desenvolvimento.

---

> **Documento gerado como parte da auditoria técnica do projeto WS-Services/eRH.**  
> **Referência cruzada:** PLANO-REFATORACAO-ATUALIZADO-2026-02.md
