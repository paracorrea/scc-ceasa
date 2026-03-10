-- SCC - Flyway V4
-- Seed inicial (aproveitando a tentativa anterior - pdc -> scc)
-- Observação: no SCC não usamos "ordem" no banco (V1). Se quiser ordenar na UI, criamos campo depois (Vx).

-- =========================
-- Despesas (categorias)
-- =========================
INSERT INTO scc_despesa (codigo, nome)
VALUES
 ('FOLHA', 'FOLHA DE PAGAMENTO'),
 ('CONSUMO', 'MATERIAL DE CONSUMO'),
 ('PESSOAL_AUX', 'PESSOAL, ENCARGOS E AUXÍLIOS'),
 ('SERV_PJ', 'SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA')
ON CONFLICT (codigo) DO NOTHING;

-- =========================
-- Itens de Despesa
-- =========================
-- FOLHA
INSERT INTO scc_item_despesa (despesa_id, nome, ativo)
SELECT d.id, x.nome, true
FROM scc_despesa d
JOIN (VALUES
 ('ASSISTENTE EM GESTÃO'),
 ('CONFERENTE'),
 ('MOTORISTA'),
 ('OPERADOR DE CARGA'),
 ('TÉCNICO DE NUTRIÇÃO'),
 ('TÉCNICO EM SEGURANÇA DO TRABALHO')
) AS x(nome) ON true
WHERE d.codigo = 'FOLHA'
  AND NOT EXISTS (
    SELECT 1 FROM scc_item_despesa i WHERE i.despesa_id = d.id AND i.nome = x.nome
  );

-- CONSUMO
INSERT INTO scc_item_despesa (despesa_id, nome, ativo)
SELECT d.id, x.nome, true
FROM scc_despesa d
JOIN (VALUES
 ('COMBUSTÍVEIS E LUBRIFICANTES AUTOMOTIVOS'),
 ('MATERIAL PARA MANUTENÇÃO VEÍCULOS'),
 ('MATERIAL DE ESCRITÓRIO'),
 ('MATERIAL DE LIMPEZA E PRODUTOS DE HIGIENIZAÇÃO'),
 ('MATERIAL PARA MANUTENÇÃO DE BENS IMÓVEIS/INSTALAÇÕES'),
 ('MATERIAL PARA MANUTENÇÃO DE BENS MÓVEIS'),
 ('MATERIAL PARA MANUTENÇÃO EQUIPAMENTOS'),
 ('MATERIAL PARA MANUTENÇÃO DE UTENSÍLIOS')
) AS x(nome) ON true
WHERE d.codigo = 'CONSUMO'
  AND NOT EXISTS (
    SELECT 1 FROM scc_item_despesa i WHERE i.despesa_id = d.id AND i.nome = x.nome
  );

-- PESSOAL_AUX
INSERT INTO scc_item_despesa (despesa_id, nome, ativo)
SELECT d.id, x.nome, true
FROM scc_despesa d
JOIN (VALUES
 ('AUXÍLIO ALIMENTAÇÃO'),
 ('AUXÍLIO REFEIÇÃO'),
 ('AUXÍLIO SAÚDE'),
 ('AUXÍLIO TRANSPORTE'),
 ('ENCARGOS SOCIAIS')
) AS x(nome) ON true
WHERE d.codigo = 'PESSOAL_AUX'
  AND NOT EXISTS (
    SELECT 1 FROM scc_item_despesa i WHERE i.despesa_id = d.id AND i.nome = x.nome
  );

-- SERV_PJ
INSERT INTO scc_item_despesa (despesa_id, nome, ativo)
SELECT d.id, x.nome, true
FROM scc_despesa d
JOIN (VALUES
 ('LOCAÇÃO DE EQUIPAMENTOS'),
 ('MANUTENÇÃO DE VEÍCULOS'),
 ('SERVIÇOS DE TELEFONIA E INTERNET'),
 ('SERVIÇOS GRÁFICOS')
) AS x(nome) ON true
WHERE d.codigo = 'SERV_PJ'
  AND NOT EXISTS (
    SELECT 1 FROM scc_item_despesa i WHERE i.despesa_id = d.id AND i.nome = x.nome
  );

-- =========================
-- Documentos aceitos (equivalente a "tipo_documento" do legado)
-- =========================
INSERT INTO scc_documento_aceito (codigo, nome, campos_obrigatorios, ativo)
VALUES
 ('CUPOM_FISCAL', 'CUPOM FISCAL', true, true),
 ('FATURA', 'FATURA', true, true),
 ('GUIA_RECOLHIMENTO', 'GUIA DE RECOLHIMENTO', true, true),
 ('HOLLERITH', 'HOLLERITH', true, true),
 ('NOTA_FISCAL', 'NOTA FISCAL', true, true),
 ('OUTROS', 'OUTROS', true, true),
 ('RECIBO_LOCACAO', 'RECIBO DE LOCAÇÃO', true, true),
 ('RECIBO_PAG_AUTONOMO', 'RECIBO DE PAGAMENTO AUTÔNOMO', true, true),
 ('RECIBO_TAXI', 'RECIBO DE TAXI', true, true),
 ('RECIBO_VT', 'RECIBO DE VALE TRANSPORTE', true, true),
 ('RPA', 'RPA - RECIBO PAGAMENTO AUTÔNOMO', true, true),
 ('TERMO_RESCISAO', 'TERMO DE RESCISÃO', true, true)
ON CONFLICT (codigo) DO NOTHING;

-- =========================
-- Fornecedores (exemplos)
-- =========================
-- Observação: "documento" pode ser CPF/CNPJ. "OUTROS" fica com documento NULL.
INSERT INTO scc_fornecedor (razao_social, documento, tipo_fornecedor, ativo)
VALUES
  ('COLABORADOR - EXEMPLO', '123.456.789-00', 'PESSOA', true),
  ('EMPRESA - EXEMPLO LTDA', '12.345.678/0001-99', 'EMPRESA', true),
  ('OUTROS / GENÉRICO', NULL, 'OUTROS', true)
ON CONFLICT DO NOTHING;
