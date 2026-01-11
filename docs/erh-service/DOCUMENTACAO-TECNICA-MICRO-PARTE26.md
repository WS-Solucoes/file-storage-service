# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 26
## Módulo de Dashboards e Indicadores

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Fornecer painéis gerenciais e indicadores de desempenho (KPIs) para apoio à tomada de decisão, permitindo visão consolidada de dados de RH, folha de pagamento e gestão de pessoas.

### 1.2 Escopo
- Dashboards executivos
- KPIs de RH
- Indicadores de folha
- Relatórios gerenciais
- Análises comparativas
- Gráficos e visualizações
- Exportação de dados

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### Dashboard
```java
@Entity
@Table(name = "dashboard")
public class Dashboard {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String codigo;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoDashboard tipo;
    
    @Column(name = "layout_config", columnDefinition = "TEXT")
    private String layoutConfig; // JSON
    
    @ElementCollection
    @CollectionTable(name = "dashboard_perfis")
    @Column(name = "perfil")
    private Set<String> perfisAcesso;
    
    @Column(name = "publico")
    private Boolean publico = false;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "criado_por")
    private Usuario criadoPor;
    
    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @Column(name = "ordem")
    private Integer ordem;
    
    @OneToMany(mappedBy = "dashboard", cascade = CascadeType.ALL)
    private List<WidgetDashboard> widgets;
}
```

#### WidgetDashboard
```java
@Entity
@Table(name = "widget_dashboard")
public class WidgetDashboard {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dashboard_id", nullable = false)
    private Dashboard dashboard;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "indicador_id")
    private Indicador indicador;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TipoWidget tipoWidget;
    
    @Column(nullable = false, length = 200)
    private String titulo;
    
    @Column(name = "posicao_x")
    private Integer posicaoX;
    
    @Column(name = "posicao_y")
    private Integer posicaoY;
    
    @Column(name = "largura")
    private Integer largura = 1;
    
    @Column(name = "altura")
    private Integer altura = 1;
    
    @Column(name = "configuracao", columnDefinition = "TEXT")
    private String configuracao; // JSON
    
    @Column(name = "intervalo_atualizacao")
    private Integer intervaloAtualizacao; // segundos
    
    @Enumerated(EnumType.STRING)
    @Column(name = "cor_tema")
    private CorTema corTema;
}
```

#### Indicador
```java
@Entity
@Table(name = "indicador")
public class Indicador {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50, unique = true)
    private String codigo;
    
    @Column(nullable = false, length = 200)
    private String nome;
    
    @Column(columnDefinition = "TEXT")
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CategoriaIndicador categoria;
    
    @Column(name = "formula", columnDefinition = "TEXT")
    private String formula;
    
    @Column(name = "query_sql", columnDefinition = "TEXT")
    private String querySql;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_dado")
    private TipoDadoIndicador tipoDado;
    
    @Column(name = "unidade", length = 20)
    private String unidade; // %, R$, dias, etc.
    
    @Column(name = "casas_decimais")
    private Integer casasDecimais = 2;
    
    @Column(name = "meta")
    private BigDecimal meta;
    
    @Column(name = "limite_inferior")
    private BigDecimal limiteInferior;
    
    @Column(name = "limite_superior")
    private BigDecimal limiteSuperior;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "sentido")
    private SentidoIndicador sentido; // MAIOR_MELHOR, MENOR_MELHOR
    
    @ElementCollection
    @CollectionTable(name = "indicador_dimensoes")
    @Column(name = "dimensao")
    private Set<String> dimensoes;
    
    @Column(name = "cache_minutos")
    private Integer cacheMinutos = 60;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### ValorIndicador
```java
@Entity
@Table(name = "valor_indicador", indexes = {
    @Index(name = "idx_valor_ind_periodo", columnList = "indicador_id, competencia")
})
public class ValorIndicador {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "indicador_id", nullable = false)
    private Indicador indicador;
    
    @Column(nullable = false, length = 7)
    private String competencia; // YYYY-MM
    
    @Column(name = "valor", precision = 18, scale = 4)
    private BigDecimal valor;
    
    @Column(name = "valor_anterior", precision = 18, scale = 4)
    private BigDecimal valorAnterior;
    
    @Column(name = "variacao_percentual", precision = 10, scale = 2)
    private BigDecimal variacaoPercentual;
    
    @Column(name = "dimensao_chave", length = 100)
    private String dimensaoChave;
    
    @Column(name = "dimensao_valor", length = 200)
    private String dimensaoValor;
    
    @Column(name = "data_calculo", nullable = false)
    private LocalDateTime dataCalculo;
    
    @Column(name = "dados_detalhados", columnDefinition = "TEXT")
    private String dadosDetalhados; // JSON
}
```

#### FiltroRelatorio
```java
@Entity
@Table(name = "filtro_relatorio")
public class FiltroRelatorio {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario usuario;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Column(name = "codigo_relatorio", nullable = false, length = 50)
    private String codigoRelatorio;
    
