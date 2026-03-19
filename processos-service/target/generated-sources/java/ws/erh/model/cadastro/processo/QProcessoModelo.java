package ws.erh.model.cadastro.processo;

import static com.querydsl.core.types.PathMetadataFactory.*;

import com.querydsl.core.types.dsl.*;

import com.querydsl.core.types.PathMetadata;
import javax.annotation.processing.Generated;
import com.querydsl.core.types.Path;
import com.querydsl.core.types.dsl.PathInits;


/**
 * QProcessoModelo is a Querydsl query type for ProcessoModelo
 */
@Generated("com.querydsl.codegen.DefaultEntitySerializer")
public class QProcessoModelo extends EntityPathBase<ProcessoModelo> {

    private static final long serialVersionUID = -97065975L;

    public static final QProcessoModelo processoModelo = new QProcessoModelo("processoModelo");

    public final ws.erh.model.core.config.QAbstractExecucaoTenantEntity _super = new ws.erh.model.core.config.QAbstractExecucaoTenantEntity(this);

    public final BooleanPath ativo = createBoolean("ativo");

    public final ListPath<ProcessoCampoModelo, QProcessoCampoModelo> camposAdicionais = this.<ProcessoCampoModelo, QProcessoCampoModelo>createList("camposAdicionais", ProcessoCampoModelo.class, QProcessoCampoModelo.class, PathInits.DIRECT2);

    public final EnumPath<ws.erh.core.enums.processo.CategoriaProcesso> categoria = createEnum("categoria", ws.erh.core.enums.processo.CategoriaProcesso.class);

    public final StringPath codigo = createString("codigo");

    public final StringPath cor = createString("cor");

    public final StringPath descricao = createString("descricao");

    public final ListPath<ProcessoDocumentoModelo, QProcessoDocumentoModelo> documentosExigidos = this.<ProcessoDocumentoModelo, QProcessoDocumentoModelo>createList("documentosExigidos", ProcessoDocumentoModelo.class, QProcessoDocumentoModelo.class, PathInits.DIRECT2);

    //inherited
    public final DateTimePath<java.time.LocalDateTime> dtLog = _super.dtLog;

    public final ListPath<ProcessoEtapaModelo, QProcessoEtapaModelo> etapas = this.<ProcessoEtapaModelo, QProcessoEtapaModelo>createList("etapas", ProcessoEtapaModelo.class, QProcessoEtapaModelo.class, PathInits.DIRECT2);

    //inherited
    public final BooleanPath excluido = _super.excluido;

    public final BooleanPath geraAcaoAutomatica = createBoolean("geraAcaoAutomatica");

    public final StringPath icone = createString("icone");

    public final NumberPath<Long> id = createNumber("id", Long.class);

    public final StringPath instrucoes = createString("instrucoes");

    public final StringPath nome = createString("nome");

    public final NumberPath<Integer> ordemExibicao = createNumber("ordemExibicao", Integer.class);

    public final NumberPath<Integer> prazoAtendimentoDias = createNumber("prazoAtendimentoDias", Integer.class);

    public final BooleanPath requerAprovacaoChefia = createBoolean("requerAprovacaoChefia");

    //inherited
    public final NumberPath<Long> unidadeGestoraId = _super.unidadeGestoraId;

    //inherited
    public final NumberPath<Long> usuarioId = _super.usuarioId;

    //inherited
    public final StringPath usuarioLog = _super.usuarioLog;

    public final BooleanPath visivelPortal = createBoolean("visivelPortal");

    public QProcessoModelo(String variable) {
        super(ProcessoModelo.class, forVariable(variable));
    }

    public QProcessoModelo(Path<? extends ProcessoModelo> path) {
        super(path.getType(), path.getMetadata());
    }

    public QProcessoModelo(PathMetadata metadata) {
        super(ProcessoModelo.class, metadata);
    }

}

