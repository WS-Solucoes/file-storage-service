# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 19
## Módulo de Benefícios (VA/VT/Auxílios)

---

## 1. VISÃO GERAL

### 1.1 Objetivo
Gerenciar a concessão, controle e desconto em folha de benefícios como vale-alimentação, vale-transporte, auxílio-creche, plano de saúde e outros auxílios previstos na legislação municipal.

### 1.2 Escopo
- Cadastro de tipos de benefícios
- Concessão de benefícios aos servidores
- Cálculo de valores e descontos
- Integração com folha de pagamento
- Controle de dependentes elegíveis
- Gestão de fornecedores/operadoras

---

## 2. MODELO DE DADOS

### 2.1 Entidades Principais

#### TipoBeneficio
```java
@Entity
@Table(name = "tipo_beneficio")
public class TipoBeneficio {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Column(length = 20)
    private String codigo;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private CategoriaBeneficio categoria;
    
    @Column(name = "valor_padrao", precision = 10, scale = 2)
    private BigDecimal valorPadrao;
    
    @Column(name = "percentual_desconto", precision = 5, scale = 2)
    private BigDecimal percentualDesconto;
    
    @Column(name = "valor_maximo", precision = 10, scale = 2)
    private BigDecimal valorMaximo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "forma_calculo")
    private FormaCalculoBeneficio formaCalculo;
    
    @Column(name = "desconta_folha")
    private Boolean descontaFolha = true;
    
    @Column(name = "proporcional_dias_trabalhados")
    private Boolean proporcionalDiasTrabalhados = true;
    
    @Column(name = "considera_dependentes")
    private Boolean consideraDependentes = false;
    
    @Column(name = "idade_limite_dependente")
    private Integer idadeLimiteDependente;
    
    @ManyToOne
    @JoinColumn(name = "rubrica_provento_id")
    private Rubrica rubricaProvento;
    
    @ManyToOne
    @JoinColumn(name = "rubrica_desconto_id")
    private Rubrica rubricaDesconto;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @Column(name = "data_criacao")
    private LocalDateTime dataCriacao;
}
```

#### ConcessaoBeneficio
```java
@Entity
@Table(name = "concessao_beneficio")
public class ConcessaoBeneficio {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id")
    private Vinculo vinculo;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "tipo_beneficio_id", nullable = false)
    private TipoBeneficio tipoBeneficio;
    
    @Column(name = "data_inicio", nullable = false)
    private LocalDate dataInicio;
    
    @Column(name = "data_fim")
    private LocalDate dataFim;
    
    @Column(name = "valor_concedido", precision = 10, scale = 2)
    private BigDecimal valorConcedido;
    
    @Column(name = "percentual_desconto", precision = 5, scale = 2)
    private BigDecimal percentualDesconto;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoBeneficio situacao;
    
    @Column(name = "numero_processo", length = 50)
    private String numeroProcesso;
    
    @Column(name = "data_solicitacao")
    private LocalDate dataSolicitacao;
    
    @Column(name = "data_aprovacao")
    private LocalDate dataAprovacao;
    
    @ManyToOne
    @JoinColumn(name = "aprovador_id")
    private Usuario aprovador;
    
    @Column(columnDefinition = "TEXT")
    private String observacao;
    
    @Column(name = "motivo_cancelamento", columnDefinition = "TEXT")
    private String motivoCancelamento;
    
    @Column(name = "data_cancelamento")
    private LocalDate dataCancelamento;
    
    // Campos específicos Vale-Transporte
    @Column(name = "quantidade_passagens")
    private Integer quantidadePassagens;
    
    @Column(name = "valor_passagem", precision = 10, scale = 2)
    private BigDecimal valorPassagem;
    
    // Campos específicos para benefícios por dependente
    @ManyToOne
    @JoinColumn(name = "dependente_id")
    private Dependente dependente;
}
```

#### BeneficioFolha
```java
@Entity
@Table(name = "beneficio_folha")
public class BeneficioFolha {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concessao_id", nullable = false)
    private ConcessaoBeneficio concessao;
    
    @Column(name = "competencia", nullable = false)
    private YearMonth competencia;
    
    @Column(name = "valor_provento", precision = 10, scale = 2)
    private BigDecimal valorProvento;
    
    @Column(name = "valor_desconto", precision = 10, scale = 2)
    private BigDecimal valorDesconto;
    
    @Column(name = "dias_direito")
    private Integer diasDireito;
    
    @Column(name = "dias_desconto")
    private Integer diasDesconto;
    
    @Column(name = "quantidade_utilizada")
    private Integer quantidadeUtilizada;
    
    @Column(name = "processado")
    private Boolean processado = false;
    
    @Column(name = "data_processamento")
    private LocalDateTime dataProcessamento;
    
    @ManyToOne
    @JoinColumn(name = "folha_id")
    private Folha folha;
}
```

