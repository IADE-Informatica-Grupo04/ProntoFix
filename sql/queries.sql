-- ============================================================
--  ProntoFix — queries.sql
--  Grupo 04 · Dispositivos Móveis · IADE / Universidade Europeia
-- ============================================================

USE prontofix;

-- ============================================================
--  PARÂMETROS DE EXEMPLO
-- ============================================================
SET @cliente_id    = 1;                 -- cliente.id
SET @tecnico_id    = 1;                 -- tecnico.id
SET @utilizador_id = 1;                 -- utilizador.id
SET @categoria_id  = 1;                 -- categoria_servico.id (no populate.sql: 1 = Eletricidade, 2 = Canalização)
SET @lat           = 38.7369;           -- localização do pedido (exemplo: Lisboa)
SET @lng           = -9.1427;


-- ============================================================
--  A. CONSULTAS BÁSICAS (SELECT, JOIN, filtros)
-- ============================================================

-- Q01 · Utilizadores por tipo
SELECT tipo, COUNT(*) AS total
  FROM utilizador
 GROUP BY tipo
 ORDER BY total DESC;

-- Q02 · Prestadores disponíveis, com especialidade, avaliação e localização
SELECT t.id AS tecnico_id, u.nome, t.especialidade,
       t.avaliacao_media, t.latitude, t.longitude
  FROM tecnico t
  JOIN utilizador u ON u.id = t.utilizador_id
 WHERE t.disponivel = 1
 ORDER BY t.avaliacao_media DESC, u.nome;

-- Q03 · Visão geral de todos os pedidos (cliente, categoria, prestador)
--       LEFT JOIN no prestador: um pedido "criado" ainda não tem técnico.
SELECT p.id, p.estado, c.nome AS categoria,
       cu.nome AS cliente,
       tu.nome AS prestador,
       p.preco_estimado, p.preco_final, p.criado_em
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
  JOIN cliente cl          ON cl.id = p.cliente_id
  JOIN utilizador cu       ON cu.id = cl.utilizador_id
  LEFT JOIN tecnico t      ON t.id = p.tecnico_id
  LEFT JOIN utilizador tu  ON tu.id = t.utilizador_id
 ORDER BY p.criado_em DESC;

-- Q04 · Histórico de um cliente (os mais recentes primeiro)
SELECT p.id, p.estado, c.nome AS categoria, p.descricao,
       tu.nome AS prestador, p.preco_final, p.criado_em
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
  LEFT JOIN tecnico t      ON t.id = p.tecnico_id
  LEFT JOIN utilizador tu  ON tu.id = t.utilizador_id
 WHERE p.cliente_id = @cliente_id
 ORDER BY p.criado_em DESC;

-- Q05 · Pedidos ativos de um prestador (os que a app mostra no ecrã de trabalho)
SELECT p.id, p.estado, c.nome AS categoria, p.morada, cu.nome AS cliente, cu.telefone
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
  JOIN cliente cl          ON cl.id = p.cliente_id
  JOIN utilizador cu       ON cu.id = cl.utilizador_id
 WHERE p.tecnico_id = @tecnico_id
   AND p.estado IN ('atribuido','a_caminho','no_local','em_curso')
 ORDER BY p.criado_em;

-- Q06 · Pedidos à espera de prestador (estado "criado", sem técnico)
SELECT p.id, c.nome AS categoria, p.morada, p.criado_em,
       TIMESTAMPDIFF(MINUTE, p.criado_em, NOW()) AS minutos_em_espera
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
 WHERE p.estado = 'criado' AND p.tecnico_id IS NULL
 ORDER BY p.criado_em;

-- Q07 · Notificações por ler de um utilizador
SELECT id, titulo, mensagem, enviada_em
  FROM notificacao
 WHERE utilizador_id = @utilizador_id AND lida = 0
 ORDER BY enviada_em DESC;


-- ============================================================
--  B. AGREGAÇÕES (GROUP BY, HAVING)
-- ============================================================

-- Q08 · Número de pedidos por estado
SELECT estado, COUNT(*) AS total
  FROM pedido
 GROUP BY estado
 ORDER BY total DESC;

-- Q09 · Pedidos concluídos e receita por categoria
SELECT c.nome AS categoria,
       COUNT(p.id)                       AS pedidos_concluidos,
       COALESCE(SUM(p.preco_final), 0)   AS receita_total,
       ROUND(AVG(p.preco_final), 2)      AS preco_medio
  FROM categoria_servico c
  LEFT JOIN pedido p ON p.categoria_id = c.id AND p.estado = 'concluido'
 GROUP BY c.id, c.nome
 ORDER BY receita_total DESC;

