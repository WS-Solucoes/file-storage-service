-- ============================================================================
-- V002 - Quinquênio Configurável, RPPS Progressivo e Regras de Aposentadoria
-- ============================================================================
-- Data: 2026-01-16
-- Descrição: Adiciona campos para:
--   1. Quinquênio configurável (percentual, frequência, máximo)
--   2. RPPS com alíquotas progressivas (EC 103/2019)
--   3. Regras de aposentadoria (pontos, idade mínima, coeficientes)
-- ============================================================================

-- ============================================================================
-- QUINQUÊNIO (ADICIONAL POR TEMPO DE SERVIÇO)
-- ============================================================================

-- Percentual de acréscimo por quinquênio (ex: 5.00 = 5%)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS quinquenio_percentual DECIMAL(5,2) NOT NULL DEFAULT 5.00;
COMMENT ON COLUMN legislacao.quinquenio_percentual IS 'Percentual de acréscimo por quinquênio (ex: 5.00 = 5%). Configurável conforme estatuto do ente.';

-- Frequência em anos para cada quinquênio (ex: 5 = a cada 5 anos)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS quinquenio_frequencia_anos INTEGER NOT NULL DEFAULT 5;
COMMENT ON COLUMN legislacao.quinquenio_frequencia_anos IS 'Frequência em anos para cada quinquênio. 5=quinquênio, 3=triênio, 1=anuênio';

-- Número máximo de quinquênios permitidos
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS quinquenio_maximo INTEGER NOT NULL DEFAULT 7;
COMMENT ON COLUMN legislacao.quinquenio_maximo IS 'Número máximo de quinquênios permitidos (ex: 7 x 5% = 35% máximo)';

-- Percentual máximo acumulado de quinquênio
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS quinquenio_percentual_maximo DECIMAL(5,2);
COMMENT ON COLUMN legislacao.quinquenio_percentual_maximo IS 'Percentual máximo acumulado (ex: 35.00). Se null, usa quinquenio_maximo * quinquenio_percentual';

-- ============================================================================
-- RPPS PROGRESSIVO (EC 103/2019)
-- ============================================================================

-- Flag para ativar modo progressivo
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_progressivo BOOLEAN NOT NULL DEFAULT FALSE;
COMMENT ON COLUMN legislacao.rpps_progressivo IS 'Se TRUE, usa alíquotas progressivas por faixa como INSS. Se FALSE, usa alíquota única (rpps_aliquota_1)';

-- FAIXA 1 (até 1 SM) - geralmente 7,5%
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_1 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_1 IS 'RPPS Progressivo - Teto da faixa 1 (geralmente 1 SM)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_1 DECIMAL(5,2);
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_1 IS 'RPPS Progressivo - Alíquota faixa 1 (geralmente 7,5%)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_1 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_deducao_1 IS 'RPPS Progressivo - Dedução faixa 1';

-- FAIXA 2 - geralmente 9%
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_2_1 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_2_1 IS 'RPPS Progressivo - Início da faixa 2';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_2_2 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_2_2 IS 'RPPS Progressivo - Teto da faixa 2';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_2 DECIMAL(5,2);
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_2 IS 'RPPS Progressivo - Alíquota faixa 2 (geralmente 9%)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_2 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_deducao_2 IS 'RPPS Progressivo - Dedução faixa 2';

-- FAIXA 3 - geralmente 12%
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_3_1 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_3_1 IS 'RPPS Progressivo - Início da faixa 3';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_3_2 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_3_2 IS 'RPPS Progressivo - Teto da faixa 3';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_3 DECIMAL(5,2);
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_3 IS 'RPPS Progressivo - Alíquota faixa 3 (geralmente 12%)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_3 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_deducao_3 IS 'RPPS Progressivo - Dedução faixa 3';

