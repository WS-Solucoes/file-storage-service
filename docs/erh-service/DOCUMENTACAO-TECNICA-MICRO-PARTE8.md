# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 8
## Integração eSocial

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Integrar o sistema eRH com o eSocial, gerando, validando e transmitindo os eventos obrigatórios para órgãos públicos municipais.

### 1.2 Eventos Aplicáveis a Órgãos Públicos

| Grupo | Evento | Descrição | Periodicidade |
|-------|--------|-----------|---------------|
| Tabelas | S-1000 | Informações do Empregador | Inicial/Alteração |
| Tabelas | S-1005 | Estabelecimentos | Inicial/Alteração |
| Tabelas | S-1010 | Rubricas | Inicial/Alteração |
| Tabelas | S-1020 | Lotações Tributárias | Inicial/Alteração |
| Tabelas | S-1070 | Processos Admin/Judiciais | Quando houver |
| Não Periódicos | S-2200 | Cadastramento Inicial/Admissão | Admissão |
| Não Periódicos | S-2205 | Alteração Dados Cadastrais | Quando houver |
| Não Periódicos | S-2206 | Alteração Contrato | Quando houver |
| Não Periódicos | S-2230 | Afastamento Temporário | Quando houver |
| Não Periódicos | S-2299 | Desligamento | Desligamento |
| Não Periódicos | S-2300 | TSV - Início | Sem vínculo |
| Periódicos | S-1200 | Remuneração RGPS | Mensal |
| Periódicos | S-1202 | Remuneração RPPS | Mensal |
| Periódicos | S-1210 | Pagamentos | Mensal |
| Periódicos | S-1260 | Comercialização Produção | Se aplicável |
| Periódicos | S-1298 | Reabertura Eventos | Quando necessário |
| Periódicos | S-1299 | Fechamento Eventos | Mensal |

---

## 2. ARQUITETURA DE INTEGRAÇÃO

### 2.1 Diagrama de Componentes

```
┌──────────────────────────────────────────────────────────────┐
│                        eRH-Service                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐      │
│  │ Folha       │    │ Servidor    │    │ Vínculo     │      │
│  │ Pagamento   │    │ Service     │    │ Service     │      │
│  └──────┬──────┘    └──────┬──────┘    └──────┬──────┘      │
│         │                  │                  │              │
│         └──────────────────┼──────────────────┘              │
│                            │                                 │
│                            ▼                                 │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              EsocialEventoService                    │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │    │
│  │  │ S1200   │ │ S1202   │ │ S2200   │ │ S2299   │   │    │
│  │  │ Builder │ │ Builder │ │ Builder │ │ Builder │   │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘   │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                    │
│                         ▼                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              EsocialXmlService                       │    │
│  │  - Gerar XML conforme layout                         │    │
│  │  - Validar XSD                                       │    │
│  │  - Assinar digitalmente                              │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                    │
│                         ▼                                    │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              EsocialTransmissaoService               │    │
│  │  - Enviar lote                                       │    │
│  │  - Consultar processamento                           │    │
│  │  - Tratar retornos                                   │    │
│  └──────────────────────┬──────────────────────────────┘    │
│                         │                                    │
└─────────────────────────┼────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │   WebService eSocial  │
              │   (Governo Federal)   │
              └───────────────────────┘
```

### 2.2 Modelo de Dados

