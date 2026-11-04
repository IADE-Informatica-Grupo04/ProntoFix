// src/routes/pedidos.routes.js
const router = require('express').Router();
const auth = require('../middlewares/auth');
const role = require('../middlewares/requireRole');
const controller = require('../controllers/pedidos.controller');

router.use(auth);

router.post('/estimativa', role('cliente'), controller.estimar);
router.post('/', role('cliente'), controller.criar);
router.get('/', role('cliente'), controller.listarDoCliente);
router.get('/:id', controller.obter); // cliente ou prestador do pedido
router.patch('/:id/cancelar', role('cliente'), controller.cancelar);
router.post('/:id/chegada', role('cliente'), controller.chegada);
router.post('/:id/avaliacao', role('cliente'), controller.avaliar);
router.post('/:id/aceitar', role('tecnico'), controller.aceitar);
router.patch('/:id/estado', role('tecnico'), controller.atualizarEstado);

module.exports = router;