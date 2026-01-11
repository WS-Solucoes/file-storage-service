# 📘 DOCUMENTAÇÃO TÉCNICA DETALHADA - eRH Municipal

## PARTE 5: Tarefas de Stakeholders por Módulo e Casos de Uso Detalhados

**Data:** 08 de Janeiro de 2026  
**Versão:** 1.0

---

## 14. DIVISÃO DE STAKEHOLDERS POR MÓDULO

### 14.1 Mapa de Stakeholders

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MAPA DE STAKEHOLDERS - SISTEMA ERH                                   │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              NÍVEL ESTRATÉGICO                                               │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│   ┌─────────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────────┐ │
│   │      PREFEITO           │    │  SECRETÁRIO ADMIN.      │    │  CONTROLADOR INTERNO   │ │
│   ├─────────────────────────┤    ├─────────────────────────┤    ├─────────────────────────┤ │
│   │ • Aprova orçamento      │    │ • Define políticas RH   │    │ • Audita folha          │ │
│   │ • Visualiza dashboards  │    │ • Autoriza contratações │    │ • Verifica conformidade │ │
│   │ • Assina decretos       │    │ • Aprova progressões    │    │ • Emite pareceres       │ │
│   │                         │    │ • Homologa nomeações    │    │ • Analisa prestações    │ │
│   │ ROLE: USUARIO           │    │ ROLE: GESTOR            │    │ ROLE: GESTOR            │ │
│   └─────────────────────────┘    └─────────────────────────┘    └─────────────────────────┘ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              NÍVEL TÁTICO                                                    │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│   ┌─────────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────────┐ │
│   │  DIRETOR DE RH          │    │ COORDENADOR DE FOLHA    │    │  CONTADOR              │ │
│   ├─────────────────────────┤    ├─────────────────────────┤    ├─────────────────────────┤ │
│   │ • Gerencia equipe RH    │    │ • Processa folha        │    │ • Empenha despesas      │ │
│   │ • Aprova movimentações  │    │ • Fecha competências    │    │ • Gera relatórios contábeis
│   │ • Define procedimentos  │    │ • Valida cálculos       │    │ • Confere encargos      │ │
│   │ • Responde auditorias   │    │ • Aprova exceções       │    │ • Registra provisões    │ │
│   │ • Planeja quadro        │    │ • Gerencia arquivos     │    │ • Integra com SIAFEM    │ │
│   │                         │    │                         │    │                         │ │
│   │ ROLE: ADMIN             │    │ ROLE: GESTOR            │    │ ROLE: GESTOR            │ │
│   └─────────────────────────┘    └─────────────────────────┘    └─────────────────────────┘ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              NÍVEL OPERACIONAL                                               │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│   ┌─────────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────────┐ │
│   │  ANALISTA DE RH         │    │  ANALISTA DE FOLHA      │    │  ASSISTENTE ADM.       │ │
│   ├─────────────────────────┤    ├─────────────────────────┤    ├─────────────────────────┤ │
│   │ • Cadastra servidores   │    │ • Lança rubricas        │    │ • Atende servidores     │ │
│   │ • Atualiza vínculos     │    │ • Importa dados         │    │ • Emite declarações     │ │
│   │ • Cadastra dependentes  │    │ • Confere lançamentos   │    │ • Protocola documentos  │ │
│   │ • Processa afastamentos │    │ • Ajusta divergências   │    │ • Esclarece dúvidas     │ │
│   │ • Gerencia férias       │    │ • Gera contracheques    │    │ • Encaminha demandas    │ │
│   │                         │    │                         │    │                         │ │
│   │ ROLE: ANALISTA          │    │ ROLE: ANALISTA          │    │ ROLE: USUARIO           │ │
│   └─────────────────────────┘    └─────────────────────────┘    └─────────────────────────┘ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              STAKEHOLDERS EXTERNOS                                           │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│   ┌─────────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────────┐ │
│   │  SERVIDOR (Portal)      │    │  BANCO CONSIGNATÁRIO    │    │  ÓRGÃOS FISCALIZADORES │ │
│   ├─────────────────────────┤    ├─────────────────────────┤    ├─────────────────────────┤ │
│   │ • Consulta contracheque │    │ • Recebe arquivo remessa│    │ • TCE - Tribunal Contas │ │
│   │ • Solicita férias       │    │ • Envia arquivo retorno │    │ • INSS - Previdência    │ │
│   │ • Atualiza cadastro     │    │ • Consulta margem       │    │ • Receita Federal       │ │
│   │ • Consulta margem       │    │ • Cadastra contratos    │    │ • MTE - Trabalho        │ │
│   │ • Imprime documentos    │    │                         │    │ • Câmara Municipal      │ │
│   │                         │    │                         │    │                         │ │
│   │ ROLE: USUARIO (próprio) │    │ ROLE: EXTERNO (API)     │    │ ROLE: EXTERNO (relat.)  │ │
│   └─────────────────────────┘    └─────────────────────────┘    └─────────────────────────┘ │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 14.2 Módulos e Responsáveis

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         MATRIZ MÓDULO × STAKEHOLDER                                          │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┬───────────┬───────────┬───────────┬───────────┬───────────┬─────────┐
│       MÓDULO         │  Dir.RH   │ Coord.Fol │ Anal.RH   │ Anal.Fol. │ Contador  │ Servidor│
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Cadastro Funcionário │  Aprova   │     -     │ Executa   │     -     │     -     │ Consulta│
│ Cadastro Vínculo     │  Aprova   │     -     │ Executa   │     -     │     -     │ Consulta│
│ Cadastro Dependente  │     -     │     -     │ Executa   │     -     │     -     │ Consulta│
│ Cadastro Cargo       │  Executa  │     -     │ Consulta  │     -     │     -     │    -    │
│ Cadastro Lotação     │  Executa  │     -     │ Consulta  │     -     │     -     │    -    │
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Lançamentos Folha    │     -     │  Aprova   │     -     │ Executa   │     -     │    -    │
│ Processamento Folha  │  Consulta │  Executa  │     -     │ Consulta  │ Consulta  │    -    │
│ Fechamento Folha     │  Aprova   │  Executa  │     -     │     -     │ Consulta  │    -    │
│ Relatórios Folha     │  Consulta │  Executa  │     -     │ Consulta  │ Executa   │    -    │
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Férias - Programação │     -     │     -     │ Executa   │     -     │     -     │ Solicita│
│ Férias - Aprovação   │  Aprova   │     -     │ Executa   │     -     │     -     │    -    │
│ Férias - Processa    │     -     │  Executa  │     -     │     -     │     -     │    -    │
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ 13º - Configuração   │  Aprova   │  Executa  │     -     │     -     │     -     │    -    │
│ 13º - Processamento  │     -     │  Executa  │     -     │ Consulta  │ Consulta  │    -    │
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Consignado - Convênio│  Aprova   │     -     │ Executa   │     -     │     -     │    -    │
│ Consignado - Contrato│     -     │     -     │ Executa   │     -     │     -     │ Consulta│
│ Consignado - Margem  │     -     │     -     │ Consulta  │     -     │     -     │ Consulta│
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Arquivos Bancários   │     -     │  Executa  │     -     │     -     │ Consulta  │    -    │
│ Arquivos Legais      │  Aprova   │  Executa  │     -     │     -     │ Executa   │    -    │
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Legislação           │  Aprova   │  Executa  │ Consulta  │ Consulta  │ Consulta  │    -    │
│ Rubricas             │  Aprova   │  Executa  │ Consulta  │ Consulta  │     -     │    -    │
├──────────────────────┼───────────┼───────────┼───────────┼───────────┼───────────┼─────────┤
│ Portal do Servidor   │     -     │     -     │     -     │     -     │     -     │ Executa │
│ Contracheque         │     -     │     -     │     -     │     -     │     -     │ Consulta│
└──────────────────────┴───────────┴───────────┴───────────┴───────────┴───────────┴─────────┘

