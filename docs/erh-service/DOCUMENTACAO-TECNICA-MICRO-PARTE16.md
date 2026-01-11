# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 16
## Módulo de DIRF e Informe de Rendimentos

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerar a DIRF (Declaração do Imposto de Renda Retido na Fonte) para envio à Receita Federal e os Informes de Rendimentos individuais para os servidores declararem seu IR.

### 1.2 Obrigações Legais

| Obrigação | Prazo | Destinatário |
|-----------|-------|--------------|
| **DIRF** | Último dia útil de fevereiro | Receita Federal |
| **Informe de Rendimentos** | Até 28 de fevereiro | Servidor |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: DIRF

```java
@Entity
@Table(name = "dirf")
public class DIRF extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ano_calendario")
    private Integer anoCalendario; // Ex: 2025
    
    @Column(name = "ano_exercicio")
    private Integer anoExercicio; // Ex: 2026
    
    @Column(name = "numero_recibo", length = 30)
    private String numeroRecibo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoDIRF situacao;
    
    @Column(name = "retificadora")
    private Boolean retificadora = false;
    
    @Column(name = "numero_dirf_original", length = 30)
    private String numeroDirfOriginal; // Se retificadora
    
    // Totalizadores
    @Column(name = "total_beneficiarios")
    private Integer totalBeneficiarios;
    
    @Column(name = "total_rendimentos")
    private BigDecimal totalRendimentos;
    
    @Column(name = "total_irrf")
    private BigDecimal totalIRRF;
    
    @Column(name = "total_previdencia")
    private BigDecimal totalPrevidencia;
    
    @Column(name = "total_pensao_alimenticia")
    private BigDecimal totalPensaoAlimenticia;
    
    // Datas
    @Column(name = "data_geracao")
    private LocalDateTime dataGeracao;
    
    @Column(name = "data_transmissao")
    private LocalDateTime dataTransmissao;
    
    // Arquivo
    @Column(name = "arquivo_nome", length = 200)
    private String arquivoNome;
    
    @Column(name = "arquivo_hash", length = 64)
    private String arquivoHash;
    
    @OneToMany(mappedBy = "dirf", cascade = CascadeType.ALL)
    private List<DIRFBeneficiario> beneficiarios = new ArrayList<>();
}
```

### 2.2 Entidade: DIRFBeneficiario

```java
@Entity
@Table(name = "dirf_beneficiario")
public class DIRFBeneficiario extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "dirf_id", nullable = false)
    private DIRF dirf;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id")
    private Servidor servidor;
    
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    // Natureza do rendimento
    @Column(name = "codigo_receita", length = 10)
    private String codigoReceita; // 0561 (trabalho assalariado)
    
    // Rendimentos tributáveis
    @Column(name = "rendimentos_tributaveis")
    private BigDecimal rendimentosTributaveis;
    
    @Column(name = "contrib_previdenciaria")
    private BigDecimal contribPrevidenciaria;
    
    @Column(name = "pensao_alimenticia")
    private BigDecimal pensaoAlimenticia;
    
    @Column(name = "irrf")
    private BigDecimal irrf;
    
    // 13º Salário
    @Column(name = "decimo_terceiro")
    private BigDecimal decimoTerceiro;
    
    @Column(name = "irrf_decimo_terceiro")
    private BigDecimal irrfDecimoTerceiro;
    
    // Rendimentos isentos
    @Column(name = "rendimentos_isentos")
    private BigDecimal rendimentosIsentos;
    
    // Rendimentos com tributação exclusiva
    @Column(name = "rendimentos_trib_exclusiva")
    private BigDecimal rendimentosTribExclusiva;
    
    // Deduções
    @Column(name = "dependentes_deducao")
    private BigDecimal dependentesDeducao;
    
    @Column(name = "quantidade_dependentes")
    private Integer quantidadeDependentes;
    
    // Detalhamento mensal
    @OneToMany(mappedBy = "beneficiario", cascade = CascadeType.ALL)
    private List<DIRFBeneficiarioMensal> mensais = new ArrayList<>();
    
    // Dependentes informados
    @OneToMany(mappedBy = "beneficiario", cascade = CascadeType.ALL)
    private List<DIRFDependente> dependentes = new ArrayList<>();
}
```

