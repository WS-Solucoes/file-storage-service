# 📘 DOCUMENTAÇÃO TÉCNICA DETALHADA - eRH Municipal

## PARTE 4: Relacionamento entre Classes e Diagrama de Fluxo de Dados

**Data:** 08 de Janeiro de 2026  
**Versão:** 1.0

---

## 11. DIAGRAMA DE CLASSES COMPLETO

### 11.1 Núcleo do Sistema - Entidades Principais

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         DIAGRAMA DE CLASSES - NÚCLEO ERH                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌─────────────────────┐
                                    │   UnidadeGestora    │
                                    ├─────────────────────┤
                                    │ id: Long            │
                                    │ nome: String        │
                                    │ cnpj: String        │
                                    │ tipo: TipoUG        │
                                    │ ativo: Boolean      │
                                    └─────────────────────┘
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
         ┌─────────────────────┐   ┌─────────────────────┐   ┌─────────────────────┐
         │     Legislacao      │   │   Funcionario       │   │    Secretaria       │
         ├─────────────────────┤   ├─────────────────────┤   ├─────────────────────┤
         │ id: Long            │   │ id: Long            │   │ id: Long            │
         │ competencia: String │   │ cpf: String         │   │ nome: String        │
         │ salarioMinimo: BD   │   │ nome: String        │   │ sigla: String       │
         │ tetoRGPS: BD        │   │ dataNasc: Date      │   │ secretario: String  │
         │ rppsAliquota1: BD   │   │ sexo: String        │   │ unidadeGestoraId: L │
         │ rppsProgressivo: B  │   │ email: String       │   └─────────────────────┘
         │ irFaixa1..5: BD     │   │ unidadeGestoraId: L │             │
         │ inssFaixa1..4: BD   │   └─────────────────────┘             │
         └─────────────────────┘             │                         │
                    │                        │                         │
                    │              ┌─────────┴─────────┐               │
                    │              │                   │               │
                    │              ▼                   ▼               ▼
                    │   ┌─────────────────────┐   ┌─────────────────────┐
                    │   │  Dependente         │   │     Lotacao         │
                    │   ├─────────────────────┤   ├─────────────────────┤
                    │   │ id: Long            │   │ id: Long            │
                    │   │ nome: String        │   │ nome: String        │
                    │   │ parentesco: String  │   │ secretaria: Secr.   │
                    │   │ dataNasc: Date      │   │ unidadeGestoraId: L │
                    │   │ cpf: String         │   └─────────────────────┘
                    │   │ irrf: Boolean       │             │
                    │   │ salarioFam: Boolean │             │
                    │   │ funcionario: Func.  │             │
                    │   └─────────────────────┘             │
                    │                                       │
                    │                                       │
                    ▼                                       ▼
         ┌───────────────────────────────────────────────────────────────┐
         │                    VinculoFuncionalDet                        │
         ├───────────────────────────────────────────────────────────────┤
         │ id: Long                                                      │
         │ matricula: String                                             │
         │ dataAdmissao: LocalDate                                       │
         │ dataDemissao: LocalDate                                       │
         │ tipoVinculo: TipoVinculo (EFETIVO, COMISSIONADO, TEMPORARIO)  │
         │ regime: RegimePrevidenciario (RGPS, RPPS)                     │
         │ cargaHoraria: Integer                                         │
         │ situacao: Situacao (ATIVO, AFASTADO, DEMITIDO, APOSENTADO)    │
         │ funcionario: Funcionario (FK)                                 │
         │ cargo: Cargo (FK)                                             │
         │ lotacao: Lotacao (FK)                                         │
         │ legislacao: Legislacao (FK)                                   │
         │ unidadeGestoraId: Long                                        │
         │                                                               │
         │ // Remuneração                                                │
         │ salarioBase: BigDecimal                                       │
         │ representacao: BigDecimal                                     │
         │ percentualQuinquenio: BigDecimal                              │
         │ quinquenio: BigDecimal                                        │
         │                                                               │
         │ // Rubricas fixas do vínculo                                  │
         │ vinculoRubricas: List<VinculoFuncRubrica>                     │
         │                                                               │
         │ // Folhas de pagamento                                        │
         │ folhas: List<FolhaPagamento>                                  │
         └───────────────────────────────────────────────────────────────┘
                    │                           │
                    │ 1:N                       │ 1:N
                    ▼                           ▼
         ┌─────────────────────┐     ┌─────────────────────────────────────┐
         │  VinculoFuncRubrica │     │        FolhaPagamento               │
         ├─────────────────────┤     ├─────────────────────────────────────┤
         │ id: Long            │     │ id: Long                            │
         │ vinculoFuncDet: VFD │     │ competencia: String ("2026-01")     │
         │ vantagemDescDet: VDD│     │ ferias: String ("0", "1")           │
         │ valor: BigDecimal   │     │ parcela13: String (null, "1", "2")  │
         │ parcelas: Integer   │     │ vinculoFuncDet: VFD                 │
         │ parcelaAtual: Int   │     │ legislacao: Legislacao              │
         │ dataInicio: Date    │     │                                     │
         │ dataFim: Date       │     │ // Valores calculados               │
         │ ativo: Boolean      │     │ salarioBase, representacao, quinq.  │
         └─────────────────────┘     │ baseInss, baseRpps, baseIrrf        │
                                     │ aliqInss, aliqRpps, aliqIrrf        │
                                     │                                     │
                                     │ // Detalhes                         │
                                     │ detalhes: List<FolhaPagamentoDet>   │
                                     └─────────────────────────────────────┘
                                                │
                                                │ 1:N
                                                ▼
                                     ┌─────────────────────────────────────┐
                                     │       FolhaPagamentoDet             │
                                     ├─────────────────────────────────────┤
                                     │ id: Long                            │
                                     │ folhaPagamento: FolhaPagamento      │
                                     │ vantagemDescontoDet: VDD            │
                                     │ valor: BigDecimal                   │
                                     │ parcelas: Integer                   │
                                     │ origem: OrigemLancamento            │
                                     │   (MANUAL, AUTOMATICO, VINCULO)     │
                                     └─────────────────────────────────────┘