Legenda:
• Executa  = Realiza a operação
• Aprova   = Autoriza/Homologa a operação
• Consulta = Visualiza sem poder alterar
• Solicita = Inicia o processo (workflow)
• -        = Sem acesso ao módulo
```

---

## 15. TAREFAS DETALHADAS POR STAKEHOLDER

### 15.1 Coordenador de Folha - Ciclo Mensal Completo

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                    TAREFAS DO COORDENADOR DE FOLHA - CICLO MENSAL                            │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════════════════════════
SEMANA 1 (Dias 1-7): PREPARAÇÃO E ABERTURA
═══════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 1-2: ABERTURA DA COMPETÊNCIA                                                           │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 1: Abrir nova competência                                                           │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Competências → Nova Competência                                           │
│                                                                                            │
│ Ações:                                                                                     │
│ 1. Informar mês/ano (ex: 2026-02)                                                         │
│ 2. Verificar se legislação está configurada para o período                                │
│ 3. Confirmar abertura                                                                      │
│                                                                                            │
│ Sistema:                                                                                   │
│ • Cria registro em Competencia com status ABERTA                                          │
│ • Vincula à Legislacao vigente                                                            │
│ • Habilita lançamentos para o período                                                      │
│                                                                                            │
│ Verificações:                                                                              │
│ ✓ Competência anterior está fechada?                                                       │
│ ✓ Legislação tem tabelas atualizadas (INSS, IRRF)?                                         │
│ ✓ Salário mínimo está correto?                                                             │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 3-5: IMPORTAÇÕES E LANÇAMENTOS INICIAIS                                                │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 2: Importar dados externos                                                          │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Importações → Selecionar tipo                                            │
│                                                                                            │
│ Importações típicas:                                                                       │
│ a) Arquivo de ponto eletrônico                                                            │
│    • Horas extras, faltas, atrasos                                                        │
│    • Formato: CSV/TXT do sistema de ponto                                                 │
│                                                                                            │
│ b) Arquivo de consignados (bancos)                                                        │
│    • Novos contratos                                                                       │
│    • Quitações/Cancelamentos                                                              │
│    • Formato: CNAB específico de cada banco                                               │
│                                                                                            │
│ c) Arquivo de pensões alimentícias                                                        │
│    • Novos descontos judiciais                                                            │
│    • Alterações de valores                                                                 │
│                                                                                            │
│ Verificações pós-importação:                                                               │
│ ✓ Quantidade de registros importados                                                       │
│ ✓ Registros rejeitados (com motivo)                                                        │
│ ✓ Valores totais batem com arquivo original                                                │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════════════════════
SEMANA 2 (Dias 8-14): LANÇAMENTOS E AJUSTES
═══════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 8-10: SUPERVISÃO DE LANÇAMENTOS                                                        │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 3: Acompanhar lançamentos dos analistas                                             │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Painel de Lançamentos                                                     │
│                                                                                            │
│ Monitorar:                                                                                 │
│ • Servidores sem lançamentos (pendentes)                                                  │
│ • Lançamentos com valores atípicos                                                        │
│ • Servidores com muitas horas extras                                                       │
│ • Lançamentos de rubricas sensíveis                                                        │
│                                                                                            │
│ Alertas automáticos:                                                                       │
│ ⚠️ Hora extra > 44h/mês → Requer justificativa                                             │
│ ⚠️ Adicional noturno em servidor diurno → Conferir escala                                  │
│ ⚠️ Novo desconto > 30% do salário → Verificar margem                                       │
│                                                                                            │
│                                                                                            │
│ TAREFA 4: Resolver pendências                                                              │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ • Servidores sem lotação definida                                                         │
│ • Servidores com vínculo incompleto                                                        │
│ • Rubricas sem configuração de incidência                                                  │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 11-14: AJUSTES ESPECIAIS                                                               │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 5: Processar eventos especiais                                                      │
│ ─────────────────────────────────────────────────────────────────────────────              │
│                                                                                            │
│ a) Retroativos:                                                                           │
│    • Reajustes salariais com efeito retroativo                                            │
│    • Diferenças de meses anteriores                                                        │
│    • Progressões/Promoções com data retroativa                                             │
│                                                                                            │
│ b) Rescisões:                                                                             │
│    • Exonerações do mês                                                                    │
│    • Cálculo de verbas rescisórias                                                        │
│    • Proporcional de férias e 13º                                                          │
│                                                                                            │
│ c) Admissões:                                                                             │
│    • Novos servidores do mês                                                               │
│    • Verificar cadastro completo                                                           │
│    • Salário proporcional se admissão após dia 1                                          │
│                                                                                            │
│ d) Afastamentos:                                                                          │
│    • Licenças médicas                                                                      │
│    • Férias                                                                                │
│    • Outros afastamentos                                                                   │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════════════════════
SEMANA 3 (Dias 15-21): PROCESSAMENTO E CONFERÊNCIA
═══════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 15-16: PROCESSAMENTO DA FOLHA                                                          │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 6: Processar folha de pagamento                                                     │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Processamento → Processar Competência                                    │
│                                                                                            │
│ Pré-requisitos:                                                                            │
│ ✓ Todos os lançamentos manuais realizados                                                  │
│ ✓ Legislação configurada                                                                   │
│ ✓ Vínculos atualizados                                                                     │
│                                                                                            │
│ Ações do sistema:                                                                          │
│ 1. Limpa itens automáticos anteriores                                                      │
│ 2. Aplica rubricas do vínculo                                                              │
│ 3. Gera itens automáticos (A1-A9)                                                          │
│ 4. Calcula bases de incidência                                                             │
│ 5. Calcula INSS/RPPS                                                                       │
│ 6. Calcula IRRF                                                                            │
│ 7. Calcula Salário Família                                                                 │
│ 8. Totaliza folha                                                                          │
│                                                                                            │
│ Acompanhamento:                                                                            │
│ • Barra de progresso: "Processando servidor 234/1500..."                                  │
│ • Log de erros em tempo real                                                               │
│ • Resumo final: processados/erros/avisos                                                   │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 17-19: CONFERÊNCIA                                                                     │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 7: Conferir resultados do processamento                                             │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Relatórios → Conferência                                                 │
│                                                                                            │
│ Relatórios de conferência:                                                                 │
│                                                                                            │
│ a) Comparativo com mês anterior:                                                          │
│    ┌─────────────────┬────────────┬────────────┬───────────┐                              │
│    │ Item            │ Mês Anter. │ Mês Atual  │ Diferença │                              │
│    ├─────────────────┼────────────┼────────────┼───────────┤                              │
│    │ Total Proventos │ 850.000,00 │ 875.000,00 │ +2,94%    │                              │
│    │ Total Descontos │ 180.000,00 │ 185.000,00 │ +2,78%    │                              │
│    │ Líquido         │ 670.000,00 │ 690.000,00 │ +2,98%    │                              │
│    │ Qtd Servidores  │      1.498 │      1.502 │    +4     │                              │
│    └─────────────────┴────────────┴────────────┴───────────┘                              │
│                                                                                            │
│ b) Servidores com maior variação:                                                         │
│    • Listar top 20 com maior aumento                                                      │
│    • Listar top 20 com maior redução                                                      │
│    • Verificar se variações são justificadas                                               │
│                                                                                            │
│ c) Conferência de encargos:                                                               │
│    • Total INSS servidor                                                                   │
│    • Total INSS patronal                                                                   │
│    • Total RPPS servidor                                                                   │
│    • Total RPPS patronal                                                                   │
│    • Total IRRF                                                                            │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 20-21: AJUSTES E REPROCESSAMENTO                                                       │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 8: Corrigir divergências encontradas                                                │
│ ─────────────────────────────────────────────────────────────────────────────              │
│                                                                                            │
│ Tipos de correção:                                                                         │
│                                                                                            │
│ a) Individual:                                                                            │
│    Caminho: Folha → Servidor → Matrícula → Editar                                         │
│    • Ajustar lançamento específico                                                        │
│    • Reprocessar folha individual                                                          │
│                                                                                            │
│ b) Em lote:                                                                               │
│    Caminho: Folha → Lançamentos em Lote                                                   │
│    • Aplicar rubrica para grupo de servidores                                             │
│    • Remover rubrica aplicada incorretamente                                              │
│                                                                                            │
│ c) Reprocessamento geral:                                                                 │
│    Caminho: Folha → Processamento → Reprocessar                                           │
│    • Reprocessa toda a folha                                                               │
│    • Mantém lançamentos manuais                                                           │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════════════════════════════════
SEMANA 4 (Dias 22-30): FECHAMENTO E GERAÇÃO DE ARQUIVOS
═══════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 22-23: APROVAÇÃO E FECHAMENTO                                                          │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 9: Aprovar folha para fechamento                                                    │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Competência → Aprovar                                                    │
│                                                                                            │
│ Checklist de aprovação:                                                                    │
│ ✓ Todos os servidores foram processados                                                    │
│ ✓ Não há erros pendentes                                                                   │
│ ✓ Relatório de conferência analisado                                                       │
│ ✓ Divergências foram justificadas                                                          │
│ ✓ Diretor de RH autorizou (assinatura digital ou workflow)                                 │
│                                                                                            │
│                                                                                            │
│ TAREFA 10: Fechar competência                                                              │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Competência → Fechar                                                     │
│                                                                                            │
│ Sistema:                                                                                   │
│ • Altera status para FECHADA                                                              │
│ • Bloqueia qualquer alteração                                                              │
│ • Registra data/hora e usuário do fechamento                                              │
│ • Gera hash de integridade                                                                 │
│                                                                                            │
│ ⚠️ ATENÇÃO: Após fechamento, alterações só com autorização especial!                       │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 24-26: GERAÇÃO DE ARQUIVOS                                                             │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 11: Gerar arquivos bancários                                                        │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Arquivos → Bancário → CNAB 240                                           │
│                                                                                            │
│ Arquivos gerados:                                                                          │
│ • Pagamento de salários (por banco)                                                        │
│ • Consignados (remessa por convênio)                                                       │
│ • Pensões alimentícias                                                                     │
│                                                                                            │
│ Verificações:                                                                              │
│ ✓ Total do arquivo = Total da folha                                                        │
│ ✓ Quantidade de registros correta                                                          │
│ ✓ Contas bancárias válidas                                                                 │
│                                                                                            │
│                                                                                            │
│ TAREFA 12: Gerar arquivos legais                                                           │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Arquivos → Legais                                                        │
│                                                                                            │
│ Arquivos mensais:                                                                          │
│ • SEFIP (INSS/FGTS)                                                                        │
│ • eSocial eventos S-1200, S-1210                                                           │
│                                                                                            │
│ Arquivos anuais (quando aplicável):                                                        │
│ • DIRF (até fevereiro)                                                                     │
│ • RAIS (março)                                                                             │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ DIA 27-30: DISPONIBILIZAÇÃO E RELATÓRIOS                                                   │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ TAREFA 13: Gerar e disponibilizar contracheques                                            │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Contracheques → Gerar Lote                                               │
│                                                                                            │
│ Ações:                                                                                     │
│ • Gerar PDFs individuais                                                                   │
│ • Disponibilizar no Portal do Servidor                                                     │
│ • Enviar notificação por email (opcional)                                                  │
│                                                                                            │
│                                                                                            │
│ TAREFA 14: Gerar relatórios gerenciais                                                     │
│ ─────────────────────────────────────────────────────────────────────────────              │
│ Caminho: Folha → Relatórios → Gerenciais                                                  │
│                                                                                            │
│ Relatórios:                                                                                │
│ • Resumo da folha (para Secretário)                                                        │
│ • Custo por secretaria/lotação (para Contabilidade)                                        │
│ • Provisão de férias (para Contabilidade)                                                  │
│ • Provisão de 13º (para Contabilidade)                                                     │
│ • Despesa com pessoal para LRF (para TCE)                                                  │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 15.2 Analista de RH - Tarefas de Cadastro

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                    TAREFAS DO ANALISTA DE RH - CADASTROS                                     │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

TAREFA 1: CADASTRAR NOVO SERVIDOR
════════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ PASSO A PASSO - ADMISSÃO DE SERVIDOR                                                       │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ ETAPA 1: Cadastrar Dados Pessoais                                                          │
│ ─────────────────────────────────                                                          │
│ Caminho: Cadastros → Funcionários → Novo                                                  │
│                                                                                            │
│ Campos obrigatórios:                                                                       │
│ ├─ CPF (validar na Receita)                                                               │
│ ├─ Nome completo                                                                          │
│ ├─ Data de nascimento                                                                      │
│ ├─ Sexo                                                                                    │
│ ├─ Estado civil                                                                            │
│ └─ Nacionalidade                                                                           │
│                                                                                            │
│ Campos complementares:                                                                     │
│ ├─ RG (número, órgão, UF, data expedição)                                                 │
│ ├─ Título de eleitor                                                                       │
│ ├─ PIS/PASEP                                                                              │
│ ├─ Endereço completo                                                                       │
│ ├─ Telefones                                                                               │
│ └─ Email                                                                                   │
│                                                                                            │
│ Dados bancários:                                                                           │
│ ├─ Banco                                                                                   │
│ ├─ Agência                                                                                 │
│ ├─ Conta corrente                                                                          │
│ └─ Tipo de conta                                                                           │
│                                                                                            │
│ [Salvar] → Sistema gera ID do Funcionário                                                 │
│                                                                                            │
│                                                                                            │
│ ETAPA 2: Cadastrar Dependentes                                                             │
│ ─────────────────────────────────                                                          │
│ Caminho: Funcionário → [servidor] → Dependentes → Novo                                    │
│                                                                                            │
│ Para cada dependente:                                                                      │
│ ├─ Nome completo                                                                          │
│ ├─ CPF (obrigatório para IRRF)                                                            │
│ ├─ Data de nascimento                                                                      │
│ ├─ Parentesco (filho, cônjuge, pai/mãe, etc.)                                             │
│ ├─ [✓] Deduz IRRF (filhos até 21/24 anos, cônjuge)                                        │
│ └─ [✓] Salário Família (filhos até 14 anos)                                               │
│                                                                                            │
│ Regras de validação:                                                                       │
│ ⚠️ Filho > 21 anos só deduz se inválido ou universitário até 24                            │
│ ⚠️ Cônjuge só deduz se sem renda própria                                                   │
│ ⚠️ Salário Família só para filhos até 14 anos                                              │
│                                                                                            │
│                                                                                            │
│ ETAPA 3: Criar Vínculo Funcional                                                           │
│ ─────────────────────────────────                                                          │
│ Caminho: Funcionário → [servidor] → Vínculos → Novo                                       │
│                                                                                            │
│ Dados do vínculo:                                                                          │
│ ├─ Matrícula (gerada automaticamente ou informada)                                        │
│ ├─ Data de admissão                                                                        │
│ ├─ Tipo de vínculo:                                                                        │
│ │   ├─ EFETIVO (estatutário)                                                              │
│ │   ├─ COMISSIONADO (cargo em comissão)                                                   │
│ │   └─ TEMPORARIO (contrato por prazo)                                                    │
│ │                                                                                          │
│ ├─ Regime Previdenciário:                                                                  │
│ │   ├─ RPPS (Regime Próprio - estatutários)                                               │
│ │   └─ RGPS (INSS - temporários, comissionados)                                           │
│ │                                                                                          │
│ ├─ Cargo (buscar da tabela de cargos)                                                     │
│ ├─ Lotação (secretaria/departamento)                                                       │
│ ├─ Carga horária semanal                                                                   │
│ └─ Situação: ATIVO                                                                         │
│                                                                                            │
│ Dados de remuneração:                                                                      │
│ ├─ Salário base (pode vir do cargo)                                                       │
│ ├─ Representação (se cargo em comissão)                                                   │
│ └─ Percentual de quinquênio (0% para novos)                                               │
│                                                                                            │
│ [Salvar] → Servidor está apto para folha de pagamento                                     │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


TAREFA 2: PROGRAMAR FÉRIAS
════════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ PASSO A PASSO - PROGRAMAÇÃO DE FÉRIAS                                                      │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ ETAPA 1: Verificar direito a férias                                                        │
│ ─────────────────────────────────                                                          │
│ Caminho: Férias → Períodos Aquisitivos → Consultar                                        │
│                                                                                            │
│ Sistema mostra:                                                                            │
│ ┌─────────────────────────────────────────────────────────────────────────────┐           │
│ │ Servidor: João da Silva (Mat. 12345)                                        │           │
│ │                                                                             │           │
│ │ Período Aquisitivo     │ Dias Direito │ Dias Gozados │ Saldo │ Status      │           │
│ │ ────────────────────────────────────────────────────────────────────────── │           │
│ │ 15/03/2023 - 14/03/2024│     30       │      0       │   30  │ DISPONÍVEL  │           │
│ │ 15/03/2024 - 14/03/2025│     30       │     15       │   15  │ PARCIAL     │           │
│ │ 15/03/2025 - 14/03/2026│     30       │      0       │   30  │ EM AQUISIÇÃO│           │
│ └─────────────────────────────────────────────────────────────────────────────┘           │
│                                                                                            │
│                                                                                            │
│ ETAPA 2: Criar programação                                                                 │
│ ─────────────────────────────────                                                          │
│ Caminho: Férias → Programações → Nova                                                     │
│                                                                                            │
│ Informar:                                                                                  │
│ ├─ Período aquisitivo (selecionar da lista)                                               │
│ ├─ Data início das férias                                                                  │
│ ├─ Quantidade de dias (max: saldo disponível)                                             │
│ ├─ Solicitar abono pecuniário? [✓] Sim                                                    │
│ │   └─ Dias para abono: 10 (máx 1/3 = 10 dias)                                            │
│ └─ Observações                                                                             │
│                                                                                            │
│ Validações automáticas:                                                                    │
│ ✓ Dias solicitados ≤ saldo disponível                                                      │
│ ✓ Data dentro do período concessivo                                                        │
│ ✓ Não conflita com outras férias programadas                                               │
│ ✓ Mínimo 10 dias se fracionamento                                                          │
│                                                                                            │
│ [Salvar] → Status: PROGRAMADA (aguarda aprovação)                                         │
│                                                                                            │
│                                                                                            │
│ ETAPA 3: Aprovar programação                                                               │
│ ─────────────────────────────────                                                          │
│ Caminho: Férias → Aprovações → Pendentes                                                  │
│ (Realizado pelo GESTOR ou ADMIN)                                                          │
│                                                                                            │
│ [Aprovar] → Status: CONFIRMADA                                                            │
│ [Rejeitar] → Status: REJEITADA + motivo                                                   │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘


TAREFA 3: CADASTRAR CONSIGNADO
════════════════════════════════════════════════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│ PASSO A PASSO - CADASTRO DE CONSIGNADO                                                     │
├────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                            │
│ ETAPA 1: Verificar margem disponível                                                       │
│ ─────────────────────────────────                                                          │
│ Caminho: Consignado → Margem → Consultar                                                  │
│                                                                                            │
│ Informar matrícula → Sistema calcula:                                                      │
│ ┌─────────────────────────────────────────────────────────────────────────────┐           │
│ │ MARGEM CONSIGNÁVEL                                                          │           │
│ │ ─────────────────────────────────────────────────                           │           │
│ │ Remuneração Bruta:     R$ 5.150,00                                          │           │
│ │ (-) Descontos obrig.:  R$ 1.382,64                                          │           │
│ │ (=) Base margem:       R$ 3.767,36                                          │           │
│ │                                                                             │           │
│ │ Margem Total (35%):    R$ 1.318,58                                          │           │
│ │ Margem Utilizada:      R$   750,00                                          │           │
│ │ MARGEM DISPONÍVEL:     R$   568,58                                          │           │
│ │                                                                             │           │
│ │ ████████████░░░░░░░░ 56,9%                                                  │           │
│ └─────────────────────────────────────────────────────────────────────────────┘           │
│                                                                                            │
│                                                                                            │
│ ETAPA 2: Cadastrar contrato                                                                │
│ ─────────────────────────────────                                                          │
│ Caminho: Consignado → Contratos → Novo                                                    │
│                                                                                            │
│ Informar:                                                                                  │
│ ├─ Servidor (matrícula)                                                                   │
│ ├─ Consignatária (banco conveniado)                                                       │
│ ├─ Número do contrato (do banco)                                                          │
│ ├─ Valor contratado                                                                        │
│ ├─ Taxa de juros (% a.m.)                                                                 │
│ ├─ Quantidade de parcelas                                                                  │
│ ├─ Valor da parcela                                                                        │
│ ├─ Data primeiro desconto                                                                  │
│ └─ Anexar documento (contrato escaneado)                                                  │
│                                                                                            │
│ Validações:                                                                                │
│ ✓ Parcela ≤ margem disponível                                                              │
│ ✓ Taxa ≤ taxa máxima do convênio                                                           │
│ ✓ Prazo ≤ prazo máximo do convênio                                                         │
│ ✓ Consignatária está ativa                                                                 │
│                                                                                            │
│ [Salvar] → Sistema cria rubrica de desconto no vínculo                                    │
│                                                                                            │
└────────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 16. ÍNDICE GERAL DA DOCUMENTAÇÃO

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         ÍNDICE COMPLETO - DOCUMENTAÇÃO TÉCNICA MICRO                         │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

PARTE 1: Arquitetura de Permissões e Stakeholders
├── 1. Sistema de Permissões MBAC
│   ├── 1.1 Arquitetura de Permissões
│   ├── 1.2 Matriz de Permissões por Role
│   └── 1.3 Implementação no Controller
├── 2. Mapeamento de Stakeholders
│   ├── 2.1 Níveis Hierárquicos
│   └── 2.2 Responsabilidades por Área
├── 3. TenantContext - Multi-Tenancy
│   ├── 3.1 Fluxo de Autenticação
│   └── 3.2 Isolamento de Dados
└── 4. Tarefas do Coordenador de Folha
    └── 4.1 Ciclo Mensal de 4 Semanas

PARTE 2: Processamento da Folha em Nível Micro
├── 5. Processamento da Folha
│   ├── 5.1 Diagrama de Sequência Completo
│   ├── 5.2 Estrutura de Dados Durante Processamento
│   ├── 5.3 Cálculo de Bases de Incidência
│   └── 5.4 Tipos de Cálculo Automático (A1-A9)
├── 6. Cálculo de Previdência
│   ├── 6.1 INSS (RGPS) - Cálculo Progressivo
│   ├── 6.2 RPPS - Alíquota Única vs Progressiva
│   └── 6.3 Código do Cálculo
└── 7. Cálculo do IRRF
    ├── 7.1 Fluxo Completo
    └── 7.2 Código do Cálculo

PARTE 3: Funcionalidades Faltantes - Comportamento Detalhado
├── 8. Módulo Consignado
│   ├── 8.1 Visão Geral
│   ├── 8.2 Modelo de Dados
│   ├── 8.3 Regra de Margem Consignável
│   ├── 8.4 Fluxo de Processamento
│   └── 8.5 Telas do Módulo
├── 9. Módulo Férias
│   ├── 9.1 Conceitos
│   ├── 9.2 Modelo de Dados
│   ├── 9.3 Fluxo de Processamento
│   └── 9.4 Cálculo de Férias - Exemplo
└── 10. Módulo 13º Salário
    ├── 10.1 Conceitos
    ├── 10.2 Modelo de Dados
    └── 10.3 Fluxo de Cálculo

PARTE 4: Relacionamento entre Classes
├── 11. Diagrama de Classes Completo
│   ├── 11.1 Núcleo do Sistema
│   ├── 11.2 Sistema de Rubricas
│   └── 11.3 Autenticação e Permissões
├── 12. Fluxo de Dados
│   ├── 12.1 Da Admissão ao Contracheque
│   └── 12.2 Sequência de Processamento Individual
└── 13. Mapa de Serviços
    └── 13.1 Arquitetura de Serviços

PARTE 5: Tarefas de Stakeholders
├── 14. Divisão por Módulo
│   ├── 14.1 Mapa de Stakeholders
│   └── 14.2 Matriz Módulo × Stakeholder
├── 15. Tarefas Detalhadas
│   ├── 15.1 Coordenador de Folha - Ciclo Mensal
│   └── 15.2 Analista de RH - Cadastros
└── 16. Índice Geral

══════════════════════════════════════════════════════════════════════════════════════════════

DOCUMENTOS RELACIONADOS:
─────────────────────────────────────────────────────────────────────────────────────────────
• FUNCIONALIDADES-FALTANTES-RH-MUNICIPAL.md - Lista das 28 lacunas identificadas
• PLANO-IMPLEMENTACAO-PARTE1 a PARTE5.md - Plano de implementação completo
• PLANO-OTIMIZACAO-ERH.md - Otimizações propostas
• avaliacao_estrutural.md - Análise da estrutura do sistema

```

---

**FIM DA DOCUMENTAÇÃO TÉCNICA DETALHADA - NÍVEL MICRO**

