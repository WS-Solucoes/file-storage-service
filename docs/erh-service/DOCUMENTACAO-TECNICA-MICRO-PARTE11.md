# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 11
## Portal do Servidor (Autoatendimento)

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Fornecer uma interface de autoatendimento para servidores municipais, permitindo consultas, solicitações e acompanhamento de processos de forma autônoma.

### 1.2 Funcionalidades do Portal

| Categoria | Funcionalidade | Descrição |
|-----------|---------------|-----------|
| **Consultas** | Contracheque | Visualizar/baixar holerites |
| | Informe de Rendimentos | IRRF anual |
| | Ficha Funcional | Dados cadastrais |
| | Histórico de Férias | Períodos gozados/pendentes |
| | Margem Consignável | Consulta de margem |
| **Solicitações** | Férias | Solicitar período |
| | Licenças | Requerer licenças |
| | Atualização Cadastral | Alterar dados |
| | Declarações | Solicitar documentos |
| **Simulações** | Aposentadoria | Simular proventos |
| | Empréstimo | Simular parcelas |
| **Acompanhamento** | Solicitações | Status de pedidos |
| | Notificações | Avisos e alertas |

---

## 2. ARQUITETURA DO PORTAL

### 2.1 Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                    PORTAL DO SERVIDOR                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   Frontend (Next.js)                 │   │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐  │   │
│  │  │ Login   │ │ Home    │ │ Contra- │ │Solicita- │  │   │
│  │  │ Page    │ │ Dash    │ │ cheque  │ │ ções     │  │   │
│  │  └─────────┘ └─────────┘ └─────────┘ └──────────┘  │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   API Gateway                        │   │
│  │              (Autenticação JWT)                      │   │
│  └──────────────────────┬──────────────────────────────┘   │
│                         │                                   │
│                         ▼                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │               PortalServidorController               │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌────────────┐  │   │
│  │  │ Contracheque │ │ Solicitações │ │ Simulações │  │   │
│  │  │ Endpoint     │ │ Endpoint     │ │ Endpoint   │  │   │
│  │  └──────────────┘ └──────────────┘ └────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Fluxo de Autenticação

```
┌─────────────────────────────────────────────────────────────┐
│               AUTENTICAÇÃO PORTAL SERVIDOR                  │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Servidor]                                                 │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────┐                                            │
│  │ Informar    │                                            │
│  │ CPF + Senha │                                            │
│  └──────┬──────┘                                            │
│         │                                                   │
│         ▼                                                   │
│  ┌─────────────────────────────────────┐                   │
│  │ Validar credenciais                 │                   │
│  │ - Verificar CPF cadastrado          │                   │
│  │ - Validar senha (BCrypt)            │                   │
│  │ - Verificar situação = ATIVO        │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│         ┌───────────┴───────────┐                          │
│         │                       │                           │
│         ▼                       ▼                           │
│  ┌───────────┐          ┌───────────┐                      │
│  │ SUCESSO   │          │ FALHA     │                      │
│  │ Gerar JWT │          │ Erro msg  │                      │
│  └─────┬─────┘          └───────────┘                      │
│        │                                                    │
│        ▼                                                    │
│  ┌─────────────────────────────────────┐                   │
│  │ JWT contém:                         │                   │
│  │ - servidorId                        │                   │
│  │ - cpf                               │                   │
│  │ - nome                              │                   │
│  │ - vinculoId                         │                   │
│  │ - unidadeGestoraId                  │                   │
│  │ - role = SERVIDOR                   │                   │
│  │ - exp = 8 horas                     │                   │
│  └─────────────────────────────────────┘                   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. MODELO DE DADOS

### 3.1 Entidade: PortalSolicitacao

```java
@Entity
@Table(name = "portal_solicitacao")
public class PortalSolicitacao extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 50)
    private TipoSolicitacao tipo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoSolicitacao situacao;
    
    @Column(name = "data_solicitacao")
    private LocalDateTime dataSolicitacao;
    
    @Column(name = "data_analise")
    private LocalDateTime dataAnalise;
    
    @Column(name = "descricao", length = 1000)
    private String descricao;
    
    @Column(name = "justificativa", length = 500)
    private String justificativa; // Para solicitações que exigem
    
    @Column(name = "dados_json", columnDefinition = "TEXT")
    private String dadosJson; // Dados específicos do tipo
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "analisado_por")
    private Usuario analisadoPor;
    
    @Column(name = "parecer", length = 1000)
    private String parecer;
    
    @Column(name = "protocolo", length = 20, unique = true)
    private String protocolo;
}
```

### 3.2 Enum TipoSolicitacao

```java
public enum TipoSolicitacao {
    FERIAS("Solicitação de Férias"),
    LICENCA_MEDICA("Licença Médica"),
    LICENCA_PREMIO("Licença Prêmio"),
    LICENCA_MATERNIDADE("Licença Maternidade"),
    LICENCA_PATERNIDADE("Licença Paternidade"),
    ATUALIZACAO_ENDERECO("Atualização de Endereço"),
    ATUALIZACAO_TELEFONE("Atualização de Telefone"),
    ATUALIZACAO_EMAIL("Atualização de E-mail"),
    ATUALIZACAO_BANCARIA("Atualização Dados Bancários"),
    DECLARACAO_VINCULO("Declaração de Vínculo"),
    DECLARACAO_TEMPO("Declaração de Tempo de Serviço"),
    DECLARACAO_RENDIMENTOS("Declaração de Rendimentos"),
    CERTIDAO_TEMPO("Certidão de Tempo de Contribuição"),
    SIMULACAO_APOSENTADORIA("Simulação de Aposentadoria"),
    CONSIGNADO_MARGEM("Consulta Margem Consignável"),
    RECADASTRAMENTO("Recadastramento"),
    OUTRA("Outra Solicitação");
    
