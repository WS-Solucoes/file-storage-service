# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 15
## Módulo de Saúde Ocupacional (SST)

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar a saúde e segurança do trabalho dos servidores municipais, incluindo exames ocupacionais, perícias médicas, afastamentos por saúde e conformidade com eSocial.

### 1.2 Funcionalidades Principais

| Funcionalidade | Descrição |
|----------------|-----------|
| **ASO** | Atestados de Saúde Ocupacional |
| **PCMSO** | Programa de Controle Médico |
| **PPP** | Perfil Profissiográfico Previdenciário |
| **Perícias** | Agendamento e laudos |
| **Afastamentos** | Licenças por saúde |
| **eSocial SST** | Eventos S-2220, S-2240 |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: ExameOcupacional (ASO)

```java
@Entity
@Table(name = "exame_ocupacional")
public class ExameOcupacional extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_exame", length = 30)
    private TipoExameOcupacional tipoExame;
    
    @Column(name = "data_exame")
    private LocalDate dataExame;
    
    @Column(name = "data_validade")
    private LocalDate dataValidade;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado", length = 20)
    private ResultadoASO resultado;
    
    @Column(name = "observacoes", length = 2000)
    private String observacoes;
    
    @Column(name = "restricoes", length = 1000)
    private String restricoes; // Restrições laborais
    
    // Médico
    @Column(name = "medico_nome", length = 200)
    private String medicoNome;
    
    @Column(name = "medico_crm", length = 20)
    private String medicoCRM;
    
    @Column(name = "medico_uf", length = 2)
    private String medicoUF;
    
    // Riscos ocupacionais identificados
    @ManyToMany
    @JoinTable(name = "exame_risco",
        joinColumns = @JoinColumn(name = "exame_id"),
        inverseJoinColumns = @JoinColumn(name = "risco_id"))
    private Set<RiscoOcupacional> riscos = new HashSet<>();
    
    // Exames complementares realizados
    @OneToMany(mappedBy = "exameOcupacional", cascade = CascadeType.ALL)
    private List<ExameComplementar> examesComplementares = new ArrayList<>();
    
    // Integração eSocial
    @Column(name = "esocial_enviado")
    private Boolean esocialEnviado = false;
    
    @Column(name = "esocial_recibo", length = 50)
    private String esocialRecibo;
}
```

### 2.2 Entidade: ExameComplementar

```java
@Entity
@Table(name = "exame_complementar")
public class ExameComplementar extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "exame_ocupacional_id")
    private ExameOcupacional exameOcupacional;
    
    @Column(name = "codigo_tabela", length = 10)
    private String codigoTabela; // Tabela eSocial 27
    
    @Column(name = "descricao", length = 200)
    private String descricao;
    
    @Column(name = "data_realizacao")
    private LocalDate dataRealizacao;
    
    @Column(name = "resultado", length = 500)
    private String resultado;
    
    @Column(name = "interpretacao", length = 500)
    private String interpretacao;
    
    @Column(name = "ordem_exame", length = 50)
    private String ordemExame; // Protocolo/ordem de serviço
}
```

### 2.3 Entidade: RiscoOcupacional

```java
@Entity
@Table(name = "risco_ocupacional")
public class RiscoOcupacional extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "codigo", length = 20)
    private String codigo; // Código tabela eSocial
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 20)
    private TipoRisco tipo; // FISICO, QUIMICO, BIOLOGICO, ERGONOMICO, ACIDENTE
    
    @Column(name = "descricao", length = 500)
    private String descricao;
    
    @Column(name = "fator_risco", length = 200)
    private String fatorRisco; // Ex: "Ruído contínuo"
    
    @Column(name = "intensidade", length = 100)
    private String intensidade;
    
    @Column(name = "tecnica_utilizada", length = 200)
    private String tecnicaUtilizada;
    
    @Column(name = "epi_recomendado", length = 500)
    private String epiRecomendado;
    
    @Column(name = "ativo")
    private Boolean ativo = true;
}
```

### 2.4 Entidade: Pericia

