package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoEtapaModelo is a Querydsl query type for ProcessoEtapaModelo
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoEtapaModelo extends EntityPathBase<ProcessoEtapaModelo> {

    private static final long serialVersionUID = 1985894278L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoEtapaModelo processoEtapaModelo = new QProcessoEtapaModelo("processoEtapaModelo");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final StringPath acaoAutomatica = createString("acaoAutomatica");

    public final StringPath descricao = createString("descricao");

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath nome = createString("nome");

    public final NumberPath<Integer> ordem = createNumber("ordem", Integer.class);

    public final NumberPath<Integer> prazoDias = createNumber("prazoDias", Integer.class);

    public final QProcessoModelo processoModelo;

    public final EnumPath<ws.erh.core.enums.processo.TipoResponsavel> tipoResponsavel = createEnum("tipoResponsavel", ws.erh.core.enums.processo.TipoResponsavel.class);

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoEtapaModelo(String variable) {
        this(ProcessoEtapaModelo.class, forVariable(variable), INITS);
    }

    public QProcessoEtapaModelo(Path<? extends ProcessoEtapaModelo> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoEtapaModelo(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoEtapaModelo(PathMetadata metadata, PathInits inits) {
        this(ProcessoEtapaModelo.class, metadata, inits);
    }

    public QProcessoEtapaModelo(Class<? extends ProcessoEtapaModelo> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.processoModelo = inits.isInitialized("processoModelo") ? new QProcessoModelo(forProperty("processoModelo")) : null;
    }

}

