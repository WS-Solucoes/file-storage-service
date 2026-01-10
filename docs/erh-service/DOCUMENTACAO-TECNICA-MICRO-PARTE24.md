# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 24
## Módulo de Auditoria e Logs

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Rastrear todas as alterações realizadas no sistema, mantendo histórico completo de operações para fins de auditoria, conformidade legal e segurança da informação.

### 1.2 Escopo
- Logs de auditoria (quem, quando, o quê)
- Histórico de alterações de entidades
- Rastreamento de acessos
- Logs de segurança
- Relatórios de auditoria
- Conformidade LGPD
- Retenção e arquivamento

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### AuditLog
```java
@Entity
@Table(name = "audit_log", indexes = {
    @Index(name = "idx_audit_entidade", columnList = "entidade_tipo, entidade_id"),
    @Index(name = "idx_audit_usuario", columnList = "usuario_id"),
    @Index(name = "idx_audit_data", columnList = "data_hora"),
    @Index(name = "idx_audit_acao", columnList = "acao")
})
public class AuditLog {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "entidade_tipo", nullable = false, length = 100)
    private String entidadeTipo;
    
    @Column(name = "entidade_id", nullable = false)
    private Long entidadeId;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private AcaoAuditoria acao;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @Column(name = "usuario_nome", length = 200)
    private String usuarioNome;
    
    @Column(name = "usuario_login", length = 100)
    private String usuarioLogin;
    
    @Column(name = "ip_address", length = 50)
    private String ipAddress;
    
    @Column(name = "user_agent", length = 500)
    private String userAgent;
    
    @Column(name = "session_id", length = 100)
    private String sessionId;
    
    @Column(name = "request_id", length = 100)
    private String requestId;
    
    @Column(name = "endpoint", length = 500)
    private String endpoint;
    
    @Column(name = "metodo_http", length = 10)
    private String metodoHttp;
    
    @Column(name = "dados_anteriores", columnDefinition = "TEXT")
    private String dadosAnteriores; // JSON
    
    @Column(name = "dados_novos", columnDefinition = "TEXT")
    private String dadosNovos; // JSON
    
    @Column(name = "campos_alterados", columnDefinition = "TEXT")
    private String camposAlterados; // JSON array
    
    @Column(name = "descricao", columnDefinition = "TEXT")
    private String descricao;
    
    @Column(name = "sucesso")
    private Boolean sucesso = true;
    
    @Column(name = "mensagem_erro", columnDefinition = "TEXT")
    private String mensagemErro;
    
    @Column(name = "tempo_execucao_ms")
    private Long tempoExecucaoMs;
    
    // Contexto adicional
    @Column(name = "servidor_id")
    private Long servidorId;
    
    @Column(name = "servidor_nome", length = 200)
    private String servidorNome;
    
    @Column(name = "modulo", length = 50)
    private String modulo;
    
    @Column(name = "funcionalidade", length = 100)
    private String funcionalidade;
}
```

#### AuditLogDetalhe
```java
@Entity
@Table(name = "audit_log_detalhe")
public class AuditLogDetalhe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "audit_log_id", nullable = false)
    private AuditLog auditLog;
    
    @Column(name = "campo", nullable = false, length = 100)
    private String campo;
    
    @Column(name = "valor_anterior", columnDefinition = "TEXT")
    private String valorAnterior;
    
    @Column(name = "valor_novo", columnDefinition = "TEXT")
    private String valorNovo;
    
    @Column(name = "tipo_dado", length = 50)
    private String tipoDado;
}
```