    @Column(name = "filtros", nullable = false, columnDefinition = "TEXT")
    private String filtros; // JSON
    
    @Column(name = "padrao")
    private Boolean padrao = false;
    
    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum TipoDashboard {
    EXECUTIVO("Executivo"),
    GERENCIAL("Gerencial"),
    OPERACIONAL("Operacional"),
    ANALITICO("Analítico"),
    PERSONALIZADO("Personalizado");
}

public enum TipoWidget {
    CARD_KPI("Card KPI"),
    GRAFICO_LINHA("Gráfico de Linha"),
    GRAFICO_BARRA("Gráfico de Barras"),
    GRAFICO_PIZZA("Gráfico de Pizza"),
    GRAFICO_AREA("Gráfico de Área"),
    GRAFICO_ROSCA("Gráfico Rosca"),
    TABELA("Tabela"),
    LISTA("Lista"),
    GAUGE("Gauge/Velocímetro"),
    MAPA_CALOR("Mapa de Calor"),
    TIMELINE("Linha do Tempo"),
    COMPARATIVO("Comparativo"),
    RANKING("Ranking");
}

public enum CategoriaIndicador {
    QUADRO_PESSOAL("Quadro de Pessoal"),
    REMUNERACAO("Remuneração"),
    ABSENTEISMO("Absenteísmo"),
    TURNOVER("Turnover"),
    CAPACITACAO("Capacitação"),
    AVALIACAO("Avaliação"),
    CUSTOS("Custos"),
    PROCESSOS("Processos"),
    COMPLIANCE("Compliance");
}

public enum TipoDadoIndicador {
    NUMERO("Número"),
    PERCENTUAL("Percentual"),
    MOEDA("Moeda"),
    TEXTO("Texto"),
    DATA("Data");
}

public enum SentidoIndicador {
    MAIOR_MELHOR("Quanto maior, melhor"),
    MENOR_MELHOR("Quanto menor, melhor"),
    NEUTRO("Neutro");
}

public enum CorTema {
    AZUL("blue"),
    VERDE("green"),
    VERMELHO("red"),
    AMARELO("yellow"),
    ROXO("purple"),
    LARANJA("orange"),
    CINZA("gray");
}
```

---

## 4. INDICADORES PADRÃO

### 4.1 Quadro de Pessoal

| Código | Nome | Fórmula | Meta |
|--------|------|---------|------|
| QP-001 | Total Servidores Ativos | COUNT(servidores WHERE situacao='ATIVO') | - |
| QP-002 | Total por Vínculo | GROUP BY tipoVinculo | - |
| QP-003 | Média de Idade | AVG(idade) | - |
| QP-004 | Tempo Médio Serviço | AVG(anos_servico) | - |
| QP-005 | Servidores Aposentáveis | COUNT(tempo_servico >= 25) | - |
| QP-006 | Distribuição por Sexo | GROUP BY sexo | - |
| QP-007 | Distribuição por Escolaridade | GROUP BY escolaridade | - |
| QP-008 | Pirâmide Etária | GROUP BY faixa_etaria, sexo | - |

### 4.2 Remuneração

| Código | Nome | Fórmula | Meta |
|--------|------|---------|------|
| REM-001 | Folha Total Bruta | SUM(total_bruto) | - |
| REM-002 | Folha Total Líquida | SUM(total_liquido) | - |
| REM-003 | Média Salarial | AVG(salario_base) | - |
| REM-004 | Custo por Servidor | Folha Total / Total Servidores | - |
| REM-005 | % Despesa Pessoal | Folha / Receita * 100 | <54% |
| REM-006 | Horas Extras | SUM(valor_horas_extras) | - |
| REM-007 | Gratificações | SUM(gratificacoes) | - |
| REM-008 | Encargos Patronais | SUM(inss_patronal + fgts) | - |

### 4.3 Absenteísmo

| Código | Nome | Fórmula | Meta |
|--------|------|---------|------|
| ABS-001 | Taxa Absenteísmo | (Dias Ausência / Dias Trabalho) * 100 | <3% |
| ABS-002 | Faltas Justificadas | COUNT(faltas WHERE justificada) | - |
| ABS-003 | Faltas Injustificadas | COUNT(faltas WHERE !justificada) | 0 |
| ABS-004 | Afastamentos Saúde | COUNT(atestados) | - |
| ABS-005 | Dias Perdidos | SUM(dias_afastamento) | - |
| ABS-006 | Motivos Afastamento | GROUP BY motivo | - |

### 4.4 Turnover

| Código | Nome | Fórmula | Meta |
|--------|------|---------|------|
| TRN-001 | Taxa Turnover | ((Admissões + Demissões) / 2) / Total * 100 | <5% |
| TRN-002 | Taxa Admissão | Admissões / Total * 100 | - |
| TRN-003 | Taxa Desligamento | Desligamentos / Total * 100 | <3% |
| TRN-004 | Motivos Desligamento | GROUP BY motivo_desligamento | - |
| TRN-005 | Tempo Médio Casa | AVG(tempo_servico_desligados) | - |

### 4.5 Capacitação

| Código | Nome | Fórmula | Meta |
|--------|------|---------|------|
| CAP-001 | Horas Treinamento/Servidor | Total Horas / Total Servidores | 40h/ano |
| CAP-002 | Investimento Capacitação | SUM(custos_treinamento) | - |
| CAP-003 | Taxa Participação | Participantes / Convocados * 100 | >80% |
| CAP-004 | Taxa Conclusão | Concluintes / Inscritos * 100 | >90% |
| CAP-005 | Satisfação Treinamentos | AVG(nota_avaliacao) | >4 |

---

## 5. SERVIÇOS

### 5.1 DashboardService
```java
@Service
@Transactional
public class DashboardService {
    
