package ws.processos.event;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;


/**
 * QProcessoOutboxEvent is a Querydsl query type for ProcessoOutboxEvent
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoOutboxEvent extends EntityPathBase<ProcessoOutboxEvent> {

    private static final long serialVersionUID = 1849357244L;

    public static final QProcessoOutboxEvent processoOutboxEvent = new QProcessoOutboxEvent("processoOutboxEvent");

    public final NumberPath<Long> aggregateId = createNumber("aggregateId", Long.class);

    public final StringPath aggregateType = createString("aggregateType");

    public final NumberPath<Integer> attempts = createNumber("attempts", Integer.class);

    public final DateTimePath<java.time.LocalDateTime> createdAt = createDateTime("createdAt", java.time.LocalDateTime.class);

    public final StringPath eventId = createString("eventId");

    public final StringPath eventType = createString("eventType");

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath lastError = createString("lastError");

    public final StringPath payload = createString("payload");

    public final DateTimePath<java.time.LocalDateTime> publishedAt = createDateTime("publishedAt", java.time.LocalDateTime.class);

    public final StringPath routingKey = createString("routingKey");

    public final EnumPath<ProcessoOutboxStatus> status = createEnum("status", ProcessoOutboxStatus.class);

    public QProcessoOutboxEvent(String variable) {
        super(ProcessoOutboxEvent.class, forVariable(variable));
    }

    public QProcessoOutboxEvent(Path<? extends ProcessoOutboxEvent> path) {
        super(path.getType(), path.getMetadata());
    }

    public QProcessoOutboxEvent(PathMetadata metadata) {
        super(ProcessoOutboxEvent.class, metadata);
    }

}

