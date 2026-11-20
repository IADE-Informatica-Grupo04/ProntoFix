const categoriaModel = require('../models/categoria.model');
const prestadorModel = require('../models/prestador.model');
const AppError = require('../utils/AppError');
const { simularChegada } = require('../utils/montecarlo');

const EUR_POR_KM = 1.5;

// Preço: base da categoria + deslocação (€/km).
// Tempo de chegada: simulação de Monte Carlo (ver utils/montecarlo.js).
exports.calcular = async (categoriaId, lat, lng) => {
  const categoria = await categoriaModel.porId(categoriaId);
  if (!categoria) throw new AppError('Categoria inválida', 400);

  const t = await prestadorModel.maisProximo(categoriaId, lat, lng);
  const km = t ? Number(t.distancia_km) : null;
  const chegada = km == null ? null : simularChegada(km);

  return {
    preco_estimado: Math.round((categoria.preco_base + (km ?? 0) * EUR_POR_KM) * 100) / 100,
    tempo_estimado_min: chegada ? chegada.mediana : null, // mediana (P50)
    tempo_min: chegada ? chegada.p10 : null,              // cenário otimista (P10)
    tempo_max: chegada ? chegada.p90 : null,              // cenário pessimista (P90)
  };
};
