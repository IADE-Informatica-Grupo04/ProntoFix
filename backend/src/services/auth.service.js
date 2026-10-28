const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { jwtSecret, jwtExpiresIn } = require('../config/env');
const utilizadorModel = require('../models/utilizador.model');
const AppError = require('../utils/AppError');

// A app pode mandar "Cliente", "Prestador", "Técnico"... a BD só conhece cliente|tecnico
function normalizarTipo(t) {
  const v = String(t || '').trim().toLowerCase();
  if (v === 'cliente') return 'cliente';
  if (['tecnico', 'técnico', 'prestador'].includes(v)) return 'tecnico';
  return null;   // 'Admin' nunca se cria aqui
}

function gerarToken(u) {
  return jwt.sign(
    { id: u.id, role: u.tipo, perfilId: u.perfilId ?? null },
    jwtSecret,
    { expiresIn: jwtExpiresIn }
  );
}

exports.registar = async ({ nome, email, password, telefone, tipo, especialidade }) => {
  const tipoBD = normalizarTipo(tipo);
  if (!nome || !email || !password || !tipoBD)
    throw new AppError('Dados em falta ou tipo inválido', 400);
  if (!/^\S+@\S+\.\S+$/.test(email))
    throw new AppError('Email inválido', 400);
  if (password.length < 6)
    throw new AppError('A palavra-passe deve ter pelo menos 6 caracteres', 400);
  if (tipoBD === 'tecnico' && !especialidade)
    throw new AppError('Os técnicos têm de indicar a especialidade', 400);

  const passwordHash = await bcrypt.hash(password, 10);
  try {
    const { id, perfilId } = await utilizadorModel.criar({
      nome: nome.trim(),
      email: email.trim().toLowerCase(),
      passwordHash, telefone, tipo: tipoBD, especialidade,
    });
    const u = { id, nome, email, tipo: tipoBD, perfilId };
    return { token: gerarToken(u), utilizador: { id, nome, email, tipo: tipoBD } };
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') throw new AppError('Este email já está registado', 409);
    throw err;
  }
};

exports.login = async ({ email, password, tipo }) => {
  if (!email || !password) throw new AppError('Email e palavra-passe obrigatórios', 400);

  const u = await utilizadorModel.findByEmail(email.trim().toLowerCase());
  const ok = u && (await bcrypt.compare(password, u.password_hash));
  if (!ok) throw new AppError('Credenciais inválidas', 401);

  // Se a app disser com que perfil está a entrar, tem de bater com o da BD
  const tipoUtilizador = normalizarTipo(tipo);
  if (tipoUtilizador && tipoUtilizador !== u.tipo) throw new AppError('Credenciais inválidas', 401);

  const perfilId = u.cliente_id ?? u.tecnico_id;
  return {
    token: gerarToken({ id: u.id, tipo: u.tipo, perfilId }),
    utilizador: { id: u.id, nome: u.nome, email: u.email, tipo: u.tipo },
  };
};