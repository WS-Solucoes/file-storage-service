-- Migration: Adicionar campos de controle de exportação de dados bancários na tabela legislacao
-- Data: 2026-01-15
-- Descrição: Permite controlar se os dados bancários foram exportados para uma competência,
--            bloqueando o reprocessamento da folha após a exportação.

-- Passo 1: Adicionar coluna permitindo NULL (funciona com dados existentes)
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS dados_bancarios_exportados BOOLEAN;

-- Passo 2: Atualizar registros existentes para FALSE
UPDATE legislacao SET dados_bancarios_exportados = FALSE WHERE dados_bancarios_exportados IS NULL;

-- Passo 3: Aplicar NOT NULL e DEFAULT
ALTER TABLE legislacao 
ALTER COLUMN dados_bancarios_exportados SET NOT NULL,
ALTER COLUMN dados_bancarios_exportados SET DEFAULT FALSE;

-- Adicionar coluna para data/hora da exportação bancária
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS data_exportacao_bancaria TIMESTAMP NULL;

-- Adicionar coluna para ID do usuário que exportou
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS usuario_exportacao_bancaria_id BIGINT NULL;

-- Comentários nas colunas
COMMENT ON COLUMN legislacao.dados_bancarios_exportados IS 'Indica se os dados bancários foram exportados para esta competência. Quando true, bloqueia o reprocessamento da folha.';
COMMENT ON COLUMN legislacao.data_exportacao_bancaria IS 'Data e hora em que os dados bancários foram exportados.';
COMMENT ON COLUMN legislacao.usuario_exportacao_bancaria_id IS 'ID do usuário que realizou a exportação dos dados bancários.';

-- Criar índice para otimizar consultas por status de exportação
CREATE INDEX IF NOT EXISTS idx_legislacao_dados_bancarios_exportados 
ON legislacao(unidade_gestora_id, competencia, dados_bancarios_exportados);