```java
@Entity
@Table(name = "pericia")
public class Pericia extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 30)
    private TipoPericia tipo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "motivo", length = 50)
    private MotivoPericia motivo;
    
    @Column(name = "data_agendamento")
    private LocalDateTime dataAgendamento;
    
    @Column(name = "data_realizacao")
    private LocalDateTime dataRealizacao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoPericia situacao;
    
    // Laudo
    @Column(name = "laudo_numero", length = 50)
    private String laudoNumero;
    
    @Column(name = "laudo_data")
    private LocalDate laudoData;
    
    @Column(name = "cid_principal", length = 10)
    private String cidPrincipal;
    
    @Column(name = "cid_secundario", length = 10)
    private String cidSecundario;
    
    @Column(name = "parecer", length = 2000)
    private String parecer;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "resultado", length = 30)
    private ResultadoPericia resultado;
    
    // Período de afastamento (se aplicável)
    @Column(name = "dias_afastamento")
    private Integer diasAfastamento;
    
    @Column(name = "data_inicio_afastamento")
    private LocalDate dataInicioAfastamento;
    
    @Column(name = "data_fim_afastamento")
    private LocalDate dataFimAfastamento;
    
    @Column(name = "data_retorno")
    private LocalDate dataRetorno;
    
    // Perito
    @Column(name = "perito_nome", length = 200)
    private String peritoNome;
    
    @Column(name = "perito_crm", length = 20)
    private String peritoCRM;
    
    @Column(name = "perito_especialidade", length = 100)
    private String peritoEspecialidade;
    
    // Gera afastamento?
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "afastamento_id")
    private Afastamento afastamento;
}
```

### 2.5 Entidade: PPP (Perfil Profissiográfico Previdenciário)

```java
@Entity
@Table(name = "ppp")
public class PPP extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Column(name = "numero", length = 20)
    private String numero;
    
    @Column(name = "data_emissao")
    private LocalDate dataEmissao;
    
    // Seção 1: Dados do Empregador
    @Column(name = "cnpj_empregador", length = 20)
    private String cnpjEmpregador;
    
    @Column(name = "nome_empregador", length = 200)
    private String nomeEmpregador;
    
    // Seção 2: Dados do Trabalhador
    @Column(name = "cpf", length = 14)
    private String cpf;
    
    @Column(name = "nome", length = 200)
    private String nome;
    
    @Column(name = "data_nascimento")
    private LocalDate dataNascimento;
    
    @Column(name = "sexo", length = 1)
    private String sexo;
    
    @Column(name = "nis", length = 15)
    private String nis;
    
    @Column(name = "data_admissao")
    private LocalDate dataAdmissao;
    
    // Seção 3: CTPS (para CLT)
    @Column(name = "ctps_numero", length = 20)
    private String ctpsNumero;
    
    @Column(name = "ctps_serie", length = 10)
    private String ctpsSerie;
    
    @Column(name = "ctps_uf", length = 2)
    private String ctpsUF;
    
    // Históricos
    @OneToMany(mappedBy = "ppp", cascade = CascadeType.ALL)
    private List<PPPAtividadeProfissional> atividades = new ArrayList<>();
    
    @OneToMany(mappedBy = "ppp", cascade = CascadeType.ALL)
    private List<PPPExposicaoRisco> exposicoes = new ArrayList<>();
    
    @OneToMany(mappedBy = "ppp", cascade = CascadeType.ALL)
    private List<PPPResultadoExame> resultadosExames = new ArrayList<>();
    
    // Responsável
    @Column(name = "responsavel_nome", length = 200)
    private String responsavelNome;
    
    @Column(name = "responsavel_nit", length = 15)
    private String responsavelNIT;
    
    @Column(name = "responsavel_cargo", length = 100)
    private String responsavelCargo;
}
```

### 2.6 Entidade: CAT (Comunicação de Acidente de Trabalho)

