# Sprint 1 — Plano de Ação Detalhado

**Versão:** 1.0  
**Data:** 2026-02-22  
**Escopo:** Correção de gaps críticos + relatórios prioritários + cobertura de testes  
**Duração estimada:** 2 semanas (10 dias úteis)

---

## Resumo Executivo

Análise completa do backend revelou **3 TODOs críticos** (1 stale, 2 não-implementados), **3 relatórios com schema incompatível**, **8 relatórios faltantes** e **cobertura de testes < 1%** (53 testes em 2 arquivos para 3.299+ linhas de serviço core).

### Inventário Atual

| Item | Estado | Impacto | Esforço |
|------|--------|---------|---------|
| TODO `isFechada` (CompetenciaController:116) | STALE — já implementado | Nenhum (limpeza) | 5 min |
| TODO `copiarVantagens` (ProcessamentoFolhaService:2156) | **NÃO IMPLEMENTADO** | Crítico — vantagens não migram entre competências | 4h |
| TODO CNAB (ExportacaoController:497) | **NÃO IMPLEMENTADO** (retorna 501) | Crítico — pagamento bancário impossível | 8h |
| FolhaPGResumo.jrxml | Schema incompatível (INNER JOINs) | Relatório quebrado | 2h |
| FichaFinanceira.jrxml | Schema incompatível | Relatório quebrado | 2h |
| ComprovanteIR.jrxml | Schema incompatível | Relatório quebrado | 2h |
| 8 relatórios novos (#1-6, #8, #14) | Não existem | Funcionalidade faltante | 16h |
| Testes unitários | 53 testes / 2 arquivos (<1%) | Risco de regressão | 12h |

**Total estimado:** ~46h de trabalho efetivo

---

## FASE 1 — TODOs Críticos (Dias 1-3)

### 1.1 Remover TODO Stale: `isFechada` ⏱️ 5 min

**Arquivo:** `ws/erh/core/competencia/CompetenciaController.java` linha ~116

**Estado atual:** O comentário `// TODO: implement isFechada method in CompetenciaService` é **OBSOLETO**. O método `isFechada()` **já existe** em `CompetenciaService` e é usado em 4 locais no código.

**Ação:** Remover o comentário TODO da linha 116.

```java
// DE:
boolean fechada = exists && competenciaService.isFechada(ugId, solicitada);  // TODO: implement isFechada method in CompetenciaService

// PARA:
boolean fechada = exists && competenciaService.isFechada(ugId, solicitada);
```

---

### 1.2 Implementar `copiarVantagensParaProximaCompetencia` ⏱️ 4h

**Arquivo:** `ws/erh/folha/processamento/service/ProcessamentoFolhaService.java` linhas 2153-2165

**Estado atual:** Método é um stub vazio que apenas loga warning:
```java
private void copiarVantagensParaProximaCompetencia(Long unidadeGestoraId, String competencia, String proximaCompetencia) {
    log.debug("Copiando vantagens/descontos para competência {}", proximaCompetencia);
    // TODO: Implementar cópia de vantagens/descontos
    log.warn("Cópia de vantagens/descontos ainda não implementada - competência: {} -> {}", 
             competencia, proximaCompetencia);
}
```

**Modelo de dados relevante:**

- `VantagemDescontoDet` (tabela `vantagem_desconto_det`):
  - `id`, `mes` (String), `exercicio` (String), `naturezaLancamento` (PROVENTO/DESCONTO), `tipoCalculo`, `valor` (BigDecimal), `incideIrrf/Inss/Rpps/SalarioFamilia/Ferias/DecimoTerceiro` (SimNao enum), `vantagemDesconto` (ManyToOne → VantagemDesconto)
  - Herda de `AbstractExecucaoTenantEntity`: `unidadeGestoraId`, `excluido`

- `VinculoVantagemDesconto` (tabela `vinculo_vantagem_desconto`):
  - Associa VinculoFuncional ↔ VantagemDescontoDet
  - Campos: `valorBase`, `fixo` (SIM/NAO), `dataInicio`, `dataFim`, `parcelas`
  - Constraint: unique(vinculo_funcional_id, vantagem_desconto_det_id)

**Repository existente:**
```java
// VantagemDescontoDetRepository
Optional<VantagemDescontoDet> findByVantagemDescontoIdAndMesAndExercicioAndUnidadeGestoraId(
    Long vantagemDescontoId, String mes, String exercicio, Long unidadeGestoraId);
```

**⚠️ PROBLEMA:** O repository **não tem** método para buscar TODOS os detalhes por mes/exercicio/unidadeGestoraId. Precisa criar.

**Implementação necessária:**

#### Passo 1: Adicionar query no `VantagemDescontoDetRepository`

```java
@Query("SELECT vdd FROM VantagemDescontoDet vdd " +
       "LEFT JOIN FETCH vdd.vantagemDesconto " +
       "WHERE vdd.mes = :mes AND vdd.exercicio = :exercicio " +
       "AND vdd.unidadeGestoraId = :unidadeGestoraId AND vdd.excluido = false")
List<VantagemDescontoDet> findAllByMesAndExercicioAndUnidadeGestoraId(
    @Param("mes") String mes,
    @Param("exercicio") String exercicio,
    @Param("unidadeGestoraId") Long unidadeGestoraId);
```

#### Passo 2: Adicionar método no `VantagemDescontoDetService`

```java
public List<VantagemDescontoDet> findAllByCompetencia(String mes, String exercicio, Long unidadeGestoraId) {
    return repository.findAllByMesAndExercicioAndUnidadeGestoraId(mes, exercicio, unidadeGestoraId);
}
```

#### Passo 3: Implementar o método em `ProcessamentoFolhaService`

```java
private void copiarVantagensParaProximaCompetencia(Long unidadeGestoraId, String competencia, String proximaCompetencia) {
    log.debug("Copiando vantagens/descontos para competência {}", proximaCompetencia);
    
    // Extrair mes/exercicio da competência atual (formato "YYYY-MM")
    String[] partes = competencia.split("-");
    String exercicioAtual = partes[0];
    String mesAtual = partes[1];
    
    String[] partesProxima = proximaCompetencia.split("-");
    String exercicioProximo = partesProxima[0];
    String mesProximo = partesProxima[1];
    
    // 1. Buscar todos VantagemDescontoDet da competência atual
    List<VantagemDescontoDet> detalhesAtuais = vantagemDescontoDetService
        .findAllByCompetencia(mesAtual, exercicioAtual, unidadeGestoraId);
    
    if (detalhesAtuais.isEmpty()) {
        log.info("Nenhuma vantagem/desconto encontrada para copiar - competência: {}", competencia);
        return;
    }
    
    int copiados = 0;
    int ignorados = 0;
    
    for (VantagemDescontoDet detalheOrigem : detalhesAtuais) {
        // 2. Verificar se já existe na próxima competência
        Optional<VantagemDescontoDet> existente = vantagemDescontoDetRepository
            .findByVantagemDescontoIdAndMesAndExercicioAndUnidadeGestoraId(
                detalheOrigem.getVantagemDesconto() != null ? detalheOrigem.getVantagemDesconto().getId() : null,
                mesProximo, exercicioProximo, unidadeGestoraId);
        
        if (existente.isPresent()) {
            ignorados++;
            continue;
        }
        
        // 3. Clonar para próxima competência
        VantagemDescontoDet novoDetalhe = new VantagemDescontoDet();
        novoDetalhe.setMes(mesProximo);
        novoDetalhe.setExercicio(exercicioProximo);
        novoDetalhe.setNaturezaLancamento(detalheOrigem.getNaturezaLancamento());
        novoDetalhe.setTipoCalculo(detalheOrigem.getTipoCalculo());
        novoDetalhe.setValor(detalheOrigem.getValor());
        novoDetalhe.setIncideIrrf(detalheOrigem.getIncideIrrf());
        novoDetalhe.setIncideInss(detalheOrigem.getIncideInss());
        novoDetalhe.setIncideRpps(detalheOrigem.getIncideRpps());
        novoDetalhe.setIncideSalarioFamilia(detalheOrigem.getIncideSalarioFamilia());
        novoDetalhe.setIncideFerias(detalheOrigem.getIncideFerias());
        novoDetalhe.setIncideDecimoTerceiro(detalheOrigem.getIncideDecimoTerceiro());
        novoDetalhe.setVantagemDesconto(detalheOrigem.getVantagemDesconto());
        novoDetalhe.setUnidadeGestoraId(unidadeGestoraId);
        
        vantagemDescontoDetService.save(novoDetalhe);
        copiados++;
    }
    
    log.info("Cópia de vantagens concluída: {} copiados, {} ignorados (já existiam) - {} -> {}", 
             copiados, ignorados, competencia, proximaCompetencia);
}
```

**Padrão seguido:** Método irmão `copiarFolhasParaProximaCompetencia()` (linhas 2166+) que clona `FolhaPagamento` zerando bases calculadas.

**Dependências já injetadas no service:**
- `VantagemDescontoDetService` — precisa verificar se está `@Autowired` no service
- `VantagemDescontoDetRepository` — pode precisar ser injetado diretamente para o `findBy...`

---

### 1.3 Implementar Geração CNAB ⏱️ 8h

**Arquivo:** `ws/erh/obrigacoes/exportacao/controller/ExportacaoController.java` linhas 487-502

**Estado atual:** Endpoint `GET /cnab` retorna HTTP 501 ("em desenvolvimento"). Porém:
- ✅ `calcularLiquidoParaCnab()` (linha 576+) — **FUNCIONA**
- ✅ `contarServidoresParaCnab()` — **FUNCIONA**
- ✅ Endpoint `GET /cnab/preview` — **FUNCIONA** (retorna totalServidores e valorTotalLiquido)
- ❌ Não existe: `CnabService`, `CnabWriter`, modelos de registro CNAB

**Dados disponíveis para CNAB (entidades):**
- `Servidor`: `banco_id` (FK→Banco), `agencia`, `agencia_dv`, `contaCorrente`, `contaCorrenteDv`
- `Banco`: `codigo` (código FEBRABAN 3 dígitos), `descricao`
- `FolhaPagamento`: todos os campos de base/alíquota para calcular líquido
- `UnidadeGestora`: `cnpj`, `nome` (dados do cedente/empresa)

**Arquivos a criar:**

#### 1.3.1 Modelo: `CnabRegistro.java`
Pacote: `ws.erh.obrigacoes.exportacao.model`
```
- CnabHeader (registro tipo 0): banco, empresa, data, sequencial
- CnabHeaderLote (registro tipo 1): tipo pagamento, forma
- CnabDetalheSegmentoA (registro tipo 3-A): dados bancários do favorecido
- CnabDetalheSegmentoB (registro tipo 3-B): dados complementares (CPF, endereço)
- CnabTrailerLote (registro tipo 5): totalização do lote
- CnabTrailer (registro tipo 9): totalização do arquivo
```

#### 1.3.2 Service: `CnabService.java`
Pacote: `ws.erh.obrigacoes.exportacao.service`
```
- gerarArquivoCnab240(Long tenantId, String competencia) → byte[]
- montarHeader(UnidadeGestora ug, Banco banco, int sequencial)
- montarDetalhesPagamento(List<FolhaPagamento> folhas)
- montarTrailer(int totalRegistros, BigDecimal valorTotal)
- formatarLinha240(String... campos) → String (240 chars padded)
```

#### 1.3.3 Atualizar ExportacaoController
Substituir o bloco 501 por chamada ao CnabService:
```java
@GetMapping("/cnab")
public ResponseEntity<byte[]> exportarCnab(@RequestParam Integer ano, @RequestParam Integer mes) {
    Long tenantId = TenantContext.getCurrentUnidadeGestoraId();
    String competencia = String.format("%04d-%02d", ano, mes);
    String nomeArquivo = String.format("REMESSA_BANCARIA_%04d_%02d.txt", ano, mes);
    
    byte[] arquivo = cnabService.gerarArquivoCnab240(tenantId, competencia);
    
    return ResponseEntity.ok()
        .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + nomeArquivo + "\"")
        .contentType(MediaType.TEXT_PLAIN)
        .body(arquivo);
}
```

#### 1.3.4 Remover TODO stale (linha 472)
O TODO `// TODO: Calcular valor total do líquido a pagar` no endpoint preview é **STALE** — `calcularLiquidoParaCnab()` já está implementado e funciona.

---

## FASE 2 — Relatórios com Schema Incompatível (Dias 3-4)

### 2.1 Problema Identificado

Os 3 relatórios desabilitados usam `INNER JOIN` onde `FolhaPG.jrxml` (que funciona) usa `LEFT JOIN`:

| Relatório | JOINs problemáticos | Consequência |
|-----------|---------------------|--------------|
| FolhaPGResumo.jrxml | `INNER JOIN cargo`, `INNER JOIN tce_tipo_vinculo`, `INNER JOIN tce_tipo_ato_pessoal`, `INNER JOIN tce_regime_previdenciario` | Servidores sem cargo/vínculo TCE = excluídos do relatório |
| FichaFinanceira.jrxml | Idem + JOINs por período anual | Idem |
| ComprovanteIR.jrxml | Idem + cálculo IRRF anual | Idem |

Além disso, `FolhaPGResumo` filtra por `dataInicio/dataFim` enquanto `FolhaPG` filtra por `competencia` (parâmetro mais simples e correto).

### 2.2 Solução: Atualizar JOINs e Filtros

**Para cada relatório:**
1. Converter `INNER JOIN cargo` → `LEFT JOIN cargo`
2. Converter `INNER JOIN tce_tipo_vinculo` → `LEFT JOIN tce_tipo_vinculo`
3. Converter `INNER JOIN tce_tipo_ato_pessoal` → `LEFT JOIN tce_tipo_ato_pessoal`
4. Converter `INNER JOIN tce_regime_previdenciario` → `LEFT JOIN tce_regime_previdenciario`
5. Adicionar parâmetro `competencia` (String) se ausente
6. Adicionar `COALESCE` em campos que podem ser NULL
7. Atualizar filtro WHERE para usar `fp.competencia = $P{competencia}` em vez de range de datas (para FolhaPGResumo)

**Modelo a seguir:** Queries de [FolhaPG.jrxml](eRH-Service/src/main/resources/reports/folha/FolhaPG.jrxml) linhas 40-130.

### 2.3 FolhaPGResumo.jrxml — Correções Específicas

```sql
-- DE (linhas 137-148):
inner join cargo c on vf.cargo_id = c.id
inner join lotacao l on vfd.lotacao_id = l.id
inner join nivel n on vfd.nivel_id = n.id
inner join tce_tipo_vinculo ttv on vf.tce_tipo_vinculo_id = ttv.id
inner join tce_tipo_ato_pessoal ttp on vfd.tce_tipo_ato_pessoal_id = ttp.id
inner join tce_regime_previdenciario trp on vfd.tce_regime_previdenciario_id = trp.id

-- PARA:
LEFT JOIN cargo c ON c.id = vf.cargo_id
INNER JOIN lotacao l ON l.id = vfd.lotacao_id
INNER JOIN nivel n ON n.id = vfd.nivel_id
LEFT JOIN tce_tipo_vinculo ttv ON ttv.id = vf.tce_tipo_vinculo_id
LEFT JOIN tce_tipo_ato_pessoal ttp ON ttp.id = vfd.tce_tipo_ato_pessoal_id
LEFT JOIN tce_regime_previdenciario trp ON trp.id = vfd.tce_regime_previdenciario_id
```

Adicionar parâmetro `competencia` e ajustar WHERE:
```sql
-- DE:
and fp.competencia >= SUBSTRING($P{dataInicio}, 1, 7)
and fp.competencia <= SUBSTRING($P{dataFim}, 1, 7)

-- PARA:
and fp.competencia = $P{competencia}
```

### 2.4 FichaFinanceira.jrxml / ComprovanteIR.jrxml

Aplicar mesma correção de JOINs. Estes usam range de datas por natureza (ficha anual / comprovante anual), então manter `dataInicio/dataFim` mas converter JOINs para LEFT JOIN.

---

## FASE 3 — Relatórios Novos (Dias 4-7)

### Template Base

Todos os novos relatórios seguem o padrão de `FolhaPG.jrxml`:
- **Parâmetros padrão:** cabec1-5, rodape1-5, exercicio, cnpj, LOGO_PARAM, THEME_* colors, competencia
- **JOIN chain:** `folhapagamento → vinculofuncionaldet → vinculo_funcional → servidor → cargo → lotacao → nivel`
- **WHERE base:** `fp.excluido = false AND fp.competencia = $P{competencia}`
- **JOINs opcionais:** LEFT JOIN sempre (nunca INNER para entidades não-obrigatórias)

### 3.1 Relatório #1: Servidores por Lotação ⏱️ 1.5h

**Arquivo:** `reports/folha/ServidoresPorLotacao.jrxml`
**SQL:**
```sql
SELECT l.descricao AS lotacao, l.codigo AS codigo_lotacao,
       vf.matricula, s.nome AS nomeservidor, s.cpf AS cpfservidor,
       c.descricao AS cargo, n.descricao AS nivel,
       fp.salario_base AS salariobase
FROM folhapagamento fp
INNER JOIN vinculofuncionaldet vfd ON vfd.id = fp.vinculo_funcional_det_id
INNER JOIN vinculo_funcional vf ON vf.id = vfd.vinculo_funcional_id
INNER JOIN servidor s ON s.id = vf.servidor_id
INNER JOIN lotacao l ON l.id = vfd.lotacao_id
INNER JOIN nivel n ON n.id = vfd.nivel_id
LEFT JOIN cargo c ON c.id = vf.cargo_id
WHERE fp.excluido = false AND fp.competencia = $P{competencia}
ORDER BY l.descricao, s.nome
```
**Agrupamento:** Group por `lotacao` (startNewPage=true)
**Variáveis:** `COUNT(DISTINCT idservidor)` por lotação, `SUM(salariobase)` por lotação

### 3.2 Relatório #2: Servidores por Cargo ⏱️ 1.5h

**Arquivo:** `reports/folha/ServidoresPorCargo.jrxml`
**SQL:** Mesmo JOIN chain, GROUP BY cargo
**Agrupamento:** Group por `cargo` (startNewPage=true)

### 3.3 Relatório #3: Resumo por Rubrica ⏱️ 2h

**Arquivo:** `reports/folha/ResumoPorRubrica.jrxml`
**SQL:**
```sql
SELECT vd.descricao AS rubrica, gvd.descricao AS grupo,
       vdd.natureza_lancamento,
       SUM(fpd.valor) AS total_valor,
       COUNT(DISTINCT fp.id) AS qtd_servidores
FROM folhapagamento fp
INNER JOIN folhapagamentodet fpd ON fpd.folha_pagamento_id = fp.id
INNER JOIN vantagem_desconto_det vdd ON vdd.id = fpd.vantagem_desconto_det_id AND vdd.excluido = false
LEFT JOIN vantagem_desconto vd ON vd.id = vdd.vantagem_desconto_id AND vd.excluido = false
LEFT JOIN grupo_vantagem_desconto gvd ON gvd.id = vd.grupo_vantagem_desconto_id AND gvd.excluido = false
WHERE fp.excluido = false AND fp.competencia = $P{competencia}
GROUP BY vd.descricao, gvd.descricao, vdd.natureza_lancamento
ORDER BY vdd.natureza_lancamento, gvd.descricao, vd.descricao
```
**Agrupamento:** Group por `natureza_lancamento` (PROVENTO / DESCONTO)
**Variáveis:** soma por grupo, soma geral de proventos vs descontos

### 3.4 Relatório #4: Líquido por Banco ⏱️ 2h

**Arquivo:** `reports/folha/LiquidoPorBanco.jrxml`
**SQL:**
```sql
SELECT b.codigo AS codigo_banco, b.descricao AS banco,
       s.agencia, s.conta_corrente,
       vf.matricula, s.nome AS nomeservidor,
       SUM(CASE WHEN vdd.natureza_lancamento = 'PROVENTO' THEN fpd.valor ELSE 0 END) AS total_proventos,
       SUM(CASE WHEN vdd.natureza_lancamento = 'DESCONTO' THEN fpd.valor ELSE 0 END) AS total_descontos,
       SUM(CASE WHEN vdd.natureza_lancamento = 'PROVENTO' THEN fpd.valor ELSE -fpd.valor END) AS liquido
FROM folhapagamento fp
... (JOIN chain padrão + LEFT JOIN banco b ON s.banco_id = b.id)
WHERE fp.excluido = false AND fp.competencia = $P{competencia}
GROUP BY b.codigo, b.descricao, s.agencia, s.conta_corrente, vf.matricula, s.nome
ORDER BY b.descricao, s.nome
```
**Agrupamento:** Group por `banco`
**Variáveis:** total líquido por banco, total geral

### 3.5 Relatório #5: Contribuições Previdenciárias ⏱️ 2h

**Arquivo:** `reports/previdencia/ContribuicoesPrevidenciarias.jrxml`
**SQL:**
```sql
SELECT vf.matricula, s.nome, s.cpf,
       trp.codigo AS regime,
       fp.base_inss_servidor, fp.aliq_inss_servidor, fp.aliq_inss_patronal,
       fp.base_rpps_servidor, fp.aliq_rpps_servidor, fp.aliq_rpps_patronal,
       l.descricao AS lotacao
FROM folhapagamento fp
... (JOIN chain padrão + LEFT JOIN tce_regime_previdenciario trp)
WHERE fp.excluido = false AND fp.competencia = $P{competencia}
ORDER BY trp.codigo, s.nome
```
**Agrupamento:** Group por `regime` (RGPS / RPPS)
**Variáveis:** SUM(base * aliquota) por regime

### 3.6 Relatório #6: IRRF ⏱️ 2h

**Arquivo:** `reports/folha/RelatorioIRRF.jrxml`
**SQL:**
```sql
SELECT vf.matricula, s.nome, s.cpf,
       fp.base_irrf_servidor, fp.aliq_irrf_servidor,
       fp.deducao_dep_irrf_servidor, fp.deducao_irrf_servidor,
       fp.qtd_dep_irrf,
       ROUND(fp.base_irrf_servidor * fp.aliq_irrf_servidor / 100, 2) - fp.deducao_irrf_servidor AS irrf_retido,
       l.descricao AS lotacao
FROM folhapagamento fp
... (JOIN chain padrão)
WHERE fp.excluido = false AND fp.competencia = $P{competencia}
  AND fp.base_irrf_servidor > 0
ORDER BY s.nome
```

### 3.7 Relatório #8: 13º Salário ⏱️ 2h

**Arquivo:** `reports/folha/MemoriaCalculo13.jrxml`
**Tabela dedicada:** `memoria_calculo_13` (já existente com 25+ campos)
**SQL:**
```sql
SELECT mc.servidor_nome, mc.matricula, mc.cpf,
       mc.cargo, mc.lotacao, mc.nivel,
       mc.tipo_parcela, mc.competencia,
       mc.salario_base, mc.representacao, mc.quinquenio,
       mc.meses_trabalhados, mc.avos,
       mc.base_calculo_13, mc.valor_bruto_13,
       mc.base_inss, mc.valor_inss,
       mc.base_rpps, mc.valor_rpps,
       mc.base_irrf, mc.valor_irrf,
       mc.valor_liquido_13,
       mc.regime_previdenciario
FROM memoria_calculo_13 mc
WHERE mc.excluido = false AND mc.competencia = $P{competencia}
  AND mc.unidade_gestora_id = CAST($P{filtro1} AS BIGINT)
ORDER BY mc.lotacao, mc.servidor_nome
```
**Agrupamento:** Group por `lotacao`, subgroup por `tipo_parcela`

### 3.8 Relatório #14: Previdência / Guia RPPS ⏱️ 2h

**Arquivo:** `reports/previdencia/GuiaRPPSRelatorio.jrxml`
**Tabela dedicada:** `guia_rpps` (já existente)

> Nota: Já existe `GuiaRPPS.jrxml` — verificar se pode ser adaptado ou se precisa novo template.

**SQL:**
```sql
SELECT gr.competencia, gr.tipo_guia, gr.status,
       gr.base_calculo, gr.contribuicao_servidor, gr.contribuicao_patronal,
       gr.taxa_administrativa, gr.valor_total,
       gr.regime_previdenciario,
       ip.nome AS instituto_nome, ip.cnpj AS instituto_cnpj
FROM guia_rpps gr
LEFT JOIN instituto_previdencia ip ON ip.id = gr.instituto_previdencia_id
WHERE gr.excluido = false AND gr.competencia = $P{competencia}
  AND gr.unidade_gestora_id = CAST($P{filtro1} AS BIGINT)
ORDER BY gr.tipo_guia, gr.competencia
```

---

## FASE 4 — Cobertura de Testes (Dias 7-10)

### Estado Atual

| Arquivo de Teste | Testes | Cobertura |
|------------------|--------|-----------|
| `Processamento13SalarioTest.java` | 34 | Classes de 13º salário |
| `CalculoPrevidenciaServiceTest.java` | 19 | CalculoPrevidenciaService |
| **TOTAL** | **53** | **< 1%** |

### Padrão Estabelecido (seguir existente)

```java
@ExtendWith(MockitoExtension.class)
class NomeDoServiceTest {
    @InjectMocks private NomeDoService service;
    @Mock private DependenciaRepository repository;
    
    @Nested
    @DisplayName("Nome do Grupo de Testes")
    class GrupoTestes {
        @BeforeEach
        void setUp() { /* fixtures */ }
        
        @Test
        @DisplayName("Deve fazer X quando Y")
        void deveFazerXQuandoY() { ... }
    }
}
```

### 4.1 Testes para `ProcessamentoFolhaService` ⏱️ 6h

**Prioridade MÁXIMA** — Service com 3.299 linhas, core do sistema.

Grupos de teste:
1. **Cópia de Competência** — `copiarVantagensParaProximaCompetencia()`, `copiarFolhasParaProximaCompetencia()`, `copiarDetalhesParcelados()`
2. **Processamento de Folha** — `processarFolha()`, `recalcularFolha()`, `zerarBasesCalculadas()`
3. **Virada de Competência** — `abrirProximaCompetencia()`, `fecharCompetencia()`
4. **Cópia Campos** — `copiarCamposCalculados()` (verificar todos os 50+ campos)

### 4.2 Testes para `FolhaPagamentoService` ⏱️ 3h

Grupos:
1. CRUD básico (salvar, buscar, listar por competência)
2. `findByUnidadeGestoraAndCompetencia()` 
3. Detalhes da folha (FolhaPagamentoDet)

### 4.3 Testes para `CnabService` (novo) ⏱️ 2h

Grupos:
1. Formatação de linhas (240 posições, padding)
2. Geração de header/trailer
3. Detalhes de pagamento (dados bancários)
4. Totalização

### 4.4 Testes para `VantagemDescontoDetService` ⏱️ 1h

Grupos:
1. `findAllByCompetencia()` (novo método)
2. Cópia entre competências (novo)
3. CRUD padrão

---

## Ordem de Execução Recomendada

```
DIA 1:  1.1 Remover TODO stale isFechada          [5 min]
        1.2 Implementar copiarVantagens             [4h]
        4.4 Testes VantagemDescontoDetService       [1h]

DIA 2:  1.3 Implementar CNAB (modelos + service)   [4h]

DIA 3:  1.3 Finalizar CNAB (controller + integração) [4h]
        4.3 Testes CnabService                      [2h]

DIA 4:  2.1-2.4 Corrigir relatórios schema incomp.  [6h]

DIA 5:  3.1 Servidores por Lotação                  [1.5h]
        3.2 Servidores por Cargo                    [1.5h]
        3.3 Resumo por Rubrica                      [2h]

DIA 6:  3.4 Líquido por Banco                      [2h]
        3.5 Contribuições Previdenciárias           [2h]

DIA 7:  3.6 IRRF                                   [2h]
        3.7 13º Salário (MemoriaCalculo13)          [2h]

DIA 8:  3.8 Previdência/Guia RPPS                  [2h]
        4.1 Testes ProcessamentoFolhaService (pt 1) [3h]

DIA 9:  4.1 Testes ProcessamentoFolhaService (pt 2) [3h]
        4.2 Testes FolhaPagamentoService            [3h]

DIA 10: Buffer / code review / ajustes finais       [full day]
```

---

## Critérios de Aceite Sprint 1

- [ ] Zero TODOs críticos (CNAB funcional, vantagens copiam, isFechada limpo)
- [ ] 6 relatórios Jasper funcionando (3 corrigidos + FolhaPG + DemonstrativoPG + GuiaRPPS)
- [ ] 8 relatórios novos gerando PDF
- [ ] Endpoint `/cnab` retorna arquivo .txt válido (não mais 501)
- [ ] Cobertura: ≥ 100 testes unitários (meta: dobrar para 106+)
- [ ] Build `mvn test` passa sem erros
- [ ] Nenhum TODO com label "CRITICAL" restante

---

## Dependências e Riscos

| Risco | Probabilidade | Mitigação |
|-------|---------------|-----------|
| Campos NULL em dados existentes quebrando relatórios | Alta | Usar COALESCE em todos os campos do SELECT |
| Layout CNAB varia por banco | Média | Implementar layout 240 genérico FEBRABAN primeiro |
| VantagemDescontoDet sem mes/exercicio preenchido | Média | Query de validação antes de copiar |
| Jasper compilation errors | Baixa | Compilar com JasperCompileManager no teste |
| ProcessamentoFolhaService muito acoplado | Alta | Testes com Mockito isolando deps |

---

## Referências de Código

| Recurso | Caminho |
|---------|---------|
| ProcessamentoFolhaService | `ws/erh/folha/processamento/service/ProcessamentoFolhaService.java` |
| ExportacaoController | `ws/erh/obrigacoes/exportacao/controller/ExportacaoController.java` |
| CompetenciaController | `ws/erh/core/competencia/CompetenciaController.java` |
| VantagemDescontoDet (entity) | `ws/erh/model/folha/rubrica/VantagemDescontoDet.java` |
| VantagemDescontoDetRepository | `ws/erh/folha/execucao/repository/VantagemDescontoDetRepository.java` |
| VantagemDescontoDetService | `ws/erh/folha/execucao/service/VantagemDescontoDetService.java` |
| RelatoriosController | `ws/erh/apoio/relatorio/controller/RelatoriosController.java` |
| FolhaPG.jrxml (modelo) | `reports/folha/FolhaPG.jrxml` |
| FolhaPGResumo.jrxml (corrigir) | `reports/folha/FolhaPGResumo.jrxml` |
| FichaFinanceira.jrxml (corrigir) | `reports/folha/FichaFinanceira.jrxml` |
| ComprovanteIR.jrxml (corrigir) | `reports/folha/ComprovanteIR.jrxml` |
| GuiaRPPS.jrxml | `reports/previdencia/GuiaRPPS.jrxml` |
| Processamento13SalarioTest | `src/test/java/ws/erh/folha/processamento/service/Processamento13SalarioTest.java` |
| CalculoPrevidenciaServiceTest | `src/test/java/ws/erh/folha/calculo/service/CalculoPrevidenciaServiceTest.java` |
