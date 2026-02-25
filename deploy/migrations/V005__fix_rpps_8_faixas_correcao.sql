-- ============================================================================
-- V005: Correção - Adiciona colunas de RPPS 8 faixas na tabela CORRETA
-- 
-- Esta migração corrige o problema da V004 que usava o nome de tabela errado
-- (tb_legislacao ao invés de legislacao).
-- ============================================================================

-- ===== FAIXA 5 =====
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_5_2 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_faixa_5_ativa BOOLEAN DEFAULT FALSE;

-- ===== FAIXA 6 =====
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_6_1 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_6_2 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_6 DECIMAL(5,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_6 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_faixa_6_ativa BOOLEAN DEFAULT FALSE;

-- ===== FAIXA 7 =====
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_7_1 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_7_2 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_7 DECIMAL(5,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_7 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_faixa_7_ativa BOOLEAN DEFAULT FALSE;

-- ===== FAIXA 8 =====
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_base_8_1 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_aliquota_progressiva_8 DECIMAL(5,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_deducao_8 DECIMAL(12,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS rpps_faixa_8_ativa BOOLEAN DEFAULT FALSE;

-- Comentários nas colunas
COMMENT ON COLUMN legislacao.rpps_base_5_2 IS 'Teto da faixa 5 RPPS (R$ 13.918,85 em 2026)';
COMMENT ON COLUMN legislacao.rpps_faixa_5_ativa IS 'Status da faixa 5 - true = ativa (opcional para municípios)';

COMMENT ON COLUMN legislacao.rpps_base_6_1 IS 'Início da faixa 6 RPPS';
COMMENT ON COLUMN legislacao.rpps_base_6_2 IS 'Teto da faixa 6 RPPS (R$ 27.837,70 em 2026)';
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_6 IS 'Alíquota da faixa 6 (16,5%)';
COMMENT ON COLUMN legislacao.rpps_deducao_6 IS 'Dedução calculada para faixa 6';
COMMENT ON COLUMN legislacao.rpps_faixa_6_ativa IS 'Status da faixa 6 - true = ativa (opcional para municípios)';

COMMENT ON COLUMN legislacao.rpps_base_7_1 IS 'Início da faixa 7 RPPS';
COMMENT ON COLUMN legislacao.rpps_base_7_2 IS 'Teto da faixa 7 RPPS (R$ 54.283,52 em 2026)';
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_7 IS 'Alíquota da faixa 7 (19%)';
COMMENT ON COLUMN legislacao.rpps_deducao_7 IS 'Dedução calculada para faixa 7';
COMMENT ON COLUMN legislacao.rpps_faixa_7_ativa IS 'Status da faixa 7 - true = ativa (opcional para municípios)';

COMMENT ON COLUMN legislacao.rpps_base_8_1 IS 'Início da faixa 8 RPPS (acima do teto faixa 7)';
COMMENT ON COLUMN legislacao.rpps_aliquota_progressiva_8 IS 'Alíquota da faixa 8 (22%) - sem limite superior';
COMMENT ON COLUMN legislacao.rpps_deducao_8 IS 'Dedução calculada para faixa 8';
COMMENT ON COLUMN legislacao.rpps_faixa_8_ativa IS 'Status da faixa 8 - true = ativa (opcional para municípios)';