#### LogAcesso
```java
@Entity
@Table(name = "log_acesso", indexes = {
    @Index(name = "idx_acesso_usuario", columnList = "usuario_id"),
    @Index(name = "idx_acesso_data", columnList = "data_hora")
})
public class LogAcesso {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @Column(name = "usuario_login", length = 100)
    private String usuarioLogin;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_evento", nullable = false)
    private TipoEventoAcesso tipoEvento;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @Column(name = "ip_address", length = 50)
    private String ipAddress;
    
    @Column(name = "user_agent", length = 500)
    private String userAgent;
    
    @Column(name = "dispositivo", length = 200)
    private String dispositivo;
    
    @Column(name = "navegador", length = 100)
    private String navegador;
    
    @Column(name = "sistema_operacional", length = 100)
    private String sistemaOperacional;
    
    @Column(name = "localizacao", length = 200)
    private String localizacao;
    
    @Column(name = "latitude", precision = 10, scale = 7)
    private BigDecimal latitude;
    
    @Column(name = "longitude", precision = 10, scale = 7)
    private BigDecimal longitude;
    
    @Column(name = "sucesso")
    private Boolean sucesso = true;
    
    @Column(name = "motivo_falha", length = 500)
    private String motivoFalha;
    
    @Column(name = "session_id", length = 100)
    private String sessionId;
    
    @Column(name = "duracao_sessao_minutos")
    private Integer duracaoSessaoMinutos;
}
```

#### LogSeguranca
```java
@Entity
@Table(name = "log_seguranca")
public class LogSeguranca {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_evento", nullable = false)
    private TipoEventoSeguranca tipoEvento;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private NivelSeveridade severidade;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @Column(name = "ip_address", length = 50)
    private String ipAddress;
    
    @Column(name = "descricao", nullable = false, columnDefinition = "TEXT")
    private String descricao;
    
    @Column(name = "detalhes", columnDefinition = "TEXT")
    private String detalhes; // JSON
    
    @Column(name = "recurso_afetado", length = 200)
    private String recursoAfetado;
    
    @Column(name = "acao_tomada", length = 500)
    private String acaoTomada;
    
    @Column(name = "resolvido")
    private Boolean resolvido = false;
    
    @Column(name = "data_resolucao")
    private LocalDateTime dataResolucao;
    
    @ManyToOne
    @JoinColumn(name = "resolvido_por")
    private Usuario resolvidoPor;
    
    @Column(name = "observacao_resolucao", columnDefinition = "TEXT")
    private String observacaoResolucao;
}
```

#### LogDadosPessoais (LGPD)
```java
@Entity
@Table(name = "log_dados_pessoais")
public class LogDadosPessoais {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "titular_tipo", nullable = false, length = 50)
    private String titularTipo; // SERVIDOR, APOSENTADO, PENSIONISTA, DEPENDENTE
    
    @Column(name = "titular_id", nullable = false)
    private Long titularId;
    
    @Column(name = "titular_cpf", length = 14)
    private String titularCpf;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_operacao", nullable = false)
    private TipoOperacaoLGPD tipoOperacao;
    
    @Column(name = "data_hora", nullable = false)
    private LocalDateTime dataHora;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @Column(name = "finalidade", length = 500)
    private String finalidade;
    
    @Column(name = "base_legal", length = 200)
    private String baseLegal;
    
    @Column(name = "dados_acessados", columnDefinition = "TEXT")
    private String dadosAcessados; // JSON - campos acessados
    
    @Column(name = "ip_address", length = 50)
    private String ipAddress;
    
    @Column(name = "sistema_origem", length = 100)
    private String sistemaOrigem;
}
```

