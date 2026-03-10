-- SCC - Flyway V9
-- Auditoria / Histórico do módulo financeiro (imutável)
-- Modelo genérico: registra eventos para Conta, Repasse, Investimento e Movimentos.

CREATE TABLE IF NOT EXISTS scc_financeiro_historico (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  entidade varchar(40) NOT NULL,        -- CONTA_CONVENIO | REPASSE | INVESTIMENTO | MOVIMENTO_CONTA
  entidade_id uuid NOT NULL,            -- id da entidade afetada

  evento varchar(60) NOT NULL,          -- ex.: CRIAR, ALTERAR, EXCLUIR, POSTAR, ESTORNAR, CONCILIAR
  status_de varchar(40),
  status_para varchar(40),

  usuario_id uuid NULL,
  data_evento timestamptz NOT NULL DEFAULT now(),
  observacao text,

  snapshot_antes jsonb,
  snapshot_depois jsonb,

  CONSTRAINT fk_scc_fin_hist_usuario
    FOREIGN KEY (usuario_id) REFERENCES scc_usuario(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_fin_hist_entidade
  ON scc_financeiro_historico(entidade, entidade_id);

CREATE INDEX IF NOT EXISTS ix_scc_fin_hist_data
  ON scc_financeiro_historico(data_evento);

-- Importante:
-- - Este histórico é IMUTÁVEL: a aplicação apenas INSERE registros.
-- - A aplicação (service layer) deve registrar eventos críticos:
--   REPASSE_CRIADO, REPASSE_POSTADO, MOVIMENTO_CRIADO, RENDIMENTO_LANCADO, etc.
