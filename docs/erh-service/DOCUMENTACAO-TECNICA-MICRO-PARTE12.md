# DOCUMENTAÇÃO TÉCNICA MICRO - PARTE 12
## Módulo de Frequência e Controle de Ponto

**Versão:** 1.0  
**Data:** 08/01/2026  
**Status:** A Implementar

---

## 1. VISÃO GERAL DO MÓDULO

### 1.1 Objetivo
Gerenciar o controle de frequência dos servidores municipais, incluindo registro de ponto, tratamento de ocorrências, integração com relógios de ponto e cálculo de horas extras/faltas.

### 1.2 Funcionalidades Principais

| Funcionalidade | Descrição |
|----------------|-----------|
| **Registro de Ponto** | Marcações de entrada/saída |
| **Tratamento de Ocorrências** | Justificativas, abonos |
| **Banco de Horas** | Controle de saldo |
| **Escalas de Trabalho** | Definição de horários |
| **Integração REP** | Relógios eletrônicos |
| **Relatórios** | Espelho de ponto, frequência |
| **Cálculo Automático** | Horas extras, faltas |

---

## 2. MODELO DE DADOS

### 2.1 Entidade: EscalaTrabalho

```java
@Entity
@Table(name = "escala_trabalho")
public class EscalaTrabalho extends AbstractTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "codigo", length = 20)
    private String codigo;
    
    @Column(name = "nome", length = 100)
    private String nome;
    
    @Column(name = "descricao", length = 500)
    private String descricao;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_escala", length = 20)
    private TipoEscala tipoEscala; // FIXA, FLEXIVEL, PLANTAO
    
    @Column(name = "carga_horaria_semanal")
    private Integer cargaHorariaSemanal; // Em minutos
    
    @Column(name = "tolerancia_entrada")
    private Integer toleranciaEntrada; // Em minutos
    
    @Column(name = "tolerancia_saida")
    private Integer toleranciaSaida; // Em minutos
    
    @Column(name = "intervalo_minimo")
    private Integer intervaloMinimo; // Intervalo obrigatório
    
    @OneToMany(mappedBy = "escala", cascade = CascadeType.ALL)
    private List<HorarioTrabalho> horarios = new ArrayList<>();
}
```

### 2.2 Entidade: HorarioTrabalho

```java
@Entity
@Table(name = "horario_trabalho")
public class HorarioTrabalho extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "escala_id", nullable = false)
    private EscalaTrabalho escala;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "dia_semana", length = 15)
    private DayOfWeek diaSemana;
    
    @Column(name = "entrada1")
    private LocalTime entrada1;
    
    @Column(name = "saida1")
    private LocalTime saida1;
    
    @Column(name = "entrada2")
    private LocalTime entrada2;
    
    @Column(name = "saida2")
    private LocalTime saida2;
    
    @Column(name = "jornada_minutos")
    private Integer jornadaMinutos;
    
    @Column(name = "dia_trabalho")
    private Boolean diaTrabalho = true;
}
```

### 2.3 Entidade: RegistroPonto

```java
@Entity
@Table(name = "registro_ponto")
public class RegistroPonto extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Column(name = "data_registro")
    private LocalDate dataRegistro;
    
    @Column(name = "hora_registro")
    private LocalTime horaRegistro;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_registro", length = 20)
    private TipoRegistroPonto tipoRegistro; // ENTRADA, SAIDA, INTERVALO_INICIO, INTERVALO_FIM
    
    @Enumerated(EnumType.STRING)
    @Column(name = "origem", length = 20)
    private OrigemRegistro origem; // REP, MANUAL, SISTEMA, APP
    
    @Column(name = "nsr", length = 20)
    private String nsr; // Número Sequencial do REP
    
    @Column(name = "codigo_rep", length = 20)
    private String codigoREP;
    
    @Column(name = "latitude")
    private Double latitude;
    
    @Column(name = "longitude")
    private Double longitude;
    
    @Column(name = "ip_origem", length = 50)
    private String ipOrigem;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoRegistro situacao; // NORMAL, AJUSTADO, ABONADO, DESCONSIDERADO
    
    @Column(name = "justificativa", length = 500)
    private String justificativa;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "ajustado_por")
    private Usuario ajustadoPor;
}
```

### 2.4 Entidade: ApuracaoPonto

