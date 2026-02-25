-- =====================================================================
-- V015 — Portal do Servidor (Fase 5)
-- Credenciais + Notificações
-- =====================================================================

-- Credenciais do portal (autenticação separada dos usuários RH)
CREATE TABLE IF NOT EXISTS portal_credencial (
    id                         BIGSERIAL PRIMARY KEY,
    servidor_id                BIGINT NOT NULL UNIQUE REFERENCES servidor(id),
    cpf                        VARCHAR(11) NOT NULL UNIQUE,
    senha_hash                 VARCHAR(255),
    primeiro_acesso            BOOLEAN DEFAULT TRUE,
    ativo                      BOOLEAN DEFAULT TRUE,
    tentativas_login           INTEGER DEFAULT 0,
    bloqueado_ate              TIMESTAMP,
    ultimo_login               TIMESTAMP,
    token_recuperacao          VARCHAR(255),
    token_recuperacao_expira   TIMESTAMP,
    unidade_gestora_id         BIGINT,
    usuario_id                 BIGINT,
    log_usuario                VARCHAR(100) NOT NULL DEFAULT 'PORTAL_SISTEMA',
    log_data                   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    excluido                   BOOLEAN DEFAULT FALSE
);

-- Notificações do portal
CREATE TABLE IF NOT EXISTS portal_notificacao (
    id                  BIGSERIAL PRIMARY KEY,
    servidor_id         BIGINT NOT NULL REFERENCES servidor(id),
    titulo              VARCHAR(200) NOT NULL,
    mensagem            TEXT,
    tipo                VARCHAR(20) DEFAULT 'INFO',
    lida                BOOLEAN DEFAULT FALSE,
    data_criacao        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    link                VARCHAR(500),
    unidade_gestora_id  BIGINT,
    usuario_id          BIGINT,
    log_usuario         VARCHAR(100) NOT NULL DEFAULT 'PORTAL_SISTEMA',
    log_data            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    excluido            BOOLEAN DEFAULT FALSE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_portal_credencial_cpf ON portal_credencial(cpf);
CREATE INDEX IF NOT EXISTS idx_portal_credencial_servidor ON portal_credencial(servidor_id);
CREATE INDEX IF NOT EXISTS idx_portal_notificacao_servidor ON portal_notificacao(servidor_id);
CREATE INDEX IF NOT EXISTS idx_portal_notificacao_lida ON portal_notificacao(servidor_id, lida);
CREATE INDEX IF NOT EXISTS idx_portal_notificacao_tipo ON portal_notificacao(servidor_id, tipo);
CREATE INDEX IF NOT EXISTS idx_portal_notificacao_data ON portal_notificacao(data_criacao DESC);
