-- Active: 1741976726672@@127.0.0.1@5432@frotas
-- Active: 1737565399754@@127.0.0.1@5435
-- ============================================================================
-- Script de Migração: Sistema de Permissões MBAC (Module-Based Access Control)
-- ============================================================================
-- Este script migra o modelo antigo de permissões (usuario_unidade_gestora)
-- para o novo modelo MBAC (usuario_permissao) que suporta permissões
-- independentes por módulo.
--
-- IMPORTANTE: Execute este script em um ambiente de teste antes da produção!
-- ============================================================================

-- 1. Criar a nova tabela de permissões
CREATE TABLE IF NOT EXISTS usuario_permissao (
    id BIGSERIAL PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    unidade_gestora_id BIGINT NOT NULL,
    modulo VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    CONSTRAINT fk_usuario_permissao_usuario 
        FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    CONSTRAINT fk_usuario_permissao_ug 
        FOREIGN KEY (unidade_gestora_id) REFERENCES unidade_gestora(id) ON DELETE CASCADE,
    CONSTRAINT uk_usuario_ug_modulo 
        UNIQUE (usuario_id, unidade_gestora_id, modulo)
);

-- 2. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_usuario_permissao_usuario 
    ON usuario_permissao(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_permissao_ug 
    ON usuario_permissao(unidade_gestora_id);
CREATE INDEX IF NOT EXISTS idx_usuario_permissao_modulo 
    ON usuario_permissao(modulo);
CREATE INDEX IF NOT EXISTS idx_usuario_permissao_usuario_modulo 
    ON usuario_permissao(usuario_id, modulo);

-- 3. Migrar dados existentes para o módulo FROTAS (modelo legado era do eFrotas)
-- Ajuste o módulo conforme necessário para sua situação
INSERT INTO usuario_permissao (usuario_id, unidade_gestora_id, modulo, role)
SELECT 
    usuario_id, 
    unidade_gestora_id, 
    'FROTAS' AS modulo, 
    role
FROM usuario_unidade_gestora
WHERE NOT EXISTS (
    SELECT 1 FROM usuario_permissao up 
    WHERE up.usuario_id = usuario_unidade_gestora.usuario_id 
      AND up.unidade_gestora_id = usuario_unidade_gestora.unidade_gestora_id 
      AND up.modulo = 'FROTAS'
);

-- 4. Copiar permissões para o módulo ERH (usuários terão acesso a ambos os módulos)
-- Descomente se quiser que todos os usuários existentes tenham acesso ao ERH também

INSERT INTO usuario_permissao (usuario_id, unidade_gestora_id, modulo, role)
SELECT 
    usuario_id, 
    unidade_gestora_id, 
    'ERH' AS modulo, 
    role
FROM usuario_unidade_gestora
WHERE NOT EXISTS (
    SELECT 1 FROM usuario_permissao up 
    WHERE up.usuario_id = usuario_unidade_gestora.usuario_id 
      AND up.unidade_gestora_id = usuario_unidade_gestora.unidade_gestora_id 
      AND up.modulo = 'ERH'
);


-- 5. Adicionar coluna 'modulo' na tabela de sessões (acesso) se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'acesso' AND column_name = 'modulo'
    ) THEN
        ALTER TABLE acesso ADD COLUMN modulo VARCHAR(20) NOT NULL DEFAULT 'LEGACY';
    END IF;
END $$;

-- 6. Criar índice para busca de sessões por módulo
CREATE INDEX IF NOT EXISTS idx_acesso_usuario_modulo 
    ON acesso(usuario_id, modulo);

-- ============================================================================
-- VERIFICAÇÃO PÓS-MIGRAÇÃO
-- ============================================================================

-- Verificar quantidade de registros migrados
SELECT 'Permissões migradas:' AS info, COUNT(*) AS total FROM usuario_permissao;

-- Listar permissões por módulo
SELECT modulo, COUNT(*) AS quantidade 
FROM usuario_permissao 
GROUP BY modulo 
ORDER BY modulo;

-- Verificar usuários sem permissões no novo modelo
SELECT u.id, u.login, u.email
FROM usuario u
LEFT JOIN usuario_permissao up ON u.id = up.usuario_id
WHERE up.id IS NULL AND u.excluido = false;

-- ============================================================================
-- ROLLBACK (se necessário)
-- ============================================================================
-- Para reverter a migração, execute:
-- DROP TABLE IF EXISTS usuario_permissao;
-- ALTER TABLE acesso DROP COLUMN IF EXISTS modulo;
-- ============================================================================
