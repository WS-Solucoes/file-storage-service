-- =====================================================
-- V014: Módulo de Processos / Workflow
-- Cria tabelas de modelo e instância de processos
-- =====================================================

-- =====================================================
-- 1. TABELAS DE MODELO (Templates de processo)
-- =====================================================

CREATE TABLE IF NOT EXISTS processo_modelo (
    id BIGSERIAL PRIMARY KEY,
    codigo VARCHAR(50) NOT NULL UNIQUE,
    nome VARCHAR(200) NOT NULL,
    descricao VARCHAR(1000),
    instrucoes TEXT,
    categoria VARCHAR(30) NOT NULL,
    icone VARCHAR(50),
    cor VARCHAR(20),
    prazo_atendimento_dias INTEGER,
    requer_aprovacao_chefia BOOLEAN DEFAULT FALSE,
    gera_acao_automatica BOOLEAN DEFAULT FALSE,
    ativo BOOLEAN DEFAULT TRUE,
    visivel_portal BOOLEAN DEFAULT TRUE,
    ordem_exibicao INTEGER DEFAULT 0,
    -- Campos audit/tenant (AbstractExecucaoTenantEntity)
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

CREATE TABLE IF NOT EXISTS processo_documento_modelo (
    id BIGSERIAL PRIMARY KEY,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id),
    nome VARCHAR(200) NOT NULL,
    descricao VARCHAR(500),
    obrigatorio BOOLEAN DEFAULT TRUE,
    tipos_permitidos VARCHAR(200) DEFAULT 'PDF,JPG,PNG',
    tamanho_maximo_mb INTEGER DEFAULT 10,
    modelo_url VARCHAR(500),
    ordem INTEGER DEFAULT 0,
    -- Campos audit/tenant
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

CREATE TABLE IF NOT EXISTS processo_etapa_modelo (
    id BIGSERIAL PRIMARY KEY,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id),
    nome VARCHAR(200) NOT NULL,
    descricao VARCHAR(500),
    ordem INTEGER NOT NULL,
    tipo_responsavel VARCHAR(30) DEFAULT 'RH',
    acao_automatica VARCHAR(100),
    prazo_dias INTEGER,
    -- Campos audit/tenant
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

CREATE TABLE IF NOT EXISTS processo_campo_modelo (
    id BIGSERIAL PRIMARY KEY,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id),
    nome_campo VARCHAR(100) NOT NULL,
    label VARCHAR(200) NOT NULL,
    tipo_campo VARCHAR(20) NOT NULL DEFAULT 'TEXT',
    obrigatorio BOOLEAN DEFAULT FALSE,
    opcoes_select TEXT,
    placeholder VARCHAR(200),
    ajuda VARCHAR(500),
    ordem INTEGER DEFAULT 0,
    -- Campos audit/tenant
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

-- =====================================================
-- 2. TABELAS DE INSTÂNCIA (Processos abertos)
-- =====================================================

CREATE TABLE IF NOT EXISTS processo (
    id BIGSERIAL PRIMARY KEY,
    protocolo VARCHAR(20) NOT NULL UNIQUE,
    processo_modelo_id BIGINT NOT NULL REFERENCES processo_modelo(id),
    servidor_id BIGINT NOT NULL,
    vinculo_funcional_id BIGINT,
    situacao VARCHAR(30) NOT NULL DEFAULT 'ABERTO',
    etapa_atual INTEGER DEFAULT 1,
    data_abertura TIMESTAMP NOT NULL,
    data_ultima_atualizacao TIMESTAMP,
    data_conclusao TIMESTAMP,
    prazo_limite DATE,
    atribuido_para VARCHAR(255),
    departamento_atribuido VARCHAR(255),
    dados_formulario JSONB,
    observacao_servidor TEXT,
    resultado VARCHAR(20),
    justificativa_resultado TEXT,
    referencia_tipo VARCHAR(50),
    referencia_id BIGINT,
    prioridade VARCHAR(20) DEFAULT 'NORMAL',
    -- Campos audit/tenant
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

CREATE TABLE IF NOT EXISTS processo_documento (
    id BIGSERIAL PRIMARY KEY,
    processo_id BIGINT NOT NULL REFERENCES processo(id),
    documento_modelo_id BIGINT REFERENCES processo_documento_modelo(id),
    nome_arquivo VARCHAR(500) NOT NULL,
    caminho_storage VARCHAR(1000) NOT NULL,
    tipo_arquivo VARCHAR(100),
    tamanho_bytes BIGINT,
    data_envio TIMESTAMP NOT NULL,
    enviado_por VARCHAR(255) NOT NULL,
    situacao VARCHAR(20) DEFAULT 'PENDENTE',
    motivo_recusa VARCHAR(500),
    avaliado_por VARCHAR(255),
    data_avaliacao TIMESTAMP,
    -- Campos audit/tenant
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

CREATE TABLE IF NOT EXISTS processo_mensagem (
    id BIGSERIAL PRIMARY KEY,
    processo_id BIGINT NOT NULL REFERENCES processo(id),
    autor VARCHAR(255) NOT NULL,
    tipo_autor VARCHAR(20) NOT NULL,
    mensagem TEXT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    lida BOOLEAN DEFAULT FALSE,
    data_leitura TIMESTAMP,
    anexo_nome VARCHAR(500),
    anexo_caminho VARCHAR(1000),
    anexo_tipo VARCHAR(100),
    -- Campos audit/tenant
    excluido BOOLEAN DEFAULT FALSE,
    usuario_log VARCHAR(255),
    dt_log TIMESTAMP,
    unidade_gestora_id BIGINT,
    usuario_id BIGINT
);

CREATE TABLE IF NOT EXISTS processo_historico (
    id BIGSERIAL PRIMARY KEY,
    processo_id BIGINT NOT NULL REFERENCES processo(id),
    data_hora TIMESTAMP NOT NULL,
    acao VARCHAR(50) NOT NULL,
    situacao_anterior VARCHAR(30),
    situacao_nova VARCHAR(30),
    etapa_anterior INTEGER,
    etapa_nova INTEGER,
    usuario VARCHAR(255) NOT NULL,
    tipo_usuario VARCHAR(20),
    descricao VARCHAR(1000),
    dados_extras JSONB,
    unidade_gestora_id BIGINT
);

-- =====================================================
-- 3. ÍNDICES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_processo_protocolo ON processo(protocolo);
CREATE INDEX IF NOT EXISTS idx_processo_servidor ON processo(servidor_id);
CREATE INDEX IF NOT EXISTS idx_processo_situacao ON processo(situacao);
CREATE INDEX IF NOT EXISTS idx_processo_modelo ON processo(processo_modelo_id);
CREATE INDEX IF NOT EXISTS idx_processo_prazo ON processo(prazo_limite);
CREATE INDEX IF NOT EXISTS idx_processo_atribuido ON processo(atribuido_para);
CREATE INDEX IF NOT EXISTS idx_processo_data_abertura ON processo(data_abertura);
CREATE INDEX IF NOT EXISTS idx_processo_ug ON processo(unidade_gestora_id);

CREATE INDEX IF NOT EXISTS idx_proc_doc_processo ON processo_documento(processo_id);
CREATE INDEX IF NOT EXISTS idx_proc_msg_processo ON processo_mensagem(processo_id);
CREATE INDEX IF NOT EXISTS idx_proc_hist_processo ON processo_historico(processo_id);
CREATE INDEX IF NOT EXISTS idx_proc_modelo_categoria ON processo_modelo(categoria);

-- =====================================================
-- 4. SEED DATA: 6 Modelos padrão de processo
-- =====================================================

-- 4.1 Solicitação de Férias
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_FERIAS', 'Solicitação de Férias', 'Solicitação de gozo de férias regulamentares', 
        'Preencha o período desejado para gozo de férias. O RH verificará o saldo disponível e a chefia imediata deverá aprovar.',
        'FERIAS', 'Calendar', '#3B82F6', 15, TRUE, TRUE, TRUE, TRUE, 1)
ON CONFLICT (codigo) DO NOTHING;

-- Documentos exigidos (Férias)
INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Requerimento de Férias', 'Formulário de requerimento assinado', TRUE, 'PDF', 5, 1
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND nome = 'Requerimento de Férias'
);

-- Etapas (Férias)
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Triagem RH', 'Verificação de saldo e elegibilidade', 1, 'RH', 3
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Aprovação Chefia', 'Aprovação do chefe imediato', 2, 'CHEFIA', 5
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND ordem = 2
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Concessão', 'Geração da portaria de concessão', 3, 'RH', 5
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND ordem = 3
);

