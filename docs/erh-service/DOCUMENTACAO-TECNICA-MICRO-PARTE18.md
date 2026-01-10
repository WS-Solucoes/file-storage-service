# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 18
## Módulo de SEFIP/GFIP

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerar a GFIP (Guia de Recolhimento do FGTS e Informações à Previdência Social) através do SEFIP (Sistema Empresa de Recolhimento do FGTS e Informações à Previdência Social).

### 1.2 Obrigatoriedade
- **Prazo:** Até dia 7 do mês seguinte
- **Competência:** Mensal + 13º salário
- **Destinatário:** Caixa Econômica Federal

> **Nota:** Servidores estatutários (RPPS) geralmente não têm FGTS, mas municípios com CLT ou RGPS precisam da GFIP.

---

## 2. MODELO DE DADOS

### 2.1 Entidade: SEFIP

```java
@Entity
@Table(name = "sefip")
public class SEFIP extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "competencia", length = 7)
    private String competencia; // YYYY-MM
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 20)
    private TipoSEFIP tipo; // MENSAL, DECIMO_TERCEIRO
    
    @Enumerated(EnumType.STRING)
    @Column(name = "modalidade", length = 20)
    private ModalidadeSEFIP modalidade; // BRANCO, 1, 9
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoSEFIP situacao;
    
    @Column(name = "codigo_recolhimento")
    private Integer codigoRecolhimento; // 115, 150, etc
    
    // Totalizadores
    @Column(name = "total_trabalhadores")
    private Integer totalTrabalhadores;
    
    @Column(name = "base_fgts")
    private BigDecimal baseFGTS;
    
    @Column(name = "valor_fgts")
    private BigDecimal valorFGTS; // 8%
    
    @Column(name = "base_previdencia")
    private BigDecimal basePrevidencia;
    
    @Column(name = "valor_inss_segurados")
    private BigDecimal valorINSSSegurados;
    
    @Column(name = "valor_inss_empresa")
    private BigDecimal valorINSSEmpresa;
    
    @Column(name = "valor_rat")
    private BigDecimal valorRAT;
    
    @Column(name = "valor_terceiros")
    private BigDecimal valorTerceiros; // Sistema S
    
    @Column(name = "valor_total")
    private BigDecimal valorTotal;
    
    // Datas
    @Column(name = "data_geracao")
    private LocalDateTime dataGeracao;
    
    @Column(name = "data_transmissao")
    private LocalDateTime dataTransmissao;
    
    // Protocolo
    @Column(name = "numero_protocolo", length = 30)
    private String numeroProtocolo;
    
    @Column(name = "arquivo_nome", length = 200)
    private String arquivoNome;
    
    @OneToMany(mappedBy = "sefip", cascade = CascadeType.ALL)
    private List<SEFIPTrabalhador> trabalhadores = new ArrayList<>();
}
```

### 2.2 Entidade: SEFIPTrabalhador

```java
@Entity
@Table(name = "sefip_trabalhador")
public class SEFIPTrabalhador extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sefip_id", nullable = false)
    private SEFIP sefip;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id")
    private VinculoFuncional vinculo;
    
    // Identificação
    @Column(name = "pis", length = 15)
    private String pis;
    
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    @Column(name = "data_nascimento")
    private LocalDate dataNascimento;
    
    @Column(name = "data_admissao")
    private LocalDate dataAdmissao;
    
    @Column(name = "data_opcao_fgts")
    private LocalDate dataOpcaoFGTS;
    
    @Column(name = "categoria_trabalhador")
    private Integer categoriaTrabalhador; // 01, 05, etc
    
    @Column(name = "cbo", length = 10)
    private String cbo;
    
    // Remuneração
    @Column(name = "remuneracao_sem_13")
    private BigDecimal remuneracaoSem13;
    
    @Column(name = "remuneracao_13")
    private BigDecimal remuneracao13;
    
    @Column(name = "base_fgts")
    private BigDecimal baseFGTS;
    
    @Column(name = "valor_fgts")
    private BigDecimal valorFGTS;
    
    @Column(name = "base_previdencia")
    private BigDecimal basePrevidencia;
    
    @Column(name = "valor_inss")
    private BigDecimal valorINSS;
    
    // Ocorrências
    @Column(name = "ocorrencia")
    private Integer ocorrencia; // Código de movimentação
    
    @Column(name = "data_movimentacao")
    private LocalDate dataMovimentacao;
    
    // Múltiplos vínculos
    @Column(name = "multiplos_vinculos")
    private Boolean multiplosVinculos = false;
    
    @Column(name = "multiplos_vinculos_base")
    private BigDecimal multiplosVinculosBase; // Base de outro empregador
}
```

### 2.3 Enums

```java
public enum TipoSEFIP {
    MENSAL,
    DECIMO_TERCEIRO
}

public enum ModalidadeSEFIP {
    BRANCO,     // Recolhimento ao FGTS e Declaração à Previdência
    UM,         // Declaração ao FGTS e à Previdência
    NOVE        // Confirmação de informações anteriores
}

public enum SituacaoSEFIP {
    RASCUNHO,
    GERADA,
    VALIDADA,
    TRANSMITIDA,
    ERRO
}
```

