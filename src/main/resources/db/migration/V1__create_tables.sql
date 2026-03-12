-- SCC (Sistema de Contas de Convênio)
-- Flyway V1 - Criação das tabelas principais
-- Observação: padrão UUID + timestamps, prefixo scc_
-- Banco: PostgreSQL

-- =========================
-- Extensões
-- =========================
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- =========================
-- Funções utilitárias
-- =========================
-- (opcional) gatilho updated_at
CREATE OR REPLACE FUNCTION scc_set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================
-- Tabelas BASE (Cadastros)
-- =========================

CREATE TABLE IF NOT EXISTS scc_unidade_administrativa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome varchar(255) NOT NULL,
  sigla varchar(30),
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_scc_unidade_updated_at
BEFORE UPDATE ON scc_unidade_administrativa
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE scc_entidade_conveniada (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome varchar(255) NOT NULL,
  cnpj varchar(18) NOT NULL,
  email varchar(255),
  telefone varchar(50),
  cidade varchar(120),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_scc_entidade_cnpj UNIQUE (cnpj)
);

CREATE INDEX IF NOT EXISTS ix_scc_entidade_nome ON scc_entidade_conveniada(nome);

CREATE TRIGGER trg_scc_entidade_updated_at
BEFORE UPDATE ON scc_entidade_conveniada
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE scc_dirigente_entidade (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entidade_conveniada_id uuid NOT NULL,
  nome varchar(255) NOT NULL,
  cpf varchar(14) NOT NULL,
  cargo varchar(120),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (entidade_conveniada_id)
      REFERENCES scc_entidade_conveniada(id)
);
CREATE INDEX IF NOT EXISTS ix_scc_dirigente_entidade_id ON scc_dirigente_entidade(entidade_conveniada_id);

