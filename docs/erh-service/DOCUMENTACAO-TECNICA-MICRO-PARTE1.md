# 📘 DOCUMENTAÇÃO TÉCNICA DETALHADA - eRH Municipal

## PARTE 1: Arquitetura de Permissões e Stakeholders

**Data:** 08 de Janeiro de 2026  
**Versão:** 1.0 - Documentação em Nível Micro

---

## 1. ARQUITETURA DE PERMISSÕES (MBAC)

### 1.1 Modelo de Controle de Acesso Baseado em Módulos

O sistema utiliza **MBAC (Module-Based Access Control)**, permitindo que um mesmo usuário tenha papéis diferentes em módulos diferentes para a mesma Unidade Gestora.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ESTRUTURA DE PERMISSÕES                                 │
└─────────────────────────────────────────────────────────────────────────────┘

                            ┌──────────────┐
                            │   Usuario    │
                            │  (login,     │
                            │   email,     │
                            │   senha)     │
                            └──────┬───────┘
                                   │
                                   │ 1:N
                                   ▼
                      ┌────────────────────────┐
                      │   UsuarioPermissao     │
                      │  ─────────────────     │
                      │  - usuario_id (FK)     │
                      │  - unidade_gestora_id  │
                      │  - modulo ("ERH")      │
                      │  - role (RoleUsuario)  │
                      └────────────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
              ┌──────────┐  ┌──────────┐  ┌──────────┐
              │ UG: 1    │  │ UG: 1    │  │ UG: 2    │
              │ Mod: ERH │  │ Mod:FROTA│  │ Mod: ERH │
              │ Role:ADM │  │ Role:GEST│  │ Role:ANAL│
              └──────────┘  └──────────┘  └──────────┘
