-- ============================================================================
-- V004 - RPPS Progressivo - Valores de Referência 2026
-- ============================================================================
-- Data: 2026-01-26
-- Descrição: Atualiza valores das faixas progressivas do RPPS para 2026
--            Baseado nas alíquotas da EC 103/2019 e valores do INSS/União
-- ============================================================================

-- ============================================================================
-- NOTA IMPORTANTE:
-- Os valores abaixo são referência da União (INSS/RGPS).
-- Cada ente federativo (Estado/Município) pode ter valores diferentes
-- conforme legislação local. Este script pode ser usado como base.
-- ============================================================================

-- ============================================================================
-- FAIXAS RPPS PROGRESSIVO 2026 (Valores de Referência - União)
-- ============================================================================
-- 
-- 1ª Faixa: até R$ 1.518,00 → 7,5%
-- 2ª Faixa: de R$ 1.518,01 até R$ 2.793,88 → 9%
-- 3ª Faixa: de R$ 2.793,89 até R$ 4.190,83 → 12%
-- 4ª Faixa: de R$ 4.190,84 até R$ 8.157,41 → 14%
-- 5ª Faixa: acima de R$ 8.157,41 → 14% a 22% (conforme ente)
--
-- ============================================================================
-- CÁLCULO DAS DEDUÇÕES (para uso da fórmula simplificada):
-- Dedução = Σ (diferença entre alíquotas × limite da faixa anterior)
-- ============================================================================
-- Faixa 1: Dedução = 0 (primeira faixa)
-- Faixa 2: Dedução = 1.518,00 × (9% - 7,5%) = 1.518,00 × 1,5% = 22,77
-- Faixa 3: Dedução = 22,77 + 2.793,88 × (12% - 9%) = 22,77 + 83,82 = 106,59
-- Faixa 4: Dedução = 106,59 + 4.190,83 × (14% - 12%) = 106,59 + 83,82 = 190,41
-- Faixa 5: Dedução = 190,41 (se mantiver 14%) ou recalcular se alíquota diferente
-- ============================================================================

-- Exemplo de UPDATE para uma legislação existente (descomente e ajuste o WHERE)
/*
UPDATE legislacao 
SET 
    -- Ativar modo progressivo
    rpps_progressivo = TRUE,
    
    -- Faixa 1: até 1 SM (7,5%)
    rpps_base_1 = 1518.00,
    rpps_aliquota_progressiva_1 = 7.50,
    rpps_deducao_1 = 0.00,
    
    -- Faixa 2: de 1.518,01 até 2.793,88 (9%)
    rpps_base_2_1 = 1518.01,
    rpps_base_2_2 = 2793.88,
    rpps_aliquota_progressiva_2 = 9.00,
    rpps_deducao_2 = 22.77,
    
    -- Faixa 3: de 2.793,89 até 4.190,83 (12%)
    rpps_base_3_1 = 2793.89,
    rpps_base_3_2 = 4190.83,
    rpps_aliquota_progressiva_3 = 12.00,
    rpps_deducao_3 = 106.59,
    
    -- Faixa 4: de 4.190,84 até 8.157,41 (14%)
    rpps_base_4_1 = 4190.84,
    rpps_base_4_2 = 8157.41,
    rpps_aliquota_progressiva_4 = 14.00,
    rpps_deducao_4 = 190.41,
    
    -- Faixa 5: acima de 8.157,41 (14% - pode ser até 22% em alguns entes)
    rpps_base_5_1 = 8157.42,
    rpps_aliquota_progressiva_5 = 14.00,
    rpps_deducao_5 = 190.41
WHERE competencia = '2026-01' AND unidade_gestora_id = ?;
*/

-- ============================================================================
-- EXEMPLOS DE CÁLCULO
-- ============================================================================
--
-- EXEMPLO 1: Salário de R$ 3.000,00 (modo progressivo)
-- ----------------------------------------------------------------
-- 1ª faixa: R$ 1.518,00 × 7,5% = R$ 113,85
-- 2ª faixa: (R$ 2.793,88 - R$ 1.518,00) × 9% = R$ 1.275,88 × 9% = R$ 114,83
-- 3ª faixa: (R$ 3.000,00 - R$ 2.793,88) × 12% = R$ 206,12 × 12% = R$ 24,73
-- TOTAL: R$ 113,85 + R$ 114,83 + R$ 24,73 = R$ 253,41
-- Alíquota efetiva: R$ 253,41 / R$ 3.000,00 = 8,45%
--
-- OU usando fórmula simplificada (faixa 3):
-- R$ 3.000,00 × 12% - R$ 106,59 = R$ 360,00 - R$ 106,59 = R$ 253,41 ✓
--
-- ----------------------------------------------------------------
--
-- EXEMPLO 2: Salário de R$ 3.000,00 (modo simples, alíquota 11%)
-- ----------------------------------------------------------------
-- R$ 3.000,00 × 11% = R$ 330,00
--
-- ----------------------------------------------------------------
-- Diferença: R$ 330,00 - R$ 253,41 = R$ 76,59 a mais no modo simples
-- ============================================================================

-- ============================================================================
-- FUNÇÃO PARA CALCULAR DEDUÇÃO (opcional - para referência)
-- ============================================================================
-- Esta função pode ser usada para calcular as deduções automaticamente
-- a partir das faixas e alíquotas configuradas.
-- ============================================================================

/*
-- Exemplo de função PL/pgSQL para calcular dedução de uma faixa
CREATE OR REPLACE FUNCTION calcular_deducao_rpps(
    p_faixa INTEGER,
    p_base_faixa_anterior DECIMAL(12,2),
    p_aliquota_atual DECIMAL(5,2),
    p_aliquota_anterior DECIMAL(5,2),
    p_deducao_anterior DECIMAL(12,2)
) RETURNS DECIMAL(12,2) AS $$
BEGIN
    IF p_faixa = 1 THEN
        RETURN 0.00;
    END IF;
    
    RETURN p_deducao_anterior + (p_base_faixa_anterior * (p_aliquota_atual - p_aliquota_anterior) / 100);
END;
$$ LANGUAGE plpgsql;
*/

-- ============================================================================
-- ÍNDICE PARA PERFORMANCE (já criado em V002, mantido para referência)
-- ============================================================================
-- CREATE INDEX IF NOT EXISTS idx_legislacao_rpps_progressivo ON legislacao(rpps_progressivo, competencia);