    @Autowired
    private DashboardRepository dashboardRepository;
    
    @Autowired
    private IndicadorService indicadorService;
    
    public DashboardDTO getDashboard(String codigo, FiltroDTO filtros) {
        Dashboard dashboard = dashboardRepository.findByCodigo(codigo)
            .orElseThrow(() -> new NotFoundException("Dashboard não encontrado"));
        
        verificarAcesso(dashboard);
        
        DashboardDTO dto = new DashboardDTO();
        dto.setId(dashboard.getId());
        dto.setCodigo(dashboard.getCodigo());
        dto.setNome(dashboard.getNome());
        dto.setLayoutConfig(dashboard.getLayoutConfig());
        
        // Carregar dados dos widgets
        List<WidgetDTO> widgetsDTO = new ArrayList<>();
        for (WidgetDashboard widget : dashboard.getWidgets()) {
            WidgetDTO widgetDTO = carregarDadosWidget(widget, filtros);
            widgetsDTO.add(widgetDTO);
        }
        dto.setWidgets(widgetsDTO);
        
        return dto;
    }
    
    private WidgetDTO carregarDadosWidget(WidgetDashboard widget, FiltroDTO filtros) {
        WidgetDTO dto = new WidgetDTO();
        dto.setId(widget.getId());
        dto.setTitulo(widget.getTitulo());
        dto.setTipoWidget(widget.getTipoWidget());
        dto.setPosicao(new PosicaoDTO(widget.getPosicaoX(), widget.getPosicaoY()));
        dto.setTamanho(new TamanhoDTO(widget.getLargura(), widget.getAltura()));
        dto.setCorTema(widget.getCorTema());
        
        if (widget.getIndicador() != null) {
            Object dados = indicadorService.calcularIndicador(
                widget.getIndicador().getCodigo(), 
                filtros
            );
            dto.setDados(dados);
        }
        
        return dto;
    }
    
