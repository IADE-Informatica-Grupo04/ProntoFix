
const prestadorModel = require('../models/prestador.model');
const AppError = require('../utils/AppError');

exports.definirDisponibilidade = async (user, { disponivel }) => {
  if (typeof disponivel !== 'boolean') throw new AppError('"disponivel" tem de ser true ou false', 400);
  await prestadorModel.definirDisponibilidade(user.perfilId, disponivel);
  return { disponivel };
};

exports.atualizarLocalizacao = async (user, d) => {
  const latitude = Number(d.latitude), longitude = Number(d.longitude);
  if (d.latitude == null || d.longitude == null ||
      !Number.isFinite(latitude) || Math.abs(latitude) > 90 ||
      !Number.isFinite(longitude) || Math.abs(longitude) > 180)
    throw new AppError('Localização inválida', 400);
  await prestadorModel.atualizarLocalizacao(user.perfilId, latitude, longitude);
  return { latitude, longitude };
};