# 📘 DOCUMENTAÇÃO TÉCNICA DETALHADA - eRH Municipal

## PARTE 3: Funcionalidades Faltantes - Comportamento Detalhado

**Data:** 08 de Janeiro de 2026  
**Versão:** 1.0

---

## 8. MÓDULO CONSIGNADO - COMPORTAMENTO DETALHADO

### 8.1 Visão Geral do Consignado

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MÓDULO CONSIGNADO - FLUXO COMPLETO                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

O QUE É:
────────────────────────────────────────────────────────────────────────────────────────────────
Empréstimos descontados diretamente na folha de pagamento do servidor.
São contratos entre o servidor e instituições financeiras conveniadas,
onde a Prefeitura atua como intermediária no desconto.

ENTIDADES ENVOLVIDAS:
────────────────────────────────────────────────────────────────────────────────────────────────

┌─────────────────────┐     ┌─────────────────────┐     ┌─────────────────────┐
│   BANCOS/FINANC.    │     │     PREFEITURA      │     │      SERVIDOR       │
│   (Consignatárias)  │     │   (Consignante)     │     │   (Consignado)      │
├─────────────────────┤     ├─────────────────────┤     ├─────────────────────┤
│ • Oferece crédito   │     │ • Cadastra convênio │     │ • Solicita empréstimo│
│ • Envia contratos   │     │ • Valida margem     │     │ • Assina contrato   │
│ • Recebe valores    │     │ • Desconta em folha │     │ • Parcela descontada│
└─────────────────────┘     │ • Repassa ao banco  │     └─────────────────────┘
                            └─────────────────────┘
```

### 8.2 Estrutura de Dados - Consignado

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MODELO DE DADOS - CONSIGNADO                                         │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│ ConvenioConsignataria (Entidade)                                                             │
├───────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                                │
│ unidadeGestoraId: Long (FK → UnidadeGestora)                                                │
│                                                                                              │
│ // Dados da Consignatária (Banco/Financeira)                                                │
│ nome: String             → "Banco do Brasil", "Caixa Econômica", etc.                       │
│ cnpj: String             → "00.000.000/0001-91"                                             │
│ codigoBanco: String      → "001", "104", etc.                                               │
│ agencia: String          → "1234-5"                                                         │
│ contaRepasse: String     → "12345-6" (conta para depósito)                                  │
│                                                                                              │
│ // Dados do Convênio                                                                        │
│ numeroConvenio: String   → "2026/001"                                                       │
│ dataInicio: LocalDate    → Data início do convênio                                          │
│ dataFim: LocalDate       → Data fim (pode ser null = indeterminado)                         │
│ taxaMaxima: BigDecimal   → Taxa máxima permitida (2,14% a.m. exemplo)                       │
│ prazoMaximo: Integer     → Prazo máximo em meses (96 meses exemplo)                         │
│                                                                                              │
│ // Contato                                                                                  │
│ responsavel: String      → Nome do gestor do convênio                                       │
│ telefone: String                                                                            │
│ email: String                                                                               │
│                                                                                              │
│ // Status                                                                                   │
│ ativo: Boolean                                                                              │
│ motivoInativacao: String                                                                    │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
                                               │
                                               │ 1:N
                                               ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│ ContratoConsignado (Entidade)                                                                │
├───────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                                │
│ unidadeGestoraId: Long (FK)                                                                 │
│                                                                                              │
│ // Relacionamentos                                                                          │
│ vinculoFuncionalDet: VinculoFuncionalDet (FK) → Servidor que contratou                      │
│ convenioConsignataria: ConvenioConsignataria (FK) → Banco que emprestou                     │
│                                                                                              │
│ // Dados do Contrato                                                                        │
│ numeroContrato: String   → "2026001234" (número do banco)                                   │
│ valorContratado: BigDecimal → R$ 15.000,00 (valor total)                                    │
│ taxaJuros: BigDecimal    → 2,05% ao mês                                                     │
│ dataContratacao: LocalDate → 2026-01-15                                                     │
│ dataPrimeiroDesconto: LocalDate → 2026-02-05                                                │
│                                                                                              │
│ // Parcelas                                                                                 │
│ quantidadeParcelas: Integer → 48                                                            │
│ valorParcela: BigDecimal → R$ 450,00                                                        │
│ parcelaAtual: Integer    → 12 (parcela atual)                                               │
│ parcelasRestantes: Integer → 36                                                             │
│                                                                                              │
│ // Status e Controle                                                                        │
│ status: StatusContrato   → ATIVO, QUITADO, SUSPENSO, CANCELADO, RENEGOCIADO                │
│ motivoSuspensao: String  → Se suspenso, motivo                                              │
│ dataSuspensao: LocalDate                                                                    │
│ dataQuitacao: LocalDate                                                                     │
│                                                                                              │
│ // Refinanciamento                                                                          │
│ contratoOriginal: ContratoConsignado → Se é refinanciamento, aponta para o original        │
│ valorSaldoDevedor: BigDecimal → Saldo para quitação antecipada                              │
│                                                                                              │
│ // Rubrica gerada                                                                           │
│ vantagemDescontoDet: VantagemDescontoDet → Rubrica de desconto                              │
│                                                                                              │
│ // Auditoria                                                                                │
│ usuarioCriacao: String                                                                      │
│ dataCriacao: LocalDateTime                                                                  │
│ usuarioAlteracao: String                                                                    │
│ dataAlteracao: LocalDateTime                                                                │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Regra de Margem Consignável

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                     CÁLCULO DA MARGEM CONSIGNÁVEL                                            │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

DEFINIÇÃO LEGAL (Lei 10.820/2003):
────────────────────────────────────────────────────────────────────────────────────────────────
A margem consignável é o percentual máximo da remuneração que pode ser 
comprometido com descontos de consignados. 

LIMITES:
• 35% para empréstimos consignados convencionais
• 5% adicionais exclusivo para cartão de crédito consignado
• Total máximo: 40%


FÓRMULA DE CÁLCULO:
────────────────────────────────────────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                             │
│   BASE MARGEM = Remuneração Bruta - Descontos Obrigatórios                                  │
│                                                                                             │
│   Descontos Obrigatórios:                                                                   │
│   ├─ INSS ou RPPS (contribuição previdenciária)                                            │
│   ├─ IRRF                                                                                   │
│   ├─ Pensão Alimentícia (se houver)                                                        │
│   └─ Outros descontos legais (determinados judicialmente)                                   │
│                                                                                             │
│   MARGEM TOTAL = BASE MARGEM × 35%                                                          │
│   MARGEM DISPONÍVEL = MARGEM TOTAL - Consignados já contratados                            │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


EXEMPLO PRÁTICO:
────────────────────────────────────────────────────────────────────────────────────────────────

Servidor: João da Silva
Matrícula: 12345

┌─────────────────────────────────────────────┬─────────────────┐
│ Remuneração Bruta                           │   R$ 5.150,00   │
├─────────────────────────────────────────────┼─────────────────┤
│ (-) RPPS                                    │   R$   609,00   │
│ (-) IRRF                                    │   R$   273,64   │
│ (-) Pensão Alimentícia                      │   R$   500,00   │
├─────────────────────────────────────────────┼─────────────────┤
│ (=) BASE PARA MARGEM                        │   R$ 3.767,36   │
├─────────────────────────────────────────────┼─────────────────┤
│ MARGEM TOTAL (35%)                          │   R$ 1.318,58   │
├─────────────────────────────────────────────┼─────────────────┤
│ Consignado Banco BB (parcela)               │   R$   450,00   │
│ Consignado Caixa (parcela)                  │   R$   300,00   │
├─────────────────────────────────────────────┼─────────────────┤
│ (=) MARGEM UTILIZADA                        │   R$   750,00   │
├─────────────────────────────────────────────┼─────────────────┤
│ (=) MARGEM DISPONÍVEL                       │   R$   568,58   │
├─────────────────────────────────────────────┼─────────────────┤
│ % UTILIZADO                                 │       56,9%     │
└─────────────────────────────────────────────┴─────────────────┘

⚠️ O servidor João pode contratar novo consignado de até R$ 568,58/parcela
```

