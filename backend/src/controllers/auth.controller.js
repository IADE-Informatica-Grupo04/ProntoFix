const authService = require('../services/auth.service');

exports.register = async (req, res, next) => {
  try {
    res.status(201).json(await authService.registar(req.body));
  } catch (err) { next(err); }
};

exports.login = async (req, res, next) => {
  try {
    res.json(await authService.login(req.body));   // { token, utilizador }
  } catch (err) { next(err); }
};

// Rota protegida só para testar o middleware
exports.me = (req, res) => res.json(req.user);