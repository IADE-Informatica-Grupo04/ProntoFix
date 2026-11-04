
const categoriaModel = require('../models/categoria.model');
const prestadorModel = require('../models/prestador.model');
const AppError = require('../utils/AppError');

const EUR_POR_KM = 1.5;
const VELOCIDADE_KMH = 30;

// Substituir por um modelo númerico (Matemática Discreta)
exports.calcular = async (categoriaId, lat, lng) => {
  const categoria = await categoriaModel.porId(categoriaId);
  if (!categoria) throw new AppError('Categoria inválida', 400);

  const t = await prestadorModel.maisProximo(categoriaId, lat, lng);
  const km = t ? Number(t.distancia_km) : null;

  return {
    preco_estimado: Math.round((categoria.preco_base + (km ?? 0) * EUR_POR_KM) * 100) / 100,
    tempo_estimado_min: km == null ? null : Math.max(5, Math.round((km / VELOCIDADE_KMH) * 60) + 5),
  };
};