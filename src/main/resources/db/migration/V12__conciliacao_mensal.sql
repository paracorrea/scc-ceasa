-- SCC - Flyway V12
-- Conciliação mensal (Resumo Financeiro x Razão do Convênio x Itens da Prestação)
-- Cria tabela de conciliação e views de cálculo.

CREATE TABLE IF NOT EXISTS scc_conciliacao_mensal (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prestacao_id uuid NOT NULL,

  status varchar(20) NOT NULL DEFAULT 'ABERTA', -- ABERTA | DIVERGENTE | CONCILIADA | FECHADA

  total_itens_regular numeric(14,2) NOT NULL DEFAULT 0,
  total_itens_glosado numeric(14,2) NOT NULL DEFAULT 0,

  total_razao_entradas numeric(14,2) NOT NULL DEFAULT 0,
  total_razao_saidas numeric(14,2) NOT NULL DEFAULT 0,

  saldo_inicio_mes numeric(14,2) NOT NULL DEFAULT 0,
  saldo_fim_mes numeric(14,2) NOT NULL DEFAULT 0,

  diferenca numeric(14,2) NOT NULL DEFAULT 0,
  observacao text,

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT fk_scc_conciliacao_prestacao
    FOREIGN KEY (prestacao_id) REFERENCES scc_prestacao(id),
  CONSTRAINT uq_scc_conciliacao_prestacao UNIQUE (prestacao_id)
);

CREATE INDEX IF NOT EXISTS ix_scc_conciliacao_status
  ON scc_conciliacao_mensal(status);

CREATE TRIGGER trg_scc_conciliacao_updated_at
BEFORE UPDATE ON scc_conciliacao_mensal
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();

-- 1) Faixa do mês para cada prestação
CREATE OR REPLACE VIEW scc_vw_prestacao_periodo AS
SELECT
  p.id AS prestacao_id,
  p.convenio_id,
  p.mes_referencia,
  date_trunc('month', p.mes_referencia)::date AS mes_inicio,
  (date_trunc('month', p.mes_referencia) + interval '1 month')::date AS mes_fim_exclusivo
FROM scc_prestacao p;

-- 2) Totais de itens por prestação (REGULAR / GLOSADO)
CREATE OR REPLACE VIEW scc_vw_totais_itens_prestacao AS
SELECT
  per.prestacao_id,
  COALESCE(SUM(CASE WHEN i.status = 'REGULAR' AND i.deleted_at IS NULL THEN i.valor ELSE 0 END), 0) AS total_itens_regular,
  COALESCE(SUM(CASE WHEN i.status = 'GLOSADO' AND i.deleted_at IS NULL THEN i.valor ELSE 0 END), 0) AS total_itens_glosado
FROM scc_vw_prestacao_periodo per
LEFT JOIN scc_item_prestacao i
  ON i.prestacao_id = per.prestacao_id
 AND i.data_documento >= per.mes_inicio
 AND i.data_documento <  per.mes_fim_exclusivo
GROUP BY per.prestacao_id;

-- 3) Totais do razão por convênio e mês
CREATE OR REPLACE VIEW scc_vw_totais_razao_mes AS
SELECT
  per.prestacao_id,
  COALESCE(SUM(CASE WHEN m.tipo_movimento = 'ENTRADA' THEN m.valor ELSE 0 END), 0) AS total_razao_entradas,
  COALESCE(SUM(CASE WHEN m.tipo_movimento = 'SAIDA' THEN m.valor ELSE 0 END), 0) AS total_razao_saidas
FROM scc_vw_prestacao_periodo per
JOIN scc_conta_convenio c
  ON c.convenio_id = per.convenio_id
LEFT JOIN scc_movimento_conta m
  ON m.conta_convenio_id = c.id
 AND m.data_movimento >= per.mes_inicio
 AND m.data_movimento <  per.mes_fim_exclusivo
GROUP BY per.prestacao_id;

-- 4) Saldos do razão no início e fim do mês
CREATE OR REPLACE VIEW scc_vw_saldos_razao_mes AS
SELECT
  per.prestacao_id,
  (c.saldo_inicial
   + COALESCE(SUM(CASE WHEN m.data_movimento < per.mes_inicio AND m.tipo_movimento = 'ENTRADA' THEN m.valor ELSE 0 END), 0)
   - COALESCE(SUM(CASE WHEN m.data_movimento < per.mes_inicio AND m.tipo_movimento = 'SAIDA' THEN m.valor ELSE 0 END), 0)
  ) AS saldo_inicio_mes,
  (c.saldo_inicial
   + COALESCE(SUM(CASE WHEN m.data_movimento < per.mes_fim_exclusivo AND m.tipo_movimento = 'ENTRADA' THEN m.valor ELSE 0 END), 0)
   - COALESCE(SUM(CASE WHEN m.data_movimento < per.mes_fim_exclusivo AND m.tipo_movimento = 'SAIDA' THEN m.valor ELSE 0 END), 0)
  ) AS saldo_fim_mes
FROM scc_vw_prestacao_periodo per
JOIN scc_conta_convenio c
  ON c.convenio_id = per.convenio_id
LEFT JOIN scc_movimento_conta m
  ON m.conta_convenio_id = c.id
GROUP BY per.prestacao_id, c.saldo_inicial;

-- 5) Conciliação calculada
CREATE OR REPLACE VIEW scc_vw_conciliacao_calc AS
SELECT
  per.prestacao_id,
  per.convenio_id,
  per.mes_referencia,
  it.total_itens_regular,
  it.total_itens_glosado,
  rz.total_razao_entradas,
  rz.total_razao_saidas,
  sd.saldo_inicio_mes,
  sd.saldo_fim_mes,
  (it.total_itens_regular - rz.total_razao_saidas) AS diferenca_itens_vs_saidas
FROM scc_vw_prestacao_periodo per
LEFT JOIN scc_vw_totais_itens_prestacao it ON it.prestacao_id = per.prestacao_id
LEFT JOIN scc_vw_totais_razao_mes rz ON rz.prestacao_id = per.prestacao_id
LEFT JOIN scc_vw_saldos_razao_mes sd ON sd.prestacao_id = per.prestacao_id;