```

### 1.2 Roles Disponíveis

```java
public enum RoleUsuario implements GrantedAuthority {
    ADMIN,       // Acesso total ao módulo
    GESTOR,      // Gerencia operações, aprova solicitações
    ANALISTA,    // Visualiza e analisa, não modifica dados críticos
    USUARIO;     // Acesso básico de leitura e operações simples
}
```

### 1.3 Tabela de Permissões Detalhada por Role no eRH

```
┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                           MATRIZ DE PERMISSÕES - MÓDULO eRH                                 │
├─────────────────────────────────┬─────────┬─────────┬──────────┬─────────────────────────────┤
│        FUNCIONALIDADE           │  ADMIN  │ GESTOR  │ ANALISTA │        USUARIO              │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ CADASTROS                       │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Cadastrar servidor              │   ✅    │   ✅    │    ❌    │            ❌               │
│ Editar servidor                 │   ✅    │   ✅    │    ❌    │            ❌               │
│ Visualizar servidor             │   ✅    │   ✅    │    ✅    │            ✅               │
│ Excluir servidor                │   ✅    │   ❌    │    ❌    │            ❌               │
│ Cadastrar dependente            │   ✅    │   ✅    │    ❌    │            ❌               │
│ Editar vínculo funcional        │   ✅    │   ✅    │    ❌    │            ❌               │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ FOLHA DE PAGAMENTO              │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Processar folha                 │   ✅    │   ✅    │    ❌    │            ❌               │
│ Reprocessar folha individual    │   ✅    │   ✅    │    ❌    │            ❌               │
│ Fechar competência              │   ✅    │   ❌    │    ❌    │            ❌               │
│ Reabrir competência             │   ✅    │   ❌    │    ❌    │            ❌               │
│ Adicionar rubrica manual        │   ✅    │   ✅    │    ❌    │            ❌               │
│ Editar rubrica manual           │   ✅    │   ✅    │    ❌    │            ❌               │
│ Visualizar folha                │   ✅    │   ✅    │    ✅    │            ✅               │
│ Emitir contra-cheque            │   ✅    │   ✅    │    ✅    │            ❌               │
│ Exportar SAGRES/TCE             │   ✅    │   ✅    │    ❌    │            ❌               │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ LEGISLAÇÃO                      │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Cadastrar legislação            │   ✅    │   ❌    │    ❌    │            ❌               │
│ Editar faixas IRRF/INSS/RPPS    │   ✅    │   ❌    │    ❌    │            ❌               │
│ Visualizar legislação           │   ✅    │   ✅    │    ✅    │            ✅               │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ CONSIGNADO (A IMPLEMENTAR)      │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Cadastrar consignatária         │   ✅    │   ❌    │    ❌    │            ❌               │
│ Cadastrar empréstimo            │   ✅    │   ✅    │    ❌    │            ❌               │
│ Consultar margem                │   ✅    │   ✅    │    ✅    │            ❌               │
│ Cancelar empréstimo             │   ✅    │   ❌    │    ❌    │            ❌               │
│ Reservar margem (API banco)     │   ✅    │   ✅    │    ❌    │            ❌               │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ FÉRIAS (A IMPLEMENTAR)          │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Cadastrar programação           │   ✅    │   ✅    │    ✅    │            ❌               │
│ Aprovar programação             │   ✅    │   ✅    │    ❌    │            ❌               │
│ Cancelar programação            │   ✅    │   ✅    │    ❌    │            ❌               │
│ Interromper férias              │   ✅    │   ✅    │    ❌    │            ❌               │
│ Visualizar períodos aquisitivos │   ✅    │   ✅    │    ✅    │            ✅               │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ LICENÇAS (A IMPLEMENTAR)        │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Solicitar licença               │   ✅    │   ✅    │    ✅    │            ❌               │
│ Aprovar licença                 │   ✅    │   ✅    │    ❌    │            ❌               │
│ Negar licença                   │   ✅    │   ✅    │    ❌    │            ❌               │
│ Prorrogar licença               │   ✅    │   ✅    │    ❌    │            ❌               │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ RELATÓRIOS                      │         │         │          │                             │
├─────────────────────────────────┼─────────┼─────────┼──────────┼─────────────────────────────┤
│ Gerar qualquer relatório        │   ✅    │   ✅    │    ✅    │            ❌               │
│ Exportar dados                  │   ✅    │   ✅    │    ✅    │            ❌               │
│ Visualizar dashboard            │   ✅    │   ✅    │    ✅    │            ✅               │
└─────────────────────────────────┴─────────┴─────────┴──────────┴─────────────────────────────┘
```

---

## 2. STAKEHOLDERS E RESPONSABILIDADES

### 2.1 Mapeamento de Stakeholders por Módulo

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                           STAKEHOLDERS DO SISTEMA eRH                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  NÍVEL ESTRATÉGICO                                                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    ┌───────────────────────┐   │
│  │   SECRETÁRIO DE         │    │   PREFEITO/ORDENADOR    │    │   CONTROLADOR         │   │
│  │   ADMINISTRAÇÃO         │    │   DE DESPESA            │    │   INTERNO             │   │
│  ├─────────────────────────┤    ├─────────────────────────┤    ├───────────────────────┤   │
│  │ • Decisões estratégicas │    │ • Autoriza pagamentos   │    │ • Audita processos    │   │
│  │ • Política de pessoal   │    │ • Assina empenhos       │    │ • Verifica compliance │   │
│  │ • Aprovação de PCCS     │    │ • Autoriza nomeações    │    │ • Valida relatórios   │   │
│  │                         │    │                         │    │                       │   │
│  │ Role: ADMIN (leitura)   │    │ Role: Não acessa        │    │ Role: ANALISTA        │   │
│  │ Acesso: Relatórios      │    │ sistema diretamente     │    │ Acesso: Leitura total │   │
│  └─────────────────────────┘    └─────────────────────────┘    └───────────────────────┘   │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  NÍVEL OPERACIONAL                                                                          │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    ┌───────────────────────┐   │
│  │   DIRETOR DE RH         │    │   COORDENADOR DE        │    │   ANALISTA DE RH      │   │
│  │                         │    │   FOLHA DE PAGAMENTO    │    │                       │   │
│  ├─────────────────────────┤    ├─────────────────────────┤    ├───────────────────────┤   │
│  │ • Gestão da equipe      │    │ • Processa folha        │    │ • Cadastra servidores │   │
│  │ • Aprovação de férias   │    │ • Fecha competência     │    │ • Lança rubricas      │   │
│  │ • Aprovação licenças    │    │ • Exporta SAGRES        │    │ • Consulta margem     │   │
│  │ • Decisões operacionais │    │ • Gera relatórios       │    │ • Atende servidores   │   │
│  │                         │    │ • Configura legislação  │    │                       │   │
│  │ Role: ADMIN             │    │ Role: ADMIN             │    │ Role: GESTOR          │   │
│  │ Acesso: Total           │    │ Acesso: Total Folha     │    │ Acesso: Operacional   │   │
│  └─────────────────────────┘    └─────────────────────────┘    └───────────────────────┘   │
│                                                                                             │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    ┌───────────────────────┐   │
│  │   CONTADOR              │    │   AUXILIAR DE RH        │    │   SERVIDOR            │   │
│  │                         │    │                         │    │   (Portal - futuro)   │   │
│  ├─────────────────────────┤    ├─────────────────────────┤    ├───────────────────────┤   │
│  │ • Confere cálculos      │    │ • Digitação de dados    │    │ • Consulta contra-    │   │
│  │ • Valida previdência    │    │ • Atualização cadastral │    │   cheque              │   │
│  │ • Concilia valores      │    │ • Arquivamento          │    │ • Solicita férias     │   │
│  │ • Confere IRRF          │    │                         │    │ • Solicita licenças   │   │
│  │                         │    │                         │    │ • Atualiza dados      │   │
│  │ Role: ANALISTA          │    │ Role: USUARIO           │    │ Role: SERVIDOR        │   │
│  │ Acesso: Leitura         │    │ Acesso: Básico          │    │ (futuro)              │   │
│  └─────────────────────────┘    └─────────────────────────┘    └───────────────────────┘   │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  STAKEHOLDERS EXTERNOS                                                                      │
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                             │
│  ┌─────────────────────────┐    ┌─────────────────────────┐    ┌───────────────────────┐   │
│  │   TCE/SAGRES            │    │   CONSIGNATÁRIA         │    │   e-SOCIAL            │   │
│  │                         │    │   (Banco)               │    │                       │   │
│  ├─────────────────────────┤    ├─────────────────────────┤    ├───────────────────────┤   │
│  │ • Recebe arquivos       │    │ • Consulta margem       │    │ • Recebe eventos      │   │
│  │ • Audita dados          │    │ • Reserva margem        │    │ • Valida dados        │   │
│  │ • Fiscaliza folha       │    │ • Contrata empréstimos  │    │ • Retorna erros       │   │
│  │                         │    │ • Envia parcelas        │    │                       │   │
│  │ Integração: Arquivo XML │    │ Integração: API REST    │    │ Integração: WebService│   │
│  │ Frequência: Mensal      │    │ Frequência: Sob demanda │    │ Frequência: Por evento│   │
│  └─────────────────────────┘    └─────────────────────────┘    └───────────────────────┘   │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Tarefas por Stakeholder - Detalhamento

#### 2.2.1 Coordenador de Folha de Pagamento

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│  TAREFAS DO COORDENADOR DE FOLHA - CICLO MENSAL                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

SEMANA 1 (Dias 1-7 do mês)
──────────────────────────────────────────────────────────────────────────────────────────────
┌─────────┬───────────────────────────────────────────────────────────────────────────────────┐
│ DIA 1-2 │ ABERTURA DA COMPETÊNCIA                                                          │
├─────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ Ação    │ 1. Criar nova competência no sistema                                             │
│         │ 2. Verificar legislação vigente (IRRF, INSS, RPPS, Salário Mínimo)               │
│         │ 3. Atualizar tabelas de legislação se houve mudança                              │
│         │ 4. Verificar se há novas rubricas para cadastrar                                 │
│         │                                                                                   │
│ Sistema │ Menu > Folha > Competências > Nova                                               │
│         │ Menu > Legislação > Parâmetros Legais > Verificar/Editar                         │
│         │                                                                                   │
│ Cuidado │ ⚠️ Se a legislação mudou (ex: nova tabela IRRF), DEVE atualizar ANTES            │
│         │    de processar qualquer folha                                                   │
└─────────┴───────────────────────────────────────────────────────────────────────────────────┘

┌─────────┬───────────────────────────────────────────────────────────────────────────────────┐
│ DIA 3-5 │ MOVIMENTAÇÕES E LANÇAMENTOS                                                      │
├─────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ Ação    │ 1. Processar admissões do mês anterior                                           │
│         │    - Cadastrar novo servidor                                                     │
│         │    - Criar vínculo funcional                                                     │
│         │    - Definir cargo, nível, lotação                                               │
│         │    - Cadastrar dependentes                                                       │
│         │                                                                                   │
│         │ 2. Processar desligamentos                                                       │
│         │    - Alterar situação do vínculo                                                 │
│         │    - Calcular verbas rescisórias (futuro)                                        │
│         │                                                                                   │
│         │ 3. Lançar rubricas variáveis                                                     │
│         │    - Horas extras                                                                │
│         │    - Faltas/Atrasos                                                              │
│         │    - Gratificações eventuais                                                     │
│         │    - Descontos judiciais                                                         │
│         │                                                                                   │
│ Sistema │ Menu > Cadastros > Servidores > Novo/Editar                                      │
│         │ Menu > Folha > Lançamentos > Adicionar Rubrica                                   │
└─────────┴───────────────────────────────────────────────────────────────────────────────────┘

SEMANA 2 (Dias 8-15 do mês)
──────────────────────────────────────────────────────────────────────────────────────────────
┌─────────┬───────────────────────────────────────────────────────────────────────────────────┐
│ DIA 8-10│ PROCESSAMENTO DA FOLHA                                                           │
├─────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ Ação    │ 1. Executar processamento em lote                                                │
│         │    Sistema irá:                                                                  │
│         │    a) Buscar todos os vínculos ativos                                            │
│         │    b) Para cada vínculo, criar/atualizar FolhaPagamento                          │
│         │    c) Aplicar rubricas fixas do vínculo                                          │
│         │    d) Calcular bases de incidência                                               │
│         │    e) Calcular INSS/RPPS                                                         │
│         │    f) Calcular IRRF                                                              │
│         │    g) Calcular Salário Família                                                   │
│         │    h) Gerar itens automáticos (A1-A9)                                            │
│         │                                                                                   │
│         │ 2. Verificar erros do processamento                                              │
│         │    - Servidor sem cargo                                                          │
│         │    - Base de cálculo zerada                                                      │
│         │    - Dados incompletos                                                           │
│         │                                                                                   │
│ Sistema │ Menu > Folha > Processamento > Processar Competência                             │
│         │ Botão: "Iniciar Processamento"                                                   │
│         │ Botão: "Ver Erros" (se houver)                                                   │
└─────────┴───────────────────────────────────────────────────────────────────────────────────┘

┌─────────┬───────────────────────────────────────────────────────────────────────────────────┐
│DIA 11-12│ CONFERÊNCIA E AJUSTES                                                            │
├─────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ Ação    │ 1. Conferir resumo da folha                                                      │
│         │    - Total bruto vs mês anterior                                                 │
│         │    - Total descontos                                                             │
│         │    - Total líquido                                                               │
│         │    - Variação % (alertar se > 5%)                                                │
│         │                                                                                   │
│         │ 2. Verificar casos específicos                                                   │
│         │    - Servidores com salário zerado                                               │
│         │    - IRRF muito alto ou muito baixo                                              │
│         │    - Dependentes não contabilizados                                              │
│         │                                                                                   │
│         │ 3. Reprocessar folhas com erro                                                   │
│         │                                                                                   │
│ Sistema │ Menu > Folha > Relatórios > Resumo Folha                                         │
│         │ Menu > Folha > Processamento > Reprocessar (individual)                          │
└─────────┴───────────────────────────────────────────────────────────────────────────────────┘

SEMANA 3-4 (Dias 16-30 do mês)
──────────────────────────────────────────────────────────────────────────────────────────────
┌─────────┬───────────────────────────────────────────────────────────────────────────────────┐
│DIA 16-18│ FECHAMENTO E EXPORTAÇÕES                                                         │
├─────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ Ação    │ 1. Fechar competência                                                            │
│         │    ⚠️ ATENÇÃO: Após fechar, não é possível alterar!                              │
│         │    - Revisar todos os valores                                                    │
│         │    - Confirmar com Diretor de RH                                                 │
│         │                                                                                   │
│         │ 2. Gerar arquivo SAGRES/TCE                                                      │
│         │    - Exportar XML                                                                │
│         │    - Validar no validador do TCE                                                 │
│         │    - Corrigir erros se houver                                                    │
│         │                                                                                   │
│         │ 3. Enviar eventos e-Social                                                       │
│         │    - S-1200 (Remuneração)                                                        │
│         │    - S-1210 (Pagamentos)                                                         │
│         │                                                                                   │
│ Sistema │ Menu > Folha > Competências > Fechar                                             │
│         │ Menu > Integrações > SAGRES > Exportar                                           │
│         │ Menu > Integrações > e-Social > Enviar Eventos                                   │
└─────────┴───────────────────────────────────────────────────────────────────────────────────┘

┌─────────┬───────────────────────────────────────────────────────────────────────────────────┐
│DIA 20-25│ RELATÓRIOS E ARQUIVAMENTO                                                        │
├─────────┼───────────────────────────────────────────────────────────────────────────────────┤
│ Ação    │ 1. Gerar contra-cheques                                                          │
│         │    - PDF individual ou em lote                                                   │
│         │    - Disponibilizar no Portal (futuro)                                           │
│         │                                                                                   │
│         │ 2. Gerar relatórios gerenciais                                                   │
│         │    - Folha por secretaria                                                        │
│         │    - Resumo de descontos                                                         │
│         │    - Relatório previdenciário                                                    │
│         │                                                                                   │
│         │ 3. Arquivo bancário para pagamento                                               │
│         │    - CNAB 240 para banco                                                         │
│         │                                                                                   │
│ Sistema │ Menu > Relatórios > Contra-Cheque                                                │
│         │ Menu > Relatórios > Gerenciais                                                   │
│         │ Menu > Integrações > Bancos > Gerar Remessa                                      │
└─────────┴───────────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. CONTEXTO DE EXECUÇÃO (TenantContext)

### 3.1 Como Funciona o Contexto Multi-Tenant

O sistema usa `ThreadLocal` para armazenar informações do usuário autenticado durante a requisição:

```java
public class TenantContext {
    // ID da Unidade Gestora atual
    private static final ThreadLocal<Long> currentUnidadeGestoraId = new ThreadLocal<>();
    
