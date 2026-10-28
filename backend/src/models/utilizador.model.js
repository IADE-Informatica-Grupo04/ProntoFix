const db = require('../config/db');

// Utilizador + id do perfil (cliente.id ou tecnico.id) numa só query
exports.findByEmail = async (email) => {
  const [rows] = await db.execute(
    `SELECT u.id, u.nome, u.email, u.password_hash, u.tipo,
            c.id AS cliente_id, t.id AS tecnico_id
       FROM utilizador u
       LEFT JOIN cliente c ON c.utilizador_id = u.id
       LEFT JOIN tecnico t ON t.utilizador_id = u.id
      WHERE u.email = ?`,
    [email]
  );
  return rows[0] || null;
};

// Cria utilizador + cliente/tecnico na mesma transação
exports.criar = async ({ nome, email, passwordHash, telefone, tipo, especialidade }) => {
  const conn = await db.getConnection();
  try {
    await conn.beginTransaction();

    const [u] = await conn.execute(
      `INSERT INTO utilizador (nome, email, password_hash, telefone, tipo)
       VALUES (?, ?, ?, ?, ?)`,
      [nome, email, passwordHash, telefone || null, tipo]
    );

    let perfilId;
    if (tipo === 'cliente') {
      const [c] = await conn.execute(
        'INSERT INTO cliente (utilizador_id) VALUES (?)', [u.insertId]);
      perfilId = c.insertId;
    } else {
      const [t] = await conn.execute(
        'INSERT INTO tecnico (utilizador_id, especialidade) VALUES (?, ?)',
        [u.insertId, especialidade]);
      perfilId = t.insertId;
    }

    await conn.commit();
    return { id: u.insertId, perfilId };
    
  } catch (err) {
    await conn.rollback();
    throw err;
  } finally {
    conn.release();
  }
};