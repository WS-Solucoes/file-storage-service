# 📘 DOCUMENTAÇÃO TÉCNICA DETALHADA - eRH Municipal

## PARTE 2: Fluxo de Processamento da Folha em Nível Micro

**Data:** 08 de Janeiro de 2026  
**Versão:** 1.0

---

## 5. PROCESSAMENTO DA FOLHA - NÍVEL MICRO

### 5.1 Diagrama de Sequência Completo

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│              FLUXO DE PROCESSAMENTO DA FOLHA DE PAGAMENTO - NÍVEL MICRO                     │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

Usuário     Controller    ProcessamentoService    FolhaService    CalculoServices    Repository
   │            │               │                     │                 │                │
   │ processar  │               │                     │                 │                │
   ├───────────▶│               │                     │                 │                │
   │            │ processar     │                     │                 │                │
   │            │ Folhas        │                     │                 │                │
   │            ├──────────────▶│                     │                 │                │
   │            │               │                     │                 │                │
   │            │               │ 1. Validar se pode  │                 │                │
   │            │               │    processar        │                 │                │
   │            │               ├────────────────────▶│                 │                │
   │            │               │◀───────────────────┤│                 │                │
   │            │               │                     │                 │                │
   │            │               │ 2. Buscar           │                 │                │
   │            │               │    Legislação       │                 │                │
   │            │               ├─────────────────────┼─────────────────┼───────────────▶│
   │            │               │◀────────────────────┼─────────────────┼────────────────┤
   │            │               │                     │                 │                │
   │            │               │ 3. Limpar itens     │                 │                │
   │            │               │    automáticos      │                 │                │
   │            │               ├─────────────────────┼─────────────────┼───────────────▶│
   │            │               │                     │                 │                │
   │            │               │ 4. Buscar todas     │                 │                │
   │            │               │    as folhas        │                 │                │
   │            │               ├────────────────────▶│                 │                │
   │            │               │◀───────────────────┤│                 │                │
   │            │               │                     │                 │                │
   │            │               │                     │                 │                │
   │            │               │ ═══════ LOOP: Para cada folha ═══════ │                │
   │            │               │ │                   │                 │                │
   │            │               │ │ 5. Aplicar rubricas fixas do vínculo                 │
   │            │               │ ├───────────────────┼────────────────▶│                │
   │            │               │ │                   │                 │                │
   │            │               │ │ 6. Calcular bases de incidência    │                │
   │            │               │ │    (INSS, RPPS, IRRF, SalFam, etc) │                │
   │            │               │ ├───────────────────────────────────▶│                │
   │            │               │ │                   │                 │                │
   │            │               │ │ 7. Calcular Previdência            │                │
   │            │               │ ├───────────────────────────────────▶│                │
   │            │               │ │                   │  calcularINSS() │                │
   │            │               │ │                   │  ou             │                │
   │            │               │ │                   │  calcularRPPS() │                │
   │            │               │ │◀──────────────────────────────────┤│                │
   │            │               │ │                   │                 │                │
   │            │               │ │ 8. Calcular IRRF                   │                │
   │            │               │ ├───────────────────────────────────▶│                │
   │            │               │ │                   │  calcularIRRF() │                │
   │            │               │ │◀──────────────────────────────────┤│                │
   │            │               │ │                   │                 │                │
   │            │               │ │ 9. Calcular Salário Família        │                │
   │            │               │ ├───────────────────────────────────▶│                │
   │            │               │ │◀──────────────────────────────────┤│                │
   │            │               │ │                   │                 │                │
   │            │               │ │ 10. Salvar folha atualizada        │                │
   │            │               │ ├────────────────────────────────────┼───────────────▶│
   │            │               │ │                   │                 │                │
   │            │               │ │ 11. Gerar itens automáticos        │                │
   │            │               │ │     (A1-A9)       │                 │                │
   │            │               │ ├────────────────────────────────────┼───────────────▶│
   │            │               │ │                   │                 │                │
   │            │               │ │ 12. Processar 13º (se aplicável)   │                │
   │            │               │ ├────────────────────────────────────┼───────────────▶│
   │            │               │ │                   │                 │                │
   │            │               │ ═══════ FIM DO LOOP ═══════════════ │                │
   │            │               │                     │                 │                │
   │            │◀──────────────┤                     │                 │                │
   │◀───────────┤               │                     │                 │                │
   │ Resultado  │               │                     │                 │                │