```

### 11.2 Sistema de Rubricas (Vantagens e Descontos)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         SISTEMA DE RUBRICAS                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                          VantagemDesconto (Pai)                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long                                                                                    │
│ codigo: String              → "001", "002", "A1", etc.                                      │
│ descricao: String           → "Salário Base", "RPPS Servidor"                               │
│ tipo: TipoRubrica           → VANTAGEM, DESCONTO                                            │
│ unidadeGestoraId: Long                                                                      │
│ ativo: Boolean                                                                              │
│                                                                                             │
│ // Lista de detalhamentos por período                                                       │
│ detalhamentos: List<VantagemDescontoDet>                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ 1:N (por competência/período)
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                          VantagemDescontoDet (Filho)                                         │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long                                                                                    │
│ vantagemDesconto: VantagemDesconto (FK)                                                     │
│ competenciaInicio: String   → "2026-01" (quando passou a valer)                             │
│ competenciaFim: String      → null (vigente) ou "2026-06" (quando terminou)                 │
│                                                                                             │
│ // Natureza                                                                                 │
│ naturezaLancamento: NaturezaLancamento → PROVENTO, DESCONTO                                 │
│                                                                                             │
│ // Tipo de cálculo                                                                          │
│ tipoCalculo: String         → null (manual), "A1"-"A9" (automático)                         │
│                                                                                             │
│ // ═══════════════════════════════════════════════════════════════════════════════════════  │
│ // FLAGS DE INCIDÊNCIA (Qual imposto/base incide sobre esta rubrica)                        │
│ // ═══════════════════════════════════════════════════════════════════════════════════════  │
│                                                                                             │
│ incideInss: SimNao          → Esta rubrica entra na base do INSS?                           │
│ incideRpps: SimNao          → Esta rubrica entra na base do RPPS?                           │
│ incideIrrf: SimNao          → Esta rubrica entra na base do IRRF?                           │
│ incideFgts: SimNao          → Esta rubrica entra na base do FGTS?                           │
│ incideSalarioFamilia: SimNao → Esta rubrica entra na base do Sal.Família?                   │
│ incideFerias: SimNao        → Esta rubrica entra na base de Férias?                         │
│ incideDecimoTerceiro: SimNao → Esta rubrica entra na base do 13º?                           │
│                                                                                             │
│ // Valor fixo (se aplicável)                                                                │
│ valorReferencia: BigDecimal → Para rubricas com valor fixo                                  │
│ percentualReferencia: BD    → Para rubricas calculadas sobre % da base                      │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


EXEMPLOS DE RUBRICAS CONFIGURADAS:
══════════════════════════════════════════════════════════════════════════════════════════════

┌────────┬──────────────────────┬───────────┬────────┬──────┬──────┬──────┬────────┬─────┐
│ Código │ Descrição            │ Natureza  │ INSS   │ RPPS │ IRRF │ Férias│ 13º    │ Tipo│
├────────┼──────────────────────┼───────────┼────────┼──────┼──────┼──────┼────────┼─────┤
│ A1     │ Salário Base         │ PROVENTO  │  SIM   │ SIM  │ SIM  │ SIM  │  SIM   │ A1  │
│ A2     │ Representação        │ PROVENTO  │  SIM   │ SIM  │ SIM  │ NÃO  │  NÃO   │ A2  │
│ A3     │ Quinquênio           │ PROVENTO  │  SIM   │ SIM  │ SIM  │ SIM  │  SIM   │ A3  │
│ A5     │ Salário Família      │ PROVENTO  │  NÃO   │ NÃO  │ NÃO  │ NÃO  │  NÃO   │ A5  │
│ A6     │ Adicional Férias 1/3 │ PROVENTO  │  SIM   │ SIM  │ SIM  │ N/A  │  NÃO   │ A6  │
│ A7     │ INSS Servidor        │ DESCONTO  │  N/A   │ N/A  │ NÃO  │ N/A  │  N/A   │ A7  │
│ A8     │ RPPS Servidor        │ DESCONTO  │  N/A   │ N/A  │ NÃO  │ N/A  │  N/A   │ A8  │
│ A9     │ IRRF                 │ DESCONTO  │  N/A   │ N/A  │ N/A  │ N/A  │  N/A   │ A9  │
├────────┼──────────────────────┼───────────┼────────┼──────┼──────┼──────┼────────┼─────┤
│ 050    │ Gratif. Função       │ PROVENTO  │  SIM   │ SIM  │ SIM  │ NÃO  │  NÃO   │null │
│ 100    │ Hora Extra 50%       │ PROVENTO  │  SIM   │ SIM  │ SIM  │ NÃO  │  NÃO   │null │
│ 150    │ Adicional Noturno    │ PROVENTO  │  SIM   │ SIM  │ SIM  │ NÃO  │  NÃO   │null │
│ 200    │ Auxílio Alimentação  │ PROVENTO  │  NÃO   │ NÃO  │ NÃO  │ NÃO  │  NÃO   │null │
│ 300    │ Pensão Alimentícia   │ DESCONTO  │  N/A   │ N/A  │ NÃO* │ N/A  │  N/A   │null │
│ 350    │ Consignado Banco X   │ DESCONTO  │  N/A   │ N/A  │ NÃO  │ N/A  │  N/A   │null │
└────────┴──────────────────────┴───────────┴────────┴──────┴──────┴──────┴────────┴─────┘

* Pensão alimentícia pode deduzir da base IRRF em alguns casos
```

