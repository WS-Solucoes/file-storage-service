package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoMensagem is a Querydsl query type for ProcessoMensagem
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoMensagem extends EntityPathBase<ProcessoMensagem> {

    private static final long serialVersionUID = 1222664974L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoMensagem processoMensagem = new QProcessoMensagem("processoMensagem");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final StringPath anexoCaminho = createString("anexoCaminho");

    public final StringPath anexoNome = createString("anexoNome");

    public final StringPath anexoTipo = createString("anexoTipo");

    public final StringPath autor = createString("autor");

    public final DateTimePath<java.time.LocalDateTime> dataHora = createDateTime("dataHora", java.time.LocalDateTime.class);

    public final DateTimePath<java.time.LocalDateTime> dataLeitura = createDateTime("dataLeitura", java.time.LocalDateTime.class);

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final BooleanPath lida = createBoolean("lida");

    public final StringPath mensagem = createString("mensagem");

    public final QProcesso processo;

    public final EnumPath<ws.erh.core.enums.processo.TipoAutor> tipoAutor = createEnum("tipoAutor", ws.erh.core.enums.processo.TipoAutor.class);

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoMensagem(String variable) {
        this(ProcessoMensagem.class, forVariable(variable), INITS);
    }

    public QProcessoMensagem(Path<? extends ProcessoMensagem> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoMensagem(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoMensagem(PathMetadata metadata, PathInits inits) {
        this(ProcessoMensagem.class, metadata, inits);
    }

    public QProcessoMensagem(Class<? extends ProcessoMensagem> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.processo = inits.isInitialized("processo") ? new QProcesso(forProperty("processo"), inits.get("processo")) : null;
    }

}

