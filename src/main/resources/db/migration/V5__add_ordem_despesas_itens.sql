-- SCC - Flyway V5
-- Adiciona colunas de ordenação (ordem) em despesas e itens de despesa

ALTER TABLE scc_despesa
  ADD COLUMN IF NOT EXISTS ordem integer;

ALTER TABLE scc_item_despesa
  ADD COLUMN IF NOT EXISTS ordem integer;

-- Índices úteis para ordenação por despesa
CREATE INDEX IF NOT EXISTS ix_scc_despesa_ordem ON scc_despesa(ordem);
CREATE INDEX IF NOT EXISTS ix_scc_item_despesa_ordem ON scc_item_despesa(despesa_id, ordem);
