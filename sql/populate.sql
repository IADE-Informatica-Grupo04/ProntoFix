-- ============================================================
--  ProntoFix — populate.sql
--  Grupo 04 · Dispositivos Móveis · IADE / Universidade Europeia
-- ============================================================

USE prontofix;

-- ─────────────────────────────────────────────
--  DADOS DE EXEMPLO (opcional)
--  preco_base = base da estimativa de preço
-- ─────────────────────────────────────────────
INSERT INTO categoria_servico (nome, icone_url, preco_base) VALUES
    ('Eletricidade',  NULL, 50.00),
    ('Canalização',   NULL, 45.00),
    ('Pintura',       NULL, 55.00),
    ('Carpintaria',   NULL, 55.00),
    ('Limpeza',       NULL, 35.00),
    ('Serralharia',   NULL, 60.00);

-- ─────────────────────────────────────────────
--  OS DADOS A SEREM INSERIDOS
--  (palavra-passe de todos: Teste123, guardada com bcrypt)
-- ─────────────────────────────────────────────
INSERT INTO utilizador
(nome, email, password_hash, telefone, latitude, longitude, tipo)
VALUES
('João Silva',      'joao@email.com',      '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '912345678', 38.7223, -9.1393, 'cliente'),
('Ana Costa',       'ana@email.com',       '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '923456789', 41.1579, -8.6291, 'cliente'),
('Carlos Mendes',   'carlos@email.com',    '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '934567890', NULL,    NULL,    'tecnico'),
('Sergio Mendes',   'carlos@email.com',    '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '934567890', NULL,    NULL,    'tecnico'),
('Admin ProntoFix', 'admin@prontofix.com', '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '900000000', NULL,    NULL,    'admin');


INSERT INTO cliente
(utilizador_id, morada)
VALUES
(1, 'Rua das Flores, Lisboa'),
(2, 'Avenida Central, Porto');


-- A especialidade tem de ser igual ao nome da categoria (é assim que a API
-- atribui pedidos). A localização é a atual do prestador (Lisboa).
INSERT INTO tecnico
(utilizador_id, especialidade, avaliacao_media, disponivel, latitude, longitude, localizacao_em)
VALUES
(3, 'Eletricidade', 5.00, 1, 38.7300, -9.1400, NOW());
(4, 'Canalização', 5.00, 1, 35.7300, -8.1400, NOW());


-- Estados: criado | atribuido | a_caminho | no_local | em_curso | concluido | cancelado
-- preco_final só existe depois de concluído; antes disso há só o preco_estimado.
INSERT INTO pedido
(cliente_id, tecnico_id, categoria_id, descricao, morada, latitude, longitude,
 estado, preco_estimado, tempo_estimado_min, preco_final, codigo_qr, criado_em, concluido_em)
VALUES
(1, 1, 1, 'Tomada da sala deixou de funcionar e precisa de reparação',
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'concluido', 45.00, 15, 50.00, 'a0000000-0000-4000-8000-000000000001',
    NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY + INTERVAL 60 MINUTE),

(2, 2, 2, 'Fuga de água debaixo do lava-loiça',
    'Avenida Central, Porto', 41.1579, -8.6291,
    'em_curso', 80.00, 20, NULL, 'a0000000-0000-4000-8000-000000000002',
    NOW() - INTERVAL 90 MINUTE, NULL),

(1, NULL, 3, 'Pintura de uma parede do quarto',
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'criado', 60.00, NULL, NULL, 'a0000000-0000-4000-8000-000000000003',
    NOW() - INTERVAL 10 MINUTE, NULL);


INSERT INTO avaliacao
(pedido_id, cliente_id, tecnico_id, estrelas, comentario)
VALUES
(1, 1, 1, 5, 'Excelente serviço, técnico muito profissional e resolveu o problema rapidamente.');



INSERT INTO notificacao
(utilizador_id, titulo, mensagem, lida)
VALUES
(1, 'Pedido concluído', 'O teu serviço de eletricidade foi concluído com sucesso.', 0),

(3, 'Novo serviço', 'Foi atribuído um novo pedido de eletricidade.', 0),

(2, 'Pedido em progresso', 'O técnico já iniciou o serviço solicitado.', 1);
