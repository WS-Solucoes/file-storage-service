package ws.erh.model.cadastro.servidor;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QServidor is a Querydsl query type for Servidor
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QServidor extends EntityPathBase<Servidor> {

    private static final long serialVersionUID = -226718141L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QServidor servidor = new QServidor("servidor");

    public final StringPath cpf = createString("cpf");

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final ws.common.model.QMunicipio municipio;

    public final StringPath nome = createString("nome");

    public QServidor(String variable) {
        this(Servidor.class, forVariable(variable), INITS);
    }

    public QServidor(Path<? extends Servidor> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QServidor(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QServidor(PathMetadata metadata, PathInits inits) {
        this(Servidor.class, metadata, inits);
    }

    public QServidor(Class<? extends Servidor> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.municipio = inits.isInitialized("municipio") ? new ws.common.model.QMunicipio(forProperty("municipio")) : null;
    }

}