```java
@Entity
@Table(name = "cat")
public class CAT extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 20)
    private TipoCAT tipo; // INICIAL, REABERTURA, OBITO
    
    @Column(name = "numero_cat", length = 30)
    private String numeroCAT;
    
    // Data e hora do acidente
    @Column(name = "data_acidente")
    private LocalDate dataAcidente;
    
    @Column(name = "hora_acidente")
    private LocalTime horaAcidente;
    
    @Column(name = "horas_trabalhadas_antes")
    private Integer horasTrabalhadasAntes;
    
    // Local
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_local", length = 20)
    private TipoLocalAcidente tipoLocal; // ESTABELECIMENTO, EXTERNO, TRAJETO
    
    @Column(name = "local_acidente", length = 500)
    private String localAcidente;
    
    @Column(name = "especificacao_local", length = 500)
    private String especificacaoLocal;
    
    // Descrição
    @Column(name = "descricao", length = 2000)
    private String descricao;
    
    @Column(name = "parte_corpo_atingida", length = 100)
    private String parteCorpoAtingida;
    
    @Column(name = "agente_causador", length = 200)
    private String agenteCausador;
    
    // CID
    @Column(name = "cid", length = 10)
    private String cid;
    
    @Column(name = "natureza_lesao", length = 200)
    private String naturezaLesao;
    
    // Afastamento
    @Column(name = "houve_afastamento")
    private Boolean houveAfastamento;
    
    @Column(name = "ultimo_dia_trabalhado")
    private LocalDate ultimoDiaTrabalhado;
    
    // Testemunhas
    @Column(name = "testemunha1_nome", length = 200)
    private String testemunha1Nome;
    
    @Column(name = "testemunha1_endereco", length = 500)
    private String testemunha1Endereco;
    
    @Column(name = "testemunha2_nome", length = 200)
    private String testemunha2Nome;
    
    // Médico
    @Column(name = "medico_nome", length = 200)
    private String medicoNome;
    
    @Column(name = "medico_crm", length = 20)
    private String medicoCRM;
    
    // eSocial
    @Column(name = "esocial_enviado")
    private Boolean esocialEnviado = false;
}
```

### 2.7 Enums

```java
public enum TipoExameOcupacional {
    ADMISSIONAL,
    PERIODICO,
    RETORNO_TRABALHO,
    MUDANCA_RISCO,
    DEMISSIONAL
}

public enum ResultadoASO {
    APTO,
    APTO_COM_RESTRICAO,
    INAPTO_TEMPORARIO,
    INAPTO_DEFINITIVO
}

public enum TipoPericia {
    ADMISSIONAL,
    LICENCA_SAUDE,
    LICENCA_ACIDENTE,
    READAPTACAO,
    APOSENTADORIA_INVALIDEZ,
    RETORNO_TRABALHO
}

public enum MotivoPericia {
    DOENCA_COMUM,
    DOENCA_PROFISSIONAL,
    ACIDENTE_TRABALHO,
    ACIDENTE_TRAJETO,
    GESTACAO_RISCO,
    ACOMPANHAMENTO_FAMILIA
}

public enum ResultadoPericia {
    APTO,
    APTO_COM_RESTRICAO,
    INAPTO_TEMPORARIO,
    INAPTO_DEFINITIVO,
    READAPTACAO,
    APOSENTADORIA
}

public enum TipoRisco {
    FISICO,      // Ruído, temperatura, radiação
    QUIMICO,     // Poeira, gases, vapores
    BIOLOGICO,   // Vírus, bactérias
    ERGONOMICO,  // Postura, repetição
    ACIDENTE     // Mecânico, elétrico
}

public enum TipoCAT {
    INICIAL,
    REABERTURA,
    COMUNICACAO_OBITO
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Exames Ocupacionais

```
REGRA EO-001: Exame Admissional
├── Obrigatório antes do início das atividades
├── ASO válido = pode começar
├── ASO inapto = não pode ser admitido
└── Prazo: até data da posse

REGRA EO-002: Exame Periódico
├── Frequência conforme risco:
│   ├── Sem risco: anual (>45 anos) ou bienal (<45)
│   ├── Com risco: semestral ou conforme PCMSO
├── Servidor notificado 30 dias antes
└── Falta ao exame = advertência

