-- Migration: Adiciona coluna ir_faixa_isenta na tabela legislacao
-- Esta coluna armazena o limite de isenção do IRRF (valores até este limite não pagam imposto)
-- Valor para 2026: R$ 2.428,80

-- Adiciona a coluna com valor padrão
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS ir_faixa_isenta DECIMAL(12, 2) NOT NULL DEFAULT 2428.80;

-- Atualiza os registros existentes com o valor correto de 2026
UPDATE legislacao 
SET ir_faixa_isenta = 2428.80 
WHERE ir_faixa_isenta = 0 OR ir_faixa_isenta IS NULL;

-- Atualiza também os valores das faixas para a tabela IRRF 2026 correta
-- Faixa 1: R$ 2.428,81 a R$ 2.826,65 - 7,5%
UPDATE legislacao SET 
    ir_base_1_1 = 2428.81,
    ir_base_1_2 = 2826.65,
    ir_aliquota_1 = 7.5,
    ir_deducao_1 = 182.16
WHERE competencia >= '2026-01';

-- Faixa 2: R$ 2.826,66 a R$ 3.751,05 - 15%
UPDATE legislacao SET 
    ir_base_2_1 = 2826.66,
    ir_base_2_2 = 3751.05,
    ir_aliquota_2 = 15,
    ir_deducao_2 = 394.16
WHERE competencia >= '2026-01';

-- Faixa 3: R$ 3.751,06 a R$ 4.664,68 - 22,5%
UPDATE legislacao SET 
    ir_base_3_1 = 3751.06,
    ir_base_3_2 = 4664.68,
    ir_aliquota_3 = 22.5,
    ir_deducao_3 = 675.54
WHERE competencia >= '2026-01';

-- Faixa 4: acima de R$ 4.664,68 - 27,5%
UPDATE legislacao SET 
    ir_base_4_1 = 4664.69,
    ir_aliquota_4 = 27.5,
    ir_deducao_4 = 908.78
WHERE competencia >= '2026-01';

-- Comentário explicativo
COMMENT ON COLUMN legislacao.ir_faixa_isenta IS 'Limite de isenção do IRRF - valores até este limite não pagam imposto (2026: R$ 2.428,80)';