### 2.3 Entidade: DIRFBeneficiarioMensal

```java
@Entity
@Table(name = "dirf_beneficiario_mensal")
public class DIRFBeneficiarioMensal extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "beneficiario_id", nullable = false)
    private DIRFBeneficiario beneficiario;
    
    @Column(name = "mes")
    private Integer mes; // 1-12 e 13 para 13º
    
    @Column(name = "rendimento_bruto")
    private BigDecimal rendimentoBruto;
    
    @Column(name = "previdencia")
    private BigDecimal previdencia;
    
    @Column(name = "pensao_alimenticia")
    private BigDecimal pensaoAlimenticia;
    
    @Column(name = "deducao_dependentes")
    private BigDecimal deducaoDependentes;
    
    @Column(name = "base_calculo")
    private BigDecimal baseCalculo;
    
    @Column(name = "irrf")
    private BigDecimal irrf;
}
```

### 2.4 Entidade: InformeRendimentos

```java
@Entity
@Table(name = "informe_rendimentos")
public class InformeRendimentos extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "servidor_id", nullable = false)
    private Servidor servidor;
    
    @Column(name = "ano_calendario")
    private Integer anoCalendario;
    
    // Fonte Pagadora
    @Column(name = "cnpj_fonte", length = 20)
    private String cnpjFonte;
    
    @Column(name = "nome_fonte", length = 200)
    private String nomeFonte;
    
    // Beneficiário
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    // QUADRO 3 - Rendimentos Tributáveis
    @Column(name = "total_rendimentos")
    private BigDecimal totalRendimentos;
    
    @Column(name = "contrib_previdenciaria")
    private BigDecimal contribPrevidenciaria;
    
    @Column(name = "pensao_alimenticia")
    private BigDecimal pensaoAlimenticia;
    
    @Column(name = "irrf")
    private BigDecimal irrf;
    
    // QUADRO 4 - Rendimentos Isentos e Não Tributáveis
    @Column(name = "parcela_isenta_65_anos")
    private BigDecimal parcelaIsenta65Anos;
    
    @Column(name = "diarias_ajuda_custo")
    private BigDecimal diariasAjudaCusto;
    
    @Column(name = "pensao_aposentadoria_invalidez")
    private BigDecimal pensaoAposentadoriaInvalidez;
    
    @Column(name = "outros_isentos")
    private BigDecimal outrosIsentos;
    
    // QUADRO 5 - Rendimentos Tributação Exclusiva
    @Column(name = "decimo_terceiro_liquido")
    private BigDecimal decimoTerceiroLiquido;
    
    @Column(name = "irrf_decimo_terceiro")
    private BigDecimal irrfDecimoTerceiro;
    
    @Column(name = "outros_trib_exclusiva")
    private BigDecimal outrosTribExclusiva;
    
    // QUADRO 6 - Rendimentos Recebidos Acumuladamente (RRA)
    @Column(name = "rra_total")
    private BigDecimal rraTotal;
    
    @Column(name = "rra_exclusivo_fonte")
    private BigDecimal rraExclusivoFonte;
    
    // QUADRO 7 - Informações Complementares
    @Column(name = "informacoes_complementares", length = 2000)
    private String informacoesComplementares;
    
    // Geração
    @Column(name = "data_geracao")
    private LocalDateTime dataGeracao;
    
    @Column(name = "hash_documento", length = 64)
    private String hashDocumento;
    
    @Column(name = "disponibilizado_portal")
    private Boolean disponibilizadoPortal = false;
    
    @Column(name = "data_disponibilizacao")
    private LocalDateTime dataDisponibilizacao;
}
```

### 2.5 Enums

```java
public enum SituacaoDIRF {
    RASCUNHO,
    GERANDO,
    GERADA,
    VALIDADA,
    TRANSMITIDA,
    ERRO_VALIDACAO,
    ERRO_TRANSMISSAO
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Geração da DIRF

```
REGRA DI-001: Beneficiários Obrigatórios
├── Todos com rendimento tributável no ano
├── Todos com IRRF retido (mesmo que R$ 0,01)
├── Pensionistas alimentícios
└── Beneficiários de RRA

