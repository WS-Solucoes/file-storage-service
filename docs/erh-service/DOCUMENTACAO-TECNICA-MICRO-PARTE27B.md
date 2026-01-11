# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 27B
## Módulo de Processos Administrativos Disciplinares (PAD) - Serviços e API

---

## 5. SERVIÇOS

### 5.1 ProcessoAdministrativoService
```java
@Service
@Transactional
public class ProcessoAdministrativoService {
    
    @Autowired
    private ProcessoAdministrativoRepository processoRepository;
    
    @Autowired
    private ComissaoProcessanteRepository comissaoRepository;
    
    @Autowired
    private PenalidadeService penalidadeService;
    
    public ProcessoAdministrativo instaurar(InstauracaoProcessoDTO dto) {
        // Validar servidor
        Servidor servidor = servidorRepository.findById(dto.getServidorId())
            .orElseThrow(() -> new NotFoundException("Servidor não encontrado"));
        
        // Verificar se já existe processo ativo para o mesmo fato
        if (existeProcessoAtivoParaFato(servidor.getId(), dto.getDescricaoFatos())) {
            throw new BusinessException("Já existe processo ativo para o mesmo fato");
        }
        
        ProcessoAdministrativo processo = new ProcessoAdministrativo();
        processo.setNumeroProcesso(gerarNumeroProcesso(dto.getTipoProcesso()));
        processo.setAno(LocalDate.now().getYear());
        processo.setSequencial(getProximoSequencial(processo.getAno()));
        processo.setTipoProcesso(dto.getTipoProcesso());
        processo.setServidor(servidor);
        processo.setSituacao(SituacaoProcesso.INSTAURADO);
        processo.setDataAbertura(LocalDate.now());
        processo.setDataConhecimentoFato(dto.getDataConhecimentoFato());
        processo.setDataFato(dto.getDataFato());
        processo.setDescricaoFatos(dto.getDescricaoFatos());
        processo.setEnquadramentoLegal(dto.getEnquadramentoLegal());
        processo.setNumeroPortaria(dto.getNumeroPortaria());
        processo.setDataPortaria(dto.getDataPortaria());
        
        // Calcular prescrição
        processo.setDataPrescricao(calcularDataPrescricao(dto));
        
        // Definir prazo de conclusão
        int prazoDias = dto.getTipoProcesso() == TipoProcessoAdministrativo.PAD_SUMARIO ? 30 : 60;
        processo.setPrazoConclusaoDias(prazoDias);
        
        processo = processoRepository.save(processo);
        
        // Criar fase inicial
        criarFase(processo, TipoFaseProcesso.INSTAURACAO, LocalDate.now());
        
        // Registrar histórico
        registrarHistorico(processo, "Processo instaurado", null);
        
        // Notificar envolvidos
        notificarInstauracao(processo);
        
        return processo;
    }
    
    public void designarComissao(Long processoId, ComissaoDTO dto) {
        ProcessoAdministrativo processo = buscarProcesso(processoId);
        
        validarDesignacaoComissao(dto);
        
        ComissaoProcessante comissao = new ComissaoProcessante();
        comissao.setNumeroPortaria(dto.getNumeroPortaria());
        comissao.setDataPortaria(dto.getDataPortaria());
        comissao.setDataInicio(LocalDate.now());
        comissao.setTipoComissao(dto.getTipoComissao());
        comissao.setSituacao(SituacaoComissao.ATIVA);
        comissao.setProcesso(processo);
        
        comissao = comissaoRepository.save(comissao);
        
        // Adicionar membros
        for (MembroDTO membroDTO : dto.getMembros()) {
            MembroComissao membro = new MembroComissao();
            membro.setComissao(comissao);
            membro.setServidor(servidorRepository.findById(membroDTO.getServidorId()).orElseThrow());
            membro.setFuncao(membroDTO.getFuncao());
            membro.setDataDesignacao(LocalDate.now());
            membro.setAtivo(true);
            membroComissaoRepository.save(membro);
        }
        
        processo.setComissao(comissao);
        processoRepository.save(processo);
        
        registrarHistorico(processo, "Comissão designada", dto.getNumeroPortaria());
    }
    
    public void registrarCitacao(Long processoId, CitacaoDTO dto) {
        ProcessoAdministrativo processo = buscarProcesso(processoId);
        
        // Criar fase de citação
        FaseProcesso faseCitacao = criarFase(processo, TipoFaseProcesso.CITACAO, LocalDate.now());
        
        // Calcular prazo de defesa (10 dias úteis)
        LocalDate prazoDefesa = calcularDiasUteis(LocalDate.now(), 10);
        
        // Criar fase de defesa com prazo
        FaseProcesso faseDefesa = criarFase(processo, TipoFaseProcesso.DEFESA_ESCRITA, null);
        faseDefesa.setPrazoDias(10);
        faseDefesa.setPrazoFinal(prazoDefesa);
        faseProcessoRepository.save(faseDefesa);
        
        // Atualizar situação
        processo.setSituacao(SituacaoProcesso.CITACAO);
        processoRepository.save(processo);
        
        // Concluir fase de citação
        faseCitacao.setDataFim(LocalDate.now());
        faseCitacao.setSituacao(SituacaoFase.CONCLUIDA);
        faseProcessoRepository.save(faseCitacao);
        
        registrarHistorico(processo, "Servidor citado", "Prazo defesa: " + prazoDefesa);
        
        // Notificar servidor
        notificacaoService.enviar(NotificacaoDTO.builder()
            .usuarioId(processo.getServidor().getUsuario().getId())
            .tipo(TipoNotificacao.URGENTE)
            .titulo("Citação em Processo Administrativo")
            .mensagem(String.format(
                "Você foi citado no processo %s. Prazo para defesa: %s",
                processo.getNumeroProcesso(),
                prazoDefesa.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"))
            ))
            .build());
    }
    
    public void registrarDefesa(Long processoId, DefesaDTO dto) {
        ProcessoAdministrativo processo = buscarProcesso(processoId);
        
        DefesaProcesso defesa = new DefesaProcesso();
        defesa.setProcesso(processo);
        defesa.setTipoDefesa(dto.getTipoDefesa());
        defesa.setDataProtocolo(LocalDateTime.now());
        defesa.setNumeroProtocolo(gerarNumeroProtocolo());
        defesa.setConteudo(dto.getConteudo());
        
        // Verificar tempestividade
        FaseProcesso faseDefesa = buscarFaseAtiva(processo, TipoFaseProcesso.DEFESA_ESCRITA);
        defesa.setTempestiva(!LocalDate.now().isAfter(faseDefesa.getPrazoFinal()));
        
        if (dto.getAdvogadoId() != null) {
            defesa.setAdvogado(advogadoRepository.findById(dto.getAdvogadoId()).orElse(null));
        }
        
        defesa = defesaRepository.save(defesa);
        
        // Salvar documentos anexos
        if (dto.getDocumentos() != null) {
            for (MultipartFile arquivo : dto.getDocumentos()) {
                DocumentoDefesa doc = new DocumentoDefesa();
                doc.setDefesa(defesa);
                doc.setNomeArquivo(arquivo.getOriginalFilename());
                doc.setCaminho(documentoService.salvar(arquivo, "defesas/" + processo.getNumeroProcesso()));
                documentoDefesaRepository.save(doc);
            }
        }
        
        // Atualizar situação do processo
        processo.setSituacao(SituacaoProcesso.DEFESA);
        processoRepository.save(processo);
        
        // Concluir fase de defesa
        faseDefesa.setDataFim(LocalDate.now());
        faseDefesa.setSituacao(SituacaoFase.CONCLUIDA);
        faseProcessoRepository.save(faseDefesa);
        
        registrarHistorico(processo, "Defesa protocolada", defesa.getNumeroProtocolo());
    }
    
    public void julgar(Long processoId, JulgamentoDTO dto) {
        ProcessoAdministrativo processo = buscarProcesso(processoId);
        
        // Validar que está na fase correta
        if (processo.getSituacao() != SituacaoProcesso.RELATORIO) {
            throw new BusinessException("Processo não está na fase de julgamento");
        }
        
        processo.setResultado(dto.getResultado());
        processo.setFundamentacaoDecisao(dto.getFundamentacao());
        
        if (dto.getResultado() == ResultadoProcesso.APLICACAO_PENALIDADE) {
            PenalidadeAplicada penalidade = penalidadeService.aplicar(
                processo.getServidor().getId(),
                dto.getPenalidadeId(),
                processo.getId(),
                dto.getFundamentacao(),
                dto.getDuracaoDias()
            );
            processo.setPenalidadeAplicada(penalidade);
        }
        
        // Criar fase de julgamento
        FaseProcesso faseJulgamento = criarFase(processo, TipoFaseProcesso.JULGAMENTO, LocalDate.now());
        faseJulgamento.setDataFim(LocalDate.now());
        faseJulgamento.setSituacao(SituacaoFase.CONCLUIDA);
        faseProcessoRepository.save(faseJulgamento);
        
        processo.setSituacao(SituacaoProcesso.JULGAMENTO);
        processo.setDataEncerramento(LocalDate.now());
        processoRepository.save(processo);
        
        registrarHistorico(processo, "Processo julgado", dto.getResultado().getDescricao());
        
        // Notificar servidor
        notificarJulgamento(processo);
    }
    
    public void prorrogar(Long processoId, ProrrogacaoDTO dto) {
        ProcessoAdministrativo processo = buscarProcesso(processoId);
        
        // Validar limite de prorrogações
        int maxProrrogacoes = processo.getTipoProcesso() == TipoProcessoAdministrativo.PAD_SUMARIO ? 1 : 1;
        if (processo.getProrrogacoes() >= maxProrrogacoes) {
            throw new BusinessException("Limite de prorrogações atingido");
        }
        
        int diasProrrogacao = processo.getTipoProcesso() == TipoProcessoAdministrativo.PAD_SUMARIO ? 15 : 60;
        processo.setPrazoConclusaoDias(processo.getPrazoConclusaoDias() + diasProrrogacao);
        processo.setProrrogacoes(processo.getProrrogacoes() + 1);
        processoRepository.save(processo);
        
        registrarHistorico(processo, "Processo prorrogado", dto.getJustificativa());
    }
    
    private LocalDate calcularDataPrescricao(InstauracaoProcessoDTO dto) {
        // Buscar prazo de prescrição baseado no enquadramento mais grave
        int anosPrescriao = 5; // Demissão como padrão mais grave
        
        LocalDate dataBase = dto.getDataConhecimentoFato() != null 
            ? dto.getDataConhecimentoFato() 
            : dto.getDataFato();
        
        return dataBase.plusYears(anosPrescriao);
    }
    
    @Scheduled(cron = "0 0 8 * * *")
    public void verificarPrescricoes() {
        List<ProcessoAdministrativo> processos = processoRepository
            .findBySituacaoNotIn(Arrays.asList(
                SituacaoProcesso.ARQUIVADO, 
                SituacaoProcesso.CONCLUIDO, 
                SituacaoProcesso.PRESCRITO
            ));
        
        for (ProcessoAdministrativo processo : processos) {
            if (processo.getDataPrescricao() != null 
                && LocalDate.now().isAfter(processo.getDataPrescricao())) {
                
                processo.setSituacao(SituacaoProcesso.PRESCRITO);
                processo.setResultado(ResultadoProcesso.PRESCRICAO);
                processo.setDataEncerramento(LocalDate.now());
                processoRepository.save(processo);
                
                registrarHistorico(processo, "Processo prescrito", null);
                notificarPrescricao(processo);
            }
        }
    }
}
```