### 11.3 Sistema de Autenticação e Permissões

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                    DIAGRAMA DE CLASSES - AUTENTICAÇÃO E PERMISSÕES                           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    Usuario                                                   │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                               │
│ login: String (unique)                                                                      │
│ email: String                                                                               │
│ senha: String (BCrypt)                                                                      │
│ nome: String                                                                                │
│ ativo: Boolean                                                                              │
│ dataCriacao: LocalDateTime                                                                  │
│ ultimoLogin: LocalDateTime                                                                  │
│                                                                                             │
│ // Relacionamento com permissões                                                            │
│ permissoes: Set<UsuarioPermissao>                                                           │
│                                                                                             │
│ // Métodos MBAC                                                                             │
│ +getRoleParaModulo(ugId, modulo): RoleUsuario                                               │
│ +getUnidadesGestorasParaModulo(modulo): Set<Long>                                           │
│ +temAcessoAoModulo(ugId, modulo): boolean                                                   │
│ +isAdminParaModulo(ugId, modulo): boolean                                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ 1:N
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              UsuarioPermissao                                                │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                               │
│ usuario: Usuario (FK)                                                                       │
│ unidadeGestora: UnidadeGestora (FK)                                                         │
│ modulo: String              → "ERH", "EFROTAS", "FINANCEIRO"                                │
│ role: RoleUsuario           → ADMIN, GESTOR, ANALISTA, USUARIO                              │
│                                                                                             │
│ // Constraint: UNIQUE(usuario_id, unidade_gestora_id, modulo)                               │
│ // Um usuário tem UMA role por módulo por UG                                                │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ N:1
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              RoleUsuario (Enum)                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ ADMIN       → Acesso total ao módulo na UG (configurações, exclusões, etc.)                 │
│ GESTOR      → Pode aprovar, processar folha, fechar competências                            │
│ ANALISTA    → Pode cadastrar, editar, mas não aprovar/fechar                                │
│ USUARIO     → Apenas consulta (visualização)                                                │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