REGRA DI-002: Códigos de Receita
├── 0561 - Trabalho Assalariado
├── 0588 - Aposentadorias/Pensões
├── 3208 - Aluguéis/Royalties
├── 0473 - RRA (Rendimentos Acumulados)
└── Outros conforme natureza

REGRA DI-003: Valores Mensais
├── Informar mês a mês
├── Mês 13 = 13º salário
├── Valores com centavos
└── IRRF efetivamente retido
```

### 3.2 Informe de Rendimentos

```
REGRA IR-001: Prazo de Entrega
├── Até 28 de fevereiro
├── Disponibilizar no portal do servidor
├── Enviar por e-mail (opcional)
└── Imprimir para entrega física (se solicitado)

REGRA IR-002: Quadros do Informe
├── Quadro 3: Rendimentos tributáveis
├── Quadro 4: Isentos e não tributáveis
├── Quadro 5: Tributação exclusiva
├── Quadro 6: RRA
└── Quadro 7: Informações complementares

REGRA IR-003: Rendimentos Isentos
├── Maiores de 65 anos: parcela isenta até limite
│   └── 2025: R$ 1.903,98 × 12 + R$ 1.903,98 (13º)
├── Aposentadoria por invalidez: isenta
├── Moléstia grave (art. 6º Lei 7.713): isenta
└── Diárias e ajudas de custo: isentas
```

### 3.3 Cálculos

```
CÁLCULO RENDIMENTO TRIBUTÁVEL:

Total Rendimentos Tributáveis =
  Σ(Salário Bruto Mensal)
  - Férias Indenizadas
  - Abono Pecuniário de Férias
  - Licença-prêmio Convertida
  - Outras verbas indenizatórias

CÁLCULO BASE IRRF:

Base de Cálculo =
  Rendimento Bruto
  - Contribuição Previdenciária
  - Pensão Alimentícia
  - Dedução por Dependente (valor fixo × qtd)
  - Parcela Isenta (se > 65 anos)
```

---

## 4. FLUXO DE GERAÇÃO

```
┌─────────────────────────────────────────────────────────────┐
│               FLUXO GERAÇÃO DIRF/INFORME                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Janeiro - Preparação]                                    │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────┐                   │
│  │ 1. Fechamento Folha Dezembro        │                   │
│  │    + Folha 13º Salário              │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 2. Conferência de Valores           │                   │
│  │    - Totalizar rendimentos          │                   │
│  │    - Totalizar IRRF                 │                   │
│  │    - Verificar inconsistências      │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 3. Gerar Arquivo DIRF               │                   │
│  │    - Layout RFB vigente             │                   │
│  │    - Validar estrutura              │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 4. Validar no PGD DIRF              │                   │
│  │    - Importar arquivo               │                   │
│  │    - Verificar erros/avisos         │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│         ┌───────────┴───────────┐                          │
│         │                       │                           │
│         ▼                       ▼                           │
│  ┌───────────┐          ┌───────────┐                      │
│  │ ERROS     │          │ OK        │                      │
│  │ Corrigir  │          │           │                      │
│  └─────┬─────┘          └─────┬─────┘                      │
│        │                      │                            │
│        └──────────────────────┤                            │
│                               ▼                            │
│  ┌─────────────────────────────────────┐                   │
│  │ 5. Transmitir DIRF                  │                   │
│  │    - ReceitaNet                     │                   │
│  │    - Certificado Digital            │                   │
│  │    - Obter recibo                   │                   │
│  └──────────────────┬──────────────────┘                   │
│                     │                                       │
│                     ▼                                       │
│  ┌─────────────────────────────────────┐                   │
│  │ 6. Gerar Informes Individuais       │                   │
│  │    - PDF para cada servidor         │                   │
│  │    - Disponibilizar no portal       │                   │
│  │    - Notificar servidores           │                   │
│  └─────────────────────────────────────┘                   │
│                                                             │
│  [Fevereiro - Prazo final: dia 28]                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 5. SERVIÇOS PRINCIPAIS