### 5.2 SindicanciaService
```java
@Service
@Transactional
public class SindicanciaService {
    
    public Sindicancia abrir(AberturaSindicanciaDTO dto) {
        Sindicancia sindicancia = new Sindicancia();
        sindicancia.setNumeroSindicancia(gerarNumeroSindicancia());
        sindicancia.setTipoSindicancia(dto.getTipoSindicancia());
        sindicancia.setSituacao(SituacaoSindicancia.ABERTA);
        sindicancia.setDataAbertura(LocalDate.now());
        sindicancia.setDataFato(dto.getDataFato());
        sindicancia.setDescricaoFatos(dto.getDescricaoFatos());
        sindicancia.setObjetoInvestigacao(dto.getObjetoInvestigacao());
        sindicancia.setPrazoDias(30);
        
        if (dto.getServidorInvestigadoId() != null) {
            sindicancia.setServidorInvestigado(
                servidorRepository.findById(dto.getServidorInvestigadoId()).orElse(null)
            );
        }
        
        return sindicanciaRepository.save(sindicancia);
    }
    
    public void designarSindicante(Long sindicanciaId, Long servidorId) {
        Sindicancia sindicancia = buscarSindicancia(sindicanciaId);
        Servidor sindicante = servidorRepository.findById(servidorId)
            .orElseThrow(() -> new NotFoundException("Servidor não encontrado"));
        
        // Validar que servidor é estável
        if (!sindicante.isEstavel()) {
            throw new BusinessException("Sindicante deve ser servidor estável");
        }
        
        sindicancia.setSindicante(sindicante);
        sindicancia.setSituacao(SituacaoSindicancia.EM_ANDAMENTO);
        sindicanciaRepository.save(sindicancia);
    }
    
    public void concluir(Long sindicanciaId, ConclusaoSindicanciaDTO dto) {
        Sindicancia sindicancia = buscarSindicancia(sindicanciaId);
        
        sindicancia.setResultado(dto.getResultado());
        sindicancia.setConclusaoParecer(dto.getParecer());
        sindicancia.setRecomendacao(dto.getRecomendacao());
        sindicancia.setDataConclusao(LocalDate.now());
        sindicancia.setSituacao(SituacaoSindicancia.CONCLUIDA);
        
        // Se resultado é instauração de PAD, criar processo
        if (dto.getResultado() == ResultadoSindicancia.INSTAURACAO_PAD 
            && sindicancia.getServidorInvestigado() != null) {
            
            ProcessoAdministrativo pad = processoService.instaurarAPartirSindicancia(sindicancia);
            sindicancia.setProcessoGerado(pad);
        }
        
        sindicanciaRepository.save(sindicancia);
    }
}
```