```java
@Entity
@Table(name = "esocial_evento")
public class EsocialEvento extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "tipo_evento", length = 10)
    private String tipoEvento; // S-1200, S-2200, etc.
    
    @Column(name = "id_evento", length = 50, unique = true)
    private String idEvento; // ID único do evento
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoEvento situacao;
    
    @Column(name = "competencia", length = 7)
    private String competencia; // YYYY-MM
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id")
    private VinculoFuncional vinculo;
    
    @Column(name = "xml_evento", columnDefinition = "TEXT")
    private String xmlEvento;
    
    @Column(name = "xml_retorno", columnDefinition = "TEXT")
    private String xmlRetorno;
    
    @Column(name = "protocolo_envio", length = 50)
    private String protocoloEnvio;
    
    @Column(name = "recibo", length = 50)
    private String recibo;
    
    @Column(name = "data_geracao")
    private LocalDateTime dataGeracao;
    
    @Column(name = "data_envio")
    private LocalDateTime dataEnvio;
    
    @Column(name = "data_retorno")
    private LocalDateTime dataRetorno;
    
    @Column(name = "codigo_retorno", length = 10)
    private String codigoRetorno;
    
    @Column(name = "mensagem_retorno", length = 1000)
    private String mensagemRetorno;
    
    @Column(name = "numero_lote", length = 50)
    private String numeroLote;
}
```

### 2.3 Enum SituacaoEvento

```java
public enum SituacaoEvento {
    RASCUNHO,       // Evento criado, não validado
    VALIDADO,       // XML validado contra XSD
    ASSINADO,       // XML assinado digitalmente
    ENVIADO,        // Enviado ao eSocial
    PROCESSANDO,    // Aguardando retorno
    ACEITO,         // Evento aceito
    REJEITADO,      // Evento com erro
    RETIFICADO,     // Substituído por outro evento
    EXCLUIDO        // Evento de exclusão enviado
}
```

---

## 3. EVENTOS PRINCIPAIS

### 3.1 S-1200 - Remuneração RGPS

```java
/**
 * Evento S-1200: Remuneração de trabalhador vinculado ao RGPS
 * Aplicável a: Celetistas, Temporários, Comissionados sem vínculo efetivo
 */
@Service
public class S1200Builder {
    
    public EsocialEvento build(VinculoFuncional vinculo, 
                               FolhaPagamentoDet folhaDet,
                               YearMonth competencia) {
        
        S1200 evento = new S1200();
        
        // Identificação
        evento.setIdEvento(gerarIdEvento("S1200", vinculo));
        evento.setIndRetif(1); // 1=Original, 2=Retificação
        evento.setPerApur(competencia.toString()); // YYYY-MM
        
        // Empregador
        evento.setTpInsc(1); // 1=CNPJ
        evento.setNrInsc(getUnidadeGestora().getCnpj());
        
        // Trabalhador
        evento.setCpfTrab(vinculo.getServidor().getCpf());
        evento.setNisTrab(vinculo.getServidor().getPis());
        
        // Informações do vínculo
        evento.setMatricula(vinculo.getMatricula());
        evento.setCodCateg(mapearCategoria(vinculo));
        
        // Remuneração
        DmDev dmDev = new DmDev();
        dmDev.setIdeDmDev(competencia.toString());
        
        // Itens de remuneração (rubricas)
        for (FolhaPagamentoItem item : folhaDet.getItens()) {
            InfoPerApur info = new InfoPerApur();
            info.setCodRubr(item.getRubrica().getCodigoEsocial());
            info.setIdeTabRubr("TAB_RUBRICA");
            info.setVrRubr(item.getValor());
            dmDev.addInfoPerApur(info);
        }
        
        evento.addDmDev(dmDev);
        
        return toEsocialEvento(evento);
    }
}
```

### 3.2 S-1202 - Remuneração RPPS

