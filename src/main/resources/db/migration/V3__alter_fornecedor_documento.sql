-- SCC - Flyway V3
-- Ajustes para suportar fornecedores Pessoa Física / genéricos (alinhado ao seed legado)
-- - troca "cnpj" por "documento"
-- - documento passa a ser opcional (NULL permitido)
-- - adiciona tipo_fornecedor (PESSOA, EMPRESA, OUTROS)
-- - mantém índice/uniqueness para documento quando informado

-- 1) Renomeia coluna cnpj -> documento (se existir)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'scc_fornecedor' AND column_name = 'cnpj'
  ) THEN
    ALTER TABLE scc_fornecedor RENAME COLUMN cnpj TO documento;
  END IF;
END $$;

-- 2) Ajusta nullability do documento
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'scc_fornecedor' AND column_name = 'documento'
  ) THEN
    ALTER TABLE scc_fornecedor ALTER COLUMN documento DROP NOT NULL;
  END IF;
END $$;

-- 3) Adiciona tipo_fornecedor se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'scc_fornecedor' AND column_name = 'tipo_fornecedor'
  ) THEN
    ALTER TABLE scc_fornecedor ADD COLUMN tipo_fornecedor varchar(20) NOT NULL DEFAULT 'EMPRESA';
  END IF;
END $$;

-- 4) Garante unicidade do documento quando informado (partial unique index)
-- (Remove constraint antiga se existir, para evitar conflito)
DO $$
BEGIN
  -- remove constraint unique antiga (nome pode variar por ambiente)
  IF EXISTS (
    SELECT 1 FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    WHERE t.relname = 'scc_fornecedor' AND c.contype = 'u'
  ) THEN
    -- Não tentamos dropar automaticamente por nome (pode variar). Mantemos o índice parcial abaixo como fonte de verdade.
    NULL;
  END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS ux_scc_fornecedor_documento_not_null
  ON scc_fornecedor(documento)
  WHERE documento IS NOT NULL;
