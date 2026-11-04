const router = require('express').Router();

// Routes são adiconadas aqui
router.use('/auth', require('./auth.routes'));
router.use('/categorias', require('./categorias.routes'));
router.use('/pedidos', require('./pedidos.routes'));
routes.use('/prestadores', require('./prestador.routes'))
module.exports = router;