```java
/**
 * Evento S-1202: Remuneração de servidor vinculado ao RPPS
 * Aplicável a: Servidores efetivos, estatutários
 */
@Service
public class S1202Builder {
    
    public EsocialEvento build(VinculoFuncional vinculo,
                               FolhaPagamentoDet folhaDet,
                               YearMonth competencia) {
        
        S1202 evento = new S1202();
        
        // Identificação
        evento.setIdEvento(gerarIdEvento("S1202", vinculo));
        evento.setIndRetif(1);
        evento.setPerApur(competencia.toString());
        
        // Empregador
        evento.setTpInsc(1);
        evento.setNrInsc(getUnidadeGestora().getCnpj());
        
        // Trabalhador
        evento.setCpfTrab(vinculo.getServidor().getCpf());
        
        // Informações do vínculo
        evento.setMatricula(vinculo.getMatricula());
        evento.setCodCateg(mapearCategoriaRPPS(vinculo)); // 301, 302, etc.
        
        // Tipo de regime previdenciário
        evento.setTpRegPrev(2); // 2=RPPS
        
        // Remuneração
        DmDev dmDev = new DmDev();
        dmDev.setIdeDmDev(competencia.toString());
        dmDev.setTpAcConv("E"); // E=Estatutário
        
        // Itens
        for (FolhaPagamentoItem item : folhaDet.getItens()) {
            InfoPerApur info = new InfoPerApur();
            info.setCodRubr(item.getRubrica().getCodigoEsocial());
            info.setIdeTabRubr("TAB_RUBRICA");
            info.setQtdRubr(item.getQuantidade());
            info.setFatorRubr(item.getFator());
            info.setVrRubr(item.getValor());
            
            // Incidências
            info.setIndApworker(mapearIncidenciaPrevidencia(item));
            info.setIndApIRRF(mapearIncidenciaIRRF(item));
            
            dmDev.addInfoPerApur(info);
        }
        
        // Informações de contribuição RPPS
        InfoComplCont infoRPPS = new InfoComplCont();
        infoRPPS.setVrCpSeg(folhaDet.getContribuicaoRPPS());
        infoRPPS.setVrDescSeg(folhaDet.getDescontoRPPS());
        evento.setInfoComplCont(infoRPPS);
        
        evento.addDmDev(dmDev);
        
        return toEsocialEvento(evento);
    }
}
```

### 3.3 S-2200 - Admissão/Cadastramento

```java
/**
 * Evento S-2200: Cadastramento Inicial do Vínculo ou Admissão
 */
@Service
public class S2200Builder {
    
    public EsocialEvento build(VinculoFuncional vinculo) {
        
        S2200 evento = new S2200();
        Servidor servidor = vinculo.getServidor();
        
        // Identificação
        evento.setIdEvento(gerarIdEvento("S2200", vinculo));
        
        // Empregador
        evento.setTpInsc(1);
        evento.setNrInsc(getUnidadeGestora().getCnpj());
        
        // Trabalhador - Dados pessoais
        evento.setCpfTrab(servidor.getCpf());
        evento.setNisTrab(servidor.getPis());
        evento.setNmTrab(servidor.getNome());
        evento.setSexo(servidor.getSexo());
        evento.setRacaCor(mapearRacaCor(servidor));
        evento.setEstCiv(mapearEstadoCivil(servidor));
        evento.setGrauInstr(mapearGrauInstrucao(servidor));
        evento.setNmSoc(servidor.getNomeSocial());
        
        // Nascimento
        Nascimento nasc = new Nascimento();
        nasc.setDtNascto(servidor.getDataNascimento());
        nasc.setCodMunic(servidor.getMunicipioNascimento());
        nasc.setUf(servidor.getUfNascimento());
        nasc.setPaisNascto(servidor.getPaisNascimento());
        nasc.setPaisNac(servidor.getNacionalidade());
        nasc.setNmMae(servidor.getNomeMae());
        nasc.setNmPai(servidor.getNomePai());
        evento.setNascimento(nasc);
        
        // Documentos
        Documentos docs = new Documentos();
        docs.setCtps(mapearCTPS(servidor));
        docs.setRic(mapearRG(servidor));
        evento.setDocumentos(docs);
        
        // Endereço
        evento.setEndereco(mapearEndereco(servidor));
        
        // Contato
        evento.setTelefone(servidor.getTelefone());
        evento.setEmail(servidor.getEmail());
        
        // Dados do vínculo
        Vinculo vinc = new Vinculo();
        vinc.setMatricula(vinculo.getMatricula());
        vinc.setTpRegTrab(2); // 2=Estatutário
        vinc.setTpRegPrev(2); // 2=RPPS
        vinc.setCadIni("S"); // S=Cadastramento inicial
        
        // Informações do contrato
        InfoContrato contrato = new InfoContrato();
        contrato.setCodCargo(vinculo.getCargo().getCodigo());
        contrato.setCodFuncao(vinculo.getFuncao() != null ? 
            vinculo.getFuncao().getCodigo() : null);
        contrato.setCodCateg(mapearCategoria(vinculo));
        contrato.setDtIngrCargo(vinculo.getDataAdmissao());
        contrato.setVrSalFx(vinculo.getSalarioBase());
        contrato.setUndSalFixo(5); // 5=Mensal
        
        // Lotação
        contrato.setCodLotacao(vinculo.getLotacao().getCodigo());
        
        vinc.setInfoContrato(contrato);
        evento.setVinculo(vinc);
        
        return toEsocialEvento(evento);
    }
}
```