    private final String descricao;
}
```

### 3.3 Enum SituacaoSolicitacao

```java
public enum SituacaoSolicitacao {
    RASCUNHO,       // Iniciada, não enviada
    PENDENTE,       // Aguardando análise
    EM_ANALISE,     // Sendo analisada
    APROVADA,       // Deferida
    REJEITADA,      // Indeferida
    CANCELADA,      // Cancelada pelo servidor
    CONCLUIDA       // Processada e finalizada
}
```

### 3.4 Entidade: PortalNotificacao

```java
@Entity
@Table(name = "portal_notificacao")
public class PortalNotificacao extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoNotificacao tipo;
    
    @Column(name = "titulo", length = 200)
    private String titulo;
    
    @Column(name = "mensagem", length = 1000)
    private String mensagem;
    
    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;
    
    @Column(name = "data_leitura")
    private LocalDateTime dataLeitura;
    
    @Column(name = "lida")
    private Boolean lida = false;
    
    @Column(name = "link", length = 500)
    private String link; // Link para ação relacionada
}
```

---

## 4. FUNCIONALIDADES DETALHADAS

### 4.1 Contracheque

```java
/**
 * Serviço de Contracheque para o Portal
 */
@Service
public class PortalContrachequeService {
    
    /**
     * Buscar contracheques disponíveis
     */
    public List<ContrachequeResumo> listarDisponiveis(Long servidorId) {
        // Buscar últimos 12 meses
        YearMonth atual = YearMonth.now();
        YearMonth inicio = atual.minusMonths(12);
        
        return folhaDetRepository
            .findByServidorAndPeriodo(servidorId, inicio, atual)
            .stream()
            .map(this::toResumo)
            .collect(Collectors.toList());
    }
    
    /**
     * Gerar PDF do contracheque
     */
    public byte[] gerarPDF(Long servidorId, YearMonth competencia) {
        FolhaPagamentoDet det = folhaDetRepository
            .findByServidorAndCompetencia(servidorId, competencia)
            .orElseThrow(() -> new NotFoundException("Contracheque não encontrado"));
        
        // Validar se servidor pode acessar
        validarAcesso(servidorId, det);
        
        return contrachequeReportService.gerarPDF(det);
    }
    
    /**
     * Buscar detalhes do contracheque
     */
    public ContrachequeDetalhado buscarDetalhes(Long servidorId, YearMonth competencia) {
        FolhaPagamentoDet det = folhaDetRepository
            .findByServidorAndCompetencia(servidorId, competencia)
            .orElseThrow();
        
        ContrachequeDetalhado resultado = new ContrachequeDetalhado();
        resultado.setCompetencia(competencia);
        resultado.setServidor(mapearServidor(det.getServidor()));
        resultado.setCargo(det.getCargo().getNome());
        resultado.setLotacao(det.getLotacao().getNome());
        
        // Proventos
        List<ItemContracheque> proventos = det.getItens().stream()
            .filter(i -> i.getTipo() == TipoRubrica.PROVENTO)
            .map(this::toItemContracheque)
            .collect(Collectors.toList());
        resultado.setProventos(proventos);
        
        // Descontos
        List<ItemContracheque> descontos = det.getItens().stream()
            .filter(i -> i.getTipo() == TipoRubrica.DESCONTO)
            .map(this::toItemContracheque)
            .collect(Collectors.toList());
        resultado.setDescontos(descontos);
        
        // Totais
        resultado.setTotalProventos(det.getTotalProventos());
        resultado.setTotalDescontos(det.getTotalDescontos());
        resultado.setLiquido(det.getLiquido());
        
        return resultado;
    }
}
```

### 4.2 Solicitação de Férias

```java
/**
 * Serviço de Solicitação de Férias no Portal
 */