```

### 5.2 Estrutura de Dados Durante o Processamento

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                    ESTRUTURA DE DADOS - FOLHA DE PAGAMENTO                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ FolhaPagamento                                                                              │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  IDENTIFICAÇÃO                         VALORES BASE                                         │
│  ────────────────────────────          ─────────────────────────────                        │
│  id: 12345                             salarioBase: 3.500,00                                │
│  competencia: "2026-01"                representacao: 500,00                                │
│  unidadeGestoraId: 1                   quinquenio: 350,00 (10% de 5 anos)                   │
│  ferias: "0" (não é folha de férias)                                                        │
│  parcela13: null (folha normal)        BASES DE INCIDÊNCIA                                  │
│                                        ─────────────────────────────                        │
│  RELACIONAMENTOS                       baseInssServidor: 4.350,00                           │
│  ────────────────────────────          baseRppsServidor: 4.350,00                           │
│  vinculoFuncionalDet: VFD#789          baseIrrfServidor: 4.350,00                           │
│  legislacao: LEG#2026-01               baseSalFamServidor: 0,00                             │
│  detalhes: [FPDet#1, FPDet#2...]       baseFeriasServidor: 4.350,00                         │
│                                        base13SalarioServidor: 4.350,00                      │
│  DEPENDENTES                                                                                │
│  ────────────────────────────          ALÍQUOTAS CALCULADAS                                 │
│  qtdDependentesIrrf: 2                 ─────────────────────────────                        │
│  qtdDependentesSalarioFamilia: 1       aliqInssServidor: 0,00 (é RPPS)                      │
│                                        aliqRppsServidor: 14,00                              │
│                                        aliqIrrfServidor: 15,00                              │
│                                        deducaoIrrfServidor: 381,44                          │
│                                        deducaoDepIrrfServidor: 189,59/dep                   │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
                                             │
                                             │ 1:N
                                             ▼
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│ FolhaPagamentoDet (Lista de Lançamentos)                                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 1 - Salário Base (Automático A1)                                                 │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1001                                                                              │ │
│  │ valor: 3.500,00                                                                       │ │
│  │ parcelas: 1                                                                           │ │
│  │ origem: AUTOMATICO                                                                    │ │
│  │ vantagemDescontoDet: VDD que representa "A1 - Salário Base"                           │ │
│  │   └─ naturezaLancamento: PROVENTO                                                     │ │
│  │   └─ incideInss: SIM                                                                  │ │
│  │   └─ incideRpps: SIM                                                                  │ │
│  │   └─ incideIrrf: SIM                                                                  │ │
│  │   └─ tipoCalculo: "A1"                                                                │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 2 - Representação (Automático A2)                                                │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1002                                                                              │ │
│  │ valor: 500,00                                                                         │ │
│  │ parcelas: 1                                                                           │ │
│  │ origem: AUTOMATICO                                                                    │ │
│  │ vantagemDescontoDet: VDD "A2 - Representação"                                         │ │
│  │   └─ naturezaLancamento: PROVENTO                                                     │ │
│  │   └─ incideInss: SIM                                                                  │ │
│  │   └─ incideIrrf: SIM                                                                  │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 3 - Quinquênio (Automático A3)                                                   │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1003                                                                              │ │
│  │ valor: 350,00                                                                         │ │
│  │ parcelas: 1                                                                           │ │
│  │ origem: AUTOMATICO                                                                    │ │
│  │ vantagemDescontoDet: VDD "A3 - Quinquênio"                                            │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 4 - Gratificação de Função (Manual)                                              │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1004                                                                              │ │
│  │ valor: 800,00                                                                         │ │
│  │ parcelas: 1                                                                           │ │
│  │ origem: MANUAL                                                                        │ │
│  │ vantagemDescontoDet: VDD "Gratificação de Função"                                     │ │
│  │   └─ naturezaLancamento: PROVENTO                                                     │ │
│  │   └─ incideInss: SIM                                                                  │ │
│  │   └─ incideIrrf: SIM                                                                  │ │
│  │   └─ incideFerias: NÃO (gratificação não incorpora em férias)                         │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 5 - RPPS Servidor (Automático A8) - DESCONTO                                     │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1005                                                                              │ │
│  │ valor: 609,00 (14% de 4.350,00)                                                       │ │
│  │ parcelas: 1                                                                           │ │
│  │ origem: AUTOMATICO                                                                    │ │
│  │ vantagemDescontoDet: VDD "A8 - RPPS"                                                  │ │
│  │   └─ naturezaLancamento: DESCONTO                                                     │ │
│  │   └─ tipoCalculo: "A8"                                                                │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 6 - IRRF (Automático A9) - DESCONTO                                              │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1006                                                                              │ │
│  │ valor: 178,42                                                                         │ │
│  │ parcelas: 1                                                                           │ │
│  │ origem: AUTOMATICO                                                                    │ │
│  │ vantagemDescontoDet: VDD "A9 - IRRF"                                                  │ │
│  │   └─ naturezaLancamento: DESCONTO                                                     │ │
│  │   └─ tipoCalculo: "A9"                                                                │ │
│  │                                                                                        │ │
│  │ Memória de Cálculo IRRF:                                                              │ │
│  │ ─────────────────────────────────────────────────────────────────                     │ │
│  │ Base Bruta:         4.350,00                                                          │ │
│  │ (-) RPPS:             609,00                                                          │ │
│  │ (-) Dependentes:      379,18 (2 x 189,59)                                             │ │
│  │ (=) Base Líquida:   3.361,82                                                          │ │
│  │                                                                                        │ │
│  │ Faixa 2: 15% sobre 3.361,82 = 504,27                                                  │ │
│  │ (-) Dedução:        381,44                                                            │ │
│  │ (=) IRRF:           122,83                                                            │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ┌────────────────────────────────────────────────────────────────────────────────────────┐ │
│  │ ITEM 7 - Consignado Banco X (Manual/Vínculo) - DESCONTO                               │ │
│  ├────────────────────────────────────────────────────────────────────────────────────────┤ │
│  │ id: 1007                                                                              │ │
│  │ valor: 450,00                                                                         │ │
│  │ parcelas: 36 (parcela 12 de 48)                                                       │ │
│  │ origem: VINCULO (veio do vínculo funcional)                                           │ │
│  │ vantagemDescontoDet: VDD "Empréstimo Consignado"                                      │ │
│  │   └─ naturezaLancamento: DESCONTO                                                     │ │
│  │   └─ incideInss: NÃO                                                                  │ │
│  │   └─ incideIrrf: NÃO                                                                  │ │
│  └────────────────────────────────────────────────────────────────────────────────────────┘ │
│                                                                                             │
│  ══════════════════════════════════════════════════════════════════════════════════════════ │
│  TOTAIS:                                                                                    │
│  ──────────────────────────────────────────────────────────────────────────────────────     │
│  Total Proventos:  5.150,00 (3.500 + 500 + 350 + 800)                                       │
│  Total Descontos:  1.181,83 (609 + 122,83 + 450)                                            │
│  Total Líquido:    3.968,17                                                                 │
│  ══════════════════════════════════════════════════════════════════════════════════════════ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 5.3 Código do Cálculo de Bases de Incidência

```java
/**
 * Calcula as bases de incidência para cada tipo de desconto/benefício.
 * 
 * REGRA: Percorre todos os detalhes da folha e acumula valores nas bases
 * de acordo com as flags de incidência de cada rubrica.
 */