```java
@Entity
@Table(name = "apuracao_ponto")
public class ApuracaoPonto extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Column(name = "data_apuracao")
    private LocalDate dataApuracao;
    
    // Marcações do dia
    @Column(name = "entrada1")
    private LocalTime entrada1;
    
    @Column(name = "saida1")
    private LocalTime saida1;
    
    @Column(name = "entrada2")
    private LocalTime entrada2;
    
    @Column(name = "saida2")
    private LocalTime saida2;
    
    // Valores calculados (em minutos)
    @Column(name = "jornada_prevista")
    private Integer jornadaPrevista;
    
    @Column(name = "jornada_realizada")
    private Integer jornadaRealizada;
    
    @Column(name = "horas_extras")
    private Integer horasExtras;
    
    @Column(name = "horas_falta")
    private Integer horasFalta;
    
    @Column(name = "atraso")
    private Integer atraso;
    
    @Column(name = "saida_antecipada")
    private Integer saidaAntecipada;
    
    @Column(name = "intervalo_realizado")
    private Integer intervaloRealizado;
    
    // Ocorrências
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_ocorrencia", length = 30)
    private TipoOcorrenciaPonto tipoOcorrencia;
    
    @Column(name = "abonado")
    private Boolean abonado = false;
    
    @Column(name = "justificativa_abono", length = 500)
    private String justificativaAbono;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "situacao", length = 20)
    private SituacaoApuracao situacao; // PENDENTE, APURADO, FECHADO
}
```

### 2.5 Entidade: BancoHoras

```java
@Entity
@Table(name = "banco_horas")
public class BancoHoras extends AbstractExecucaoTenantEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "vinculo_id", nullable = false)
    private VinculoFuncional vinculo;
    
    @Column(name = "competencia", length = 7)
    private String competencia; // YYYY-MM
    
    @Column(name = "saldo_anterior")
    private Integer saldoAnterior; // Em minutos
    
    @Column(name = "creditos")
    private Integer creditos; // Horas extras do mês
    
    @Column(name = "debitos")
    private Integer debitos; // Compensações do mês
    
    @Column(name = "saldo_atual")
    private Integer saldoAtual;
    
    @Column(name = "horas_expiradas")
    private Integer horasExpiradas; // Que venceram no mês
    
    @OneToMany(mappedBy = "bancoHoras", cascade = CascadeType.ALL)
    private List<MovimentoBancoHoras> movimentos = new ArrayList<>();
}
```

### 2.6 Entidade: MovimentoBancoHoras

```java
@Entity
@Table(name = "movimento_banco_horas")
public class MovimentoBancoHoras extends AbstractEntity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "banco_horas_id", nullable = false)
    private BancoHoras bancoHoras;
    
    @Column(name = "data_movimento")
    private LocalDate dataMovimento;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "tipo", length = 20)
    private TipoMovimentoBH tipo; // CREDITO, DEBITO, EXPIRACAO
    
    @Column(name = "minutos")
    private Integer minutos;
    
    @Column(name = "descricao", length = 200)
    private String descricao;
    
    @Column(name = "data_origem")
    private LocalDate dataOrigem; // Data da hora extra/compensação
}
```

### 2.7 Enums

```java
public enum TipoRegistroPonto {
    ENTRADA,
    SAIDA,
    INTERVALO_INICIO,
    INTERVALO_FIM
}

public enum TipoOcorrenciaPonto {
    NORMAL,           // Dia normal trabalhado
    FALTA,            // Não compareceu
    FALTA_JUSTIFICADA,// Falta com justificativa
    AFASTAMENTO,      // Em licença/afastamento
    FERIAS,           // Em férias
    FERIADO,          // Feriado
    FOLGA,            // Dia de folga na escala
    COMPENSACAO,      // Compensando banco de horas
    ATRASO,           // Chegou atrasado
    SAIDA_ANTECIPADA, // Saiu antes
    HORA_EXTRA        // Trabalhou além
}

public enum SituacaoApuracao {
    PENDENTE,    // Aguardando apuração
    APURADO,     // Apurado, pode ser ajustado
    FECHADO      // Fechado para folha
}

public enum OrigemRegistro {
    REP,        // Relógio Eletrônico de Ponto
    MANUAL,     // Inserção manual
    SISTEMA,    // Gerado pelo sistema (abono)
    APP         // Aplicativo mobile
}
```

---

## 3. REGRAS DE NEGÓCIO

### 3.1 Registro de Ponto

