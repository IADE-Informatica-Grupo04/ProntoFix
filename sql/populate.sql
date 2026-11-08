-- ============================================================
--  ProntoFix — populate.sql
--  Grupo 04 · Dispositivos Móveis · IADE / Universidade Europeia
-- ============================================================
--  Os IDs são previsíveis (as tabelas são esvaziadas no início),
--  por isso os parâmetros de queries.sql (@cliente_id = 1,
--  @tecnico_id = 1, @utilizador_id = 1, @categoria_id = 1) funcionam.
--
--  Resumo dos dados:
--    17 utilizadores : 5 clientes, 11 técnicos, 1 admin
--    11 técnicos     : 6 cobrem Eletricidade/Canalização (casos de atribuição),
--                      os restantes cobrem Pintura, Limpeza, Serralharia, Carpintaria
--    23 pedidos      : 11 concluídos, 1 em curso, 1 a caminho, 1 atribuído,
--                      1 no local, 4 criados (à espera), 2 cancelados
--    11 avaliações   : 1 a 5 estrelas, todas em pedidos concluídos
--    14 notificações : lidas e por ler, para clientes, técnicos e admin
--
--  Todas as datas são relativas a NOW(), por isso as consultas
--  "de hoje" (Q16) e "tempo em espera" (Q06) fazem sentido
--  em qualquer altura (o pedido 7 fica sempre concluído "hoje").
-- ============================================================

USE prontofix;

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ─────────────────────────────────────────────
--  0. LIMPEZA (torna o script repetível e os IDs previsíveis)
--     Comenta este bloco se NÃO quiseres apagar dados existentes.
-- ─────────────────────────────────────────────
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notificacao;
TRUNCATE TABLE avaliacao;
TRUNCATE TABLE pedido;
TRUNCATE TABLE tecnico;
TRUNCATE TABLE cliente;
TRUNCATE TABLE utilizador;
TRUNCATE TABLE categoria_servico;
SET FOREIGN_KEY_CHECKS = 1;

-- ─────────────────────────────────────────────
--  1. CATEGORIAS DE SERVIÇO
--     preco_base = base da estimativa de preço
--     IDs: 1 Eletricidade · 2 Canalização · 3 Pintura
--          4 Carpintaria · 5 Limpeza · 6 Serralharia
-- ─────────────────────────────────────────────
INSERT INTO categoria_servico (nome, icone_url, preco_base) VALUES
    ('Eletricidade',  NULL, 50.00),
    ('Canalização',   NULL, 45.00),
    ('Pintura',       NULL, 55.00),
    ('Carpintaria',   NULL, 55.00),
    ('Limpeza',       NULL, 35.00),
    ('Serralharia',   NULL, 60.00);