### 5.3 PenalidadeService
```java
@Service
@Transactional
public class PenalidadeService {
    
    public PenalidadeAplicada aplicar(Long servidorId, Long penalidadeId, 
                                       Long processoId, String fundamentacao, Integer duracaoDias) {
        Servidor servidor = servidorRepository.findById(servidorId)
            .orElseThrow(() -> new NotFoundException("Servidor não encontrado"));
        
        Penalidade penalidade = penalidadeRepository.findById(penalidadeId)
            .orElseThrow(() -> new NotFoundException("Penalidade não encontrada"));
        
        // Validar duração
        if (penalidade.getDuracaoMinimaDias() != null && duracaoDias < penalidade.getDuracaoMinimaDias()) {
            throw new BusinessException("Duração menor que o mínimo permitido");
        }
        if (penalidade.getDuracaoMaximaDias() != null && duracaoDias > penalidade.getDuracaoMaximaDias()) {
            throw new BusinessException("Duração maior que o máximo permitido");
        }
        
        PenalidadeAplicada aplicada = new PenalidadeAplicada();
        aplicada.setServidor(servidor);
        aplicada.setPenalidade(penalidade);
        aplicada.setProcesso(processoId != null ? processoRepository.findById(processoId).orElse(null) : null);
        aplicada.setDataAplicacao(LocalDate.now());
        aplicada.setDuracaoDias(duracaoDias);
        aplicada.setFundamentacao(fundamentacao);
        aplicada.setSituacao(SituacaoPenalidade.APLICADA);
        
        // Calcular datas de efeitos
        if (penalidade.getTipo() == TipoPenalidade.SUSPENSAO) {
            aplicada.setDataInicioEfeitos(LocalDate.now().plusDays(1));
            aplicada.setDataFimEfeitos(aplicada.getDataInicioEfeitos().plusDays(duracaoDias - 1));
        } else if (penalidade.getTipo() == TipoPenalidade.DEMISSAO) {
            aplicada.setDataInicioEfeitos(LocalDate.now());
        }
        
        aplicada = penalidadeAplicadaRepository.save(aplicada);
        
        // Registrar na ficha funcional
        if (penalidade.getGeraAnotacaoAssentamento()) {
            registrarNaFichaFuncional(aplicada);
            aplicada.setRegistradoFichaFuncional(true);
            penalidadeAplicadaRepository.save(aplicada);
        }
        
        // Executar efeitos da penalidade
        executarEfeitosPenalidade(aplicada);
        
        return aplicada;
    }
    
    private void executarEfeitosPenalidade(PenalidadeAplicada aplicada) {
        switch (aplicada.getPenalidade().getTipo()) {
            case SUSPENSAO:
                // Criar afastamento
                afastamentoService.criar(AfastamentoDTO.builder()
                    .servidorId(aplicada.getServidor().getId())
                    .tipoAfastamento(TipoAfastamento.SUSPENSAO_DISCIPLINAR)
                    .dataInicio(aplicada.getDataInicioEfeitos())
                    .dataFim(aplicada.getDataFimEfeitos())
                    .motivoId(aplicada.getId())
                    .build());
                break;
                
            case DEMISSAO:
                // Iniciar processo de desligamento
                desligamentoService.iniciar(DesligamentoDTO.builder()
                    .servidorId(aplicada.getServidor().getId())
                    .motivoDesligamento(MotivoDesligamento.DEMISSAO)
                    .dataDesligamento(aplicada.getDataInicioEfeitos())
                    .processoId(aplicada.getProcesso().getId())
                    .build());
                break;
                
            case CASSACAO_APOSENTADORIA:
                // Cessar benefício
                beneficioService.cessar(aplicada.getServidor().getId(), 
                    "Cassação por penalidade disciplinar");
                break;
        }
    }
    
    public void cancelar(Long penalidadeAplicadaId, String motivo) {
        PenalidadeAplicada aplicada = penalidadeAplicadaRepository.findById(penalidadeAplicadaId)
            .orElseThrow();
        
        aplicada.setSituacao(SituacaoPenalidade.CANCELADA);
        aplicada.setDataCancelamento(LocalDate.now());
        aplicada.setMotivoCancelamento(motivo);
        penalidadeAplicadaRepository.save(aplicada);
        
        // Reverter efeitos se necessário
        reverterEfeitosPenalidade(aplicada);
    }
}
```

