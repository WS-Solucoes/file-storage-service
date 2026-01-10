# ÍNDICE DA DOCUMENTAÇÃO DO SISTEMA eRH
## Guia Completo de Navegação

---

## 📁 ESTRUTURA DA DOCUMENTAÇÃO

### 1️⃣ DOCUMENTAÇÃO TÉCNICA DE MÓDULOS (PARTE 1-27)

| Arquivo | Módulo | Descrição |
|---------|--------|-----------|
| `DOCUMENTACAO-TECNICA-MICRO-PARTE1.md` | PARTE 1 | Arquitetura de Permissões e Stakeholders |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE2.md` | PARTE 2 | Servidor |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE3.md` | PARTE 3 | Dependentes |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE4.md` | PARTE 4 | Departamentos |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE5.md` | PARTE 5 | Cargos |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE6.md` | PARTE 6 | Vínculo Funcional |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE7.md` | PARTE 7 | Rubricas |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE8.md` | PARTE 8 | Folha de Pagamento |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE9.md` | PARTE 9 | 13º Salário |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE10.md` | PARTE 10 | Consignados |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE11.md` | PARTE 11 | eSocial |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE12.md` | PARTE 12 | TCE |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE13.md` | PARTE 13 | SEFIP/DIRF/RAIS |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE14.md` | PARTE 14 | Férias |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE15.md` | PARTE 15 | Ponto |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE16.md` | PARTE 16 | Afastamentos |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE17.md` | PARTE 17 | Concursos |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE18.md` | PARTE 18 | Capacitação |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE19.md` | PARTE 19 | Avaliação |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE20.md` | PARTE 20 | Progressão |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE21.md` | PARTE 21 | Pensionistas |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE22.md` | PARTE 22 | Simulações |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE23.md` | PARTE 23 | Relatórios |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE24.md` | PARTE 24 | Auditoria e Logs |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE25.md` | PARTE 25 | Notificações e Alertas |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE26.md` | PARTE 26 | Dashboards e Indicadores |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE27A.md` | PARTE 27A | PAD (Parte 1) |
| `DOCUMENTACAO-TECNICA-MICRO-PARTE27B.md` | PARTE 27B | PAD (Parte 2) |

### 2️⃣ ARQUITETURA E IMPLEMENTAÇÃO

| Arquivo | Conteúdo |
|---------|----------|
| `ARQUITETURA-ECOSSISTEMA-WS-SERVICES.md` | Visão geral do ecossistema (eRH, eFrotas, etc.) |
| `PLANO-REFATORACAO-ERH-SERVICE.md` | **Plano de refatoração**, módulos, cronograma |

---

## 📋 RESUMO DOS MÓDULOS

### PARTE 1 - Visão Geral
- Arquitetura do sistema
- Multi-tenancy (gerenciado pelo COMMON)
- Modelo de dados base

### PARTE 2 - Servidor
- Cadastro de servidores públicos
- Dados pessoais, documentos
- Dados bancários

### PARTE 3 - Dependentes
- Cadastro de dependentes
- Benefícios (IRRF, Salário Família)
- Vigência

### PARTE 4 - Departamentos
- Estrutura organizacional
- Hierarquia
- Lotações

### PARTE 5 - Cargos
- Plano de Cargos e Carreiras
- CBO
- Níveis de progressão

### PARTE 6 - Vínculo Funcional
- Relação de emprego
- Matrícula
- Histórico de detalhes

### PARTE 7 - Rubricas
- Vantagens e descontos
- Fórmulas de cálculo
- Incidências

### PARTE 8 - Folha de Pagamento
- Motor de cálculo
- INSS, IRRF, RPPS
- Processamento batch

### PARTE 9 - 13º Salário
- 1ª e 2ª parcela
- Proporcionalidade
- Médias

### PARTE 10 - Consignados
- Empréstimos
- Margem consignável
- Integração bancária

### PARTE 11 - eSocial
- Eventos de tabelas
- Eventos não periódicos
- Eventos periódicos

### PARTE 12 - TCE
- Layouts por estado
- Validações
- Exportação

### PARTE 13 - SEFIP/DIRF/RAIS
- Obrigações federais
- Geração de arquivos
- Retificações

### PARTE 14 - Férias
- Período aquisitivo/concessivo
- Fracionamento
- Abono pecuniário

### PARTE 15 - Ponto Eletrônico
- Jornada de trabalho
- Banco de horas
- Integração REP

### PARTE 16 - Afastamentos
- Licenças
- Faltas
- Suspensões

### PARTE 17 - Concursos
- Processos seletivos
- Candidatos
- Nomeações

### PARTE 18 - Capacitação
- Treinamentos
- Certificações
- PDI

### PARTE 19 - Avaliação de Desempenho
- Ciclos avaliativos
- Metas
- Feedback

### PARTE 20 - Progressão
- Vertical e horizontal
- Enquadramento
- Retroatividade

### PARTE 21 - Pensionistas
- Beneficiários de pensão
- Quotas
- Cessação

### PARTE 22 - Simulações
- Projeções de folha
- Impacto de reajustes
- Cenários

### PARTE 23 - Relatórios
- Jasper Reports
- Templates
- Exportação

### PARTE 24 - Auditoria e Logs
- Trilha de auditoria
- Compliance
- LGPD

### PARTE 25 - Notificações
- Alertas do sistema
- E-mail
- Push notifications

### PARTE 26 - Dashboards
- Indicadores de RH
- Gráficos
- KPIs

### PARTE 27 - PAD
- Processos disciplinares
- Fases processuais
- Penalidades

---

## 📊 ESTATÍSTICAS DA DOCUMENTAÇÃO

| Métrica | Valor |
|---------|-------|
| Total de Módulos Documentados | 27 |
| Total de Arquivos de Documentação | 12 |
| Issues de Implementação Criadas | 50+ |
| Estados TCE Mapeados | 10 |
| Integrações Externas Planejadas | 15+ |

---

## 🚀 COMO USAR ESTA DOCUMENTAÇÃO

### Para Desenvolvedores
1. Comece pela [ARQUITETURA-SISTEMA-ERH.md](ARQUITETURA-SISTEMA-ERH.md)
2. Consulte [INTEGRACAO-MODULOS-ERH.md](INTEGRACAO-MODULOS-ERH.md) para entender fluxos
3. Use [PLANO-IMPLEMENTACAO-ERH.md](PLANO-IMPLEMENTACAO-ERH.md) para issues

### Para Gerentes de Projeto
1. Leia [VISAO-FUTURA-ERH.md](VISAO-FUTURA-ERH.md) para roadmap
2. Consulte [PLANO-IMPLEMENTACAO-ERH.md](PLANO-IMPLEMENTACAO-ERH.md) para cronograma
3. Use [ADAPTABILIDADE-MULTI-ENTE.md](ADAPTABILIDADE-MULTI-ENTE.md) para escopo comercial

### Para Analistas de Negócio
1. Consulte os arquivos PARTE para regras de negócio
2. Use [README-PLANO-ERH.md](README-PLANO-ERH.md) como referência rápida

---

## 📝 CHANGELOG

| Data | Versão | Alterações |
|------|--------|------------|
| 2024-01 | 1.0 | Documentação inicial (PARTE 1-23) |
| 2024-01 | 1.1 | Adicionado PARTE 24-27 |
| 2024-01 | 2.0 | Documentação de arquitetura e implementação |

---

**Última atualização**: Janeiro 2025
