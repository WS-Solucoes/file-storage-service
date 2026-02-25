# eFrotas — Índice de Documentação

> **Última atualização:** 23/02/2026

---

## Documentos Disponíveis

| # | Documento | Descrição | Audiência |
|---|-----------|-----------|-----------|
| 1 | [01-DOCUMENTACAO-SISTEMA-ATUAL.md](01-DOCUMENTACAO-SISTEMA-ATUAL.md) | Documentação completa do sistema atual: modelos, endpoints, frontend, fluxos de negócio, segurança | Desenvolvedores, Arquitetos |
| 2 | [02-PLANO-APRIMORAMENTO-AUTOMACAO.md](02-PLANO-APRIMORAMENTO-AUTOMACAO.md) | Plano detalhado de aprimoramento com 12 módulos novos, automações, correções e roadmap de implementação | Desenvolvedores, Product Owners |
| 3 | [03-ANALISE-MERCADO-PRODUTO.md](03-ANALISE-MERCADO-PRODUTO.md) | Análise competitiva, personas, planos comerciais, relatórios para TC, arquitetura completa e estratégia go-to-market | Gestores, Comercial, Arquitetos |

---

## Resumo Executivo

O **eFrotas** é um sistema de gestão de frotas municipais com:

- **Backend:** Java 21 + Spring Boot 3.2.5 + PostgreSQL — 26 entidades, ~117 endpoints REST, 14 relatórios PDF
- **Frontend:** Next.js + React + TypeScript — 25+ páginas funcionais
- **Diferenciais:** Multi-tenant, fluxo de aprovação, transporte escolar, soft delete, auditoria

### Aprimoramentos Propostos (12 módulos)

1. Automação de Controle de Combustível (consumo médio, saldo, anomalias)
2. Manutenção Preventiva Automática (planos, agendas, alertas)
3. GPS e Rastreamento em Tempo Real
4. Gestão de CNH e Documentação
5. Controle de Pneus e Patrimônio
6. Dashboard Inteligente com KPIs
7. Relatórios para Tribunal de Contas (12 relatórios + exportação XML)
8. Notificações e Alertas Automáticos
9. App Mobile para Motoristas
10. Integrações Externas (ANP, DETRAN, TC)
11. Auditoria e Compliance (LGPD)
12. Gestão de Seguros e Sinistros

**Estimativa:** 30-42 semanas | **Meta:** Sistema pronto para mercado atendendo 150+ municípios em 24 meses