### 3.4 S-2299 - Desligamento

```java
/**
 * Evento S-2299: Desligamento
 */
@Service
public class S2299Builder {
    
    public EsocialEvento build(Desligamento deslig) {
        
        S2299 evento = new S2299();
        VinculoFuncional vinculo = deslig.getVinculo();
        
        // Identificação
        evento.setIdEvento(gerarIdEvento("S2299", vinculo));
        
        // Empregador
        evento.setTpInsc(1);
        evento.setNrInsc(getUnidadeGestora().getCnpj());
        
        // Trabalhador
        evento.setCpfTrab(vinculo.getServidor().getCpf());
        evento.setMatricula(vinculo.getMatricula());
        
        // Informações do desligamento
        InfoDeslig info = new InfoDeslig();
        info.setMtvDeslig(mapearMotivoDesligamento(deslig.getTipo()));
        info.setDtDeslig(deslig.getDataDesligamento());
        info.setIndPagtoAPI("N"); // Pagamento em folha
        info.setDtProjFimAPI(null);
        
        // Pensão alimentícia (se houver)
        info.setPensAlim(0); // 0=Não há
        
        // Informações do processo (se demissão)
        if (deslig.getTipo() == TipoDesligamento.DEM) {
            info.setNrProcTrab(deslig.getNumeroProcessoPAD());
        }
        
        evento.setInfoDeslig(info);
        
        // Verbas rescisórias
        VerbasResc verbas = new VerbasResc();
        
        // Férias vencidas
        if (deslig.getValorFeriasVencidas() != null &&
            deslig.getValorFeriasVencidas().compareTo(BigDecimal.ZERO) > 0) {
            verbas.addDmDev(criarDmDev("1000", "FERIAS_VENCIDAS", 
                deslig.getValorFeriasVencidas()));
        }
        
        // Férias proporcionais
        if (deslig.getValorFeriasProporcionais() != null &&
            deslig.getValorFeriasProporcionais().compareTo(BigDecimal.ZERO) > 0) {
            verbas.addDmDev(criarDmDev("1001", "FERIAS_PROPORCIONAIS",
                deslig.getValorFeriasProporcionais()));
        }
        
        // 13º proporcional
        if (deslig.getValor13Proporcional() != null &&
            deslig.getValor13Proporcional().compareTo(BigDecimal.ZERO) > 0) {
            verbas.addDmDev(criarDmDev("5001", "13_PROPORCIONAL",
                deslig.getValor13Proporcional()));
        }
        
        evento.setVerbasResc(verbas);
        
        return toEsocialEvento(evento);
    }
    
    private String mapearMotivoDesligamento(TipoDesligamento tipo) {
        return switch (tipo) {
            case EXO -> "02"; // Rescisão sem justa causa, por iniciativa do empregado
            case EXD -> "07"; // Exoneração a pedido de servidor em cargo em comissão
            case DEM -> "10"; // Dispensa por justa causa
            case APO -> "15"; // Aposentadoria por tempo de contribuição
            case FAL -> "17"; // Falecimento
            case TCC -> "04"; // Término de contrato por prazo determinado
            default -> "99";
        };
    }
}
```