### 8.4 Fluxo de Processamento do Consignado na Folha

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│            FLUXO: COMO O CONSIGNADO É PROCESSADO NA FOLHA                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

1. CADASTRO DO CONTRATO
────────────────────────────────────────────────────────────────────────────────────────────────
   Usuário         Sistema                  Resultado
      │               │                        │
      │ Cadastra      │                        │
      │ contrato      │                        │
      ├──────────────▶│                        │
      │               │                        │
      │               ├─ Valida margem ────────┤
      │               │   disponível           │
      │               │                        │
      │               ├─ Cria VinculoFuncDet  ─┤
      │               │   Desconto com rubrica │
      │               │   de consignado        │
      │               │                        │
      │               ├─ Define parcelas:      │
      │               │   48 parcelas de       │
      │               │   R$ 450,00            │


2. PROCESSAMENTO MENSAL
────────────────────────────────────────────────────────────────────────────────────────────────
   Processamento    ConsignadoService         FolhaPagamento
        │               │                        │
        │ processar     │                        │
        │ folha         │                        │
        ├──────────────▶│                        │
        │               │                        │
        │               ├─ Buscar contratos  ────┤
        │               │   ATIVOS do servidor   │
        │               │                        │
        │               ├─ Para cada contrato:   │
        │               │   • Verifica se tem    │
        │               │     parcelas restantes │
        │               │                        │
        │               │   • Gera lançamento    │
        │               │     na folha (DESCONTO)│
        │               │                        │
        │               │   • Incrementa         │
        │               │     parcelaAtual       │
        │               │                        │
        │               │   • Se última parcela: │
        │               │     status = QUITADO   │
        │               │                        │
        │               ├─────────────────────────────────▶ FolhaPagamentoDet
        │               │                                   criado com origem
        │               │                                   = VINCULO


