/// Dados recolhidos no passo 1 do pedido e passados ao passo 2.
class DadosPedido {
  final String categoria;
  final String descricao;
  final String urgencia;

  const DadosPedido({
    required this.categoria,
    required this.descricao,
    required this.urgencia,
  });
}