#### LinhaValeTransporte
```java
@Entity
@Table(name = "linha_vale_transporte")
public class LinhaValeTransporte {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 50)
    private String codigo;
    
    @Column(nullable = false, length = 200)
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_transporte", nullable = false)
    private TipoTransporte tipoTransporte;
    
    @Column(name = "empresa_operadora", length = 200)
    private String empresaOperadora;
    
    @Column(name = "valor_tarifa", nullable = false, precision = 10, scale = 2)
    private BigDecimal valorTarifa;
    
    @Column(name = "data_vigencia_tarifa")
    private LocalDate dataVigenciaTarifa;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### ValeTransporteServidor
```java
@Entity
@Table(name = "vale_transporte_servidor")
public class ValeTransporteServidor {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concessao_id", nullable = false)
    private ConcessaoBeneficio concessao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "linha_id", nullable = false)
    private LinhaValeTransporte linha;
    
    @Column(name = "quantidade_ida")
    private Integer quantidadeIda = 1;
    
    @Column(name = "quantidade_volta")
    private Integer quantidadeVolta = 1;
    
    @Column(name = "dias_semana")
    private Integer diasSemana = 5;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

#### OperadoraPlanoSaude
```java
@Entity
@Table(name = "operadora_plano_saude")
public class OperadoraPlanoSaude {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 200)
    private String razaoSocial;
    
    @Column(name = "nome_fantasia", length = 200)
    private String nomeFantasia;
    
    @Column(nullable = false, length = 14)
    private String cnpj;
    
    @Column(name = "registro_ans", length = 20)
    private String registroANS;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @OneToMany(mappedBy = "operadora", cascade = CascadeType.ALL)
    private List<PlanoSaude> planos = new ArrayList<>();
}
```

#### PlanoSaude
```java
@Entity
@Table(name = "plano_saude")
public class PlanoSaude {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "operadora_id", nullable = false)
    private OperadoraPlanoSaude operadora;
    
    @Column(nullable = false, length = 100)
    private String nome;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_plano", nullable = false)
    private TipoPlanoSaude tipoPlano;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "abrangencia")
    private AbrangenciaPlano abrangencia;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "acomodacao")
    private TipoAcomodacao acomodacao;
    
    @Column(name = "possui_coparticipacao")
    private Boolean possuiCoparticipacao = false;
    
    @Column(name = "percentual_coparticipacao", precision = 5, scale = 2)
    private BigDecimal percentualCoparticipacao;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
    
    @OneToMany(mappedBy = "plano", cascade = CascadeType.ALL)
    private List<FaixaEtariaPlano> faixasEtarias = new ArrayList<>();
}
```

#### FaixaEtariaPlano
```java
@Entity
@Table(name = "faixa_etaria_plano")
public class FaixaEtariaPlano {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plano_id", nullable = false)
    private PlanoSaude plano;
    
    @Column(name = "idade_inicial", nullable = false)
    private Integer idadeInicial;
    
    @Column(name = "idade_final")
    private Integer idadeFinal;
    
    @Column(name = "valor", nullable = false, precision = 10, scale = 2)
    private BigDecimal valor;
    
    @Column(name = "data_vigencia")
    private LocalDate dataVigencia;
}
```

#### AdesaoPlanoSaude
```java
@Entity
@Table(name = "adesao_plano_saude")
public class AdesaoPlanoSaude {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "concessao_id", nullable = false)
    private ConcessaoBeneficio concessao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "plano_id", nullable = false)
    private PlanoSaude plano;
    
    @Column(name = "numero_carteirinha", length = 50)
    private String numeroCarteirinha;
    
    @Column(name = "data_adesao")
    private LocalDate dataAdesao;
    
    @Column(name = "data_carencia_fim")
    private LocalDate dataCarenciaFim;
    
    @OneToMany(mappedBy = "adesao", cascade = CascadeType.ALL)
    private List<DependentePlanoSaude> dependentes = new ArrayList<>();
}
```