    public Dashboard criarDashboardPersonalizado(DashboardCriacaoDTO dto) {
        Dashboard dashboard = new Dashboard();
        dashboard.setCodigo("CUSTOM_" + UUID.randomUUID().toString().substring(0, 8));
        dashboard.setNome(dto.getNome());
        dashboard.setDescricao(dto.getDescricao());
        dashboard.setTipo(TipoDashboard.PERSONALIZADO);
        dashboard.setPublico(false);
        dashboard.setCriadoPor(getUsuarioLogado());
        dashboard.setDataCriacao(LocalDateTime.now());
        dashboard.setAtivo(true);
        
        return dashboardRepository.save(dashboard);
    }
}
```

### 5.2 IndicadorService
```java
@Service
@Transactional
public class IndicadorService {
    
    @Autowired
    private IndicadorRepository indicadorRepository;
    
    @Autowired
    private ValorIndicadorRepository valorRepository;
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    @Cacheable(value = "indicadores", key = "#codigo + '_' + #filtros.hashCode()")
    public Object calcularIndicador(String codigo, FiltroDTO filtros) {
        Indicador indicador = indicadorRepository.findByCodigo(codigo)
            .orElseThrow(() -> new NotFoundException("Indicador não encontrado"));
        
        // Verificar cache de valor calculado
        Optional<ValorIndicador> valorCache = valorRepository
            .findByIndicadorAndCompetencia(indicador, filtros.getCompetencia());
        
        if (valorCache.isPresent() && !isCacheExpirado(valorCache.get(), indicador)) {
            return converterParaDTO(valorCache.get(), indicador);
        }
        
        // Calcular valor
        Object resultado;
        if (indicador.getQuerySql() != null) {
            resultado = executarQuery(indicador, filtros);
        } else {
            resultado = calcularPorFormula(indicador, filtros);
        }
        
        // Salvar no cache
        salvarValorCalculado(indicador, filtros.getCompetencia(), resultado);
        
        return resultado;
    }
    
    private Object executarQuery(Indicador indicador, FiltroDTO filtros) {
        String sql = indicador.getQuerySql();
        
        // Substituir parâmetros na query
        sql = sql.replace(":competencia", "'" + filtros.getCompetencia() + "'");
        if (filtros.getOrgaoId() != null) {
            sql = sql.replace(":orgaoId", filtros.getOrgaoId().toString());
        }
        if (filtros.getLotacaoId() != null) {
            sql = sql.replace(":lotacaoId", filtros.getLotacaoId().toString());
        }
        
        // Executar query
        switch (indicador.getTipoWidget()) {
            case CARD_KPI:
            case GAUGE:
                return jdbcTemplate.queryForObject(sql, BigDecimal.class);
            
            case GRAFICO_LINHA:
            case GRAFICO_BARRA:
            case GRAFICO_AREA:
                return jdbcTemplate.queryForList(sql);
            
            case TABELA:
            case RANKING:
                return jdbcTemplate.queryForList(sql);
            
            default:
                return jdbcTemplate.queryForList(sql);
        }
    }
    
    public List<IndicadorResumoDTO> getIndicadoresPorCategoria(CategoriaIndicador categoria) {
        return indicadorRepository.findByCategoriaAndAtivo(categoria, true)
            .stream()
            .map(this::toResumoDTO)
            .collect(Collectors.toList());
    }
    
    public HistoricoIndicadorDTO getHistorico(String codigo, int meses) {
        Indicador indicador = indicadorRepository.findByCodigo(codigo).orElseThrow();
        
        YearMonth atual = YearMonth.now();
        List<ValorIndicador> valores = valorRepository.findHistorico(
            indicador,
            atual.minusMonths(meses).toString(),
            atual.toString()
        );
        
        HistoricoIndicadorDTO dto = new HistoricoIndicadorDTO();
        dto.setIndicador(toResumoDTO(indicador));
        dto.setValores(valores.stream()
            .map(v -> new PontoHistoricoDTO(v.getCompetencia(), v.getValor()))
            .collect(Collectors.toList()));
        dto.setTendencia(calcularTendencia(valores));
        
        return dto;
    }
    