### 5.4 RecursoService
```java
@Service
@Transactional
public class RecursoService {
    
    public RecursoAdministrativo protocolar(RecursoDTO dto) {
        ProcessoAdministrativo processo = processoRepository.findById(dto.getProcessoId())
            .orElseThrow();
        
        // Validar prazo (10 dias)
        LocalDate dataJulgamento = processo.getDataEncerramento();
        if (LocalDate.now().isAfter(dataJulgamento.plusDays(10))) {
            throw new BusinessException("Prazo para recurso expirado");
        }
        
        RecursoAdministrativo recurso = new RecursoAdministrativo();
        recurso.setProcesso(processo);
        recurso.setTipoRecurso(dto.getTipoRecurso());
        recurso.setDataProtocolo(LocalDateTime.now());
        recurso.setNumeroProtocolo(gerarNumeroProtocolo());
        recurso.setFundamentacao(dto.getFundamentacao());
        recurso.setPedido(dto.getPedido());
        recurso.setSituacao(SituacaoRecurso.PROTOCOLADO);
        recurso.setInstancia(1);
        
        if (dto.getPenalidadeAplicadaId() != null) {
            recurso.setPenalidadeAplicada(
                penalidadeAplicadaRepository.findById(dto.getPenalidadeAplicadaId()).orElse(null)
            );
        }
        
        recurso = recursoRepository.save(recurso);
        
        // Atualizar situação do processo
        processo.setSituacao(SituacaoProcesso.RECURSO);
        processoRepository.save(processo);
        
        return recurso;
    }
    
    public void julgar(Long recursoId, JulgamentoRecursoDTO dto) {
        RecursoAdministrativo recurso = recursoRepository.findById(recursoId)
            .orElseThrow();
        
        recurso.setResultado(dto.getResultado());
        recurso.setFundamentacaoDecisao(dto.getFundamentacao());
        recurso.setDataJulgamento(LocalDate.now());
        recurso.setSituacao(SituacaoRecurso.JULGADO);
        recurso.setJulgadoPor(getUsuarioLogado());
        
        recursoRepository.save(recurso);
        
        // Se provido, reverter ou modificar penalidade
        if (dto.getResultado() == ResultadoRecurso.PROVIDO && recurso.getPenalidadeAplicada() != null) {
            penalidadeService.cancelar(recurso.getPenalidadeAplicada().getId(), 
                "Recurso provido");
        } else if (dto.getResultado() == ResultadoRecurso.PARCIALMENTE_PROVIDO) {
            // Aplicar nova penalidade se definida
            if (dto.getNovaPenalidadeId() != null) {
                // Cancelar atual e aplicar nova
                penalidadeService.cancelar(recurso.getPenalidadeAplicada().getId(), 
                    "Recurso parcialmente provido");
                penalidadeService.aplicar(
                    recurso.getProcesso().getServidor().getId(),
                    dto.getNovaPenalidadeId(),
                    recurso.getProcesso().getId(),
                    dto.getFundamentacao(),
                    dto.getNovaDuracaoDias()
                );
            }
        }
        
        // Atualizar processo
        ProcessoAdministrativo processo = recurso.getProcesso();
        processo.setSituacao(SituacaoProcesso.CONCLUIDO);
        processoRepository.save(processo);
    }
}
```