CREATE TRIGGER trg_scc_dirigente_updated_at
BEFORE UPDATE ON scc_dirigente_entidade
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE scc_conta_bancaria_entidade (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entidade_conveniada_id uuid NOT NULL,
  banco varchar(120) NOT NULL,
  agencia varchar(50) NOT NULL,
  numero_conta varchar(50) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  FOREIGN KEY (entidade_conveniada_id)
      REFERENCES scc_entidade_conveniada(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_conta_entidade_id ON scc_conta_bancaria_entidade(entidade_conveniada_id);

CREATE TRIGGER trg_scc_conta_updated_at
BEFORE UPDATE ON scc_conta_bancaria_entidade
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_despesa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo varchar(30) NOT NULL,
  nome varchar(255) NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_scc_despesa_codigo UNIQUE (codigo)
);

CREATE INDEX IF NOT EXISTS ix_scc_despesa_nome ON scc_despesa(nome);

CREATE TRIGGER trg_scc_despesa_updated_at
BEFORE UPDATE ON scc_despesa
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_item_despesa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  despesa_id uuid NOT NULL,
  nome varchar(255) NOT NULL,
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_item_despesa_despesa
    FOREIGN KEY (despesa_id) REFERENCES scc_despesa(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_item_despesa_despesa_id ON scc_item_despesa(despesa_id);

CREATE TRIGGER trg_scc_item_despesa_updated_at
BEFORE UPDATE ON scc_item_despesa
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_documento_aceito (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  codigo varchar(30) NOT NULL,
  nome varchar(255) NOT NULL,
  campos_obrigatorios boolean NOT NULL DEFAULT true,
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_scc_documento_codigo UNIQUE (codigo)
);

CREATE INDEX IF NOT EXISTS ix_scc_documento_nome ON scc_documento_aceito(nome);

CREATE TRIGGER trg_scc_documento_updated_at
BEFORE UPDATE ON scc_documento_aceito
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_fornecedor (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  cnpj varchar(18) NOT NULL,
  razao_social varchar(255) NOT NULL,
  nome_fantasia varchar(255),
  email varchar(255),
  telefone varchar(50),
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_scc_fornecedor_cnpj UNIQUE (cnpj)
);

CREATE INDEX IF NOT EXISTS ix_scc_fornecedor_razao ON scc_fornecedor(razao_social);

CREATE TRIGGER trg_scc_fornecedor_updated_at
BEFORE UPDATE ON scc_fornecedor
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


-- =========================
-- Plano de Trabalho / Convênio
-- =========================

CREATE TABLE IF NOT EXISTS scc_plano_trabalho (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entidade_conveniada_id uuid NOT NULL,
  edicao integer NOT NULL DEFAULT 1,
  status varchar(40) NOT NULL DEFAULT 'ATIVO',
  data_inicio date,
  data_fim date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_plano_entidade
    FOREIGN KEY (entidade_conveniada_id) REFERENCES scc_entidade_conveniada(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_plano_entidade_id ON scc_plano_trabalho(entidade_conveniada_id);

CREATE TRIGGER trg_scc_plano_updated_at
BEFORE UPDATE ON scc_plano_trabalho
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_meta_plano (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plano_trabalho_id uuid NOT NULL,
  descricao text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_meta_plano
    FOREIGN KEY (plano_trabalho_id) REFERENCES scc_plano_trabalho(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_meta_plano_id ON scc_meta_plano(plano_trabalho_id);

CREATE TRIGGER trg_scc_meta_updated_at
BEFORE UPDATE ON scc_meta_plano
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_etapa_plano (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  meta_plano_id uuid NOT NULL,
  despesa_id uuid NOT NULL,
  item_despesa_id uuid NOT NULL,
  valor numeric(14,2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_etapa_meta
    FOREIGN KEY (meta_plano_id) REFERENCES scc_meta_plano(id),
  CONSTRAINT fk_scc_etapa_despesa
    FOREIGN KEY (despesa_id) REFERENCES scc_despesa(id),
  CONSTRAINT fk_scc_etapa_item_despesa
    FOREIGN KEY (item_despesa_id) REFERENCES scc_item_despesa(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_etapa_meta_id ON scc_etapa_plano(meta_plano_id);
CREATE INDEX IF NOT EXISTS ix_scc_etapa_despesa_id ON scc_etapa_plano(despesa_id);
CREATE INDEX IF NOT EXISTS ix_scc_etapa_item_despesa_id ON scc_etapa_plano(item_despesa_id);

CREATE TRIGGER trg_scc_etapa_updated_at
BEFORE UPDATE ON scc_etapa_plano
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_convenio (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  plano_trabalho_id uuid NOT NULL,
  unidade_administrativa_id uuid NULL,
  numero varchar(60) NOT NULL,
  protocolo varchar(60),
  objeto text,
  data_assinatura date,
  data_inicio date,
  data_fim date,
  valor_total numeric(14,2) NOT NULL DEFAULT 0,
  status varchar(40) NOT NULL DEFAULT 'ATIVO',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_convenio_plano
    FOREIGN KEY (plano_trabalho_id) REFERENCES scc_plano_trabalho(id),
  CONSTRAINT fk_scc_convenio_unidade
    FOREIGN KEY (unidade_administrativa_id) REFERENCES scc_unidade_administrativa(id),
  CONSTRAINT uq_scc_convenio_numero UNIQUE (numero)
);

CREATE INDEX IF NOT EXISTS ix_scc_convenio_plano_id ON scc_convenio(plano_trabalho_id);
CREATE INDEX IF NOT EXISTS ix_scc_convenio_unidade_id ON scc_convenio(unidade_administrativa_id);

CREATE TRIGGER trg_scc_convenio_updated_at
BEFORE UPDATE ON scc_convenio
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


-- =========================
-- Segurança (Perfis/Usuários)
-- =========================

CREATE TABLE IF NOT EXISTS scc_perfil (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome varchar(60) NOT NULL,
  descricao varchar(255),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT uq_scc_perfil_nome UNIQUE (nome)
);

CREATE TRIGGER trg_scc_perfil_updated_at
BEFORE UPDATE ON scc_perfil
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_usuario (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  perfil_id uuid NOT NULL,
  nome varchar(255) NOT NULL,
  login varchar(120) NOT NULL,
  senha_hash varchar(255) NOT NULL,
  ativo boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_usuario_perfil
    FOREIGN KEY (perfil_id) REFERENCES scc_perfil(id),
  CONSTRAINT uq_scc_usuario_login UNIQUE (login)
);

CREATE INDEX IF NOT EXISTS ix_scc_usuario_perfil_id ON scc_usuario(perfil_id);

CREATE TRIGGER trg_scc_usuario_updated_at
BEFORE UPDATE ON scc_usuario
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


-- =========================
-- PRESTAÇÃO (mensal por convênio)
-- =========================

CREATE TABLE IF NOT EXISTS scc_prestacao (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  convenio_id uuid NOT NULL,
  mes_referencia date NOT NULL, -- recomenda-se sempre o 1º dia do mês
  status varchar(40) NOT NULL DEFAULT 'PENDENTE',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_prestacao_convenio
    FOREIGN KEY (convenio_id) REFERENCES scc_convenio(id),
  CONSTRAINT uq_scc_prestacao_mes UNIQUE (convenio_id, mes_referencia)
);

CREATE INDEX IF NOT EXISTS ix_scc_prestacao_convenio_id ON scc_prestacao(convenio_id);
CREATE INDEX IF NOT EXISTS ix_scc_prestacao_mes_ref ON scc_prestacao(mes_referencia);

CREATE TRIGGER trg_scc_prestacao_updated_at
BEFORE UPDATE ON scc_prestacao
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_item_prestacao (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prestacao_id uuid NOT NULL,
  fornecedor_id uuid NULL,
  item_despesa_id uuid NOT NULL,
  documento_aceito_id uuid NOT NULL,
  data_documento date NOT NULL,
  numero_documento varchar(80) NOT NULL,
  descricao text,
  valor numeric(14,2) NOT NULL DEFAULT 0,
  status varchar(40) NOT NULL DEFAULT 'PENDENTE',
  deleted_at timestamptz NULL, -- exclusão lógica
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_item_prestacao_prestacao
    FOREIGN KEY (prestacao_id) REFERENCES scc_prestacao(id),
  CONSTRAINT fk_scc_item_prestacao_fornecedor
    FOREIGN KEY (fornecedor_id) REFERENCES scc_fornecedor(id),
  CONSTRAINT fk_scc_item_prestacao_item_despesa
    FOREIGN KEY (item_despesa_id) REFERENCES scc_item_despesa(id),
  CONSTRAINT fk_scc_item_prestacao_doc_aceito
    FOREIGN KEY (documento_aceito_id) REFERENCES scc_documento_aceito(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_item_prestacao_prestacao_id ON scc_item_prestacao(prestacao_id);
CREATE INDEX IF NOT EXISTS ix_scc_item_prestacao_fornecedor_id ON scc_item_prestacao(fornecedor_id);
CREATE INDEX IF NOT EXISTS ix_scc_item_prestacao_item_despesa_id ON scc_item_prestacao(item_despesa_id);
CREATE INDEX IF NOT EXISTS ix_scc_item_prestacao_doc_aceito_id ON scc_item_prestacao(documento_aceito_id);
CREATE INDEX IF NOT EXISTS ix_scc_item_prestacao_num_doc ON scc_item_prestacao(numero_documento);

CREATE TRIGGER trg_scc_item_prestacao_updated_at
BEFORE UPDATE ON scc_item_prestacao
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_anexo_item (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_prestacao_id uuid NOT NULL,
  nome_arquivo varchar(255) NOT NULL,
  content_type varchar(120),
  tamanho_bytes bigint,
  storage_key varchar(500) NOT NULL, -- caminho/identificador no storage (filesystem/S3/etc)
  checksum_sha256 varchar(80),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_anexo_item
    FOREIGN KEY (item_prestacao_id) REFERENCES scc_item_prestacao(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_anexo_item_id ON scc_anexo_item(item_prestacao_id);


-- =========================
-- HISTÓRICO (imutável)
-- =========================

CREATE TABLE IF NOT EXISTS scc_prestacao_historico (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prestacao_id uuid NOT NULL,
  evento varchar(60) NOT NULL,
  status_de varchar(40),
  status_para varchar(40),
  usuario_id uuid NULL,
  data_evento timestamptz NOT NULL DEFAULT now(),
  observacao text,
  snapshot_antes jsonb,
  snapshot_depois jsonb,
  CONSTRAINT fk_scc_prest_hist_prestacao
    FOREIGN KEY (prestacao_id) REFERENCES scc_prestacao(id),
  CONSTRAINT fk_scc_prest_hist_usuario
    FOREIGN KEY (usuario_id) REFERENCES scc_usuario(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_prest_hist_prestacao_id ON scc_prestacao_historico(prestacao_id);
CREATE INDEX IF NOT EXISTS ix_scc_prest_hist_data ON scc_prestacao_historico(data_evento);


CREATE TABLE IF NOT EXISTS scc_item_historico (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_prestacao_id uuid NOT NULL,
  evento varchar(60) NOT NULL,
  status_de varchar(40),
  status_para varchar(40),
  usuario_id uuid NULL,
  data_evento timestamptz NOT NULL DEFAULT now(),
  observacao text,
  snapshot_antes jsonb,
  snapshot_depois jsonb,
  CONSTRAINT fk_scc_item_hist_item
    FOREIGN KEY (item_prestacao_id) REFERENCES scc_item_prestacao(id),
  CONSTRAINT fk_scc_item_hist_usuario
    FOREIGN KEY (usuario_id) REFERENCES scc_usuario(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_item_hist_item_id ON scc_item_historico(item_prestacao_id);
CREATE INDEX IF NOT EXISTS ix_scc_item_hist_data ON scc_item_historico(data_evento);


-- =========================
-- RESUMO FINANCEIRO
-- =========================

CREATE TABLE IF NOT EXISTS scc_resumo_financeiro (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  prestacao_id uuid NOT NULL,
  total_prestacao numeric(14,2) NOT NULL DEFAULT 0,
  total_resumo numeric(14,2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_resumo_prestacao
    FOREIGN KEY (prestacao_id) REFERENCES scc_prestacao(id),
  CONSTRAINT uq_scc_resumo_prestacao UNIQUE (prestacao_id)
);

CREATE INDEX IF NOT EXISTS ix_scc_resumo_prestacao_id ON scc_resumo_financeiro(prestacao_id);

CREATE TRIGGER trg_scc_resumo_updated_at
BEFORE UPDATE ON scc_resumo_financeiro
FOR EACH ROW EXECUTE FUNCTION scc_set_updated_at();


CREATE TABLE IF NOT EXISTS scc_movimento_bancario (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  resumo_financeiro_id uuid NOT NULL,
  tipo_movimento varchar(40) NOT NULL, -- ENTRADA/SAIDA/RENDIMENTO/AJUSTE (definir no app; opcional criar type no V2)
  data_movimento date NOT NULL,
  descricao text,
  valor numeric(14,2) NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fk_scc_mov_resumo
    FOREIGN KEY (resumo_financeiro_id) REFERENCES scc_resumo_financeiro(id)
);

CREATE INDEX IF NOT EXISTS ix_scc_mov_resumo_id ON scc_movimento_bancario(resumo_financeiro_id);
CREATE INDEX IF NOT EXISTS ix_scc_mov_data ON scc_movimento_bancario(data_movimento);

-- =========================
-- Fim V1
-- =========================
