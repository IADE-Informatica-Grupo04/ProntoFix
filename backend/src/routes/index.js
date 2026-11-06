const router = require('express').Router();

// Routes são adiconadas aqui
router.use('/auth', require('./auth.routes'));
router.use('/categorias', require('./categorias.routes'));
router.use('/pedidos', require('./pedidos.routes'));
router.use('/prestadores', require('./prestadores.routes'))
module.exports = router;