REGRA EO-003: Exame Retorno ao Trabalho
├── Obrigatório após afastamento > 30 dias
├── Por doença ou acidente
├── ASO antes de reassumir
└── Pode ter restrições temporárias

REGRA EO-004: Exame Demissional
├── Até data do desligamento
├── Pode ser dispensado se:
│   ├── Último exame < 135 dias (grau 1-2)
│   └── Último exame < 90 dias (grau 3-4)
└── Obrigatório se exposição a riscos
```

### 3.2 Perícias Médicas

```
REGRA PM-001: Agendamento
├── RH agenda a pedido do servidor
├── Ou convocação para retorno
├── Antecedência mínima: 3 dias úteis
└── Servidor pode remarcar 1x

REGRA PM-002: Licença Saúde
├── Atestado médico + perícia
├── Até 15 dias: atestado do médico assistente
├── > 15 dias: perícia oficial obrigatória
├── Prorrogação: nova perícia
└── Alta: exame de retorno

REGRA PM-003: Readaptação
├── Servidor com restrição permanente
├── Perícia define limitações
├── Busca novo cargo compatível
├── Mantém remuneração do cargo original
└── Se não houver vaga: disponibilidade
```

### 3.3 eSocial SST

```
REGRA ES-001: S-2220 - Monitoramento Saúde
├── Enviar após cada ASO
├── Prazo: até dia 15 do mês seguinte
├── Dados: tipo exame, data, resultado, médico
└── Exames complementares inclusos

REGRA ES-002: S-2240 - Condições Ambientais
├── Enviar para cada servidor exposto a riscos
├── Atualizar quando mudar setor/função
├── Informar todos os fatores de risco
├── Código da tabela eSocial
└── Técnicas utilizadas

REGRA ES-003: S-2210 - CAT
├── Enviar imediatamente após acidente
├── Prazo máximo: 1 dia útil
├── Óbito: imediatamente
└── Campos obrigatórios conforme layout
```

---

## 4. FLUXOS DE PROCESSOS

### 4.1 Fluxo: Perícia Médica

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUXO DE PERÍCIA                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  [Servidor apresenta atestado]                             │
│       │                                                     │
│       ▼                                                     │
│  ┌─────────────────────────────────────┐                   │
│  │ Atestado > 15 dias?                 │                   │
│  └──────────────────┬──────────────────┘                   │
│         ┌───────────┴───────────┐                          │
│         │                       │                           │
│         ▼                       ▼                           │
│  ┌───────────┐          ┌───────────┐                      │
│  │ NÃO       │          │ SIM       │                      │
│  │ Homologa  │          │ Agendar   │                      │
│  │ atestado  │          │ perícia   │                      │
│  └─────┬─────┘          └─────┬─────┘                      │
│        │                      │                            │
│        │                      ▼                            │
│        │         ┌─────────────────────────────┐           │
│        │         │ PERÍCIA REALIZADA           │           │
│        │         └──────────────┬──────────────┘           │
│        │                        │                          │
│        │         ┌──────────────┼──────────────┐           │
│        │         │              │              │           │
│        │         ▼              ▼              ▼           │
│        │   ┌─────────┐   ┌─────────┐   ┌─────────┐        │
│        │   │ APTO    │   │ INAPTO  │   │READAPTA │        │
│        │   │ Alta    │   │ Prorroga│   │ Realocar│        │
│        │   └────┬────┘   └────┬────┘   └────┬────┘        │
│        │        │             │              │            │
│        │        ▼             ▼              ▼            │
│        │   ┌─────────────────────────────────────┐        │
│        │   │ Atualizar afastamento               │        │
│        │   └──────────────┬──────────────────────┘        │
│        │                  │                               │
│        └──────────────────┼───────────────────────────────│
│                           │                               │
│                           ▼                               │
│  ┌─────────────────────────────────────┐                  │
│  │ Gerar/Atualizar Afastamento         │                  │
│  │ Integrar com Folha                  │                  │
│  │ Enviar eSocial (se aplicável)       │                  │
│  └─────────────────────────────────────┘                  │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

---

## 5. SERVIÇOS PRINCIPAIS

### 5.1 ExameOcupacionalService

```java
@Service
@Transactional
public class ExameOcupacionalService extends AbstractTenantService {
    