---

## 6. API REST

### 6.1 Endpoints

```
# Processos Administrativos
GET    /api/v1/processos-administrativos                      # Lista processos
GET    /api/v1/processos-administrativos/{id}                 # Busca processo
POST   /api/v1/processos-administrativos                      # Instaurar
PUT    /api/v1/processos-administrativos/{id}                 # Atualizar
POST   /api/v1/processos-administrativos/{id}/comissao        # Designar comissão
POST   /api/v1/processos-administrativos/{id}/citacao         # Registrar citação
POST   /api/v1/processos-administrativos/{id}/defesa          # Registrar defesa
POST   /api/v1/processos-administrativos/{id}/julgamento      # Julgar
POST   /api/v1/processos-administrativos/{id}/prorrogacao     # Prorrogar
GET    /api/v1/processos-administrativos/{id}/historico       # Histórico
GET    /api/v1/processos-administrativos/{id}/documentos      # Documentos

# Sindicâncias
GET    /api/v1/sindicancias                                   # Lista
POST   /api/v1/sindicancias                                   # Abrir
GET    /api/v1/sindicancias/{id}                              # Busca
PUT    /api/v1/sindicancias/{id}/sindicante                   # Designar
POST   /api/v1/sindicancias/{id}/conclusao                    # Concluir

# Penalidades
GET    /api/v1/penalidades                                    # Lista tipos
POST   /api/v1/penalidades-aplicadas                          # Aplicar
GET    /api/v1/penalidades-aplicadas/servidor/{id}            # Por servidor
PUT    /api/v1/penalidades-aplicadas/{id}/cancelar            # Cancelar

# Recursos
POST   /api/v1/recursos                                       # Protocolar
GET    /api/v1/recursos/{id}                                  # Busca
POST   /api/v1/recursos/{id}/julgamento                       # Julgar

# Comissões
GET    /api/v1/comissoes                                      # Lista
POST   /api/v1/comissoes                                      # Criar
PUT    /api/v1/comissoes/{id}/membros                         # Gerenciar membros
```

