const router = require('express').Router();
const auth = require('../middlewares/auth');
const asyncHandler = require('../utils/asyncHandler');
const categoriaModel = require('../models/categoria.model');

router.get('/', auth, asyncHandler(async (req, res) => res.json(await categoriaModel.listar())));

module.exports = router;