```
REGRA RP-001: Marcações Obrigatórias
├── Mínimo 4 marcações por dia (escala padrão)
├── Entrada 1 → Saída 1 (manhã)
├── Entrada 2 → Saída 2 (tarde)
└── Tolerância de 10 minutos

REGRA RP-002: Intervalo Mínimo
├── Mínimo 1 hora de intervalo
├── Se < 1 hora → Desconta diferença
└── Configurável por legislação municipal

REGRA RP-003: Validação de Sequência
├── Não pode SAIDA sem ENTRADA anterior
├── Não pode 2 ENTRADAS consecutivas
└── Marcação ímpar no fim do dia = pendência
```

### 3.2 Cálculo de Horas

```
REGRA CH-001: Jornada Normal
├── Somar tempo entre marcações
├── Descontar intervalo
├── Comparar com jornada prevista
└── Diferença = extra ou falta

REGRA CH-002: Horas Extras
├── Excedente da jornada diária
├── Limite: 2 horas/dia (CLT)
├── Servidor pode acumular em banco de horas
└── Ou receber em pecúnia (conforme legislação)

REGRA CH-003: Atrasos e Faltas
├── Atraso > tolerância = desconta proporcionalmente
├── Falta = desconta dia inteiro
├── Falta pode ser abonada com justificativa
└── DSR impactado por faltas na semana

EXEMPLO CÁLCULO DIÁRIO:
├── Jornada prevista: 8h (480 min)
├── Marcações: 08:00 | 12:00 | 13:00 | 18:00
├── Período 1: 12:00 - 08:00 = 4h (240 min)
├── Período 2: 18:00 - 13:00 = 5h (300 min)
├── Total trabalhado: 9h (540 min)
├── Intervalo: 1h (OK)
├── Hora extra: 540 - 480 = 60 min = 1h
```

### 3.3 Banco de Horas

```
REGRA BH-001: Acumulação
├── Horas extras vão para o banco
├── Máximo acumulado: conforme acordo (ex: 120h)
└── Servidor pode optar por pecúnia

REGRA BH-002: Compensação
├── Servidor solicita folga
├── Desconta do saldo
├── Mínimo: 4 horas
└── Máximo: jornada do dia

REGRA BH-003: Validade
├── Horas expiram em 6 meses (ou conforme acordo)
├── Ao expirar: pagar em pecúnia ou perder
└── Sistema alerta sobre horas a vencer
```

---

## 4. FLUXOS DE PROCESSOS

### 4.1 Fluxo: Apuração Diária

```
┌─────────────────────────────────────────────────────────┐
│                   APURAÇÃO DE PONTO                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [00:00 - Processamento Noturno]                       │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ Buscar servidores com escala ativa  │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  ┌─────────────────────────────────────┐               │
│  │ Para cada servidor:                 │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  ┌─────────────────────────────────────┐               │
│  │ 1. Buscar registros do dia anterior │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│                     ▼                                   │
│  ┌─────────────────────────────────────┐               │
│  │ 2. Verificar escala do dia          │               │
│  │    - Era dia de trabalho?           │               │
│  │    - Qual a jornada prevista?       │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│         ┌───────────┴───────────┐                      │
│         │                       │                       │
│         ▼                       ▼                       │
│  ┌───────────┐          ┌───────────┐                  │
│  │ DIA DE    │          │ FOLGA/    │                  │
│  │ TRABALHO  │          │ FERIADO   │                  │
│  └─────┬─────┘          └─────┬─────┘                  │
│        │                      │                        │
│        ▼                      ▼                        │
│  ┌───────────────────┐  ┌───────────────────┐         │
│  │ Tem marcações?    │  │ Tem marcações?    │         │
│  └─────────┬─────────┘  └─────────┬─────────┘         │
│     ┌──────┴──────┐        ┌──────┴──────┐            │
│     │             │        │             │            │
│     ▼             ▼        ▼             ▼            │
│  ┌──────┐    ┌──────┐  ┌──────┐    ┌──────┐          │
│  │ SIM  │    │ NÃO  │  │ SIM  │    │ NÃO  │          │
│  │Calcul│    │FALTA │  │H.EXTR│    │ OK   │          │
│  │horas │    │      │  │100%  │    │      │          │
│  └──────┘    └──────┘  └──────┘    └──────┘          │
│                     │                                  │
│                     ▼                                  │
│  ┌─────────────────────────────────────┐              │
│  │ 3. Criar ApuracaoPonto com:         │              │
│  │    - Marcações consolidadas         │              │
│  │    - Jornada realizada              │              │
│  │    - Horas extras/faltas            │              │
│  │    - Ocorrências detectadas         │              │
│  └─────────────────────────────────────┘              │
│                                                        │
└────────────────────────────────────────────────────────┘
```

