// src/models/pedido.model.js
const db = require('../config/db');

const BASE = `
  SELECT p.*, c.nome AS categoria,
         cu.nome AS cliente_nome,
         tu.nome AS prestador_nome, t.avaliacao_media AS prestador_avaliacao,
         t.latitude AS prestador_latitude, t.longitude AS prestador_longitude
    FROM pedido p
    JOIN categoria_servico c ON c.id = p.categoria_id
    JOIN cliente cl          ON cl.id = p.cliente_id
    JOIN utilizador cu       ON cu.id = cl.utilizador_id
    LEFT JOIN tecnico t      ON t.id = p.tecnico_id
    LEFT JOIN utilizador tu  ON tu.id = t.utilizador_id`;

exports.criar = async (p) => {
  const [r] = await db.execute(
    `INSERT INTO pedido (cliente_id, categoria_id, descricao, morada, latitude, longitude,
                         foto_url, preco_estimado, tempo_estimado_min, codigo_qr)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [p.cliente_id, p.categoria_id, p.descricao, p.morada, p.latitude, p.longitude,
     p.foto_url, p.preco_estimado, p.tempo_estimado_min, p.codigo_qr]
  );
  return r.insertId;
};

exports.obter = async (id) => {
  const [rows] = await db.execute(`${BASE} WHERE p.id = ?`, [id]);
  return rows[0] || null;
};

exports.listarDoCliente = async (clienteId) => {
  const [rows] = await db.execute(`${BASE} WHERE p.cliente_id = ? ORDER BY p.criado_em DESC`, [clienteId]);
  return rows;
};

exports.listarDoPrestador = async (tecnicoId) => {
  const [rows] = await db.execute(
    `${BASE} WHERE p.tecnico_id = ?
        AND p.estado IN ('atribuido','a_caminho','no_local','em_curso')
      ORDER BY p.criado_em DESC`, [tecnicoId]);
  return rows;
};

exports.atribuir = async (pedidoId, tecnicoId) => {
  const [r] = await db.execute(
    "UPDATE pedido SET tecnico_id = ?, estado = 'atribuido' WHERE id = ? AND estado = 'criado'",
    [tecnicoId, pedidoId]);
  return r.affectedRows === 1;
};

// Transição atómica: só muda se o estado atual for um dos permitidos
exports.transitar = async (id, de, para, campos = {}) => {
  const sets = ['estado = ?', ...Object.keys(campos).map((k) => `${k} = ?`)];
  const [r] = await db.execute(
    `UPDATE pedido SET ${sets.join(', ')}
      WHERE id = ? AND estado IN (${de.map(() => '?').join(',')})`,
    [para, ...Object.values(campos), id, ...de]
  );
  return r.affectedRows === 1;
};

exports.avaliar = async ({ pedido_id, cliente_id, tecnico_id, estrelas, comentario }) => {
  await db.execute(
    `INSERT INTO avaliacao (pedido_id, cliente_id, tecnico_id, estrelas, comentario)
     VALUES (?, ?, ?, ?, ?)`,
    [pedido_id, cliente_id, tecnico_id, estrelas, comentario]
  );
  await db.execute(
    `UPDATE tecnico
        SET avaliacao_media = (SELECT AVG(estrelas) FROM avaliacao WHERE tecnico_id = ?)
      WHERE id = ?`,
    [tecnico_id, tecnico_id]
  );
};