    private TendenciaDTO calcularTendencia(List<ValorIndicador> valores) {
        if (valores.size() < 2) {
            return new TendenciaDTO(TipoTendencia.ESTAVEL, BigDecimal.ZERO);
        }
        
        BigDecimal primeiro = valores.get(0).getValor();
        BigDecimal ultimo = valores.get(valores.size() - 1).getValor();
        BigDecimal variacao = ultimo.subtract(primeiro)
            .divide(primeiro, 4, RoundingMode.HALF_UP)
            .multiply(BigDecimal.valueOf(100));
        
        TipoTendencia tipo;
        if (variacao.compareTo(BigDecimal.valueOf(5)) > 0) {
            tipo = TipoTendencia.CRESCENTE;
        } else if (variacao.compareTo(BigDecimal.valueOf(-5)) < 0) {
            tipo = TipoTendencia.DECRESCENTE;
        } else {
            tipo = TipoTendencia.ESTAVEL;
        }
        
        return new TendenciaDTO(tipo, variacao);
    }
}
```

### 5.3 RelatorioGerencialService
```java
@Service
public class RelatorioGerencialService {
    
    public byte[] gerarRelatorioDemografico(FiltroDTO filtros) {
        Map<String, Object> dados = new HashMap<>();
        
        // Total por vínculo
        dados.put("totalPorVinculo", servidorRepository
            .countGroupByTipoVinculo(filtros.getOrgaoId()));
        
        // Distribuição por sexo
        dados.put("distribuicaoSexo", servidorRepository
            .countGroupBySexo(filtros.getOrgaoId()));
        
        // Pirâmide etária
        dados.put("piramideEtaria", servidorRepository
            .getPiramideEtaria(filtros.getOrgaoId()));
        
        // Distribuição por escolaridade
        dados.put("distribuicaoEscolaridade", servidorRepository
            .countGroupByEscolaridade(filtros.getOrgaoId()));
        
        // Média de idade e tempo de serviço
        dados.put("mediaIdade", servidorRepository.getMediaIdade(filtros.getOrgaoId()));
        dados.put("mediaTempoServico", servidorRepository.getMediaTempoServico(filtros.getOrgaoId()));
        
        return jasperService.gerarPdf("relatorio_demografico", dados);
    }
    
    public byte[] gerarRelatorioFolha(String competencia, FiltroDTO filtros) {
        Map<String, Object> dados = new HashMap<>();
        
        // Totais
        dados.put("totalBruto", folhaRepository.getTotalBruto(competencia, filtros));
        dados.put("totalLiquido", folhaRepository.getTotalLiquido(competencia, filtros));
        dados.put("totalDescontos", folhaRepository.getTotalDescontos(competencia, filtros));
        
        // Composição da folha
        dados.put("composicaoRubricas", folhaRepository
            .getComposicaoPorRubrica(competencia, filtros));
        
        // Comparativo com mês anterior
        String competenciaAnterior = YearMonth.parse(competencia)
            .minusMonths(1).toString();
        dados.put("variacaoMesAnterior", calcularVariacao(competencia, competenciaAnterior, filtros));
        
        // Top 10 maiores salários
        dados.put("topSalarios", folhaRepository
            .getTopSalarios(competencia, filtros, 10));
        
        return jasperService.gerarPdf("relatorio_folha_gerencial", dados);
    }
    
    public byte[] gerarRelatorioAbsenteismo(YearMonth mes, FiltroDTO filtros) {
        Map<String, Object> dados = new HashMap<>();
        
        // Taxa de absenteísmo
        dados.put("taxaAbsenteismo", calcularTaxaAbsenteismo(mes, filtros));
        
        // Motivos de afastamento
        dados.put("motivosAfastamento", afastamentoRepository
            .countGroupByMotivo(mes, filtros));
        
        // Dias perdidos por setor
        dados.put("diasPerdidosPorSetor", afastamentoRepository
            .sumDiasPorSetor(mes, filtros));
        
        // Evolução últimos 12 meses
        dados.put("evolucao12Meses", calcularEvolucaoAbsenteismo(mes, 12, filtros));
        
        return jasperService.gerarPdf("relatorio_absenteismo", dados);
    }
}
```

### 5.4 ProcessamentoIndicadoresJob
```java
@Service
public class ProcessamentoIndicadoresJob {
    
