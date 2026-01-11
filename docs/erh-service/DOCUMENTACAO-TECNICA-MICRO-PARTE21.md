# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 21
## Módulo de Cessão e Requisição de Servidores

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar o processo de cessão e requisição de servidores públicos entre órgãos, controlando ônus, prazos, reembolsos e a situação funcional durante o afastamento.

### 1.2 Escopo
- Cessão de servidores (saída)
- Requisição de servidores (entrada)
- Controle de ônus (cedente/cessionário)
- Gestão de termos e convênios
- Prorrogações e revogações
- Controle financeiro de reembolsos
- Integração com folha de pagamento

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### Cessao
```java
@Entity
@Table(name = "cessao")
public class Cessao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id")
    private Vinculo vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_movimentacao", nullable = false)
    private TipoMovimentacaoServidor tipoMovimentacao;
    
    @Column(name = "numero_processo", length = 50)
    private String numeroProcesso;
    
    @Column(name = "numero_portaria", length = 50)
    private String numeroPortaria;
    
    @Column(name = "data_portaria")
    private LocalDate dataPortaria;
    
    @Column(name = "data_publicacao_doe")
    private LocalDate dataPublicacaoDOE;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "data_retorno")
    private LocalDate dataRetorno;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoCessao situacao;
    
    // Órgão de destino (para cessão) / origem (para requisição)
    @ManyToOne
    @JoinColumn(name = "orgao_externo_id")
    private OrgaoExterno orgaoExterno;
    
    @Column(name = "orgao_nome", length = 200)
    private String orgaoNome;
    
    @Column(name = "orgao_cnpj", length = 14)
    private String orgaoCnpj;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "esfera_orgao")
    private EsferaOrgao esferaOrgao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_onus", nullable = false)
    private TipoOnus tipoOnus;
    
    @Column(name = "percentual_reembolso", precision = 5, scale = 2)
    private BigDecimal percentualReembolso;
    
    @Column(name = "cargo_exercido", length = 200)
    private String cargoExercido;
    
    @Column(name = "funcao_exercida", length = 200)
    private String funcaoExercida;
    
    @Column(name = "fundamentacao_legal", columnDefinition = "TEXT")
    private String fundamentacaoLegal;
    
    @Column(name = "motivo", columnDefinition = "TEXT")
    private String motivo;
    
    @Column(columnDefinition = "TEXT")
    private String observacao;
    
    @ManyToOne
    @JoinColumn(name = "convenio_id")
    private ConvenioCessao convenio;
    
    @OneToMany(mappedBy = "cessao", cascade = CascadeType.ALL)
    private List<ProrrogacaoCessao> prorrogacoes = new ArrayList<>();
    
    @OneToMany(mappedBy = "cessao", cascade = CascadeType.ALL)
    private List<ReembolsoCessao> reembolsos = new ArrayList<>();
    
    // Auditoria
    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;
    
    @ManyToOne
    @JoinColumn(name = "criado_por")
    private Usuario criadoPor;
}
```

