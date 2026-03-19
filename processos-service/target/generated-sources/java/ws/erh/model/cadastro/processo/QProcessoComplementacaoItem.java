package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoComplementacaoItem is a Querydsl query type for ProcessoComplementacaoItem
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoComplementacaoItem extends EntityPathBase<ProcessoComplementacaoItem> {

    private static final long serialVersionUID = -504865716L;

    private static final PathInits INITS = PathInits.DIRECT2;

    public static final QProcessoComplementacaoItem processoComplementacaoItem = new QProcessoComplementacaoItem("processoComplementacaoItem");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final QProcessoCampoModelo campoModelo;

    public final QProcessoComplementacao complementacao;

    public final QProcessoDocumentoModelo documentoModelo;

    public final QProcessoDocumento documentoRespondido;

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath label = createString("label");

    public final StringPath motivo = createString("motivo");

    public final BooleanPath obrigatorio = createBoolean("obrigatorio");

    public final NumberPath<Integer> ordem = createNumber("ordem", Integer.class);

    public final EnumPath<ws.erh.core.enums.processo.TipoItemComplementacaoProcesso> tipoItem = createEnum("tipoItem", ws.erh.core.enums.processo.TipoItemComplementacaoProcesso.class);

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public QProcessoComplementacaoItem(String variable) {
        this(ProcessoComplementacaoItem.class, forVariable(variable), INITS);
    }

    public QProcessoComplementacaoItem(Path<? extends ProcessoComplementacaoItem> path) {
        this(path.getType(), path.getMetadata(), PathInits.getFor(path.getMetadata(), INITS));
    }

    public QProcessoComplementacaoItem(PathMetadata metadata) {
        this(metadata, PathInits.getFor(metadata, INITS));
    }

    public QProcessoComplementacaoItem(PathMetadata metadata, PathInits inits) {
        this(ProcessoComplementacaoItem.class, metadata, inits);
    }

    public QProcessoComplementacaoItem(Class<? extends ProcessoComplementacaoItem> type, PathMetadata metadata, PathInits inits) {
        super(type, metadata, inits);
        this.campoModelo = inits.isInitialized("campoModelo") ? new QProcessoCampoModelo(forProperty("campoModelo"), inits.get("campoModelo")) : null;
        this.complementacao = inits.isInitialized("complementacao") ? new QProcessoComplementacao(forProperty("complementacao"), inits.get("complementacao")) : null;
        this.documentoModelo = inits.isInitialized("documentoModelo") ? new QProcessoDocumentoModelo(forProperty("documentoModelo"), inits.get("documentoModelo")) : null;
        this.documentoRespondido = inits.isInitialized("documentoRespondido") ? new QProcessoDocumento(forProperty("documentoRespondido"), inits.get("documentoRespondido")) : null;
    }

}