    // Mapa de todas as UGs do usuário com suas roles
    private static final ThreadLocal<Map<Long, String>> unidadesGestoras = new ThreadLocal<>();
    
    // Role do usuário na UG atual
    private static final ThreadLocal<String> currentUnidadeGestoraRole = new ThreadLocal<>();
    
    // Módulo atual (ERH, FROTAS, etc.)
    private static final ThreadLocal<String> currentModulo = new ThreadLocal<>();
}
```

### 3.2 Fluxo de Autenticação e Contexto

```
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                         FLUXO DE AUTENTICAÇÃO E CONTEXTO                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

     CLIENTE (Frontend)                                       SERVIDOR (Backend)
     ─────────────────                                        ─────────────────
            │                                                        │
            │  1. POST /auth/login                                   │
            │     {login, senha, unidadeGestoraId, modulo}           │
            ├───────────────────────────────────────────────────────▶│
            │                                                        │
            │                                    2. Validar credenciais
            │                                       │
            │                                       ▼
            │                          ┌─────────────────────────┐
            │                          │ SELECT * FROM usuario   │
            │                          │ WHERE login = ?         │
            │                          │ AND senha = hash(?)     │
            │                          └─────────────────────────┘
            │                                       │
            │                                       ▼
            │                          3. Buscar permissões MBAC
            │                          ┌─────────────────────────┐
            │                          │ SELECT * FROM           │
            │                          │ usuario_permissao       │
            │                          │ WHERE usuario_id = ?    │
            │                          │ AND unidade_gestora_id=?│
            │                          │ AND modulo = ?          │
            │                          └─────────────────────────┘
            │                                       │
            │                                       ▼
            │                          4. Verificar se tem acesso
            │                             ao módulo/UG solicitado
            │                                       │
            │                                       ▼
            │                          5. Gerar JWT Token com:
            │                             - usuarioId
            │                             - currentUnidadeGestora
            │                             - currentModulo  
            │                             - role
            │                             - unidadesGestoras[]
            │                                       │
            │  6. Response: {token, usuario, ug, role}              │
            │◀───────────────────────────────────────────────────────┤
            │                                                        │
            │                                                        │
     ═══════════════════════ REQUISIÇÕES SUBSEQUENTES ═══════════════════════
            │                                                        │
            │  7. GET /api/erh/servidores                            │
            │     Header: Authorization: Bearer <JWT>                │
            ├───────────────────────────────────────────────────────▶│
            │                                                        │
            │                                    8. JwtFilter intercepta
            │                                       │
            │                                       ▼
            │                          9. Extrair claims do JWT
            │                          ┌─────────────────────────┐
            │                          │ ugId = claims.get(      │
            │                          │   "currentUnidadeGestora│
            │                          │ ")                      │
            │                          │ role = claims.get("role")│
            │                          │ modulo = claims.get(    │
            │                          │   "modulo")             │
            │                          └─────────────────────────┘
            │                                       │
            │                                       ▼
            │                          10. Setar TenantContext
            │                          ┌─────────────────────────┐
            │                          │ TenantContext           │
            │                          │  .setCurrentUgId(ugId)  │
            │                          │ TenantContext           │
            │                          │  .setCurrentRole(role)  │
            │                          │ TenantContext           │
            │                          │  .setCurrentModulo(mod) │
            │                          └─────────────────────────┘
            │                                       │
            │                                       ▼
            │                          11. Hibernate Filter ativado
            │                          ┌─────────────────────────┐
            │                          │ @Filter("tenantFilter") │
            │                          │ condition:              │
            │                          │ unidade_gestora_id = :id│
            │                          └─────────────────────────┘
            │                                       │
            │                                       ▼
            │                          12. Executar query com filtro
            │                          ┌─────────────────────────┐
            │                          │ SELECT * FROM servidor  │
            │                          │ WHERE unidade_gestora_id│
            │                          │       = 123             │
            │                          │ AND excluido = false    │
            │                          └─────────────────────────┘
            │                                       │
            │  13. Response: [servidores da UG 123]                  │
            │◀───────────────────────────────────────────────────────┤
            │                                                        │
            │                                    14. TenantContext.clear()
            │                                        (no finally do filter)
```

---

## 4. IMPLEMENTAÇÃO DE PERMISSÕES NOS CONTROLLERS

### 4.1 Exemplo de Controller com Verificação de Permissão

```java
@RestController
@RequestMapping("/api/erh/servidores")
@RequiredArgsConstructor
public class ServidorController {
    
    private final ServidorService servidorService;
    private final PermissaoService permissaoService;
    
    /**
     * Lista servidores - Qualquer role pode visualizar
     * Roles: ADMIN, GESTOR, ANALISTA, USUARIO
     */
    @GetMapping
    public ResponseEntity<Page<ServidorDTO>> listar(
            @RequestParam(required = false) String nome,
            Pageable pageable) {
        
        // TenantContext já filtra por UG automaticamente via Hibernate Filter
        return ResponseEntity.ok(servidorService.findAll(nome, pageable));
    }
    
    /**
     * Cadastra novo servidor - Apenas ADMIN e GESTOR
     * Roles: ADMIN, GESTOR
     */
    @PostMapping
    public ResponseEntity<ServidorDTO> criar(@RequestBody @Valid ServidorCreateDTO dto) {
        
        // Verificar permissão
        verificarPermissao(RoleUsuario.ADMIN, RoleUsuario.GESTOR);
        
        Servidor servidor = servidorService.create(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(toDTO(servidor));
    }
    
    /**
     * Exclui servidor - Apenas ADMIN
     * Roles: ADMIN
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> excluir(@PathVariable Long id) {
        
        // Verificar permissão
        verificarPermissao(RoleUsuario.ADMIN);
        
        servidorService.delete(id);
        return ResponseEntity.noContent().build();
    }
    
    /**
     * Método auxiliar para verificar permissão
     */
    private void verificarPermissao(RoleUsuario... rolesPermitidas) {
        String roleAtual = TenantContext.getCurrentUnidadeGestoraRole();
        
        boolean permitido = Arrays.stream(rolesPermitidas)
            .anyMatch(r -> r.name().equals(roleAtual));
        
        if (!permitido) {
            throw new AccessDeniedException(
                "Usuário com role " + roleAtual + " não tem permissão para esta operação"
            );
        }
    }
}
```

### 4.2 Anotação Personalizada para Permissões (Sugestão de Implementação)

```java
/**
 * Anotação para declarar permissões necessárias no método
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface RequiresRole {
    RoleUsuario[] value();
}

/**
 * Aspect para interceptar e validar permissões
 */
@Aspect
@Component
@RequiredArgsConstructor
public class PermissaoAspect {
    
    @Before("@annotation(requiresRole)")
    public void verificarPermissao(JoinPoint joinPoint, RequiresRole requiresRole) {
        String roleAtual = TenantContext.getCurrentUnidadeGestoraRole();
        
        boolean permitido = Arrays.stream(requiresRole.value())
            .anyMatch(r -> r.name().equals(roleAtual));
        
        if (!permitido) {
            throw new AccessDeniedException(
                "Acesso negado. Roles necessárias: " + 
                Arrays.toString(requiresRole.value()) +
                ", Role atual: " + roleAtual
            );
        }
    }
}

// Uso no Controller:
@PostMapping
@RequiresRole({RoleUsuario.ADMIN, RoleUsuario.GESTOR})
public ResponseEntity<ServidorDTO> criar(@RequestBody ServidorCreateDTO dto) {
    // ... implementação
}
```

---

**Continua na PARTE 2: Fluxo de Processamento da Folha em Nível Micro**

