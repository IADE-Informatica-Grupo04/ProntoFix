const jwt = require('jsonwebtoken');
const { jwtSecret } = require('../config/env');

module.exports = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ erro: 'Token em falta' });
  try {
    req.user = jwt.verify(token, jwtSecret);   // { id, role }
    next();
  } catch {
    res.status(401).json({ erro: 'Token inválido' });
  }
};