-- FAIXA 4 - geralmente 14%
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_4_1 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_4_1 IS 'RPPS Progressivo - Início da faixa 4';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_4_2 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_4_2 IS 'RPPS Progressivo - Teto da faixa 4';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_4 DECIMAL(5,2);
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_4 IS 'RPPS Progressivo - Alíquota faixa 4 (geralmente 14%)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_4 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_deducao_4 IS 'RPPS Progressivo - Dedução faixa 4';

-- FAIXA 5 (acima do teto) - pode ter alíquota diferenciada
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_5_1 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_base_5_1 IS 'RPPS Progressivo - Início da faixa 5 (acima do teto)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_5 DECIMAL(5,2);
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_5 IS 'RPPS Progressivo - Alíquota faixa 5 (pode ser 14% a 22%)';

ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_5 DECIMAL(12,2);
COMMENT ON COLUMN legislacao.rpps_deducao_5 IS 'RPPS Progressivo - Dedução faixa 5';

-- ============================================================================
-- REGRAS DE APOSENTADORIA RPPS (EC 103/2019)
-- ============================================================================

-- Coeficiente base da aposentadoria (60% = 0.60)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_coeficiente_base DECIMAL(5,4) NOT NULL DEFAULT 0.6000;
COMMENT ON COLUMN legislacao.aposentadoria_coeficiente_base IS 'Coeficiente base da aposentadoria (EC 103/2019: 60% = 0.6000)';

-- Percentual adicional por ano excedente (2% = 0.02)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_percentual_ano_excedente DECIMAL(5,4) NOT NULL DEFAULT 0.0200;
COMMENT ON COLUMN legislacao.aposentadoria_percentual_ano_excedente IS 'Percentual adicional por ano excedente (EC 103/2019: 2% = 0.0200)';

-- Anos mínimos de contribuição para HOMEM (base para cálculo do excedente)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_anos_minimos_homem INTEGER NOT NULL DEFAULT 20;
COMMENT ON COLUMN legislacao.aposentadoria_anos_minimos_homem IS 'Anos mínimos de contribuição para homens (EC 103/2019: 20 anos)';

-- Anos mínimos de contribuição para MULHER
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_anos_minimos_mulher INTEGER NOT NULL DEFAULT 15;
COMMENT ON COLUMN legislacao.aposentadoria_anos_minimos_mulher IS 'Anos mínimos de contribuição para mulheres (EC 103/2019: 15 anos)';

-- Pontos necessários para aposentadoria - MULHER
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_pontos_mulher INTEGER NOT NULL DEFAULT 93;
COMMENT ON COLUMN legislacao.aposentadoria_pontos_mulher IS 'Pontos necessários para aposentadoria mulher (2026: 93 pontos)';

-- Pontos necessários para aposentadoria - HOMEM
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_pontos_homem INTEGER NOT NULL DEFAULT 103;
COMMENT ON COLUMN legislacao.aposentadoria_pontos_homem IS 'Pontos necessários para aposentadoria homem (2026: 103 pontos)';

-- Idade mínima para aposentadoria - MULHER (em meses para precisão)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_idade_minima_mulher_meses INTEGER NOT NULL DEFAULT 714;
COMMENT ON COLUMN legislacao.aposentadoria_idade_minima_mulher_meses IS 'Idade mínima mulher em meses (2026: 59 anos e 6 meses = 714 meses)';

-- Idade mínima para aposentadoria - HOMEM (em meses para precisão)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_idade_minima_homem_meses INTEGER NOT NULL DEFAULT 774;
COMMENT ON COLUMN legislacao.aposentadoria_idade_minima_homem_meses IS 'Idade mínima homem em meses (2026: 64 anos e 6 meses = 774 meses)';

-- Tempo mínimo de contribuição para aposentadoria - MULHER (anos)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_tempo_contribuicao_mulher INTEGER NOT NULL DEFAULT 30;
COMMENT ON COLUMN legislacao.aposentadoria_tempo_contribuicao_mulher IS 'Tempo mínimo de contribuição mulher (2026: 30 anos)';