### 3.5 S-2230 - Afastamento Temporário

```java
/**
 * Evento S-2230: Afastamento Temporário
 */
@Service
public class S2230Builder {
    
    public EsocialEvento build(Afastamento afast) {
        
        S2230 evento = new S2230();
        VinculoFuncional vinculo = afast.getVinculo();
        
        // Identificação
        evento.setIdEvento(gerarIdEvento("S2230", vinculo));
        
        // Empregador
        evento.setTpInsc(1);
        evento.setNrInsc(getUnidadeGestora().getCnpj());
        
        // Trabalhador
        evento.setCpfTrab(vinculo.getServidor().getCpf());
        evento.setMatricula(vinculo.getMatricula());
        
        // Informações do afastamento
        InfoAfastamento info = new InfoAfastamento();
        info.setDtIniAfast(afast.getDataInicio());
        info.setCodMotAfast(mapearMotivoAfastamento(afast.getTipo()));
        
        // Se licença médica
        if (afast.getTipo() == TipoAfastamento.LM ||
            afast.getTipo() == TipoAfastamento.LTS) {
            
            InfoAtestado atestado = new InfoAtestado();
            atestado.setCodCID(afast.getCid());
            atestado.setQtdDiasAfast(afast.getDias());
            info.setInfoAtestado(atestado);
        }
        
        // Se cessão
        if (afast.getTipo() == TipoAfastamento.CES) {
            InfoCessao cessao = new InfoCessao();
            cessao.setCnpjCess(afast.getCnpjCessionario());
            info.setInfoCessao(cessao);
        }
        
        evento.setInfoAfastamento(info);
        
        // Término do afastamento (se já encerrado)
        if (afast.getDataFim() != null && 
            afast.getSituacao() == SituacaoAfastamento.ENCERRADO) {
            FimAfastamento fim = new FimAfastamento();
            fim.setDtTermAfast(afast.getDataFim());
            evento.setFimAfastamento(fim);
        }
        
        return toEsocialEvento(evento);
    }
    
    private String mapearMotivoAfastamento(TipoAfastamento tipo) {
        return switch (tipo) {
            case LM -> "01"; // Acidente/Doença do trabalho
            case LMA -> "17"; // Licença maternidade
            case LPA -> "18"; // Licença paternidade
            case LTS -> "03"; // Acidente/Doença não relacionada ao trabalho
            case LAC -> "01"; // Acidente de trabalho
            case SUS -> "21"; // Licença remunerada - Processo disciplinar
            case FAL, FAI -> "33"; // Outros motivos
            default -> "33";
        };
    }
}
```

---

## 4. SERVIÇOS DE INTEGRAÇÃO

### 4.1 EsocialEventoService

```java
@Service
@Transactional
public class EsocialEventoService extends AbstractTenantService {
    
    // Gerar eventos da competência
    public List<EsocialEvento> gerarEventosCompetencia(YearMonth competencia);
    
    // Gerar evento específico
    public EsocialEvento gerarEvento(String tipoEvento, Long vinculoId);
    
    // Validar evento contra XSD
    public ValidationResult validarEvento(Long eventoId);
    
    // Assinar evento
    public EsocialEvento assinarEvento(Long eventoId);
    
    // Enviar lote de eventos
    public LoteEnvio enviarLote(List<Long> eventoIds);
    
    // Consultar processamento
    public void consultarProcessamento(String protocoloEnvio);
    
    // Retificar evento
    public EsocialEvento retificarEvento(Long eventoId);
    
    // Excluir evento
    public EsocialEvento excluirEvento(Long eventoId, String motivo);
    
    // Listar eventos pendentes
    public List<EsocialEvento> listarPendentes();
    
    // Listar eventos com erro
    public List<EsocialEvento> listarComErro();
}
```

### 4.2 EsocialXmlService