### 4.2 Fluxo: Fechamento Mensal

```
┌─────────────────────────────────────────────────────────┐
│                FECHAMENTO DO PONTO                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  [Dia do fechamento - ex: dia 20]                      │
│       │                                                 │
│       ▼                                                 │
│  ┌─────────────────────────────────────┐               │
│  │ 1. Verificar pendências:            │               │
│  │    - Marcações ímpares              │               │
│  │    - Faltas não justificadas        │               │
│  │    - Horas extras não aprovadas     │               │
│  └──────────────────┬──────────────────┘               │
│                     │                                   │
│         ┌───────────┴───────────┐                      │
│         │                       │                       │
│         ▼                       ▼                       │
│  ┌───────────┐          ┌───────────┐                  │
│  │ HÁ        │          │ SEM       │                  │
│  │PENDÊNCIAS │          │PENDÊNCIAS │                  │
│  └─────┬─────┘          └─────┬─────┘                  │
│        │                      │                        │
│        ▼                      ▼                        │
│  ┌─────────────┐       ┌─────────────┐                │
│  │ Notificar   │       │ 2. Calcular │                │
│  │ RH/Gestor   │       │ totais mês  │                │
│  │ para tratar │       └──────┬──────┘                │
│  └─────────────┘              │                        │
│                               ▼                        │
│                 ┌─────────────────────────────────┐    │
│                 │ 3. Atualizar banco de horas     │    │
│                 │    - Somar créditos (extras)    │    │
│                 │    - Somar débitos (compens.)   │    │
│                 │    - Verificar expirações       │    │
│                 └──────────────┬──────────────────┘    │
│                                │                       │
│                                ▼                       │
│                 ┌─────────────────────────────────┐    │
│                 │ 4. Gerar dados para folha:      │    │
│                 │    - Dias trabalhados           │    │
│                 │    - Faltas (com/sem desconto)  │    │
│                 │    - Horas extras a pagar       │    │
│                 │    - DSR perdido                │    │
│                 └──────────────┬──────────────────┘    │
│                                │                       │
│                                ▼                       │
│                 ┌─────────────────────────────────┐    │
│                 │ 5. Status: FECHADO              │    │
│                 │    (não permite mais alterações)│    │
│                 └─────────────────────────────────┘    │
│                                                        │
└────────────────────────────────────────────────────────┘
```

---

## 5. SERVIÇOS E MÉTODOS

### 5.1 PontoService