@Service
public class PortalFeriasService {
    
    /**
     * Consultar saldo de férias
     */
    public SaldoFerias consultarSaldo(Long servidorId) {
        List<PeriodoFerias> periodos = feriasService
            .buscarPeriodosAquisitivos(servidorId);
        
        SaldoFerias saldo = new SaldoFerias();
        saldo.setDiasVencidos(0);
        saldo.setDiasAVencer(0);
        saldo.setPeriodos(new ArrayList<>());
        
        LocalDate hoje = LocalDate.now();
        
        for (PeriodoFerias periodo : periodos) {
            PeriodoFeriasDTO dto = new PeriodoFeriasDTO();
            dto.setInicio(periodo.getDataInicio());
            dto.setFim(periodo.getDataFim());
            dto.setDiasDireito(periodo.getDiasDireito());
            dto.setDiasGozados(periodo.getDiasGozados());
            dto.setDiasPendentes(periodo.getDiasDireito() - periodo.getDiasGozados());
            dto.setVencido(periodo.getDataLimite().isBefore(hoje));
            
            saldo.getPeriodos().add(dto);
            
            if (dto.isVencido()) {
                saldo.setDiasVencidos(saldo.getDiasVencidos() + dto.getDiasPendentes());
            } else {
                saldo.setDiasAVencer(saldo.getDiasAVencer() + dto.getDiasPendentes());
            }
        }
        
        return saldo;
    }
    
    /**
     * Solicitar férias
     */
    public PortalSolicitacao solicitarFerias(Long servidorId, SolicitacaoFeriasDTO request) {
        // Validações
        validarPeriodo(servidorId, request);
        validarSaldoDisponivel(servidorId, request.getDias());
        validarAntecedenciaMinima(request.getDataInicio());
        
        // Criar solicitação
        PortalSolicitacao solicitacao = new PortalSolicitacao();
        solicitacao.setServidor(servidorRepository.findById(servidorId).orElseThrow());
        solicitacao.setTipo(TipoSolicitacao.FERIAS);
        solicitacao.setSituacao(SituacaoSolicitacao.PENDENTE);
        solicitacao.setDataSolicitacao(LocalDateTime.now());
        solicitacao.setProtocolo(gerarProtocolo());
        
        // Dados específicos
        FeriasSolicitacaoData dados = new FeriasSolicitacaoData();
        dados.setDataInicio(request.getDataInicio());
        dados.setDataFim(request.getDataFim());
        dados.setDias(request.getDias());
        dados.setAbonarDias(request.getAbonarDias());
        dados.setAdiantamento13(request.isAdiantamento13());
        solicitacao.setDadosJson(objectMapper.writeValueAsString(dados));
        
        portalSolicitacaoRepository.save(solicitacao);
        
        // Notificar RH
        notificarRH(solicitacao);
        
        return solicitacao;
    }
    
    private void validarPeriodo(Long servidorId, SolicitacaoFeriasDTO request) {
        // Verificar se não há sobreposição com outras férias
        List<Ferias> feriasExistentes = feriasRepository
            .findByServidorAndPeriodo(servidorId, request.getDataInicio(), request.getDataFim());
        
        if (!feriasExistentes.isEmpty()) {
            throw new BusinessException("Já existe férias programadas no período");
        }
        
        // Verificar dias mínimos/máximos
        if (request.getDias() < 5) {
            throw new BusinessException("Período mínimo de férias é 5 dias");
        }
        if (request.getDias() > 30) {
            throw new BusinessException("Período máximo de férias é 30 dias");
        }
    }
}
```

### 4.3 Atualização Cadastral

```java
/**
 * Serviço de Atualização Cadastral no Portal
 */
@Service
public class PortalCadastroService {
    
