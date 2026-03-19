package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoComplementacao is a Querydsl query type for ProcessoComplementacao
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoComplementacao extends EntityPathBase<ProcessoComplementacao> {

    private static final long serialVersionUID = 1999757721L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoComplementacao processoComplementacao = new QProcessoComplementacao("processoComplementacao");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final DateTimePath<java.time.LocalDateTime> dataEncerramento = createDateTime("dataEncerramento", java.time.LocalDateTime.class);

    public final DateTimePath<java.time.LocalDateTime> dataResposta = createDateTime("dataResposta", java.time.LocalDateTime.class);

    public final DateTimePath<java.time.LocalDateTime> dataSolicitacao = createDateTime("dataSolicitacao", java.time.LocalDateTime.class);

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    public final StringPath etapaNomeSnapshot = createString("etapaNomeSnapshot");

    public final NumberPath<Integer> etapaReferencia = createNumber("etapaReferencia", Integer.class);

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final ListPath<ProcessoComplementacaoItem, QProcessoComplementacaoItem> itens = this.<ProcessoComplementacaoItem, QProcessoComplementacaoItem>createList("itens", ProcessoComplementacaoItem.class, QProcessoComplementacaoItem.class, PathInits.DIRECT2);

    public final StringPath motivoConsolidado = createString("motivoConsolidado");

    public final DatePath<java.time.LocalDate> prazoLimite = createDate("prazoLimite", java.time.LocalDate.class);

    public final QProcesso processo;

    public final StringPath respondidoPor = createString("respondidoPor");

    public final EnumPath<ws.erh.core.enums.processo.SituacaoProcesso> situacaoRetorno = createEnum("situacaoRetorno", ws.erh.core.enums.processo.SituacaoProcesso.class);

    public final StringPath solicitadoPor = createString("solicitadoPor");

    public final EnumPath<ws.erh.core.enums.processo.StatusComplementacaoProcesso> status = createEnum("status", ws.erh.core.enums.processo.StatusComplementacaoProcesso.class);

    public final EnumPath<ws.erh.core.enums.processo.TipoAutor> tipoSolicitante = createEnum("tipoSolicitante", ws.erh.core.enums.processo.TipoAutor.class);

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoComplementacao(String variable) {
        this(ProcessoComplementacao.class, forVariable(variable), INITS);
    }

    public QProcessoComplementacao(Path<? extends ProcessoComplementacao> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoComplementacao(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoComplementacao(PathMetadata metadata, PathInits inits) {
        this(ProcessoComplementacao.class, metadata, inits);
    }

    public QProcessoComplementacao(Class<? extends ProcessoComplementacao> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.processo = inits.isInitialized("processo") ? new QProcesso(forProperty("processo"), inits.get("processo")) : null;
    }

}