3. GERAÇÃO DE REMESSA BANCÁRIA
────────────────────────────────────────────────────────────────────────────────────────────────
   FinanceiroService   ContratoConsignado      ArquivoBancario
        │                    │                       │
        │ gerar remessa      │                       │
        ├───────────────────▶│                       │
        │                    │                       │
        │                    ├─ Agrupa contratos  ───┤
        │                    │   por banco           │
        │                    │                       │
        │                    ├─ Calcula total  ──────┤
        │                    │   por banco           │
        │                    │                       │
        │                    ├─ Gera arquivo ────────┤
        │                    │   CNAB 240            │
        │                    │                       │
        │                    │   Layout:             │
        │                    │   - Header arquivo    │
        │                    │   - Header lote       │
        │                    │   - Detalhe (1 por    │
        │                    │     servidor)         │
        │                    │   - Trailer lote      │
        │                    │   - Trailer arquivo   │
        │                    │                       │
        │◀───────────────────┼───────────────────────┤
        │                    │   Arquivo .rem gerado │
```

### 8.5 Telas do Módulo Consignado

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         TELAS DO MÓDULO CONSIGNADO                                           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

TELA 1: Cadastro de Convênio
────────────────────────────────────────────────────────────────────────────────────────────────
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  📋 Cadastro de Consignatária                                            [Salvar] [Cancelar]│
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  DADOS DA INSTITUIÇÃO                                                                       │
│  ──────────────────────────────────────────────────────────────────────────                 │
│  Nome: [________________________] Banco do Brasil S.A.                                      │
│  CNPJ: [00.000.000/0001-91____]                                                            │
│  Código Banco: [001_]  Agência: [1234-5___]  Conta: [12345-6_____]                         │
│                                                                                             │
│  DADOS DO CONVÊNIO                                                                          │
│  ──────────────────────────────────────────────────────────────────────────                 │
│  Nº Convênio: [2026/001_____]                                                              │
│  Início: [15/01/2026]  Fim: [__/__/____] (deixar vazio = indeterminado)                    │
│  Taxa Máxima: [2,14__] % a.m.   Prazo Máximo: [96__] meses                                 │
│                                                                                             │
│  CONTATO                                                                                    │
│  ──────────────────────────────────────────────────────────────────────────                 │
│  Responsável: [Maria Silva_______________]                                                 │
│  Telefone: [(11) 3003-0001___]  Email: [consignado@bb.com.br____________]                  │
│                                                                                             │
│  [✓] Convênio Ativo                                                                        │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


TELA 2: Cadastro de Contrato
────────────────────────────────────────────────────────────────────────────────────────────────
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  💳 Cadastro de Contrato Consignado                                      [Salvar] [Cancelar]│
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  SERVIDOR                                                                                   │
│  ──────────────────────────────────────────────────────────────────────────                 │
│  Matrícula: [12345___]  [🔍 Buscar]                                                        │
│  Nome: João da Silva                                                                        │
│  Cargo: Assistente Administrativo                                                           │
│  Lotação: Secretaria de Administração                                                       │
│                                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐                   │
│  │ MARGEM CONSIGNÁVEL                                                   │                   │
│  │ ─────────────────────────────────────────────────                    │                   │
│  │ Margem Total (35%):      R$ 1.318,58                                 │                   │
│  │ Margem Utilizada:        R$   750,00                                 │                   │
│  │ Margem Disponível:       R$   568,58   ████████░░░░░░░ 56,9%        │                   │
│  └──────────────────────────────────────────────────────────────────────┘                   │
│                                                                                             │
│  DADOS DO CONTRATO                                                                          │
│  ──────────────────────────────────────────────────────────────────────────                 │
│  Consignatária: [▼ Banco do Brasil S.A.                                ]                   │
│  Nº Contrato: [2026001234____]                                                             │
│  Valor Contratado: [R$ 20.000,00___]                                                       │
│  Taxa de Juros: [2,05_] % a.m.                                                             │
│                                                                                             │
│  Data Contratação: [15/01/2026]                                                            │
│  Primeiro Desconto: [05/02/2026]                                                           │
│                                                                                             │
│  PARCELAS                                                                                   │
│  ──────────────────────────────────────────────────────────────────────────                 │
│  Quantidade: [48__]   Valor da Parcela: [R$ 568,00___]                                     │
│                                                                                             │
│  ⚠️ ATENÇÃO: Parcela de R$ 568,00 está DENTRO da margem disponível                          │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


TELA 3: Consulta de Margem
────────────────────────────────────────────────────────────────────────────────────────────────
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  📊 Consulta de Margem Consignável                                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  Matrícula: [12345___]  [🔍 Consultar]                                                     │
│                                                                                             │
│  ═══════════════════════════════════════════════════════════════════════════════════        │
│                                                                                             │
│  SERVIDOR: JOÃO DA SILVA                                                                    │
│  Matrícula: 12345 | Cargo: Assistente Administrativo                                        │
│                                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────────────────────┐   │
│  │ RESUMO DA MARGEM                                                                    │   │
│  ├─────────────────────────────────────────────────────────────────────────────────────┤   │
│  │                                                                                     │   │
│  │   Remuneração Bruta         R$ 5.150,00                                             │   │
│  │   (-) RPPS                  R$   609,00                                             │   │
│  │   (-) IRRF                  R$   273,64                                             │   │
│  │   (-) Pensão Alimentícia    R$   500,00                                             │   │
│  │   ─────────────────────────────────────                                             │   │
│  │   Base para Margem          R$ 3.767,36                                             │   │
│  │                                                                                     │   │
│  │   MARGEM TOTAL (35%)        R$ 1.318,58                                             │   │
│  │   MARGEM DISPONÍVEL         R$   568,58                                             │   │
│  │                                                                                     │   │
│  │   ████████████░░░░░░░░░░ 56,9% utilizado                                           │   │
│  │                                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────────────────────┘   │
│                                                                                             │
│  CONTRATOS VIGENTES:                                                                        │
│  ┌─────────────────┬──────────────────┬───────────┬───────────────┬────────────────────┐   │
│  │ Consignatária   │ Nº Contrato      │ Parcela   │ Valor Parcela │ Restantes          │   │
│  ├─────────────────┼──────────────────┼───────────┼───────────────┼────────────────────┤   │
│  │ Banco do Brasil │ 2025005678       │ 12/48     │ R$ 450,00     │ 36                 │   │
│  │ Caixa Econômica │ 2024012345       │ 24/36     │ R$ 300,00     │ 12                 │   │
│  └─────────────────┴──────────────────┴───────────┴───────────────┴────────────────────┘   │
│                                                                                             │
│  [📄 Imprimir Declaração]  [📊 Exportar PDF]                                               │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. MÓDULO FÉRIAS - COMPORTAMENTO DETALHADO

### 9.1 Conceitos de Férias no Serviço Público

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         CONCEITOS DE FÉRIAS                                                  │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

PERÍODO AQUISITIVO:
────────────────────────────────────────────────────────────────────────────────────────────────
É o período de 12 meses de efetivo exercício que dá direito às férias.
Inicia na data de admissão e renova a cada 12 meses.

Exemplo:
Admissão: 15/03/2024
├─ 1º Período Aquisitivo: 15/03/2024 a 14/03/2025 → Direito a 30 dias
├─ 2º Período Aquisitivo: 15/03/2025 a 14/03/2026 → Direito a 30 dias
└─ 3º Período Aquisitivo: 15/03/2026 a 14/03/2027 → ...


PERÍODO CONCESSIVO:
────────────────────────────────────────────────────────────────────────────────────────────────
É o período de 12 meses seguintes ao período aquisitivo em que as 
férias DEVEM ser concedidas. Se não forem, geram direito a DOBRA.

Exemplo:
1º Período Aquisitivo: 15/03/2024 a 14/03/2025
1º Período Concessivo: 15/03/2025 a 14/03/2026

⚠️ Se as férias não forem gozadas até 14/03/2026, o servidor tem direito 
   a receber o valor das férias EM DOBRO (sanção ao empregador).


MODALIDADES DE FRACIONAMENTO:
────────────────────────────────────────────────────────────────────────────────────────────────
• 30 dias corridos (padrão)
• 2 períodos de 15 dias
• 3 períodos de 10 dias
• 15 + 10 + 5 dias (se permitido pelo estatuto)

⚠️ O fracionamento depende da legislação municipal e acordo com o servidor.


ADICIONAIS DE FÉRIAS:
────────────────────────────────────────────────────────────────────────────────────────────────
• ADICIONAL DE 1/3 (Constitucional): 33,33% sobre a remuneração de férias
• ABONO PECUNIÁRIO: Conversão de até 1/3 das férias em dinheiro (10 dias)
```

