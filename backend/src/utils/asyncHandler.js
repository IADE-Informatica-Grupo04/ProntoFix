// Captura erros de funções assincronas que o Express deixa passar
module.exports = (fn) => (req, res, next) => fn(req, res, next).catch(next);