#### OrgaoExterno
```java
@Entity
@Table(name = "orgao_externo")
public class OrgaoExterno {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(length = 100)
    private String sigla;
    
    @Column(nullable = false, length = 14)
    private String cnpj;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "esfera", nullable = false)
    private EsferaOrgao esfera;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "poder")
    private PoderOrgao poder;
    
    @Column(length = 100)
    private String uf;
    
    @Column(length = 100)
    private String municipio;
    
    @Column(length = 200)
    private String endereco;
    
    @Column(length = 20)
    private String telefone;
    
    @Column(length = 100)
    private String email;
    
    @Column(name = "responsavel_nome", length = 200)
    private String responsavelNome;
    
    @Column(name = "responsavel_cargo", length = 100)
    private String responsavelCargo;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### ConvenioCessao
```java
@Entity
@Table(name = "convenio_cessao")
public class ConvenioCessao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50)
    private String numero;
    
    @Column(nullable = false, length = 200)
    private String objeto;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "orgao_externo_id")
    private OrgaoExterno orgaoExterno;
    
    @Column(name = "data_assinatura")
    private LocalDate dataAssinatura;
    
    @Column(name = "data_publicacao")
    private LocalDate dataPublicacao;
    
    @Column(name = "data_vigencia_inicio")
    private LocalDate dataVigenciaInicio;
    
    @Column(name = "data_vigencia_fim")
    private LocalDate dataVigenciaFim;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoConvenio situacao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_onus_padrao")
    private TipoOnus tipoOnusPadrao;
    
    @Column(name = "quantidade_vagas")
    private Integer quantidadeVagas;
    
    @Column(columnDefinition = "TEXT")
    private String clausulas;
    
    @Column(name = "arquivo_path", length = 500)
    private String arquivoPath;
    
    @OneToMany(mappedBy = "convenio")
    private List<Cessao> cessoes = new ArrayList<>();
}
```

#### ProrrogacaoCessao
```java
@Entity
@Table(name = "prorrogacao_cessao")
public class ProrrogacaoCessao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cessao_id", nullable = false)
    private Cessao cessao;
    
    @Column(name = "numero_prorrogacao", nullable = false)
    private Integer numeroProrrogacao;
    
    @Column(name = "data_inicio_anterior", nullable = false)
    private LocalDate dataInicioAnterior;
    
    @Column(name = "data_fim_anterior", nullable = false)
    private LocalDate dataFimAnterior;
    
    @Column(name = "nova_data_fim", nullable = false)
    private LocalDate novaDataFim;
    
    @Column(name = "numero_portaria", length = 50)
    private String numeroPortaria;
    
    @Column(name = "data_portaria")
    private LocalDate dataPortaria;
    
    @Column(name = "numero_processo", length = 50)
    private String numeroProcesso;
    
    @Column(columnDefinition = "TEXT")
    private String justificativa;
    
    @Column(name = "data_registro")
    private LocalDateTime dataRegistro;
}
```

#### ReembolsoCessao
```java
@Entity
@Table(name = "reembolso_cessao")
public class ReembolsoCessao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cessao_id", nullable = false)
    private Cessao cessao;
    
    @Column(name = "competencia", nullable = false)
    private YearMonth competencia;
    
    @Column(name = "valor_remuneracao", precision = 15, scale = 2)
    private BigDecimal valorRemuneracao;
    
    @Column(name = "valor_encargos", precision = 15, scale = 2)
    private BigDecimal valorEncargos;
    
    @Column(name = "valor_total", nullable = false, precision = 15, scale = 2)
    private BigDecimal valorTotal;
    
    @Column(name = "percentual_aplicado", precision = 5, scale = 2)
    private BigDecimal percentualAplicado;
    
    @Column(name = "valor_reembolso", nullable = false, precision = 15, scale = 2)
    private BigDecimal valorReembolso;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoReembolso situacao;
    
    @Column(name = "data_geracao")
    private LocalDate dataGeracao;
    
    @Column(name = "data_cobranca")
    private LocalDate dataCobranca;
    
    @Column(name = "data_pagamento")
    private LocalDate dataPagamento;
    
    @Column(name = "numero_documento", length = 50)
    private String numeroDocumento;
    
    @Column(name = "numero_gru", length = 50)
    private String numeroGRU;
    
    @Column(columnDefinition = "TEXT")
    private String observacao;
}
```

#### HistoricoCessao
```java
@Entity
@Table(name = "historico_cessao")
public class HistoricoCessao {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "cessao_id", nullable = false)
    private Cessao cessao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao_anterior")
    private SituacaoCessao situacaoAnterior;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao_nova", nullable = false)
    private SituacaoCessao situacaoNova;
    
    @Column(name = "data_alteracao", nullable = false)
    private LocalDateTime dataAlteracao;
    
    @ManyToOne
    @JoinColumn(name = "usuario_id")
    private Usuario usuario;
    
    @Column(columnDefinition = "TEXT")
    private String motivo;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum TipoMovimentacaoServidor {
    CESSAO("Cessão"),           // Servidor SAI do órgão
    REQUISICAO("Requisição");   // Servidor ENTRA no órgão
}

public enum SituacaoCessao {
    SOLICITADA("Solicitada"),
    EM_ANALISE("Em Análise"),
    AUTORIZADA("Autorizada"),
    ATIVA("Ativa"),
    SUSPENSA("Suspensa"),
    ENCERRADA("Encerrada"),
    REVOGADA("Revogada"),
    INDEFERIDA("Indeferida");
}