@Override
public void calcularBasesIncidencia(FolhaPagamento folha) {
    BigDecimal baseInss = BigDecimal.ZERO;
    BigDecimal baseRpps = BigDecimal.ZERO;
    BigDecimal baseIrrf = BigDecimal.ZERO;
    BigDecimal baseSalFam = BigDecimal.ZERO;
    BigDecimal baseFerias = BigDecimal.ZERO;
    BigDecimal base13 = BigDecimal.ZERO;

    // Determinar tipo de previdência do servidor
    String tipoPrevidencia = getTipoPrevidencia(folha);

    // Percorrer os detalhes da folha e acumular nas bases
    for (FolhaPagamentoDet detalhe : folha.getDetalhes()) {
        VantagemDescontoDet vdd = detalhe.getVantagemDescontoDet();
        if (vdd == null) continue;

        // Pular itens automáticos (serão recalculados)
        if (TipoCalculoAutomatico.isAutomatico(vdd.getTipoCalculo())) continue;

        // Apenas PROVENTOS entram nas bases (descontos não)
        if (vdd.getNaturezaLancamento() != NaturezaLancamento.PROVENTO) continue;

        BigDecimal valor = detalhe.getValor();
        if (valor == null || valor.compareTo(BigDecimal.ZERO) <= 0) continue;

        // Verificar cada flag de incidência
        if ("1".equals(tipoPrevidencia) && vdd.getIncideInss() == SimNao.SIM) {
            baseInss = baseInss.add(valor);
        }
        if ("2".equals(tipoPrevidencia) && vdd.getIncideRpps() == SimNao.SIM) {
            baseRpps = baseRpps.add(valor);
        }
        if (vdd.getIncideIrrf() == SimNao.SIM) {
            baseIrrf = baseIrrf.add(valor);
        }
        if (vdd.getIncideSalarioFamilia() == SimNao.SIM) {
            baseSalFam = baseSalFam.add(valor);
        }
        if (vdd.getIncideFerias() == SimNao.SIM) {
            baseFerias = baseFerias.add(valor);
        }
        if (vdd.getIncideDecimoTerceiro() == SimNao.SIM) {
            base13 = base13.add(valor);
        }
    }

    // Adicionar valores fixos (salário base, representação, quinquênio)
    BigDecimal salRepQuinq = folha.getSalarioBase()
            .add(folha.getRepresentacao())
            .add(folha.getQuinquenio());

    // Setar bases na folha
    folha.setBaseInssServidor(baseInss.add(salRepQuinq));
    folha.setBaseRppsServidor(baseRpps.add(salRepQuinq));
    folha.setBaseIrrfServidor(baseIrrf.add(salRepQuinq));
    folha.setBaseSalFamServidor(baseSalFam);
    folha.setBaseFeriasServidor(baseFerias.add(salRepQuinq));
    folha.setBase13SalarioServidor(base13.add(salRepQuinq));
}
```

### 5.4 Tipos de Cálculo Automático (A1-A9)

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         TIPOS DE CÁLCULO AUTOMÁTICO                                          │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌───────┬──────────────────────┬────────────────────────────────────────────────────────────────┐
│ CÓDIGO│ DESCRIÇÃO            │ COMO É CALCULADO                                               │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A1   │ Salário Base         │ Vem do VinculoFuncionalDet → Cargo → Remuneração              │
│       │                      │ Ou diretamente de FolhaPagamento.salarioBase                   │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A2   │ Representação        │ Vem do VinculoFuncionalDet.representacao                      │
│       │                      │ Ou de rubricas do vínculo com tipo "representação"             │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A3   │ Quinquênio           │ Calculado: (salarioBase × percentualQuinquenio)               │
│       │                      │ Percentual vem de VinculoFuncionalDet.percentualQuinquenio    │
│       │                      │ Ex: 5 anos = 5%, 10 anos = 10%, etc.                          │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A4   │ (Reservado)          │ Não utilizado atualmente                                       │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A5   │ Salário Família      │ Calculado pelo CalculoSalarioFamiliaService:                  │
│       │                      │ - Verifica se base está dentro do limite                       │
│       │                      │ - Multiplica qtdDependentes × valorCota                        │
│       │                      │ - Usa tabela da Legislação                                     │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A6   │ Adicional de Férias  │ Calculado: baseFeriasServidor ÷ 3                             │
│       │                      │ Só gera se folha.ferias = "1" (folha de férias)               │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A7   │ INSS Servidor        │ Calculado pelo CalculoPrevidenciaService.calcularINSS()       │
│       │                      │ Usa tabela progressiva do INSS (4 faixas)                      │
│       │                      │ Só gera se servidor é RGPS (CLT/Comissionado)                  │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A8   │ RPPS Servidor        │ Calculado pelo CalculoPrevidenciaService.calcularRPPS()       │
│       │                      │ Pode usar alíquota única (14%) ou progressiva (EC 103)        │
│       │                      │ Só gera se servidor é estatutário (RPPS)                       │
├───────┼──────────────────────┼────────────────────────────────────────────────────────────────┤
│  A9   │ IRRF                 │ Calculado pelo CalculoIRRFService.calcularIRRF()              │
│       │                      │ Usa tabela progressiva do IRRF (4 faixas + isento)            │
│       │                      │ Deduz: INSS/RPPS + dependentes                                 │
└───────┴──────────────────────┴────────────────────────────────────────────────────────────────┘
```