    /**
     * Buscar dados cadastrais
     */
    public DadosCadastraisDTO buscarDados(Long servidorId) {
        Servidor servidor = servidorRepository.findById(servidorId)
            .orElseThrow();
        
        DadosCadastraisDTO dados = new DadosCadastraisDTO();
        
        // Dados pessoais (apenas visualização)
        dados.setNome(servidor.getNome());
        dados.setCpf(servidor.getCpf());
        dados.setDataNascimento(servidor.getDataNascimento());
        
        // Dados editáveis
        dados.setEndereco(mapearEndereco(servidor));
        dados.setTelefone(servidor.getTelefone());
        dados.setCelular(servidor.getCelular());
        dados.setEmail(servidor.getEmail());
        dados.setEmailPessoal(servidor.getEmailPessoal());
        dados.setDadosBancarios(mapearDadosBancarios(servidor));
        
        return dados;
    }
    
    /**
     * Solicitar atualização de endereço
     */
    public PortalSolicitacao atualizarEndereco(Long servidorId, EnderecoDTO novoEndereco) {
        PortalSolicitacao solicitacao = new PortalSolicitacao();
        solicitacao.setServidor(servidorRepository.findById(servidorId).orElseThrow());
        solicitacao.setTipo(TipoSolicitacao.ATUALIZACAO_ENDERECO);
        solicitacao.setSituacao(SituacaoSolicitacao.PENDENTE);
        solicitacao.setDataSolicitacao(LocalDateTime.now());
        solicitacao.setProtocolo(gerarProtocolo());
        
        AtualizacaoEnderecoData dados = new AtualizacaoEnderecoData();
        dados.setEnderecoAnterior(buscarEnderecoAtual(servidorId));
        dados.setEnderecoNovo(novoEndereco);
        solicitacao.setDadosJson(objectMapper.writeValueAsString(dados));
        
        return portalSolicitacaoRepository.save(solicitacao);
    }
    
    /**
     * Atualizar telefone (direto, sem aprovação)
     */
    public void atualizarTelefone(Long servidorId, String telefone, String celular) {
        Servidor servidor = servidorRepository.findById(servidorId)
            .orElseThrow();
        
        servidor.setTelefone(telefone);
        servidor.setCelular(celular);
        
        servidorRepository.save(servidor);
        
        // Registrar log
        auditService.registrar("ATUALIZACAO_TELEFONE", servidorId);
    }
}
```

### 4.4 Informe de Rendimentos

```java
/**
 * Serviço de Informe de Rendimentos no Portal
 */
@Service
public class PortalRendimentosService {
    
    /**
     * Listar anos disponíveis
     */
    public List<Integer> listarAnosDisponiveis(Long servidorId) {
        return informeRendimentosRepository
            .findAnosByServidor(servidorId);
    }
    
    /**
     * Gerar informe de rendimentos
     */
    public InformeRendimentosDTO gerarInforme(Long servidorId, Integer ano) {
        // Buscar todas as folhas do ano
        List<FolhaPagamentoDet> folhas = folhaDetRepository
            .findByServidorAndAno(servidorId, ano);
        
        if (folhas.isEmpty()) {
            throw new NotFoundException("Não há dados para o ano " + ano);
        }
        
        InformeRendimentosDTO informe = new InformeRendimentosDTO();
        informe.setAnoCalendario(ano);
        informe.setServidor(mapearServidor(folhas.get(0).getServidor()));
        
        // Somar rendimentos tributáveis
        BigDecimal totalTributavel = folhas.stream()
            .flatMap(f -> f.getItens().stream())
            .filter(i -> i.getRubrica().getIncidenciaIRRF() == IncidenciaIRRF.TRIBUTAVEL)
            .map(FolhaPagamentoItem::getValor)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        informe.setRendimentosTributaveis(totalTributavel);
        
        // Somar deduções
        BigDecimal totalPrevidencia = folhas.stream()
            .flatMap(f -> f.getItens().stream())
            .filter(i -> i.getRubrica().getCodigo().startsWith("D02")) // RPPS
            .map(FolhaPagamentoItem::getValor)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        informe.setContribuicaoPrevidenciaria(totalPrevidencia);
        
        // Imposto retido
        BigDecimal totalIRRF = folhas.stream()
            .map(FolhaPagamentoDet::getIrrf)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        informe.setImpostoRetido(totalIRRF);
        
        // 13º salário
        BigDecimal total13 = folhas.stream()
            .flatMap(f -> f.getItens().stream())
            .filter(i -> i.getRubrica().getCodigo().startsWith("P04")) // 13º
            .map(FolhaPagamentoItem::getValor)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        informe.setDecimoTerceiro(total13);
        
        // IRRF sobre 13º
        // ... cálculo similar
        
        return informe;
    }
    