-- Q10 · Ganhos por prestador (inclui os que ainda não concluíram nenhum serviço)
SELECT t.id AS tecnico_id, u.nome, t.especialidade,
       COUNT(p.id)                     AS servicos_concluidos,
       COALESCE(SUM(p.preco_final), 0) AS ganhos
  FROM tecnico t
  JOIN utilizador u ON u.id = t.utilizador_id
  LEFT JOIN pedido p ON p.tecnico_id = t.id AND p.estado = 'concluido'
 GROUP BY t.id, u.nome, t.especialidade
 ORDER BY ganhos DESC;

-- Q11 · Prestadores com boa avaliação: média >= 4 e pelo menos 2 avaliações (HAVING)
SELECT t.id AS tecnico_id, u.nome,
       ROUND(AVG(a.estrelas), 2) AS media_estrelas,
       COUNT(a.id)               AS n_avaliacoes
  FROM avaliacao a
  JOIN tecnico t    ON t.id = a.tecnico_id
  JOIN utilizador u ON u.id = t.utilizador_id
 GROUP BY t.id, u.nome
HAVING AVG(a.estrelas) >= 4 AND COUNT(a.id) >= 2
 ORDER BY media_estrelas DESC;

-- Q12 · Distribuição das avaliações (quantas de 1 a 5 estrelas)
SELECT estrelas, COUNT(*) AS total
  FROM avaliacao
 GROUP BY estrelas
 ORDER BY estrelas DESC;

-- Q13 · Pedidos criados por dia
SELECT DATE(criado_em) AS dia, COUNT(*) AS pedidos
  FROM pedido
 GROUP BY DATE(criado_em)
 ORDER BY dia DESC;

-- Q14 · Duração média do serviço (criação → conclusão), em minutos, por categoria
SELECT c.nome AS categoria,
       COUNT(*) AS pedidos,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, p.criado_em, p.concluido_em)), 1) AS minutos_medios
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
 WHERE p.estado = 'concluido' AND p.concluido_em IS NOT NULL
 GROUP BY c.id, c.nome
 ORDER BY minutos_medios DESC;

-- Q15 · Estimativa vs preço final: desvio médio por categoria
--       (útil para afinar a fórmula de estimativa / o método numérico)
SELECT c.nome AS categoria,
       ROUND(AVG(p.preco_estimado), 2)                  AS estimado_medio,
       ROUND(AVG(p.preco_final), 2)                     AS final_medio,
       ROUND(AVG(p.preco_final - p.preco_estimado), 2)  AS desvio_medio
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
 WHERE p.estado = 'concluido'
   AND p.preco_estimado IS NOT NULL AND p.preco_final IS NOT NULL
 GROUP BY c.id, c.nome;

-- Q16 · Resumo do dia de um prestador (o que a app mostra no ecrã inicial)
SELECT t.disponivel,
       t.avaliacao_media AS avaliacao,
       (SELECT COUNT(*) FROM pedido p
         WHERE p.tecnico_id = t.id AND p.estado = 'concluido'
           AND DATE(p.concluido_em) = CURDATE())                      AS servicos_hoje,
       (SELECT COALESCE(SUM(p.preco_final), 0) FROM pedido p
         WHERE p.tecnico_id = t.id AND p.estado = 'concluido'
           AND DATE(p.concluido_em) = CURDATE())                      AS ganhos_hoje
  FROM tecnico t
 WHERE t.id = @tecnico_id;


-- ============================================================
--  C. SUBCONSULTAS (IN, EXISTS, correlacionadas)
-- ============================================================

-- Q17 · Clientes que nunca fizeram um pedido (NOT EXISTS)
SELECT cl.id AS cliente_id, u.nome, u.email
  FROM cliente cl
  JOIN utilizador u ON u.id = cl.utilizador_id
 WHERE NOT EXISTS (SELECT 1 FROM pedido p WHERE p.cliente_id = cl.id);

-- Q18 · Prestadores sem nenhum serviço concluído
SELECT t.id AS tecnico_id, u.nome, t.especialidade
  FROM tecnico t
  JOIN utilizador u ON u.id = t.utilizador_id
 WHERE t.id NOT IN (SELECT tecnico_id FROM pedido
                     WHERE estado = 'concluido' AND tecnico_id IS NOT NULL);