```java
@Service
@Transactional
public class PontoService extends AbstractTenantService {
    
    /**
     * Registrar marcação de ponto
     */
    public RegistroPonto registrar(RegistroPontoRequest request) {
        VinculoFuncional vinculo = vinculoRepository
            .findById(request.getVinculoId())
            .orElseThrow();
        
        // Validar se pode registrar
        validarRegistro(vinculo, request);
        
        // Determinar tipo de registro
        TipoRegistroPonto tipo = determinarTipoRegistro(vinculo, request.getHora());
        
        RegistroPonto registro = new RegistroPonto();
        registro.setVinculo(vinculo);
        registro.setDataRegistro(request.getData());
        registro.setHoraRegistro(request.getHora());
        registro.setTipoRegistro(tipo);
        registro.setOrigem(request.getOrigem());
        registro.setSituacao(SituacaoRegistro.NORMAL);
        
        // Se veio de REP
        if (request.getOrigem() == OrigemRegistro.REP) {
            registro.setNsr(request.getNsr());
            registro.setCodigoREP(request.getCodigoREP());
        }
        
        // Se veio de APP (mobile)
        if (request.getOrigem() == OrigemRegistro.APP) {
            registro.setLatitude(request.getLatitude());
            registro.setLongitude(request.getLongitude());
            registro.setIpOrigem(request.getIpOrigem());
        }
        
        return registroPontoRepository.save(registro);
    }
    
    /**
     * Apurar ponto de um dia
     */
    public ApuracaoPonto apurarDia(Long vinculoId, LocalDate data) {
        VinculoFuncional vinculo = vinculoRepository.findById(vinculoId).orElseThrow();
        
        // Buscar escala do servidor
        EscalaTrabalho escala = vinculo.getEscalaTrabalho();
        HorarioTrabalho horario = escala.getHorario(data.getDayOfWeek());
        
        // Verificar afastamentos/férias
        Optional<Afastamento> afastamento = afastamentoService
            .buscarAtivo(vinculoId, data);
        if (afastamento.isPresent()) {
            return criarApuracaoAfastamento(vinculo, data, afastamento.get());
        }
        
        // Verificar feriado
        if (feriadoService.isFeriado(data, vinculo.getUnidadeGestora().getId())) {
            return criarApuracaoFeriado(vinculo, data);
        }
        
        // Buscar marcações do dia
        List<RegistroPonto> marcacoes = registroPontoRepository
            .findByVinculoAndData(vinculoId, data);
        
        // Se dia de trabalho sem marcações = falta
        if (horario.isDiaTrabalho() && marcacoes.isEmpty()) {
            return criarApuracaoFalta(vinculo, data, horario);
        }
        
        // Calcular jornada realizada
        return calcularApuracao(vinculo, data, marcacoes, horario);
    }
    
    /**
     * Calcular apuração com marcações
     */
    private ApuracaoPonto calcularApuracao(VinculoFuncional vinculo,
                                           LocalDate data,
                                           List<RegistroPonto> marcacoes,
                                           HorarioTrabalho horario) {
        ApuracaoPonto apuracao = new ApuracaoPonto();
        apuracao.setVinculo(vinculo);
        apuracao.setDataApuracao(data);
        apuracao.setJornadaPrevista(horario.getJornadaMinutos());
        
        // Ordenar marcações
        marcacoes.sort(Comparator.comparing(RegistroPonto::getHoraRegistro));
        
        // Extrair marcações (assumindo 4)
        if (marcacoes.size() >= 1) apuracao.setEntrada1(marcacoes.get(0).getHoraRegistro());
        if (marcacoes.size() >= 2) apuracao.setSaida1(marcacoes.get(1).getHoraRegistro());
        if (marcacoes.size() >= 3) apuracao.setEntrada2(marcacoes.get(2).getHoraRegistro());
        if (marcacoes.size() >= 4) apuracao.setSaida2(marcacoes.get(3).getHoraRegistro());
        
        // Calcular tempo trabalhado
        int minutosTrabalhados = 0;
        
        if (apuracao.getEntrada1() != null && apuracao.getSaida1() != null) {
            minutosTrabalhados += Duration.between(
                apuracao.getEntrada1(), apuracao.getSaida1()).toMinutes();
        }
        if (apuracao.getEntrada2() != null && apuracao.getSaida2() != null) {
            minutosTrabalhados += Duration.between(
                apuracao.getEntrada2(), apuracao.getSaida2()).toMinutes();
        }
        
        apuracao.setJornadaRealizada((int) minutosTrabalhados);
        
        // Calcular intervalo
        if (apuracao.getSaida1() != null && apuracao.getEntrada2() != null) {
            int intervalo = (int) Duration.between(
                apuracao.getSaida1(), apuracao.getEntrada2()).toMinutes();
            apuracao.setIntervaloRealizado(intervalo);
        }
        
        // Calcular horas extras ou falta
        int diferenca = minutosTrabalhados - horario.getJornadaMinutos();
        if (diferenca > 0) {
            apuracao.setHorasExtras(diferenca);
            apuracao.setTipoOcorrencia(TipoOcorrenciaPonto.HORA_EXTRA);
        } else if (diferenca < 0) {
            apuracao.setHorasFalta(Math.abs(diferenca));
            apuracao.setTipoOcorrencia(TipoOcorrenciaPonto.NORMAL);
        } else {
            apuracao.setTipoOcorrencia(TipoOcorrenciaPonto.NORMAL);
        }
        
        // Verificar atraso
        if (apuracao.getEntrada1() != null && horario.getEntrada1() != null) {
            int atraso = (int) Duration.between(
                horario.getEntrada1(), apuracao.getEntrada1()).toMinutes();
            if (atraso > escala.getToleranciaEntrada()) {
                apuracao.setAtraso(atraso);
            }
        }
        
        apuracao.setSituacao(SituacaoApuracao.APURADO);
        
        return apuracaoPontoRepository.save(apuracao);
    }
}
```

### 5.2 BancoHorasService

