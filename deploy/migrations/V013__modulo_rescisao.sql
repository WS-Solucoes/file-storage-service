-- ============================================================
-- V013__modulo_rescisao.sql
-- Módulo de Rescisão/Desligamento
-- ============================================================

-- Tabela de motivos de desligamento (configuração)
CREATE TABLE IF NOT EXISTS motivo_desligamento (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    descricao VARCHAR(200) NOT NULL,
    codigo_esocial VARCHAR(10),
    codigo_rais INTEGER,
    codigo_tce VARCHAR(10),
    tipo_rescisao VARCHAR(30),
    gera_ferias_proporcionais BOOLEAN DEFAULT TRUE,
    gera_13_proporcional BOOLEAN DEFAULT TRUE,
    gera_ferias_vencidas BOOLEAN DEFAULT TRUE,
    gera_aviso_previo BOOLEAN DEFAULT FALSE,
    gera_multa_fgts BOOLEAN DEFAULT FALSE,
    ativo BOOLEAN DEFAULT TRUE,
    unidade_gestora_id BIGINT,
    log_usuario VARCHAR(100),
    usuario_id BIGINT,
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabela principal de rescisão
CREATE TABLE IF NOT EXISTS rescisao (
    id BIGSERIAL PRIMARY KEY,
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    motivo_desligamento_id BIGINT NOT NULL REFERENCES motivo_desligamento(id),
    data_desligamento DATE NOT NULL,
    data_aviso_previo DATE,
    numero_ato VARCHAR(50),
    data_publicacao_ato DATE,
    situacao VARCHAR(20) NOT NULL DEFAULT 'RASCUNHO',
    -- Verbas rescisórias
    saldo_salario NUMERIC(15,2),
    dias_saldo_salario INTEGER,
    ferias_vencidas NUMERIC(15,2),
    terco_ferias_vencidas NUMERIC(15,2),
    ferias_proporcionais NUMERIC(15,2),
    terco_ferias_proporcionais NUMERIC(15,2),
    meses_ferias_proporcionais INTEGER,
    decimo_terceiro_proporcional NUMERIC(15,2),
    meses_13_proporcional INTEGER,
    decimo_terceiro_integral NUMERIC(15,2),
    aviso_previo_indenizado NUMERIC(15,2),
    outras_vantagens NUMERIC(15,2),
    descricao_outras_vantagens TEXT,
    -- Descontos
    desconto_inss_rpps NUMERIC(15,2),
    desconto_irrf NUMERIC(15,2),
    desconto_adiantamento_13 NUMERIC(15,2),
    desconto_faltas NUMERIC(15,2),
    outros_descontos NUMERIC(15,2),
    descricao_outros_descontos TEXT,
    -- Totais
    total_bruto NUMERIC(15,2),
    total_descontos NUMERIC(15,2),
    total_liquido NUMERIC(15,2),
    -- Referências
    folha_pagamento_id BIGINT,
    competencia_pagamento VARCHAR(7),
    -- eSocial
    enviado_esocial BOOLEAN DEFAULT FALSE,
    recibo_esocial VARCHAR(100),
    -- Documentação
    data_homologacao DATE,
    observacao TEXT,
    -- Tenant / Audit
    unidade_gestora_id BIGINT,
    log_usuario VARCHAR(100),
    log_data TIMESTAMP,
    usuario_id BIGINT,
    excluido BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seed de motivos de desligamento
INSERT INTO motivo_desligamento (codigo, descricao, tipo_rescisao, codigo_esocial, gera_ferias_proporcionais, gera_13_proporcional, gera_ferias_vencidas, gera_aviso_previo, gera_multa_fgts) VALUES
    ('EXON_PEDIDO',     'Exoneração a Pedido',                'EXONERACAO_PEDIDO',      '07', true,  true,  true,  false, false),
    ('EXON_OFICIO',     'Exoneração de Ofício',               'EXONERACAO_OFICIO',      '07', true,  true,  true,  false, false),
    ('DEMISSAO',        'Demissão por Justa Causa',           'DEMISSAO',               '02', false, false, true,  false, false),
    ('APOSENT_VOLUNT',  'Aposentadoria Voluntária',           'APOSENTADORIA',          '34', true,  true,  true,  false, false),
    ('APOSENT_COMPULS', 'Aposentadoria Compulsória',          'APOSENTADORIA',          '35', true,  true,  true,  false, false),
    ('APOSENT_INVALID', 'Aposentadoria por Invalidez',        'APOSENTADORIA',          '36', true,  true,  true,  false, false),
    ('FALECIMENTO',     'Falecimento',                        'FALECIMENTO',            '10', true,  true,  true,  false, false),
    ('TERM_CONTRATO',   'Término de Contrato Temporário',     'TERMINO_CONTRATO',       '04', true,  true,  true,  false, false),
    ('CASSACAO',        'Cassação de Aposentadoria',          'CASSACAO',               '17', false, false, false, false, false),
    ('DESTIT_CC',       'Destituição de Cargo em Comissão',   'DESTITUICAO_CARGO',      '07', true,  true,  true,  false, false),
    ('VACANCIA',        'Vacância por Posse em Outro Cargo',  'VACANCIA_POSSE_OUTRO',   '33', true,  true,  true,  false, false);

-- Índices
CREATE INDEX IF NOT EXISTS idx_rescisao_vinculo   ON rescisao(vinculo_funcional_id);
CREATE INDEX IF NOT EXISTS idx_rescisao_data      ON rescisao(data_desligamento);
CREATE INDEX IF NOT EXISTS idx_rescisao_situacao  ON rescisao(situacao);
CREATE INDEX IF NOT EXISTS idx_motivo_desl_codigo ON motivo_desligamento(codigo);

-- Adicionar campo tipo_folha na tabela de folha (para folha rescisória)
ALTER TABLE folhapagamento ADD COLUMN IF NOT EXISTS tipo_folha VARCHAR(20) DEFAULT 'NORMAL';