### 9.2 Modelo de Dados - Férias

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MODELO DE DADOS - FÉRIAS                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│ PeriodoAquisitivo (Entidade)                                                                 │
├───────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                                │
│ unidadeGestoraId: Long (FK)                                                                 │
│                                                                                              │
│ // Relacionamento                                                                           │
│ vinculoFuncionalDet: VinculoFuncionalDet (FK)                                               │
│                                                                                              │
│ // Período                                                                                  │
│ dataInicio: LocalDate       → 15/03/2024                                                    │
│ dataFim: LocalDate          → 14/03/2025                                                    │
│ numero: Integer             → 1, 2, 3... (qual período é)                                   │
│                                                                                              │
│ // Direito                                                                                  │
│ diasDireito: Integer        → 30 (pode ser menos se faltas/licenças)                        │
│ diasGozados: Integer        → 20 (quantos já foram gozados)                                 │
│ diasRestantes: Integer      → 10 (quantos ainda faltam)                                     │
│ diasAbono: Integer          → 10 (quantos foram convertidos em $)                           │
│                                                                                              │
│ // Status                                                                                   │
│ status: StatusPeriodo       → ABERTO, PARCIAL, QUITADO, VENCIDO, DOBRA                      │
│                                                                                              │
│ // Faltas/Reduções (afetam dias de direito)                                                 │
│ faltasNoPeriodo: Integer    → Se > 5 faltas, reduz dias de férias                           │
│ licencasMedicas: Integer    → Licenças > 6 meses podem afetar                               │
│                                                                                              │
│ // Relacionamento 1:N com programações                                                       │
│ programacoes: List<ProgramacaoFerias>                                                       │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
                                               │
                                               │ 1:N
                                               ▼
┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│ ProgramacaoFerias (Entidade)                                                                 │
├───────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                                │
│ unidadeGestoraId: Long (FK)                                                                 │
│                                                                                              │
│ // Relacionamento                                                                           │
│ periodoAquisitivo: PeriodoAquisitivo (FK)                                                   │
│                                                                                              │
│ // Programação                                                                              │
│ dataInicio: LocalDate       → 01/07/2025 (início das férias)                                │
│ dataFim: LocalDate          → 15/07/2025 (fim das férias)                                   │
│ diasProgramados: Integer    → 15                                                            │
│                                                                                              │
│ // Status                                                                                   │
│ status: StatusFerias        → PROGRAMADA, CONFIRMADA, EM_GOZO, GOZADA,                      │
│                               CANCELADA, INTERROMPIDA                                        │
│                                                                                              │
│ // Abono Pecuniário                                                                         │
│ diasAbono: Integer          → 5 (dias convertidos em $)                                     │
│ valorAbono: BigDecimal      → Calculado: (rem/30) × diasAbono                               │
│                                                                                              │
│ // Folha gerada                                                                             │
│ folhaPagamento: FolhaPagamento (FK) → Folha de férias gerada                                │
│ competenciaFolha: String    → "2025-06" (folha complementar de férias)                      │
│                                                                                              │
│ // Interrupção (se aplicável)                                                               │
│ dataInterrupcao: LocalDate  → Se interrompida, quando                                       │
│ motivoInterrupcao: String   → "Convocação para júri", "Licença médica", etc.                │
│ diasGozadosAteInterrupcao: Integer → Quantos dias gozou antes de interromper               │
│                                                                                              │
│ // Aprovação (workflow)                                                                     │
│ solicitadoPor: String       → Login do servidor/chefia                                      │
│ dataSolicitacao: LocalDateTime                                                              │
│ aprovadoPor: String         → Login de quem aprovou                                         │
│ dataAprovacao: LocalDateTime                                                                │
│ observacoes: String                                                                         │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 9.3 Fluxo de Processamento de Férias

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         FLUXO DE FÉRIAS - PASSO A PASSO                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

FASE 1: PROGRAMAÇÃO ANUAL
────────────────────────────────────────────────────────────────────────────────────────────────

┌────────────┐     ┌────────────┐     ┌────────────┐     ┌────────────┐
│ Janeiro    │     │ Secretaria │     │   Chefia   │     │    RH      │
│ de cada    │────▶│ envia escala├────▶│ valida e   │────▶│ consolida  │
│ ano        │     │ de férias  │     │ ajusta     │     │ aprovação  │
└────────────┘     └────────────┘     └────────────┘     └────────────┘
                          │                                    │
                          ▼                                    ▼
              ┌─────────────────────┐              ┌─────────────────────┐
              │ ProgramacaoFerias   │              │ STATUS: PROGRAMADA  │
              │ com status inicial  │              │ → CONFIRMADA        │
              └─────────────────────┘              └─────────────────────┘


FASE 2: ANTES DAS FÉRIAS (15-30 dias antes)
────────────────────────────────────────────────────────────────────────────────────────────────

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                            │
│  Servidor João programou férias para 01/07/2025 a 30/07/2025 (30 dias)                    │
│  Sistema deve processar ANTES das férias:                                                  │
│                                                                                            │
│  1. Gerar FOLHA DE FÉRIAS (competência 2025-06 FÉRIAS)                                    │
│     ├─ Inclui: Remuneração dos 30 dias                                                    │
│     ├─ Inclui: 1/3 Constitucional                                                         │
│     └─ Inclui: Abono Pecuniário (se solicitado)                                           │
│                                                                                            │
│  2. Calcular:                                                                              │
│     ├─ Base de férias = (Salário + Vantagens que incidem em férias)                       │
│     ├─ Adicional 1/3 = Base de férias ÷ 3                                                 │
│     ├─ Abono = (Base de férias ÷ 30) × dias de abono                                      │
│     └─ Descontos (RPPS, IRRF sobre o total)                                               │
│                                                                                            │
│  3. Pagar ADIANTADO (antes do início das férias)                                          │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 3: DURANTE AS FÉRIAS
────────────────────────────────────────────────────────────────────────────────────────────────

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                            │
│  Servidor está de férias de 01/07 a 30/07                                                 │
│                                                                                            │
│  Na FOLHA NORMAL de julho (processada em agosto):                                          │
│  ├─ Servidor NÃO recebe salário (já recebeu nas férias)                                   │
│  ├─ Se férias parciais (15 dias): recebe proporcional dos outros 15                       │
│  └─ Registro de "AFASTAMENTO FÉRIAS" no ponto                                             │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