#### DependentePlanoSaude
```java
@Entity
@Table(name = "dependente_plano_saude")
public class DependentePlanoSaude {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "adesao_id", nullable = false)
    private AdesaoPlanoSaude adesao;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dependente_id", nullable = false)
    private Dependente dependente;
    
    @Column(name = "numero_carteirinha", length = 50)
    private String numeroCarteirinha;
    
    @Column(name = "data_inclusao")
    private LocalDate dataInclusao;
    
    @Column(name = "data_exclusao")
    private LocalDate dataExclusao;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private SituacaoDependentePlano situacao;
}
```

---

## 3. ENUMERAÇÕES

```java
public enum CategoriaBeneficio {
    ALIMENTACAO("Alimentação"),
    TRANSPORTE("Transporte"),
    SAUDE("Saúde"),
    EDUCACAO("Educação"),
    ASSISTENCIA("Assistência"),
    OUTROS("Outros");
}

public enum FormaCalculoBeneficio {
    VALOR_FIXO("Valor Fixo"),
    PERCENTUAL_SALARIO("Percentual do Salário"),
    POR_DEPENDENTE("Por Dependente"),
    POR_QUANTIDADE("Por Quantidade"),
    TABELA_FAIXA("Tabela por Faixa");
}

public enum SituacaoBeneficio {
    SOLICITADO("Solicitado"),
    EM_ANALISE("Em Análise"),
    APROVADO("Aprovado"),
    ATIVO("Ativo"),
    SUSPENSO("Suspenso"),
    CANCELADO("Cancelado"),
    ENCERRADO("Encerrado");
}

public enum TipoTransporte {
    ONIBUS_URBANO("Ônibus Urbano"),
    ONIBUS_INTERMUNICIPAL("Ônibus Intermunicipal"),
    METRO("Metrô"),
    TREM("Trem"),
    BARCA("Barca/Ferry"),
    VAN("Van/Micro-ônibus");
}

public enum TipoPlanoSaude {
    ENFERMARIA("Enfermaria"),
    APARTAMENTO("Apartamento"),
    AMBULATORIAL("Ambulatorial"),
    HOSPITALAR("Hospitalar"),
    AMBULATORIAL_HOSPITALAR("Ambulatorial + Hospitalar"),
    ODONTOLOGICO("Odontológico"),
    COMPLETO("Completo");
}

public enum AbrangenciaPlano {
    MUNICIPAL("Municipal"),
    ESTADUAL("Estadual"),
    REGIONAL("Regional"),
    NACIONAL("Nacional");
}

public enum TipoAcomodacao {
    ENFERMARIA("Enfermaria"),
    APARTAMENTO("Apartamento");
}

public enum SituacaoDependentePlano {
    ATIVO("Ativo"),
    SUSPENSO("Suspenso"),
    EXCLUIDO("Excluído");
}
```

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Vale-Alimentação (VA)

| Código | Regra | Descrição |
|--------|-------|-----------|
| VA-001 | Direito | Todo servidor ativo tem direito a VA |
| VA-002 | Proporcionalidade | VA proporcional aos dias trabalhados no mês |
| VA-003 | Afastamento | Não concede VA em afastamentos > 15 dias |
| VA-004 | Férias | Concede VA integral nas férias |
| VA-005 | Licença Maternidade | Mantém VA durante licença maternidade |
| VA-006 | Não Acumula | Apenas 1 VA por servidor, independente de vínculos |

### 4.2 Vale-Transporte (VT)

| Código | Regra | Descrição |
|--------|-------|-----------|
| VT-001 | Desconto | Desconto máximo de 6% do salário base |
| VT-002 | Declaração | Servidor deve declarar linhas utilizadas |
| VT-003 | Proporcionalidade | VT proporcional aos dias úteis trabalhados |
| VT-004 | Férias | Não concede VT durante férias |
| VT-005 | Afastamento | Não concede VT em afastamentos |
| VT-006 | Home Office | Não concede VT em regime teletrabalho |
| VT-007 | Veículo Próprio | Servidor com veículo próprio pode optar por não receber |
| VT-008 | Atualização | Servidor deve atualizar declaração quando mudar endereço |

### 4.3 Auxílio-Creche

