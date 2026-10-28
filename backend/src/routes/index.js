const router = require('express').Router();
// Routes get plugged in here as you create them
// router.use('/pedidos', require('./pedidos.routes'));


router.use('/auth', require('./auth.routes'));
module.exports = router;