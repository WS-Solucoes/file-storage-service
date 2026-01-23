-- ==============================================================================
-- MIGRAÇÃO: VALORES LEGISLAÇÃO 2026
-- Data: Janeiro 2026
-- Descrição: Atualização das tabelas de INSS, IRRF e Salário Família para 2026
-- ==============================================================================

-- ==============================================================================
-- TABELA INSS 2026 (RGPS) - Portaria Interministerial MPS/MF Nº 13
-- Teto: R$ 8.475,55 | Salário Mínimo: R$ 1.621,00
-- ==============================================================================
-- Faixa 1: até R$ 1.621,00         - 7,5%  (dedução R$ 0,00)
-- Faixa 2: R$ 1.621,01 a R$ 2.902,84 - 9%    (dedução R$ 24,32)
-- Faixa 3: R$ 2.902,85 a R$ 4.354,27 - 12%   (dedução R$ 111,40)
-- Faixa 4: R$ 4.354,28 a R$ 8.475,55 - 14%   (dedução R$ 198,49)
-- ==============================================================================

-- ==============================================================================
-- TABELA IRRF 2026 - Receita Federal
-- NOVA REGRA: Isenção total até R$ 5.000, redução parcial até R$ 7.350
-- ==============================================================================
-- Isento:   até R$ 2.428,80
-- Faixa 1: R$ 2.428,81 a R$ 2.826,65 - 7,5%  (dedução R$ 182,16)
-- Faixa 2: R$ 2.826,66 a R$ 3.751,05 - 15%   (dedução R$ 394,16)
-- Faixa 3: R$ 3.751,06 a R$ 4.664,68 - 22,5% (dedução R$ 675,49)
-- Faixa 4: acima de R$ 4.664,68     - 27,5% (dedução R$ 908,73)
-- 
-- REDUTOR 2026 (aplicado automaticamente pelo sistema):
-- - Renda até R$ 5.000: redutor R$ 312,89 (zera o imposto)
-- - Renda R$ 5.000,01 a R$ 7.350: redutor = R$ 978,62 - (0,133145 × renda)
-- - Renda acima de R$ 7.350: sem redutor
-- ==============================================================================

-- ==============================================================================
-- SALÁRIO FAMÍLIA 2026
-- ==============================================================================
-- Cota: R$ 67,54 para remuneração até R$ 1.980,38
-- ==============================================================================

-- Atualizar legislação existente para competência 2026-01
-- (Ajuste o WHERE conforme necessário para sua UG)
UPDATE legislacao SET
    -- Salário Mínimo 2026
    salario_minimo = 1621.00,
    
    -- INSS Faixa 1 (até R$ 1.621,00 - 7,5%)
    inss_base_1 = 1621.00,
    inss_aliquota_1 = 7.5,
    inss_deducao_1 = 0.00,
    
    -- INSS Faixa 2 (R$ 1.621,01 a R$ 2.902,84 - 9%)
    inss_base_2_1 = 1621.01,
    inss_base_2_2 = 2902.84,
    inss_aliquota_2 = 9.0,
    inss_deducao_2 = 24.32,
    
    -- INSS Faixa 3 (R$ 2.902,85 a R$ 4.354,27 - 12%)
    inss_base_3_1 = 2902.85,
    inss_base_3_2 = 4354.27,
    inss_aliquota_3 = 12.0,
    inss_deducao_3 = 111.40,
    
    -- INSS Faixa 4 (R$ 4.354,28 a R$ 8.475,55 - 14%) - TETO
    inss_base_4_1 = 4354.28,
    inss_base_4_2 = 8475.55,
    inss_aliquota_4 = 14.0,
    inss_deducao_4 = 198.49,
    
    -- INSS Patronal (mantém 20%)
    inss_patronal = 20.0,
    
    -- IRRF Faixa 1 (R$ 2.428,81 a R$ 2.826,65 - 7,5%)
    ir_base_1_1 = 2428.81,
    ir_base_1_2 = 2826.65,
    ir_aliquota_1 = 7.5,
    ir_deducao_1 = 182.16,
    
    -- IRRF Faixa 2 (R$ 2.826,66 a R$ 3.751,05 - 15%)
    ir_base_2_1 = 2826.66,
    ir_base_2_2 = 3751.05,
    ir_aliquota_2 = 15.0,
    ir_deducao_2 = 394.16,
    
    -- IRRF Faixa 3 (R$ 3.751,06 a R$ 4.664,68 - 22,5%)
    ir_base_3_1 = 3751.06,
    ir_base_3_2 = 4664.68,
    ir_aliquota_3 = 22.5,
    ir_deducao_3 = 675.49,
    
    -- IRRF Faixa 4 (acima de R$ 4.664,68 - 27,5%)
    ir_base_4_1 = 4664.69,
    ir_aliquota_4 = 27.5,
    ir_deducao_4 = 908.73,
    
    -- Deduções IRRF
    ir_deducao_dep = 189.59,    -- Dedução por dependente 2026
    ir_deducao_idade = 1903.98, -- Dedução aposentado > 65 anos (parcela isenta)
    
    -- Salário Família
    salfamilia_base_1 = 1980.38,
    salfamilia_aliquota_1 = 67.54,
    salfamilia_base_2_1 = 1980.39,
    salfamilia_base_2_2 = 999999.99,
    salfamilia_aliquota_2 = 0.00

