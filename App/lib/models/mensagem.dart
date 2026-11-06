/// Mensagem do chat entre cliente e prestador (dados de exemplo).
class Mensagem {
  final String texto;
  final bool minha;
  final String hora;

  const Mensagem({
    required this.texto,
    required this.minha,
    required this.hora,
  });
}
