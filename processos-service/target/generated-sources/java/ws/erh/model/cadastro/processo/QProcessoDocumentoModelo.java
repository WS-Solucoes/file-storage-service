package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoDocumentoModelo is a Querydsl query type for ProcessoDocumentoModelo
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoDocumentoModelo extends EntityPathBase<ProcessoDocumentoModelo> {

    private static final long serialVersionUID = -793149449L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoDocumentoModelo processoDocumentoModelo = new QProcessoDocumentoModelo("processoDocumentoModelo");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final StringPath descricao = createString("descricao");

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    public final QProcessoEtapaModelo etapaModelo;

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath modeloUrl = createString("modeloUrl");

    public final StringPath nome = createString("nome");

    public final BooleanPath obrigatorio = createBoolean("obrigatorio");

    public final NumberPath<Integer> ordem = createNumber("ordem", Integer.class);

    public final QProcessoModelo processoModelo;

    public final NumberPath<Integer> tamanhoMaximoMb = createNumber("tamanhoMaximoMb", Integer.class);

    public final StringPath tiposPermitidos = createString("tiposPermitidos");

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoDocumentoModelo(String variable) {
        this(ProcessoDocumentoModelo.class, forVariable(variable), INITS);
    }

    public QProcessoDocumentoModelo(Path<? extends ProcessoDocumentoModelo> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoDocumentoModelo(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoDocumentoModelo(PathMetadata metadata, PathInits inits) {
        this(ProcessoDocumentoModelo.class, metadata, inits);
    }

    public QProcessoDocumentoModelo(Class<? extends ProcessoDocumentoModelo> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.etapaModelo = inits.isInitialized("etapaModelo") ? new QProcessoEtapaModelo(forProperty("etapaModelo"), inits.get("etapaModelo")) : null;
        this.processoModelo = inits.isInitialized("processoModelo") ? new QProcessoModelo(forProperty("processoModelo")) : null;
    }

}

