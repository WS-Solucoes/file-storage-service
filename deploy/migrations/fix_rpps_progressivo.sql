-- Primeiro, atualiza os registros existentes com valor padrão FALSE
UPDATE legislacao SET rpps_progressivo = FALSE WHERE rpps_progressivo IS NULL;

-- Depois, adiciona a constraint NOT NULL
ALTER TABLE legislacao ALTER COLUMN rpps_progressivo SET NOT NULL;
ALTER TABLE legislacao ALTER COLUMN rpps_progressivo SET DEFAULT FALSE;