-- Q19 · Pedidos concluídos ainda sem avaliação (a lembrar o cliente de avaliar)
SELECT p.id, c.nome AS categoria, cu.nome AS cliente, p.concluido_em
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
  JOIN cliente cl          ON cl.id = p.cliente_id
  JOIN utilizador cu       ON cu.id = cl.utilizador_id
  LEFT JOIN avaliacao a    ON a.pedido_id = p.id
 WHERE p.estado = 'concluido' AND a.id IS NULL
 ORDER BY p.concluido_em DESC;

-- Q20 · Pedidos concluídos acima do preço médio da sua categoria (subconsulta correlacionada)
SELECT p.id, c.nome AS categoria, p.preco_final,
       (SELECT ROUND(AVG(p2.preco_final), 2)
          FROM pedido p2
         WHERE p2.categoria_id = p.categoria_id AND p2.estado = 'concluido') AS media_da_categoria
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
 WHERE p.estado = 'concluido'
   AND p.preco_final > (SELECT AVG(p2.preco_final)
                          FROM pedido p2
                         WHERE p2.categoria_id = p.categoria_id AND p2.estado = 'concluido')
 ORDER BY p.preco_final DESC;

-- Q21 · Prestador com mais ganhos (o mais bem-sucedido)
SELECT t.id AS tecnico_id, u.nome, SUM(p.preco_final) AS ganhos
  FROM tecnico t
  JOIN utilizador u ON u.id = t.utilizador_id
  JOIN pedido p     ON p.tecnico_id = t.id AND p.estado = 'concluido'
 GROUP BY t.id, u.nome
 ORDER BY ganhos DESC
 LIMIT 1;

-- Q22 · Clientes com mais de um pedido concluído (clientes recorrentes)
SELECT cl.id AS cliente_id, u.nome, COUNT(*) AS pedidos_concluidos
  FROM cliente cl
  JOIN utilizador u ON u.id = cl.utilizador_id
  JOIN pedido p     ON p.cliente_id = cl.id AND p.estado = 'concluido'
 GROUP BY cl.id, u.nome
HAVING COUNT(*) > 1;

-- Q23 · Prestadores já avaliados por um cliente (para marcar como favoritos)
SELECT DISTINCT t.id AS tecnico_id, u.nome, t.especialidade, a.estrelas
  FROM avaliacao a
  JOIN tecnico t    ON t.id = a.tecnico_id
  JOIN utilizador u ON u.id = t.utilizador_id
 WHERE a.cliente_id = @cliente_id
 ORDER BY a.estrelas DESC;


-- ============================================================
--  D. ATRIBUIÇÃO DO PRESTADOR MAIS PRÓXIMO (usada pela API)
-- ============================================================

-- Q24 · Prestador livre, da categoria certa, mais próximo do pedido.
--       Distância pela fórmula de Haversine (km); raio da Terra = 6371 km.
--       Exclui quem não está disponível, não tem localização ou já tem um serviço ativo.
SELECT t.id AS tecnico_id, u.nome, t.especialidade,
       ROUND(6371 * 2 * ASIN(SQRT(
             POWER(SIN(RADIANS(t.latitude - @lat) / 2), 2) +
             COS(RADIANS(@lat)) * COS(RADIANS(t.latitude)) *
             POWER(SIN(RADIANS(t.longitude - @lng) / 2), 2)
       )), 2) AS distancia_km
  FROM tecnico t
  JOIN utilizador u        ON u.id = t.utilizador_id
  JOIN categoria_servico c ON c.id = @categoria_id AND t.especialidade = c.nome
 WHERE t.disponivel = 1
   AND t.latitude IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM pedido p
                    WHERE p.tecnico_id = t.id
                      AND p.estado IN ('atribuido','a_caminho','no_local','em_curso'))
 ORDER BY distancia_km ASC
 LIMIT 1;

-- Q25 · Todos os prestadores candidatos, ordenados por distância (a mesma regra do Q24,
--       mas sem LIMIT): útil para a reatribuição ao seguinte quando o primeiro não responde
SELECT t.id AS tecnico_id, u.nome,
       ROUND(6371 * 2 * ASIN(SQRT(
             POWER(SIN(RADIANS(t.latitude - @lat) / 2), 2) +
             COS(RADIANS(@lat)) * COS(RADIANS(t.latitude)) *
             POWER(SIN(RADIANS(t.longitude - @lng) / 2), 2)
       )), 2) AS distancia_km
  FROM tecnico t
  JOIN utilizador u        ON u.id = t.utilizador_id
  JOIN categoria_servico c ON c.id = @categoria_id AND t.especialidade = c.nome
 WHERE t.disponivel = 1 AND t.latitude IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM pedido p
                    WHERE p.tecnico_id = t.id
                      AND p.estado IN ('atribuido','a_caminho','no_local','em_curso'))
 ORDER BY distancia_km ASC;