    /**
     * Registrar ASO
     */
    public ExameOcupacional registrarASO(ASORequest request) {
        VinculoFuncional vinculo = vinculoRepository
            .findById(request.getVinculoId())
            .orElseThrow();
        
        ExameOcupacional exame = new ExameOcupacional();
        exame.setVinculo(vinculo);
        exame.setTipoExame(request.getTipoExame());
        exame.setDataExame(request.getDataExame());
        exame.setResultado(request.getResultado());
        exame.setObservacoes(request.getObservacoes());
        exame.setRestricoes(request.getRestricoes());
        
        // Médico
        exame.setMedicoNome(request.getMedicoNome());
        exame.setMedicoCRM(request.getMedicoCRM());
        exame.setMedicoUF(request.getMedicoUF());
        
        // Calcular validade conforme tipo
        exame.setDataValidade(calcularValidade(exame));
        
        // Registrar exames complementares
        for (ExameComplementarDTO ec : request.getExamesComplementares()) {
            ExameComplementar complementar = new ExameComplementar();
            complementar.setExameOcupacional(exame);
            complementar.setCodigoTabela(ec.getCodigo());
            complementar.setDescricao(ec.getDescricao());
            complementar.setDataRealizacao(ec.getData());
            complementar.setResultado(ec.getResultado());
            exame.getExamesComplementares().add(complementar);
        }
        
        exame = exameRepository.save(exame);
        
        // Enviar para eSocial S-2220
        if (configuracaoService.isEsocialAtivo()) {
            esocialService.enviarS2220(exame);
        }
        
        return exame;
    }
    
    /**
     * Buscar servidores com exame vencendo
     */
    public List<ExameVencendoDTO> buscarExamesVencendo(int diasAntecedencia) {
        LocalDate dataLimite = LocalDate.now().plusDays(diasAntecedencia);
        
        return exameRepository.findExamesVencendoAte(dataLimite);
    }
    
    /**
     * Verificar aptidão para trabalho
     */
    public boolean isAptoParaTrabalho(Long vinculoId) {
        ExameOcupacional ultimoExame = exameRepository
            .findUltimoByVinculo(vinculoId)
            .orElse(null);
        
        if (ultimoExame == null) {
            return false;
        }
        
        // Verificar validade
        if (ultimoExame.getDataValidade().isBefore(LocalDate.now())) {
            return false;
        }
        
        // Verificar resultado
        return ultimoExame.getResultado() == ResultadoASO.APTO ||
               ultimoExame.getResultado() == ResultadoASO.APTO_COM_RESTRICAO;
    }
}
```

### 5.2 PericiaService

```java
@Service
@Transactional
public class PericiaService extends AbstractTenantService {
    
    /**
     * Agendar perícia
     */
    public Pericia agendar(AgendamentoPericiaRequest request) {
        VinculoFuncional vinculo = vinculoRepository
            .findById(request.getVinculoId())
            .orElseThrow();
        
        // Verificar se há perícia pendente
        if (periciaRepository.existsPendenteByVinculo(vinculo.getId())) {
            throw new BusinessException("Já existe perícia pendente para este servidor");
        }
        
        Pericia pericia = new Pericia();
        pericia.setVinculo(vinculo);
        pericia.setTipo(request.getTipo());
        pericia.setMotivo(request.getMotivo());
        pericia.setDataAgendamento(request.getDataHora());
        pericia.setSituacao(SituacaoPericia.AGENDADA);
        
        pericia = periciaRepository.save(pericia);
        
        // Notificar servidor
        notificacaoService.notificarAgendamentoPericia(pericia);
        
        return pericia;
    }
    
