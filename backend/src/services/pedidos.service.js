
const crypto = require('crypto');
const pedidoModel = require('../models/pedido.model');
const estimativa = require('./estimativa.service');
const atribuicao = require('./atribuicao.service');
const AppError = require('../utils/AppError');

// O prestador vê o codigo_qr; o cliente nunca
const vista = (p, user) => {
  if (user.role === 'tecnico') return p;
  const { codigo_qr, ...resto } = p;
  return resto;
};

function lerLocal(d) {
  if (d.latitude == null || d.longitude == null) throw new AppError('Localização em falta', 400);
  const latitude = Number(d.latitude), longitude = Number(d.longitude);
  if (!Number.isFinite(latitude) || Math.abs(latitude) > 90 ||
      !Number.isFinite(longitude) || Math.abs(longitude) > 180)
    throw new AppError('Localização inválida', 400);
  return { latitude, longitude };
}

// Carrega o pedido e garante que pertence a quem pergunta
async function carregar(user, id) {
  const p = await pedidoModel.obter(id);
  if (!p) throw new AppError('Pedido não encontrado', 404);
  const meu = user.role === 'cliente'
    ? p.cliente_id === user.perfilId
    : p.tecnico_id === user.perfilId;
  if (!meu) throw new AppError('Sem acesso a este pedido', 403);
  return p;
}

const recarregar = async (user, id) => vista(await pedidoModel.obter(id), user);

// ── Fase 1 ──────────────────────────────────────────
exports.estimar = async (d) => {
  if (!d.categoria_id) throw new AppError('Categoria em falta', 400);
  const { latitude, longitude } = lerLocal(d);
  return estimativa.calcular(d.categoria_id, latitude, longitude);
};

exports.criar = async (user, d) => {
  const { categoria_id, descricao, morada, foto_url } = d;
  if (!categoria_id || !descricao || !morada) throw new AppError('Dados em falta', 400);
  const { latitude, longitude } = lerLocal(d);

  const est = await estimativa.calcular(categoria_id, latitude, longitude);  // recalculado no servidor
  const id = await pedidoModel.criar({
    cliente_id: user.perfilId, categoria_id, descricao, morada, latitude, longitude,
    foto_url: foto_url || null, ...est, codigo_qr: crypto.randomUUID(),
  });
  await atribuicao.atribuir(id, categoria_id, latitude, longitude);
  return recarregar(user, id);
};

exports.listarDoCliente = async (user) =>
  (await pedidoModel.listarDoCliente(user.perfilId)).map((p) => vista(p, user));

exports.listarDoPrestador = async (user) =>
  pedidoModel.listarDoPrestador(user.perfilId);

exports.obter = async (user, id) => vista(await carregar(user, id), user);

exports.aceitar = async (user, id) => {
  await carregar(user, id);
  if (!(await pedidoModel.transitar(id, ['atribuido'], 'a_caminho')))
    throw new AppError('Este pedido já não pode ser aceite', 409);
  return recarregar(user, id);
};

// ── Fase 2 ──────────────────────────────────────────
exports.cancelar = async (user, id) => {
  await carregar(user, id);
  const ok = await pedidoModel.transitar(id, ['criado', 'atribuido', 'a_caminho', 'no_local'], 'cancelado');
  if (!ok) throw new AppError('Este pedido já não pode ser cancelado', 409);
  return recarregar(user, id);
};

exports.chegada = async (user, id, { codigo }) => {
  const p = await carregar(user, id);
  if (p.estado !== 'a_caminho') throw new AppError('O prestador ainda não está a caminho', 409);
  if (String(codigo || '').trim() !== p.codigo_qr) throw new AppError('Código QR inválido', 400);
  await pedidoModel.transitar(id, ['a_caminho'], 'no_local');
  return recarregar(user, id);
};

const ESTADOS_PRESTADOR = { em_curso: ['no_local'], concluido: ['em_curso'] };

exports.atualizarEstado = async (user, id, { estado, preco_final }) => {
  const p = await carregar(user, id);
  const de = ESTADOS_PRESTADOR[estado];
  if (!de) throw new AppError('Estado inválido (usa em_curso ou concluido)', 400);

  let campos = {};
  if (estado === 'concluido') {
    const preco = preco_final == null ? p.preco_estimado : Number(preco_final);
    if (!Number.isFinite(preco) || preco < 0) throw new AppError('Preço final inválido', 400);
    campos = { preco_final: preco, concluido_em: new Date() };
  }
  if (!(await pedidoModel.transitar(id, de, estado, campos)))
    throw new AppError(`Não é possível passar a "${estado}" a partir de "${p.estado}"`, 409);
  return recarregar(user, id);
};

exports.avaliar = async (user, id, { estrelas, comentario }) => {
  const p = await carregar(user, id);
  if (p.estado !== 'concluido') throw new AppError('Só se avalia um pedido concluído', 409);
  const n = Number(estrelas);
  if (!Number.isInteger(n) || n < 1 || n > 5) throw new AppError('Estrelas: de 1 a 5', 400);
  try {
    await pedidoModel.avaliar({
      pedido_id: id, cliente_id: p.cliente_id, tecnico_id: p.tecnico_id,
      estrelas: n, comentario: comentario || null,
    });
  } catch (err) {
    if (err.code === 'ER_DUP_ENTRY') throw new AppError('Este pedido já foi avaliado', 409);
    throw err;
  }
  return { mensagem: 'Avaliação guardada' };
};