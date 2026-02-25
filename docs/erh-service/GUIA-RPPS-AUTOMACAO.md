# Análise e Proposta de Automação - Guia RPPS

## 📊 Análise do Fluxo Atual

### 1. Fluxo de Competência

```
┌─────────────────────────────────────────────────────────────────┐
│                    CICLO DE COMPETÊNCIA                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐    ┌──────────────┐    ┌──────────────┐         │
│   │ FUTURE   │ -> │    OPEN      │ -> │   CLOSED     │         │
│   │ (Futura) │    │  (Aberta)    │    │  (Fechada)   │         │
│   └──────────┘    └──────────────┘    └──────────────┘         │
│                         │                    │                  │
│                         v                    v                  │
│                  ┌─────────────┐      ┌─────────────┐          │
│                  │ Processamento│      │ Fechamento  │          │
│                  │   da Folha   │      │ da Competência│        │
│                  └─────────────┘      └─────────────┘          │
│                         │                    │                  │
│                         v                    │                  │
│                  ┌─────────────┐             │                  │
│                  │  FolhaPag.  │             │                  │
│                  │ (com RPPS)  │             │                  │
│                  └─────────────┘             │                  │
│                                              │                  │
│                                              v                  │
│                                       [Guia RPPS???]           │
│                                       (NÃO INTEGRADO)          │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Entidades Principais

| Entidade | Responsabilidade |
|----------|------------------|
| **Legislacao** | Define competência (YYYY-MM), alíquotas, status (aberta/fechada) |
| **FolhaPagamento** | Dados calculados por servidor (baseRppsServidor, aliqRppsServidor, etc.) |
| **GuiaRpps** | Documento de recolhimento previdenciário |
| **InstitutoPrevidencia** | Dados do instituto (banco, multa, juros, carência) |
| **CompetenciaService** | Valida status da competência |
| **ProcessamentoFolhaService** | Processa folha e fecha competência |
| **GuiaRppsService** | Gera guias manualmente |

### 3. Fluxo Atual de Geração de Guia

**Problema identificado:** A geração de guias é **totalmente manual**.

```
USUÁRIO
   │
   ├──> Acessa /e-RH/cadastro/previdencia/guia
   │
   ├──> Preenche manualmente:
   │    - Competência (YYYY-MM)
   │    - Instituto de Previdência
   │    - Tipo da Guia
   │    - Data de Vencimento
   │
   ├──> Envia POST /api/v1/guias-rpps
   │
   └──> GuiaRppsService.gerarGuia():
        - Busca folhas da competência
        - Calcula contribuições
        - Gera número da guia
        - Gera dados do boleto
```

### 4. Dados Obtidos Automaticamente vs. Manuais

| Campo | Fonte Atual | Deveria Ser |
|-------|-------------|-------------|
| Competência | Manual | Auto (competência aberta) |
| Instituto | Manual | Auto (se único) / Seleção |
| Tipo | Manual | Auto (NORMAL por padrão) |
| Data Vencimento | Manual/Calculado | Auto (dia 15 do mês seguinte) |
| Base Cálculo | Auto (FolhaPagamento) | ✅ OK |
| Contribuições | Auto (FolhaPagamento) | ✅ OK |
| Multa/Juros | Auto (InstitutoPrevidencia) | ✅ OK |

---

## 🎯 Proposta de Automação

### Fluxo Proposto

```
┌─────────────────────────────────────────────────────────────────┐
│                    FLUXO AUTOMATIZADO                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────────────────────────────────────────────────────┐ │
│   │             ProcessamentoFolhaService                     │ │
│   │                fecharCompetencia()                        │ │
│   └──────────────────────────────────────────────────────────┘ │
│                           │                                     │
│                           v                                     │
│   ┌──────────────────────────────────────────────────────────┐ │
│   │  1. Fecha legislação (fechado = true)                    │ │
│   │  2. Copia para próxima competência (opcional)            │ │
│   │  3. ✨ NOVO: Gera Guias RPPS automaticamente             │ │
│   └──────────────────────────────────────────────────────────┘ │
│                           │                                     │
│                           v                                     │
│   ┌──────────────────────────────────────────────────────────┐ │
│   │           GuiaRppsService.gerarGuiasCompetencia()        │ │
│   │                                                          │ │
│   │  - Busca institutos ativos da UG                         │ │
│   │  - Para cada instituto:                                  │ │
│   │    - Verifica se tem servidores vinculados               │ │
│   │    - Gera guia tipo NORMAL                               │ │
│   │    - Status: EMITIDA                                     │ │
│   └──────────────────────────────────────────────────────────┘ │
│                           │                                     │
│                           v                                     │
│   ┌──────────────────────────────────────────────────────────┐ │
│   │                   RESULTADO                              │ │
│   │                                                          │ │
│   │  - Guias RPPS prontas para pagamento                     │ │
│   │  - Notificação ao usuário (opcional)                     │ │
│   │  - PDFs disponíveis para download                        │ │
│   └──────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Cenários de Uso