---

## 6. CÁLCULO DE PREVIDÊNCIA - DETALHAMENTO

### 6.1 INSS (RGPS) - Cálculo Progressivo

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         CÁLCULO INSS - EXEMPLO PRÁTICO                                       │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

TABELA INSS 2026 (exemplo):
┌──────────┬─────────────────────────┬───────────────┐
│  FAIXA   │      FAIXA SALARIAL     │   ALÍQUOTA    │
├──────────┼─────────────────────────┼───────────────┤
│    1     │ Até R$ 1.518,00         │     7,5%      │
│    2     │ De R$ 1.518,01 a 2.793,88│     9,0%      │
│    3     │ De R$ 2.793,89 a 4.190,83│    12,0%      │
│    4     │ De R$ 4.190,84 a 8.157,41│    14,0%      │
└──────────┴─────────────────────────┴───────────────┘

EXEMPLO: Servidor com base de R$ 5.000,00

Cálculo por faixas (PROGRESSIVO):
────────────────────────────────────────────────────────────────────

Faixa 1: R$ 1.518,00 × 7,5% = R$ 113,85
         (aplica 7,5% sobre o valor ATÉ o limite da faixa 1)

Faixa 2: (R$ 2.793,88 - R$ 1.518,00) × 9,0% 
         = R$ 1.275,88 × 9,0% = R$ 114,83
         (aplica 9% sobre a DIFERENÇA entre limites)