FLUXO DE VERIFICAÇÃO DE PERMISSÃO:
══════════════════════════════════════════════════════════════════════════════════════════════

┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│   Controller     │     │  @PreAuthorize   │     │ TenantContext    │     │ UsuarioPermissao │
│   recebe request │────▶│  verifica role   │────▶│ fornece UG atual │────▶│ busca role do    │
│                  │     │  necessária      │     │ e modulo atual   │     │ usuario na UG    │
└──────────────────┘     └──────────────────┘     └──────────────────┘     └──────────────────┘
         │                        │                        │                        │
         │                        ▼                        │                        │
         │               ┌──────────────────┐              │                        │
         │               │ Role suficiente? │              │                        │
         │               │                  │              │                        │
         │               │ ADMIN > GESTOR > │              │                        │
         │               │ ANALISTA > USR   │              │                        │
         │               └──────────────────┘              │                        │
         │                     │     │                     │                        │
         │              SIM ───┘     └─── NÃO              │                        │
         │               │                 │               │                        │
         │               ▼                 ▼               │                        │
         │        ┌──────────┐      ┌──────────┐          │                        │
         │        │ Executa  │      │ 403      │          │                        │
         │        │ método   │      │ Forbidden│          │                        │
         │        └──────────┘      └──────────┘          │                        │
         │                                                 │                        │
         └─────────────────────────────────────────────────┴────────────────────────┘