| Código | Regra | Descrição |
|--------|-------|-----------|
| AC-001 | Idade Limite | Filho até 6 anos (ou conforme lei municipal) |
| AC-002 | Comprovação | Exige matrícula em creche/escola |
| AC-003 | Um por Dependente | Um auxílio por dependente elegível |
| AC-004 | Ambos Servidores | Se pai e mãe são servidores, apenas um recebe |
| AC-005 | Reembolso | Modalidade reembolso exige comprovante de pagamento |

### 4.4 Plano de Saúde

| Código | Regra | Descrição |
|--------|-------|-----------|
| PS-001 | Coparticipação | Servidor paga percentual conforme faixa salarial |
| PS-002 | Dependentes | Pode incluir dependentes legais (cônjuge, filhos) |
| PS-003 | Idade Filhos | Filhos até 21 anos (ou 24 se universitário) |
| PS-004 | Carência | Novos dependentes podem ter carência |
| PS-005 | Faixa Etária | Valor varia conforme faixa etária |
| PS-006 | Desconto Folha | Desconto integral em folha |
| PS-007 | Aposentados | Aposentados podem manter plano (custeio próprio) |

---

## 5. CÁLCULOS

### 5.1 Vale-Transporte
```java
public class CalculoValeTransporte {
    
    // VT-001: Desconto máximo 6% do salário base
    private static final BigDecimal PERCENTUAL_MAXIMO_DESCONTO = new BigDecimal("0.06");
    
    public ResultadoCalculoVT calcular(ConcessaoBeneficio concessao, int diasUteisMes, int diasTrabalhados) {
        BigDecimal valorTotal = BigDecimal.ZERO;
        
        // Calcula valor das passagens
        for (ValeTransporteServidor vt : concessao.getLinhasVT()) {
            BigDecimal qtdDiaria = new BigDecimal(vt.getQuantidadeIda() + vt.getQuantidadeVolta());
            BigDecimal valorDiario = vt.getLinha().getValorTarifa().multiply(qtdDiaria);
            BigDecimal valorMensal = valorDiario.multiply(new BigDecimal(diasTrabalhados));
            valorTotal = valorTotal.add(valorMensal);
        }
        
        // Calcula desconto (máximo 6% do salário)
        BigDecimal salarioBase = concessao.getVinculo().getSalarioBase();
        BigDecimal descontoMaximo = salarioBase.multiply(PERCENTUAL_MAXIMO_DESCONTO);
        BigDecimal desconto = valorTotal.min(descontoMaximo);
        
        // Se desconto >= valor VT, não concede (servidor paga mais que recebe)
        if (desconto.compareTo(valorTotal) >= 0) {
            return new ResultadoCalculoVT(BigDecimal.ZERO, BigDecimal.ZERO, false);
        }
        
        return new ResultadoCalculoVT(valorTotal, desconto, true);
    }
}
```

### 5.2 Vale-Alimentação Proporcional
```java
public class CalculoValeAlimentacao {
    
    public BigDecimal calcularProporcional(ConcessaoBeneficio concessao, 
                                           int diasMes, 
                                           int diasAfastamento,
                                           boolean emFerias,
                                           boolean licencaMaternidade) {
        BigDecimal valorIntegral = concessao.getValorConcedido();
        
        // VA-004, VA-005: Férias e licença maternidade = integral
        if (emFerias || licencaMaternidade) {
            return valorIntegral;
        }
        
        // VA-003: Afastamento > 15 dias = não concede
        if (diasAfastamento > 15) {
            return BigDecimal.ZERO;
        }
        
        // VA-002: Proporcional aos dias trabalhados
        int diasTrabalhados = diasMes - diasAfastamento;
        return valorIntegral.multiply(new BigDecimal(diasTrabalhados))
                           .divide(new BigDecimal(diasMes), 2, RoundingMode.HALF_UP);
    }
}
```