### 5.1 DIRFService

```java
@Service
@Transactional
public class DIRFService extends AbstractTenantService {
    
    /**
     * Gerar DIRF do ano
     */
    public DIRF gerarDIRF(Integer anoCalendario) {
        DIRF dirf = new DIRF();
        dirf.setAnoCalendario(anoCalendario);
        dirf.setAnoExercicio(anoCalendario + 1);
        dirf.setSituacao(SituacaoDIRF.GERANDO);
        dirf.setDataGeracao(LocalDateTime.now());
        
        dirf = dirfRepository.save(dirf);
        
        // Buscar todos os servidores com folha no ano
        List<Servidor> servidores = servidorRepository
            .findComFolhaNoAno(anoCalendario);
        
        BigDecimal totalRendimentos = BigDecimal.ZERO;
        BigDecimal totalIRRF = BigDecimal.ZERO;
        BigDecimal totalPrevidencia = BigDecimal.ZERO;
        
        for (Servidor servidor : servidores) {
            DIRFBeneficiario beneficiario = gerarBeneficiario(dirf, servidor, anoCalendario);
            
            if (beneficiario != null) {
                dirf.getBeneficiarios().add(beneficiario);
                totalRendimentos = totalRendimentos.add(
                    beneficiario.getRendimentosTributaveis());
                totalIRRF = totalIRRF.add(
                    beneficiario.getIrrf());
                totalPrevidencia = totalPrevidencia.add(
                    beneficiario.getContribPrevidenciaria());
            }
        }
        
        // Totalizadores
        dirf.setTotalBeneficiarios(dirf.getBeneficiarios().size());
        dirf.setTotalRendimentos(totalRendimentos);
        dirf.setTotalIRRF(totalIRRF);
        dirf.setTotalPrevidencia(totalPrevidencia);
        dirf.setSituacao(SituacaoDIRF.GERADA);
        
        return dirfRepository.save(dirf);
    }
    
    /**
     * Gerar dados do beneficiário
     */
    private DIRFBeneficiario gerarBeneficiario(DIRF dirf, Servidor servidor, Integer ano) {
        // Buscar folhas do servidor no ano
        List<FolhaPagamentoDet> folhas = folhaDetRepository
            .findByServidorAndAno(servidor.getId(), ano);
        
        if (folhas.isEmpty()) {
            return null;
        }
        
        DIRFBeneficiario beneficiario = new DIRFBeneficiario();
        beneficiario.setDirf(dirf);
        beneficiario.setServidor(servidor);
        beneficiario.setCpf(servidor.getCpf());
        beneficiario.setNome(servidor.getNome());
        beneficiario.setCodigoReceita("0561");
        
        BigDecimal rendTributaveis = BigDecimal.ZERO;
        BigDecimal previdencia = BigDecimal.ZERO;
        BigDecimal irrf = BigDecimal.ZERO;
        BigDecimal decimoTerceiro = BigDecimal.ZERO;
        BigDecimal irrfDecimo = BigDecimal.ZERO;
        
        // Agrupar por mês
        Map<Integer, List<FolhaPagamentoDet>> porMes = folhas.stream()
            .collect(Collectors.groupingBy(f -> f.getFolha().getMes()));
        
        for (int mes = 1; mes <= 13; mes++) {
            List<FolhaPagamentoDet> folhasMes = porMes.getOrDefault(mes, List.of());
            
            DIRFBeneficiarioMensal mensal = calcularMensal(beneficiario, mes, folhasMes);
            beneficiario.getMensais().add(mensal);
            
            if (mes == 13) {
                // 13º salário
                decimoTerceiro = decimoTerceiro.add(mensal.getRendimentoBruto());
                irrfDecimo = irrfDecimo.add(mensal.getIrrf());
            } else {
                rendTributaveis = rendTributaveis.add(mensal.getRendimentoBruto());
                irrf = irrf.add(mensal.getIrrf());
            }
            previdencia = previdencia.add(mensal.getPrevidencia());
        }
        
        beneficiario.setRendimentosTributaveis(rendTributaveis);
        beneficiario.setContribPrevidenciaria(previdencia);
        beneficiario.setIrrf(irrf);
        beneficiario.setDecimoTerceiro(decimoTerceiro);
        beneficiario.setIrrfDecimoTerceiro(irrfDecimo);
        
        // Buscar dependentes para IR
        List<Dependente> dependentes = dependenteRepository
            .findDedutiveisIR(servidor.getId());
        beneficiario.setQuantidadeDependentes(dependentes.size());
        
        for (Dependente dep : dependentes) {
            DIRFDependente dirfDep = new DIRFDependente();
            dirfDep.setBeneficiario(beneficiario);
            dirfDep.setCpf(dep.getCpf());
            dirfDep.setNome(dep.getNome());
            dirfDep.setDataNascimento(dep.getDataNascimento());
            dirfDep.setParentesco(dep.getParentesco());
            beneficiario.getDependentes().add(dirfDep);
        }
        
        // Só incluir se teve rendimento ou IRRF
        if (rendTributaveis.compareTo(BigDecimal.ZERO) > 0 ||
            irrf.compareTo(BigDecimal.ZERO) > 0) {
            return beneficiario;
        }
        
        return null;
    }
    
    /**
     * Exportar arquivo DIRF
     */
    public byte[] exportarArquivo(Long dirfId) {
        DIRF dirf = dirfRepository.findById(dirfId).orElseThrow();
        
        StringBuilder sb = new StringBuilder();
        
        // Registro DIRF (tipo 1)
        sb.append(gerarRegistroDIRF(dirf));
        
        // Registro Responsável (tipo 2)
        sb.append(gerarRegistroResponsavel(dirf));
        
        // Para cada beneficiário
        for (DIRFBeneficiario ben : dirf.getBeneficiarios()) {
            // Registro BPFDEC (tipo 3)
            sb.append(gerarRegistroBeneficiario(ben));
            
            // Registros RTRT (rendimentos mensais)
            for (DIRFBeneficiarioMensal mensal : ben.getMensais()) {
                sb.append(gerarRegistroRendimento(mensal));
            }
            
            // Registros INFPA (dependentes)
            for (DIRFDependente dep : ben.getDependentes()) {
                sb.append(gerarRegistroDependente(dep));
            }
        }
        
        // Registro FIMDIRF
        sb.append("FIMDIRF\r\n");
        
        byte[] arquivo = sb.toString().getBytes(StandardCharsets.ISO_8859_1);
        
        // Salvar hash
        dirf.setArquivoHash(DigestUtils.sha256Hex(arquivo));
        dirf.setArquivoNome("DIRF" + dirf.getAnoExercicio() + ".txt");
        dirf.setSituacao(SituacaoDIRF.VALIDADA);
        
        return arquivo;
    }
}
```