    /**
     * Gerar PDF do informe
     */
    public byte[] gerarPDF(Long servidorId, Integer ano) {
        InformeRendimentosDTO informe = gerarInforme(servidorId, ano);
        return informeReportService.gerarPDF(informe);
    }
}
```

### 4.5 Simulação de Aposentadoria

```java
/**
 * Serviço de Simulação de Aposentadoria no Portal
 */
@Service
public class PortalAposentadoriaService {
    
    /**
     * Realizar simulação
     */
    public SimulacaoAposentadoriaDTO simular(Long servidorId) {
        Servidor servidor = servidorRepository.findById(servidorId)
            .orElseThrow();
        
        // Calcular tempo de contribuição
        TempoContribuicao tempo = aposentadoriaService.calcularTempo(servidorId);
        
        // Calcular idade
        int idadeAtual = Period.between(
            servidor.getDataNascimento(), LocalDate.now()).getYears();
        
        // Verificar elegibilidade em cada regra
        SimulacaoAposentadoriaDTO simulacao = new SimulacaoAposentadoriaDTO();
        simulacao.setIdadeAtual(idadeAtual);
        simulacao.setTempoContribuicao(tempo);
        
        // Regra comum
        RegraSimulacao regraComum = simularRegraComum(servidor, tempo, idadeAtual);
        simulacao.setRegraComum(regraComum);
        
        // Regra de pontos
        RegraSimulacao regraPontos = simularRegraPontos(servidor, tempo, idadeAtual);
        simulacao.setRegraPontos(regraPontos);
        
        // Pedágio 50%
        RegraSimulacao pedagio50 = simularPedagio50(servidor, tempo, idadeAtual);
        simulacao.setPedagio50(pedagio50);
        
        // Pedágio 100%
        RegraSimulacao pedagio100 = simularPedagio100(servidor, tempo, idadeAtual);
        simulacao.setPedagio100(pedagio100);
        
        // Melhor opção
        simulacao.setMelhorOpcao(determinarMelhorOpcao(simulacao));
        
        return simulacao;
    }
    
