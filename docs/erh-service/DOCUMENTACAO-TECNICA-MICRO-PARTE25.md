# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 25
## Módulo de Notificações e Alertas

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar comunicações automatizadas e alertas do sistema para usuários, servidores e gestores, garantindo que informações importantes sejam entregues de forma tempestiva através de múltiplos canais.

### 1.2 Escopo
- Notificações internas (sistema)
- Alertas automáticos
- E-mail
- SMS
- Push notifications
- Vencimentos e prazos
- Templates de mensagens
- Filas de envio

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### Notificacao
```java
@Entity
@Table(name = "notificacao", indexes = {
    @Index(name = "idx_notif_destinatario", columnList = "usuario_id"),
    @Index(name = "idx_notif_data", columnList = "data_envio"),
    @Index(name = "idx_notif_status", columnList = "status")
})
public class Notificacao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @Column(name = "servidor_id")
    private Long servidorId;
    
    @Column(name = "email_destinatario", length = 200)
    private String emailDestinatario;
    
    @Column(name = "telefone_destinatario", length = 20)
    private String telefoneDestinatario;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoNotificacao tipo;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CanalNotificacao canal;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PrioridadeNotificacao prioridade;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusNotificacao status;
    
    @Column(nullable = false, length = 200)
    private String titulo;
    
    @Column(nullable = false, columnDefinition = "TEXT")
    private String mensagem;
    
    @Column(name = "mensagem_html", columnDefinition = "TEXT")
    private String mensagemHtml;
    
    @Column(name = "data_criacao", nullable = false)
    private LocalDateTime dataCriacao;
    
    @Column(name = "data_agendamento")
    private LocalDateTime dataAgendamento;
    
    @Column(name = "data_envio")
    private LocalDateTime dataEnvio;
    
    @Column(name = "data_leitura")
    private LocalDateTime dataLeitura;
    
    @Column(name = "tentativas_envio")
    private Integer tentativasEnvio = 0;
    
    @Column(name = "erro_envio", columnDefinition = "TEXT")
    private String erroEnvio;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "template_id")
    private TemplateNotificacao template;
    
    @Column(name = "parametros", columnDefinition = "TEXT")
    private String parametros; // JSON
    
    @Column(name = "link_acao", length = 500)
    private String linkAcao;
    
    @Column(name = "texto_acao", length = 100)
    private String textoAcao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "categoria")
    private CategoriaNotificacao categoria;
    
    @Column(name = "referencia_tipo", length = 50)
    private String referenciaTipo;
    
    @Column(name = "referencia_id")
    private Long referenciaId;
    
    @Column(name = "agrupador", length = 100)
    private String agrupador;
    
    @Column(name = "pode_desativar")
    private Boolean podeDesativar = true;
}
```

#### TemplateNotificacao
```java
@Entity
@Table(name = "template_notificacao")
public class TemplateNotificacao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100, unique = true)
    private String codigo;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoNotificacao tipo;
    
    @Column(name = "titulo_template", nullable = false, length = 200)
    private String tituloTemplate;
    
    @Column(name = "corpo_template", nullable = false, columnDefinition = "TEXT")
    private String corpoTemplate;
    
    @Column(name = "corpo_html", columnDefinition = "TEXT")
    private String corpoHtml;
    
    @ElementCollection
    @CollectionTable(name = "template_variaveis")
    @Column(name = "variavel")
    private Set<String> variaveis;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "canal_padrao")
    private CanalNotificacao canalPadrao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "prioridade_padrao")
    private PrioridadeNotificacao prioridadePadrao;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @Column(name = "sistema")
    private Boolean sistema = false; // Templates do sistema não podem ser excluídos
}
```

#### ConfiguracaoAlerta
```java
@Entity
@Table(name = "configuracao_alerta")
public class ConfiguracaoAlerta {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100, unique = true)
    private String codigo;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoAlerta tipoAlerta;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "template_id")
    private TemplateNotificacao template;
    
    @Column(name = "dias_antecedencia")
    private Integer diasAntecedencia;
    
    @Column(name = "repetir")
    private Boolean repetir = false;
    
    @Column(name = "intervalo_repeticao_dias")
    private Integer intervaloRepeticaoDias;
    
    @Column(name = "max_repeticoes")
    private Integer maxRepeticoes;
    
    @ElementCollection
    @Enumerated(EnumType.STRING)
    @CollectionTable(name = "alerta_canais")
    @Column(name = "canal")
    private Set<CanalNotificacao> canais;
    
    @ElementCollection
    @CollectionTable(name = "alerta_destinatarios")
    @Column(name = "perfil")
    private Set<String> perfisDestinatarios;
    
    @Column(name = "notificar_servidor")
    private Boolean notificarServidor = true;
    
    @Column(name = "notificar_gestor")
    private Boolean notificarGestor = false;
    
    @Column(name = "notificar_rh")
    private Boolean notificarRH = false;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @Column(name = "horario_envio")
    private LocalTime horarioEnvio;
    
    @Column(name = "dias_semana", length = 20)
    private String diasSemana; // "1,2,3,4,5" (seg a sex)
}
```

