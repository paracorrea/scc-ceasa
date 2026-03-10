-- SCC - Flyway V2 - Seed de dados mínimos (Perfis)
INSERT INTO scc_perfil (nome, descricao)
VALUES
  ('OPERADOR', 'Usuário que lança itens e anexa documentos enquanto a prestação está PENDENTE'),
  ('ANALISTA', 'Usuário que analisa itens em EM_ANALISE, podendo aprovar, glosar ou solicitar correção'),
  ('GESTOR',   'Usuário financeiro que pode fechar a prestação e registrar o resumo financeiro')
ON CONFLICT (nome) DO NOTHING;