-- Q26 · Estimativa de preço e tempo de chegada para o prestador elegível mais próximo
--       (fórmula provisória: preço base + 1,5 €/km; tempo a 30 km/h + 5 min)
SELECT c.nome AS categoria,
       ROUND(prox.distancia_km, 2)                                 AS distancia_km,
       ROUND(c.preco_base + prox.distancia_km * 1.5, 2)            AS preco_estimado,
       GREATEST(5, ROUND(prox.distancia_km / 30 * 60) + 5)         AS tempo_chegada_min
  FROM categoria_servico c
  JOIN (SELECT t.especialidade,
               MIN(6371 * 2 * ASIN(SQRT(
                   POWER(SIN(RADIANS(t.latitude - @lat) / 2), 2) +
                   COS(RADIANS(@lat)) * COS(RADIANS(t.latitude)) *
                   POWER(SIN(RADIANS(t.longitude - @lng) / 2), 2)))) AS distancia_km
          FROM tecnico t
         WHERE t.disponivel = 1 AND t.latitude IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM pedido p
                            WHERE p.tecnico_id = t.id
                              AND p.estado IN ('atribuido','a_caminho','no_local','em_curso'))
         GROUP BY t.especialidade) prox ON prox.especialidade = c.nome
 WHERE c.id = @categoria_id;


-- ============================================================
--  E. VISTAS (views)
-- ============================================================

-- Pedido com todos os dados juntos (evita repetir os JOIN em cada consulta)
CREATE OR REPLACE VIEW v_pedido_detalhe AS
SELECT p.id AS pedido_id, p.estado, p.criado_em, p.concluido_em,
       p.preco_estimado, p.preco_final,
       c.nome  AS categoria,
       cu.nome AS cliente,
       tu.nome AS prestador,
       a.estrelas
  FROM pedido p
  JOIN categoria_servico c ON c.id = p.categoria_id
  JOIN cliente cl          ON cl.id = p.cliente_id
  JOIN utilizador cu       ON cu.id = cl.utilizador_id
  LEFT JOIN tecnico t      ON t.id = p.tecnico_id
  LEFT JOIN utilizador tu  ON tu.id = t.utilizador_id
  LEFT JOIN avaliacao a    ON a.pedido_id = p.id;

-- Desempenho de cada prestador
CREATE OR REPLACE VIEW v_desempenho_tecnico AS
SELECT t.id AS tecnico_id, u.nome, t.especialidade,
       COUNT(CASE WHEN p.estado = 'concluido' THEN 1 END)                AS servicos_concluidos,
       COALESCE(SUM(CASE WHEN p.estado = 'concluido' THEN p.preco_final END), 0) AS ganhos,
       ROUND(AVG(a.estrelas), 2)                                         AS media_estrelas,
       COUNT(a.id)                                                       AS n_avaliacoes
  FROM tecnico t
  JOIN utilizador u ON u.id = t.utilizador_id
  LEFT JOIN pedido p    ON p.tecnico_id = t.id
  LEFT JOIN avaliacao a ON a.pedido_id = p.id
 GROUP BY t.id, u.nome, t.especialidade;

-- Q27 · Pedidos concluídos, com a vista de detalhe
SELECT * FROM v_pedido_detalhe WHERE estado = 'concluido' ORDER BY concluido_em DESC;

-- Q28 · Ranking de prestadores, com a vista de desempenho
SELECT * FROM v_desempenho_tecnico ORDER BY ganhos DESC, media_estrelas DESC;


-- ============================================================
--  F. VERIFICAÇÕES DE INTEGRIDADE (devem devolver 0 linhas)
-- ============================================================

-- Q29 · Pedido com técnico mas ainda em "criado", ou sem técnico mas já em andamento
SELECT id, estado, tecnico_id
  FROM pedido
 WHERE (estado = 'criado' AND tecnico_id IS NOT NULL)
    OR (estado IN ('atribuido','a_caminho','no_local','em_curso','concluido') AND tecnico_id IS NULL);

-- Q30 · Pedidos concluídos sem preço final ou sem data de conclusão
SELECT id, estado, preco_final, concluido_em
  FROM pedido
 WHERE estado = 'concluido' AND (preco_final IS NULL OR concluido_em IS NULL);