```

---

## 12. FLUXO DE DADOS - PROCESSAMENTO COMPLETO

### 12.1 Fluxo Completo: Da Admissão ao Contracheque

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                    FLUXO COMPLETO: ADMISSÃO → CONTRACHEQUE                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 1: CADASTRO DO SERVIDOR
════════════════════════════════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ USUÁRIO: Analista de RH                                                                     │
│ AÇÃO: Cadastrar novo servidor                                                               │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│ 1. Cadastrar Funcionário (dados pessoais)                                                   │
│    ├─ Nome, CPF, RG, Data Nascimento, Sexo                                                  │
│    ├─ Endereço, Telefone, Email                                                             │
│    ├─ Dados bancários (banco, agência, conta)                                               │
│    └─ Salva em: Funcionario                                                                 │
│                                                                                              │
│ 2. Cadastrar Dependentes (se houver)                                                        │
│    ├─ Nome, CPF, Data Nascimento, Parentesco                                                │
│    ├─ Flags: deduzIRRF, recebeSalarioFamilia                                                │
│    └─ Salva em: Dependente (FK → Funcionario)                                               │
│                                                                                              │
│ 3. Criar Vínculo Funcional                                                                  │
│    ├─ Matrícula, Data Admissão                                                              │
│    ├─ Tipo Vínculo (EFETIVO, COMISSIONADO, TEMPORARIO)                                      │
│    ├─ Regime Previdenciário (RGPS ou RPPS)                                                  │
│    ├─ Cargo (FK → Cargo)                                                                    │
│    ├─ Lotação (FK → Lotacao)                                                                │
│    ├─ Carga horária, Salário base                                                           │
│    └─ Salva em: VinculoFuncionalDet (FK → Funcionario)                                      │
│                                                                                              │
│ 4. Cadastrar Rubricas Fixas (se aplicável)                                                  │
│    ├─ Gratificações permanentes                                                             │
│    ├─ Adicionais de tempo de serviço                                                        │
│    ├─ Descontos fixos (consignados, pensões)                                                │
│    └─ Salva em: VinculoFuncRubrica (FK → VinculoFuncDet)                                    │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 2: LANÇAMENTOS MENSAIS
════════════════════════════════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ USUÁRIO: Analista de Folha                                                                  │
│ AÇÃO: Lançar eventos do mês                                                                 │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│ 1. Abertura da Competência (se não existir)                                                 │
│    ├─ Sistema cria registro em Competencia                                                  │
│    └─ Busca Legislação vigente para o período                                               │
│                                                                                              │
│ 2. Lançamentos Manuais                                                                      │
│    ├─ Horas extras trabalhadas                                                              │
│    ├─ Faltas e atrasos                                                                      │
│    ├─ Adicional noturno                                                                     │
│    ├─ Gratificações eventuais                                                               │
│    └─ Salva em: FolhaPagamentoDet (origem = MANUAL)                                         │
│                                                                                              │
│ 3. Importação de Dados (se aplicável)                                                       │
│    ├─ Ponto eletrônico → horas extras, faltas                                               │
│    ├─ Arquivos de consignado → novos descontos                                              │
│    └─ Integração com outros sistemas                                                        │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 3: PROCESSAMENTO DA FOLHA
════════════════════════════════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ USUÁRIO: Coordenador de Folha                                                               │
│ AÇÃO: Processar folha da competência                                                        │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│ 1. Validar Competência                                                                      │
│    ├─ Verificar se competência está aberta                                                  │
│    ├─ Verificar se legislação está configurada                                              │
│    └─ Verificar permissão do usuário                                                        │
│                                                                                              │
│ 2. Para cada VinculoFuncionalDet ATIVO:                                                     │
│    │                                                                                         │
│    ├─ 2.1. Criar/Recuperar FolhaPagamento                                                   │
│    │       └─ Se já existe, limpa itens automáticos                                         │
│    │                                                                                         │
│    ├─ 2.2. Aplicar Rubricas do Vínculo                                                      │
│    │       └─ VinculoFuncRubrica → FolhaPagamentoDet (origem = VINCULO)                     │
│    │                                                                                         │
│    ├─ 2.3. Gerar Itens Automáticos A1-A4                                                    │
│    │       ├─ A1: Salário Base (do cargo ou vínculo)                                        │
│    │       ├─ A2: Representação (do vínculo)                                                │
│    │       ├─ A3: Quinquênio (salário × % tempo serviço)                                    │
│    │       └─ FolhaPagamentoDet (origem = AUTOMATICO)                                       │
│    │                                                                                         │
│    ├─ 2.4. Calcular Bases de Incidência                                                     │
│    │       ├─ Somar todos os PROVENTOS                                                      │
│    │       ├─ Verificar flags de incidência de cada rubrica                                 │
│    │       └─ Atualizar: baseInss, baseRpps, baseIrrf, etc.                                 │
│    │                                                                                         │
│    ├─ 2.5. Calcular Previdência                                                             │
│    │       ├─ Se RGPS: calcularINSS() → gera A7                                             │
│    │       └─ Se RPPS: calcularRPPS() → gera A8                                             │
│    │                                                                                         │
│    ├─ 2.6. Calcular IRRF                                                                    │
│    │       ├─ Base = baseIrrf - previdência - dependentes                                   │
│    │       └─ Aplica tabela progressiva → gera A9                                           │
│    │                                                                                         │
│    ├─ 2.7. Calcular Salário Família                                                         │
│    │       ├─ Verifica se base está dentro do limite                                        │
│    │       └─ Multiplica qtd dependentes × cota → gera A5                                   │
│    │                                                                                         │
│    └─ 2.8. Salvar Folha Atualizada                                                          │
│            └─ FolhaPagamento com todos os FolhaPagamentoDet                                 │
│                                                                                              │
│ 3. Gerar Resumo de Processamento                                                            │
│    ├─ Total de servidores processados                                                       │
│    ├─ Total de proventos                                                                    │
│    ├─ Total de descontos                                                                    │
│    └─ Alertas/Erros encontrados                                                             │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 4: CONFERÊNCIA E APROVAÇÃO
════════════════════════════════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ USUÁRIO: Gestor/Coordenador                                                                 │
│ AÇÃO: Conferir e aprovar folha                                                              │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│ 1. Gerar Relatórios de Conferência                                                          │
│    ├─ Resumo por secretaria/lotação                                                         │
│    ├─ Comparativo com mês anterior                                                          │
│    ├─ Maiores salários (para conferência)                                                   │
│    └─ Diferenças significativas (alertas)                                                   │
│                                                                                              │
│ 2. Conferir Individualmente (se necessário)                                                 │
│    ├─ Abrir folha do servidor                                                               │
│    ├─ Verificar lançamentos                                                                 │
│    └─ Corrigir se necessário → reprocessar individual                                       │
│                                                                                              │
│ 3. Aprovar Folha                                                                            │
│    ├─ Marcar competência como CONFERIDA                                                     │
│    └─ Bloquear alterações (exceto com permissão especial)                                   │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 5: FECHAMENTO E GERAÇÃO DE ARQUIVOS
════════════════════════════════════════════════════════════════════════════════════════════════

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│ USUÁRIO: Coordenador de Folha                                                               │
│ AÇÃO: Fechar competência e gerar arquivos                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│ 1. Fechar Competência                                                                       │
│    ├─ Status → FECHADA                                                                      │
│    └─ Impede qualquer alteração                                                             │
│                                                                                              │
│ 2. Gerar Contracheques                                                                      │
│    ├─ PDF individual por servidor                                                           │
│    ├─ PDF consolidado por lotação                                                           │
│    └─ Disponibilizar no portal do servidor                                                  │
│                                                                                              │
│ 3. Gerar Arquivos Bancários                                                                 │
│    ├─ CNAB 240 para pagamento em conta                                                      │
│    ├─ Arquivo de consignados (para bancos)                                                  │
│    └─ Enviar ao banco                                                                       │
│                                                                                              │
│ 4. Gerar Arquivos Legais                                                                    │
│    ├─ SEFIP (FGTS/INSS)                                                                     │
│    ├─ eSocial (eventos S-1200, S-1210)                                                      │
│    ├─ DIRF (anual)                                                                          │
│    └─ RAIS (anual)                                                                          │
│                                                                                              │
│ 5. Gerar Relatórios Gerenciais                                                              │
│    ├─ Resumo da folha                                                                       │
│    ├─ Relatório por secretaria                                                              │
│    ├─ Custo por lotação                                                                     │
│    └─ Provisões (férias, 13º)                                                               │
│                                                                                              │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 12.2 Diagrama de Sequência - Processamento Individual

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         SEQUÊNCIA: PROCESSAMENTO DE UMA FOLHA                                │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

 Coordenador   Controller   ProcessamentoService   FolhaService   CalculoServices   Repository
     │             │               │                    │               │               │
     │ processar   │               │                    │               │               │
     │ folha 12345 │               │                    │               │               │
     ├────────────▶│               │                    │               │               │
     │             │ processar     │                    │               │               │
     │             │ Individual    │                    │               │               │
     │             ├──────────────▶│                    │               │               │
     │             │               │                    │               │               │
     │             │               │ 1. Buscar folha    │               │               │
     │             │               ├───────────────────▶│               │               │
     │             │               │◀───────────────────┤               │               │
     │             │               │    FolhaPagamento  │               │               │
     │             │               │                    │               │               │
     │             │               │ 2. Buscar vínculo  │               │               │
     │             │               ├────────────────────┼───────────────┼──────────────▶│
     │             │               │◀───────────────────┼───────────────┼───────────────┤
     │             │               │    VinculoFuncDet  │               │               │
     │             │               │                    │               │               │
     │             │               │ 3. Buscar legislação                │               │
     │             │               ├────────────────────┼───────────────┼──────────────▶│
     │             │               │◀───────────────────┼───────────────┼───────────────┤
     │             │               │    Legislacao      │               │               │
     │             │               │                    │               │               │
     │             │               │ 4. Limpar automát. │               │               │
     │             │               ├────────────────────┼───────────────┼──────────────▶│
     │             │               │                    │               │   DELETE      │
     │             │               │                    │               │   origem=AUTO │
     │             │               │                    │               │               │
     │             │               │ 5. Aplicar rubricas do vínculo     │               │
     │             │               ├────────────────────┼───────────────┼──────────────▶│
     │             │               │                    │               │   VincFuncRub │
     │             │               │                    │               │   → FolhaDet  │
     │             │               │                    │               │               │
     │             │               │ 6. Gerar A1 (Salário Base)         │               │
     │             │               ├───────────────────▶│               │               │
     │             │               │                    │ criar detalhe │               │
     │             │               │                    ├───────────────┼──────────────▶│
     │             │               │                    │               │               │
     │             │               │ 7. Gerar A2, A3 (Rep, Quinq)       │               │
     │             │               ├───────────────────▶│               │               │
     │             │               │                    ├───────────────┼──────────────▶│
     │             │               │                    │               │               │
     │             │               │ 8. Calcular bases de incidência    │               │
     │             │               ├───────────────────▶│               │               │
     │             │               │                    │ soma proventos│               │
     │             │               │                    │ por flag      │               │
     │             │               │                    │               │               │
     │             │               │ 9. Calcular RPPS   │               │               │
     │             │               ├────────────────────┼──────────────▶│               │
     │             │               │                    │               │ calcularRPPS  │
     │             │               │◀───────────────────┼───────────────┤               │
     │             │               │    ResultadoRPPS   │               │               │
     │             │               │                    │               │               │
     │             │               │ 10. Gerar A8 (RPPS)│               │               │
     │             │               ├───────────────────▶│               │               │
     │             │               │                    ├───────────────┼──────────────▶│
     │             │               │                    │               │               │
     │             │               │ 11. Calcular IRRF  │               │               │
     │             │               ├────────────────────┼──────────────▶│               │
     │             │               │                    │               │ calcularIRRF  │
     │             │               │◀───────────────────┼───────────────┤               │
     │             │               │    ResultadoIRRF   │               │               │
     │             │               │                    │               │               │
     │             │               │ 12. Gerar A9 (IRRF)│               │               │
     │             │               ├───────────────────▶│               │               │
     │             │               │                    ├───────────────┼──────────────▶│
     │             │               │                    │               │               │
     │             │               │ 13. Salvar folha   │               │               │
     │             │               ├────────────────────┼───────────────┼──────────────▶│
     │             │               │                    │               │     SAVE      │
     │             │               │                    │               │               │
     │             │◀──────────────┤                    │               │               │
     │◀────────────┤ Folha         │                    │               │               │
     │  processada │               │                    │               │               │
```