WHERE competencia = '2026-01';

-- Se não existe registro para 2026-01, criar um novo (exemplo para UG = 1)
-- INSERT INTO legislacao (
--     unidade_gestora_id, competencia, fechado, excluido, 
--     salario_minimo,
--     inss_base_1, inss_aliquota_1, inss_deducao_1,
--     inss_base_2_1, inss_base_2_2, inss_aliquota_2, inss_deducao_2,
--     inss_base_3_1, inss_base_3_2, inss_aliquota_3, inss_deducao_3,
--     inss_base_4_1, inss_base_4_2, inss_aliquota_4, inss_deducao_4,
--     inss_patronal,
--     ir_base_1_1, ir_base_1_2, ir_aliquota_1, ir_deducao_1,
--     ir_base_2_1, ir_base_2_2, ir_aliquota_2, ir_deducao_2,
--     ir_base_3_1, ir_base_3_2, ir_aliquota_3, ir_deducao_3,
--     ir_base_4_1, ir_aliquota_4, ir_deducao_4,
--     ir_deducao_dep, ir_deducao_idade,
--     salfamilia_base_1, salfamilia_aliquota_1,
--     salfamilia_base_2_1, salfamilia_base_2_2, salfamilia_aliquota_2,
--     rpps_aliquota_1, rpps_patronal,
--     decimo13_percentual, decimo13_modo_pagamento
-- ) VALUES (
--     1, '2026-01', false, false,
--     1621.00,
--     1621.00, 7.5, 0.00,
--     1621.01, 2902.84, 9.0, 24.32,
--     2902.85, 4354.27, 12.0, 111.40,
--     4354.28, 8475.55, 14.0, 198.49,
--     20.0,
--     2428.81, 2826.65, 7.5, 182.16,
--     2826.66, 3751.05, 15.0, 394.16,
--     3751.06, 4664.68, 22.5, 675.49,
--     4664.69, 27.5, 908.73,
--     189.59, 1903.98,
--     1980.38, 67.54,
--     1980.39, 999999.99, 0.00,
--     14.0, 22.0,
--     50.00, 'CONJUNTA'
-- );

-- ==============================================================================
-- RESUMO DAS ALTERAÇÕES 2026
-- ==============================================================================
-- 
-- INSS (RGPS):
-- - Teto: R$ 8.475,55 (+3,90%)
-- - Faixas atualizadas com novas bases e deduções
-- 
-- IRRF:
-- - Tabela tradicional mantida (mesmos valores de 2025)
-- - NOVA REGRA DE ISENÇÃO/REDUÇÃO:
--   * Isenção TOTAL: até R$ 5.000/mês (redutor R$ 312,89 zera o imposto)
--   * Redução PARCIAL: R$ 5.000,01 a R$ 7.350 (redutor decrescente)
--   * Sem redução: acima de R$ 7.350
-- - Dedução por dependente: R$ 189,59
-- 
-- SALÁRIO FAMÍLIA:
-- - Cota: R$ 67,54
-- - Limite de renda: R$ 1.980,38
-- 
-- SALÁRIO MÍNIMO:
-- - Novo valor: R$ 1.621,00 (+7,5%)
-- 
-- ==============================================================================