-- Q31 · Avaliações de pedidos que não estão concluídos
SELECT a.id, a.pedido_id, p.estado
  FROM avaliacao a
  JOIN pedido p ON p.id = a.pedido_id
 WHERE p.estado <> 'concluido';

-- Q32 · Prestadores com mais de um serviço ativo em simultâneo
SELECT tecnico_id, COUNT(*) AS servicos_ativos
  FROM pedido
 WHERE estado IN ('atribuido','a_caminho','no_local','em_curso')
   AND tecnico_id IS NOT NULL
 GROUP BY tecnico_id
HAVING COUNT(*) > 1;

-- Q33 · Prestadores cuja avaliacao_media guardada não coincide com a média real
SELECT t.id AS tecnico_id, t.avaliacao_media AS guardada,
       ROUND(AVG(a.estrelas), 2)           AS real_calculada
  FROM tecnico t
  JOIN avaliacao a ON a.tecnico_id = t.id
 GROUP BY t.id, t.avaliacao_media
HAVING t.avaliacao_media IS NULL OR t.avaliacao_media <> ROUND(AVG(a.estrelas), 2);


-- ============================================================
--  G. OPERAÇÕES DO BACKEND (INSERT / UPDATE)
--     Corre dentro de uma transação que termina em ROLLBACK:
--     mostra o efeito de cada passo, mas NÃO altera os dados.
--     Para aplicar de verdade, troca o ROLLBACK final por COMMIT.
--     Se alguma instrução falhar a meio, executa ROLLBACK; à mão para não
--     deixar a transação aberta.
-- ============================================================
START TRANSACTION;

-- Pedido de exemplo a trabalhar e um prestador livre
SET @pedido_novo = (SELECT MIN(id) FROM pedido WHERE estado = 'criado');
SET @tecnico_novo = (SELECT MIN(t.id) FROM tecnico t
                      WHERE t.disponivel = 1
                        AND NOT EXISTS (SELECT 1 FROM pedido p
                                         WHERE p.tecnico_id = t.id
                                           AND p.estado IN ('atribuido','a_caminho','no_local','em_curso')));

-- Q34 · Atribuir o pedido a um prestador (só se ainda estiver "criado": evita corridas)
UPDATE pedido
   SET tecnico_id = @tecnico_novo, estado = 'atribuido'
 WHERE id = @pedido_novo AND estado = 'criado';

-- Q35 · Transição de estado segura: só avança se o estado atual for o esperado
UPDATE pedido
   SET estado = 'a_caminho'
 WHERE id = @pedido_novo AND estado IN ('atribuido');

-- Q36 · Concluir o serviço com o valor final
UPDATE pedido
   SET estado = 'concluido', preco_final = 75.00, concluido_em = NOW()
 WHERE id = @pedido_novo AND estado IN ('no_local','em_curso');
--  (0 linhas afetadas aqui: o pedido ainda está "a_caminho"; a transição inválida é rejeitada.)

-- Q37 · Registar uma avaliação (1 por pedido concluído)
INSERT INTO avaliacao (pedido_id, cliente_id, tecnico_id, estrelas, comentario)
SELECT p.id, p.cliente_id, p.tecnico_id, 5, 'Excelente serviço'
  FROM pedido p
  LEFT JOIN avaliacao a ON a.pedido_id = p.id
 WHERE p.estado = 'concluido' AND p.tecnico_id IS NOT NULL AND a.id IS NULL
 LIMIT 1;

-- Q38 · Recalcular a avaliação média de todos os prestadores avaliados
UPDATE tecnico t
   SET t.avaliacao_media = (SELECT ROUND(AVG(a.estrelas), 2)
                              FROM avaliacao a WHERE a.tecnico_id = t.id)
 WHERE t.id > 0   -- (necessário para o "Safe Updates" do Workbench aceitar o UPDATE)
   AND EXISTS (SELECT 1 FROM avaliacao a WHERE a.tecnico_id = t.id);

-- Q39 · Cancelar um pedido antes de o serviço começar
UPDATE pedido
   SET estado = 'cancelado'
 WHERE id = @pedido_novo AND estado IN ('criado','atribuido','a_caminho','no_local');

-- Q40 · Marcar as notificações de um utilizador como lidas
UPDATE notificacao SET lida = 1 WHERE utilizador_id = @utilizador_id AND lida = 0;

-- Estado do pedido de exemplo dentro da transação
-- (acaba "cancelado" porque o último passo (Q39) o cancela)
SELECT id, estado, tecnico_id FROM pedido WHERE id = @pedido_novo;

ROLLBACK;
