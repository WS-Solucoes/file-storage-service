package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoHistorico is a Querydsl query type for ProcessoHistorico
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoHistorico extends EntityPathBase<ProcessoHistorico> {

    private static final long serialVersionUID = -1739006099L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoHistorico processoHistorico = new QProcessoHistorico("processoHistorico");

    public final EnumPath<ws.erh.core.enums.processo.AcaoProcesso> acao = createEnum("acao", ws.erh.core.enums.processo.AcaoProcesso.class);

    public final StringPath dadosExtras = createString("dadosExtras");

    public final DateTimePath<java.time.LocalDateTime> dataHora = createDateTime("dataHora", java.time.LocalDateTime.class);

    public final StringPath descricao = createString("descricao");

    public final NumberPath<Integer> etapaAnterior = createNumber("etapaAnterior", Integer.class);

    public final NumberPath<Integer> etapaNova = createNumber("etapaNova", Integer.class);

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final QProcesso processo;

    public final StringPath situacaoAnterior = createString("situacaoAnterior");

    public final StringPath situacaoNova = createString("situacaoNova");

    public final EnumPath<ws.erh.core.enums.processo.TipoAutor> tipoUsuario = createEnum("tipoUsuario", ws.erh.core.enums.processo.TipoAutor.class);

    public final NumberPath<Long> unidadeGestoraId = createNumber("unidadeGestoraId", Long.class);

    public final StringPath usuario = createString("usuario");

    public QProcessoHistorico(String variable) {
        this(ProcessoHistorico.class, forVariable(variable), INITS);
    }

    public QProcessoHistorico(Path<? extends ProcessoHistorico> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoHistorico(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoHistorico(PathMetadata metadata, PathInits inits) {
        this(ProcessoHistorico.class, metadata, inits);
    }

    public QProcessoHistorico(Class<? extends ProcessoHistorico> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.processo = inits.isInitialized("processo") ? new QProcesso(forProperty("processo"), inits.get("processo")) : null;
    }

}

