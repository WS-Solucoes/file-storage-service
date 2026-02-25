-- ============================================================================
-- V006: Cria tabela instituto_previdencia para dados do RPPS Municipal
-- 
-- Esta tabela armazena os dados cadastrais do Instituto de Previdência
-- necessários para emissão de guias de recolhimento previdenciário.
-- ============================================================================

CREATE TABLE IF NOT EXISTS instituto_previdencia (
    id BIGSERIAL PRIMARY KEY,
    
    -- ===== DADOS CADASTRAIS =====
    nome VARCHAR(200) NOT NULL,
    sigla VARCHAR(20),
    cnpj VARCHAR(14) NOT NULL UNIQUE,
    codigo_mps VARCHAR(20),
    numero_crp VARCHAR(30),
    
    -- ===== ENDEREÇO =====
    logradouro VARCHAR(200),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf VARCHAR(2),
    cep VARCHAR(8),
    
    -- ===== CONTATO =====
    telefone VARCHAR(20),
    email VARCHAR(100),
    site VARCHAR(200),
    
    -- ===== DADOS BANCÁRIOS PARA RECOLHIMENTO =====
    banco_codigo VARCHAR(10),
    banco_nome VARCHAR(100),
    agencia VARCHAR(10),
    agencia_dv VARCHAR(2),
    conta_corrente VARCHAR(20),
    conta_corrente_dv VARCHAR(2),
    tipo_conta VARCHAR(20),
    
    -- ===== CONFIGURAÇÕES DE GUIA =====
    convenio_bancario VARCHAR(50),
    carteira_cobranca VARCHAR(10),
    nosso_numero_sequencial BIGINT,
    percentual_multa DECIMAL(5,2),
    percentual_juros_mes DECIMAL(5,2),
    dias_carencia_multa INTEGER,
    
    -- ===== RESPONSÁVEL LEGAL =====
    responsavel_nome VARCHAR(150),
    responsavel_cpf VARCHAR(11),
    responsavel_cargo VARCHAR(100),
    
    -- ===== OUTROS =====
    observacoes TEXT,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    logo BYTEA,
    
    -- ===== AUDITORIA (campos herdados de AbstractTenantEntityErh) =====
    excluido BOOLEAN DEFAULT FALSE,
    dt_log TIMESTAMP,
    usuario_log VARCHAR(100),
    unidade_gestora_id BIGINT,
    
    -- ===== CONSTRAINTS =====
    CONSTRAINT fk_instituto_unidade_gestora 
        FOREIGN KEY (unidade_gestora_id) 
        REFERENCES unidade_gestora(id)
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_instituto_cnpj ON instituto_previdencia(cnpj);
CREATE INDEX IF NOT EXISTS idx_instituto_sigla ON instituto_previdencia(sigla);
CREATE INDEX IF NOT EXISTS idx_instituto_unidade_gestora ON instituto_previdencia(unidade_gestora_id);
CREATE INDEX IF NOT EXISTS idx_instituto_ativo ON instituto_previdencia(ativo);

-- Comentários nas colunas principais
COMMENT ON TABLE instituto_previdencia IS 'Cadastro do Instituto de Previdência Municipal (RPPS) para emissão de guias';
COMMENT ON COLUMN instituto_previdencia.nome IS 'Nome completo do Instituto de Previdência';
COMMENT ON COLUMN instituto_previdencia.sigla IS 'Sigla do Instituto (ex: IPREM, SPPREV)';
COMMENT ON COLUMN instituto_previdencia.cnpj IS 'CNPJ do Instituto (14 dígitos sem formatação)';
COMMENT ON COLUMN instituto_previdencia.codigo_mps IS 'Código identificador junto ao Ministério da Previdência';
COMMENT ON COLUMN instituto_previdencia.numero_crp IS 'Número de registro no CRP (Cadastro de RPPS)';
COMMENT ON COLUMN instituto_previdencia.convenio_bancario IS 'Código de convênio bancário para geração de boletos';
COMMENT ON COLUMN instituto_previdencia.nosso_numero_sequencial IS 'Sequencial para geração do nosso número em boletos';
COMMENT ON COLUMN instituto_previdencia.percentual_multa IS 'Percentual de multa por atraso no pagamento';
COMMENT ON COLUMN instituto_previdencia.percentual_juros_mes IS 'Percentual de juros ao mês por atraso';
