-- Adiciona campos de taxa administrativa e suplementar para RPPS na tabela legislacao
-- V004__add_rpps_taxa_administrativa_suplementar.sql

-- Taxa administrativa do RPPS (percentual sobre a folha)
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS rpps_taxa_administrativa DECIMAL(5,2);

COMMENT ON COLUMN legislacao.rpps_taxa_administrativa IS 'Taxa administrativa do RPPS (percentual sobre a folha). Usada para custear despesas administrativas do Instituto de Previdência.';

-- Taxa suplementar do RPPS (percentual sobre a folha)
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS rpps_taxa_suplementar DECIMAL(5,2);

COMMENT ON COLUMN legislacao.rpps_taxa_suplementar IS 'Taxa suplementar do RPPS (percentual sobre a folha). Contribuição adicional para cobrir déficit atuarial.';

-- Flag se a taxa administrativa incide sobre o servidor
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS rpps_taxa_adm_incide_servidor BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN legislacao.rpps_taxa_adm_incide_servidor IS 'Indica se a taxa administrativa é descontada do servidor (true) ou apenas patronal (false).';

-- Flag se a taxa suplementar incide sobre o servidor
ALTER TABLE legislacao 
ADD COLUMN IF NOT EXISTS rpps_taxa_supl_incide_servidor BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN legislacao.rpps_taxa_supl_incide_servidor IS 'Indica se a taxa suplementar é descontada do servidor (true) ou apenas patronal (false).';

-- Índices para otimização (se necessário para relatórios)
-- CREATE INDEX IF NOT EXISTS idx_legislacao_taxa_administrativa ON legislacao(rpps_taxa_administrativa) WHERE rpps_taxa_administrativa IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_legislacao_taxa_suplementar ON legislacao(rpps_taxa_suplementar) WHERE rpps_taxa_suplementar IS NOT NULL;
