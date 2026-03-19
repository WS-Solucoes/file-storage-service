package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcesso is a Querydsl query type for Processo
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcesso extends EntityPathBase<Processo> {

    private static final long serialVersionUID = 1171499971L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcesso processo = new QProcesso("processo");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final StringPath atribuidoPara = createString("atribuidoPara");

    public final StringPath dadosFormulario = createString("dadosFormulario");

    public final DateTimePath<java.time.LocalDateTime> dataAbertura = createDateTime("dataAbertura", java.time.LocalDateTime.class);

    public final DateTimePath<java.time.LocalDateTime> dataConclusao = createDateTime("dataConclusao", java.time.LocalDateTime.class);

    public final DateTimePath<java.time.LocalDateTime> dataUltimaAtualizacao = createDateTime("dataUltimaAtualizacao", java.time.LocalDateTime.class);

    public final StringPath departamentoAtribuido = createString("departamentoAtribuido");

    public final ListPath<ProcessoDocumento, QProcessoDocumento> documentos = this.<ProcessoDocumento, QProcessoDocumento>createList("documentos", ProcessoDocumento.class, QProcessoDocumento.class, PathInits.DIRECT2);

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    public final NumberPath<Integer> etapaAtual = createNumber("etapaAtual", Integer.class);

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final ListPath<ProcessoHistorico, QProcessoHistorico> historico = this.<ProcessoHistorico, QProcessoHistorico>createList("historico", ProcessoHistorico.class, QProcessoHistorico.class, PathInits.DIRECT2);

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath integracaoErro = createString("integracaoErro");

    public final EnumPath<ws.erh.core.enums.processo.IntegracaoStatusProcesso> integracaoStatus = createEnum("integracaoStatus", ws.erh.core.enums.processo.IntegracaoStatusProcesso.class);

    public final StringPath justificativaResultado = createString("justificativaResultado");

    public final ListPath<ProcessoMensagem, QProcessoMensagem> mensagens = this.<ProcessoMensagem, QProcessoMensagem>createList("mensagens", ProcessoMensagem.class, QProcessoMensagem.class, PathInits.DIRECT2);

    public final StringPath municipioNome = createString("municipioNome");

    public final StringPath observacaoServidor = createString("observacaoServidor");

    public final EnumPath<ws.erh.core.enums.processo.OrigemAberturaProcesso> origemAbertura = createEnum("origemAbertura", ws.erh.core.enums.processo.OrigemAberturaProcesso.class);

    public final DatePath<java.time.LocalDate> prazoLimite = createDate("prazoLimite", java.time.LocalDate.class);

    public final EnumPath<ws.erh.core.enums.processo.Prioridade> prioridade = createEnum("prioridade", ws.erh.core.enums.processo.Prioridade.class);

    public final QProcessoModelo processoModelo;

    public final StringPath protocolo = createString("protocolo");

    public final NumberPath<Long> referenciaId = createNumber("referenciaId", Long.class);

    public final StringPath referenciaTipo = createString("referenciaTipo");

    public final EnumPath<ws.erh.core.enums.processo.ResultadoProcesso> resultado = createEnum("resultado", ws.erh.core.enums.processo.ResultadoProcesso.class);

    public final StringPath servidorCpf = createString("servidorCpf");

    public final NumberPath<Long> servidorId = createNumber("servidorId", Long.class);

    public final StringPath servidorNome = createString("servidorNome");

    public final EnumPath<ws.erh.core.enums.processo.SituacaoProcesso> situacao = createEnum("situacao", ws.erh.core.enums.processo.SituacaoProcesso.class);

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    public final StringPath unidadeGestoraNome = createString("unidadeGestoraNome");

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public final NumberPath<Long> vinculoFuncionalId = createNumber("vinculoFuncionalId", Long.class);

    public final StringPath vinculoFuncionalMatricula = createString("vinculoFuncionalMatricula");

    public QProcesso(String variable) {
        this(Processo.class, forVariable(variable), INITS);
    }

    public QProcesso(Path<? extends Processo> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcesso(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcesso(PathMetadata metadata, PathInits inits) {
        this(Processo.class, metadata, inits);
    }

    public QProcesso(Class<? extends Processo> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.processoModelo = inits.isInitialized("processoModelo") ? new QProcessoModelo(forProperty("processoModelo")) : null;
    }

}

