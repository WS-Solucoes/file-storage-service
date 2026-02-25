-- ============================================================================
-- V005 - Colunas para RPPS Progressivo
-- ============================================================================
-- Data: 2026-01-26
-- Descrição: Adiciona colunas para cálculo progressivo do RPPS (EC 103/2019)
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