### 5.3 Plano de Saúde por Faixa Etária
```java
public class CalculoPlanoSaude {
    
    public ResultadoCalculoPS calcular(AdesaoPlanoSaude adesao, LocalDate dataReferencia) {
        BigDecimal valorTitular = calcularValorPorIdade(
            adesao.getPlano(),
            calcularIdade(adesao.getConcessao().getServidor().getDataNascimento(), dataReferencia)
        );
        
        BigDecimal valorDependentes = BigDecimal.ZERO;
        for (DependentePlanoSaude dep : adesao.getDependentesAtivos()) {
            int idade = calcularIdade(dep.getDependente().getDataNascimento(), dataReferencia);
            valorDependentes = valorDependentes.add(calcularValorPorIdade(adesao.getPlano(), idade));
        }
        
        BigDecimal valorTotal = valorTitular.add(valorDependentes);
        
        // Aplica participação do município (se houver)
        BigDecimal percentualServidor = obterPercentualServidor(adesao.getConcessao());
        BigDecimal valorDesconto = valorTotal.multiply(percentualServidor)
                                             .divide(new BigDecimal("100"), 2, RoundingMode.HALF_UP);
        
        return new ResultadoCalculoPS(valorTotal, valorDesconto, valorTitular, valorDependentes);
    }
    
    private BigDecimal calcularValorPorIdade(PlanoSaude plano, int idade) {
        return plano.getFaixasEtarias().stream()
            .filter(f -> idade >= f.getIdadeInicial() && 
                        (f.getIdadeFinal() == null || idade <= f.getIdadeFinal()))
            .findFirst()
            .map(FaixaEtariaPlano::getValor)
            .orElse(BigDecimal.ZERO);
    }
}
```

---

## 6. TABELAS DE APOIO

### 6.1 Faixas Etárias Padrão ANS (Plano de Saúde)

| Faixa | Idade Inicial | Idade Final | Fator |
|-------|---------------|-------------|-------|
| 1 | 0 | 18 | 1,00 |
| 2 | 19 | 23 | 1,00 |
| 3 | 24 | 28 | 1,00 |
| 4 | 29 | 33 | 1,10 |
| 5 | 34 | 38 | 1,20 |
| 6 | 39 | 43 | 1,30 |
| 7 | 44 | 48 | 1,50 |
| 8 | 49 | 53 | 1,80 |
| 9 | 54 | 58 | 2,20 |
| 10 | 59 | - | 3,00 |

### 6.2 Percentual Participação Plano (Exemplo)

| Faixa Salarial | % Servidor | % Município |
|----------------|------------|-------------|
| Até 2 SM | 20% | 80% |
| 2 a 4 SM | 30% | 70% |
| 4 a 6 SM | 40% | 60% |
| 6 a 10 SM | 50% | 50% |
| Acima 10 SM | 60% | 40% |

---

## 7. SERVIÇOS

### 7.1 BeneficioService
```java
@Service
@Transactional
public class BeneficioService {
    
    @Autowired
    private ConcessaoBeneficioRepository concessaoRepository;
    
    @Autowired
    private TipoBeneficioRepository tipoBeneficioRepository;
    
    @Autowired
    private BeneficioFolhaRepository beneficioFolhaRepository;
    
    public ConcessaoBeneficio concederBeneficio(ConcessaoBeneficioDTO dto) {
        // Validações
        validarElegibilidade(dto.getServidorId(), dto.getTipoBeneficioId());
        validarDuplicidade(dto.getServidorId(), dto.getTipoBeneficioId());
        
        ConcessaoBeneficio concessao = new ConcessaoBeneficio();
        concessao.setServidor(servidorRepository.findById(dto.getServidorId()).orElseThrow());
        concessao.setTipoBeneficio(tipoBeneficioRepository.findById(dto.getTipoBeneficioId()).orElseThrow());
        concessao.setDataInicio(dto.getDataInicio());
        concessao.setValorConcedido(dto.getValorConcedido());
        concessao.setSituacao(SituacaoBeneficio.ATIVO);
        
        return concessaoRepository.save(concessao);
    }
    
    public void suspenderBeneficio(Long concessaoId, String motivo) {
        ConcessaoBeneficio concessao = concessaoRepository.findById(concessaoId).orElseThrow();
        concessao.setSituacao(SituacaoBeneficio.SUSPENSO);
        concessao.setObservacao(motivo);
        concessaoRepository.save(concessao);
    }
    
    public void cancelarBeneficio(Long concessaoId, String motivo) {
        ConcessaoBeneficio concessao = concessaoRepository.findById(concessaoId).orElseThrow();
        concessao.setSituacao(SituacaoBeneficio.CANCELADO);
        concessao.setMotivoCancelamento(motivo);
        concessao.setDataCancelamento(LocalDate.now());
        concessaoRepository.save(concessao);
    }
    
    public List<BeneficioFolha> processarBeneficiosFolha(Long folhaId) {
        Folha folha = folhaRepository.findById(folhaId).orElseThrow();
        List<BeneficioFolha> beneficiosProcessados = new ArrayList<>();
        
        List<ConcessaoBeneficio> concessoesAtivas = concessaoRepository
            .findAtivasPorCompetencia(folha.getCompetencia());
        
        for (ConcessaoBeneficio concessao : concessoesAtivas) {
            BeneficioFolha bf = calcularBeneficioFolha(concessao, folha);
            beneficiosProcessados.add(beneficioFolhaRepository.save(bf));
        }
        
        return beneficiosProcessados;
    }
    
    private void validarDuplicidade(Long servidorId, Long tipoBeneficioId) {
        boolean existe = concessaoRepository.existsAtivaPorServidorETipo(servidorId, tipoBeneficioId);
        if (existe) {
            throw new BusinessException("Servidor já possui este benefício ativo");
        }
    }
}
```