#### PreferenciaNotificacao
```java
@Entity
@Table(name = "preferencia_notificacao")
public class PreferenciaNotificacao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CategoriaNotificacao categoria;
    
    @Column(name = "canal_email")
    private Boolean canalEmail = true;
    
    @Column(name = "canal_sms")
    private Boolean canalSms = false;
    
    @Column(name = "canal_push")
    private Boolean canalPush = true;
    
    @Column(name = "canal_sistema")
    private Boolean canalSistema = true;
    
    @Column(name = "horario_inicio")
    private LocalTime horarioInicio;
    
    @Column(name = "horario_fim")
    private LocalTime horarioFim;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### FilaNotificacao
```java
@Entity
@Table(name = "fila_notificacao")
public class FilaNotificacao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "notificacao_id", nullable = false)
    private Notificacao notificacao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private StatusFila status;
    
    @Column(name = "data_inclusao", nullable = false)
    private LocalDateTime dataInclusao;
    
    @Column(name = "data_processamento")
    private LocalDateTime dataProcessamento;
    
    @Column(name = "prioridade")
    private Integer prioridade;
    
    @Column(name = "tentativa_atual")
    private Integer tentativaAtual = 0;
    
    @Column(name = "proxima_tentativa")
    private LocalDateTime proximaTentativa;
    
    @Column(name = "worker_id", length = 100)
    private String workerId;
}
```

#### DispositivoPush
```java
@Entity
@Table(name = "dispositivo_push")
public class DispositivoPush {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;
    
    @Column(name = "token", nullable = false, length = 500)
    private String token;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "plataforma", nullable = false)
    private PlataformaPush plataforma;
    
    @Column(name = "modelo_dispositivo", length = 100)
    private String modeloDispositivo;
    
    @Column(name = "versao_app", length = 20)
    private String versaoApp;
    
    @Column(name = "data_registro", nullable = false)
    private LocalDateTime dataRegistro;
    
    @Column(name = "ultimo_uso")
    private LocalDateTime ultimoUso;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum TipoNotificacao {
    INFORMATIVO("Informativo"),
    ALERTA("Alerta"),
    LEMBRETE("Lembrete"),
    URGENTE("Urgente"),
    SISTEMA("Sistema"),
    APROVACAO("Aprovação");
}

public enum CanalNotificacao {
    SISTEMA("Sistema Interno"),
    EMAIL("E-mail"),
    SMS("SMS"),
    PUSH("Push Notification"),
    WHATSAPP("WhatsApp");
}

public enum PrioridadeNotificacao {
    BAIXA(1),
    NORMAL(2),
    ALTA(3),
    URGENTE(4);
}

public enum StatusNotificacao {
    PENDENTE("Pendente"),
    AGENDADA("Agendada"),
    ENVIADA("Enviada"),
    ENTREGUE("Entregue"),
    LIDA("Lida"),
    FALHA("Falha"),
    CANCELADA("Cancelada");
}

public enum CategoriaNotificacao {
    FERIAS("Férias"),
    FOLHA("Folha de Pagamento"),
    PONTO("Ponto"),
    DOCUMENTOS("Documentos"),
    CAPACITACAO("Capacitação"),
    AVALIACOES("Avaliações"),
    BENEFICIOS("Benefícios"),
    PROCESSOS("Processos"),
    CADASTRO("Cadastro"),
    SEGURANCA("Segurança"),
    SISTEMA("Sistema");
}

public enum TipoAlerta {
    VENCIMENTO_FERIAS("Vencimento de Férias"),
    VENCIMENTO_CONTRATO("Vencimento de Contrato"),
    VENCIMENTO_DOCUMENTO("Vencimento de Documento"),
    PRAZO_AVALIACAO("Prazo de Avaliação"),
    ANIVERSARIO("Aniversário"),
    FECHAMENTO_FOLHA("Fechamento de Folha"),
    RECADASTRAMENTO("Recadastramento"),
    PROVA_VIDA("Prova de Vida"),
    APROVACAO_PENDENTE("Aprovação Pendente"),
    FERIAS_PROXIMAS("Férias Próximas"),
    LICENCA_EXPIRANDO("Licença Expirando");
}

