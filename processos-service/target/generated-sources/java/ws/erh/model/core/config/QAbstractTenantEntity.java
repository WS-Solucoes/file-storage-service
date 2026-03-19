package ws.erh.model.core.config;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QAbstractTenantEntity is a Querydsl query type for AbstractTenantEntity
 */
@Generated("com.querydsl.codegen.DefaultSupertypeSerializer")
public class QAbstractTenantEntity extends EntityPathBase<AbstractTenantEntity> {

    private static final long serialVersionUID = 1927679062L;

    public static final QAbstractTenantEntity abstractTenantEntity = new QAbstractTenantEntity("abstractTenantEntity");

    public final BooleanPath excluido = createBoolean("excluido");

    public QAbstractTenantEntity(String variable) {
        super(AbstractTenantEntity.class, forVariable(variable));
    }

    public QAbstractTenantEntity(Path<? extends AbstractTenantEntity> path) {
        super(path.getType(), path.getMetadata());
    }

    public QAbstractTenantEntity(PathMetadata metadata) {
        super(AbstractTenantEntity.class, metadata);
    }

}