#### ConfiguracaoAuditoria
```java
@Entity
@Table(name = "configuracao_auditoria")
public class ConfiguracaoAuditoria {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "entidade", nullable = false, length = 100, unique = true)
    private String entidade;
    
    @Column(name = "auditar_criacao")
    private Boolean auditarCriacao = true;
    
    @Column(name = "auditar_atualizacao")
    private Boolean auditarAtualizacao = true;
    
    @Column(name = "auditar_exclusao")
    private Boolean auditarExclusao = true;
    
    @Column(name = "auditar_leitura")
    private Boolean auditarLeitura = false;
    
    @Column(name = "campos_sensiveis", columnDefinition = "TEXT")
    private String camposSensiveis; // JSON array - campos a mascarar
    
    @Column(name = "campos_ignorados", columnDefinition = "TEXT")
    private String camposIgnorados; // JSON array - campos a não auditar
    
    @Column(name = "prazo_retencao_dias")
    private Integer prazoRetencaoDias = 365 * 5; // 5 anos
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum AcaoAuditoria {
    CRIAR("Criação"),
    ATUALIZAR("Atualização"),
    EXCLUIR("Exclusão"),
    VISUALIZAR("Visualização"),
    EXPORTAR("Exportação"),
    IMPORTAR("Importação"),
    APROVAR("Aprovação"),
    REJEITAR("Rejeição"),
    CANCELAR("Cancelamento"),
    REVERTER("Reversão"),
    PROCESSAR("Processamento"),
    CALCULAR("Cálculo"),
    ENVIAR("Envio"),
    ASSINAR("Assinatura");
}

public enum TipoEventoAcesso {
    LOGIN("Login"),
    LOGOUT("Logout"),
    LOGIN_FALHA("Tentativa de Login Falha"),
    SESSAO_EXPIRADA("Sessão Expirada"),
    TROCA_SENHA("Troca de Senha"),
    RESET_SENHA("Reset de Senha"),
    BLOQUEIO_CONTA("Bloqueio de Conta"),
    DESBLOQUEIO_CONTA("Desbloqueio de Conta"),
    SEGUNDO_FATOR("Autenticação Segundo Fator");
}

public enum TipoEventoSeguranca {
    TENTATIVA_ACESSO_NAO_AUTORIZADO("Tentativa de Acesso Não Autorizado"),
    ALTERACAO_PERMISSAO("Alteração de Permissão"),
    ACESSO_DADOS_SENSIVEIS("Acesso a Dados Sensíveis"),
    EXPORTACAO_MASSA("Exportação em Massa"),
    MULTIPLAS_FALHAS_LOGIN("Múltiplas Falhas de Login"),
    ACESSO_IP_SUSPEITO("Acesso de IP Suspeito"),
    ALTERACAO_CRITICA("Alteração Crítica de Dados"),
    SQL_INJECTION("Tentativa de SQL Injection"),
    XSS_DETECTADO("Tentativa de XSS"),
    ALTERACAO_FOLHA("Alteração em Folha Fechada");
}

public enum NivelSeveridade {
    BAIXA("Baixa"),
    MEDIA("Média"),
    ALTA("Alta"),
    CRITICA("Crítica");
}

public enum TipoOperacaoLGPD {
    COLETA("Coleta"),
    ACESSO("Acesso"),
    PROCESSAMENTO("Processamento"),
    ARMAZENAMENTO("Armazenamento"),
    COMPARTILHAMENTO("Compartilhamento"),
    ELIMINACAO("Eliminação"),
    RETIFICACAO("Retificação"),
    ANONIMIZACAO("Anonimização"),
    EXPORTACAO("Exportação");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Auditoria

| Código | Regra | Descrição |
|--------|-------|-----------|
| AUD-001 | Obrigatória | Toda alteração em entidades críticas deve ser auditada |
| AUD-002 | Imutável | Logs de auditoria não podem ser alterados ou excluídos |
| AUD-003 | Completa | Registrar antes e depois da alteração |
| AUD-004 | Identificada | Sempre identificar usuário responsável |
| AUD-005 | Temporal | Registrar data/hora precisa (com fuso) |

### 4.2 Segurança

| Código | Regra | Descrição |
|--------|-------|-----------|
| SEG-001 | Falhas Login | Bloquear após 5 tentativas falhas |
| SEG-002 | IP Suspeito | Alertar sobre IPs em blacklist |
| SEG-003 | Horário | Alertar acessos fora do horário comercial |
| SEG-004 | Massa | Alertar sobre operações em massa |
| SEG-005 | Crítico | Notificar imediatamente eventos críticos |

### 4.3 LGPD

| Código | Regra | Descrição |
|--------|-------|-----------|
| LGPD-001 | Consentimento | Registrar base legal para tratamento |
| LGPD-002 | Finalidade | Documentar finalidade do acesso |
| LGPD-003 | Minimização | Registrar apenas dados necessários |
| LGPD-004 | Retenção | Respeitar prazos de retenção |
| LGPD-005 | Direitos | Permitir extração para direitos do titular |

### 4.4 Retenção

| Código | Regra | Descrição |
|--------|-------|-----------|
| RET-001 | Mínimo | Mínimo 5 anos para logs de auditoria |
| RET-002 | Acesso | Logs de acesso por 1 ano |
| RET-003 | Segurança | Logs de segurança por 5 anos |
| RET-004 | Arquivar | Arquivar antes de eliminar |

---

## 5. IMPLEMENTAÇÃO

### 5.1 Aspect de Auditoria
```java
@Aspect
@Component
@Slf4j
public class AuditAspect {
    
