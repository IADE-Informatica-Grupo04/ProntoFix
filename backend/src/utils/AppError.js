// Mensagem de Erro
module.exports = class AppError extends Error {
  constructor(message, status = 500) {
    super(message);
    this.status = status;
  }
};