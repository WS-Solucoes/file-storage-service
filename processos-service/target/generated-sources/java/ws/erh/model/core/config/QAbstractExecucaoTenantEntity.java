package ws.erh.model.core.config;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QAbstractExecucaoTenantEntity is a Querydsl query type for AbstractExecucaoTenantEntity
 */
@Generated("com.querydsl.codegen.DefaultSupertypeSerializer")
public class QAbstractExecucaoTenantEntity extends EntityPathBase<AbstractExecucaoTenantEntity> {

    private static final long serialVersionUID = -1647291581L;

    public static final QAbstractExecucaoTenantEntity abstractExecucaoTenantEntity = new QAbstractExecucaoTenantEntity("abstractExecucaoTenantEntity");

    public final QAbstractTenantEntity _super = new QAbstractTenantEntity(this);

    public final DateTimePath<java.time.LocalDateTime> dtLog = createDateTime("dtLog", java.time.LocalDateTime.class);

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> unidadeGestoraId = createNumber("unidadeGestoraId", Long.class);

    public final NumberPath<Long> usuarioId = createNumber("usuarioId", Long.class);

    public final StringPath usuarioLog = createString("usuarioLog");

    public QAbstractExecucaoTenantEntity(String variable) {
        super(AbstractExecucaoTenantEntity.class, forVariable(variable));
    }

    public QAbstractExecucaoTenantEntity(Path<? extends AbstractExecucaoTenantEntity> path) {
        super(path.getType(), path.getMetadata());
    }

    public QAbstractExecucaoTenantEntity(PathMetadata metadata) {
        super(AbstractExecucaoTenantEntity.class, metadata);
    }

}

