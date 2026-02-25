-- Adiciona coluna tipo_folha na tabela folhapagamento
-- para distinguir folhas normais de folhas de 13º salário separadas
-- Valores: 'NORMAL', '13_1PARCELA', '13_2PARCELA'

ALTER TABLE folhapagamento 
ADD COLUMN IF NOT EXISTS tipo_folha VARCHAR(20) NOT NULL DEFAULT 'NORMAL';

-- Índice para consultas por tipo_folha
CREATE INDEX IF NOT EXISTS idx_folhapagamento_tipo_folha 
ON folhapagamento(unidade_gestora_id, competencia, tipo_folha);

-- Comentário na coluna
COMMENT ON COLUMN folhapagamento.tipo_folha IS 'Tipo da folha: NORMAL (folha mensal), 13_1PARCELA (adiantamento 13º), 13_2PARCELA (parcela final 13º)';