FASE 4: POSSÍVEIS EVENTOS DURANTE FÉRIAS
────────────────────────────────────────────────────────────────────────────────────────────────

INTERRUPÇÃO DE FÉRIAS:
Causas permitidas:
• Calamidade pública
• Comoção interna
• Convocação para júri
• Convocação militar
• Necessidade de serviço (excepcionalmente, com autorização)

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ EXEMPLO DE INTERRUPÇÃO:                                                                    │
│                                                                                            │
│ João estava de férias de 01/07 a 30/07 (30 dias)                                          │
│ Em 15/07 foi convocado por necessidade de serviço                                         │
│                                                                                            │
│ Resultado:                                                                                 │
│ • Dias gozados: 15 (01/07 a 15/07)                                                        │
│ • Dias restantes: 15 (devem ser reprogramados)                                            │
│ • Status: INTERROMPIDA                                                                     │
│ • Nova programação deve ser feita para os 15 dias restantes                               │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 9.4 Cálculo de Férias - Exemplo Completo

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         EXEMPLO: CÁLCULO DE FÉRIAS                                           │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

DADOS DO SERVIDOR:
────────────────────────────────────────────────────────────────────────────────────────────────
Servidor: Maria Silva
Salário Base: R$ 4.000,00
Quinquênio (10%): R$ 400,00
Representação: R$ 500,00
Total Remuneração: R$ 4.900,00

Férias: 30 dias (01/07 a 30/07)
Abono Pecuniário: 10 dias (conversão de 1/3)


CÁLCULO DA FOLHA DE FÉRIAS:
────────────────────────────────────────────────────────────────────────────────────────────────

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                             │
│  1. REMUNERAÇÃO DE FÉRIAS (20 dias de gozo + 10 dias de abono)                             │
│  ────────────────────────────────────────────────────────────────                          │
│                                                                                             │
│  Férias Gozadas (20 dias):                                                                  │
│  ├─ Salário Base: R$ 4.000,00 × (20/30) = R$ 2.666,67                                      │
│  ├─ Quinquênio: R$ 400,00 × (20/30) = R$ 266,67                                            │
│  ├─ Representação: R$ 500,00 × (20/30) = R$ 333,33                                         │
│  └─ Subtotal Gozo: R$ 3.266,67                                                             │
│                                                                                             │
│  Abono Pecuniário (10 dias convertidos em $):                                              │
│  ├─ Base diária: R$ 4.900,00 ÷ 30 = R$ 163,33                                              │
│  └─ Abono: R$ 163,33 × 10 = R$ 1.633,33                                                    │
│                                                                                             │
│  2. ADICIONAL DE 1/3 CONSTITUCIONAL                                                        │
│  ────────────────────────────────────────────────────────────────                          │
│                                                                                             │
│  Base para 1/3: R$ 4.900,00 (remuneração mensal integral)                                  │
│  1/3 Constitucional: R$ 4.900,00 ÷ 3 = R$ 1.633,33                                         │
│                                                                                             │
│  ⚠️ O 1/3 incide sobre a remuneração INTEGRAL, não proporcional aos dias                   │
│                                                                                             │
│  3. TOTAL BRUTO                                                                            │
│  ────────────────────────────────────────────────────────────────                          │
│                                                                                             │
│  Férias Gozadas:           R$ 3.266,67                                                      │
│  Abono Pecuniário:         R$ 1.633,33                                                      │
│  1/3 Constitucional:       R$ 1.633,33                                                      │
│  ────────────────────────────────────────                                                   │
│  TOTAL BRUTO:              R$ 6.533,33                                                      │
│                                                                                             │
│  4. DESCONTOS                                                                              │
│  ────────────────────────────────────────────────────────────────                          │
│                                                                                             │
│  Base RPPS: R$ 6.533,33 (todo o valor incide)                                              │
│  RPPS (14%): R$ 6.533,33 × 14% = R$ 914,67                                                 │
│                                                                                             │
│  Base IRRF: R$ 6.533,33 - R$ 914,67 = R$ 5.618,66                                          │
│  IRRF (27,5%): (R$ 5.618,66 × 27,5%) - R$ 896,00 = R$ 649,13                               │
│                                                                                             │
│  5. TOTAL LÍQUIDO                                                                          │
│  ────────────────────────────────────────────────────────────────                          │
│                                                                                             │
│  Total Bruto:              R$ 6.533,33                                                      │
│  (-) RPPS:                 R$   914,67                                                      │
│  (-) IRRF:                 R$   649,13                                                      │
│  ────────────────────────────────────────                                                   │
│  TOTAL LÍQUIDO:            R$ 4.969,53                                                      │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