### 7.2 ValeTransporteService
```java
@Service
@Transactional
public class ValeTransporteService {
    
    public ConcessaoBeneficio solicitarValeTransporte(ValeTransporteDTO dto) {
        // Cria concessão
        ConcessaoBeneficio concessao = beneficioService.concederBeneficio(
            ConcessaoBeneficioDTO.builder()
                .servidorId(dto.getServidorId())
                .tipoBeneficioId(getTipoBeneficioVT().getId())
                .dataInicio(dto.getDataInicio())
                .build()
        );
        
        // Registra linhas utilizadas
        for (LinhaVTDTO linhaDto : dto.getLinhas()) {
            ValeTransporteServidor vts = new ValeTransporteServidor();
            vts.setConcessao(concessao);
            vts.setLinha(linhaRepository.findById(linhaDto.getLinhaId()).orElseThrow());
            vts.setQuantidadeIda(linhaDto.getQuantidadeIda());
            vts.setQuantidadeVolta(linhaDto.getQuantidadeVolta());
            vts.setDiasSemana(linhaDto.getDiasSemana());
            valeTransporteServidorRepository.save(vts);
        }
        
        return concessao;
    }
    
    public void atualizarDeclaracaoVT(Long concessaoId, List<LinhaVTDTO> novasLinhas) {
        ConcessaoBeneficio concessao = concessaoRepository.findById(concessaoId).orElseThrow();
        
        // Remove linhas antigas
        valeTransporteServidorRepository.deleteByConcessaoId(concessaoId);
        
        // Adiciona novas linhas
        for (LinhaVTDTO linhaDto : novasLinhas) {
            ValeTransporteServidor vts = new ValeTransporteServidor();
            vts.setConcessao(concessao);
            vts.setLinha(linhaRepository.findById(linhaDto.getLinhaId()).orElseThrow());
            vts.setQuantidadeIda(linhaDto.getQuantidadeIda());
            vts.setQuantidadeVolta(linhaDto.getQuantidadeVolta());
            valeTransporteServidorRepository.save(vts);
        }
    }
    
    public BigDecimal calcularVTMensal(Long concessaoId, YearMonth competencia) {
        ConcessaoBeneficio concessao = concessaoRepository.findById(concessaoId).orElseThrow();
        
        int diasUteis = calcularDiasUteis(competencia);
        int diasTrabalhados = obterDiasTrabalhados(concessao.getServidor().getId(), competencia);
        
        return calculoVT.calcular(concessao, diasUteis, diasTrabalhados).getValorProvento();
    }
}
```

