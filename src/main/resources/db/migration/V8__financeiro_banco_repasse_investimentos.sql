-- SCC - Flyway V8
-- Módulo Financeiro (Banco / Repasse / Investimentos) - base contábil do convênio
-- Objetivo:
-- 1) Registrar REPASSES (entradas) do convênio
-- 2) Manter um "BANCO" (livro-razão) com movimentos (entradas/saídas/rendimentos/ajustes)
-- 3) Permitir investimentos e rendimentos (ganhos) vinculados ao saldo do convênio
--
-- Observações:
-- - Este V8 NÃO remove o modelo mensal (scc_resumo_financeiro / scc_movimento_bancario).
-- - Ele cria o "razão do convênio", que depois será conciliado com o Resumo Financeiro mensal.
-- - Caso você queira ter 1 conta por convênio, mantenha apenas uma linha em scc_conta_convenio.

-- =====================================
-- Conta do Convênio (o "Banco" do convênio)
-- =====================================
CREATE TABLE IF NOT EXISTS scc_conta_convenio (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  convenio_id uuid NOT NULL,
  conta_bancaria_entidade_id uuid NULL, -- opcional: aponta para a conta bancária cadastrada na entidade conveniada
  nome varchar(120) NOT NULL DEFAULT 'CONTA PRINCIPAL',
  saldo_inicial numeric(14,2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_conta_convenio_convenio
    FOREIGN KEY (convenio_id) REFERENCES scc_convenio(id),
  CONSTRAINT fk_scc_conta_convenio_conta_entidade
    FOREIGN KEY (conta_bancaria_entidade_id) REFERENCES scc_conta_bancaria_entidade(id),
  CONSTRAINT uq_scc_conta_convenio_unique UNIQUE (convenio_id, nome)
);

CREATE INDEX IF NOT EXISTS ix_scc_conta_convenio_convenio_id
  ON scc_conta_convenio(convenio_id);

CREATE TRIGGER trg_scc_conta_convenio_updated_at
BEFORE UPDATE ON scc_conta_convenio
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();

-- =====================================
-- Repasse (entrada de recursos)
-- =====================================
CREATE TABLE IF NOT EXISTS scc_repasse (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  convenio_id uuid NOT NULL,
  data_entrada date NOT NULL,
  valor numeric(14,2) NOT NULL,
  descricao varchar(255),
  numero_documento varchar(80), -- opcional (TED, Ordem bancária, etc.)
  observacao text,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_repasse_convenio
    FOREIGN KEY (convenio_id) REFERENCES scc_convenio(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_repasse_convenio_id
  ON scc_repasse(convenio_id);

CREATE INDEX IF NOT EXISTS ix_scc_repasse_data
  ON scc_repasse(data_entrada);

-- =====================================
-- Investimentos (aplicações) e Rendimentos
-- =====================================
CREATE TABLE IF NOT EXISTS scc_investimento (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conta_convenio_id uuid NOT NULL,
  tipo_investimento varchar(60) NOT NULL, -- ex.: CDB, POUPANCA, FUNDO, TESOURO (ajustável)
  instituicao varchar(120),
  data_inicio date NOT NULL,
  data_fim date,
  valor_aplicado numeric(14,2) NOT NULL DEFAULT 0,
  ativo boolean NOT NULL DEFAULT true,
  observacao text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_investimento_conta
    FOREIGN KEY (conta_convenio_id) REFERENCES scc_conta_convenio(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_investimento_conta_id
  ON scc_investimento(conta_convenio_id);

CREATE TRIGGER trg_scc_investimento_updated_at
BEFORE UPDATE ON scc_investimento
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();

-- =====================================
-- Livro-razão (movimentações do "Banco" do convênio)
-- =====================================
CREATE TABLE IF NOT EXISTS scc_movimento_conta (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conta_convenio_id uuid NOT NULL,

  -- Origem do movimento (ajuda rastrear)
  origem_tipo varchar(40) NOT NULL DEFAULT 'MANUAL',
  -- exemplos: REPASSE, ITEM_PRESTACAO, INVESTIMENTO_APLICACAO, INVESTIMENTO_RESGATE, RENDIMENTO, AJUSTE, MANUAL
  origem_id uuid NULL,

  tipo_movimento varchar(20) NOT NULL, -- ENTRADA / SAIDA
  data_movimento date NOT NULL,
  descricao text,
  valor numeric(14,2) NOT NULL,

  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_mov_conta
    FOREIGN KEY (conta_convenio_id) REFERENCES scc_conta_convenio(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_mov_conta_id
  ON scc_movimento_conta(conta_convenio_id);

CREATE INDEX IF NOT EXISTS ix_scc_mov_conta_data
  ON scc_movimento_conta(data_movimento);

CREATE INDEX IF NOT EXISTS ix_scc_mov_conta_origem
  ON scc_movimento_conta(origem_tipo, origem_id);

-- =====================================
-- (Opcional V8) View de saldo (computado)
-- =====================================
-- Saldo = saldo_inicial + somatório ENTRADA - somatório SAIDA
CREATE OR REPLACE VIEW scc_vw_saldo_conta_convenio AS
SELECT
  c.id AS conta_convenio_id,
  c.convenio_id,
  c.nome,
  c.saldo_inicial,
  COALESCE(SUM(CASE WHEN m.tipo_movimento = 'ENTRADA' THEN m.valor ELSE 0 END), 0) AS total_entradas,
  COALESCE(SUM(CASE WHEN m.tipo_movimento = 'SAIDA' THEN m.valor ELSE 0 END), 0) AS total_saidas,
  (c.saldo_inicial
   + COALESCE(SUM(CASE WHEN m.tipo_movimento = 'ENTRADA' THEN m.valor ELSE 0 END), 0)
   - COALESCE(SUM(CASE WHEN m.tipo_movimento = 'SAIDA' THEN m.valor ELSE 0 END), 0)
  ) AS saldo_atual
FROM scc_conta_convenio c
LEFT JOIN scc_movimento_conta m ON m.conta_convenio_id = c.id
GROUP BY c.id, c.convenio_id, c.nome, c.saldo_inicial;
