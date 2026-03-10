-- SCC - Flyway V6
-- Popula a coluna "ordem" com base nos seeds legados (PDC -> SCC)
-- Observação: baseado em nomes. Se você alterar nomes, ajuste este script.

-- =========================
-- Ordem das Despesas (categorias)
-- =========================
UPDATE scc_despesa
SET ordem = CASE codigo
  WHEN 'FOLHA' THEN 10
  WHEN 'CONSUMO' THEN 20
  WHEN 'PESSOAL_AUX' THEN 30
  WHEN 'SERV_PJ' THEN 40
  ELSE ordem
END
WHERE codigo IN ('FOLHA','CONSUMO','PESSOAL_AUX','SERV_PJ');

-- =========================
-- Ordem dos Itens por Categoria
-- =========================

-- FOLHA
UPDATE scc_item_despesa i
SET ordem = x.ordem
FROM scc_despesa d
JOIN (VALUES
 ('ASSISTENTE EM GESTÃO', 10),
 ('CONFERENTE', 20),
 ('MOTORISTA', 30),
 ('OPERADOR DE CARGA', 40),
 ('TÉCNICO DE NUTRIÇÃO', 50),
 ('TÉCNICO EM SEGURANÇA DO TRABALHO', 60)
) AS x(nome, ordem) ON true
WHERE i.despesa_id = d.id
  AND d.codigo = 'FOLHA'
  AND i.nome = x.nome;

-- CONSUMO
UPDATE scc_item_despesa i
SET ordem = x.ordem
FROM scc_despesa d
JOIN (VALUES
 ('COMBUSTÍVEIS E LUBRIFICANTES AUTOMOTIVOS', 10),
 ('MATERIAL PARA MANUTENÇÃO VEÍCULOS', 20),
 ('MATERIAL DE ESCRITÓRIO', 30),
 ('MATERIAL DE LIMPEZA E PRODUTOS DE HIGIENIZAÇÃO', 40),
 ('MATERIAL PARA MANUTENÇÃO DE BENS IMÓVEIS/INSTALAÇÕES', 50),
 ('MATERIAL PARA MANUTENÇÃO DE BENS MÓVEIS', 60),
 ('MATERIAL PARA MANUTENÇÃO EQUIPAMENTOS', 70),
 ('MATERIAL PARA MANUTENÇÃO DE UTENSÍLIOS', 80)
) AS x(nome, ordem) ON true
WHERE i.despesa_id = d.id
  AND d.codigo = 'CONSUMO'
  AND i.nome = x.nome;

-- PESSOAL_AUX
UPDATE scc_item_despesa i
SET ordem = x.ordem
FROM scc_despesa d
JOIN (VALUES
 ('AUXÍLIO ALIMENTAÇÃO', 10),
 ('AUXÍLIO REFEIÇÃO', 20),
 ('AUXÍLIO SAÚDE', 30),
 ('AUXÍLIO TRANSPORTE', 40),
 ('ENCARGOS SOCIAIS', 50)
) AS x(nome, ordem) ON true
WHERE i.despesa_id = d.id
  AND d.codigo = 'PESSOAL_AUX'
  AND i.nome = x.nome;

-- SERV_PJ
UPDATE scc_item_despesa i
SET ordem = x.ordem
FROM scc_despesa d
JOIN (VALUES
 ('LOCAÇÃO DE EQUIPAMENTOS', 10),
 ('MANUTENÇÃO DE VEÍCULOS', 20),
 ('SERVIÇOS DE TELEFONIA E INTERNET', 30),
 ('SERVIÇOS GRÁFICOS', 40)
) AS x(nome, ordem) ON true
WHERE i.despesa_id = d.id
  AND d.codigo = 'SERV_PJ'
  AND i.nome = x.nome;