### 7.3 PlanoSaudeService
```java
@Service
@Transactional
public class PlanoSaudeService {
    
    public AdesaoPlanoSaude realizarAdesao(AdesaoPlanoDTO dto) {
        ConcessaoBeneficio concessao = beneficioService.concederBeneficio(
            ConcessaoBeneficioDTO.builder()
                .servidorId(dto.getServidorId())
                .tipoBeneficioId(getTipoBeneficioPS().getId())
                .dataInicio(dto.getDataAdesao())
                .build()
        );
        
        AdesaoPlanoSaude adesao = new AdesaoPlanoSaude();
        adesao.setConcessao(concessao);
        adesao.setPlano(planoRepository.findById(dto.getPlanoId()).orElseThrow());
        adesao.setDataAdesao(dto.getDataAdesao());
        adesao.setNumeroCarteirinha(gerarNumeroCarteirinha());
        
        // Calcula fim da carência
        if (dto.getPlano().getPossuiCarencia()) {
            adesao.setDataCarenciaFim(dto.getDataAdesao().plusDays(180));
        }
        
        return adesaoRepository.save(adesao);
    }
    
    public DependentePlanoSaude incluirDependente(Long adesaoId, Long dependenteId) {
        AdesaoPlanoSaude adesao = adesaoRepository.findById(adesaoId).orElseThrow();
        Dependente dependente = dependenteRepository.findById(dependenteId).orElseThrow();
        
        // Valida elegibilidade do dependente
        validarDependenteElegivel(dependente);
        
        DependentePlanoSaude depPlano = new DependentePlanoSaude();
        depPlano.setAdesao(adesao);
        depPlano.setDependente(dependente);
        depPlano.setDataInclusao(LocalDate.now());
        depPlano.setSituacao(SituacaoDependentePlano.ATIVO);
        depPlano.setNumeroCarteirinha(gerarNumeroCarteirinha());
        
        return dependentePlanoRepository.save(depPlano);
    }
    
    public void excluirDependente(Long dependentePlanoId, String motivo) {
        DependentePlanoSaude depPlano = dependentePlanoRepository.findById(dependentePlanoId).orElseThrow();
        depPlano.setSituacao(SituacaoDependentePlano.EXCLUIDO);
        depPlano.setDataExclusao(LocalDate.now());
        dependentePlanoRepository.save(depPlano);
    }
    
    private void validarDependenteElegivel(Dependente dependente) {
        // PS-003: Filhos até 21 anos (ou 24 se universitário)
        if (dependente.getParentesco() == TipoParentesco.FILHO) {
            int idade = calcularIdade(dependente.getDataNascimento());
            if (idade > 24) {
                throw new BusinessException("Filho acima da idade limite para inclusão no plano");
            }
            if (idade > 21 && !dependente.isEstudanteUniversitario()) {
                throw new BusinessException("Filho maior de 21 anos deve ser estudante universitário");
            }
        }
    }
}
```

---

## 8. API REST

### 8.1 Endpoints de Benefícios

```
# Tipos de Benefício
GET    /api/v1/beneficios/tipos                          # Lista tipos
GET    /api/v1/beneficios/tipos/{id}                     # Busca tipo
POST   /api/v1/beneficios/tipos                          # Cria tipo
PUT    /api/v1/beneficios/tipos/{id}                     # Atualiza tipo

# Concessões
GET    /api/v1/beneficios/concessoes                     # Lista concessões
GET    /api/v1/beneficios/concessoes/{id}                # Busca concessão
POST   /api/v1/beneficios/concessoes                     # Concede benefício
PUT    /api/v1/beneficios/concessoes/{id}                # Atualiza concessão
POST   /api/v1/beneficios/concessoes/{id}/suspender      # Suspende
POST   /api/v1/beneficios/concessoes/{id}/cancelar       # Cancela
POST   /api/v1/beneficios/concessoes/{id}/reativar       # Reativa

# Benefícios por Servidor
GET    /api/v1/servidores/{id}/beneficios                # Lista benefícios do servidor
GET    /api/v1/servidores/{id}/beneficios/ativos         # Apenas ativos

# Vale-Transporte
GET    /api/v1/vale-transporte/linhas                    # Lista linhas
POST   /api/v1/vale-transporte/linhas                    # Cadastra linha
PUT    /api/v1/vale-transporte/linhas/{id}               # Atualiza linha
POST   /api/v1/vale-transporte/solicitar                 # Solicita VT
PUT    /api/v1/vale-transporte/{id}/declaracao           # Atualiza declaração
GET    /api/v1/vale-transporte/{id}/calculo              # Calcula valor

# Plano de Saúde
GET    /api/v1/plano-saude/operadoras                    # Lista operadoras
GET    /api/v1/plano-saude/planos                        # Lista planos
POST   /api/v1/plano-saude/adesao                        # Realiza adesão
GET    /api/v1/plano-saude/adesao/{id}                   # Busca adesão
POST   /api/v1/plano-saude/adesao/{id}/dependentes       # Inclui dependente
DELETE /api/v1/plano-saude/adesao/{id}/dependentes/{depId} # Exclui dependente
GET    /api/v1/plano-saude/adesao/{id}/calculo           # Calcula valor

# Processamento Folha
POST   /api/v1/beneficios/processar-folha/{folhaId}      # Processa benefícios para folha
GET    /api/v1/beneficios/folha/{competencia}            # Benefícios da competência
```

---

## 9. COMPONENTES FRONTEND