```java
@Service
public class BancoHorasService {
    
    /**
     * Processar banco de horas do mês
     */
    public BancoHoras processarMes(Long vinculoId, YearMonth competencia) {
        // Buscar ou criar banco
        BancoHoras banco = bancoHorasRepository
            .findByVinculoAndCompetencia(vinculoId, competencia.toString())
            .orElseGet(() -> criarBancoHoras(vinculoId, competencia));
        
        // Buscar saldo anterior
        YearMonth mesAnterior = competencia.minusMonths(1);
        BancoHoras bancoAnterior = bancoHorasRepository
            .findByVinculoAndCompetencia(vinculoId, mesAnterior.toString())
            .orElse(null);
        
        banco.setSaldoAnterior(bancoAnterior != null ? 
            bancoAnterior.getSaldoAtual() : 0);
        
        // Buscar apurações do mês
        List<ApuracaoPonto> apuracoes = apuracaoPontoRepository
            .findByVinculoAndMes(vinculoId, competencia);
        
        // Somar créditos (horas extras)
        int creditos = apuracoes.stream()
            .filter(a -> a.getHorasExtras() != null && a.getHorasExtras() > 0)
            .mapToInt(ApuracaoPonto::getHorasExtras)
            .sum();
        banco.setCreditos(creditos);
        
        // Somar débitos (compensações)
        int debitos = apuracoes.stream()
            .filter(a -> a.getTipoOcorrencia() == TipoOcorrenciaPonto.COMPENSACAO)
            .mapToInt(a -> a.getJornadaPrevista())
            .sum();
        banco.setDebitos(debitos);
        
        // Verificar expirações (horas > 6 meses)
        int expiradas = calcularHorasExpiradas(vinculoId, competencia);
        banco.setHorasExpiradas(expiradas);
        
        // Calcular saldo atual
        banco.setSaldoAtual(
            banco.getSaldoAnterior() + creditos - debitos - expiradas);
        
        return bancoHorasRepository.save(banco);
    }
    
    /**
     * Solicitar compensação
     */
    public MovimentoBancoHoras solicitarCompensacao(Long vinculoId, 
                                                     LocalDate data,
                                                     int minutos) {
        // Verificar saldo disponível
        BancoHoras banco = buscarBancoAtual(vinculoId);
        if (banco.getSaldoAtual() < minutos) {
            throw new BusinessException("Saldo insuficiente no banco de horas");
        }
        
        // Criar movimento de débito
        MovimentoBancoHoras movimento = new MovimentoBancoHoras();
        movimento.setBancoHoras(banco);
        movimento.setDataMovimento(LocalDate.now());
        movimento.setTipo(TipoMovimentoBH.DEBITO);
        movimento.setMinutos(minutos);
        movimento.setDescricao("Compensação para " + data);
        movimento.setDataOrigem(data);
        
        return movimentoRepository.save(movimento);
    }
}
```

---

## 6. INTEGRAÇÃO COM REP

### 6.1 Serviço de Integração

```java
/**
 * Serviço para integração com Relógios Eletrônicos de Ponto
 */
@Service
public class REPIntegrationService {
    
    /**
     * Importar marcações do REP
     */
    @Scheduled(cron = "0 */15 * * * *") // A cada 15 minutos
    public void importarMarcacoes() {
        List<REP> reps = repRepository.findAllAtivos();
        
        for (REP rep : reps) {
            try {
                // Conectar ao REP
                REPClient client = repClientFactory.create(rep);
                
                // Buscar marcações desde última importação
                LocalDateTime ultimaImportacao = rep.getUltimaImportacao();
                List<MarcacaoREP> marcacoes = client.buscarMarcacoes(ultimaImportacao);
                
                // Processar cada marcação
                for (MarcacaoREP marc : marcacoes) {
                    processarMarcacaoREP(marc, rep);
                }
                
                // Atualizar timestamp
                rep.setUltimaImportacao(LocalDateTime.now());
                repRepository.save(rep);
                
            } catch (Exception e) {
                log.error("Erro ao importar do REP {}: {}", rep.getCodigo(), e.getMessage());
                notificarErroREP(rep, e);
            }
        }
    }
    
    private void processarMarcacaoREP(MarcacaoREP marc, REP rep) {
        // Buscar servidor pelo PIS
        Servidor servidor = servidorRepository.findByPis(marc.getPis())
            .orElseThrow(() -> new NotFoundException("Servidor não encontrado: " + marc.getPis()));
        
        VinculoFuncional vinculo = vinculoRepository.findAtivoByServidor(servidor.getId())
            .orElseThrow();
        
        // Verificar se já foi importada (pelo NSR)
        if (registroPontoRepository.existsByNsr(marc.getNsr())) {
            return; // Já importada
        }
        
        // Criar registro
        RegistroPonto registro = new RegistroPonto();
        registro.setVinculo(vinculo);
        registro.setDataRegistro(marc.getDataHora().toLocalDate());
        registro.setHoraRegistro(marc.getDataHora().toLocalTime());
        registro.setOrigem(OrigemRegistro.REP);
        registro.setNsr(marc.getNsr());
        registro.setCodigoREP(rep.getCodigo());
        registro.setSituacao(SituacaoRegistro.NORMAL);
        
        // Determinar tipo
        registro.setTipoRegistro(
            determinarTipoRegistro(vinculo, marc.getDataHora().toLocalTime()));
        
        registroPontoRepository.save(registro);
    }
}
```