Faixa 3: (R$ 4.190,83 - R$ 2.793,88) × 12,0%
         = R$ 1.396,95 × 12,0% = R$ 167,63
         (aplica 12% sobre a DIFERENÇA entre limites)

Faixa 4: (R$ 5.000,00 - R$ 4.190,83) × 14,0%
         = R$ 809,17 × 14,0% = R$ 113,28
         (aplica 14% sobre o que EXCEDE o limite da faixa 3)

────────────────────────────────────────────────────────────────────
TOTAL INSS: R$ 113,85 + R$ 114,83 + R$ 167,63 + R$ 113,28 = R$ 509,59

Alíquota EFETIVA: R$ 509,59 ÷ R$ 5.000,00 = 10,19%
(Não é 14%! É a média ponderada de todas as faixas)
```

### 6.2 RPPS - Cálculo com Alíquota Única vs Progressiva

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         CÁLCULO RPPS - DUAS MODALIDADES                                      │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

MODALIDADE 1: ALÍQUOTA ÚNICA (Municípios que não aderiram à EC 103)
──────────────────────────────────────────────────────────────────────────────────────────────

if (!legislacao.getRppsProgressivo()) {
    // Cálculo simples
    contribuicao = baseCalculo × rppsAliquota1 / 100
}

EXEMPLO: Base R$ 5.000,00, Alíquota 14%
Cálculo: R$ 5.000,00 × 14% = R$ 700,00


MODALIDADE 2: ALÍQUOTAS PROGRESSIVAS (EC 103/2019)
──────────────────────────────────────────────────────────────────────────────────────────────

if (legislacao.getRppsProgressivo()) {
    // Cálculo por faixas (similar ao INSS)
}

TABELA RPPS EC 103/2019:
┌──────────┬─────────────────────────┬───────────────┐
│  FAIXA   │      FAIXA SALARIAL     │   ALÍQUOTA    │
├──────────┼─────────────────────────┼───────────────┤
│    1     │ Até R$ 1.518,00 (SM)    │     7,5%      │
│    2     │ De R$ 1.518,01 a 2.000  │     9,0%      │
│    3     │ De R$ 2.000,01 a 3.000  │    12,0%      │
│    4     │ De R$ 3.000,01 a 5.839  │    14,0%      │
│    5     │ De R$ 5.839,01 a 10.000 │    14,5%      │
│    6     │ De R$ 10.000,01 a 20.000│    16,5%      │
│    7     │ De R$ 20.000,01 a 39.000│    19,0%      │
│    8     │ Acima de R$ 39.000      │    22,0%      │
└──────────┴─────────────────────────┴───────────────┘

EXEMPLO: Servidor com base de R$ 8.000,00 (EC 103)

Faixa 1: R$ 1.518,00 × 7,5%  = R$ 113,85
Faixa 2: R$ 482,00 × 9,0%    = R$ 43,38
Faixa 3: R$ 1.000,00 × 12,0% = R$ 120,00
Faixa 4: R$ 2.839,00 × 14,0% = R$ 397,46
Faixa 5: R$ 2.161,00 × 14,5% = R$ 313,35
────────────────────────────────────────────────────────────────────
TOTAL RPPS: R$ 988,04
Alíquota EFETIVA: 12,35%
```