---

## 3. CÓDIGOS E TABELAS

### 3.1 Códigos de Recolhimento

| Código | Descrição |
|--------|-----------|
| 115 | Recolhimento ao FGTS e informações à Previdência |
| 150 | Recolhimento ao FGTS e informações à Previdência (13º) |
| 130 | Recolhimento residual ao FGTS |
| 145 | Recolhimento complementar |
| 650 | Reclamatória trabalhista |

### 3.2 Categoria de Trabalhador (para serviço público)

| Código | Descrição |
|--------|-----------|
| 01 | Empregado |
| 02 | Trabalhador avulso |
| 05 | Contribuinte individual |
| 11 | Contribuinte individual (prestador serviço) |
| 13 | Servidor público (RGPS) |

### 3.3 Códigos de Movimentação (Ocorrência)

| Código | Descrição |
|--------|-----------|
| 00 | Sem movimentação |
| H | Rescisão com justa causa |
| I1 | Rescisão sem justa causa |
| I2 | Rescisão término contrato |
| J | Aposentadoria |
| K | Falecimento |
| N1 | Transferência (mesma empresa) |
| P1 | Afastamento > 15 dias (doença) |
| P2 | Afastamento (acidente) |
| Q1 | Afastamento (licença maternidade) |

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Geração SEFIP

```
REGRA SF-001: Trabalhadores a Informar
├── Todos com remuneração na competência
├── Trabalhadores afastados (código movimentação)
├── Demitidos (com rescisão no mês)
└── Excluir: RPPS sem contribuição RGPS

REGRA SF-002: Base de Cálculo FGTS
├── Salário + adicionais + comissões
├── Horas extras
├── Aviso prévio indenizado (não incide)
├── Férias indenizadas (não incide)
└── Teto: não há teto para FGTS

REGRA SF-003: Base de Cálculo INSS
├── Salário + adicionais
├── Respeitar teto do INSS
├── 13º: separado da folha normal
└── Múltiplos vínculos: somar bases
```

### 4.2 Alíquotas

```
FGTS:
├── Normal: 8% sobre remuneração
├── Aprendiz: 2%
└── Multa rescisória: 40% (demissão sem justa causa)

INSS Empregador:
├── Empresa: 20% sobre folha total
├── RAT: 1%, 2% ou 3% (conforme risco)
├── FAP: multiplicador de 0,5 a 2,0
├── Terceiros: SESC, SENAI, etc. (varia)
└── Total: ~27% a 28%

INSS Segurado:
├── Faixa 1: 7,5%
├── Faixa 2: 9%
├── Faixa 3: 12%
└── Faixa 4: 14%
```

---

## 5. SERVIÇOS PRINCIPAIS

### 5.1 SEFIPService

