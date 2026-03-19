package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoDocumento is a Querydsl query type for ProcessoDocumento
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoDocumento extends EntityPathBase<ProcessoDocumento> {

    private static final long serialVersionUID = 1774015025L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoDocumento processoDocumento = new QProcessoDocumento("processoDocumento");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final StringPath avaliadoPor = createString("avaliadoPor");

    public final StringPath caminhoStorage = createString("caminhoStorage");

    public final DateTimePath<java.time.LocalDateTime> dataAvaliacao = createDateTime("dataAvaliacao", java.time.LocalDateTime.class);

    public final DateTimePath<java.time.LocalDateTime> dataEnvio = createDateTime("dataEnvio", java.time.LocalDateTime.class);

    public final QProcessoDocumentoModelo documentoModelo;

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    public final StringPath enviadoPor = createString("enviadoPor");

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath motivoRecusa = createString("motivoRecusa");

    public final StringPath nomeArquivo = createString("nomeArquivo");

    public final QProcesso processo;

    public final EnumPath<ws.erh.core.enums.processo.SituacaoDocumento> situacao = createEnum("situacao", ws.erh.core.enums.processo.SituacaoDocumento.class);

    public final NumberPath<Long> tamanhoBytes = createNumber("tamanhoBytes", Long.class);

    public final StringPath tipoArquivo = createString("tipoArquivo");

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoDocumento(String variable) {
        this(ProcessoDocumento.class, forVariable(variable), INITS);
    }

    public QProcessoDocumento(Path<? extends ProcessoDocumento> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoDocumento(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoDocumento(PathMetadata metadata, PathInits inits) {
        this(ProcessoDocumento.class, metadata, inits);
    }

    public QProcessoDocumento(Class<? extends ProcessoDocumento> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.documentoModelo = inits.isInitialized("documentoModelo") ? new QProcessoDocumentoModelo(forProperty("documentoModelo"), inits.get("documentoModelo")) : null;
        this.processo = inits.isInitialized("processo") ? new QProcesso(forProperty("processo"), inits.get("processo")) : null;
    }

}