OBSERVAÇÃO IMPORTANTE:
─────────────────────────────────────────────────────────────────────────────────────────────
O servidor receberá R$ 4.969,53 ANTES das férias.
Na folha normal de julho, não receberá nada (ou proporcional se férias parciais).
```

---

## 10. MÓDULO 13º SALÁRIO - COMPORTAMENTO DETALHADO

### 10.1 Conceitos do 13º Salário

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         CONCEITOS DO 13º SALÁRIO                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

DEFINIÇÃO:
────────────────────────────────────────────────────────────────────────────────────────────────
Gratificação natalina correspondente a 1/12 da remuneração de dezembro 
por cada mês trabalhado no ano. Também chamado de Gratificação Natalina.

FORMAS DE PAGAMENTO:
────────────────────────────────────────────────────────────────────────────────────────────────

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                            │
│  OPÇÃO 1: PARCELA ÚNICA (Dezembro)                                                         │
│  ─────────────────────────────────                                                         │
│  • Pago integralmente até 20/12                                                            │
│  • Incide IRRF sobre o valor total                                                         │
│  • Incide RPPS/INSS sobre o valor total                                                    │
│                                                                                            │
│  OPÇÃO 2: DUAS PARCELAS (Mais comum)                                                       │
│  ───────────────────────────────────                                                       │
│  1ª Parcela (50%): Até 30/11 ou junto com férias                                           │
│     • NÃO incide IRRF                                                                      │
│     • NÃO incide RPPS/INSS                                                                 │
│     • É um ADIANTAMENTO                                                                    │
│                                                                                            │
│  2ª Parcela (50% + ajustes): Até 20/12                                                     │
│     • Incide IRRF sobre o VALOR TOTAL (1ª + 2ª)                                            │
│     • Incide RPPS/INSS sobre o VALOR TOTAL (1ª + 2ª)                                       │
│     • Desconta a 1ª parcela já paga                                                        │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


AVOS DE 13º:
────────────────────────────────────────────────────────────────────────────────────────────────
• Cada mês trabalhado = 1/12 (um avo)
• Fração ≥ 15 dias = conta como mês cheio
• Fração < 15 dias = não conta

Exemplo:
Admissão em 20/03/2025
├─ Março: trabalhou 12 dias → NÃO conta
├─ Abril a Dezembro: 9 meses completos
└─ Total: 9/12 avos de 13º


RUBRICAS QUE COMPÕEM O 13º:
────────────────────────────────────────────────────────────────────────────────────────────────
Compõem (incideDecimoTerceiro = SIM):
• Salário Base
• Quinquênio
• Adicional por tempo de serviço
• Gratificações incorporadas

NÃO compõem (incideDecimoTerceiro = NÃO):
• Horas extras eventuais
• Auxílio-alimentação
• Auxílio-transporte
• Gratificações de função (depende da legislação)
```

### 10.2 Modelo de Dados - 13º Salário

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MODELO DE DADOS - 13º SALÁRIO                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

O 13º utiliza a estrutura existente de FolhaPagamento com campo específico:

┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│ FolhaPagamento (campos relacionados ao 13º)                                                  │
├───────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                              │
│ // Campo que identifica folha de 13º                                                        │
│ parcela13: String                                                                           │
│   └─ null ou "" = Folha normal                                                              │
│   └─ "1" = 1ª Parcela do 13º                                                                │
│   └─ "2" = 2ª Parcela do 13º                                                                │
│   └─ "U" = Parcela Única do 13º                                                             │
│                                                                                              │
│ // Controle de avos                                                                         │
│ avosDireito: Integer         → 12 (se trabalhou o ano todo)                                 │
│ avosProporcional: Integer    → 9 (se trabalhou 9 meses)                                     │
│                                                                                              │
│ // Base específica para 13º                                                                 │
│ base13SalarioServidor: BigDecimal → Soma das rubricas que incidem em 13º                    │
│                                                                                              │
│ // Valores calculados                                                                       │
│ valor13BrutoIntegral: BigDecimal → Valor de 12/12 (base completa)                           │
│ valor13BrutoProporcional: BigDecimal → Valor proporcional aos avos                          │
│ valor13PrimeiraParcela: BigDecimal → 50% antecipado (se aplicável)                          │
│ valor13SegundaParcela: BigDecimal → Restante + ajustes                                      │
│                                                                                              │
└───────────────────────────────────────────────────────────────────────────────────────────────┘


┌───────────────────────────────────────────────────────────────────────────────────────────────┐
│ ConfiguracaoDecimoTerceiro (Nova Entidade - Parâmetros)                                      │
├───────────────────────────────────────────────────────────────────────────────────────────────┤
│ id: Long (PK)                                                                                │
│ unidadeGestoraId: Long (FK)                                                                 │
│ ano: Integer                  → 2025                                                        │
│                                                                                              │
│ // Configuração de pagamento                                                                │
│ modalidade: ModalidadePagamento → PARCELA_UNICA, DUAS_PARCELAS                              │
│                                                                                              │
│ // Datas limite                                                                             │
│ dataPrimeiraParcela: LocalDate → 30/11/2025                                                 │
│ dataSegundaParcela: LocalDate  → 20/12/2025                                                 │
│                                                                                              │
│ // Opção de pagar junto com férias                                                          │
│ permitePrimeiraParcelaFerias: Boolean → Servidor pode solicitar junto com férias            │
│                                                                                              │
│ // Status                                                                                   │
│ statusPrimeiraParcela: StatusProcessamento → NAO_PROCESSADA, EM_PROCESSAMENTO, PROCESSADA   │
│ statusSegundaParcela: StatusProcessamento                                                    │
│                                                                                              │
└───────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 10.3 Fluxo de Cálculo do 13º

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         FLUXO DE CÁLCULO DO 13º - DUAS PARCELAS                              │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


