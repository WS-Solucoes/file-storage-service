-- =====================================================================
-- V010: Tabela memoria_calculo_13 - Persistência da memória de cálculo do 13º salário
-- 
-- Permite auditoria e verificação posterior de todos os cálculos
-- realizados no processamento do décimo terceiro salário.
-- 
-- Fundamentação: Lei 4.090/62, Lei 4.749/65, Decreto 57.155/65
-- =====================================================================

CREATE TABLE IF NOT EXISTS memoria_calculo_13 (
    id                      BIGSERIAL PRIMARY KEY,
    
    -- Identificação
    folha_pagamento_id      BIGINT NOT NULL REFERENCES folhapagamento(id),
    servidor_nome           VARCHAR(200),
    matricula               VARCHAR(30),
    competencia             VARCHAR(7) NOT NULL,
    
    -- Configuração usada
    tipo_parcela            VARCHAR(20) NOT NULL,    -- PARCELA_1, PROPORCIONAL, INTEGRAL
    modo_pagamento          VARCHAR(16) NOT NULL,    -- CONJUNTA, SEPARADA
    percentual_adiantamento NUMERIC(5,2),            -- ex: 50.00
    
    -- Composição da base
    salario_base            NUMERIC(12,2) NOT NULL,
    representacao           NUMERIC(12,2),
    quinquenio              NUMERIC(12,2),
    rubricas_adicionais     NUMERIC(12,2),
    base_13_salario         NUMERIC(12,2) NOT NULL,
    
    -- Proporcionalidade
    data_admissao           DATE,
    meses_trabalhados       INTEGER NOT NULL,
    
    -- Valores calculados
    valor_bruto_13          NUMERIC(12,2) NOT NULL,
    valor_adiantamento      NUMERIC(12,2),
    
    -- Descontos (preenchidos apenas para parcela final)
    tipo_previdencia        VARCHAR(4),              -- INSS ou RPPS
    aliquota_previdencia    NUMERIC(5,2),
    desconto_previdencia    NUMERIC(12,2),
    aliquota_irrf           NUMERIC(5,2),
    faixa_irrf              VARCHAR(50),
    qtd_dependentes_irrf    INTEGER,
    desconto_irrf           NUMERIC(12,2),
    
    -- Resultado
    valor_liquido_13        NUMERIC(12,2) NOT NULL,
    
    -- Detalhes completos (texto passo-a-passo do cálculo)
    detalhes_calculo        TEXT,
    
    -- Controle
    data_processamento      TIMESTAMP NOT NULL DEFAULT NOW(),
    tipo_folha              VARCHAR(20),             -- NORMAL, 13_1PARCELA, 13_2PARCELA
    
    -- Audit (AbstractExecucaoTenantEntity)
    unidade_gestora_id      BIGINT,
    usuario_id              BIGINT,
    log_usuario             VARCHAR(255) NOT NULL DEFAULT 'SISTEMA',
    log_data                TIMESTAMP NOT NULL DEFAULT NOW(),
    excluido                BOOLEAN NOT NULL DEFAULT FALSE
);

-- Índices para consultas frequentes
CREATE INDEX IF NOT EXISTS idx_memoria13_folha 
    ON memoria_calculo_13(folha_pagamento_id);

CREATE INDEX IF NOT EXISTS idx_memoria13_competencia 
    ON memoria_calculo_13(unidade_gestora_id, competencia);

CREATE INDEX IF NOT EXISTS idx_memoria13_servidor 
    ON memoria_calculo_13(unidade_gestora_id, matricula, competencia);

-- Comentários
COMMENT ON TABLE memoria_calculo_13 IS 'Memória de cálculo do 13º salário - registro detalhado de cada processamento para auditoria';
COMMENT ON COLUMN memoria_calculo_13.tipo_parcela IS 'Tipo de parcela: PARCELA_1 (adiantamento), PROPORCIONAL (13º proporcional), INTEGRAL (13º integral)';
COMMENT ON COLUMN memoria_calculo_13.detalhes_calculo IS 'Texto completo passo-a-passo do cálculo, incluindo fórmulas e valores intermediários';
COMMENT ON COLUMN memoria_calculo_13.meses_trabalhados IS 'Meses trabalhados no ano considerando regra dos 15 dias (Art. 1º, §2º da Lei 4.090/62)';