    @Autowired
    private AuditService auditService;
    
    @Autowired
    private HttpServletRequest request;
    
    @Around("@annotation(auditar)")
    public Object auditarOperacao(ProceedingJoinPoint joinPoint, Auditar auditar) throws Throwable {
        LocalDateTime inicio = LocalDateTime.now();
        AuditContext context = criarContexto(joinPoint, auditar);
        
        Object resultado = null;
        boolean sucesso = true;
        String mensagemErro = null;
        
        try {
            // Capturar estado anterior se for atualização
            if (auditar.acao() == AcaoAuditoria.ATUALIZAR) {
                context.setDadosAnteriores(capturarEstadoAtual(joinPoint, auditar));
            }
            
            resultado = joinPoint.proceed();
            
            // Capturar estado novo
            context.setDadosNovos(capturarNovoEstado(resultado, joinPoint, auditar));
            
        } catch (Exception e) {
            sucesso = false;
            mensagemErro = e.getMessage();
            throw e;
        } finally {
            context.setSucesso(sucesso);
            context.setMensagemErro(mensagemErro);
            context.setTempoExecucaoMs(Duration.between(inicio, LocalDateTime.now()).toMillis());
            
            auditService.registrar(context);
        }
        
        return resultado;
    }
    
    private AuditContext criarContexto(ProceedingJoinPoint joinPoint, Auditar auditar) {
        AuditContext context = new AuditContext();
        context.setAcao(auditar.acao());
        context.setEntidadeTipo(auditar.entidade());
        context.setModulo(auditar.modulo());
        context.setFuncionalidade(joinPoint.getSignature().getName());
        context.setDataHora(LocalDateTime.now());
        context.setUsuario(SecurityContextHolder.getContext().getAuthentication());
        context.setIpAddress(getClientIpAddress(request));
        context.setUserAgent(request.getHeader("User-Agent"));
        context.setEndpoint(request.getRequestURI());
        context.setMetodoHttp(request.getMethod());
        context.setRequestId(MDC.get("requestId"));
        context.setSessionId(request.getSession().getId());
        
        return context;
    }
}
```

### 5.2 Entity Listener
```java
@Component
public class AuditEntityListener {
    
    private static AuditService auditService;
    
    @Autowired
    public void setAuditService(AuditService auditService) {
        AuditEntityListener.auditService = auditService;
    }
    
    @PrePersist
    public void prePersist(Object entity) {
        if (isAuditavel(entity)) {
            auditService.registrarAsync(entity, AcaoAuditoria.CRIAR, null, entity);
        }
    }
    
    @PreUpdate
    public void preUpdate(Object entity) {
        if (isAuditavel(entity)) {
            Object estadoAnterior = buscarEstadoAnterior(entity);
            auditService.registrarAsync(entity, AcaoAuditoria.ATUALIZAR, estadoAnterior, entity);
        }
    }
    
    @PreRemove
    public void preRemove(Object entity) {
        if (isAuditavel(entity)) {
            auditService.registrarAsync(entity, AcaoAuditoria.EXCLUIR, entity, null);
        }
    }
    
    private boolean isAuditavel(Object entity) {
        return entity.getClass().isAnnotationPresent(Auditavel.class);
    }
}
```

### 5.3 Anotação Personalizada
```java
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Auditar {
    AcaoAuditoria acao();
    String entidade();
    String modulo() default "";
    boolean registrarDados() default true;
}