### 6.3 Código do Cálculo de Previdência

```java
@Service
@RequiredArgsConstructor
public class CalculoPrevidenciaService {
    
    /**
     * Calcula INSS (RGPS) com alíquotas progressivas
     */
    public ResultadoCalculoPrevidencia calcularINSS(BigDecimal baseCalculo, Legislacao leg) {
        if (baseCalculo.compareTo(BigDecimal.ZERO) <= 0) {
            return ResultadoCalculoPrevidencia.semContribuicao();
        }
        
        BigDecimal contribuicaoTotal = BigDecimal.ZERO;
        BigDecimal baseRestante = baseCalculo;
        BigDecimal limiteAnterior = BigDecimal.ZERO;
        
        // Faixa 1
        if (baseRestante.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal limiteFaixa = leg.getInssFaixa1Limite();
            BigDecimal baseFaixa = baseRestante.min(limiteFaixa.subtract(limiteAnterior));
            contribuicaoTotal = contribuicaoTotal.add(
                baseFaixa.multiply(leg.getInssFaixa1Aliquota())
                         .divide(CEM, 2, RoundingMode.HALF_UP)
            );
            baseRestante = baseRestante.subtract(baseFaixa);
            limiteAnterior = limiteFaixa;
        }
        
        // Faixas 2, 3, 4... (mesmo padrão)
        // ...
        
        return ResultadoCalculoPrevidencia.builder()
            .baseCalculo(baseCalculo)
            .valorContribuicao(contribuicaoTotal)
            .aliquota(calcularAliquotaEfetiva(contribuicaoTotal, baseCalculo))
            .aliquotaPatronal(leg.getInssAliquotaPatronal())
            .tipoPrevidencia(TipoPrevidencia.RGPS)
            .build();
    }
    
    /**
     * Calcula RPPS com alíquota única ou progressiva
     */
    public ResultadoCalculoPrevidencia calcularRPPS(BigDecimal baseCalculo, Legislacao leg) {
        if (baseCalculo.compareTo(BigDecimal.ZERO) <= 0) {
            return ResultadoCalculoPrevidencia.semContribuicao();
        }
        
        BigDecimal contribuicaoTotal;
        BigDecimal aliquotaEfetiva;
        
        if (Boolean.TRUE.equals(leg.getRppsProgressivo())) {
            // EC 103/2019 - Alíquotas progressivas
            contribuicaoTotal = calcularRPPSProgressivo(baseCalculo, leg);
            aliquotaEfetiva = calcularAliquotaEfetiva(contribuicaoTotal, baseCalculo);
        } else {
            // Alíquota única
            contribuicaoTotal = baseCalculo
                .multiply(leg.getRppsAliquota1())
                .divide(CEM, 2, RoundingMode.HALF_UP);
            aliquotaEfetiva = leg.getRppsAliquota1();
        }
        
        return ResultadoCalculoPrevidencia.builder()
            .baseCalculo(baseCalculo)
            .valorContribuicao(contribuicaoTotal)
            .aliquota(aliquotaEfetiva)
            .aliquotaPatronal(leg.getRppsPatronal())
            .tipoPrevidencia(TipoPrevidencia.RPPS)
            .build();
    }
}
```