### 5.2 InformeRendimentosService

```java
@Service
public class InformeRendimentosService {
    
    /**
     * Gerar informes de todos os servidores
     */
    public int gerarInformes(Integer anoCalendario) {
        // Buscar DIRF do ano
        DIRF dirf = dirfRepository.findByAnoCalendario(anoCalendario)
            .orElseThrow(() -> new BusinessException("DIRF não gerada para o ano"));
        
        int count = 0;
        
        for (DIRFBeneficiario beneficiario : dirf.getBeneficiarios()) {
            InformeRendimentos informe = gerarInforme(beneficiario, anoCalendario);
            informeRepository.save(informe);
            count++;
        }
        
        return count;
    }
    
    /**
     * Gerar informe individual
     */
    private InformeRendimentos gerarInforme(DIRFBeneficiario beneficiario, Integer ano) {
        InformeRendimentos informe = new InformeRendimentos();
        informe.setServidor(beneficiario.getServidor());
        informe.setAnoCalendario(ano);
        
        // Fonte pagadora
        UnidadeGestora ug = beneficiario.getServidor().getUnidadeGestora();
        informe.setCnpjFonte(ug.getCnpj());
        informe.setNomeFonte(ug.getNome());
        
        // Beneficiário
        informe.setCpf(beneficiario.getCpf());
        informe.setNome(beneficiario.getNome());
        
        // Quadro 3 - Tributáveis
        informe.setTotalRendimentos(beneficiario.getRendimentosTributaveis());
        informe.setContribPrevidenciaria(beneficiario.getContribPrevidenciaria());
        informe.setPensaoAlimenticia(beneficiario.getPensaoAlimenticia());
        informe.setIrrf(beneficiario.getIrrf());
        
        // Quadro 4 - Isentos
        BigDecimal isentos = calcularRendimentosIsentos(beneficiario);
        informe.setParcelaIsenta65Anos(calcularParcelaIsenta65(beneficiario));
        informe.setDiariasAjudaCusto(calcularDiarias(beneficiario));
        informe.setOutrosIsentos(isentos);
        
        // Quadro 5 - Tributação Exclusiva
        informe.setDecimoTerceiroLiquido(beneficiario.getDecimoTerceiro()
            .subtract(beneficiario.getIrrfDecimoTerceiro()));
        informe.setIrrfDecimoTerceiro(beneficiario.getIrrfDecimoTerceiro());
        
        informe.setDataGeracao(LocalDateTime.now());
        informe.setHashDocumento(gerarHash(informe));
        
        return informe;
    }
    
    /**
     * Gerar PDF do informe
     */
    public byte[] gerarPDF(Long informeId) {
        InformeRendimentos informe = informeRepository.findById(informeId).orElseThrow();
        
        // Template baseado no modelo oficial RFB
        Context context = new Context();
        context.setVariable("informe", informe);
        context.setVariable("ano", informe.getAnoCalendario());
        
        String html = templateEngine.process("informe-rendimentos", context);
        
        return pdfService.htmlToPdf(html);
    }
    
    /**
     * Disponibilizar no portal do servidor
     */
    public void disponibilizarNoPortal(Integer anoCalendario) {
        List<InformeRendimentos> informes = informeRepository
            .findByAnoCalendario(anoCalendario);
        
        LocalDateTime agora = LocalDateTime.now();
        
        for (InformeRendimentos informe : informes) {
            informe.setDisponibilizadoPortal(true);
            informe.setDataDisponibilizacao(agora);
            
            // Notificar servidor por e-mail
            notificacaoService.enviarNotificacaoInformeDisponivel(
                informe.getServidor(),
                anoCalendario
            );
        }
        
        informeRepository.saveAll(informes);
    }
}
```

