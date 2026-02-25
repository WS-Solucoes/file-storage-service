-- ============================================================
-- V012 — MÓDULO DE AFASTAMENTOS
-- Criação das tabelas tipo_afastamento e afastamento
-- ============================================================

-- Tipo de Afastamento (configuração/catálogo)
CREATE TABLE tipo_afastamento (
    id                                  BIGSERIAL       PRIMARY KEY,
    codigo                              VARCHAR(30)     NOT NULL,
    descricao                           VARCHAR(200)    NOT NULL,
    categoria                           VARCHAR(20)     NOT NULL DEFAULT 'LICENCA',
    dias_limite                         INTEGER,
    remunerado                          BOOLEAN         DEFAULT TRUE,
    conta_tempo_servico                 BOOLEAN         DEFAULT TRUE,
    conta_periodo_aquisitivo_ferias     BOOLEAN         DEFAULT TRUE,
    suspende_contrato                   BOOLEAN         DEFAULT FALSE,
    codigo_esocial                      VARCHAR(10),
    codigo_rais                         INTEGER,
    ativo                               BOOLEAN         DEFAULT TRUE,
    -- Campos tenant / auditoria
    unidade_gestora_id                  BIGINT,
    usuario_log                         VARCHAR(100),
    excluido                            BOOLEAN         DEFAULT FALSE,
    created_at                          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at                          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_tipo_afastamento_codigo UNIQUE (codigo, unidade_gestora_id)
);

-- Afastamento (registro operacional)
CREATE TABLE afastamento (
    id                                  BIGSERIAL       PRIMARY KEY,
    vinculo_funcional_id                BIGINT          NOT NULL REFERENCES vinculo_funcional(id),
    tipo_afastamento_id                 BIGINT          NOT NULL REFERENCES tipo_afastamento(id),
    data_inicio                         DATE            NOT NULL,
    data_fim                            DATE,
    data_retorno                        DATE,
    dias_afastamento                    INTEGER,
    situacao                            VARCHAR(20)     NOT NULL DEFAULT 'ATIVO',
    -- Documentação
    numero_documento                    VARCHAR(100),
    orgao_emissor                       VARCHAR(200),
    cid                                 VARCHAR(10),
    crm_medico                          VARCHAR(30),
    nome_medico                         VARCHAR(200),
    -- Impacto financeiro
    remunerado                          BOOLEAN         DEFAULT TRUE,
    percentual_remuneracao              NUMERIC(5,2)    DEFAULT 100.00,
    responsavel_pagamento               VARCHAR(10)     DEFAULT 'ORGAO',
    dias_orgao                          INTEGER,
    dias_previdencia                    INTEGER,
    -- eSocial
    enviado_esocial                     BOOLEAN         DEFAULT FALSE,
    recibo_esocial                      VARCHAR(100),
    -- Prorrogação
    afastamento_original_id             BIGINT          REFERENCES afastamento(id),
    -- Controle
    observacao                          TEXT,
    -- Campos tenant / auditoria
    unidade_gestora_id                  BIGINT,
    usuario_log                         VARCHAR(100),
    excluido                            BOOLEAN         DEFAULT FALSE,
    created_at                          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at                          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_tipo_afastamento_codigo      ON tipo_afastamento(codigo);
CREATE INDEX idx_tipo_afastamento_categoria   ON tipo_afastamento(categoria);
CREATE INDEX idx_afastamento_vinculo          ON afastamento(vinculo_funcional_id);
CREATE INDEX idx_afastamento_tipo             ON afastamento(tipo_afastamento_id);
CREATE INDEX idx_afastamento_situacao         ON afastamento(situacao);
CREATE INDEX idx_afastamento_datas            ON afastamento(data_inicio, data_fim);
CREATE INDEX idx_afastamento_original         ON afastamento(afastamento_original_id);

-- ============================================================
-- SEED: Tipos de Afastamento padrão
-- ============================================================
INSERT INTO tipo_afastamento (codigo, descricao, categoria, dias_limite, remunerado, conta_tempo_servico, conta_periodo_aquisitivo_ferias, suspende_contrato, codigo_esocial, codigo_rais) VALUES
    ('LIC_SAUDE',        'Licença para Tratamento de Saúde',     'LICENCA',   730, TRUE,  TRUE,  TRUE,  FALSE, '01', 11),
    ('LIC_MATERNIDADE',  'Licença Maternidade',                  'LICENCA',   180, TRUE,  TRUE,  TRUE,  FALSE, '17', 12),
    ('LIC_PATERNIDADE',  'Licença Paternidade',                  'LICENCA',    20, TRUE,  TRUE,  TRUE,  FALSE, '19', 12),
    ('LIC_ACIDENTE',     'Licença por Acidente em Serviço',      'LICENCA',  NULL, TRUE,  TRUE,  TRUE,  FALSE, '01', 11),
    ('LIC_PREMIO',       'Licença Prêmio por Assiduidade',       'LICENCA',    90, TRUE,  FALSE, FALSE, FALSE, '21', 12),
    ('LIC_INTERESSE',    'Licença para Interesse Particular',     'LICENCA',   730, FALSE, FALSE, FALSE, TRUE,  '15', 40),
    ('LIC_CAPACITACAO',  'Licença para Capacitação',             'LICENCA',    90, TRUE,  TRUE,  TRUE,  FALSE, '21', 12),
    ('LIC_LUTO',         'Licença por Falecimento (Nojo)',        'LICENCA',     8, TRUE,  TRUE,  TRUE,  FALSE, '19', 12),
    ('LIC_CASAMENTO',    'Licença Casamento (Gala)',             'LICENCA',     8, TRUE,  TRUE,  TRUE,  FALSE, '19', 12),
    ('SUSP_DISCIPLINAR', 'Suspensão Disciplinar',                'SUSPENSAO',  90, FALSE, FALSE, FALSE, TRUE,  '24', 40),
    ('CESSAO',           'Cessão para Outro Órgão',              'CESSAO',   NULL, TRUE,  TRUE,  TRUE,  FALSE, '14', 40),
    ('SVC_MILITAR',      'Serviço Militar Obrigatório',          'OUTROS',    365, TRUE,  TRUE,  FALSE, FALSE, '05', 50),
    ('MANDATO_ELETIVO',  'Exercício de Mandato Eletivo',         'OUTROS',   NULL, FALSE, TRUE,  FALSE, TRUE,  '16', 40);
