-- =====================================================
-- V016: Modelos de processo para Afastamento e Rescisão
-- Adiciona templates que geram ações automáticas nos
-- módulos de Afastamento e Rescisão ao serem deferidos
-- =====================================================

-- =====================================================
-- 1. MODELO: Solicitação de Afastamento
-- =====================================================

INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_AFASTAMENTO', 'Solicitação de Afastamento', 'Solicitação de afastamento do trabalho por motivos diversos',
        'Informe o período e o motivo do afastamento. Anexe os documentos comprobatórios necessários. O RH analisará a solicitação.',
        'AFASTAMENTO', 'UserMinus', '#F97316', 10, FALSE, TRUE, TRUE, TRUE, 7)
ON CONFLICT (codigo) DO NOTHING;

-- Documentos exigidos
INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Documento Comprobatório', 'Atestado, declaração ou outro documento que comprove o motivo do afastamento', TRUE, 'PDF,JPG,PNG', 10, 1
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND nome = 'Documento Comprobatório'
);

-- Etapas do workflow
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Análise Documental', 'Verificação dos documentos e motivo do afastamento', 1, 'RH', 3
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Registro do Afastamento', 'Lançamento do afastamento no sistema', 2, 'RH', 2
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND ordem = 2
);

-- Campos dinâmicos do formulário
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'data_inicio_afastamento', 'Data Início do Afastamento', 'DATE', TRUE, '', 'Data em que o afastamento tem início', 1
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND nome_campo = 'data_inicio_afastamento'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'dias_afastamento', 'Dias de Afastamento', 'NUMBER', TRUE, 'Ex: 15', 'Quantidade total de dias de afastamento', 2
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND nome_campo = 'dias_afastamento'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'cid', 'Código CID (se aplicável)', 'TEXT', FALSE, 'Ex: J11', 'Código Internacional de Doenças (para afastamentos de saúde)', 3
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND nome_campo = 'cid'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'crm_medico', 'CRM do Médico (se aplicável)', 'TEXT', FALSE, 'Ex: CRM/SP 123456', 'CRM do médico que emitiu o atestado', 4
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND nome_campo = 'crm_medico'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'nome_medico', 'Nome do Médico (se aplicável)', 'TEXT', FALSE, '', 'Nome completo do médico responsável', 5
FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_AFASTAMENTO') AND nome_campo = 'nome_medico'
);

-- =====================================================
-- 2. MODELO: Solicitação de Rescisão / Desligamento
-- =====================================================

INSERT INTO processo_modelo (codigo, nome, descricao, instrucoes, categoria, icone, cor, prazo_atendimento_dias, requer_aprovacao_chefia, gera_acao_automatica, ativo, visivel_portal, ordem_exibicao)
VALUES ('PROC_RESCISAO', 'Solicitação de Desligamento', 'Solicitação de rescisão contratual / desligamento do servidor',
        'Informe a data pretendida de desligamento e o motivo. O RH processará a rescisão e calculará as verbas rescisórias.',
        'RESCISAO', 'UserX', '#DC2626', 20, TRUE, TRUE, TRUE, TRUE, 8)
ON CONFLICT (codigo) DO NOTHING;

-- Documentos exigidos
INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Carta de Pedido de Exoneração', 'Documento formal solicitando o desligamento', TRUE, 'PDF', 5, 1
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND nome = 'Carta de Pedido de Exoneração'
);
INSERT INTO processo_documento_modelo (processo_modelo_id, nome, descricao, obrigatorio, tipos_permitidos, tamanho_maximo_mb, ordem)
SELECT id, 'Documento de Identificação', 'RG ou CNH do servidor', TRUE, 'PDF,JPG,PNG', 10, 2
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_documento_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND nome = 'Documento de Identificação'
);

-- Etapas do workflow
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Análise RH', 'Verificação de pendências e levantamento de dados', 1, 'RH', 5
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND ordem = 1
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Aprovação Chefia', 'Ciência e concordância da chefia imediata', 2, 'CHEFIA', 5
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND ordem = 2
);
INSERT INTO processo_etapa_modelo (processo_modelo_id, nome, descricao, ordem, tipo_responsavel, prazo_dias)
SELECT id, 'Cálculo e Homologação', 'Cálculo das verbas rescisórias e homologação', 3, 'RH', 10
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_etapa_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND ordem = 3
);

-- Campos dinâmicos do formulário
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'data_desligamento', 'Data Pretendida de Desligamento', 'DATE', TRUE, '', 'Data em que pretende se desligar', 1
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND nome_campo = 'data_desligamento'
);
INSERT INTO processo_campo_modelo (processo_modelo_id, nome_campo, label, tipo_campo, obrigatorio, placeholder, ajuda, ordem)
SELECT id, 'motivo_resumo', 'Motivo do Desligamento', 'TEXTAREA', TRUE, 'Descreva brevemente o motivo do pedido de desligamento', 'Informação para registro no processo', 2
FROM processo_modelo WHERE codigo = 'PROC_RESCISAO' AND NOT EXISTS (
    SELECT 1 FROM processo_campo_modelo WHERE processo_modelo_id = (SELECT id FROM processo_modelo WHERE codigo = 'PROC_RESCISAO') AND nome_campo = 'motivo_resumo'
);