    /**
     * Registrar resultado da perícia
     */
    public Pericia registrarResultado(Long periciaId, ResultadoPericiaRequest request) {
        Pericia pericia = periciaRepository.findById(periciaId).orElseThrow();
        
        pericia.setDataRealizacao(LocalDateTime.now());
        pericia.setLaudoNumero(request.getLaudoNumero());
        pericia.setLaudoData(request.getLaudoData());
        pericia.setCidPrincipal(request.getCidPrincipal());
        pericia.setCidSecundario(request.getCidSecundario());
        pericia.setParecer(request.getParecer());
        pericia.setResultado(request.getResultado());
        
        // Perito
        pericia.setPeritoNome(request.getPeritoNome());
        pericia.setPeritoCRM(request.getPeritoCRM());
        pericia.setPeritoEspecialidade(request.getPeritoEspecialidade());
        
        // Se gera afastamento
        if (request.getResultado() == ResultadoPericia.INAPTO_TEMPORARIO) {
            pericia.setDiasAfastamento(request.getDiasAfastamento());
            pericia.setDataInicioAfastamento(request.getDataInicioAfastamento());
            pericia.setDataFimAfastamento(
                request.getDataInicioAfastamento().plusDays(request.getDiasAfastamento()));
            
            // Criar/atualizar afastamento
            Afastamento afastamento = criarOuAtualizarAfastamento(pericia);
            pericia.setAfastamento(afastamento);
        }
        
        // Se alta
        if (request.getResultado() == ResultadoPericia.APTO) {
            pericia.setDataRetorno(request.getDataRetorno());
            
            // Agendar exame de retorno
            agendarExameRetorno(pericia);
        }
        
        // Se readaptação
        if (request.getResultado() == ResultadoPericia.READAPTACAO) {
            // Iniciar processo de readaptação
            readaptacaoService.iniciar(pericia, request.getRestricoes());
        }
        
        pericia.setSituacao(SituacaoPericia.CONCLUIDA);
        
        return periciaRepository.save(pericia);
    }
}
```

### 5.3 PPPService

```java
@Service
public class PPPService {
    