#### Cenário 1: Fechamento com Geração Automática
```
1. Usuário clica "Fechar Competência" na folha
2. Sistema fecha competência
3. Sistema gera guias automaticamente para todos os institutos
4. Sistema exibe modal de confirmação:
   "Competência 2026-01 fechada. 2 guias RPPS geradas."
5. Usuário pode visualizar/baixar as guias imediatamente
```

#### Cenário 2: Geração Manual (Complementar/Atraso)
```
1. Usuário acessa página de Guias RPPS
2. Sistema já pré-seleciona competência fechada mais recente
3. Sistema já pré-seleciona instituto (se único)
4. Usuário seleciona tipo: COMPLEMENTAR ou ATRASO
5. Sistema gera a guia específica
```

#### Cenário 3: Dashboard de Guias
```
┌─────────────────────────────────────────────────────────────┐
│                  Guias RPPS - Competência 2026-01           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┬──────────────────────────────────────────┐│
│  │  PENDENTES  │  2 guias | R$ 45.320,00                  ││
│  │    ⚠️      │  [Ver todas] [Gerar Consolidado]         ││
│  └─────────────┴──────────────────────────────────────────┘│
│                                                             │
│  ┌─────────────┬──────────────────────────────────────────┐│
│  │   PAGAS     │  1 guia  | R$ 22.150,00                  ││
│  │    ✅      │  [Ver detalhes]                          ││
│  └─────────────┴──────────────────────────────────────────┘│
│                                                             │
│  ┌─────────────┬──────────────────────────────────────────┐│
│  │  VENCIDAS   │  0 guias                                 ││
│  │    ❌      │                                          ││
│  └─────────────┴──────────────────────────────────────────┘│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 Implementação Detalhada

### 1. Novo Método no GuiaRppsService

```java
/**
 * Gera guias RPPS automaticamente para todos os institutos
 * da unidade gestora para uma competência fechada.
 * 
 * @param competencia Competência no formato YYYY-MM
 * @return Lista de guias geradas
 */
@Transactional
public List<GuiaRppsResponse> gerarGuiasCompetencia(String competencia) {
    Long unidadeGestoraId = SecurityUtils.getUnidadeGestoraId();
    List<GuiaRppsResponse> guiasGeradas = new ArrayList<>();
    
    // Busca todos os institutos ativos da UG
    List<InstitutoPrevidencia> institutos = institutoRepository
        .findByUnidadeGestora(unidadeGestoraId);
    
    for (InstitutoPrevidencia instituto : institutos) {
        // Verifica se já existe guia NORMAL para esta competência/instituto
        Optional<GuiaRpps> existente = repository
            .findByCompetenciaTipoInstituto(
                unidadeGestoraId, 
                competencia, 
                TipoGuiaRpps.NORMAL, 
                instituto.getId()
            );
        
        if (existente.isEmpty()) {
            // Verifica se tem folhas RPPS para este instituto
            boolean temFolhasRpps = verificarFolhasRppsInstituto(
                unidadeGestoraId, competencia, instituto.getId()
            );
            
            if (temFolhasRpps) {
                GuiaRppsRequest request = new GuiaRppsRequest();
                request.setCompetencia(competencia);
                request.setInstitutoPrevidenciaId(instituto.getId());
                request.setTipoGuia(TipoGuiaRpps.NORMAL);
                
                GuiaRppsResponse guia = gerarGuia(request);
                guiasGeradas.add(guia);
            }
        }
    }
    
    log.info("Geração automática de guias - Competência: {} | Geradas: {}", 
             competencia, guiasGeradas.size());
    
    return guiasGeradas;
}
```

### 2. Integração no ProcessamentoFolhaService

```java
@Override
@Transactional
public void fecharCompetencia(Long unidadeGestoraId, String competencia,
                               Boolean copiarLegislacao, Boolean copiarVantagens, 
                               Boolean copiarFolhas, Boolean gerarGuiasRpps) {
    // ... código existente ...
    
    // Fechar a competência
    legislacao.setFechado(true);
    legislacao.setDataFechamento(LocalDateTime.now());
    legislacaoService.save(legislacao);
    
    // ... cópias existentes ...
    
    // ✨ NOVO: Geração automática de guias RPPS
    if (Boolean.TRUE.equals(gerarGuiasRpps)) {
        try {
            List<GuiaRppsResponse> guiasGeradas = guiaRppsService
                .gerarGuiasCompetencia(competenciaEfetiva);
            log.info("Guias RPPS geradas no fechamento: {}", guiasGeradas.size());
        } catch (Exception e) {
            log.error("Erro ao gerar guias RPPS no fechamento: {}", e.getMessage());
            // Não bloqueia o fechamento, apenas loga o erro
        }
    }
    
    log.info("Competência {} fechada com sucesso", competenciaEfetiva);
}
```

### 3. Novo Endpoint para Geração em Lote

```java
@PostMapping("/competencia/{competencia}/gerar")
@Operation(summary = "Gerar guias da competência", 
           description = "Gera automaticamente guias para todos os institutos da competência")