public enum StatusFila {
    AGUARDANDO("Aguardando"),
    PROCESSANDO("Processando"),
    CONCLUIDO("Concluído"),
    ERRO("Erro"),
    CANCELADO("Cancelado");
}

public enum PlataformaPush {
    ANDROID("Android"),
    IOS("iOS"),
    WEB("Web");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Envio de Notificações

| Código | Regra | Descrição |
|--------|-------|-----------|
| NOT-001 | Preferências | Respeitar preferências do usuário |
| NOT-002 | Horário | Respeitar horário configurado (não disturbe) |
| NOT-003 | Retentativas | Máximo 3 tentativas para falhas |
| NOT-004 | Prioridade | Urgentes ignoram horário de silêncio |
| NOT-005 | Agrupamento | Agrupar notificações similares |

### 4.2 Alertas Automáticos

| Código | Regra | Descrição |
|--------|-------|-----------|
| ALT-001 | Férias | Alertar 60, 30, 15 dias antes do vencimento |
| ALT-002 | Contratos | Alertar 90, 60, 30 dias antes do término |
| ALT-003 | Documentos | Alertar vencimento de documentos obrigatórios |
| ALT-004 | Avaliações | Alertar prazos de avaliação de desempenho |
| ALT-005 | Recadastramento | Alertar período de recadastramento |

### 4.3 Templates

| Código | Regra | Descrição |
|--------|-------|-----------|
| TPL-001 | Variáveis | Validar variáveis obrigatórias |
| TPL-002 | HTML | Sanitizar HTML para segurança |
| TPL-003 | Sistema | Templates do sistema são imutáveis |
| TPL-004 | Personalização | Permitir personalização por órgão |

### 4.4 Canais

| Código | Regra | Descrição |
|--------|-------|-----------|
| CAN-001 | Email | Validar formato de e-mail |
| CAN-002 | SMS | Máximo 160 caracteres |
| CAN-003 | Push | Dispositivo deve estar ativo |
| CAN-004 | Fallback | Se falhar, tentar próximo canal |

---

## 5. TEMPLATES PADRÃO

### 5.1 Templates do Sistema

```java
// Férias - Vencimento
FERIAS_VENCIMENTO:
  titulo: "Alerta: Férias próximas do vencimento"
  corpo: """
    Prezado(a) ${servidor.nome},
    
    Suas férias referentes ao período aquisitivo ${ferias.periodoAquisitivo} 
    vencem em ${ferias.diasParaVencer} dias (${ferias.dataVencimento}).
    
    Providencie o agendamento junto à sua chefia.
    
    Atenciosamente,
    Departamento de Recursos Humanos
  """

// Folha - Disponível
FOLHA_DISPONIVEL:
  titulo: "Contracheque disponível - ${competencia}"
  corpo: """
    Prezado(a) ${servidor.nome},
    
    O contracheque referente à competência ${competencia} está disponível 
    para consulta no portal do servidor.
    
    Valor líquido: ${valorLiquido}
    
    Acesse: ${linkPortal}
  """

// Aprovação Pendente
APROVACAO_PENDENTE:
  titulo: "Solicitação aguardando aprovação"
  corpo: """
    Prezado(a) ${gestor.nome},
    
    Existe uma solicitação de ${tipoSolicitacao} aguardando sua aprovação:
    
    Servidor: ${servidor.nome}
    Data: ${dataSolicitacao}
    Detalhes: ${detalhes}
    
    Acesse o sistema para aprovar ou rejeitar.
  """

// Recadastramento
RECADASTRAMENTO_CONVOCACAO:
  titulo: "Convocação para Recadastramento ${ano}"
  corpo: """
    Prezado(a) ${servidor.nome},
    
    Você está convocado para o Recadastramento Funcional ${ano}.
    
    Período: ${dataInicio} a ${dataFim}
    Local: ${local}
    
    Documentos necessários:
    ${listaDocumentos}
    
    O não comparecimento poderá acarretar suspensão do pagamento.
  """
```

---

## 6. SERVIÇOS

### 6.1 NotificacaoService
```java
@Service
@Transactional
public class NotificacaoService {
    
    @Autowired
    private NotificacaoRepository repository;
    
    @Autowired
    private TemplateEngine templateEngine;
    
    @Autowired
    private PreferenciaNotificacaoRepository preferenciaRepository;
    
    @Autowired
    private FilaNotificacaoRepository filaRepository;
    
    public Notificacao enviar(NotificacaoDTO dto) {
        // Validar preferências do usuário
        PreferenciaNotificacao preferencia = verificarPreferencias(dto.getUsuarioId(), dto.getCategoria());
        
        if (preferencia != null && !preferencia.getAtivo()) {
            if (dto.getPrioridade() != PrioridadeNotificacao.URGENTE) {
                log.info("Notificação bloqueada por preferência do usuário");
                return null;
            }
        }
        
        // Verificar horário de silêncio
        if (!podeEnviarNoHorario(preferencia, dto.getPrioridade())) {
            // Agendar para próximo horário permitido
            dto.setDataAgendamento(calcularProximoHorarioPermitido(preferencia));
        }
        
        Notificacao notificacao = criarNotificacao(dto);
        
        // Processar template se houver
        if (dto.getTemplateId() != null) {
            processarTemplate(notificacao, dto.getParametros());
        }
        
        notificacao = repository.save(notificacao);
        
        // Adicionar à fila de envio
        adicionarFila(notificacao);
        
        return notificacao;
    }
    
    public void enviarParaGrupo(NotificacaoGrupoDTO dto) {
        List<Usuario> usuarios = buscarUsuariosPorCriterio(dto.getCriterio());
        
        for (Usuario usuario : usuarios) {
            NotificacaoDTO notifDTO = dto.toNotificacaoDTO();
            notifDTO.setUsuarioId(usuario.getId());
            notifDTO.setEmailDestinatario(usuario.getEmail());
            enviar(notifDTO);
        }
    }
    
    private void processarTemplate(Notificacao notificacao, Map<String, Object> parametros) {
        TemplateNotificacao template = notificacao.getTemplate();
        
        // Validar variáveis obrigatórias
        for (String variavel : template.getVariaveis()) {
            if (!parametros.containsKey(variavel)) {
                throw new NotificacaoException("Variável obrigatória não fornecida: " + variavel);
            }
        }
        
        // Processar título
        String titulo = templateEngine.process(template.getTituloTemplate(), parametros);
        notificacao.setTitulo(titulo);
        
        // Processar corpo
        String corpo = templateEngine.process(template.getCorpoTemplate(), parametros);
        notificacao.setMensagem(corpo);
        
        // Processar HTML se existir
        if (template.getCorpoHtml() != null) {
            String html = templateEngine.process(template.getCorpoHtml(), parametros);
            notificacao.setMensagemHtml(html);
        }
    }
    
    public void marcarComoLida(Long id) {
        Notificacao notificacao = repository.findById(id).orElseThrow();
        notificacao.setStatus(StatusNotificacao.LIDA);
        notificacao.setDataLeitura(LocalDateTime.now());
        repository.save(notificacao);
    }
    
    public List<NotificacaoDTO> buscarNaoLidas(Long usuarioId) {
        return repository.findByUsuarioIdAndStatus(usuarioId, StatusNotificacao.ENTREGUE)
            .stream()
            .map(this::toDTO)
            .collect(Collectors.toList());
    }
    
    public long contarNaoLidas(Long usuarioId) {
        return repository.countByUsuarioIdAndStatusIn(
            usuarioId, 
            Arrays.asList(StatusNotificacao.ENVIADA, StatusNotificacao.ENTREGUE)
        );
    }
}
```

### 6.2 AlertaService
```java
@Service
@Transactional
public class AlertaService {
    
    @Autowired
    private ConfiguracaoAlertaRepository configRepository;
    
    @Autowired
    private NotificacaoService notificacaoService;
    
    @Scheduled(cron = "0 0 7 * * MON-FRI") // 7h de segunda a sexta
    public void processarAlertasVencimentoFerias() {
        ConfiguracaoAlerta config = configRepository.findByCodigo("FERIAS_VENCIMENTO").orElse(null);
        if (config == null || !config.getAtivo()) return;
        
        List<Ferias> feriasProximasVencer = feriasRepository.findProximasVencer(
            LocalDate.now().plusDays(config.getDiasAntecedencia())
        );
        
        for (Ferias ferias : feriasProximasVencer) {
            long diasParaVencer = ChronoUnit.DAYS.between(LocalDate.now(), ferias.getDataVencimento());
            
            if (deveEnviarAlerta(ferias, diasParaVencer, config)) {
                enviarAlertaFerias(ferias, diasParaVencer, config);
            }
        }
    }
    
    @Scheduled(cron = "0 0 8 * * MON-FRI")
    public void processarAlertasVencimentoContrato() {
        ConfiguracaoAlerta config = configRepository.findByCodigo("CONTRATO_VENCIMENTO").orElse(null);
        if (config == null || !config.getAtivo()) return;
        
        List<Servidor> contratosVencendo = servidorRepository
            .findContratosVencendoEm(config.getDiasAntecedencia());
        
        for (Servidor servidor : contratosVencendo) {
            long diasParaVencer = ChronoUnit.DAYS.between(
                LocalDate.now(), 
                servidor.getDataFimContrato()
            );
            
            enviarAlertaContrato(servidor, diasParaVencer, config);
        }
    }
    
    @Scheduled(cron = "0 0 6 * * *") // Todo dia às 6h
    public void processarAlertasAniversario() {
        ConfiguracaoAlerta config = configRepository.findByCodigo("ANIVERSARIO").orElse(null);
        if (config == null || !config.getAtivo()) return;
        
        List<Servidor> aniversariantes = servidorRepository.findAniversariantes(LocalDate.now());
        
        for (Servidor servidor : aniversariantes) {
            enviarAlertaAniversario(servidor, config);
        }
        
        // Notificar gestores sobre aniversariantes da equipe
        if (config.getNotificarGestor()) {
            notificarGestoresSobreAniversariantes(aniversariantes);
        }
    }
    
    @Scheduled(cron = "0 0 9 * * MON") // Segunda às 9h
    public void processarAlertasAprovacoesPendentes() {
        List<Usuario> gestores = usuarioRepository.findByPerfilIn(Arrays.asList("GESTOR", "DIRETOR"));
        
        for (Usuario gestor : gestores) {
            long aprovacoesPendentes = solicitacaoRepository
                .countPendentesByAprovador(gestor.getId());
            
            if (aprovacoesPendentes > 0) {
                notificacaoService.enviar(NotificacaoDTO.builder()
                    .usuarioId(gestor.getId())
                    .tipo(TipoNotificacao.LEMBRETE)
                    .categoria(CategoriaNotificacao.PROCESSOS)
                    .titulo("Você tem " + aprovacoesPendentes + " aprovações pendentes")
                    .mensagem("Existem solicitações aguardando sua análise. Acesse o sistema para aprovar ou rejeitar.")
                    .prioridade(PrioridadeNotificacao.ALTA)
                    .linkAcao("/aprovacoes/pendentes")
                    .build());
            }
        }
    }
    
    private void enviarAlertaFerias(Ferias ferias, long diasParaVencer, ConfiguracaoAlerta config) {
        Map<String, Object> params = Map.of(
            "servidor", ferias.getServidor(),
            "ferias", ferias,
            "diasParaVencer", diasParaVencer
        );
        
        // Notificar servidor
        if (config.getNotificarServidor()) {
            notificacaoService.enviar(NotificacaoDTO.builder()
                .usuarioId(ferias.getServidor().getUsuario().getId())
                .templateId(config.getTemplate().getId())
                .parametros(params)
                .categoria(CategoriaNotificacao.FERIAS)
                .prioridade(diasParaVencer <= 15 ? PrioridadeNotificacao.ALTA : PrioridadeNotificacao.NORMAL)
                .build());
        }
        
        // Notificar gestor
        if (config.getNotificarGestor() && ferias.getServidor().getChefeImediato() != null) {
            notificacaoService.enviar(NotificacaoDTO.builder()
                .usuarioId(ferias.getServidor().getChefeImediato().getUsuario().getId())
                .titulo("Férias de servidor próximas do vencimento")
                .mensagem(String.format(
                    "As férias do servidor %s vencem em %d dias",
                    ferias.getServidor().getNome(), diasParaVencer
                ))
                .categoria(CategoriaNotificacao.FERIAS)
                .prioridade(PrioridadeNotificacao.NORMAL)
                .build());
        }
    }
}
```

### 6.3 EnvioEmailService
```java
@Service
public class EnvioEmailService {
    
    @Autowired
    private JavaMailSender mailSender;
    
    @Value("${mail.from}")
    private String emailRemetente;
    
    @Value("${mail.from.name}")
    private String nomeRemetente;
    
    @Async
    public CompletableFuture<Boolean> enviar(Notificacao notificacao) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            
            helper.setFrom(new InternetAddress(emailRemetente, nomeRemetente));
            helper.setTo(notificacao.getEmailDestinatario());
            helper.setSubject(notificacao.getTitulo());
            
            // Prioridade
            if (notificacao.getPrioridade() == PrioridadeNotificacao.URGENTE) {
                message.setHeader("X-Priority", "1");
                message.setHeader("Importance", "high");
            }
            
            // Corpo HTML ou texto
            if (notificacao.getMensagemHtml() != null) {
                helper.setText(notificacao.getMensagem(), notificacao.getMensagemHtml());
            } else {
                helper.setText(notificacao.getMensagem());
            }
            
            mailSender.send(message);
            
            log.info("Email enviado com sucesso para: {}", notificacao.getEmailDestinatario());
            return CompletableFuture.completedFuture(true);
            
        } catch (Exception e) {
            log.error("Erro ao enviar email", e);
            return CompletableFuture.completedFuture(false);
        }
    }
}
```

### 6.4 EnvioSMSService
```java
@Service
public class EnvioSMSService {
    
    @Value("${sms.provider.url}")
    private String providerUrl;
    
    @Value("${sms.provider.apiKey}")
    private String apiKey;
    
    @Autowired
    private RestTemplate restTemplate;
    
    public boolean enviar(Notificacao notificacao) {
        try {
            String mensagem = notificacao.getMensagem();
            
            // Limitar a 160 caracteres
            if (mensagem.length() > 160) {
                mensagem = mensagem.substring(0, 157) + "...";
            }
            
            Map<String, Object> payload = Map.of(
                "to", notificacao.getTelefoneDestinatario(),
                "message", mensagem,
                "apiKey", apiKey
            );
            
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(payload, headers);
            
            ResponseEntity<Map> response = restTemplate.postForEntity(
                providerUrl + "/send", request, Map.class
            );
            
            return response.getStatusCode().is2xxSuccessful();
            
        } catch (Exception e) {
            log.error("Erro ao enviar SMS", e);
            return false;
        }
    }
}
```

### 6.5 PushNotificationService
```java
@Service
public class PushNotificationService {
    
    @Autowired
    private DispositivoPushRepository dispositivoRepository;
    
    @Autowired
    private FirebaseMessaging firebaseMessaging;
    
    public void enviar(Notificacao notificacao) {
        List<DispositivoPush> dispositivos = dispositivoRepository
            .findByUsuarioIdAndAtivo(notificacao.getUsuario().getId(), true);
        
        for (DispositivoPush dispositivo : dispositivos) {
            try {
                Message message = Message.builder()
                    .setToken(dispositivo.getToken())
                    .setNotification(Notification.builder()
                        .setTitle(notificacao.getTitulo())
                        .setBody(notificacao.getMensagem())
                        .build())
                    .putData("notificacaoId", notificacao.getId().toString())
                    .putData("categoria", notificacao.getCategoria().name())
                    .putData("linkAcao", notificacao.getLinkAcao())
                    .build();
                
                String response = firebaseMessaging.send(message);
                log.info("Push enviado: {}", response);
                
                // Atualizar último uso
                dispositivo.setUltimoUso(LocalDateTime.now());
                dispositivoRepository.save(dispositivo);
                
            } catch (FirebaseMessagingException e) {
                if (e.getMessagingErrorCode() == MessagingErrorCode.UNREGISTERED) {
                    // Token inválido, desativar dispositivo
                    dispositivo.setAtivo(false);
                    dispositivoRepository.save(dispositivo);
                }
                log.error("Erro ao enviar push notification", e);
            }
        }
    }
}
```

### 6.6 FilaProcessorService
```java
@Service
public class FilaProcessorService {
    
    @Autowired
    private FilaNotificacaoRepository filaRepository;
    
    @Autowired
    private EnvioEmailService emailService;
    
    @Autowired
    private EnvioSMSService smsService;
    
    @Autowired
    private PushNotificationService pushService;
    
    @Scheduled(fixedDelay = 5000) // A cada 5 segundos
    public void processarFila() {
        List<FilaNotificacao> pendentes = filaRepository
            .findTop100ByStatusAndProximaTentativaBeforeOrderByPrioridadeDesc(
                StatusFila.AGUARDANDO, 
                LocalDateTime.now()
            );
        
        for (FilaNotificacao item : pendentes) {
            processarItem(item);
        }
    }
    
    @Transactional
    private void processarItem(FilaNotificacao item) {
        item.setStatus(StatusFila.PROCESSANDO);
        item.setDataProcessamento(LocalDateTime.now());
        item.setWorkerId(getWorkerId());
        item.setTentativaAtual(item.getTentativaAtual() + 1);
        filaRepository.save(item);
        
        Notificacao notificacao = item.getNotificacao();
        boolean sucesso = false;
        String erro = null;
        
        try {
            sucesso = enviarPorCanal(notificacao);
        } catch (Exception e) {
            erro = e.getMessage();
            log.error("Erro ao processar notificação {}", notificacao.getId(), e);
        }
        
        if (sucesso) {
            item.setStatus(StatusFila.CONCLUIDO);
            notificacao.setStatus(StatusNotificacao.ENVIADA);
            notificacao.setDataEnvio(LocalDateTime.now());
        } else {
            // Verificar se deve tentar novamente
            if (item.getTentativaAtual() < 3) {
                item.setStatus(StatusFila.AGUARDANDO);
                item.setProximaTentativa(calcularProximaTentativa(item.getTentativaAtual()));
            } else {
                item.setStatus(StatusFila.ERRO);
                notificacao.setStatus(StatusNotificacao.FALHA);
                notificacao.setErroEnvio(erro);
            }
            notificacao.setTentativasEnvio(item.getTentativaAtual());
        }
        
        filaRepository.save(item);
        notificacaoRepository.save(notificacao);
    }
    
    private boolean enviarPorCanal(Notificacao notificacao) {
        switch (notificacao.getCanal()) {
            case EMAIL:
                return emailService.enviar(notificacao).join();
            case SMS:
                return smsService.enviar(notificacao);
            case PUSH:
                pushService.enviar(notificacao);
                return true;
            case SISTEMA:
                return true; // Notificação interna não precisa envio
            default:
                return false;
        }
    }
    
    private LocalDateTime calcularProximaTentativa(int tentativa) {
        // Backoff exponencial: 1min, 5min, 15min
        int minutosEspera = (int) Math.pow(5, tentativa - 1);
        return LocalDateTime.now().plusMinutes(minutosEspera);
    }
}
```

---

## 7. API REST

### 7.1 Endpoints

```
# Notificações
GET    /api/v1/notificacoes                              # Lista notificações
GET    /api/v1/notificacoes/{id}                         # Busca notificação
PUT    /api/v1/notificacoes/{id}/lida                    # Marcar como lida
PUT    /api/v1/notificacoes/marcar-todas-lidas           # Marcar todas como lidas
GET    /api/v1/notificacoes/nao-lidas                    # Não lidas
GET    /api/v1/notificacoes/nao-lidas/count              # Contador

# Preferências
GET    /api/v1/notificacoes/preferencias                 # Lista preferências
PUT    /api/v1/notificacoes/preferencias                 # Atualiza preferências
PUT    /api/v1/notificacoes/preferencias/{categoria}     # Atualiza por categoria

# Dispositivos Push
POST   /api/v1/notificacoes/dispositivos                 # Registrar dispositivo
DELETE /api/v1/notificacoes/dispositivos/{id}            # Remover dispositivo

# Administração
GET    /api/v1/admin/notificacoes/templates              # Lista templates
POST   /api/v1/admin/notificacoes/templates              # Criar template
PUT    /api/v1/admin/notificacoes/templates/{id}         # Atualizar template
GET    /api/v1/admin/notificacoes/alertas/config         # Configurações alertas
PUT    /api/v1/admin/notificacoes/alertas/config/{id}    # Atualizar config
POST   /api/v1/admin/notificacoes/enviar-massa           # Envio em massa
GET    /api/v1/admin/notificacoes/estatisticas           # Estatísticas
```

---

## 8. FRONTEND

### 8.1 Componentes React

```typescript
// NotificationCenter.tsx
interface NotificationCenterProps {
  onNotificationClick?: (notification: Notification) => void;
}

export const NotificationCenter: React.FC<NotificationCenterProps> = ({
  onNotificationClick
}) => {
  const { data: notifications, refetch } = useNotifications();
  const { data: unreadCount } = useUnreadCount();
  const markAsRead = useMarkAsRead();
  
  return (
    <Popover>
      <PopoverTrigger>
        <Button variant="ghost" className="relative">
          <Bell className="h-5 w-5" />
          {unreadCount > 0 && (
            <Badge className="absolute -top-1 -right-1">
              {unreadCount > 99 ? '99+' : unreadCount}
            </Badge>
          )}
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-80">
        <div className="flex justify-between items-center mb-4">
          <h4 className="font-semibold">Notificações</h4>
          <Button variant="link" size="sm" onClick={() => markAllAsRead()}>
            Marcar todas como lidas
          </Button>
        </div>
        <ScrollArea className="h-96">
          {notifications?.map((notification) => (
            <NotificationItem
              key={notification.id}
              notification={notification}
              onClick={() => handleClick(notification)}
            />
          ))}
        </ScrollArea>
      </PopoverContent>
    </Popover>
  );
};

// NotificationItem.tsx
export const NotificationItem: React.FC<{
  notification: Notification;
  onClick: () => void;
}> = ({ notification, onClick }) => {
  const getPriorityColor = () => {
    switch (notification.prioridade) {
      case 'URGENTE': return 'border-l-red-500';
      case 'ALTA': return 'border-l-orange-500';
      default: return 'border-l-blue-500';
    }
  };
  
  return (
    <div
      className={cn(
        "p-3 border-l-4 cursor-pointer hover:bg-gray-50",
        getPriorityColor(),
        !notification.lida && "bg-blue-50"
      )}
      onClick={onClick}
    >
      <div className="flex items-start gap-2">
        <NotificationIcon tipo={notification.tipo} />
        <div className="flex-1">
          <p className="font-medium text-sm">{notification.titulo}</p>
          <p className="text-xs text-gray-500 line-clamp-2">
            {notification.mensagem}
          </p>
          <p className="text-xs text-gray-400 mt-1">
            {formatDistanceToNow(notification.dataCriacao, { locale: ptBR })}
          </p>
        </div>
      </div>
    </div>
  );
};
```

### 8.2 Preferências de Notificação

```typescript
// NotificationPreferences.tsx
export const NotificationPreferences: React.FC = () => {
  const { data: preferences, isLoading } = usePreferences();
  const updatePreference = useUpdatePreference();
  
  const categorias = [
    { key: 'FERIAS', label: 'Férias', icon: Calendar },
    { key: 'FOLHA', label: 'Folha de Pagamento', icon: DollarSign },
    { key: 'PONTO', label: 'Ponto', icon: Clock },
    { key: 'DOCUMENTOS', label: 'Documentos', icon: FileText },
    { key: 'CAPACITACAO', label: 'Capacitação', icon: GraduationCap },
  ];
  
  return (
    <Card>
      <CardHeader>
        <CardTitle>Preferências de Notificação</CardTitle>
        <CardDescription>
          Configure como deseja receber notificações
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Categoria</TableHead>
              <TableHead className="text-center">Sistema</TableHead>
              <TableHead className="text-center">E-mail</TableHead>
              <TableHead className="text-center">SMS</TableHead>
              <TableHead className="text-center">Push</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {categorias.map((cat) => {
              const pref = preferences?.find(p => p.categoria === cat.key);
              return (
                <TableRow key={cat.key}>
                  <TableCell className="flex items-center gap-2">
                    <cat.icon className="h-4 w-4" />
                    {cat.label}
                  </TableCell>
                  <TableCell className="text-center">
                    <Switch
                      checked={pref?.canalSistema ?? true}
                      onCheckedChange={(v) => updatePreference.mutate({
                        categoria: cat.key,
                        canalSistema: v
                      })}
                    />
                  </TableCell>
                  <TableCell className="text-center">
                    <Switch
                      checked={pref?.canalEmail ?? true}
                      onCheckedChange={(v) => updatePreference.mutate({
                        categoria: cat.key,
                        canalEmail: v
                      })}
                    />
                  </TableCell>
                  <TableCell className="text-center">
                    <Switch
                      checked={pref?.canalSms ?? false}
                      onCheckedChange={(v) => updatePreference.mutate({
                        categoria: cat.key,
                        canalSms: v
                      })}
                    />
                  </TableCell>
                  <TableCell className="text-center">
                    <Switch
                      checked={pref?.canalPush ?? true}
                      onCheckedChange={(v) => updatePreference.mutate({
                        categoria: cat.key,
                        canalPush: v
                      })}
                    />
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};
```

---

## 9. WEBSOCKET (Tempo Real)

```java
@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic", "/queue");
        config.setApplicationDestinationPrefixes("/app");
        config.setUserDestinationPrefix("/user");
    }
    
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").withSockJS();
    }
}

@Service
public class WebSocketNotificationService {
    
    @Autowired
    private SimpMessagingTemplate messagingTemplate;
    
    public void enviarNotificacaoUsuario(Long usuarioId, NotificacaoDTO notificacao) {
        messagingTemplate.convertAndSendToUser(
            usuarioId.toString(),
            "/queue/notifications",
            notificacao
        );
    }
    
    public void enviarNotificacaoBroadcast(NotificacaoDTO notificacao) {
        messagingTemplate.convertAndSend("/topic/notifications", notificacao);
    }
}
```
