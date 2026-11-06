// src/controllers/prestadores.controller.js
const pedidos = require('../services/pedidos.service');
const prestadores = require('../services/prestadores.service');
const asyncHandler = require('../utils/asyncHandler');

exports.meusPedidos = asyncHandler(async (req, res) => res.json(await pedidos.listarDoPrestador(req.user)));
exports.disponibilidade = asyncHandler(async (req, res) => res.json(await prestadores.definirDisponibilidade(req.user, req.body)));
exports.localizacao = asyncHandler(async (req, res) => res.json(await prestadores.atualizarLocalizacao(req.user, req.body)));