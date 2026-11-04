const router = require('express').Router();
const auth = require('../middlewares/auth');
const role = require('../middlewares/requireRole');
const controller = require('../controllers/prestadores.controller');

router.use(auth, role('tecnico'));

router.get('/me/pedidos', controller.meusPedidos);
router.patch('/me/disponibilidade', controller.disponibilidade);
router.patch('/me/localizacao', controller.localizacao);

module.exports = router;