-- Tempo mínimo de contribuição para aposentadoria - HOMEM (anos)
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_tempo_contribuicao_homem INTEGER NOT NULL DEFAULT 35;
COMMENT ON COLUMN legislacao.aposentadoria_tempo_contribuicao_homem IS 'Tempo mínimo de contribuição homem (2026: 35 anos)';

-- Anos mínimos no serviço público para aposentadoria
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_anos_servico_publico INTEGER NOT NULL DEFAULT 20;
COMMENT ON COLUMN legislacao.aposentadoria_anos_servico_publico IS 'Anos mínimos no serviço público para aposentadoria';

-- Anos mínimos no cargo atual para aposentadoria
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS aposentadoria_anos_no_cargo INTEGER NOT NULL DEFAULT 5;
COMMENT ON COLUMN legislacao.aposentadoria_anos_no_cargo IS 'Anos mínimos no cargo atual para aposentadoria';

-- ============================================================================
-- DADOS DE EXEMPLO PARA RPPS PROGRESSIVO 2026
-- ============================================================================

-- Script para atualizar uma legislação existente com valores de 2026
-- (descomente e ajuste o ID conforme necessário)

/*
UPDATE legislacao 
SET 
    -- Quinquênio configurável
    quinquenio_percentual = 5.00,
    quinquenio_frequencia_anos = 5,
    quinquenio_maximo = 7,
    quinquenio_percentual_maximo = 35.00,
    
    -- Ativar RPPS progressivo
    rpps_progressivo = TRUE,
    
    -- Faixas RPPS Progressivo 2026 (valores estimados)
    rpps_base_1 = 1518.00,           -- 1 SM
    rpps_aliquota_progressiva_1 = 7.50,
    rpps_deducao_1 = 0.00,
    
    rpps_base_2_1 = 1518.01,
    rpps_base_2_2 = 2793.88,
    rpps_aliquota_progressiva_2 = 9.00,
    rpps_deducao_2 = 22.77,          -- 1518.00 * 1.5% = 22.77
    
    rpps_base_3_1 = 2793.89,
    rpps_base_3_2 = 4190.83,
    rpps_aliquota_progressiva_3 = 12.00,
    rpps_deducao_3 = 106.59,         -- Dedução acumulada
    
    rpps_base_4_1 = 4190.84,
    rpps_base_4_2 = 8157.40,         -- Teto RGPS 2026 estimado
    rpps_aliquota_progressiva_4 = 14.00,
    rpps_deducao_4 = 190.40,         -- Dedução acumulada
    
    rpps_base_5_1 = 8157.41,
    rpps_aliquota_progressiva_5 = 14.00,  -- Pode ser até 22% para alguns entes
    rpps_deducao_5 = 190.40,
    
    -- Regras de aposentadoria 2026
    aposentadoria_coeficiente_base = 0.6000,
    aposentadoria_percentual_ano_excedente = 0.0200,
    aposentadoria_anos_minimos_homem = 20,
    aposentadoria_anos_minimos_mulher = 15,
    aposentadoria_pontos_mulher = 93,
    aposentadoria_pontos_homem = 103,
    aposentadoria_idade_minima_mulher_meses = 714,  -- 59 anos e 6 meses
    aposentadoria_idade_minima_homem_meses = 774,   -- 64 anos e 6 meses
    aposentadoria_tempo_contribuicao_mulher = 30,
    aposentadoria_tempo_contribuicao_homem = 35,
    aposentadoria_anos_servico_publico = 20,
    aposentadoria_anos_no_cargo = 5
WHERE id = ?;
*/

-- ============================================================================
-- ÍNDICES PARA PERFORMANCE
-- ============================================================================

-- Índice para consultas por competência e tipo de RPPS
CREATE INDEX IF NOT EXISTS idx_legislacao_rpps_progressivo ON legislacao(rpps_progressivo, competencia);