public ResponseEntity<List<GuiaRppsResponse>> gerarGuiasCompetencia(
        @PathVariable String competencia) {
    List<GuiaRppsResponse> guias = service.gerarGuiasCompetencia(competencia);
    return ResponseEntity.status(HttpStatus.CREATED).body(guias);
}
```

### 4. Endpoint de Resumo por Competência

```java
@GetMapping("/competencia/{competencia}/resumo")
@Operation(summary = "Resumo da competência", 
           description = "Retorna resumo consolidado das guias da competência")
public ResponseEntity<ResumoGuiasCompetenciaResponse> getResumoCompetencia(
        @PathVariable String competencia) {
    return ResponseEntity.ok(service.getResumoCompetencia(competencia));
}
```

```java
@Data
public class ResumoGuiasCompetenciaResponse {
    private String competencia;
    private int totalGuias;
    private int guiasPendentes;
    private int guiasPagas;
    private int guiasVencidas;
    private int guiasCanceladas;
    private BigDecimal valorTotalPendente;
    private BigDecimal valorTotalPago;
    private List<GuiaRppsResponse> guias;
}
```

---

## 🖥️ Melhorias no Frontend

### 1. Página de Guias com Competência Auto-Selecionada

```typescript
// guia.config.ts - Campo competência com seleção inteligente
{
  line: 1,
  colSpan: 'md:col-span-3',
  nome: 'Competência',
  chave: 'competencia',
  tipo: 'select',
  uri: '/competencias/fechadas', // Busca competências fechadas
  optionValor: ['competencia'],
  mensagem: 'Selecione...',
  obrigatorio: true,
  defaultValue: 'ultima', // Seleciona última fechada automaticamente
}
```

### 2. Botão de Geração em Lote

```typescript
// Adicionar botão na toolbar da página
botoes: [
  { 
    nome: 'Gerar Guias da Competência', 
    chave: 'gerarLote', 
    icone: 'FileStack' 
  }
]
```

### 3. Dashboard de Resumo

Nova seção na página inicial mostrando:
- Guias pendentes do mês
- Alertas de vencimento
- Ações rápidas

---

## 📅 Plano de Implementação

### Fase 1: Backend (Estimativa: 2-3 dias)
1. ✅ Implementar `GuiaRppsService.gerarGuiasCompetencia()`
2. ✅ Adicionar parâmetro `gerarGuiasRpps` no fechamento
3. ✅ Criar endpoint `/competencia/{comp}/gerar`
4. ✅ Criar endpoint `/competencia/{comp}/resumo`

### Fase 2: Integração (Estimativa: 1 dia)
1. ✅ Integrar no `ProcessamentoFolhaService.fecharCompetencia()`
2. ✅ Adicionar tratamento de erros
3. ✅ Testes de integração

### Fase 3: Frontend (Estimativa: 2-3 dias)
1. ⬜ Atualizar página de guias com competência auto-selecionada
2. ⬜ Adicionar botão de geração em lote
3. ⬜ Criar componente de resumo
4. ⬜ Modal de confirmação no fechamento

### Fase 4: Melhorias (Estimativa: 1-2 dias)
1. ⬜ Notificações de guias vencendo
2. ⬜ Job schedulado para atualizar status de vencidas
3. ⬜ Relatório consolidado de guias

---

## 🔧 Configurações Recomendadas

### No Instituto de Previdência

| Campo | Descrição | Uso |
|-------|-----------|-----|
| `percentualMulta` | % de multa por atraso | Cálculo automático |
| `percentualJurosMes` | % de juros ao mês | Cálculo automático |
| `diasCarenciaMulta` | Dias antes de aplicar multa | Grace period |
| `diaVencimento` | Dia fixo de vencimento | Default: 15 |

### Na Legislação

| Campo | Descrição | Uso |
|-------|-----------|-----|
| `aliqRppsServidor` | Alíquota do servidor | Cálculo na folha |
| `aliqRppsPatronal` | Alíquota patronal | Cálculo na guia |

---

## ✅ Checklist de Validação

- [ ] Geração automática no fechamento funciona
- [ ] Não duplica guias existentes
- [ ] Calcula corretamente contribuições
- [ ] Aplica multa/juros quando aplicável
- [ ] Gera código de barras válido
- [ ] PDF é gerado corretamente
- [ ] Frontend permite geração manual quando necessário
- [ ] Resumo mostra dados corretos

---

## 📞 Próximos Passos

1. **Aprovar proposta** com stakeholders
2. **Implementar Fase 1** (backend)
3. **Testar integração** com fechamento de competência
4. **Implementar Fase 3** (frontend)
5. **Deploy** em ambiente de homologação
6. **Validação** com usuários finais