    @Scheduled(cron = "0 0 2 * * *") // Todo dia às 2h
    public void processarIndicadoresDiarios() {
        log.info("Iniciando processamento de indicadores diários");
        
        List<Indicador> indicadores = indicadorRepository
            .findByAtivoAndProcessamentoDiario(true);
        
        String competenciaAtual = YearMonth.now().toString();
        
        for (Indicador indicador : indicadores) {
            try {
                processarIndicador(indicador, competenciaAtual);
            } catch (Exception e) {
                log.error("Erro ao processar indicador {}: {}", 
                    indicador.getCodigo(), e.getMessage());
            }
        }
        
        log.info("Processamento de indicadores diários concluído");
    }
    
    @Scheduled(cron = "0 0 4 1 * *") // Dia 1 de cada mês às 4h
    public void processarIndicadoresMensais() {
        log.info("Iniciando processamento de indicadores mensais");
        
        String competenciaAnterior = YearMonth.now().minusMonths(1).toString();
        
        List<Indicador> indicadores = indicadorRepository.findByAtivo(true);
        
        for (Indicador indicador : indicadores) {
            try {
                processarIndicador(indicador, competenciaAnterior);
                calcularVariacoes(indicador, competenciaAnterior);
            } catch (Exception e) {
                log.error("Erro ao processar indicador {}: {}", 
                    indicador.getCodigo(), e.getMessage());
            }
        }
        
        log.info("Processamento de indicadores mensais concluído");
    }
    
    private void processarIndicador(Indicador indicador, String competencia) {
        // Verificar se já existe valor para esta competência
        if (valorRepository.existsByIndicadorAndCompetencia(indicador, competencia)) {
            return;
        }
        
        // Calcular valor
        BigDecimal valor = calcularValor(indicador, competencia);
        
        // Buscar valor anterior
        String competenciaAnterior = YearMonth.parse(competencia).minusMonths(1).toString();
        BigDecimal valorAnterior = valorRepository
            .findByIndicadorAndCompetencia(indicador, competenciaAnterior)
            .map(ValorIndicador::getValor)
            .orElse(null);
        
        // Calcular variação
        BigDecimal variacao = null;
        if (valorAnterior != null && valorAnterior.compareTo(BigDecimal.ZERO) != 0) {
            variacao = valor.subtract(valorAnterior)
                .divide(valorAnterior, 4, RoundingMode.HALF_UP)
                .multiply(BigDecimal.valueOf(100));
        }
        
        // Salvar
        ValorIndicador valorIndicador = new ValorIndicador();
        valorIndicador.setIndicador(indicador);
        valorIndicador.setCompetencia(competencia);
        valorIndicador.setValor(valor);
        valorIndicador.setValorAnterior(valorAnterior);
        valorIndicador.setVariacaoPercentual(variacao);
        valorIndicador.setDataCalculo(LocalDateTime.now());
        
        valorRepository.save(valorIndicador);
    }
}
```

---

## 6. API REST

### 6.1 Endpoints

```
# Dashboards
GET    /api/v1/dashboards                               # Lista dashboards
GET    /api/v1/dashboards/{codigo}                      # Busca dashboard
POST   /api/v1/dashboards                               # Criar personalizado
PUT    /api/v1/dashboards/{id}                          # Atualizar
DELETE /api/v1/dashboards/{id}                          # Excluir
POST   /api/v1/dashboards/{id}/widgets                  # Adicionar widget
PUT    /api/v1/dashboards/{id}/widgets/{widgetId}       # Atualizar widget
DELETE /api/v1/dashboards/{id}/widgets/{widgetId}       # Remover widget

# Indicadores
GET    /api/v1/indicadores                              # Lista indicadores
GET    /api/v1/indicadores/{codigo}                     # Busca indicador
GET    /api/v1/indicadores/{codigo}/valor               # Valor atual
GET    /api/v1/indicadores/{codigo}/historico           # Histórico
GET    /api/v1/indicadores/categoria/{categoria}        # Por categoria

# Relatórios Gerenciais
GET    /api/v1/relatorios/demografico                   # Relatório demográfico
GET    /api/v1/relatorios/folha                         # Relatório folha
GET    /api/v1/relatorios/absenteismo                   # Relatório absenteísmo
GET    /api/v1/relatorios/turnover                      # Relatório turnover
GET    /api/v1/relatorios/capacitacao                   # Relatório capacitação
POST   /api/v1/relatorios/exportar                      # Exportar dados
```

---

## 7. FRONTEND

### 7.1 Dashboard Principal

```typescript
// DashboardPage.tsx
export const DashboardPage: React.FC = () => {
  const { codigo } = useParams<{ codigo: string }>();
  const [filtros, setFiltros] = useState<FiltroDTO>(getFiltrosPadrao());
  const { data: dashboard, isLoading } = useDashboard(codigo, filtros);
  
  if (isLoading) return <DashboardSkeleton />;
  
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold">{dashboard?.nome}</h1>
          <p className="text-gray-500">{dashboard?.descricao}</p>
        </div>
        <FiltrosDropdown filtros={filtros} onChange={setFiltros} />
      </div>
      
      <ResponsiveGridLayout
        className="layout"
        layouts={dashboard?.layoutConfig}
        cols={{ lg: 12, md: 10, sm: 6, xs: 4, xxs: 2 }}
        rowHeight={100}
      >
        {dashboard?.widgets.map((widget) => (
          <div key={widget.id} data-grid={widget.posicao}>
            <WidgetRenderer widget={widget} />
          </div>
        ))}
      </ResponsiveGridLayout>
    </div>
  );
};