---

## 13. MAPA DE SERVIÇOS E DEPENDÊNCIAS

### 13.1 Arquitetura de Serviços

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MAPA DE SERVIÇOS - CAMADA DE NEGÓCIO                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    CONTROLLERS                                               │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ FolhaPagamentoController      │ VinculoFuncionalController  │ FuncionarioController         │
│ ConsignadoController          │ FeriasController            │ RelatorioController           │
│ ProcessamentoController       │ LegislacaoController        │ ArquivoBancarioController     │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ @Autowired
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                               SERVICES (NEGÓCIO)                                             │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │ ProcessamentoFolhaService   │────▶│ FolhaPagamentoService       │                        │
│  │ ─────────────────────────   │     │ ─────────────────────────   │                        │
│  │ • processarFolhasCompetencia│     │ • buscarPorVinculo          │                        │
│  │ • processarFolhaIndividual  │     │ • salvar                    │                        │
│  │ • calcularBasesIncidencia   │     │ • adicionarDetalhe          │                        │
│  │ • gerarItemAutomatico       │     │ • removerDetalhesAutomaticos│                        │
│  └─────────────────────────────┘     └─────────────────────────────┘                        │
│            │                                    │                                           │
│            │                                    │                                           │
│            ▼                                    ▼                                           │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │ CalculoPrevidenciaService   │     │ VinculoFuncionalService     │                        │
│  │ ─────────────────────────   │     │ ─────────────────────────   │                        │
│  │ • calcularINSS              │     │ • buscarAtivos              │                        │
│  │ • calcularRPPS              │     │ • buscarPorMatricula        │                        │
│  │ • calcularRPPSProgressivo   │     │ • aplicarRubricas           │                        │
│  └─────────────────────────────┘     └─────────────────────────────┘                        │
│            │                                                                                │
│            │                                                                                │
│            ▼                                                                                │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │ CalculoIRRFService          │     │ CalculoSalarioFamiliaService│                        │
│  │ ─────────────────────────   │     │ ─────────────────────────   │                        │
│  │ • calcularIRRF              │     │ • calcularSalarioFamilia    │                        │
│  │ • calcularDeducoes          │     │ • verificarElegibilidade    │                        │
│  │ • aplicarTabelaProgressiva  │     │ • buscarCotaVigente         │                        │
│  └─────────────────────────────┘     └─────────────────────────────┘                        │
│                                                                                             │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │ LegislacaoService           │     │ VantagemDescontoService     │                        │
│  │ ─────────────────────────   │     │ ─────────────────────────   │                        │
│  │ • buscarVigente             │     │ • buscarPorCodigo           │                        │
│  │ • buscarPorCompetencia      │     │ • buscarRubricasAutomaticas │                        │
│  │ • atualizarTabelas          │     │ • verificarIncidencias      │                        │
│  └─────────────────────────────┘     └─────────────────────────────┘                        │
│                                                                                             │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │ ConsignadoService           │     │ FeriasService               │ ← A IMPLEMENTAR       │
│  │ ─────────────────────────   │     │ ─────────────────────────   │                        │
│  │ • calcularMargem            │     │ • calcularPeriodoAquisitivo │                        │
│  │ • cadastrarContrato         │     │ • programarFerias           │                        │
│  │ • processarParcelas         │     │ • processarFolhaFerias      │                        │
│  │ • gerarRemessaBancaria      │     │ • interromperFerias         │                        │
│  └─────────────────────────────┘     └─────────────────────────────┘                        │
│                                                                                             │
│  ┌─────────────────────────────┐     ┌─────────────────────────────┐                        │
│  │ DecimoTerceiroService       │     │ ArquivoBancarioService      │ ← A IMPLEMENTAR       │
│  │ ─────────────────────────   │     │ ─────────────────────────   │                        │
│  │ • calcularAvos              │     │ • gerarCNAB240              │                        │
│  │ • processarPrimeiraParcela  │     │ • gerarArquivoConsignado    │                        │
│  │ • processarSegundaParcela   │     │ • validarRetorno            │                        │
│  │ • ajustarDiferencas         │     │                             │                        │
│  └─────────────────────────────┘     └─────────────────────────────┘                        │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
                                              │
                                              │ @Autowired
                                              ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                               REPOSITORIES (PERSISTÊNCIA)                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│ FolhaPagamentoRepository      │ VinculoFuncionalDetRepository │ FuncionarioRepository       │
│ FolhaPagamentoDetRepository   │ LegislacaoRepository          │ DependenteRepository        │
│ VantagemDescontoRepository    │ VantagemDescontoDetRepository │ SecretariaRepository        │
│ ContratoConsignadoRepository  │ ProgramacaoFeriasRepository   │ LotacaoRepository           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

**Continua na PARTE 5: Tarefas de Cada Stakeholder por Módulo**

