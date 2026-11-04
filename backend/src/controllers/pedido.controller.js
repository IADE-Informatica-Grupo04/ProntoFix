// Controlador dos Pedidos
const asyncHandler = require('../utils/asyncHandler');
const service = require('../services/pedidos.service');

exports.estimar = asyncHandler(async (req, res) => res.json(await service.estimar(req.body)));

exports.criar = asyncHandler(async (req, res) => res.status(201).json(await service.criar(req.user, req.body)));

exports.listarDoCliente  = asyncHandler(async (req, res) => res.json(await service.listarDoCliente(req.user)));

exports.obter = asyncHandler(async (req, res) => res.json(await service.obter(req.user, +req.params.id)));

exports.aceitar = asyncHandler(async (req, res) => res.json(await service.aceitar(req.user, +req.params.id)));

exports.cancelar = asyncHandler(async (req, res) => res.json(await service.cancelar(req.user, +req.params.id)));

exports.chegada = asyncHandler(async (req, res) => res.json(await service.chegada(req.user, +req.params.id, req.body)));

exports.atualizarEstado = asyncHandler(async (req, res) => res.json(await service.atualizarEstado(req.user, +req.params.id, req.body)));

exports.avaliar = asyncHandler(async (req, res) => res.status(201).json(await service.avaliar(req.user, +req.params.id, req.body)));