    private RegraSimulacao simularRegraComum(Servidor servidor, 
                                             TempoContribuicao tempo,
                                             int idadeAtual) {
        RegraSimulacao regra = new RegraSimulacao();
        regra.setNome("Regra Comum EC 103/2019");
        
        int idadeMinima = servidor.getSexo() == Sexo.MASCULINO ? 65 : 62;
        int tempoMinimo = 25;
        
        // Verificar requisitos
        boolean atingiuIdade = idadeAtual >= idadeMinima;
        boolean atingiuTempo = tempo.getAnosCompletos() >= tempoMinimo;
        
        regra.setElegivel(atingiuIdade && atingiuTempo);
        
        if (!regra.isElegivel()) {
            // Calcular tempo faltante
            if (!atingiuIdade) {
                int anosFaltam = idadeMinima - idadeAtual;
                regra.setIdadeFaltante(anosFaltam);
            }
            if (!atingiuTempo) {
                int anosFaltam = tempoMinimo - tempo.getAnosCompletos();
                regra.setTempoFaltante(anosFaltam);
            }
            
            // Prever data
            LocalDate previsao = calcularDataElegibilidade(servidor, tempo, idadeMinima, tempoMinimo);
            regra.setDataPrevistaElegibilidade(previsao);
        }
        
        // Calcular provento estimado
        BigDecimal media = aposentadoriaService.calcularMediaContribuicoes(servidor.getId());
        BigDecimal coeficiente = aposentadoriaService.calcularCoeficiente(
            tempo.getAnosCompletos(), servidor.getSexo());
        BigDecimal proventoEstimado = media.multiply(coeficiente);
        
        regra.setMediaContribuicoes(media);
        regra.setCoeficiente(coeficiente);
        regra.setProventoEstimado(proventoEstimado);
        
        return regra;
    }
}
```

---

## 5. ENDPOINTS DA API

### 5.1 PortalController

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| **Autenticação** |||
| POST | `/api/portal/login` | Login do servidor |
| POST | `/api/portal/logout` | Logout |
| POST | `/api/portal/alterar-senha` | Alterar senha |
| **Contracheque** |||
| GET | `/api/portal/contracheques` | Listar disponíveis |
| GET | `/api/portal/contracheques/{competencia}` | Detalhes |
| GET | `/api/portal/contracheques/{competencia}/pdf` | Download PDF |
| **Férias** |||
| GET | `/api/portal/ferias/saldo` | Consultar saldo |
| POST | `/api/portal/ferias/solicitar` | Solicitar |
| GET | `/api/portal/ferias/solicitacoes` | Listar solicitações |
| **Cadastro** |||
| GET | `/api/portal/cadastro` | Dados cadastrais |
| PUT | `/api/portal/cadastro/telefone` | Atualizar telefone |
| POST | `/api/portal/cadastro/endereco` | Solicitar atualização |
| **Rendimentos** |||
| GET | `/api/portal/rendimentos/anos` | Anos disponíveis |
| GET | `/api/portal/rendimentos/{ano}` | Informe do ano |
| GET | `/api/portal/rendimentos/{ano}/pdf` | Download PDF |
| **Simulações** |||
| GET | `/api/portal/simulacao/aposentadoria` | Simular aposentadoria |
| GET | `/api/portal/simulacao/margem` | Simular margem |
| **Solicitações** |||
| GET | `/api/portal/solicitacoes` | Listar todas |
| GET | `/api/portal/solicitacoes/{id}` | Detalhes |
| DELETE | `/api/portal/solicitacoes/{id}` | Cancelar |
| **Notificações** |||
| GET | `/api/portal/notificacoes` | Listar |
| PUT | `/api/portal/notificacoes/{id}/ler` | Marcar como lida |

---

## 6. INTERFACE DO USUÁRIO (Frontend)

### 6.1 Telas Principais

```
┌─────────────────────────────────────────────────────────┐
│                    PORTAL DO SERVIDOR                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │  🏠 Início  📄 Contracheque  🏖️ Férias  ⚙️ Dados │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌───────────────────┐  ┌───────────────────┐         │
│  │ ÚLTIMO PAGAMENTO  │  │ SALDO DE FÉRIAS   │         │
│  │ Janeiro/2026      │  │ 30 dias           │         │
│  │ R$ 5.234,56       │  │ disponíveis       │         │
│  │ [Ver detalhes]    │  │ [Solicitar]       │         │
│  └───────────────────┘  └───────────────────┘         │
│                                                         │
│  ┌───────────────────┐  ┌───────────────────┐         │
│  │ NOTIFICAÇÕES      │  │ SOLICITAÇÕES      │         │
│  │ 3 novas           │  │ 1 pendente        │         │
│  │ [Ver todas]       │  │ [Ver todas]       │         │
│  └───────────────────┘  └───────────────────┘         │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ACESSO RÁPIDO                                   │   │
│  │ [Informe IRRF] [Margem] [Simulação Aposent.]    │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 7. SEGURANÇA

### 7.1 Controles de Acesso

```java
/**
 * Filtro de segurança para o Portal
 */
@Component
public class PortalSecurityFilter extends OncePerRequestFilter {
    
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain) {
        // Extrair token
        String token = extractToken(request);
        
        if (token != null && jwtService.isValid(token)) {
            Claims claims = jwtService.getClaims(token);
            
            // Verificar se é token de servidor
            String role = claims.get("role", String.class);
            if (!"SERVIDOR".equals(role)) {
                throw new AccessDeniedException("Acesso negado");
            }
            
            // Criar contexto
            Long servidorId = claims.get("servidorId", Long.class);
            PortalContext.setServidorId(servidorId);
            
            chain.doFilter(request, response);
        } else {
            response.setStatus(HttpStatus.UNAUTHORIZED.value());
        }
    }
}
```

### 7.2 Validações de Acesso

```java
/**
 * Validar que servidor só acessa seus próprios dados
 */
@Aspect
@Component
public class PortalAccessAspect {
    
    @Around("@annotation(PortalAccess)")
    public Object validarAcesso(ProceedingJoinPoint joinPoint) throws Throwable {
        Long servidorIdLogado = PortalContext.getServidorId();
        Long servidorIdRequisitado = extrairServidorId(joinPoint);
        
        if (!servidorIdLogado.equals(servidorIdRequisitado)) {
            throw new AccessDeniedException(
                "Servidor não pode acessar dados de outro servidor");
        }
        
        return joinPoint.proceed();
    }
}
```

---

**Próximo Documento:** PARTE 12 - Frequência e Ponto
