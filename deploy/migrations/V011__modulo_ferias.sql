-- ============================================================
-- V011 — MÓDULO DE FÉRIAS
-- Criação das tabelas: periodo_aquisitivo, concessao_ferias,
-- programacao_ferias, programacao_ferias_item
-- ============================================================

-- Período Aquisitivo
CREATE TABLE periodo_aquisitivo (
    id BIGSERIAL PRIMARY KEY,
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    dias_direito INTEGER DEFAULT 30,
    dias_gozados INTEGER DEFAULT 0,
    dias_abono_pecuniario INTEGER DEFAULT 0,
    dias_perdidos INTEGER DEFAULT 0,
    situacao VARCHAR(20) NOT NULL DEFAULT 'ABERTO',
    data_limite_concessao DATE,
    data_prescricao DATE,
    observacao TEXT,
    -- Campos de auditoria (AbstractExecucaoTenantEntity)
    log_usuario VARCHAR(100) NOT NULL DEFAULT 'sistema',
    log_data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT,
    excluido BOOLEAN NOT NULL DEFAULT FALSE
);

-- Concessão de Férias
CREATE TABLE concessao_ferias (
    id BIGSERIAL PRIMARY KEY,
    periodo_aquisitivo_id BIGINT NOT NULL REFERENCES periodo_aquisitivo(id),
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    dias_gozo INTEGER NOT NULL,
    abono_pecuniario BOOLEAN DEFAULT FALSE,
    dias_abono INTEGER DEFAULT 0,
    adiantamento_13 BOOLEAN DEFAULT FALSE,
    situacao VARCHAR(20) NOT NULL DEFAULT 'PROGRAMADA',
    data_pagamento DATE,
    -- Valores calculados
    valor_ferias NUMERIC(15,2),
    valor_terco_constitucional NUMERIC(15,2),
    valor_abono_pecuniario NUMERIC(15,2),
    valor_terco_abono NUMERIC(15,2),
    valor_adiantamento_13 NUMERIC(15,2),
    total_bruto NUMERIC(15,2),
    total_descontos NUMERIC(15,2),
    total_liquido NUMERIC(15,2),
    -- Referência à folha
    folha_pagamento_det_id BIGINT REFERENCES folhapagamentodet(id),
    competencia_pagamento VARCHAR(7),
    -- Controle
    motivo_cancelamento TEXT,
    data_interrupcao DATE,
    motivo_interrupcao TEXT,
    observacao TEXT,
    -- Campos de auditoria (AbstractExecucaoTenantEntity)
    log_usuario VARCHAR(100) NOT NULL DEFAULT 'sistema',
    log_data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT,
    excluido BOOLEAN NOT NULL DEFAULT FALSE
);

-- Programação Anual de Férias
CREATE TABLE programacao_ferias (
    id BIGSERIAL PRIMARY KEY,
    exercicio INTEGER NOT NULL,
    departamento_rh_id BIGINT REFERENCES departamento_rh(id),
    situacao VARCHAR(20) DEFAULT 'RASCUNHO',
    data_publicacao DATE,
    -- Campos de auditoria
    log_usuario VARCHAR(100) NOT NULL DEFAULT 'sistema',
    log_data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT,
    excluido BOOLEAN NOT NULL DEFAULT FALSE
);

-- Itens da Programação Anual
CREATE TABLE programacao_ferias_item (
    id BIGSERIAL PRIMARY KEY,
    programacao_ferias_id BIGINT NOT NULL REFERENCES programacao_ferias(id) ON DELETE CASCADE,
    vinculo_funcional_id BIGINT NOT NULL REFERENCES vinculo_funcional(id),
    periodo_aquisitivo_id BIGINT NOT NULL REFERENCES periodo_aquisitivo(id),
    data_inicio_prevista DATE,
    data_fim_prevista DATE,
    dias_previstos INTEGER,
    abono_pecuniario_previsto BOOLEAN DEFAULT FALSE,
    observacao TEXT,
    -- Campos de auditoria
    log_usuario VARCHAR(100) NOT NULL DEFAULT 'sistema',
    log_data TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT,
    excluido BOOLEAN NOT NULL DEFAULT FALSE
);

-- ============================================================
-- ÍNDICES
-- ============================================================
CREATE INDEX idx_periodo_aquisitivo_vinculo ON periodo_aquisitivo(vinculo_funcional_id);
CREATE INDEX idx_periodo_aquisitivo_situacao ON periodo_aquisitivo(situacao);
CREATE INDEX idx_periodo_aquisitivo_datas ON periodo_aquisitivo(data_inicio, data_fim);

CREATE INDEX idx_concessao_ferias_vinculo ON concessao_ferias(vinculo_funcional_id);
CREATE INDEX idx_concessao_ferias_periodo ON concessao_ferias(periodo_aquisitivo_id);
CREATE INDEX idx_concessao_ferias_situacao ON concessao_ferias(situacao);
CREATE INDEX idx_concessao_ferias_datas ON concessao_ferias(data_inicio, data_fim);
CREATE INDEX idx_concessao_ferias_competencia ON concessao_ferias(competencia_pagamento);

CREATE INDEX idx_programacao_ferias_exercicio ON programacao_ferias(exercicio);
CREATE INDEX idx_programacao_ferias_depto ON programacao_ferias(departamento_rh_id);
CREATE INDEX idx_programacao_item_programacao ON programacao_ferias_item(programacao_ferias_id);
CREATE INDEX idx_programacao_item_vinculo ON programacao_ferias_item(vinculo_funcional_id);