-- Campos adicionais (Férias)
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'data_inicio', 'Data Início', 'DATE', TRUE, '', 'Data de início do gozo das férias', 1
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND nome_campo = 'data_inicio'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'data_fim', 'Data Fim', 'DATE', TRUE, '', 'Data de término do gozo das férias', 2
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND nome_campo = 'data_fim'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'abono_pecuniario', 'Abono Pecuniário?', 'BOOLEAN', FALSE, '', 'Deseja converter 1/3 das férias em abono pecuniário?', 3
FROM processo_modelo WHERE codigo = 'PROC_FERIAS' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_FERIAS') AND nome_campo = 'abono_pecuniario'
);

-- 4.2 Licença Saúde
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_LIC_SAUDE', 'Licença para Tratamento de Saúde', 'Solicitação de licença por motivo de saúde com atestado médico',
        'Envie o atestado médico com CID e período de afastamento. A perícia pode ser solicitada se o afastamento for superior a 15 dias.',
        'LICENCA', 'Heart', '#EF4444', 5, FALSE, TRUE, TRUE, TRUE, 2)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Atestado Médico', 'Atestado com CID, período e assinatura do médico', TRUE, 'PDF,JPG,PNG', 10, 1
FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE') AND nome = 'Atestado Médico'
);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Análise Documental', 'Verificação do atestado médico', 1, 'RH', 2
FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Registro de Afastamento', 'Lançamento no sistema', 2, 'RH', 2
FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE') AND ordem = 2
);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'data_inicio_afastamento', 'Data Início Afastamento', 'DATE', TRUE, '', 'Conforme atestado médico', 1
FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE') AND nome_campo = 'data_inicio_afastamento'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'dias_afastamento', 'Dias de Afastamento', 'NUMBER', TRUE, '', 'Quantidade de dias conforme atestado', 2
FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_SAUDE') AND nome_campo = 'dias_afastamento'
);

