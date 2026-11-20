const prestadorModel = require('../models/prestador.model');
const pedidoModel = require('../models/pedido.model');

// {PM} Atribui ao prestador mais próximo 
exports.atribuir = async (pedidoId, categoriaId, lat, lng) => {
  const pedido = await pedidoModel.obter(pedidoId);
  if (pedido.tecnico_id) return pedido.tecnico_id;

  const t = await prestadorModel.maisProximo(categoriaId, lat, lng);
  if (!t) return null;
  await pedidoModel.atribuir(pedidoId, t.id);
  return t.id;
};