@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface Auditavel {
    String[] camposSensiveis() default {};
    String[] camposIgnorados() default {};
}
```

---

## 6. SERVIÇOS

### 6.1 AuditService
```java
@Service
@Transactional
public class AuditService {
    
    @Autowired
    private AuditLogRepository auditLogRepository;
    
    @Autowired
    private ObjectMapper objectMapper;
    
    @Autowired
    private ConfiguracaoAuditoriaRepository configRepository;
    
    public AuditLog registrar(AuditContext context) {
        ConfiguracaoAuditoria config = configRepository.findByEntidade(context.getEntidadeTipo())
            .orElse(getConfigPadrao());
        
        // Verificar se deve auditar esta ação
        if (!deveAuditar(context.getAcao(), config)) {
            return null;
        }
        
        AuditLog log = new AuditLog();
        log.setEntidadeTipo(context.getEntidadeTipo());
        log.setEntidadeId(context.getEntidadeId());
        log.setAcao(context.getAcao());
        log.setDataHora(context.getDataHora());
        log.setUsuario(context.getUsuario());
        log.setUsuarioNome(context.getUsuarioNome());
        log.setUsuarioLogin(context.getUsuarioLogin());
        log.setIpAddress(context.getIpAddress());
        log.setUserAgent(context.getUserAgent());
        log.setSessionId(context.getSessionId());
        log.setRequestId(context.getRequestId());
        log.setEndpoint(context.getEndpoint());
        log.setMetodoHttp(context.getMetodoHttp());
        log.setModulo(context.getModulo());
        log.setFuncionalidade(context.getFuncionalidade());
        log.setSucesso(context.getSucesso());
        log.setMensagemErro(context.getMensagemErro());
        log.setTempoExecucaoMs(context.getTempoExecucaoMs());
        
        // Processar dados antes e depois
        if (context.getDadosAnteriores() != null) {
            String dadosAnteriores = serializarComMascara(context.getDadosAnteriores(), config);
            log.setDadosAnteriores(dadosAnteriores);
        }
        
        if (context.getDadosNovos() != null) {
            String dadosNovos = serializarComMascara(context.getDadosNovos(), config);
            log.setDadosNovos(dadosNovos);
        }
        
        // Calcular campos alterados
        if (context.getAcao() == AcaoAuditoria.ATUALIZAR) {
            List<String> camposAlterados = calcularCamposAlterados(
                context.getDadosAnteriores(), context.getDadosNovos(), config
            );
            log.setCamposAlterados(objectMapper.writeValueAsString(camposAlterados));
            
            // Criar detalhes por campo
            salvarDetalhes(log, context.getDadosAnteriores(), context.getDadosNovos(), config);
        }
        
        return auditLogRepository.save(log);
    }
    
    @Async
    public void registrarAsync(Object entidade, AcaoAuditoria acao, Object antes, Object depois) {
        AuditContext context = new AuditContext();
        context.setEntidadeTipo(entidade.getClass().getSimpleName());
        context.setEntidadeId(getEntityId(entidade));
        context.setAcao(acao);
        context.setDadosAnteriores(antes);
        context.setDadosNovos(depois);
        context.setDataHora(LocalDateTime.now());
        
        // Capturar contexto de segurança
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth != null && auth.getPrincipal() instanceof UserDetails) {
            UserDetails user = (UserDetails) auth.getPrincipal();
            context.setUsuarioLogin(user.getUsername());
        }
        
        registrar(context);
    }
    
    private String serializarComMascara(Object dados, ConfiguracaoAuditoria config) {
        try {
            Map<String, Object> mapa = objectMapper.convertValue(dados, Map.class);
            
            // Mascarar campos sensíveis
            if (config.getCamposSensiveis() != null) {
                List<String> sensiveis = objectMapper.readValue(
                    config.getCamposSensiveis(), new TypeReference<List<String>>() {}
                );
                for (String campo : sensiveis) {
                    if (mapa.containsKey(campo)) {
                        mapa.put(campo, "***MASKED***");
                    }
                }
            }
            
            // Remover campos ignorados
            if (config.getCamposIgnorados() != null) {
                List<String> ignorados = objectMapper.readValue(
                    config.getCamposIgnorados(), new TypeReference<List<String>>() {}
                );
                for (String campo : ignorados) {
                    mapa.remove(campo);
                }
            }
            
            return objectMapper.writeValueAsString(mapa);
        } catch (Exception e) {
            log.error("Erro ao serializar dados para auditoria", e);
            return "{}";
        }
    }
}
```

### 6.2 LogAcessoService
```java
@Service
@Transactional
public class LogAcessoService {
    