// WidgetRenderer.tsx
export const WidgetRenderer: React.FC<{ widget: WidgetDTO }> = ({ widget }) => {
  const renderContent = () => {
    switch (widget.tipoWidget) {
      case 'CARD_KPI':
        return <KPICard data={widget.dados} config={widget.configuracao} />;
      case 'GRAFICO_LINHA':
        return <LineChart data={widget.dados} config={widget.configuracao} />;
      case 'GRAFICO_BARRA':
        return <BarChart data={widget.dados} config={widget.configuracao} />;
      case 'GRAFICO_PIZZA':
        return <PieChart data={widget.dados} config={widget.configuracao} />;
      case 'GAUGE':
        return <GaugeChart data={widget.dados} config={widget.configuracao} />;
      case 'TABELA':
        return <DataTable data={widget.dados} config={widget.configuracao} />;
      case 'RANKING':
        return <RankingList data={widget.dados} config={widget.configuracao} />;
      default:
        return <div>Widget não suportado</div>;
    }
  };
  
  return (
    <Card className="h-full">
      <CardHeader className="pb-2">
        <CardTitle className="text-sm font-medium">{widget.titulo}</CardTitle>
      </CardHeader>
      <CardContent>
        {renderContent()}
      </CardContent>
    </Card>
  );
};
```

### 7.2 Componentes de Gráficos

```typescript
// KPICard.tsx
interface KPICardProps {
  data: {
    valor: number;
    valorAnterior?: number;
    meta?: number;
    unidade?: string;
  };
  config: {
    formato?: string;
    corTema?: string;
  };
}

export const KPICard: React.FC<KPICardProps> = ({ data, config }) => {
  const variacao = data.valorAnterior 
    ? ((data.valor - data.valorAnterior) / data.valorAnterior) * 100 
    : null;
  
  const formatarValor = (valor: number) => {
    switch (config.formato) {
      case 'moeda':
        return formatCurrency(valor);
      case 'percentual':
        return `${valor.toFixed(2)}%`;
      default:
        return valor.toLocaleString('pt-BR');
    }
  };
  
  const getStatusColor = () => {
    if (!data.meta) return 'text-gray-900';
    return data.valor >= data.meta ? 'text-green-600' : 'text-red-600';
  };
  
  return (
    <div className="flex flex-col items-center justify-center h-full">
      <span className={`text-4xl font-bold ${getStatusColor()}`}>
        {formatarValor(data.valor)}
      </span>
      {data.unidade && (
        <span className="text-sm text-gray-500">{data.unidade}</span>
      )}
      {variacao !== null && (
        <div className="flex items-center mt-2">
          {variacao >= 0 ? (
            <TrendingUp className="h-4 w-4 text-green-500 mr-1" />
          ) : (
            <TrendingDown className="h-4 w-4 text-red-500 mr-1" />
          )}
          <span className={variacao >= 0 ? 'text-green-500' : 'text-red-500'}>
            {variacao >= 0 ? '+' : ''}{variacao.toFixed(1)}%
          </span>
          <span className="text-gray-400 text-sm ml-1">vs. mês anterior</span>
        </div>
      )}
      {data.meta && (
        <div className="mt-2 text-xs text-gray-400">
          Meta: {formatarValor(data.meta)}
        </div>
      )}
    </div>
  );
};

