package ws.erh.model.cadastro.vinculo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QVinculoFuncional is a Querydsl query type for VinculoFuncional
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QVinculoFuncional extends EntityPathBase<VinculoFuncional> {

    private static final long serialVersionUID = -1754657048L;

    public static final QVinculoFuncional vinculoFuncional = new QVinculoFuncional("vinculoFuncional");

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath matricula = createString("matricula");

    public QVinculoFuncional(String variable) {
        super(VinculoFuncional.class, forVariable(variable));
    }

    public QVinculoFuncional(Path<? extends VinculoFuncional> path) {
        super(path.getType(), path.getMetadata());
    }

    public QVinculoFuncional(PathMetadata metadata) {
        super(VinculoFuncional.class, metadata);
    }

}