    @Autowired
    private LogAcessoRepository repository;
    
    @Autowired
    private GeoIPService geoIPService;
    
    public LogAcesso registrarLogin(Usuario usuario, HttpServletRequest request, boolean sucesso, String motivoFalha) {
        LogAcesso log = new LogAcesso();
        log.setUsuario(usuario);
        log.setUsuarioLogin(usuario != null ? usuario.getLogin() : request.getParameter("username"));
        log.setTipoEvento(sucesso ? TipoEventoAcesso.LOGIN : TipoEventoAcesso.LOGIN_FALHA);
        log.setDataHora(LocalDateTime.now());
        log.setIpAddress(getClientIpAddress(request));
        log.setUserAgent(request.getHeader("User-Agent"));
        log.setSucesso(sucesso);
        log.setMotivoFalha(motivoFalha);
        
        // Parsear User-Agent
        UserAgent userAgent = UserAgent.parseUserAgentString(request.getHeader("User-Agent"));
        log.setNavegador(userAgent.getBrowser().getName());
        log.setSistemaOperacional(userAgent.getOperatingSystem().getName());
        log.setDispositivo(userAgent.getOperatingSystem().getDeviceType().getName());
        
        // Geolocalização por IP
        try {
            GeoLocation location = geoIPService.getLocation(log.getIpAddress());
            log.setLocalizacao(location.getCity() + ", " + location.getCountry());
            log.setLatitude(location.getLatitude());
            log.setLongitude(location.getLongitude());
        } catch (Exception e) {
            log.warn("Não foi possível obter geolocalização para IP: {}", log.getIpAddress());
        }
        
        return repository.save(log);
    }
    
    public void registrarLogout(Usuario usuario, String sessionId, HttpServletRequest request) {
        LogAcesso log = new LogAcesso();
        log.setUsuario(usuario);
        log.setUsuarioLogin(usuario.getLogin());
        log.setTipoEvento(TipoEventoAcesso.LOGOUT);
        log.setDataHora(LocalDateTime.now());
        log.setIpAddress(getClientIpAddress(request));
        log.setSessionId(sessionId);
        log.setSucesso(true);
        
        // Calcular duração da sessão
        LogAcesso loginLog = repository.findUltimoLoginPorSessao(sessionId);
        if (loginLog != null) {
            long minutos = Duration.between(loginLog.getDataHora(), log.getDataHora()).toMinutes();
            log.setDuracaoSessaoMinutos((int) minutos);
        }
        
        repository.save(log);
    }
    
    public void verificarAcessoSuspeito(LogAcesso logAtual) {
        // Verificar múltiplas falhas de login
        long falhasRecentes = repository.countFalhasRecentes(
            logAtual.getUsuarioLogin(), 
            LocalDateTime.now().minusMinutes(30)
        );
        
        if (falhasRecentes >= 5) {
            logSegurancaService.registrar(
                TipoEventoSeguranca.MULTIPLAS_FALHAS_LOGIN,
                NivelSeveridade.ALTA,
                "Múltiplas falhas de login detectadas: " + falhasRecentes + " tentativas",
                logAtual.getUsuarioLogin(),
                logAtual.getIpAddress()
            );
        }
        
        // Verificar IP em blacklist
        if (ipBlacklistService.isBlacklisted(logAtual.getIpAddress())) {
            logSegurancaService.registrar(
                TipoEventoSeguranca.ACESSO_IP_SUSPEITO,
                NivelSeveridade.CRITICA,
                "Acesso de IP em blacklist",
                logAtual.getUsuarioLogin(),
                logAtual.getIpAddress()
            );
        }
        
        // Verificar horário suspeito
        int hora = logAtual.getDataHora().getHour();
        if (hora < 6 || hora > 22) {
            logSegurancaService.registrar(
                TipoEventoSeguranca.ACESSO_IP_SUSPEITO,
                NivelSeveridade.MEDIA,
                "Acesso fora do horário comercial",
                logAtual.getUsuarioLogin(),
                logAtual.getIpAddress()
            );
        }
    }
}
```

### 6.3 LogSegurancaService
```java
@Service
@Transactional
public class LogSegurancaService {
    