-- ─────────────────────────────────────────────
--  2. UTILIZADORES  (palavra-passe de todos: Teste123, bcrypt)
--     IDs 1-6 mantêm-se iguais à versão anterior.
--       1 João (cliente) · 2 Ana (cliente) · 3 Carlos · 4 Sergio · 5 António
--       6 Admin · 7 Marta (cliente) · 8 Ricardo (cliente) · 9 Beatriz (cliente)
--       10-17 técnicos novos
--     Só os clientes têm localização base; a dos técnicos está na tabela tecnico.
-- ─────────────────────────────────────────────
INSERT INTO utilizador
(nome, email, password_hash, telefone, latitude, longitude, tipo)
VALUES
('João Silva',        'joao@email.com',      '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '912345678', 38.7223, -9.1393, 'cliente'),  -- 1
('Ana Costa',         'ana@email.com',       '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '923456789', 41.1579, -8.6291, 'cliente'),  -- 2
('Carlos Mendes',     'carlos@email.com',    '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '954567890', NULL,    NULL,    'tecnico'),  -- 3
('Sergio Mendes',     'sergio@email.com',    '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '964567890', NULL,    NULL,    'tecnico'),  -- 4
('António Gonçalves', 'antonio@email.com',   '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '974567890', NULL,    NULL,    'tecnico'),  -- 5
('Admin ProntoFix',   'admin@prontofix.com', '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '900000000', NULL,    NULL,    'admin'),    -- 6
('Marta Ferreira',    'marta@email.com',     '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '931234567', 38.7369, -9.1427, 'cliente'),  -- 7
('Ricardo Oliveira',  'ricardo@email.com',   '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '932345678', 41.1469, -8.6051, 'cliente'),  -- 8
('Beatriz Almeida',   'beatriz@email.com',   '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '933456789', 40.2115, -8.4292, 'cliente'),  -- 9
('Miguel Rocha',      'miguel@email.com',    '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965111111', NULL,    NULL,    'tecnico'),  -- 10
('Tiago Lopes',       'tiago@email.com',     '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965222222', NULL,    NULL,    'tecnico'),  -- 11
('Rui Pereira',       'rui@email.com',       '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965333333', NULL,    NULL,    'tecnico'),  -- 12
('Helena Matos',      'helena@email.com',    '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965444444', NULL,    NULL,    'tecnico'),  -- 13
('Fábio Dias',        'fabio@email.com',     '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965555555', NULL,    NULL,    'tecnico'),  -- 14
('Sofia Ramos',       'sofia@email.com',     '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965666666', NULL,    NULL,    'tecnico'),  -- 15
('Nuno Teixeira',     'nuno@email.com',      '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965777777', NULL,    NULL,    'tecnico'),  -- 16
('Paulo Carvalho',    'paulo@email.com',     '$2b$10$ok/exshmY2/XZ40oE5xI4e9sh/nbxgpxZoLJ3VUGmV27HjwcL4ddO', '965888888', NULL,    NULL,    'tecnico');  -- 17

-- ─────────────────────────────────────────────
--  3. CLIENTES   (cliente.id: 1 João · 2 Ana · 3 Marta · 4 Ricardo · 5 Beatriz)
--     Beatriz nunca faz pedidos → testa Q17 (NOT EXISTS).
-- ─────────────────────────────────────────────
INSERT INTO cliente (utilizador_id, morada) VALUES
(1, 'Rua das Flores, Lisboa'),
(2, 'Avenida Central, Porto'),
(7, 'Avenida da República, Lisboa'),
(8, 'Rua de Santa Catarina, Porto'),
(9, 'Rua Ferreira Borges, Coimbra');

-- ─────────────────────────────────────────────
--  4. TÉCNICOS
--     A especialidade tem de ser igual ao nome da categoria (é assim que a API
--     atribui pedidos). Localização = posição atual do prestador.
--     avaliacao_media coincide com a média real das avaliações (ver secção 6),
--     para a verificação Q33 devolver 0 linhas.
--
--     id  nome      especialidade  cidade    disponível  casos de teste
--     1   Carlos    Eletricidade   Lisboa    sim         ocupado (pedido 16) e com serviço concluído hoje
--     2   Sergio    Canalização    Porto     sim         ocupado (pedido 2, em curso)
--     3   António   Canalização    Lisboa    sim         livre, avaliações más (média 2.00)
--     4   Miguel    Eletricidade   Lisboa    sim         livre, o mais próximo de @lat/@lng
--     5   Tiago     Eletricidade   Cascais   sim         livre, mais longe (~23 km)
--     6   Rui       Eletricidade   Lisboa    NÃO         muito perto, mas indisponível
--     7   Helena    Eletricidade   —         sim         sem localização (excluída da atribuição)
--     8   Fábio     Pintura        Lisboa    sim         ocupado (pedido 17), só 1 avaliação
--     9   Sofia     Limpeza        Porto     sim         livre, 2 avaliações boas
--     10  Nuno      Serralharia    Lisboa    sim         ocupado (pedido 18)
--     11  Paulo     Carpintaria    Porto     sim         nunca trabalhou (sem avaliação)
-- ─────────────────────────────────────────────
INSERT INTO tecnico
(utilizador_id, especialidade, avaliacao_media, disponivel, foto_url, latitude, longitude, localizacao_em)
VALUES
( 3, 'Eletricidade', 4.50, 1, 'https://exemplo.prontofix.pt/fotos/carlos.jpg', 38.7300, -9.1400, NOW() - INTERVAL 2 MINUTE),
( 4, 'Canalização',  5.00, 1, NULL,                                            41.1496, -8.6109, NOW() - INTERVAL 5 MINUTE),
( 5, 'Canalização',  2.00, 1, NULL,                                            38.7580, -9.1530, NOW() - INTERVAL 1 MINUTE),
(10, 'Eletricidade', 4.50, 1, 'https://exemplo.prontofix.pt/fotos/miguel.jpg', 38.7480, -9.1550, NOW() - INTERVAL 3 MINUTE),
(11, 'Eletricidade', NULL, 1, NULL,                                            38.6979, -9.4215, NOW() - INTERVAL 8 MINUTE),
(12, 'Eletricidade', NULL, 0, NULL,                                            38.7350, -9.1450, NOW() - INTERVAL 3 HOUR),
(13, 'Eletricidade', NULL, 1, NULL,                                            NULL,    NULL,    NULL),
(14, 'Pintura',      4.00, 1, NULL,                                            38.7100, -9.1300, NOW() - INTERVAL 4 MINUTE),
(15, 'Limpeza',      4.50, 1, NULL,                                            41.1650, -8.6300, NOW() - INTERVAL 6 MINUTE),
(16, 'Serralharia',  NULL, 1, NULL,                                            38.7800, -9.1100, NOW() - INTERVAL 2 MINUTE),
(17, 'Carpintaria',  NULL, 1, NULL,                                            41.1400, -8.6000, NOW() - INTERVAL 10 MINUTE);

-- ─────────────────────────────────────────────
--  5. PEDIDOS
--     Estados: criado | atribuido | a_caminho | no_local | em_curso | concluido | cancelado
--     preco_final e concluido_em só existem em pedidos concluídos.
--     Cada técnico tem no máximo 1 serviço ativo (Q32 devolve 0 linhas).
--
--     id  cliente  técnico  categoria     estado      nota
--     1   João     Carlos   Eletricidade  concluido   (original)
--     2   Ana      Sergio   Canalização   em_curso    (original)
--     3   João     —        Pintura       criado      (original; é o MIN(id) "criado" usado no Q34)
--     4   Marta    Carlos   Eletricidade  concluido   acima da média da categoria
--     5   João     Miguel   Eletricidade  concluido
--     6   Marta    Miguel   Eletricidade  concluido   o mais caro da categoria (+40 € vs estimativa)
--     7   João     Carlos   Eletricidade  concluido   HOJE, sem avaliação (Q16, Q19)
--     8   Ana      Sergio   Canalização   concluido   acima da média da categoria
--     9   Ricardo  Sergio   Canalização   concluido
--    10   Marta    António  Canalização   concluido   preço final < estimativa
--    11   Marta    António  Canalização   concluido
--    12   Marta    Fábio    Pintura       concluido
--    13   Ana      Sofia    Limpeza       concluido
--    14   Ana      Sofia    Limpeza       concluido
--    15   Marta    Nuno     Serralharia   concluido   sem avaliação (Q19)
--    16   João     Carlos   Eletricidade  a_caminho
--    17   Marta    Fábio    Pintura       atribuido
--    18   João     Nuno     Serralharia   no_local
--    19   Marta    —        Eletricidade  criado      à espera há 4 min
--    20   Ana      —        Limpeza       criado      à espera há 35 min
--    21   Ricardo  —        Canalização   criado      à espera há 2 h
--    22   João     —        Carpintaria   cancelado   antes de ser atribuído
--    23   João     Miguel   Eletricidade  cancelado   depois de atribuído
-- ─────────────────────────────────────────────
-- Conclusão do pedido 7: "há ~3 h", mas nunca antes das 00:01 de hoje nem no futuro,
-- para o Q16 (serviços/ganhos de hoje) funcionar a qualquer hora do dia.
SET @p7_fim = LEAST(NOW(), GREATEST(NOW() - INTERVAL 3 HOUR, TIMESTAMP(CURDATE()) + INTERVAL 1 MINUTE));

INSERT INTO pedido
(cliente_id, tecnico_id, categoria_id, descricao, foto_url, morada, latitude, longitude,
 estado, preco_estimado, tempo_estimado_min, preco_final, codigo_qr, criado_em, concluido_em)
VALUES
-- 1
(1, 1, 1, 'Tomada da sala deixou de funcionar e precisa de reparação', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'concluido', 45.00, 15, 50.00, 'a0000000-0000-4000-8000-000000000001',
    NOW() - INTERVAL 2 DAY, NOW() - INTERVAL 2 DAY + INTERVAL 60 MINUTE),
-- 2
(2, 2, 2, 'Fuga de água debaixo do lava-loiça', NULL,
    'Avenida Central, Porto', 41.1579, -8.6291,
    'em_curso', 80.00, 20, NULL, 'a0000000-0000-4000-8000-000000000002',
    NOW() - INTERVAL 90 MINUTE, NULL),
-- 3
(1, NULL, 3, 'Pintura de uma parede do quarto', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'criado', 60.00, NULL, NULL, 'a0000000-0000-4000-8000-000000000003',
    NOW() - INTERVAL 10 MINUTE, NULL),
-- 4
(3, 1, 1, 'Quadro elétrico dispara sempre que se liga o forno', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'concluido', 60.00, 18, 85.00, 'a0000000-0000-4000-8000-000000000004',
    NOW() - INTERVAL 5 DAY, NOW() - INTERVAL 5 DAY + INTERVAL 90 MINUTE),
-- 5
(1, 4, 1, 'Instalação de dois pontos de luz na cozinha', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'concluido', 50.00, 12, 55.00, 'a0000000-0000-4000-8000-000000000005',
    NOW() - INTERVAL 9 DAY, NOW() - INTERVAL 9 DAY + INTERVAL 45 MINUTE),
-- 6
(3, 4, 1, 'Substituição da cablagem antiga do corredor', 'https://exemplo.prontofix.pt/fotos/pedido6.jpg',
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'concluido', 70.00, 15, 110.00, 'a0000000-0000-4000-8000-000000000006',
    NOW() - INTERVAL 12 DAY, NOW() - INTERVAL 12 DAY + INTERVAL 120 MINUTE),
-- 7  (concluído hoje)
(1, 1, 1, 'Interruptor da casa de banho a fazer faíscas', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'concluido', 40.00, 10, 45.00, 'a0000000-0000-4000-8000-000000000007',
    @p7_fim - INTERVAL 60 MINUTE, @p7_fim),
-- 8
(2, 2, 2, 'Esquentador sem água quente', NULL,
    'Avenida Central, Porto', 41.1579, -8.6291,
    'concluido', 80.00, 20, 95.00, 'a0000000-0000-4000-8000-000000000008',
    NOW() - INTERVAL 3 DAY, NOW() - INTERVAL 3 DAY + INTERVAL 75 MINUTE),
-- 9
(4, 2, 2, 'Torneira da cozinha a pingar', NULL,
    'Rua de Santa Catarina, Porto', 41.1469, -8.6051,
    'concluido', 50.00, 15, 60.00, 'a0000000-0000-4000-8000-000000000009',
    NOW() - INTERVAL 7 DAY, NOW() - INTERVAL 7 DAY + INTERVAL 50 MINUTE),
-- 10
(3, 3, 2, 'Desentupimento de sanita', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'concluido', 70.00, 15, 65.00, 'a0000000-0000-4000-8000-000000000010',
    NOW() - INTERVAL 4 DAY, NOW() - INTERVAL 4 DAY + INTERVAL 80 MINUTE),
-- 11
(3, 3, 2, 'Substituição do sifão do lavatório', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'concluido', 55.00, 15, 55.00, 'a0000000-0000-4000-8000-000000000011',
    NOW() - INTERVAL 11 DAY, NOW() - INTERVAL 11 DAY + INTERVAL 40 MINUTE),
-- 12
(3, 8, 3, 'Pintura da sala e do corredor', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'concluido', 120.00, 25, 140.00, 'a0000000-0000-4000-8000-000000000012',
    NOW() - INTERVAL 6 DAY, NOW() - INTERVAL 6 DAY + INTERVAL 300 MINUTE),
-- 13
(2, 9, 5, 'Limpeza geral de apartamento T2', NULL,
    'Avenida Central, Porto', 41.1579, -8.6291,
    'concluido', 35.00, 20, 35.00, 'a0000000-0000-4000-8000-000000000013',
    NOW() - INTERVAL 8 DAY, NOW() - INTERVAL 8 DAY + INTERVAL 180 MINUTE),
-- 14
(2, 9, 5, 'Limpeza pós-obra da cozinha', NULL,
    'Avenida Central, Porto', 41.1579, -8.6291,
    'concluido', 40.00, 20, 38.00, 'a0000000-0000-4000-8000-000000000014',
    NOW() - INTERVAL 1 DAY, NOW() - INTERVAL 1 DAY + INTERVAL 150 MINUTE),
-- 15
(3, 10, 6, 'Substituição da fechadura da porta de entrada', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'concluido', 90.00, 25, 100.00, 'a0000000-0000-4000-8000-000000000015',
    NOW() - INTERVAL 10 DAY, NOW() - INTERVAL 10 DAY + INTERVAL 70 MINUTE),
-- 16
(1, 1, 1, 'Candeeiro da sala sem luz, suspeita de curto-circuito', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'a_caminho', 55.00, 12, NULL, 'a0000000-0000-4000-8000-000000000016',
    NOW() - INTERVAL 25 MINUTE, NULL),
-- 17
(3, 8, 3, 'Pintar o teto da casa de banho (humidade)', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'atribuido', 65.00, 22, NULL, 'a0000000-0000-4000-8000-000000000017',
    NOW() - INTERVAL 15 MINUTE, NULL),
-- 18
(1, 10, 6, 'Porta da varanda encravada, precisa de ajuste', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'no_local', 70.00, 18, NULL, 'a0000000-0000-4000-8000-000000000018',
    NOW() - INTERVAL 70 MINUTE, NULL),
-- 19
(3, NULL, 1, 'Tomadas da sala sem corrente', NULL,
    'Avenida da República, Lisboa', 38.7369, -9.1427,
    'criado', 55.00, NULL, NULL, 'a0000000-0000-4000-8000-000000000019',
    NOW() - INTERVAL 4 MINUTE, NULL),
-- 20
(2, NULL, 5, 'Limpeza de escritório', NULL,
    'Avenida Central, Porto', 41.1579, -8.6291,
    'criado', 35.00, NULL, NULL, 'a0000000-0000-4000-8000-000000000020',
    NOW() - INTERVAL 35 MINUTE, NULL),
-- 21
(4, NULL, 2, 'Cano partido na casa de banho', 'https://exemplo.prontofix.pt/fotos/pedido21.jpg',
    'Rua de Santa Catarina, Porto', 41.1469, -8.6051,
    'criado', 60.00, NULL, NULL, 'a0000000-0000-4000-8000-000000000021',
    NOW() - INTERVAL 2 HOUR, NULL),
-- 22
(1, NULL, 4, 'Montagem de roupeiro embutido', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'cancelado', 70.00, NULL, NULL, 'a0000000-0000-4000-8000-000000000022',
    NOW() - INTERVAL 6 DAY, NULL),
-- 23
(1, 4, 1, 'Instalação de ventoinha no teto', NULL,
    'Rua das Flores, Lisboa', 38.7223, -9.1393,
    'cancelado', 50.00, 14, NULL, 'a0000000-0000-4000-8000-000000000023',
    NOW() - INTERVAL 3 DAY, NULL);

-- ─────────────────────────────────────────────
--  6. AVALIAÇÕES  (só em pedidos concluídos; no máximo 1 por pedido)
--     Distribuição: 5★ ×5 · 4★ ×4 · 3★ ×1 · 1★ ×1
--     Média por técnico (bate com tecnico.avaliacao_media):
--       Carlos 4.50 (2) · Sergio 5.00 (2) · António 2.00 (2) · Miguel 4.50 (2)
--       Fábio 4.00 (1)  · Sofia 4.50 (2)
--     Pedidos concluídos SEM avaliação: 7 e 15
-- ─────────────────────────────────────────────
INSERT INTO avaliacao
(pedido_id, cliente_id, tecnico_id, estrelas, comentario, criado_em)
VALUES
( 1, 1, 1, 5, 'Excelente serviço, técnico muito profissional e resolveu o problema rapidamente.', NOW() - INTERVAL 2 DAY + INTERVAL 2 HOUR),
( 4, 3, 1, 4, 'Bom trabalho, apenas demorou um pouco mais do que o previsto.',                    NOW() - INTERVAL 5 DAY + INTERVAL 3 HOUR),
( 5, 1, 4, 5, 'Rápido, simpático e deixou tudo limpo.',                                          NOW() - INTERVAL 9 DAY + INTERVAL 2 HOUR),
( 6, 3, 4, 4, 'Trabalho bem feito, mas o preço final ficou acima da estimativa.',                NOW() - INTERVAL 12 DAY + INTERVAL 4 HOUR),
( 8, 2, 2, 5, 'Voltei a ter água quente no mesmo dia. Recomendo.',                               NOW() - INTERVAL 3 DAY + INTERVAL 2 HOUR),
( 9, 4, 2, 5, NULL,                                                                              NOW() - INTERVAL 7 DAY + INTERVAL 1 HOUR),
(10, 3, 3, 1, 'Chegou muito atrasado e o problema voltou a aparecer.',                           NOW() - INTERVAL 4 DAY + INTERVAL 3 HOUR),
(11, 3, 3, 3, 'Resolveu, mas sem grande cuidado com a limpeza do local.',                        NOW() - INTERVAL 11 DAY + INTERVAL 2 HOUR),
(12, 3, 8, 4, 'Boa pintura. Faltou apenas um retoque num canto.',                                NOW() - INTERVAL 6 DAY + INTERVAL 6 HOUR),
(13, 2, 9, 5, 'A casa ficou impecável.',                                                         NOW() - INTERVAL 8 DAY + INTERVAL 4 HOUR),
(14, 2, 9, 4, 'Muito bom, ainda ficaram alguns vestígios de pó.',                                NOW() - INTERVAL 1 DAY + INTERVAL 3 HOUR);

-- ─────────────────────────────────────────────
--  7. NOTIFICAÇÕES
--     Utilizador 1 (João) tem 3 por ler → Q07 devolve 3 linhas e o Q40 marca-as como lidas.
-- ─────────────────────────────────────────────
INSERT INTO notificacao
(utilizador_id, titulo, mensagem, lida, enviada_em)
VALUES
-- João (utilizador 1)
(1,  'Pedido concluído',      'O teu serviço de eletricidade foi concluído com sucesso.',               0, NOW() - INTERVAL 3 HOUR),
(1,  'Técnico a caminho',     'O Carlos Mendes está a caminho da tua morada.',                          0, NOW() - INTERVAL 20 MINUTE),
(1,  'Avalia o teu serviço',  'Como correu o serviço de eletricidade? Deixa a tua avaliação.',          0, NOW() - INTERVAL 2 HOUR),
(1,  'Pedido cancelado',      'O teu pedido de instalação de ventoinha foi cancelado.',                 1, NOW() - INTERVAL 3 DAY),
-- Ana (utilizador 2)
(2,  'Pedido em progresso',   'O técnico já iniciou o serviço solicitado.',                             1, NOW() - INTERVAL 80 MINUTE),
(2,  'Pedido recebido',       'Estamos a procurar um prestador para o teu pedido de limpeza.',          0, NOW() - INTERVAL 35 MINUTE),
-- Marta (utilizador 7)
(7,  'Técnico atribuído',     'O Fábio Dias foi atribuído ao teu pedido de pintura.',                   0, NOW() - INTERVAL 14 MINUTE),
-- Ricardo (utilizador 8)
(8,  'Pedido recebido',       'Estamos a procurar um prestador para o teu pedido de canalização.',      1, NOW() - INTERVAL 2 HOUR),
-- Técnicos
(3,  'Novo serviço',          'Foi atribuído um novo pedido de eletricidade.',                          0, NOW() - INTERVAL 25 MINUTE),
(4,  'Serviço em curso',      'Tens um serviço de canalização em curso no Porto.',                      1, NOW() - INTERVAL 90 MINUTE),
(14, 'Novo serviço',          'Foi atribuído um novo pedido de pintura.',                               0, NOW() - INTERVAL 15 MINUTE),
(16, 'Chegada confirmada',    'A tua chegada ao local do pedido 18 foi confirmada.',                    1, NOW() - INTERVAL 60 MINUTE),
(10, 'Pedido cancelado',      'O cliente cancelou o pedido de instalação de ventoinha.',                1, NOW() - INTERVAL 3 DAY),
-- Admin
(6,  'Pedidos em espera',     'Existem 4 pedidos à espera de prestador.',                               0, NOW() - INTERVAL 5 MINUTE);
