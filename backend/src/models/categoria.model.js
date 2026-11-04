const db = require('../config/db');

exports.listar = async () => {
  const [rows] = await db.execute('SELECT id, nome, preco_base FROM categoria_servico ORDER BY nome');
  return rows;
};
exports.porId = async (id) => {
  const [rows] = await db.execute('SELECT id, nome, preco_base FROM categoria_servico WHERE id = ?', [id]);
  return rows[0] || null;
};