    @Autowired
    private LogSegurancaRepository repository;
    
    @Autowired
    private NotificacaoService notificacaoService;
    
    public LogSeguranca registrar(TipoEventoSeguranca tipo, NivelSeveridade severidade,
                                  String descricao, String usuario, String ip) {
        LogSeguranca log = new LogSeguranca();
        log.setTipoEvento(tipo);
        log.setSeveridade(severidade);
        log.setDescricao(descricao);
        log.setDataHora(LocalDateTime.now());
        log.setIpAddress(ip);
        
        if (usuario != null) {
            log.setUsuario(usuarioRepository.findByLogin(usuario).orElse(null));
        }
        
        log = repository.save(log);
        
        // Notificar se severidade alta ou crítica
        if (severidade == NivelSeveridade.ALTA || severidade == NivelSeveridade.CRITICA) {
            notificarEquipeSeguranca(log);
        }
        
        return log;
    }
    
    private void notificarEquipeSeguranca(LogSeguranca log) {
        List<Usuario> equipeSeguranca = usuarioRepository.findByPerfilNome("ADMIN_SEGURANCA");
        
        for (Usuario admin : equipeSeguranca) {
            notificacaoService.enviar(
                admin,
                "Alerta de Segurança - " + log.getSeveridade(),
                String.format(
                    "Evento: %s\nDescrição: %s\nIP: %s\nData/Hora: %s",
                    log.getTipoEvento().getDescricao(),
                    log.getDescricao(),
                    log.getIpAddress(),
                    log.getDataHora()
                ),
                TipoNotificacao.EMAIL,
                PrioridadeNotificacao.URGENTE
            );
        }
    }
    
    public void marcarResolvido(Long logId, String observacao) {
        LogSeguranca log = repository.findById(logId).orElseThrow();
        log.setResolvido(true);
        log.setDataResolucao(LocalDateTime.now());
        log.setResolvidoPor(getUsuarioLogado());
        log.setObservacaoResolucao(observacao);
        repository.save(log);
    }
}
```

### 6.4 LGPDService
```java
@Service
@Transactional
public class LGPDService {
    
    @Autowired
    private LogDadosPessoaisRepository repository;
    
    public void registrarAcessoDadosPessoais(String titularTipo, Long titularId, 
                                              String finalidade, String baseLegal,
                                              List<String> camposAcessados) {
        LogDadosPessoais log = new LogDadosPessoais();
        log.setTitularTipo(titularTipo);
        log.setTitularId(titularId);
        log.setTipoOperacao(TipoOperacaoLGPD.ACESSO);
        log.setDataHora(LocalDateTime.now());
        log.setUsuario(getUsuarioLogado());
        log.setFinalidade(finalidade);
        log.setBaseLegal(baseLegal);
        log.setDadosAcessados(objectMapper.writeValueAsString(camposAcessados));
        log.setIpAddress(getClientIpAddress());
        log.setSistemaOrigem("eRH");
        
        // Buscar CPF do titular
        log.setTitularCpf(buscarCpfTitular(titularTipo, titularId));
        
        repository.save(log);
    }
    
