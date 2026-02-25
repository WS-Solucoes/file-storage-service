-- ============================================================================
-- V007: Cria tabela guia_rpps para guias de recolhimento previdenciário
-- 
-- Esta tabela armazena as guias de contribuição previdenciária geradas
-- pelo sistema para pagamento ao Instituto de Previdência (RPPS).
-- ============================================================================

CREATE TABLE IF NOT EXISTS guia_rpps (
    id BIGSERIAL PRIMARY KEY,
    
    -- ===== IDENTIFICAÇÃO =====
    numero_guia BIGINT NOT NULL,
    competencia VARCHAR(7) NOT NULL,  -- formato: yyyy-MM
    tipo_guia VARCHAR(30) NOT NULL,   -- MENSAL, COMPLEMENTAR, PARCELAMENTO, DECIMO_TERCEIRO, etc.
    status VARCHAR(20) NOT NULL DEFAULT 'PENDENTE',  -- PENDENTE, PAGA, VENCIDA, CANCELADA, ESTORNADA
    
    -- ===== INSTITUTO VINCULADO =====
    instituto_previdencia_id BIGINT NOT NULL,
    
    -- ===== VALORES =====
    base_calculo DECIMAL(14,2) NOT NULL,
    contribuicao_servidor DECIMAL(14,2) NOT NULL,
    contribuicao_patronal DECIMAL(14,2) NOT NULL,
    valor_principal DECIMAL(14,2) NOT NULL,
    valor_multa DECIMAL(14,2) DEFAULT 0.00,
    valor_juros DECIMAL(14,2) DEFAULT 0.00,
    valor_total DECIMAL(14,2) NOT NULL,
    
    -- ===== DATAS =====
    data_emissao DATE NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    
    -- ===== DADOS BANCÁRIOS (boleto) =====
    nosso_numero VARCHAR(30),
    linha_digitavel VARCHAR(60),
    codigo_barras VARCHAR(50),
    
    -- ===== ESTATÍSTICAS =====
    qtd_servidores INTEGER,
    aliquota_media_servidor DECIMAL(5,2),
    aliquota_patronal DECIMAL(5,2),
    
    -- ===== OUTROS =====
    observacoes TEXT,
    
    -- ===== AUDITORIA =====
    excluido BOOLEAN DEFAULT FALSE,
    dt_log TIMESTAMP,
    usuario_log VARCHAR(100),
    unidade_gestora_id BIGINT,
    
    -- ===== CONSTRAINTS =====
    CONSTRAINT fk_guia_instituto 
        FOREIGN KEY (instituto_previdencia_id) 
        REFERENCES instituto_previdencia(id),
    CONSTRAINT fk_guia_unidade_gestora 
        FOREIGN KEY (unidade_gestora_id) 
        REFERENCES unidade_gestora(id),
    CONSTRAINT uk_guia_numero_competencia_tipo 
        UNIQUE (unidade_gestora_id, competencia, tipo_guia, numero_guia)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_guia_competencia ON guia_rpps(competencia);
CREATE INDEX IF NOT EXISTS idx_guia_status ON guia_rpps(status);
CREATE INDEX IF NOT EXISTS idx_guia_vencimento ON guia_rpps(data_vencimento);
CREATE INDEX IF NOT EXISTS idx_guia_instituto ON guia_rpps(instituto_previdencia_id);
CREATE INDEX IF NOT EXISTS idx_guia_unidade_gestora ON guia_rpps(unidade_gestora_id);

-- Comentários
COMMENT ON TABLE guia_rpps IS 'Guias de recolhimento previdenciário (RPPS) geradas pelo sistema';
COMMENT ON COLUMN guia_rpps.numero_guia IS 'Número sequencial da guia';
COMMENT ON COLUMN guia_rpps.competencia IS 'Competência da contribuição (formato: yyyy-MM)';
COMMENT ON COLUMN guia_rpps.tipo_guia IS 'Tipo: MENSAL, COMPLEMENTAR, PARCELAMENTO, DECIMO_TERCEIRO, FERIAS, RETROATIVO';
COMMENT ON COLUMN guia_rpps.status IS 'Status: PENDENTE, PAGA, VENCIDA, CANCELADA, ESTORNADA';
COMMENT ON COLUMN guia_rpps.base_calculo IS 'Soma das bases de cálculo de todos os servidores';
COMMENT ON COLUMN guia_rpps.contribuicao_servidor IS 'Total de contribuição descontada dos servidores';
COMMENT ON COLUMN guia_rpps.contribuicao_patronal IS 'Total de contribuição patronal';
COMMENT ON COLUMN guia_rpps.valor_principal IS 'Valor principal (servidor + patronal)';
COMMENT ON COLUMN guia_rpps.nosso_numero IS 'Nosso número para identificação bancária';
COMMENT ON COLUMN guia_rpps.linha_digitavel IS 'Linha digitável do boleto';
COMMENT ON COLUMN guia_rpps.codigo_barras IS 'Código de barras do boleto';
