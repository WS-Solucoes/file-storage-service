# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 17
## Módulo de RAIS (Relação Anual de Informações Sociais)

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerar e transmitir a RAIS, obrigação anual do Ministério do Trabalho que informa dados dos servidores/empregados para fins estatísticos e de controle do FGTS e benefícios previdenciários.

### 1.2 Prazo de Entrega
- **Período:** Informações do ano-calendário anterior
- **Prazo:** Geralmente março do ano seguinte
- **Penalidades:** Multa por atraso ou omissão

---

## 2. MODELO DE DADOS

### 2.1 Entidade: RAIS

```java
@Entity
@Table(name = "rais")
public class RAIS extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "ano_base")
    private Integer anoBase; // Ex: 2025
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 20)
    private TipoRAIS tipo; // NORMAL, NEGATIVA, RETIFICADORA
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoRAIS situacao;
    
    @Column(name = "numero_protocolo", length = 30)
    private String numeroProtocolo;
    
    @Column(name = "numero_recibo", length = 30)
    private String numeroRecibo;
    
    // Totalizadores
    @Column(name = "total_estabelecimentos")
    private Integer totalEstabelecimentos;
    
    @Column(name = "total_vinculos")
    private Integer totalVinculos;
    
    @Column(name = "total_admissoes")
    private Integer totalAdmissoes;
    
    @Column(name = "total_desligamentos")
    private Integer totalDesligamentos;
    
    @Column(name = "total_remuneracao")
    private BigDecimal totalRemuneracao;
    
    // Datas
    @Column(name = "data_geracao")
    private LocalDateTime dataGeracao;
    
    @Column(name = "data_transmissao")
    private LocalDateTime dataTransmissao;
    
    // Arquivo
    @Column(name = "arquivo_nome", length = 200)
    private String arquivoNome;
    
    @OneToMany(mappedBy = "rais", cascade = CascadeType.ALL)
    private List<RAISEstabelecimento> estabelecimentos = new ArrayList<>();
}
```

### 2.2 Entidade: RAISEstabelecimento

```java
@Entity
@Table(name = "rais_estabelecimento")
public class RAISEstabelecimento extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "rais_id", nullable = false)
    private RAIS rais;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "unidade_gestora_id")
    private UnidadeGestora unidadeGestora;
    
    // Identificação
    @Column(name = "cnpj", length = 20)
    private String cnpj;
    
    @Column(name = "razao_social", length = 200)
    private String razaoSocial;
    
    @Column(name = "cnae", length = 10)
    private String cnae;
    
    @Column(name = "natureza_juridica", length = 10)
    private String naturezaJuridica;
    
    // Endereço
    @Column(name = "cep", length = 10)
    private String cep;
    
    @Column(name = "logradouro", length = 200)
    private String logradouro;
    
    @Column(name = "numero", length = 20)
    private String numero;
    
    @Column(name = "bairro", length = 100)
    private String bairro;
    
    @Column(name = "municipio", length = 100)
    private String municipio;
    
    @Column(name = "uf", length = 2)
    private String uf;
    
    // Contatos
    @Column(name = "email", length = 200)
    private String email;
    
    @Column(name = "telefone", length = 20)
    private String telefone;
    
    // Totais do estabelecimento
    @Column(name = "total_vinculos")
    private Integer totalVinculos;
    
    @OneToMany(mappedBy = "estabelecimento", cascade = CascadeType.ALL)
    private List<RAISVinculo> vinculos = new ArrayList<>();
}
```

### 2.3 Entidade: RAISVinculo