---

## 7. CÁLCULO DO IRRF - DETALHAMENTO

### 7.1 Fluxo Completo do Cálculo IRRF

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              CÁLCULO IRRF - FLUXO COMPLETO                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

ENTRADA:
─────────────────────────────────────────────────────────────────────────────────────────────
• baseIrrfBruta = R$ 5.150,00 (todos os proventos que incidem IRRF)
• valorPrevidencia = R$ 609,00 (RPPS já calculado)
• qtdDependentes = 2
• dataNascimento = 15/03/1960 (65 anos - maior de 65)
• legislacao = tabela IRRF 2026


PASSO 1: Calcular Deduções
─────────────────────────────────────────────────────────────────────────────────────────────

┌────────────────────────────────────────────────────────────────────────────┐
│ DEDUÇÕES PERMITIDAS PELO IRRF                                              │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│ 1. Contribuição Previdenciária (INSS ou RPPS)                              │
│    Valor: R$ 609,00                                                        │
│                                                                            │
│ 2. Dependentes                                                             │
│    Quantidade: 2                                                           │
│    Valor por dependente: R$ 189,59 (tabela 2026)                           │
│    Total: 2 × R$ 189,59 = R$ 379,18                                        │
│                                                                            │
│ 3. Parcela Isenta Maior de 65 Anos                                         │
│    Servidor nasceu em 1960, tem 65 anos                                    │
│    Parcela isenta adicional: R$ 1.903,98 (1 salário mínimo)                │
│    ⚠️ Só para maiores de 65 anos!                                          │
│                                                                            │
│ TOTAL DEDUÇÕES: R$ 609,00 + R$ 379,18 + R$ 1.903,98 = R$ 2.892,16         │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘


PASSO 2: Calcular Base de Cálculo Líquida
─────────────────────────────────────────────────────────────────────────────────────────────

Base Bruta:           R$ 5.150,00
(-) Previdência:      R$   609,00
(-) Dependentes:      R$   379,18
(-) Isento 65+:       R$ 1.903,98
═══════════════════════════════════
Base Líquida:         R$ 2.257,84


PASSO 3: Aplicar Tabela Progressiva
─────────────────────────────────────────────────────────────────────────────────────────────

TABELA IRRF 2026:
┌──────────┬─────────────────────────┬───────────┬─────────────────┐
│  FAIXA   │      BASE DE CÁLCULO    │ ALÍQUOTA  │ PARCELA A DEDUZIR│
├──────────┼─────────────────────────┼───────────┼─────────────────┤
│    1     │ Até R$ 2.259,20         │   ISENTO  │      -          │
│    2     │ De R$ 2.259,21 a 2.826,65│   7,5%    │ R$ 169,44       │
│    3     │ De R$ 2.826,66 a 3.751,05│  15,0%    │ R$ 381,44       │
│    4     │ De R$ 3.751,06 a 4.664,68│  22,5%    │ R$ 662,77       │
│    5     │ Acima de R$ 4.664,68    │  27,5%    │ R$ 896,00       │
└──────────┴─────────────────────────┴───────────┴─────────────────┘

Base Líquida: R$ 2.257,84

Resultado: Base R$ 2.257,84 está na FAIXA 1 (até R$ 2.259,20)
           SERVIDOR ISENTO DE IRRF!

IRRF = R$ 0,00


OUTRO EXEMPLO: Servidor sem isenção de 65+
─────────────────────────────────────────────────────────────────────────────────────────────

