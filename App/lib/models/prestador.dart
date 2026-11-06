/// Profissional que atende os pedidos (dados de exemplo no protótipo).
class Prestador {
  final String nome;
  final String profissao;
  final double avaliacao;
  final int numAvaliacoes;
  final int servicos;
  final int etaMinutos;
  final bool verificado;
  final int? id;
  final String? telefone;

  const Prestador({
    required this.nome,
    required this.profissao,
    required this.avaliacao,
    required this.numAvaliacoes,
    required this.servicos,
    required this.etaMinutos,
    this.verificado = true,
    this.id,
    this.telefone,
  });

  /// Avaliação com vírgula decimal, por exemplo "4,8".
  String get avaliacaoTexto => avaliacao.toStringAsFixed(1).replaceAll('.', ',');

  /// Primeiro nome, para frases como "O João chega em 12 min."
  String get primeiroNome => nome.split(' ').first;
}