---

## 6. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| **DIRF** |||
| GET | `/api/dirf` | Listar DIRFs | ADMIN |
| POST | `/api/dirf/gerar/{ano}` | Gerar DIRF do ano | ADMIN |
| GET | `/api/dirf/{id}` | Detalhe DIRF | ADMIN |
| GET | `/api/dirf/{id}/arquivo` | Download arquivo | ADMIN |
| POST | `/api/dirf/{id}/validar` | Validar arquivo | ADMIN |
| PUT | `/api/dirf/{id}/transmitir` | Registrar transmissão | ADMIN |
| **Informe** |||
| GET | `/api/informes` | Listar informes (admin) | ADMIN |
| POST | `/api/informes/gerar/{ano}` | Gerar informes do ano | ADMIN |
| POST | `/api/informes/disponibilizar/{ano}` | Disponibilizar no portal | ADMIN |
| GET | `/api/informes/meus` | Meus informes (servidor) | USUARIO |
| GET | `/api/informes/{id}/pdf` | Download PDF | USUARIO+ |

---

## 7. LAYOUT ARQUIVO DIRF

### 7.1 Estrutura de Registros

```
DIRF|2026|A|||S|...                     → Registro identificador
RESPO|12345678000190|PREFEITURA...|...  → Responsável
DECPF|12345678901|JOAO DA SILVA|...     → Beneficiário PF
IDREC|0561|...                          → Identificação receita
RTRT|01|10000.00|1000.00|200.00|...     → Rendimento mês 01
RTRT|02|10000.00|1000.00|200.00|...     → Rendimento mês 02
...
RTRT|13|5000.00|500.00|100.00|...       → 13º salário
INFPA|12345678902|MARIA|10|...          → Dependente
FIMDIRF                                  → Fim do arquivo
```

---
