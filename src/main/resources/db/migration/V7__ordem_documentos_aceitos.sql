-- SCC - Flyway V7
-- Adiciona coluna de ordenação em documentos aceitos
-- e popula com uma ordem lógica para dropdowns

ALTER TABLE scc_documento_aceito
  ADD COLUMN IF NOT EXISTS ordem integer;

CREATE INDEX IF NOT EXISTS ix_scc_documento_ordem
  ON scc_documento_aceito(ordem);

-- Ordem sugerida para exibição na interface

UPDATE scc_documento_aceito SET ordem = 10 WHERE codigo = 'NOTA_FISCAL';
UPDATE scc_documento_aceito SET ordem = 20 WHERE codigo = 'CUPOM_FISCAL';
UPDATE scc_documento_aceito SET ordem = 30 WHERE codigo = 'FATURA';
UPDATE scc_documento_aceito SET ordem = 40 WHERE codigo = 'GUIA_RECOLHIMENTO';
UPDATE scc_documento_aceito SET ordem = 50 WHERE codigo = 'HOLLERITH';
UPDATE scc_documento_aceito SET ordem = 60 WHERE codigo = 'RECIBO_LOCACAO';
UPDATE scc_documento_aceito SET ordem = 70 WHERE codigo = 'RECIBO_PAG_AUTONOMO';
UPDATE scc_documento_aceito SET ordem = 80 WHERE codigo = 'RECIBO_TAXI';
UPDATE scc_documento_aceito SET ordem = 90 WHERE codigo = 'RECIBO_VT';
UPDATE scc_documento_aceito SET ordem = 100 WHERE codigo = 'RPA';
UPDATE scc_documento_aceito SET ordem = 110 WHERE codigo = 'TERMO_RESCISAO';
UPDATE scc_documento_aceito SET ordem = 999 WHERE codigo = 'OUTROS';
