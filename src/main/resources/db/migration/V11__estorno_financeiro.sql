-- SCC - Flyway V11
-- Estorno financeiro (contábil, sem apagar registros)
-- Modelo:
-- - um estorno gera um NOVO movimento (movimento_estorno_id) ligado ao movimento original.
-- - o estorno deve inverter ENTRADA/SAIDA e repetir o valor (ou valor parcial, se permitido futuramente).
-- - o controle e a criação do movimento de estorno ficam preferencialmente no SERVICE (Java).
--
-- Este V11 cria as estruturas para rastreabilidade e auditoria do estorno.

CREATE TABLE IF NOT EXISTS scc_estorno_movimento (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  movimento_original_id uuid NOT NULL,
  movimento_estorno_id uuid NOT NULL,

  motivo text NOT NULL,
  usuario_id uuid NULL,
  data_estorno timestamptz NOT NULL DEFAULT now(),

  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT fk_scc_estorno_mov_original
    FOREIGN KEY (movimento_original_id) REFERENCES scc_movimento_conta(id),
  CONSTRAINT fk_scc_estorno_mov_estorno
    FOREIGN KEY (movimento_estorno_id) REFERENCES scc_movimento_conta(id),
  CONSTRAINT fk_scc_estorno_usuario
    FOREIGN KEY (usuario_id) REFERENCES scc_usuario(id),

  CONSTRAINT uq_scc_estorno_mov_original UNIQUE (movimento_original_id),
  CONSTRAINT uq_scc_estorno_mov_estorno UNIQUE (movimento_estorno_id)
);

CREATE INDEX IF NOT EXISTS ix_scc_estorno_original
  ON scc_estorno_movimento(movimento_original_id);

CREATE INDEX IF NOT EXISTS ix_scc_estorno_estorno
  ON scc_estorno_movimento(movimento_estorno_id);

CREATE INDEX IF NOT EXISTS ix_scc_estorno_data
  ON scc_estorno_movimento(data_estorno);

-- (Opcional) status no movimento para marcar estornado
ALTER TABLE scc_movimento_conta
  ADD COLUMN IF NOT EXISTS estornado boolean NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS ix_scc_mov_estornado
  ON scc_movimento_conta(estornado);