// GaugeChart.tsx
export const GaugeChart: React.FC<GaugeChartProps> = ({ data, config }) => {
  const percentage = Math.min(100, Math.max(0, 
    (data.valor / (config.valorMaximo || 100)) * 100
  ));
  
  const getColor = () => {
    if (percentage <= 33) return config.corBaixa || '#22c55e';
    if (percentage <= 66) return config.corMedia || '#eab308';
    return config.corAlta || '#ef4444';
  };
  
  return (
    <div className="flex flex-col items-center">
      <RadialBarChart
        width={200}
        height={200}
        cx={100}
        cy={100}
        innerRadius={60}
        outerRadius={80}
        barSize={10}
        data={[{ value: percentage, fill: getColor() }]}
        startAngle={180}
        endAngle={0}
      >
        <RadialBar dataKey="value" />
      </RadialBarChart>
      <div className="text-center -mt-16">
        <span className="text-3xl font-bold">{data.valor.toFixed(1)}</span>
        <span className="text-sm text-gray-500">{data.unidade || '%'}</span>
      </div>
    </div>
  );
};
```

### 7.3 Filtros Globais

```typescript
// FiltrosDropdown.tsx
export const FiltrosDropdown: React.FC<{
  filtros: FiltroDTO;
  onChange: (filtros: FiltroDTO) => void;
}> = ({ filtros, onChange }) => {
  const { data: orgaos } = useOrgaos();
  const { data: lotacoes } = useLotacoes(filtros.orgaoId);
  
  return (
    <div className="flex gap-4 items-center">
      <Select
        value={filtros.competencia}
        onValueChange={(v) => onChange({ ...filtros, competencia: v })}
      >
        <SelectTrigger className="w-32">
          <SelectValue placeholder="Competência" />
        </SelectTrigger>
        <SelectContent>
          {getUltimos12Meses().map((mes) => (
            <SelectItem key={mes} value={mes}>
              {formatarCompetencia(mes)}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      
      <Select
        value={filtros.orgaoId?.toString() || 'todos'}
        onValueChange={(v) => onChange({ ...filtros, orgaoId: v === 'todos' ? null : Number(v) })}
      >
        <SelectTrigger className="w-48">
          <SelectValue placeholder="Órgão" />
        </SelectTrigger>
        <SelectContent>
          <SelectItem value="todos">Todos os órgãos</SelectItem>
          {orgaos?.map((orgao) => (
            <SelectItem key={orgao.id} value={orgao.id.toString()}>
              {orgao.nome}
            </SelectItem>
          ))}
        </SelectContent>
      </Select>
      
      <Button variant="outline" size="icon" onClick={() => onChange(getFiltrosPadrao())}>
        <RotateCcw className="h-4 w-4" />
      </Button>
      
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="outline">
            <Download className="h-4 w-4 mr-2" />
            Exportar
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent>
          <DropdownMenuItem onClick={() => exportarPDF(filtros)}>
            PDF
          </DropdownMenuItem>
          <DropdownMenuItem onClick={() => exportarExcel(filtros)}>
            Excel
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
};
```

---

## 8. DASHBOARDS PADRÃO

### 8.1 Dashboard Executivo
- Total de servidores ativos
- Despesa com pessoal (% RCL)
- Taxa de absenteísmo
- Taxa de turnover
- Gráfico evolução folha 12 meses
- Distribuição por vínculo

### 8.2 Dashboard RH
- Quadro de pessoal por situação
- Pirâmide etária
- Servidores aposentáveis
- Vencimento de contratos
- Férias a vencer
- Capacitações em andamento

### 8.3 Dashboard Folha
- Total bruto/líquido do mês
- Comparativo com mês anterior
- Composição por rubrica
- Horas extras
- Descontos consignados
- Encargos patronais

### 8.4 Dashboard Ponto
- Frequência do dia
- Horas trabalhadas vs esperadas
- Banco de horas acumulado
- Atrasos e saídas antecipadas
- Servidores em férias/afastados