```java
@Service
public class EsocialXmlService {
    
    /**
     * Gerar XML do evento conforme layout eSocial
     */
    public String gerarXml(EsocialEvento evento) {
        // Usar JAXB para serializar
        JAXBContext context = JAXBContext.newInstance(evento.getClass());
        Marshaller marshaller = context.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        
        StringWriter writer = new StringWriter();
        marshaller.marshal(evento, writer);
        return writer.toString();
    }
    
    /**
     * Validar XML contra XSD do eSocial
     */
    public ValidationResult validarXsd(String xml, String tipoEvento) {
        SchemaFactory factory = SchemaFactory.newInstance(
            XMLConstants.W3C_XML_SCHEMA_NS_URI);
        Schema schema = factory.newSchema(getXsdFile(tipoEvento));
        Validator validator = schema.newValidator();
        
        try {
            validator.validate(new StreamSource(new StringReader(xml)));
            return ValidationResult.success();
        } catch (SAXException e) {
            return ValidationResult.error(e.getMessage());
        }
    }
    
    /**
     * Assinar XML com certificado digital
     */
    public String assinarXml(String xml, CertificadoDigital cert) {
        // Implementar assinatura XMLDSig
        XMLSignatureFactory fac = XMLSignatureFactory.getInstance("DOM");
        
        // Referência ao documento
        Reference ref = fac.newReference("",
            fac.newDigestMethod(DigestMethod.SHA256, null),
            Collections.singletonList(
                fac.newTransform(Transform.ENVELOPED, (TransformParameterSpec) null)),
            null, null);
        
        // SignedInfo
        SignedInfo si = fac.newSignedInfo(
            fac.newCanonicalizationMethod(CanonicalizationMethod.INCLUSIVE,
                (C14NMethodParameterSpec) null),
            fac.newSignatureMethod(SignatureMethod.RSA_SHA256, null),
            Collections.singletonList(ref));
        
        // KeyInfo
        KeyInfoFactory kif = fac.getKeyInfoFactory();
        X509Data x509Data = kif.newX509Data(
            Collections.singletonList(cert.getCertificado()));
        KeyInfo ki = kif.newKeyInfo(Collections.singletonList(x509Data));
        
        // Criar assinatura
        XMLSignature signature = fac.newXMLSignature(si, ki);
        
        // Assinar
        Document doc = parseXml(xml);
        DOMSignContext dsc = new DOMSignContext(
            cert.getChavePrivada(), doc.getDocumentElement());
        signature.sign(dsc);
        
        return documentToString(doc);
    }
}
```

### 4.3 EsocialTransmissaoService

```java
@Service
public class EsocialTransmissaoService {
    
    private static final String URL_PRODUCAO = 
        "https://webservices.producaorestrita.esocial.gov.br";
    private static final String URL_HOMOLOGACAO = 
        "https://webservices.producaorestrita.esocial.gov.br";
    
    /**
     * Enviar lote de eventos
     */
    public LoteRetorno enviarLote(LoteEnvio lote) {
        // Criar envelope SOAP
        String soapEnvelope = criarEnvelopeEnvioLote(lote);
        
        // Configurar cliente SOAP com certificado
        SOAPConnectionFactory soapFactory = SOAPConnectionFactory.newInstance();
        SOAPConnection connection = soapFactory.createConnection();
        
        // Configurar SSL com certificado
        configurarSSL(lote.getCertificado());
        
        // Enviar
        SOAPMessage response = connection.call(
            createSOAPMessage(soapEnvelope), 
            getEndpointEnvio());
        
        // Processar retorno
        return parseLoteRetorno(response);
    }
    
    /**
     * Consultar processamento do lote
     */
    public ConsultaRetorno consultarLote(String protocoloEnvio, 
                                         CertificadoDigital cert) {
        String soapEnvelope = criarEnvelopeConsulta(protocoloEnvio);
        
        configurarSSL(cert);
        
        SOAPConnectionFactory soapFactory = SOAPConnectionFactory.newInstance();
        SOAPConnection connection = soapFactory.createConnection();
        
        SOAPMessage response = connection.call(
            createSOAPMessage(soapEnvelope),
            getEndpointConsulta());
        
        return parseConsultaRetorno(response);
    }
    
    /**
     * Processar retorno e atualizar status dos eventos
     */
    @Transactional
    public void processarRetorno(ConsultaRetorno retorno) {
        for (EventoRetorno evtRet : retorno.getEventos()) {
            EsocialEvento evento = eventoRepository
                .findByIdEvento(evtRet.getIdEvento())
                .orElseThrow();
            
            if (evtRet.isAceito()) {
                evento.setSituacao(SituacaoEvento.ACEITO);
                evento.setRecibo(evtRet.getRecibo());
            } else {
                evento.setSituacao(SituacaoEvento.REJEITADO);
                evento.setCodigoRetorno(evtRet.getCodigo());
                evento.setMensagemRetorno(evtRet.getMensagem());
            }
            
            evento.setXmlRetorno(evtRet.getXml());
            evento.setDataRetorno(LocalDateTime.now());
            
            eventoRepository.save(evento);
        }
    }
}
```