---

## 7. ENDPOINTS DA API

| Método | Endpoint | Descrição | Permissão |
|--------|----------|-----------|-----------|
| **Registro** |||
| POST | `/api/ponto/registrar` | Registrar marcação | USUARIO+ |
| GET | `/api/ponto/marcacoes/{vinculoId}/{data}` | Marcações do dia | USUARIO+ |
| **Apuração** |||
| GET | `/api/ponto/apuracao/{vinculoId}/{data}` | Apuração do dia | ANALISTA+ |
| POST | `/api/ponto/apurar/{data}` | Apurar dia (lote) | GESTOR+ |
| PUT | `/api/ponto/ajustar/{id}` | Ajustar marcação | GESTOR+ |
| PUT | `/api/ponto/abonar/{id}` | Abonar ocorrência | GESTOR+ |
| **Banco de Horas** |||
| GET | `/api/banco-horas/{vinculoId}` | Saldo atual | USUARIO+ |
| POST | `/api/banco-horas/compensar` | Solicitar compensação | USUARIO+ |
| GET | `/api/banco-horas/extrato/{vinculoId}` | Extrato | USUARIO+ |
| **Relatórios** |||
| GET | `/api/ponto/espelho/{vinculoId}/{mes}` | Espelho de ponto | USUARIO+ |
| GET | `/api/ponto/frequencia/{lotacaoId}/{mes}` | Relatório frequência | GESTOR+ |
| **Escala** |||
| GET | `/api/escalas` | Listar escalas | ANALISTA+ |
| POST | `/api/escalas` | Criar escala | ADMIN |
| PUT | `/api/escalas/{id}` | Alterar escala | ADMIN |

---

## 8. INTEGRAÇÃO COM FOLHA

### 8.1 Exportação para Folha

```java
/**
 * Serviço de integração Ponto → Folha
 */
@Service
public class PontoFolhaIntegrationService {
    
    /**
     * Gerar dados para folha de pagamento
     */
    public DadosPontoFolha gerarDadosParaFolha(Long vinculoId, YearMonth competencia) {
        DadosPontoFolha dados = new DadosPontoFolha();
        dados.setVinculoId(vinculoId);
        dados.setCompetencia(competencia);
        
        // Buscar apurações do mês
        List<ApuracaoPonto> apuracoes = apuracaoPontoRepository
            .findByVinculoAndMes(vinculoId, competencia);
        
        // Contar dias trabalhados
        long diasTrabalhados = apuracoes.stream()
            .filter(a -> a.getTipoOcorrencia() == TipoOcorrenciaPonto.NORMAL ||
                        a.getTipoOcorrencia() == TipoOcorrenciaPonto.HORA_EXTRA)
            .count();
        dados.setDiasTrabalhados((int) diasTrabalhados);
        
        // Contar faltas (não abonadas)
        long faltas = apuracoes.stream()
            .filter(a -> a.getTipoOcorrencia() == TipoOcorrenciaPonto.FALTA)
            .filter(a -> !a.getAbonado())
            .count();
        dados.setFaltas((int) faltas);
        
        // Somar horas extras
        int minutosExtras = apuracoes.stream()
            .filter(a -> a.getHorasExtras() != null)
            .mapToInt(ApuracaoPonto::getHorasExtras)
            .sum();
        dados.setMinutosHoraExtra(minutosExtras);
        
        // Somar atrasos
        int minutosAtraso = apuracoes.stream()
            .filter(a -> a.getAtraso() != null)
            .mapToInt(ApuracaoPonto::getAtraso)
            .sum();
        dados.setMinutosAtraso(minutosAtraso);
        
        // Verificar DSR perdido
        dados.setDsrPerdido(calcularDSRPerdido(apuracoes));
        
        return dados;
    }
    
    /**
     * Calcular DSR perdido por faltas
     */
    private BigDecimal calcularDSRPerdido(List<ApuracaoPonto> apuracoes) {
        // Agrupar por semana
        Map<Integer, List<ApuracaoPonto>> porSemana = apuracoes.stream()
            .collect(Collectors.groupingBy(a -> 
                a.getDataApuracao().get(WeekFields.ISO.weekOfMonth())));
        
        int dsrPerdidos = 0;
        for (List<ApuracaoPonto> semana : porSemana.values()) {
            boolean temFalta = semana.stream()
                .anyMatch(a -> a.getTipoOcorrencia() == TipoOcorrenciaPonto.FALTA &&
                              !a.getAbonado());
            if (temFalta) {
                dsrPerdidos++;
            }
        }
        
        return BigDecimal.valueOf(dsrPerdidos);
    }
}
```