```java
@Entity
@Table(name = "rais_vinculo")
public class RAISVinculo extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "estabelecimento_id", nullable = false)
    private RAISEstabelecimento estabelecimento;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id")
    private VinculoFuncional vinculoFuncional;
    
    // Identificação do trabalhador
    @Column(name = "pis", length = 15)
    private String pis;
    
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    @Column(name = "data_nascimento")
    private LocalDate dataNascimento;
    
    @Column(name = "sexo")
    private Integer sexo; // 1=Masculino, 2=Feminino
    
    @Column(name = "grau_instrucao")
    private Integer grauInstrucao; // Tabela RAIS
    
    @Column(name = "raca_cor")
    private Integer racaCor; // Tabela RAIS
    
    @Column(name = "deficiencia")
    private Integer deficiencia; // 0=Não, 1-6=Tipo
    
    @Column(name = "nacionalidade")
    private Integer nacionalidade;
    
    // Dados do vínculo
    @Column(name = "tipo_vinculo")
    private Integer tipoVinculo; // 30=Estatutário, 31=Estatutário RGPS
    
    @Column(name = "tipo_admissao")
    private Integer tipoAdmissao;
    
    @Column(name = "data_admissao")
    private LocalDate dataAdmissao;
    
    @Column(name = "cbo", length = 10)
    private String cbo;
    
    @Column(name = "horas_contratuais")
    private Integer horasContratuais;
    
    // Desligamento (se houver)
    @Column(name = "data_desligamento")
    private LocalDate dataDesligamento;
    
    @Column(name = "causa_desligamento")
    private Integer causaDesligamento;
    
    // Remunerações mensais
    @Column(name = "rem_janeiro") private BigDecimal remJaneiro;
    @Column(name = "rem_fevereiro") private BigDecimal remFevereiro;
    @Column(name = "rem_marco") private BigDecimal remMarco;
    @Column(name = "rem_abril") private BigDecimal remAbril;
    @Column(name = "rem_maio") private BigDecimal remMaio;
    @Column(name = "rem_junho") private BigDecimal remJunho;
    @Column(name = "rem_julho") private BigDecimal remJulho;
    @Column(name = "rem_agosto") private BigDecimal remAgosto;
    @Column(name = "rem_setembro") private BigDecimal remSetembro;
    @Column(name = "rem_outubro") private BigDecimal remOutubro;
    @Column(name = "rem_novembro") private BigDecimal remNovembro;
    @Column(name = "rem_dezembro") private BigDecimal remDezembro;
    @Column(name = "rem_13_salario") private BigDecimal rem13Salario;
    
    // Totais
    @Column(name = "total_remuneracao")
    private BigDecimal totalRemuneracao;
    
    @Column(name = "meses_trabalhados")
    private Integer mesesTrabalhados;
    
    // Contribuição sindical
    @Column(name = "contrib_sindical")
    private BigDecimal contribSindical;
    
    // Afastamentos
    @Column(name = "afastamento_inicio1") private LocalDate afastamentoInicio1;
    @Column(name = "afastamento_fim1") private LocalDate afastamentoFim1;
    @Column(name = "afastamento_motivo1") private Integer afastamentoMotivo1;
    
    @Column(name = "afastamento_inicio2") private LocalDate afastamentoInicio2;
    @Column(name = "afastamento_fim2") private LocalDate afastamentoFim2;
    @Column(name = "afastamento_motivo2") private Integer afastamentoMotivo2;
}
```

### 2.4 Enums

```java
public enum TipoRAIS {
    NORMAL,
    NEGATIVA,      // Sem empregados no ano
    RETIFICADORA
}

public enum SituacaoRAIS {
    RASCUNHO,
    GERANDO,
    GERADA,
    VALIDANDO,
    VALIDADA,
    TRANSMITIDA,
    ERRO_VALIDACAO,
    ERRO_TRANSMISSAO
}
```

---

## 3. TABELAS RAIS

### 3.1 Tipo de Vínculo (para servidores públicos)

| Código | Descrição |
|--------|-----------|
| 30 | Servidor público estatutário (RPPS) |
| 31 | Servidor público estatutário (RGPS) |
| 35 | Servidor público não-efetivo |
| 90 | Contrato temporário |

### 3.2 Causa de Desligamento

| Código | Descrição |
|--------|-----------|
| 10 | Exoneração a pedido |
| 11 | Exoneração de ofício |
| 20 | Demissão |
| 40 | Aposentadoria |
| 50 | Falecimento |
| 70 | Término de contrato |

### 3.3 Grau de Instrução

| Código | Descrição |
|--------|-----------|
| 1 | Analfabeto |
| 2 | Até 5ª ano incompleto |
| 3 | 5ª ano completo |
| 4 | 6ª a 9ª ano |
| 5 | Fundamental completo |
| 6 | Médio incompleto |
| 7 | Médio completo |
| 8 | Superior incompleto |
| 9 | Superior completo |
| 10 | Mestrado |
| 11 | Doutorado |

---

## 4. REGRAS DE NEGÓCIO

### 4.1 Geração RAIS

```
REGRA RA-001: Vínculos a Informar
├── Todos os servidores ativos no ano-base
├── Servidores desligados durante o ano
├── Servidores afastados (licença)
├── Aposentados/pensionistas (se fonte pagadora)
└── Excluir: estagiários, autônomos, cedidos

REGRA RA-002: Remuneração Mensal
├── Valor bruto (antes dos descontos)
├── Incluir: salário + adicionais + gratificações
├── Excluir: diárias, indenizações
├── 13º: informar valor pago no ano
└── Mês sem remuneração: informar 0,00

REGRA RA-003: Afastamentos
├── Informar até 3 afastamentos principais
├── Código do motivo conforme tabela
├── Datas início e fim
├── Afastamentos > 15 dias
```

