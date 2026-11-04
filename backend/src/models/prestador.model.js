const db = require('../config/db');

// Técnico livre, da categoria certa, mais próximo (Haversine em km: funciona em qualquer versão do MySQL/MariaDB)
exports.maisProximo = async (categoriaId, lat, lng) => {
  const [rows] = await db.execute(
    `SELECT t.id,
            6371 * 2 * ASIN(SQRT(
              POWER(SIN(RADIANS(t.latitude - ?) / 2), 2) +
              COS(RADIANS(?)) * COS(RADIANS(t.latitude)) *
              POWER(SIN(RADIANS(t.longitude - ?) / 2), 2)
            )) AS distancia_km
       FROM tecnico t
       JOIN categoria_servico c ON c.id = ? AND t.especialidade = c.nome
      WHERE t.disponivel = 1
        AND t.latitude IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM pedido p
                         WHERE p.tecnico_id = t.id
                           AND p.estado IN ('atribuido','a_caminho','no_local','em_curso'))
      ORDER BY distancia_km ASC
      LIMIT 1`,
    [lat, lat, lng, categoriaId]
  );
  return rows[0] || null;
};

exports.definirDisponibilidade = (id, disponivel) =>
  db.execute('UPDATE tecnico SET disponivel = ? WHERE id = ?', [disponivel ? 1 : 0, id]);

exports.atualizarLocalizacao = (id, lat, lng) =>
  db.execute('UPDATE tecnico SET latitude = ?, longitude = ?, localizacao_em = NOW() WHERE id = ?', [lat, lng, id]);