    /**
     * Gerar PPP do servidor
     */
    public PPP gerar(Long vinculoId) {
        VinculoFuncional vinculo = vinculoRepository.findById(vinculoId).orElseThrow();
        Servidor servidor = vinculo.getServidor();
        
        PPP ppp = new PPP();
        ppp.setVinculo(vinculo);
        ppp.setNumero(gerarNumeroPPP());
        ppp.setDataEmissao(LocalDate.now());
        
        // Seção 1 - Empregador
        UnidadeGestora ug = vinculo.getUnidadeGestora();
        ppp.setCnpjEmpregador(ug.getCnpj());
        ppp.setNomeEmpregador(ug.getNome());
        
        // Seção 2 - Trabalhador
        ppp.setCpf(servidor.getCpf());
        ppp.setNome(servidor.getNome());
        ppp.setDataNascimento(servidor.getDataNascimento());
        ppp.setSexo(servidor.getSexo().name().substring(0, 1));
        ppp.setNis(servidor.getPis());
        ppp.setDataAdmissao(vinculo.getDataAdmissao());
        
        // Histórico de atividades profissionais
        List<HistoricoLotacao> historico = historicoLotacaoRepository
            .findByVinculo(vinculoId);
        
        for (HistoricoLotacao h : historico) {
            PPPAtividadeProfissional atividade = new PPPAtividadeProfissional();
            atividade.setPpp(ppp);
            atividade.setDataInicio(h.getDataInicio());
            atividade.setDataFim(h.getDataFim());
            atividade.setCargo(h.getCargo().getNome());
            atividade.setCbo(h.getCargo().getCbo());
            atividade.setSetor(h.getLotacao().getNome());
            atividade.setDescricaoAtividades(h.getCargo().getDescricao());
            ppp.getAtividades().add(atividade);
        }
        
        // Exposições a riscos
        List<ExposicaoRisco> exposicoes = exposicaoRiscoRepository
            .findByVinculo(vinculoId);
        
        for (ExposicaoRisco e : exposicoes) {
            PPPExposicaoRisco exp = new PPPExposicaoRisco();
            exp.setPpp(ppp);
            exp.setDataInicio(e.getDataInicio());
            exp.setDataFim(e.getDataFim());
            exp.setTipoRisco(e.getRisco().getTipo().name());
            exp.setFatorRisco(e.getRisco().getFatorRisco());
            exp.setIntensidade(e.getIntensidade());
            exp.setTecnicaUtilizada(e.getTecnicaUtilizada());
            exp.setEpcEficaz(e.getEpcEficaz());
            exp.setEpiEficaz(e.getEpiEficaz());
            exp.setCaEPI(e.getCaEPI());
            ppp.getExposicoes().add(exp);
        }
        
        // Resultados de exames
        List<ExameOcupacional> exames = exameRepository.findByVinculo(vinculoId);
        
        for (ExameOcupacional ex : exames) {
            PPPResultadoExame res = new PPPResultadoExame();
            res.setPpp(ppp);
            res.setData(ex.getDataExame());
            res.setTipo(ex.getTipoExame().name());
            res.setResultado(ex.getResultado().name());
            res.setMedicoNome(ex.getMedicoNome());
            res.setMedicoCRM(ex.getMedicoCRM());
            ppp.getResultadosExames().add(res);
        }
        
        return pppRepository.save(ppp);
    }
}
```

---

## 6. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| **ASO** |||
| GET | `/api/sst/asos` | Listar ASOs | ANALISTA+ |
| POST | `/api/sst/asos` | Registrar ASO | MEDICO+ |
| GET | `/api/sst/asos/{id}` | Detalhe ASO | ANALISTA+ |
| GET | `/api/sst/asos/vencendo` | ASOs a vencer | ANALISTA+ |
| **Perícia** |||
| GET | `/api/sst/pericias` | Listar perícias | ANALISTA+ |
| POST | `/api/sst/pericias/agendar` | Agendar perícia | ANALISTA+ |
| PUT | `/api/sst/pericias/{id}/resultado` | Registrar resultado | MEDICO+ |
| GET | `/api/sst/pericias/agenda` | Agenda de perícias | MEDICO+ |
| **PPP** |||
| GET | `/api/sst/ppp/{vinculoId}` | Gerar/consultar PPP | ANALISTA+ |
| GET | `/api/sst/ppp/{id}/pdf` | Download PDF | USUARIO+ |
| **CAT** |||
| POST | `/api/sst/cat` | Registrar CAT | ANALISTA+ |
| GET | `/api/sst/cat/{id}` | Consultar CAT | ANALISTA+ |
| **Riscos** |||
| GET | `/api/sst/riscos` | Listar riscos | ANALISTA+ |
| POST | `/api/sst/riscos` | Cadastrar risco | ADMIN |
| POST | `/api/sst/exposicao` | Registrar exposição | ANALISTA+ |

---

## 7. INTEGRAÇÃO eSocial

### 7.1 Evento S-2220 - Monitoramento da Saúde do Trabalhador

```java
public class S2220Builder {
    
    public S2220 build(ExameOcupacional exame) {
        S2220 evento = new S2220();
        
        // Identificação
        evento.setIdEvento(gerarIdEvento());
        evento.setIndRetificacao(1); // Original
        
        // Trabalhador
        evento.setCpfTrabalhador(exame.getVinculo().getServidor().getCpf());
        evento.setNisTrabalhador(exame.getVinculo().getServidor().getPis());
        
        // Exame
        evento.setTpExameOcup(mapearTipoExame(exame.getTipoExame()));
        evento.setDtExame(exame.getDataExame());
        evento.setRespMonit(mapearResultado(exame.getResultado()));
        
        // Médico
        evento.setNmMedico(exame.getMedicoNome());
        evento.setNrCRM(exame.getMedicoCRM());
        evento.setUfCRM(exame.getMedicoUF());
        
        // Exames complementares
        for (ExameComplementar ec : exame.getExamesComplementares()) {
            ExameASO exameASO = new ExameASO();
            exameASO.setDtExame(ec.getDataRealizacao());
            exameASO.setProcRealizado(ec.getCodigoTabela());
            exameASO.setObsExame(ec.getResultado());
            evento.getExames().add(exameASO);
        }
        
        return evento;
    }
}
```

---