```java
@Service
@Transactional
public class SEFIPService extends AbstractTenantService {
    
    /**
     * Gerar SEFIP da competência
     */
    public SEFIP gerarSEFIP(String competencia, TipoSEFIP tipo) {
        SEFIP sefip = new SEFIP();
        sefip.setCompetencia(competencia);
        sefip.setTipo(tipo);
        sefip.setModalidade(ModalidadeSEFIP.BRANCO);
        sefip.setCodigoRecolhimento(tipo == TipoSEFIP.MENSAL ? 115 : 150);
        sefip.setSituacao(SituacaoSEFIP.RASCUNHO);
        sefip.setDataGeracao(LocalDateTime.now());
        
        sefip = sefipRepository.save(sefip);
        
        // Buscar trabalhadores com folha na competência (RGPS)
        YearMonth ym = YearMonth.parse(competencia);
        List<FolhaPagamentoDet> folhas = folhaDetRepository
            .findByCompetenciaRGPS(ym.getYear(), ym.getMonthValue());
        
        BigDecimal totalBaseFGTS = BigDecimal.ZERO;
        BigDecimal totalFGTS = BigDecimal.ZERO;
        BigDecimal totalBaseINSS = BigDecimal.ZERO;
        BigDecimal totalINSSSegurado = BigDecimal.ZERO;
        
        for (FolhaPagamentoDet folha : folhas) {
            SEFIPTrabalhador trab = gerarTrabalhador(sefip, folha, tipo);
            sefip.getTrabalhadores().add(trab);
            
            totalBaseFGTS = totalBaseFGTS.add(trab.getBaseFGTS());
            totalFGTS = totalFGTS.add(trab.getValorFGTS());
            totalBaseINSS = totalBaseINSS.add(trab.getBasePrevidencia());
            totalINSSSegurado = totalINSSSegurado.add(trab.getValorINSS());
        }
        
        // Totalizadores
        sefip.setTotalTrabalhadores(sefip.getTrabalhadores().size());
        sefip.setBaseFGTS(totalBaseFGTS);
        sefip.setValorFGTS(totalFGTS);
        sefip.setBasePrevidencia(totalBaseINSS);
        sefip.setValorINSSSegurados(totalINSSSegurado);
        
        // Calcular parte empresa
        BigDecimal inssEmpresa = totalBaseINSS.multiply(new BigDecimal("0.20"));
        BigDecimal rat = totalBaseINSS.multiply(new BigDecimal("0.02")); // 2% médio
        BigDecimal terceiros = totalBaseINSS.multiply(new BigDecimal("0.058")); // 5,8%
        
        sefip.setValorINSSEmpresa(inssEmpresa);
        sefip.setValorRAT(rat);
        sefip.setValorTerceiros(terceiros);
        sefip.setValorTotal(totalFGTS.add(totalINSSSegurado)
            .add(inssEmpresa).add(rat).add(terceiros));
        
        sefip.setSituacao(SituacaoSEFIP.GERADA);
        
        return sefipRepository.save(sefip);
    }
    
    /**
     * Gerar dados do trabalhador
     */
    private SEFIPTrabalhador gerarTrabalhador(SEFIP sefip, FolhaPagamentoDet folha, TipoSEFIP tipo) {
        VinculoFuncional vinculo = folha.getVinculo();
        Servidor servidor = vinculo.getServidor();
        
        SEFIPTrabalhador trab = new SEFIPTrabalhador();
        trab.setSefip(sefip);
        trab.setVinculo(vinculo);
        
        // Identificação
        trab.setPis(servidor.getPis());
        trab.setCpf(servidor.getCpf());
        trab.setNome(servidor.getNome());
        trab.setDataNascimento(servidor.getDataNascimento());
        trab.setDataAdmissao(vinculo.getDataAdmissao());
        trab.setDataOpcaoFGTS(vinculo.getDataAdmissao());
        trab.setCategoriaTrabalhador(mapearCategoria(vinculo));
        trab.setCbo(vinculo.getCargo().getCbo());
        
        // Remuneração
        BigDecimal remuneracao = calcularRemuneracaoSEFIP(folha);
        
        if (tipo == TipoSEFIP.MENSAL) {
            trab.setRemuneracaoSem13(remuneracao);
            trab.setRemuneracao13(BigDecimal.ZERO);
        } else {
            trab.setRemuneracaoSem13(BigDecimal.ZERO);
            trab.setRemuneracao13(remuneracao);
        }
        
        // Base e valor FGTS (8%)
        BigDecimal baseFGTS = remuneracao;
        trab.setBaseFGTS(baseFGTS);
        trab.setValorFGTS(baseFGTS.multiply(new BigDecimal("0.08"))
            .setScale(2, RoundingMode.HALF_UP));
        
        // Base e valor INSS
        BigDecimal tetoINSS = parametroService.getTetoINSS();
        BigDecimal baseINSS = remuneracao.min(tetoINSS);
        trab.setBasePrevidencia(baseINSS);
        
        // Buscar valor INSS já calculado na folha
        BigDecimal inssRetido = folha.getVantagensDesconto().stream()
            .filter(vd -> vd.getRubrica().getNatureza() == NaturezaRubrica.INSS)
            .map(VantagemDesconto::getValor)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        trab.setValorINSS(inssRetido);
        
        // Ocorrência (movimentação)
        trab.setOcorrencia(determinarOcorrencia(vinculo, sefip.getCompetencia()));
        
        return trab;
    }
    
    /**
     * Exportar arquivo SEFIP (RE)
     */
    public byte[] exportarArquivo(Long sefipId) {
        SEFIP sefip = sefipRepository.findById(sefipId).orElseThrow();
        
        StringBuilder sb = new StringBuilder();
        
        // Registro tipo 00 - Cabeçalho
        sb.append(gerarRegistro00(sefip));
        
        // Registro tipo 10 - Empresa
        sb.append(gerarRegistro10(sefip));
        
        // Registro tipo 30 - Trabalhadores
        for (SEFIPTrabalhador trab : sefip.getTrabalhadores()) {
            sb.append(gerarRegistro30(trab));
        }
        
        // Registro tipo 90 - Totalizador
        sb.append(gerarRegistro90(sefip));
        
        byte[] arquivo = sb.toString().getBytes(StandardCharsets.ISO_8859_1);
        
        sefip.setArquivoNome("SEFIP_" + sefip.getCompetencia() + ".RE");
        sefip.setSituacao(SituacaoSEFIP.VALIDADA);
        
        return arquivo;
    }
}
```

---

## 6. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/api/sefip` | Listar SEFIPs | ADMIN |
| POST | `/api/sefip/gerar` | Gerar SEFIP | ADMIN |
| GET | `/api/sefip/{id}` | Detalhe | ADMIN |
| GET | `/api/sefip/{id}/arquivo` | Download RE | ADMIN |
| GET | `/api/sefip/{id}/guias` | Gerar guias GPS/GRF | ADMIN |
| PUT | `/api/sefip/{id}/transmitir` | Registrar transmissão | ADMIN |

---