---

## 9. RELATÓRIO ESPELHO DE PONTO

```
┌──────────────────────────────────────────────────────────────┐
│                    ESPELHO DE PONTO                          │
│                    Janeiro/2026                              │
├──────────────────────────────────────────────────────────────┤
│ Servidor: João da Silva                                      │
│ Matrícula: 12345         Cargo: Técnico Administrativo      │
│ Escala: 08:00-12:00 / 13:00-17:00 (40h semanais)            │
├──────────────────────────────────────────────────────────────┤
│ Data  │ E1    │ S1    │ E2    │ S2    │ Trab. │ Extra │ Obs │
├───────┼───────┼───────┼───────┼───────┼───────┼───────┼─────┤
│ 02/01 │ 08:00 │ 12:00 │ 13:00 │ 17:00 │ 08:00 │   -   │     │
│ 03/01 │ 08:15 │ 12:00 │ 13:00 │ 17:00 │ 07:45 │   -   │ ATR │
│ 04/01 │   -   │   -   │   -   │   -   │   -   │   -   │ FER │
│ 05/01 │   -   │   -   │   -   │   -   │   -   │   -   │ DOM │
│ 06/01 │ 08:00 │ 12:00 │ 13:00 │ 18:00 │ 09:00 │ 01:00 │ HE  │
│ ...   │ ...   │ ...   │ ...   │ ...   │ ...   │ ...   │ ... │
├──────────────────────────────────────────────────────────────┤
│ RESUMO DO MÊS:                                               │
│ Dias trabalhados: 22    Horas trabalhadas: 176:00           │
│ Horas extras: 04:30     Faltas: 0                           │
│ Atrasos: 00:15          DSR perdido: 0                      │
│ Banco de horas: +04:30                                       │
├──────────────────────────────────────────────────────────────┤
│ Legenda: ATR=Atraso, FER=Feriado, DOM=Domingo, HE=Hora Extra│
│          FLT=Falta, ABO=Abonado, LIC=Licença, FER=Férias    │
└──────────────────────────────────────────────────────────────┘
```

---

## 10. RESUMO DAS 12 PARTES

| Parte | Módulo | Status |
|-------|--------|--------|
| 1 | Permissões MBAC, Stakeholders | ✅ Documentado |
| 2 | Processamento de Folha, Cálculos | ✅ Documentado |
| 3 | Consignado, Férias, 13º Salário | ✅ Documentado |
| 4 | Relacionamento de Classes | ✅ Documentado |
| 5 | Tarefas dos Stakeholders | ✅ Documentado |
| 6 | Licenças e Afastamentos | ✅ Documentado |
| 7 | Rescisões e Desligamentos | ✅ Documentado |
| 8 | Integração eSocial | ✅ Documentado |
| 9 | PCCS e Carreira | ✅ Documentado |
| 10 | Aposentadoria e Pensões | ✅ Documentado |
| 11 | Portal do Servidor | ✅ Documentado |
| 12 | Frequência e Ponto | ✅ Documentado |

---

**FIM DA DOCUMENTAÇÃO TÉCNICA MICRO**

Esta documentação cobre todos os módulos necessários para um sistema de RH municipal completo e pode servir como base para implementação.