1ª PARCELA (Novembro)
════════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                            │
│  CÁLCULO DA 1ª PARCELA:                                                                    │
│                                                                                            │
│  1. Calcular base de 13º (rubricas que incidem)                                           │
│     Base13 = Salário + Quinquênio + outras vantagens com incide13=SIM                      │
│                                                                                            │
│  2. Calcular avos de direito até novembro                                                  │
│     Avos = meses trabalhados no ano (considerando regra dos 15 dias)                       │
│                                                                                            │
│  3. Calcular valor proporcional                                                            │
│     Valor13 = (Base13 × Avos) ÷ 12                                                         │
│                                                                                            │
│  4. Primeira parcela = 50%                                                                 │
│     1ªParcela = Valor13 × 50%                                                              │
│                                                                                            │
│  ⚠️ NÃO HÁ DESCONTOS NA 1ª PARCELA (é adiantamento)                                        │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

EXEMPLO 1ª PARCELA:
────────────────────────────────────────────────────────────────────────────────────────────────

Servidor trabalhou de janeiro a novembro (11 meses)
Base de 13º: R$ 5.000,00

Cálculo:
├─ Valor13 Proporcional = R$ 5.000,00 × 11/12 = R$ 4.583,33
├─ 1ª Parcela = R$ 4.583,33 × 50% = R$ 2.291,67
└─ Descontos = R$ 0,00

LÍQUIDO 1ª PARCELA: R$ 2.291,67


2ª PARCELA (Dezembro)
════════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                            │
│  CÁLCULO DA 2ª PARCELA:                                                                    │
│                                                                                            │
│  1. Recalcular base de 13º COM VALORES DE DEZEMBRO                                         │
│     (Pode ter tido aumento, promoção, etc.)                                                │
│                                                                                            │
│  2. Calcular avos completos (até dezembro)                                                 │
│     Avos = 12/12 (se trabalhou o ano todo)                                                 │
│                                                                                            │
│  3. Calcular IRRF sobre o VALOR TOTAL                                                      │
│     BaseIRRF = Valor13 Total - RPPS                                                        │
│     IRRF = tabela progressiva normal                                                       │
│                                                                                            │
│  4. Calcular RPPS sobre o VALOR TOTAL                                                      │
│     RPPS = Valor13 Total × alíquota                                                        │
│                                                                                            │
│  5. Segunda parcela                                                                        │
│     2ªParcela = Valor13 Total - 1ªParcela - RPPS - IRRF                                    │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

EXEMPLO 2ª PARCELA:
────────────────────────────────────────────────────────────────────────────────────────────────

Servidor trabalhou o ano todo (12 meses)
Base de 13º dezembro: R$ 5.200,00 (teve aumento em dezembro)
1ª Parcela paga: R$ 2.291,67

Cálculo:
├─ Valor13 Total = R$ 5.200,00 × 12/12 = R$ 5.200,00
│
├─ RPPS (14% sobre total):
│  R$ 5.200,00 × 14% = R$ 728,00
│
├─ IRRF (sobre total - RPPS):
│  Base = R$ 5.200,00 - R$ 728,00 = R$ 4.472,00
│  IRRF = (R$ 4.472,00 × 22,5%) - R$ 662,77 = R$ 343,43
│
├─ 2ª Parcela:
│  = Valor Total - 1ª Parcela - RPPS - IRRF
│  = R$ 5.200,00 - R$ 2.291,67 - R$ 728,00 - R$ 343,43
│  = R$ 1.836,90

LÍQUIDO 2ª PARCELA: R$ 1.836,90


RESUMO TOTAL DO 13º:
────────────────────────────────────────────────────────────────────────────────────────────────
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1ª Parcela (Nov):      R$ 2.291,67                                          │
│ 2ª Parcela (Dez):      R$ 1.836,90                                          │
│ ────────────────────────────────────────────────────────────────────        │
│ TOTAL RECEBIDO:        R$ 4.128,57                                          │
│                                                                             │
│ VALOR BRUTO 13º:       R$ 5.200,00                                          │
│ DESCONTOS:             R$ 1.071,43 (RPPS R$ 728 + IRRF R$ 343,43)          │
│ LÍQUIDO TOTAL:         R$ 4.128,57                                          │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

**Continua na PARTE 4: Relacionamento entre Classes e Fluxo de Dados**

