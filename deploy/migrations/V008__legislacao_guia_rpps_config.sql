-- V008__legislacao_guia_rpps_config.sql
-- Adiciona campos de configuração de Guia RPPS na tabela legislacao
-- Centraliza configurações de guia de pagamento que antes ficavam em tela separada

-- Adiciona colunas para configuração de Guias RPPS
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_aviso TEXT;
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_dia_vencimento INTEGER;
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_mes_vencimento VARCHAR(20);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_percentual_multa DECIMAL(5,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_percentual_juros_mes DECIMAL(5,2);
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_dias_carencia_multa INTEGER;
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_criterios TEXT;
ALTER TABLE legislacao ADD COLUMN IF NOT EXISTS guia_rpps_observacoes TEXT;

-- Define valor padrão para mês de vencimento (SUBSEQUENTE = mês seguinte à competência)
UPDATE legislacao SET guia_rpps_mes_vencimento = 'SUBSEQUENTE' WHERE guia_rpps_mes_vencimento IS NULL;

-- Comentários nas colunas para documentação
COMMENT ON COLUMN legislacao.guia_rpps_aviso IS 'Aviso/mensagem a ser exibido nas guias de pagamento RPPS';
COMMENT ON COLUMN legislacao.guia_rpps_dia_vencimento IS 'Dia de vencimento das guias RPPS (1-31)';
COMMENT ON COLUMN legislacao.guia_rpps_mes_vencimento IS 'Mês de vencimento: MESMO (mesmo mês da competência) ou SUBSEQUENTE (mês seguinte)';
COMMENT ON COLUMN legislacao.guia_rpps_percentual_multa IS 'Percentual de multa por atraso no pagamento';
COMMENT ON COLUMN legislacao.guia_rpps_percentual_juros_mes IS 'Percentual de juros ao mês por atraso';
COMMENT ON COLUMN legislacao.guia_rpps_dias_carencia_multa IS 'Dias de carência antes de aplicar multa';
COMMENT ON COLUMN legislacao.guia_rpps_criterios IS 'Critérios/instruções para processamento das guias';
COMMENT ON COLUMN legislacao.guia_rpps_observacoes IS 'Observações gerais sobre as guias RPPS';
