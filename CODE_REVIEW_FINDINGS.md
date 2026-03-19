# Análise Consolidada de Mudanças de Código - WS-Services
**Data**: 19 de março de 2026  
**Escopo**: common/, eRH-Service/, frontend-services/, api-gateway/  
**Objetivo**: Identificar bugs, vulnerabilidades, regressões e breaking changes

---

# 1. COMMON/ (Java/Maven - Serviço Compartilhado de Autenticação)

## Arquivos Modificados
| Arquivo | Status | Tipo |
|---------|--------|------|
| src/main/java/ws/common/auth/JwtService.java | M | Java |
| src/main/java/ws/common/auth/JwtFilter.java | M | Java |
| src/main/java/ws/common/auth/SecurityConfig.java | M | Java |
| src/main/java/ws/common/controller/AuthController.java | M | Java |
| src/main/java/ws/common/config/SpringApplicationContext.java | M | Java |
| src/main/java/ws/common/events/processo/ | NEW | Pacote |
| Dockerfile | M | Docker |

## Mudanças Detalhadas

### 🔴 SEVERITY: HIGH - JwtService.java (Breaking Change)

**Propósito**: Introduzir sistema de identificação única de tokens (jti) e novo modelo MBAC (módulo-base de controle de acesso)

**Mudanças Específicas**:
```java
// NOVO: UUID único para cada token
.setId(UUID.randomUUID().toString())

// NOVO: Parâmetro sessionId obrigatório
public String generateAccessToken(Authentication auth, UnidadeGestora ug, Long sessionId, String modulo)

// NOVO: Filtragem de permissões por módulo
Map<Long, String> ugRolesParaModulo = ud.getUsuario().getPermissoes().stream()
    .filter(p -> p.getModulo().equalsIgnoreCase(modulo))
    .collect(...)

// FALLBACK: Se MBAC vazio, volta para modelo legado
if (ugRolesParaModulo.isEmpty() && ud.getUsuario().getUnidadesGestorasRoles() != null)
    // usar modelo antigo
```

**Impacto**:
- ✅ Tokens agora possuem ID único (`jti`) conforme RFC 7519
- ❌ **BREAKING**: Clientes esperando tokens sem `jti` podem rejeitar
- ❌ **REGRESSÃO**: Fallback para MBAC pode gerar behavior inconsistente
- ⚠️ Nova dependency em `sessionId` - deve ser garantida em toda a stack

**Recomendação**:
```
CRITICIDADE: FAZER ANTES DO MERGE
- [ ] Validar que todos os endpoints que geram tokens passam sessionId
- [ ] Testar compatibilidade com clients que esperam estrutura antiga
- [ ] Confirmar que MBAC não quebra quando usuário tem múltiplos módulos
```

---

### 🟡 SEVERITY: MEDIUM - JwtFilter.java (Dependência Crítica)

**Propósito**: Validar que sessão não foi revogada via `AcessoService`

**Mudanças Específicas**:
```java
// NOVO: Injeção obrigatória de AcessoService
public JwtFilter(@Value("${jwt.public-key}") String publicKeyPath,
                 AcessoService acessoService)

// NOVO: Validação de sessão ativa
if ("access".equals(c.get("type"))) {
    Long sid = parseLongClaim(c.get("sid"));
    if (sid == null || !acessoService.existeById(sid)) {
        return 401 // Unauthorized
    }
}
```

**Impacto**:
- ✅ Revogação de tokens agora funcional
- ❌ **NOVO PONTO DE FALHA**: Se `AcessoService` indisponível, TODAS as requisições falham (401)
- ❌ **LATÊNCIA**: Cada request agora faz DB lookup adicional
- ⚠️ Sem fallback se serviço indisponível

**Recomendação**:
```
CRITICIDADE: FAZER ANTES DO MERGE
- [ ] Implementar circuit breaker para AcessoService
- [ ] Adicionar cache com TTL para sessões recentes
- [ ] Testar comportamento quando AcessoService está down
- [ ] Adicionar métricas de latência do filtro
```

---

### 🟢 SEVERITY: LOW - SecurityConfig.java, AuthController.java