### 4.2 Validações

```
REGRA VA-001: Dados Obrigatórios
├── PIS válido (dígito verificador)
├── CPF válido
├── CBO válido (6 dígitos)
├── Data admissão ≤ 31/12 ano-base
└── Data desligamento (se houver) no ano-base

REGRA VA-002: Consistências
├── Remuneração: não pode ser negativa
├── Meses trabalhados: 1-12
├── Data desligamento > data admissão
├── Sexo: 1 ou 2
└── Grau instrução: 1-11
```

---

## 5. SERVIÇOS PRINCIPAIS

### 5.1 RAISService

```java
@Service
@Transactional
public class RAISService extends AbstractTenantService {
    
    /**
     * Gerar RAIS do ano-base
     */
    public RAIS gerarRAIS(Integer anoBase) {
        RAIS rais = new RAIS();
        rais.setAnoBase(anoBase);
        rais.setTipo(TipoRAIS.NORMAL);
        rais.setSituacao(SituacaoRAIS.GERANDO);
        rais.setDataGeracao(LocalDateTime.now());
        
        rais = raisRepository.save(rais);
        
        // Buscar unidades gestoras (estabelecimentos)
        List<UnidadeGestora> unidades = unidadeGestoraRepository.findAllAtivas();
        
        int totalVinculos = 0;
        int totalAdmissoes = 0;
        int totalDesligamentos = 0;
        BigDecimal totalRemuneracao = BigDecimal.ZERO;
        
        for (UnidadeGestora ug : unidades) {
            RAISEstabelecimento estab = gerarEstabelecimento(rais, ug, anoBase);
            
            if (estab.getTotalVinculos() > 0) {
                rais.getEstabelecimentos().add(estab);
                totalVinculos += estab.getTotalVinculos();
                
                // Contabilizar admissões e desligamentos
                for (RAISVinculo v : estab.getVinculos()) {
                    if (v.getDataAdmissao().getYear() == anoBase) {
                        totalAdmissoes++;
                    }
                    if (v.getDataDesligamento() != null) {
                        totalDesligamentos++;
                    }
                    totalRemuneracao = totalRemuneracao.add(v.getTotalRemuneracao());
                }
            }
        }
        
        rais.setTotalEstabelecimentos(rais.getEstabelecimentos().size());
        rais.setTotalVinculos(totalVinculos);
        rais.setTotalAdmissoes(totalAdmissoes);
        rais.setTotalDesligamentos(totalDesligamentos);
        rais.setTotalRemuneracao(totalRemuneracao);
        rais.setSituacao(SituacaoRAIS.GERADA);
        
        return raisRepository.save(rais);
    }
    
    /**
     * Gerar dados do estabelecimento
     */
    private RAISEstabelecimento gerarEstabelecimento(RAIS rais, UnidadeGestora ug, Integer ano) {
        RAISEstabelecimento estab = new RAISEstabelecimento();
        estab.setRais(rais);
        estab.setUnidadeGestora(ug);
        estab.setCnpj(ug.getCnpj());
        estab.setRazaoSocial(ug.getNome());
        estab.setCnae(ug.getCnae());
        estab.setNaturezaJuridica(ug.getNaturezaJuridica());
        
        // Endereço
        estab.setCep(ug.getCep());
        estab.setLogradouro(ug.getLogradouro());
        estab.setNumero(ug.getNumero());
        estab.setBairro(ug.getBairro());
        estab.setMunicipio(ug.getMunicipio());
        estab.setUf(ug.getUf());
        estab.setEmail(ug.getEmail());
        estab.setTelefone(ug.getTelefone());
        
        // Buscar vínculos do estabelecimento no ano
        List<VinculoFuncional> vinculos = vinculoRepository
            .findByUnidadeGestoraNoAno(ug.getId(), ano);
        
        for (VinculoFuncional vf : vinculos) {
            RAISVinculo raisVinculo = gerarVinculo(estab, vf, ano);
            estab.getVinculos().add(raisVinculo);
        }
        
        estab.setTotalVinculos(estab.getVinculos().size());
        
        return estab;
    }
    
    /**
     * Gerar dados do vínculo
     */
    private RAISVinculo gerarVinculo(RAISEstabelecimento estab, VinculoFuncional vf, Integer ano) {
        RAISVinculo vinculo = new RAISVinculo();
        vinculo.setEstabelecimento(estab);
        vinculo.setVinculoFuncional(vf);
        
        Servidor servidor = vf.getServidor();
        
        // Dados do trabalhador
        vinculo.setPis(servidor.getPis());
        vinculo.setCpf(servidor.getCpf());
        vinculo.setNome(servidor.getNome());
        vinculo.setDataNascimento(servidor.getDataNascimento());
        vinculo.setSexo(servidor.getSexo() == Sexo.MASCULINO ? 1 : 2);
        vinculo.setGrauInstrucao(mapearGrauInstrucao(servidor.getEscolaridade()));
        vinculo.setRacaCor(mapearRacaCor(servidor.getRacaCor()));
        vinculo.setDeficiencia(servidor.getPcd() ? 
            mapearDeficiencia(servidor.getTipoDeficiencia()) : 0);
        vinculo.setNacionalidade(10); // Brasileiro
        
        // Dados do vínculo
        vinculo.setTipoVinculo(mapearTipoVinculo(vf.getTipoVinculo(), vf.getRegimePrevidenciario()));
        vinculo.setTipoAdmissao(1); // Primeiro emprego ou não
        vinculo.setDataAdmissao(vf.getDataAdmissao());
        vinculo.setCbo(vf.getCargo().getCbo());
        vinculo.setHorasContratuais(vf.getCargaHoraria());
        
        // Desligamento
        if (vf.getDataDesligamento() != null && 
            vf.getDataDesligamento().getYear() == ano) {
            vinculo.setDataDesligamento(vf.getDataDesligamento());
            vinculo.setCausaDesligamento(mapearCausaDesligamento(vf.getMotivoDesligamento()));
        }
        
        // Remunerações mensais
        BigDecimal totalRem = BigDecimal.ZERO;
        int mesesTrabalhados = 0;
        
        for (int mes = 1; mes <= 12; mes++) {
            BigDecimal remMes = calcularRemuneracaoMes(vf.getId(), ano, mes);
            setRemuneracaoMes(vinculo, mes, remMes);
            if (remMes.compareTo(BigDecimal.ZERO) > 0) {
                totalRem = totalRem.add(remMes);
                mesesTrabalhados++;
            }
        }
        
        // 13º salário
        BigDecimal rem13 = calcularRemuneracao13(vf.getId(), ano);
        vinculo.setRem13Salario(rem13);
        totalRem = totalRem.add(rem13);
        
        vinculo.setTotalRemuneracao(totalRem);
        vinculo.setMesesTrabalhados(mesesTrabalhados);
        
        // Afastamentos
        List<Afastamento> afastamentos = afastamentoRepository
            .findByVinculoNoAno(vf.getId(), ano);
        
        if (afastamentos.size() >= 1) {
            vinculo.setAfastamentoInicio1(afastamentos.get(0).getDataInicio());
            vinculo.setAfastamentoFim1(afastamentos.get(0).getDataFim());
            vinculo.setAfastamentoMotivo1(mapearMotivoAfastamento(afastamentos.get(0).getTipo()));
        }
        if (afastamentos.size() >= 2) {
            vinculo.setAfastamentoInicio2(afastamentos.get(1).getDataInicio());
            vinculo.setAfastamentoFim2(afastamentos.get(1).getDataFim());
            vinculo.setAfastamentoMotivo2(mapearMotivoAfastamento(afastamentos.get(1).getTipo()));
        }
        
        return vinculo;
    }
    
    /**
     * Exportar arquivo RAIS
     */
    public byte[] exportarArquivo(Long raisId) {
        RAIS rais = raisRepository.findById(raisId).orElseThrow();
        
        StringBuilder sb = new StringBuilder();
        
        for (RAISEstabelecimento estab : rais.getEstabelecimentos()) {
            // Registro tipo 1 - Estabelecimento
            sb.append(gerarRegistroEstabelecimento(estab, rais.getAnoBase()));
            
            // Registros tipo 2 - Vínculos
            for (RAISVinculo vinculo : estab.getVinculos()) {
                sb.append(gerarRegistroVinculo(vinculo));
            }
        }
        
        // Registro tipo 9 - Totalizador
        sb.append(gerarRegistroTotalizador(rais));
        
        byte[] arquivo = sb.toString().getBytes(StandardCharsets.ISO_8859_1);
        
        rais.setArquivoNome("RAIS" + rais.getAnoBase() + ".txt");
        rais.setSituacao(SituacaoRAIS.VALIDADA);
        
        return arquivo;
    }
}
```

---

## 6. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| GET | `/api/rais` | Listar RAIS | ADMIN |
| POST | `/api/rais/gerar/{ano}` | Gerar RAIS | ADMIN |
| GET | `/api/rais/{id}` | Detalhe | ADMIN |
| GET | `/api/rais/{id}/arquivo` | Download arquivo | ADMIN |
| GET | `/api/rais/{id}/inconsistencias` | Listar erros | ADMIN |
| PUT | `/api/rais/{id}/transmitir` | Registrar transmissão | ADMIN |

---