-- 4.3 Licença Maternidade
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_LIC_MATERNIDADE', 'Licença Maternidade', 'Solicitação de licença maternidade (120 ou 180 dias)',
        'Envie a certidão de nascimento ou atestado médico com data prevista do parto. A licença será de 120 dias, podendo ser prorrogada por mais 60 dias.',
        'LICENCA', 'Baby', '#EC4899', 10, FALSE, TRUE, TRUE, TRUE, 3)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Certidão de Nascimento ou Atestado Médico', 'Certidão de nascimento ou atestado com DPP', TRUE, 'PDF,JPG,PNG', 10, 1
FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE') AND ordem = 1
);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Análise Documental', 'Verificação dos documentos', 1, 'RH', 3
FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Concessão da Licença', 'Publicação e registro', 2, 'RH', 5
FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_MATERNIDADE') AND ordem = 2
);

-- 4.4 Atualização Cadastral
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_ATUALIZACAO_CADASTRAL', 'Atualização Cadastral', 'Solicitar atualização de dados pessoais, endereço ou dados bancários',
        'Informe quais dados deseja atualizar e envie os documentos comprobatórios.',
        'CADASTRAL', 'UserEdit', '#8B5CF6', 10, FALSE, FALSE, TRUE, TRUE, 4)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Documento Comprobatório', 'Comprovante de endereço, RG, CPF, etc.', TRUE, 'PDF,JPG,PNG', 10, 1
FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL') AND ordem = 1
);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Análise e Atualização', 'Verificação e atualização dos dados', 1, 'RH', 5
FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL') AND ordem = 1
);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, opcoes_select, placeholder, ajuda, ordem)
SELECT id, 'tipo_atualizacao', 'Tipo de Atualização', 'SELECT', TRUE, 'Endereço,Telefone,E-mail,Dados Bancários,Estado Civil,Dependentes,Escolaridade,Outro', 'Selecione', 'Selecione o que deseja atualizar', 1
FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL') AND nome_campo = 'tipo_atualizacao'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'descricao_atualizacao', 'Descreva a Atualização', 'TEXTAREA', TRUE, 'Descreva detalhadamente o que precisa ser alterado', 'Informe os dados antigos e os novos dados', 2
FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_ATUALIZACAO_CADASTRAL') AND nome_campo = 'descricao_atualizacao'
);

-- 4.5 Certidão de Tempo de Serviço
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_CERTIDAO_TEMPO', 'Certidão de Tempo de Serviço', 'Solicitar certidão de tempo de serviço/contribuição',
        'Informe a finalidade da certidão. O RH emitirá o documento após análise do tempo de serviço.',
        'DOCUMENTAL', 'FileText', '#F59E0B', 15, FALSE, FALSE, TRUE, TRUE, 5)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Levantamento de Tempo', 'Apuração do tempo de serviço', 1, 'RH', 10
FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Emissão da Certidão', 'Geração e assinatura do documento', 2, 'RH', 5
FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO') AND ordem = 2
);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, opcoes_select, placeholder, ajuda, ordem)
SELECT id, 'finalidade', 'Finalidade', 'SELECT', TRUE, 'Aposentadoria,Averbação,Concurso Público,Outros', 'Selecione', 'Para que será utilizada a certidão?', 1
FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_CERTIDAO_TEMPO') AND nome_campo = 'finalidade'
);

-- 4.6 Licença Prêmio
INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_LIC_PREMIO', 'Licença Prêmio', 'Solicitação de licença prêmio por assiduidade (a cada 5 anos)',
        'Informe o período desejado para gozo. A licença deve ser requerida com antecedência mínima de 30 dias.',
        'LICENCA', 'Award', '#10B981', 20, TRUE, TRUE, TRUE, TRUE, 6)
ON CONFLICT (codigo) DO NOTHING;

INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Requerimento', 'Requerimento assinado de licença prêmio', TRUE, 'PDF', 5, 1
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND ordem = 1
);

INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Verificação de Elegibilidade', 'Verificar tempo de serviço e assiduidade', 1, 'RH', 5
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Aprovação Chefia', 'Aprovação do chefe imediato', 2, 'CHEFIA', 5
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND ordem = 2
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Publicação', 'Publicação da portaria', 3, 'RH', 10
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND ordem = 3
);

INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'periodo_aquisitivo', 'Período Aquisitivo', 'TEXT', TRUE, 'Ex: 01/01/2019 a 31/12/2023', 'Quinquênio de referência', 1
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND nome_campo = 'periodo_aquisitivo'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'data_inicio_gozo', 'Data Início do Gozo', 'DATE', TRUE, '', 'Data desejada para início', 2
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND nome_campo = 'data_inicio_gozo'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'dias_gozo', 'Dias de Gozo', 'NUMBER', TRUE, '90', 'Máximo de 90 dias', 3
FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_LIC_PREMIO') AND nome_campo = 'dias_gozo'
);