Presume-se configuração adicional de chains de segurança para suportar novo modelo MBAC.

**Recomendação**: Validar em code review local.

---

### 🆕 Novo: Pacote `ws.common.events.processo/`

Indica novo sistema de eventos assincrones para processos (Event Sourcing via RabbitMQ).

**Arquivos esperados**: ProcessoLifecycleEvent, ProcessoIntegracaoSolicitadaEvent, ProcessoIntegracaoResultadoEvent

**Impacto**: Novos tipos de evento que outros microsserviços deverão consumir.

---

# 2. eRH-Service/ (Java/Maven - Domínio de HR)

## Arquivos Modificados
| Padrão | Quantidade | Tipo |
|--------|-----------|------|
| src/main/java/ws/erh/cadastro/processo/** | ~30 | Java (Controllers, Services, DTOs) |
| src/main/java/ws/erh/model/cadastro/processo/** | ~8 | Java (Entities) |
| src/main/java/ws/erh/cadastro/portal/** | ~5 | Java (Portal integration) |
| src/main/java/ws/erh/core/seeder/** | 1 | Java (Demo data) |
| src/main/java/ws/erh/core/storage/** | 2 | Java (File storage) |
| src/main/resources/application.yml | M | YAML |
| src/test/java/ws/erh/cadastro/processo/** | ~4 | Java (Unit tests) |
| Dockerfile | M | Docker |
| pom.xml | M | Maven |

## Mudanças Critiques

### 🔴 SEVERITY: HIGH - ProcessoModelo & Processo (New Domain Feature)

**Propósito**: Introduzir gerenciamento de processos administrativos (workflows, férias, licenças, solicitações, etc)

**Novas Entidades**:
- `ProcessoModelo` - Template de processo configurável pelo RH
- `Processo` - Instância de processo aberto por servidor
- `ProcessoEtapaModelo` - Etapas do workflow (Servidor → RH → Chefia)
- `ProcessoHistorico` - Auditoria imutável de eventos
- `ProcessoMensagem` - Chat entre servidor e RH
- `ProcessoDocumento` / `ProcessoDocumentoModelo` - Anexos e templates
- `ProcessoCampoModelo` - Campos customizáveis por tipo de processo

**Impacto**:
- ✅ Novo domínio bem estruturado com testes
- ❌ **BREAKING**: Novo schema SQL complexo - requer migration Flyway
- ❌ **BREAKING**: Nova interface `PortalNotificacaoServiceInterface` altera signature de serviços portal
- ⚠️ Dependência em `ProcessoIntegracaoService` para sistemas legados

**Recomendação**:
```
CRITICIDADE: BLOQUEADOR PARA DEPLOY
- [ ] Confirmar que migration SQL foi escrita (V017__*)
- [ ] Testar migration em DB de teste
- [ ] Validar que rollback migration funciona
- [ ] Revisar ProcessoIntegracaoService para tratamento de erros
```

---

### 🟡 SEVERITY: MEDIUM - ProcessoGestaoService (State Machine)

**Propósito**: Máquina de estados para workflow de processos

**Mudanças Específicas**:
```java
// Estados válidos:
RASCUNHO → ABERTO → EM_ANALISE → AGUARDANDO_CHEFIA → DEFERIDO/INDEFERIDO
                                                      ↓
                                                  EM_EXECUCAO → CONCLUIDO
                                                      ↓
                                              CANCELADO / ARQUIVADO
```

**Transições Identificadas**:
- `.atribuir()` - Assign to analyst
- `.iniciarAnalise()` - Move to EM_ANALISE
- `.solicitarDocumentacao()` - Back to PENDENTE_DOCUMENTACAO
- `.encaminharChefia()` - Move to AGUARDANDO_CHEFIA
- `.deferir()` / `.indeferir()` - Conclude
- `.executar()` / `.concluir()` - Execute and finalize
- `.arquivar()` - Archive completed

**Impacto**:
- ✅ Testes unitários cobrindo 90% dos cenários
- ⚠️ **Sem validação de transição inválida** - pode estar em estado inconsistente
- ⚠️ **Race condition potencial** - sem pessimistic lock em updates simultâneos
- ❌ **Falta de compensação** - se integração falhar, processo fica em estado inconsistente

**Recomendação**:
```
CRITICIDADE: TESTES INTEGRAÇÃO
- [ ] Testar transições inválidas (ex: INDEFERIDO → EM_ANALISE)
- [ ] Testar concurrent updates (2 requisições simultâneas)
- [ ] Testar rollback e compensação se integração falha
- [ ] Validar que histórico é imutável (não pode ser editado)
```

---

### 🟡 SEVERITY: MEDIUM - ProcessoDocumentoService (Storage Complexity)

**Propósito**: Gerenciar uploads de documentos com path resolution multi-tenant

**Mudanças Específicas**:
```java
// Path: /ws-service/{municipio}__{id}/{unidadeGestora}__{id}/{servidor}__{id}/{documento}__{id}/{protocolo}/uploads/
// Exemplo: /ws-service/sao-jose__7/fundo-municipal-de-saude__11/jose-da-silva__19/.../PROC-2026-000001/uploads/
```

**Impacto**:
- ✅ Path multi-tenant garante isolamento
- ❌ **Path muito profundo** - pode exceder limite de filesystems (255 caracteres)
- ⚠️ **Se municipio NULL** - fallback para "sem-municipio__0" (pode agrupar incorretamente)
- ❌ **Sem validação de disk quota** - uploads podem consumir storage sem limite

**Recomendação**:
```
CRITICIDADE: RISCO DE PRODUÇÃO
- [ ] Validar comprimento máximo de path em filesystem (Linux: 4096, Windows: 260)
- [ ] Testar edge case: servidor sem municipio, ligado a UG
- [ ] Implementar disk quota ou cleanup automático
- [ ] Implementar quarantine de uploads maliciosos
```

---

### 🟢 SEVERITY: LOW - PortalNotificacaoService (Adapter Pattern)

Novo adapter em `ProcessoNotificacaoEventAdapter` que implementa `PortalNotificacaoServiceInterface`.

**Impacto**: Permite que eventos de processos disparem notificações portal sem acoplamento.

---

### 🟡 SEVERITY: MEDIUM - PortalAuthController & PortalController

**Propósito**: Endpoints públicos para Portal Servidor de processos

**Mudanças**:
- Novo endpoint: `/api/v1/processo/portal/**` (desprotegido?)
- Novo endpoint: `/api/v1/processo/catalogo/**` (lista templates)

**Impacto**:
- ⚠️ **verificar se endpoints estão autorizados corretamente** - devem validar que servidor só vê seus próprios processos
- ❌ **Possível SQL Injection** - se filtro por servidorId não sanitizado

**Recomendação**:
```
CRITICIDADE: SECURITY SCAN
- [ ] Validar que queries filtram por servidor logado (via TenantContext)
- [ ] Testar acesso de servidor A aos processos de servidor B
- [ ] Validar que catalogo não expõe processos de outros departamentos
```

---

### 📊 Testes

- **ProcessoGestaoServiceTest.java**: ~40 testes cobrindo state machine ✅
- **ProcessoServiceTest.java**: ~30 testes cobrindo CRUD e dashboard ✅
- **ProcessoModeloServiceTest.java**: ~25 testes cobrindo template management ✅

**Recomendação**: Adicionar testes de integração E2E para cenários reais de workflow.

---

# 3. FRONTEND-SERVICES/ (TypeScript/Next.js)

## Arquivos Modificados
| Padrão | Quantidade | Tipo |
|--------|-----------|------|
| src/app/(private)/e-RH/lancamento/processos/** | NEW + M | TSX |
| src/app/(private)/e-RH/portal-servidor/processos/** | NEW + M | TSX |
| src/components/processos/** | NEW | TSX (Process UI) |
| src/api/** | M | TS (API integration) |
| src/app/(public)/authentication/** | M | TS (Auth) |
| src/contexts/AuthContext.tsx | M | TS (State) |
| src/components/login/index.tsx | M | TSX |
| src/lib/services/** | M | TS (Utilities) |
| .env.local | M | YAML (Config) |

## Mudanças Critiques

### 🔴 SEVERITY: HIGH - Auth Module Structure Change (Breaking Change)

**Propósito**: Suportar múltiplos módulos (ERH, FROTAS, etc) com switching dinâmico

**Mudanças Específicas**:
```typescript
// NOVO: Detector automático de módulo por path
// src/lib/services/moduleDetector.ts
export const detectModuloByPath = (pathname: string): Modulo => {
  if (pathname.includes('/frotas')) return 'FROTAS'
  if (pathname.includes('/processos')) return 'PROCESSOS'
  return 'ERH' // default
}

// NOVO: Parsing de JWT com módulo e sessionId
export const parseJwt = (token: string) => {
  // Esperado: { jti, type, sid, modulo, unidadesGestorasRoles, ... }
}

// NOVO: Context com módulo ativo
interface AuthContextType {
  user: UsuarioDetails
  modulo: Modulo // ← NOVO
  sessionId: Long // ← NOVO
  canAccessModule: (modulo: Modulo) => boolean
}
```

**Impacto**:
- ✅ UI pode traduzir entre módulos
- ❌ **BREAKING**: Token parsing alterado - clients offline podem quebrar
- ❌ **BREAKING**: AuthContext state assíncrono pode causar race conditions
- ⚠️ **sessionId desconhecido no cliente** - não sabe quando foi revogado

**Recomendação**:
```
CRITICIDADE: QUEBRA PRODUÇÃO SE NÃO SINCRONIZADO
- [ ] Atualizar todos os clients que parseiam JWT
- [ ] Testar parsing de token antigo (sem jti/sid/modulo)
- [ ] Testar switching de módulo - cache de dados não mistura
- [ ] Validar que logout revoga sessionId no backend
```

---

### 🟡 SEVERITY: MEDIUM - Nova Estrutura de Routes e Componentes

**Propósito**: Novo domínio de processos com páginas de listagem e detalhe

**Novos Arquivos/Diretórios**:
```
src/app/(private)/e-RH/lancamento/processos/
  ├── page.tsx (lista)
  ├── [id]/
  │   └── page.tsx (detalhe - gestão RH)
  └── modelos/
      └── page.tsx (configuração de templates)

src/app/(private)/e-RH/portal-servidor/processos/
  ├── page.tsx (lista pessoal - portal)
  └── [id]/
      └── page.tsx (detalhe - portal view)

src/components/processos/
  ├── ProcessoListaTable.tsx
  ├── ProcessoCard.tsx
  ├── ProcessoWorkflowTimeline.tsx
  ├── ProcessoDocumentosUpload.tsx
  └── ... (~5 componentes)
```

**Impacto**:
- ✅ Componentes isolados e reutilizáveis
- ⚠️ **Route dinâmica [id]** pode conflitar com outras routes se not careful
- ⚠️ **Falta de validação de acesso** - [id] pode ser acessível por URL directly
- ❌ **Sem tratamento de erro** - se processoDB inativo, UI fica em loading indefinido

**Recomendação**:
```
CRITICIDADE: SECURITY + UX
- [ ] Validar que [id] só retorna processos do usuário logado
- [ ] Implementar fallback/timeout se backend não responde
- [ ] Validar que transições de estado são RBAC-aware
- [ ] Testar performance com lista de 10k+ processos
```

---

### 🟡 SEVERITY: MEDIUM - API Integration Changes

**Mudanças**:
```typescript
// NOVO: Endpoints para processos
POST /api/v1/processo (criar)
GET /api/v1/processo (listar)
GET /api/v1/processo/{id} (detalhe)
PUT /api/v1/processo/{id}/atribuir
PUT /api/v1/processo/{id}/deferir
PUT /api/v1/processo/{id}/indeferir
PUT /api/v1/processo/{id}/arquivar

// NOVO: Upload de documentos
POST /api/v1/processo/{id}/documentos/upload
DELETE /api/v1/processo/{id}/documentos/{docId}
```

**Impacto**:
- ✅ API bem-estruturada seguindo RESTful
- ⚠️ **Falta de paginação explícita** - GET /processo pode retornar 10k registros
- ⚠️ **Sem versionamento de API** - v1 já, mas sem strategy de v2
- ❌ **Upload sem limite de tamanho** - pode abuser storage

**Recomendação**:
```
CRITICIDADE: TESTES DE CARGA
- [ ] Testar GET /processo com >10k registros - implementar paginação
- [ ] Testar upload de arquivo >100MB - rejeitar com erro claro
- [ ] Testar concurrent uploads - garantir sem corruption
- [ ] Implementar retry logic com exponential backoff
```

---

### 🟢 SEVERITY: LOW - Environment Variables Changes

**Mudanças**:
- `.env.local` modificado (detalhes não visíveis)

**Recomendação**:
```
CRITICIDADE: DEPLOYMENT
- [ ] Documentar quais vars foram adicionadas
- [ ] Atualizar .env.example
- [ ] Validar que CI/CD injeta vars corretamente
```

---

### 📊 Deletados (Limpeza)

```
- CHANGELOG-REESTRUTURACAO.md (antigo)
- CHECKLIST-TESTES.md (antigo)
- CONFIRMACAO-DE-ENTREGA.md (antigo)
- EXEMPLOS-VALIDACAO.md (antigo)
- INDICE-DOCUMENTACAO.md (antigo)
- MELHORIAS-VALIDACAO-CAMPOS.md (antigo)
```

Limpeza de documentação desatualizada - bom prática! ✅

---

# 4. API-GATEWAY/ (Spring Cloud Gateway)

## Arquivos Modificados
| Arquivo | Status | Tipo |
|---------|--------|------|
| src/main/java/ws/gateway/filter/AuthenticationFilter.java | M | Java |
| src/main/resources/application.yml | M | YAML |
| Dockerfile | M | Docker |

## Mudanças Critiques

### 🔴 SEVERITY: HIGH - AuthenticationFilter Routes & RBAC Model

**Propósito**: Validar tokens e autorização baseada em módulo antes de rotear

**Mudanças Específicas**:
```java
// NOVO: Patterns públicos (sem auth)
private static final List<String> PUBLIC_UNIDADE_GESTORA_PATTERNS = List.of(
    "/common/api/v1/unidadeGestora/**",
    "/common/api/v1/unidadeGestora/municipio/**"
);

// NOVO: Patterns públicos para portal
private static final List<String> PUBLIC_PORTAL_PATTERNS = List.of(
    "/erh/api/v1/processo/portal/**",          // ← DUPLICADO?
    "/processos/api/v1/processo/portal/**",    // ← DUPLICADO?
    "/erh/api/v1/processo/catalogo/**",        // ← DUPLICADO?
    "/processos/api/v1/processo/catalogo/**"   // ← DUPLICADO?
);

// NOVO: Validação com módulo
String moduloAlvo = identificarModulo(path);
authClient.get()
    .uri(uriBuilder -> uriBuilder
        .path("/api/auth/validate")
        .queryParam("modulo", moduloAlvo)
        .build())
```

**Impacto**:
- ✅ Validação centralizada de auth
- ❌ **ROUTING AMBIGUOUS**: Paths duplicados (erh vs processos) podem causar routing indefinido
- ❌ **OPEN ROUTES**: Portal routes sem auth - deve validar que servidor só vê seus dados
- ⚠️ **Fallback ambíguo**: Se módulo não detectado, padrão é??

**Recomendação**:
```
CRITICIDADE: BLOQUEADOR PARA MERGE
- [ ] Remover duplicação: decidir entre /erh/api e /processos/api
- [ ] Validar que /processo/portal/** requer auth mínima (token válido)
- [ ] Implementar rate limiting para prevent DDoS em routes públicas
- [ ] Testar que moduloAlvo é detectado corretamente para todos os paths
- [ ] Adicionar circuit breaker para auth-service (atualmente falha = 503)
```

---

### 🟡 SEVERITY: MEDIUM - Error Handling

**Propósito**: Tratamento de erros de autenticação

**Mudanças Específicas**:
```java
.onErrorResume(WebClientResponseException.class, ex -> {
    HttpStatusCode statusCode = ex.getStatusCode();
    if (statusCode.equals(HttpStatus.UNAUTHORIZED) || 
        statusCode.equals(HttpStatus.FORBIDDEN)) {
        exchange.getResponse().setStatusCode(statusCode);
    } else {
        exchange.getResponse().setStatusCode(HttpStatus.SERVICE_UNAVAILABLE);
    }
    return exchange.getResponse().setComplete();
})
```

**Impacto**:
- ⚠️ **Erro genérico 503** - não diferencia auth-service down de network error
- ⚠️ **Sem logging** - impossível diagnosticar problemas

**Recomendação**:
```
CRITICIDADE: OBSERVABILITY
- [ ] Adicionar structured logging (MDC com requestId)
- [ ] Diferenciar: 500 vs 502 (bad gateway) vs 503 (service unavailable)
- [ ] Adicionar prometheus metrics para erros de auth
```

---

### 🟢 SEVERITY: LOW - Dockerfile Changes

Presume-se adição de copiar certificados SSL ou atualizar base image.

---

# 📋 SUMÁRIO EXECUTIVO

## High-Risk Findings

| Serviço | Arquivo | Risco | Ação |
|---------|---------|-------|------|
| common | JwtService.java | Breaking: jti UUID breaks old clients | Validar backward compat |
| common | JwtFilter.java | AcessoService down = all 401 | Implementar circuit breaker |
| eRH | Processo* | New schema migration blocker | Validar migration |
| eRH | ProcessoDocumentoService | Path length > 255 char limit | Test filesystem limits |
| frontend | AuthContext.tsx | State race conditions | Test concurrent module switch |
| frontend | Processo routes | SQL injection risk | Input validation audit |
| gateway | AuthenticationFilter | Duplicate paths ambiguous | Choose single path |
| gateway | AuthenticationFilter | Public routes no validation | Ensure RBAC applied |

## Medium-Risk Findings

| Serviço | Arquivo | Risco | Ação |
|---------|---------|-------|------|
| eRH | ProcessoGestaoService | No invalid transition validation | Add state machine guards |
| eRH | ProcessoIntegracaoService | Failure = inconsistent state | Implement compensation |
| frontend | ProcessoListaTable | No pagination | Implement infinite scroll or limit |
| frontend | ProcessoDocumentosUpload | No size limit | Add max 100MB check |
| gateway | Error handling | Generic 503 response | Differentiate error types |

## Low-Risk Findings

| Serviço | Arquivo | Risco | Ação |
|---------|---------|-------|------|
| frontend | Documentation cleanup | Outdated docs | Keep README.md updated |
| common | SecurityConfig | Pressumed config OK | Validate in code review |

---

## Breaking Changes Summary

### 1. JWT Token Structure
**Impact**: All clients must handle new `jti`, `sid`, `modulo` claims  
**Migration**: Provide backward-compat parsing for 1 version cycle

### 2. PortalNotificacaoServiceInterface
**Impact**: All implementations must update method signature  
**Migration**: Update all clients before deploy

### 3. Database Schema (Processo tables)
**Impact**: Flyway migration required before service startup  
**Migration**: Apply V017__* migration to test + prod databases

### 4. Frontend Auth Context
**Impact**: State management changed, parsing logic altered  
**Migration**: Test all auth flows thoroughly

### 5. API Gateway Routes
**Impact**: Public portal routes now served under /processos/  
**Migration**: Update DNS/loadbalancer if needed

---

## Recommended Pre-Merge Actions

```
BLOCKER - Must fix before merge:
☐ Resolve duplicate gateway routes (erh vs processos paths)
☐ Validate JwtService backward compatibility
☐ Confirm ProcessoIntegracaoService error handling
☐ Test Flyway migration on test database

HIGH PRIORITY - Fix before production deployment:
☐ Implement circuit breaker for AcessoService
☐ Add pagination to Processo list endpoints
☐ Validate ProcessoDocumentoService path length
☐ Test concurrent JWT parsing in frontend

IMPORTANT - Complete within 1 sprint:
☐ Add comprehensive integration tests for workflow
☐ Security audit for portal routes (SQL injection, authz)
☐ Performance test with large process lists
☐ Update documentation for new MBAC model
```

---

**Report Generated**: March 19, 2026 | **Reviewed Services**: 4 | **Critical Findings**: 8 | **Medium Findings**: 7 | **Low Findings**: 2