### 9.1 Estrutura de Arquivos
```
src/features/beneficios/
├── components/
│   ├── BeneficioForm.tsx
│   ├── BeneficiosList.tsx
│   ├── ValeTransporteForm.tsx
│   ├── DeclaracaoVTForm.tsx
│   ├── PlanoSaudeAdesaoForm.tsx
│   ├── DependentePlanoForm.tsx
│   └── BeneficioServidorCard.tsx
├── hooks/
│   ├── useBeneficios.ts
│   ├── useValeTransporte.ts
│   └── usePlanoSaude.ts
├── services/
│   └── beneficioService.ts
└── types/
    └── beneficio.types.ts
```

### 9.2 Tipos TypeScript
```typescript
// beneficio.types.ts

export interface TipoBeneficio {
  id: number;
  nome: string;
  codigo: string;
  categoria: CategoriaBeneficio;
  valorPadrao?: number;
  percentualDesconto?: number;
  formaCalculo: FormaCalculoBeneficio;
  descontaFolha: boolean;
  proporcionalDiasTrabalhados: boolean;
  consideraDependentes: boolean;
}

export interface ConcessaoBeneficio {
  id: number;
  servidor: ServidorResumo;
  tipoBeneficio: TipoBeneficio;
  dataInicio: string;
  dataFim?: string;
  valorConcedido?: number;
  situacao: SituacaoBeneficio;
  numeroProcesso?: string;
}

export interface ValeTransporteServidor {
  id: number;
  linha: LinhaValeTransporte;
  quantidadeIda: number;
  quantidadeVolta: number;
  diasSemana: number;
}

export interface AdesaoPlanoSaude {
  id: number;
  plano: PlanoSaude;
  numeroCarteirinha?: string;
  dataAdesao: string;
  dependentes: DependentePlanoSaude[];
}

export enum CategoriaBeneficio {
  ALIMENTACAO = 'ALIMENTACAO',
  TRANSPORTE = 'TRANSPORTE',
  SAUDE = 'SAUDE',
  EDUCACAO = 'EDUCACAO',
  ASSISTENCIA = 'ASSISTENCIA',
  OUTROS = 'OUTROS'
}

export enum SituacaoBeneficio {
  SOLICITADO = 'SOLICITADO',
  EM_ANALISE = 'EM_ANALISE',
  APROVADO = 'APROVADO',
  ATIVO = 'ATIVO',
  SUSPENSO = 'SUSPENSO',
  CANCELADO = 'CANCELADO',
  ENCERRADO = 'ENCERRADO'
}
```

---

## 10. RELATÓRIOS

### 10.1 Relatórios Disponíveis

| Relatório | Descrição | Parâmetros |
|-----------|-----------|------------|
| Beneficiários por Tipo | Lista servidores por benefício | Tipo benefício, Situação |
| Custo Mensal Benefícios | Totalização mensal por categoria | Competência, Secretaria |
| Evolução VT | Histórico valores VT | Período, Servidor |
| Beneficiários Plano Saúde | Lista titulares e dependentes | Plano, Operadora |
| Custos Plano Saúde | Valor por faixa etária | Competência |
| Benefícios Concedidos | Novas concessões no período | Data início, Data fim |
| Cancelamentos | Benefícios cancelados | Período, Motivo |

---

## 11. INTEGRAÇÕES

### 11.1 Folha de Pagamento
- Gera lançamentos de proventos (VA, VT subsidiado)
- Gera lançamentos de descontos (VT 6%, Plano de Saúde)
- Considera proporcionalizações

### 11.2 Cadastro de Servidores
- Verifica elegibilidade (vínculo ativo)
- Consulta dependentes para benefícios

### 11.3 Controle de Frequência
- Obtém dias trabalhados para proporcionalização
- Identifica afastamentos que impactam benefícios

---

## 12. CONSIDERAÇÕES DE IMPLEMENTAÇÃO

### 12.1 Validações Importantes
- Verificar vínculo ativo ao conceder benefício
- Validar duplicidade de benefícios
- Controlar idade limite de dependentes
- Atualizar valores quando tarifas mudam

### 12.2 Processos Automáticos
- Recalcular VT quando tarifa atualizar
- Encerrar benefícios de servidores exonerados
- Notificar vencimento de idade de dependentes
- Suspender benefícios em afastamentos longos

### 12.3 Auditoria
- Registrar todas alterações em concessões
- Manter histórico de valores
- Log de processamentos de folha