---

## 5. ENDPOINTS DA API

### 5.1 EsocialController

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| POST | `/api/esocial/gerar/{competencia}` | Gerar eventos | GESTOR+ |
| GET | `/api/esocial/eventos` | Listar eventos | ANALISTA+ |
| GET | `/api/esocial/eventos/{id}` | Buscar evento | ANALISTA+ |
| POST | `/api/esocial/validar/{id}` | Validar evento | GESTOR+ |
| POST | `/api/esocial/assinar/{id}` | Assinar evento | GESTOR+ |
| POST | `/api/esocial/enviar` | Enviar lote | ADMIN |
| GET | `/api/esocial/consultar/{protocolo}` | Consultar lote | ANALISTA+ |
| GET | `/api/esocial/pendentes` | Listar pendentes | ANALISTA+ |
| GET | `/api/esocial/erros` | Listar com erro | ANALISTA+ |

---

## 6. FLUXO DE TRANSMISSÃO

```
┌─────────────────────────────────────────────────────────┐
│              FLUXO TRANSMISSÃO eSocial                  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [1] GERAR EVENTOS                                      │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐                                        │
│  │ Processar   │──► Para cada servidor:                │
│  │ Folha       │    - Gerar S-1200 ou S-1202           │
│  └──────┬──────┘    - Gerar S-1210 (pagamentos)        │
│         │                                               │
│         ▼                                               │
│  [2] VALIDAR                                            │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐                                        │
│  │ Validar XSD │──► Eventos com erro vão para correção │
│  └──────┬──────┘                                        │
│         │                                               │
│         ▼                                               │
│  [3] ASSINAR                                            │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐                                        │
│  │ Certificado │──► A1 ou A3                           │
│  │ Digital     │                                        │
│  └──────┬──────┘                                        │
│         │                                               │
│         ▼                                               │
│  [4] ENVIAR LOTE                                        │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────┐                                        │
│  │ WebService  │──► Recebe protocolo                   │
│  │ eSocial     │                                        │
│  └──────┬──────┘                                        │
│         │                                               │
│         ▼                                               │
│  [5] CONSULTAR RETORNO                                  │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Processar retorno:                  │               │
│  │ - ACEITO: Armazenar recibo          │               │
│  │ - REJEITADO: Corrigir e reenviar    │               │
│  └─────────────────────────────────────┘               │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 7. TABELAS DE APOIO

### 7.1 Entidades de Referência (já existentes)

| Entidade | Tabela eSocial | Descrição |
|----------|----------------|-----------|
| EsocCategTrabalhador | Tabela 01 | Categorias de trabalhadores |
| EsocClassTributaria | Tabela 08 | Classificação tributária |
| EsocTipoDependente | Tabela 07 | Tipos de dependentes |
| EsocTipoArquivo | - | Tipos de eventos |
| EsocNatRubrica | Tabela 03 | Natureza das rubricas |

---

**Próximo Documento:** PARTE 9 - PCCS e Carreira