Base Bruta:           R$ 5.150,00
(-) Previdência:      R$   609,00
(-) Dependentes:      R$   379,18
═══════════════════════════════════
Base Líquida:         R$ 4.161,82

Faixa 4: 22,5% sobre R$ 4.161,82
IRRF Bruto = R$ 4.161,82 × 22,5% = R$ 936,41
(-) Parcela a Deduzir = R$ 662,77
═══════════════════════════════════
IRRF Final = R$ 273,64
```

### 7.2 Código do Cálculo IRRF

```java
@Service
@RequiredArgsConstructor
public class CalculoIRRFService {
    
    public ResultadoCalculoIRRF calcularIRRF(
            BigDecimal baseBruta,
            BigDecimal valorPrevidencia,
            int qtdDependentes,
            LocalDate dataNascimento,
            Legislacao leg) {
        
        // 1. Calcular deduções
        BigDecimal deducaoPrevidencia = valorPrevidencia;
        BigDecimal deducaoDependentes = leg.getIrDeducaoDep()
            .multiply(new BigDecimal(qtdDependentes));
        
        // 2. Verificar isenção 65+
        BigDecimal isencao65 = BigDecimal.ZERO;
        if (dataNascimento != null) {
            int idade = Period.between(dataNascimento, LocalDate.now()).getYears();
            if (idade >= 65) {
                isencao65 = leg.getSalarioMinimo(); // 1 SM isento para 65+
            }
        }
        
        // 3. Calcular base líquida
        BigDecimal baseLiquida = baseBruta
            .subtract(deducaoPrevidencia)
            .subtract(deducaoDependentes)
            .subtract(isencao65);
        
        if (baseLiquida.compareTo(BigDecimal.ZERO) <= 0) {
            return ResultadoCalculoIRRF.isento(baseBruta, baseLiquida);
        }
        
        // 4. Determinar faixa e calcular
        BigDecimal aliquota;
        BigDecimal parcelaADeduzir;
        
        if (baseLiquida.compareTo(leg.getIrFaixa1Limite()) <= 0) {
            return ResultadoCalculoIRRF.isento(baseBruta, baseLiquida);
        } else if (baseLiquida.compareTo(leg.getIrFaixa2Limite()) <= 0) {
            aliquota = leg.getIrFaixa2Aliquota();
            parcelaADeduzir = leg.getIrFaixa2Deducao();
        } else if (baseLiquida.compareTo(leg.getIrFaixa3Limite()) <= 0) {
            aliquota = leg.getIrFaixa3Aliquota();
            parcelaADeduzir = leg.getIrFaixa3Deducao();
        } else if (baseLiquida.compareTo(leg.getIrFaixa4Limite()) <= 0) {
            aliquota = leg.getIrFaixa4Aliquota();
            parcelaADeduzir = leg.getIrFaixa4Deducao();
        } else {
            aliquota = leg.getIrFaixa5Aliquota(); // 27,5%
            parcelaADeduzir = leg.getIrFaixa5Deducao();
        }
        
        // 5. Calcular IRRF
        BigDecimal irrfBruto = baseLiquida
            .multiply(aliquota)
            .divide(CEM, 2, RoundingMode.HALF_UP);
        
        BigDecimal irrfFinal = irrfBruto.subtract(parcelaADeduzir);
        
        // Não pode ser negativo
        if (irrfFinal.compareTo(BigDecimal.ZERO) < 0) {
            irrfFinal = BigDecimal.ZERO;
        }
        
        return ResultadoCalculoIRRF.builder()
            .baseBruta(baseBruta)
            .baseCalculoLiquida(baseLiquida)
            .aliquota(aliquota)
            .parcelaADeduzir(parcelaADeduzir)
            .valorIRRF(irrfFinal)
            .deducaoPrevidencia(deducaoPrevidencia)
            .deducaoDependentes(deducaoDependentes)
            .isencao65Anos(isencao65)
            .build();
    }
}
```

---

**Continua na PARTE 3: Módulos a Implementar - Consignado, Férias, 13º**