    public RelatorioLGPD gerarRelatorioTitular(String cpf) {
        // LGPD-005: Direito de acesso do titular
        List<LogDadosPessoais> logs = repository.findByTitularCpf(cpf);
        
        RelatorioLGPD relatorio = new RelatorioLGPD();
        relatorio.setCpfTitular(cpf);
        relatorio.setDataGeracao(LocalDateTime.now());
        relatorio.setTotalAcessos(logs.size());
        
        // Agrupar por tipo de operação
        Map<TipoOperacaoLGPD, Long> porTipo = logs.stream()
            .collect(Collectors.groupingBy(LogDadosPessoais::getTipoOperacao, Collectors.counting()));
        relatorio.setAcessosPorTipo(porTipo);
        
        // Listar todos os acessos
        relatorio.setDetalhes(logs.stream()
            .map(this::converterParaDTO)
            .collect(Collectors.toList()));
        
        return relatorio;
    }
    
    public void executarDireitoEsquecimento(String cpf) {
        // Anonimizar dados pessoais conforme permitido por lei
        // Nota: Alguns dados devem ser mantidos por obrigação legal
        
        logDadosPessoaisService.registrar(
            "TITULAR", buscarIdPorCpf(cpf), 
            TipoOperacaoLGPD.ANONIMIZACAO,
            "Exercício do direito ao esquecimento pelo titular"
        );
    }
}
```

---

## 7. API REST

### 7.1 Endpoints

```
# Logs de Auditoria
GET    /api/v1/auditoria/logs                            # Lista logs
GET    /api/v1/auditoria/logs/{id}                       # Busca log
GET    /api/v1/auditoria/logs/entidade/{tipo}/{id}       # Logs por entidade
GET    /api/v1/auditoria/logs/usuario/{id}               # Logs por usuário
GET    /api/v1/auditoria/logs/exportar                   # Exportar logs

# Logs de Acesso
GET    /api/v1/auditoria/acessos                         # Lista acessos
GET    /api/v1/auditoria/acessos/usuario/{id}            # Acessos por usuário
GET    /api/v1/auditoria/acessos/sessoes-ativas          # Sessões ativas

# Logs de Segurança
GET    /api/v1/auditoria/seguranca                       # Lista eventos
GET    /api/v1/auditoria/seguranca/{id}                  # Busca evento
PUT    /api/v1/auditoria/seguranca/{id}/resolver         # Marcar resolvido
GET    /api/v1/auditoria/seguranca/pendentes             # Eventos pendentes
GET    /api/v1/auditoria/seguranca/dashboard             # Dashboard segurança

# LGPD
GET    /api/v1/auditoria/lgpd/titular/{cpf}              # Relatório titular
POST   /api/v1/auditoria/lgpd/esquecimento/{cpf}         # Direito esquecimento
GET    /api/v1/auditoria/lgpd/exportar/{cpf}             # Exportar dados titular

# Configurações
GET    /api/v1/auditoria/configuracoes                   # Lista configurações
PUT    /api/v1/auditoria/configuracoes/{entidade}        # Atualiza config

# Histórico de Entidade
GET    /api/v1/servidores/{id}/historico                 # Histórico servidor
GET    /api/v1/folhas/{id}/historico                     # Histórico folha
```

---

## 8. RELATÓRIOS

### 8.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| Trilha de Auditoria | Histórico completo de alterações | Entidade, Período |
| Acessos por Usuário | Logins e atividades | Usuário, Período |
| Eventos de Segurança | Incidentes detectados | Severidade, Período |
| Operações em Folha | Alterações em folha | Competência |
| Acessos a Dados Pessoais | Conformidade LGPD | Titular, Período |
| Sessões Ativas | Usuários conectados | Data/Hora |
| Falhas de Login | Tentativas malsucedidas | Período |

---

## 9. CONSIDERAÇÕES DE IMPLEMENTAÇÃO

### 9.1 Performance
- Usar tabelas particionadas por data
- Índices em campos de busca frequente
- Arquivar logs antigos
- Processamento assíncrono

### 9.2 Armazenamento
- Compressão de dados JSON
- Rotação de logs
- Backup automático
- Retenção configurável

### 9.3 Segurança
- Logs imutáveis (append-only)
- Acesso restrito aos logs
- Criptografia de dados sensíveis
- Integridade verificável