public enum TipoOnus {
    CEDENTE("Ônus para o Cedente"),
    CESSIONARIO("Ônus para o Cessionário"),
    COMPARTILHADO("Ônus Compartilhado"),
    SEM_ONUS("Sem Ônus para Nenhuma das Partes");
}

public enum EsferaOrgao {
    FEDERAL("Federal"),
    ESTADUAL("Estadual"),
    MUNICIPAL("Municipal"),
    DISTRITAL("Distrital");
}

public enum PoderOrgao {
    EXECUTIVO("Executivo"),
    LEGISLATIVO("Legislativo"),
    JUDICIARIO("Judiciário"),
    MINISTERIO_PUBLICO("Ministério Público"),
    DEFENSORIA("Defensoria Pública"),
    TRIBUNAL_CONTAS("Tribunal de Contas");
}

public enum SituacaoConvenio {
    VIGENTE("Vigente"),
    VENCIDO("Vencido"),
    RESCINDIDO("Rescindido"),
    SUSPENSO("Suspenso");
}

public enum SituacaoReembolso {
    PENDENTE("Pendente"),
    GERADO("Gerado"),
    COBRADO("Cobrado"),
    PAGO("Pago"),
    CANCELADO("Cancelado");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Cessão de Servidores

| Código | Regra | Descrição |
|--------|-------|-----------|
| CES-001 | Vínculo Ativo | Apenas servidor com vínculo ativo pode ser cedido |
| CES-002 | Estágio Probatório | Servidor em estágio probatório não pode ser cedido |
| CES-003 | Processo PAD | Servidor com PAD em andamento não pode ser cedido |
| CES-004 | Portaria | Toda cessão exige portaria de autorização |
| CES-005 | Prazo Máximo | Cessão por prazo determinado, com prorrogações |
| CES-006 | Retorno | Servidor deve retornar ao encerrar cessão |

### 4.2 Requisição de Servidores

| Código | Regra | Descrição |
|--------|-------|-----------|
| REQ-001 | Necessidade | Deve justificar necessidade do serviço |
| REQ-002 | Convênio | Preferencialmente vinculada a convênio |
| REQ-003 | Vaga | Não ocupa vaga do quadro de pessoal |
| REQ-004 | Reembolso | Controlar reembolso conforme tipo de ônus |

### 4.3 Controle de Ônus

| Código | Regra | Descrição |
|--------|-------|-----------|
| ONS-001 | Cedente | Ônus cedente = município continua pagando |
| ONS-002 | Cessionário | Ônus cessionário = órgão destino paga e reembolsa |
| ONS-003 | Compartilhado | Percentual definido no termo de cessão |
| ONS-004 | Encargos | Reembolso inclui encargos patronais |

### 4.4 Reembolsos

| Código | Regra | Descrição |
|--------|-------|-----------|
| RMB-001 | Mensal | Gerar cobrança mensal de reembolso |
| RMB-002 | Prazo | Pagamento até dia 10 do mês seguinte |
| RMB-003 | GRU | Reembolso via GRU (Guia de Recolhimento) |
| RMB-004 | Inadimplência | Notificar após 30 dias de atraso |

---

## 5. FLUXOS DE TRABALHO

### 5.1 Fluxo de Cessão
```
1. Solicitação de cessão (órgão interessado)
2. Análise RH (verificar impedimentos)
3. Parecer jurídico
4. Autorização autoridade competente
5. Emissão de portaria
6. Publicação no DOE
7. Início da cessão
8. Acompanhamento periódico
9. Prorrogação (se necessário)
10. Encerramento/Retorno
```

### 5.2 Fluxo de Requisição
```
1. Identificação da necessidade
2. Solicitação ao órgão de origem
3. Negociação de ônus
4. Termo de cessão
5. Portaria de autorização
6. Entrada em exercício
7. Controle de reembolsos
8. Renovação ou encerramento
```

---

## 6. SERVIÇOS

### 6.1 CessaoService
```java
@Service
@Transactional
public class CessaoService {
    
    @Autowired
    private CessaoRepository cessaoRepository;
    
    @Autowired
    private ServidorRepository servidorRepository;
    
    @Autowired
    private VinculoRepository vinculoRepository;
    
    public Cessao registrarCessao(CessaoDTO dto) {
        Servidor servidor = servidorRepository.findById(dto.getServidorId()).orElseThrow();
        
        // Validações (CES-001 a CES-003)
        validarElegibilidadeCessao(servidor);
        
        Cessao cessao = new Cessao();
        cessao.setServidor(servidor);
        cessao.setVinculo(servidor.getVinculoAtivo());
        cessao.setTipoMovimentacao(TipoMovimentacaoServidor.CESSAO);
        cessao.setNumeroProcesso(dto.getNumeroProcesso());
        cessao.setDataInicio(dto.getDataInicio());
        cessao.setDataFim(dto.getDataFim());
        cessao.setTipoOnus(dto.getTipoOnus());
        cessao.setPercentualReembolso(dto.getPercentualReembolso());
        cessao.setSituacao(SituacaoCessao.SOLICITADA);
        
        // Órgão destino
        if (dto.getOrgaoExternoId() != null) {
            cessao.setOrgaoExterno(orgaoExternoRepository.findById(dto.getOrgaoExternoId()).orElseThrow());
        } else {
            cessao.setOrgaoNome(dto.getOrgaoNome());
            cessao.setOrgaoCnpj(dto.getOrgaoCnpj());
            cessao.setEsferaOrgao(dto.getEsferaOrgao());
        }
        
        cessao.setCargoExercido(dto.getCargoExercido());
        cessao.setFundamentacaoLegal(dto.getFundamentacaoLegal());
        cessao.setMotivo(dto.getMotivo());
        cessao.setDataCriacao(LocalDateTime.now());
        
        return cessaoRepository.save(cessao);
    }
    
    public void autorizarCessao(Long cessaoId, AutorizacaoDTO dto) {
        Cessao cessao = cessaoRepository.findById(cessaoId).orElseThrow();
        
        cessao.setSituacao(SituacaoCessao.AUTORIZADA);
        cessao.setNumeroPortaria(dto.getNumeroPortaria());
        cessao.setDataPortaria(dto.getDataPortaria());
        
        cessaoRepository.save(cessao);
        
        // Registra histórico
        registrarHistorico(cessao, SituacaoCessao.SOLICITADA, SituacaoCessao.AUTORIZADA, "Autorização");
    }
    
    public void iniciarCessao(Long cessaoId) {
        Cessao cessao = cessaoRepository.findById(cessaoId).orElseThrow();
        
        if (cessao.getSituacao() != SituacaoCessao.AUTORIZADA) {
            throw new BusinessException("Cessão não está autorizada");
        }
        
        cessao.setSituacao(SituacaoCessao.ATIVA);
        cessaoRepository.save(cessao);
        
        // Atualiza situação do vínculo
        Vinculo vinculo = cessao.getVinculo();
        vinculo.setSituacao(SituacaoVinculo.CEDIDO);
        vinculoRepository.save(vinculo);
        
        // Se ônus do cessionário, suspende folha
        if (cessao.getTipoOnus() == TipoOnus.CESSIONARIO) {
            suspenderFolhaServidor(cessao.getServidor().getId());
        }
        
        registrarHistorico(cessao, SituacaoCessao.AUTORIZADA, SituacaoCessao.ATIVA, "Início da cessão");
    }
    
    public void encerrarCessao(Long cessaoId, LocalDate dataRetorno) {
        Cessao cessao = cessaoRepository.findById(cessaoId).orElseThrow();
        
        cessao.setSituacao(SituacaoCessao.ENCERRADA);
        cessao.setDataRetorno(dataRetorno);
        cessaoRepository.save(cessao);
        
        // Restaura situação do vínculo
        Vinculo vinculo = cessao.getVinculo();
        vinculo.setSituacao(SituacaoVinculo.ATIVO);
        vinculoRepository.save(vinculo);
        
        // Reativa folha se necessário
        if (cessao.getTipoOnus() == TipoOnus.CESSIONARIO) {
            reativarFolhaServidor(cessao.getServidor().getId());
        }
        
        registrarHistorico(cessao, SituacaoCessao.ATIVA, SituacaoCessao.ENCERRADA, "Encerramento da cessão");
    }
    
    private void validarElegibilidadeCessao(Servidor servidor) {
        // CES-001: Vínculo ativo
        if (servidor.getVinculoAtivo() == null) {
            throw new BusinessException("Servidor não possui vínculo ativo");
        }
        
        // CES-002: Estágio probatório
        if (servidor.isEmEstagioProbatorio()) {
            throw new BusinessException("Servidor em estágio probatório não pode ser cedido");
        }
        
        // CES-003: PAD em andamento
        if (processoAdministrativoRepository.existsAtivoPorServidor(servidor.getId())) {
            throw new BusinessException("Servidor com processo administrativo em andamento");
        }
        
        // Verifica se já está cedido
        if (cessaoRepository.existsAtivaPorServidor(servidor.getId())) {
            throw new BusinessException("Servidor já possui cessão ativa");
        }
    }
}
```

### 6.2 RequisicaoService
```java
@Service
@Transactional
public class RequisicaoService {
    
    public Cessao registrarRequisicao(RequisicaoDTO dto) {
        Cessao requisicao = new Cessao();
        requisicao.setTipoMovimentacao(TipoMovimentacaoServidor.REQUISICAO);
        requisicao.setNumeroProcesso(dto.getNumeroProcesso());
        requisicao.setDataInicio(dto.getDataInicio());
        requisicao.setDataFim(dto.getDataFim());
        requisicao.setTipoOnus(dto.getTipoOnus());
        requisicao.setPercentualReembolso(dto.getPercentualReembolso());
        requisicao.setSituacao(SituacaoCessao.SOLICITADA);
        
        // Órgão de origem
        if (dto.getOrgaoExternoId() != null) {
            requisicao.setOrgaoExterno(orgaoExternoRepository.findById(dto.getOrgaoExternoId()).orElseThrow());
        }
        
        // Dados do servidor requisitado
        requisicao.setOrgaoNome(dto.getNomeServidorRequisitado());
        requisicao.setCargoExercido(dto.getCargoOrigem());
        requisicao.setFuncaoExercida(dto.getFuncaoDestino());
        requisicao.setMotivo(dto.getJustificativa());
        
        // Vincula ao convênio se existir
        if (dto.getConvenioId() != null) {
            requisicao.setConvenio(convenioRepository.findById(dto.getConvenioId()).orElseThrow());
        }
        
        return cessaoRepository.save(requisicao);
    }
    
    public void vincularServidor(Long requisicaoId, Long servidorId) {
        Cessao requisicao = cessaoRepository.findById(requisicaoId).orElseThrow();
        
        // Cria servidor temporário se não existir
        Servidor servidor;
        if (servidorId != null) {
            servidor = servidorRepository.findById(servidorId).orElseThrow();
        } else {
            servidor = criarServidorRequisitado(requisicao);
        }
        
        requisicao.setServidor(servidor);
        cessaoRepository.save(requisicao);
    }
}
```

### 6.3 ReembolsoService
```java
@Service
@Transactional
public class ReembolsoService {
    
    public List<ReembolsoCessao> gerarReembolsosMensal(YearMonth competencia) {
        List<ReembolsoCessao> reembolsosGerados = new ArrayList<>();
        
        // Busca cessões ativas com ônus cessionário ou compartilhado
        List<Cessao> cessoes = cessaoRepository.findAtivasComReembolso(competencia);
        
        for (Cessao cessao : cessoes) {
            ReembolsoCessao reembolso = calcularReembolso(cessao, competencia);
            reembolsosGerados.add(reembolsoRepository.save(reembolso));
        }
        
        return reembolsosGerados;
    }
    
    private ReembolsoCessao calcularReembolso(Cessao cessao, YearMonth competencia) {
        // Busca valores da folha do servidor
        BigDecimal valorRemuneracao = folhaService.obterRemuneracaoBruta(
            cessao.getServidor().getId(), competencia
        );
        
        // Calcula encargos patronais
        BigDecimal valorEncargos = calcularEncargosPatronais(valorRemuneracao);
        
        BigDecimal valorTotal = valorRemuneracao.add(valorEncargos);
        
        // Aplica percentual de reembolso
        BigDecimal percentual = cessao.getTipoOnus() == TipoOnus.CESSIONARIO 
            ? new BigDecimal("100")
            : cessao.getPercentualReembolso();
        
        BigDecimal valorReembolso = valorTotal.multiply(percentual)
            .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        
        ReembolsoCessao reembolso = new ReembolsoCessao();
        reembolso.setCessao(cessao);
        reembolso.setCompetencia(competencia);
        reembolso.setValorRemuneracao(valorRemuneracao);
        reembolso.setValorEncargos(valorEncargos);
        reembolso.setValorTotal(valorTotal);
        reembolso.setPercentualAplicado(percentual);
        reembolso.setValorReembolso(valorReembolso);
        reembolso.setSituacao(SituacaoReembolso.PENDENTE);
        reembolso.setDataGeracao(LocalDate.now());
        
        return reembolso;
    }
    
    private BigDecimal calcularEncargosPatronais(BigDecimal remuneracao) {
        // Exemplo: INSS patronal 20% + RAT 2% + Terceiros 5.8% = 27.8%
        BigDecimal aliquotaEncargos = new BigDecimal("0.278");
        return remuneracao.multiply(aliquotaEncargos).setScale(2, RoundingMode.HALF_UP);
    }
    
    public void registrarPagamento(Long reembolsoId, PagamentoReembolsoDTO dto) {
        ReembolsoCessao reembolso = reembolsoRepository.findById(reembolsoId).orElseThrow();
        
        reembolso.setSituacao(SituacaoReembolso.PAGO);
        reembolso.setDataPagamento(dto.getDataPagamento());
        reembolso.setNumeroDocumento(dto.getNumeroDocumento());
        reembolso.setNumeroGRU(dto.getNumeroGRU());
        
        reembolsoRepository.save(reembolso);
    }
    
    public List<ReembolsoCessao> buscarInadimplentes() {
        LocalDate dataLimite = LocalDate.now().minusDays(30);
        return reembolsoRepository.findInadimplentes(dataLimite);
    }
}
```

### 6.4 ProrrogacaoService
```java
@Service
@Transactional
public class ProrrogacaoService {
    
    public ProrrogacaoCessao prorrogarCessao(Long cessaoId, ProrrogacaoDTO dto) {
        Cessao cessao = cessaoRepository.findById(cessaoId).orElseThrow();
        
        if (cessao.getSituacao() != SituacaoCessao.ATIVA) {
            throw new BusinessException("Apenas cessões ativas podem ser prorrogadas");
        }
        
        // Conta número da prorrogação
        int numeroProrrogacao = cessao.getProrrogacoes().size() + 1;
        
        ProrrogacaoCessao prorrogacao = new ProrrogacaoCessao();
        prorrogacao.setCessao(cessao);
        prorrogacao.setNumeroProrrogacao(numeroProrrogacao);
        prorrogacao.setDataInicioAnterior(cessao.getDataInicio());
        prorrogacao.setDataFimAnterior(cessao.getDataFim());
        prorrogacao.setNovaDataFim(dto.getNovaDataFim());
        prorrogacao.setNumeroPortaria(dto.getNumeroPortaria());
        prorrogacao.setDataPortaria(dto.getDataPortaria());
        prorrogacao.setNumeroProcesso(dto.getNumeroProcesso());
        prorrogacao.setJustificativa(dto.getJustificativa());
        prorrogacao.setDataRegistro(LocalDateTime.now());
        
        prorrogacaoRepository.save(prorrogacao);
        
        // Atualiza data fim da cessão
        cessao.setDataFim(dto.getNovaDataFim());
        cessaoRepository.save(cessao);
        
        return prorrogacao;
    }
}
```

---

## 7. API REST

### 7.1 Endpoints

```
# Cessões
GET    /api/v1/cessoes                                   # Lista cessões
GET    /api/v1/cessoes/{id}                              # Busca cessão
POST   /api/v1/cessoes                                   # Registra cessão
PUT    /api/v1/cessoes/{id}                              # Atualiza cessão
POST   /api/v1/cessoes/{id}/autorizar                    # Autoriza cessão
POST   /api/v1/cessoes/{id}/iniciar                      # Inicia cessão
POST   /api/v1/cessoes/{id}/encerrar                     # Encerra cessão
POST   /api/v1/cessoes/{id}/revogar                      # Revoga cessão
POST   /api/v1/cessoes/{id}/suspender                    # Suspende cessão

# Prorrogações
GET    /api/v1/cessoes/{id}/prorrogacoes                 # Lista prorrogações
POST   /api/v1/cessoes/{id}/prorrogacoes                 # Registra prorrogação

# Requisições
GET    /api/v1/requisicoes                               # Lista requisições
POST   /api/v1/requisicoes                               # Registra requisição
PUT    /api/v1/requisicoes/{id}                          # Atualiza requisição
POST   /api/v1/requisicoes/{id}/vincular-servidor        # Vincula servidor

# Órgãos Externos
GET    /api/v1/orgaos-externos                           # Lista órgãos
POST   /api/v1/orgaos-externos                           # Cadastra órgão
GET    /api/v1/orgaos-externos/{id}                      # Busca órgão
PUT    /api/v1/orgaos-externos/{id}                      # Atualiza órgão

# Convênios
GET    /api/v1/convenios-cessao                          # Lista convênios
POST   /api/v1/convenios-cessao                          # Cadastra convênio
GET    /api/v1/convenios-cessao/{id}                     # Busca convênio
PUT    /api/v1/convenios-cessao/{id}                     # Atualiza convênio

# Reembolsos
GET    /api/v1/reembolsos                                # Lista reembolsos
POST   /api/v1/reembolsos/gerar/{competencia}            # Gera reembolsos do mês
GET    /api/v1/reembolsos/{id}                           # Busca reembolso
POST   /api/v1/reembolsos/{id}/cobrar                    # Registra cobrança
POST   /api/v1/reembolsos/{id}/pagar                     # Registra pagamento
GET    /api/v1/reembolsos/inadimplentes                  # Lista inadimplentes

# Por Servidor
GET    /api/v1/servidores/{id}/cessoes                   # Histórico de cessões
GET    /api/v1/servidores/{id}/cessao-ativa              # Cessão ativa

# Relatórios
GET    /api/v1/cessoes/relatorio/servidores-cedidos      # Servidores cedidos
GET    /api/v1/cessoes/relatorio/servidores-requisitados # Servidores requisitados
GET    /api/v1/cessoes/relatorio/vencimentos             # Cessões a vencer
GET    /api/v1/cessoes/relatorio/financeiro              # Relatório financeiro
```

---

## 8. RELATÓRIOS

### 8.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| Servidores Cedidos | Lista de cessões ativas | Órgão destino, Tipo ônus |
| Servidores Requisitados | Lista de requisições ativas | Órgão origem |
| Cessões por Vencer | Cessões próximas do término | Dias para vencimento |
| Histórico de Cessões | Todas cessões de um servidor | Servidor, Período |
| Reembolsos Pendentes | Reembolsos não pagos | Competência, Órgão |
| Controle Financeiro | Valores de reembolso | Período, Órgão |
| Cessões por Convênio | Cessões vinculadas a convênios | Convênio |
| Tempo de Cessão | Tempo total cedido | Servidor, Período |

---

## 9. INTEGRAÇÕES

### 9.1 Folha de Pagamento
- Suspender pagamento quando ônus do cessionário
- Manter pagamento quando ônus do cedente
- Calcular valores para reembolso

### 9.2 Cadastro de Servidores
- Atualizar situação do vínculo (CEDIDO)
- Registrar lotação de exercício

### 9.3 Frequência
- Não gerar frequência para cedidos (ônus cessionário)
- Manter registro para cedidos (ônus cedente)

---

## 10. CONSIDERAÇÕES DE IMPLEMENTAÇÃO

### 10.1 Alertas Automáticos
- Vencimento de cessão (30, 15, 7 dias antes)
- Prorrogação necessária
- Reembolso pendente
- Inadimplência

### 10.2 Validações Importantes
- Verificar vigência do convênio
- Controlar prazo máximo de cessão
- Validar autoridade competente para portaria
- Verificar impedimentos do servidor

### 10.3 Auditoria
- Registrar todas alterações de situação
- Manter histórico de prorrogações
- Controlar acesso às informações