---

## 7. FRONTEND

### 7.1 Componentes React

```typescript
// ProcessosList.tsx
export const ProcessosList: React.FC = () => {
  const [filtros, setFiltros] = useState<FiltroProcessoDTO>({});
  const { data: processos, isLoading } = useProcessos(filtros);
  
  const getSituacaoBadge = (situacao: SituacaoProcesso) => {
    const cores: Record<string, string> = {
      'INSTAURADO': 'bg-blue-100 text-blue-800',
      'EM_INSTRUCAO': 'bg-yellow-100 text-yellow-800',
      'DEFESA': 'bg-purple-100 text-purple-800',
      'JULGAMENTO': 'bg-orange-100 text-orange-800',
      'CONCLUIDO': 'bg-green-100 text-green-800',
      'ARQUIVADO': 'bg-gray-100 text-gray-800',
      'PRESCRITO': 'bg-red-100 text-red-800',
    };
    return cores[situacao] || 'bg-gray-100';
  };
  
  return (
    <Card>
      <CardHeader>
        <CardTitle>Processos Administrativos</CardTitle>
        <Button onClick={() => setShowNovoProcesso(true)}>
          <Plus className="h-4 w-4 mr-2" />
          Novo Processo
        </Button>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Nº Processo</TableHead>
              <TableHead>Tipo</TableHead>
              <TableHead>Servidor</TableHead>
              <TableHead>Situação</TableHead>
              <TableHead>Data Abertura</TableHead>
              <TableHead>Prazo</TableHead>
              <TableHead>Ações</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {processos?.map((processo) => (
              <TableRow key={processo.id}>
                <TableCell className="font-medium">
                  {processo.numeroProcesso}
                </TableCell>
                <TableCell>{processo.tipoProcesso}</TableCell>
                <TableCell>{processo.servidor.nome}</TableCell>
                <TableCell>
                  <Badge className={getSituacaoBadge(processo.situacao)}>
                    {processo.situacao}
                  </Badge>
                </TableCell>
                <TableCell>
                  {format(processo.dataAbertura, 'dd/MM/yyyy')}
                </TableCell>
                <TableCell>
                  <PrazoIndicator processo={processo} />
                </TableCell>
                <TableCell>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="sm">
                        <MoreHorizontal className="h-4 w-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent>
                      <DropdownMenuItem onClick={() => verDetalhes(processo.id)}>
                        Ver Detalhes
                      </DropdownMenuItem>
                      <DropdownMenuItem onClick={() => verHistorico(processo.id)}>
                        Histórico
                      </DropdownMenuItem>
                      <DropdownMenuSeparator />
                      <DropdownMenuItem onClick={() => registrarAndamento(processo.id)}>
                        Registrar Andamento
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </CardContent>
    </Card>
  );
};

// ProcessoTimeline.tsx
export const ProcessoTimeline: React.FC<{ processoId: number }> = ({ processoId }) => {
  const { data: fases } = useFasesProcesso(processoId);
  
  return (
    <div className="relative">
      <div className="absolute left-4 top-0 h-full w-0.5 bg-gray-200" />
      {fases?.map((fase, index) => (
        <div key={fase.id} className="relative pl-10 pb-8">
          <div className={cn(
            "absolute left-2 w-4 h-4 rounded-full border-2",
            fase.situacao === 'CONCLUIDA' ? "bg-green-500 border-green-500" :
            fase.situacao === 'EM_ANDAMENTO' ? "bg-blue-500 border-blue-500" :
            "bg-white border-gray-300"
          )} />
          <div className="bg-white p-4 rounded-lg shadow-sm border">
            <div className="flex justify-between items-start">
              <div>
                <h4 className="font-medium">{fase.fase}</h4>
                <p className="text-sm text-gray-500">
                  Início: {format(fase.dataInicio, 'dd/MM/yyyy')}
                  {fase.dataFim && ` | Fim: ${format(fase.dataFim, 'dd/MM/yyyy')}`}
                </p>
              </div>
              <Badge variant={fase.situacao === 'CONCLUIDA' ? 'success' : 'default'}>
                {fase.situacao}
              </Badge>
            </div>
            {fase.observacoes && (
              <p className="mt-2 text-sm text-gray-600">{fase.observacoes}</p>
            )}
          </div>
        </div>
      ))}
    </div>
  );
};
```

---

## 8. RELATÓRIOS

| Relatório | Descrição |
|-----------|-----------|
| Processos por Situação | Quantidade de processos por situação |
| Processos por Período | Processos instaurados no período |
| Penalidades Aplicadas | Penalidades por tipo e período |
| Processos Próximos Prescrição | Alertas de prescrição |
| Desempenho Comissões | Tempo médio de conclusão |
| Estatísticas Gerais | Dashboard de PAD |

---

## 9. CONSIDERAÇÕES FINAIS

### 9.1 Integração com Outros Módulos
- **Servidor**: Dados do acusado
- **Folha**: Efeitos de suspensão/demissão
- **Documentos**: GED para processo digital
- **Auditoria**: Rastreabilidade total
- **Notificações**: Alertas de prazos

### 9.2 Conformidade Legal
- Lei 8.112/90 (Federal)
- Estatuto do Servidor Municipal
- Princípios do contraditório e ampla defesa
- Due process of law
