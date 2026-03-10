-- SCC - Flyway V10
-- Auto-posting (base) e proteção contra duplicidade de lançamentos financeiros
-- Objetivo:
-- 1) Vincular Repasse a um Movimento de Conta (quando postado)
-- 2) Evitar duplicidade para a mesma origem (origem_tipo + origem_id)
-- 3) Opcional: Trigger para auto-gerar movimento ao inserir repasse

-- 1) Coluna para vínculo repasse -> movimento_conta
ALTER TABLE scc_repasse
  ADD COLUMN IF NOT EXISTS movimento_conta_id uuid NULL;

-- FK (repasse -> movimento)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    WHERE t.relname = 'scc_repasse' AND c.conname = 'fk_scc_repasse_movimento'
  ) THEN
    ALTER TABLE scc_repasse
      ADD CONSTRAINT fk_scc_repasse_movimento
      FOREIGN KEY (movimento_conta_id) REFERENCES scc_movimento_conta(id);
  END IF;
END $$;

-- 2) Status do repasse (controle do posting)
ALTER TABLE scc_repasse
  ADD COLUMN IF NOT EXISTS status varchar(20) NOT NULL DEFAULT 'PENDENTE';

CREATE INDEX IF NOT EXISTS ix_scc_repasse_status
  ON scc_repasse(status);

-- 3) Índice único parcial para impedir duplicidade de movimento por origem
-- (ex.: REPASSE + repasse.id não pode gerar 2 movimentos)
CREATE UNIQUE INDEX IF NOT EXISTS ux_scc_movimento_origem_unica
  ON scc_movimento_conta(conta_convenio_id, origem_tipo, origem_id)
  WHERE origem_id IS NOT NULL;

-- 4) Função utilitária: obter conta_convenio padrão do convênio (pega a mais antiga)
CREATE OR REPLACE FUNCTION scc_get_conta_convenio(p_convenio_id uuid)
RETURNS uuid AS $$
DECLARE v_id uuid;
BEGIN
  SELECT c.id
    INTO v_id
    FROM scc_conta_convenio c
   WHERE c.convenio_id = p_convenio_id
   ORDER BY c.created_at ASC
   LIMIT 1;

  RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- 5) Trigger opcional: ao inserir repasse, gerar movimento ENTRADA automaticamente
--    e vincular movimento_conta_id + marcar status=POSTADO.
--    Se você preferir fazer tudo via aplicação, comente este bloco na sua base.
CREATE OR REPLACE FUNCTION scc_repasse_autopostar()
RETURNS TRIGGER AS $$
DECLARE v_conta_id uuid;
DECLARE v_mov_id uuid;
BEGIN
  -- Só autoposta se ainda não estiver postado e não houver movimento vinculado
  IF NEW.status <> 'PENDENTE' OR NEW.movimento_conta_id IS NOT NULL THEN
    RETURN NEW;
  END IF;

  v_conta_id := scc_get_conta_convenio(NEW.convenio_id);

  -- se não existir conta, não autoposta (a aplicação deve criar a conta primeiro)
  IF v_conta_id IS NULL THEN
    RETURN NEW;
  END IF;

  INSERT INTO scc_movimento_conta (
    conta_convenio_id, origem_tipo, origem_id, tipo_movimento, data_movimento, descricao, valor
  ) VALUES (
    v_conta_id, 'REPASSE', NEW.id, 'ENTRADA', NEW.data_entrada,
    COALESCE(NEW.descricao, 'Repasse'), NEW.valor
  )
  RETURNING id INTO v_mov_id;

  NEW.movimento_conta_id := v_mov_id;
  NEW.status := 'POSTADO';

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Gatilho (BEFORE INSERT) para permitir preencher NEW.*
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'trg_scc_repasse_autopostar'
  ) THEN
    CREATE TRIGGER trg_scc_repasse_autopostar
    BEFORE INSERT ON scc_repasse
    FOR EACH ROW
    EXECUTE FUNCTION scc_repasse_autopostar();
  END IF;
END $$;
