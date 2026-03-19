package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoCampoModelo is a Querydsl query type for ProcessoCampoModelo
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoCampoModelo extends EntityPathBase<ProcessoCampoModelo> {

    private static final long serialVersionUID = 49151569L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoCampoModelo processoCampoModelo = new QProcessoCampoModelo("processoCampoModelo");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final StringPath ajuda = createString("ajuda");

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    public final QProcessoEtapaModelo etapaModelo;

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath label = createString("label");

    public final StringPath nomeCampo = createString("nomeCampo");

    public final BooleanPath obrigatorio = createBoolean("obrigatorio");

    public final StringPath opcoesSelect = createString("opcoesSelect");

    public final NumberPath<Integer> ordem = createNumber("ordem", Integer.class);

    public final StringPath placeholder = createString("placeholder");

    public final QProcessoModelo processoModelo;

    public final EnumPath<ws.erh.core.enums.processo.TipoCampo> tipoCampo = createEnum("tipoCampo", ws.erh.core.enums.processo.TipoCampo.class);

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoCampoModelo(String variable) {
        this(ProcessoCampoModelo.class, forVariable(variable), INITS);
    }

    public QProcessoCampoModelo(Path<? extends ProcessoCampoModelo> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoCampoModelo(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoCampoModelo(PathMetadata metadata, PathInits inits) {
        this(ProcessoCampoModelo.class, metadata, inits);
    }

    public QProcessoCampoModelo(Class<? extends ProcessoCampoModelo> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.etapaModelo = inits.isInitialized("etapaModelo") ? new QProcessoEtapaModelo(forProperty("etapaModelo"), inits.get("etapaModelo")) : null;
        this.processoModelo = inits.isInitialized("processoModelo") ? new QProcessoModelo(forProperty("processoModelo")) : null;
    }

}

