import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/categoria.dart';
import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../../widgets/cartoes_pedido.dart';
import '../../widgets/componentes.dart';

// 03 Home do cliente.
// É Stateless: recebe tudo da ClientePrincipalPage pelo construtor.
class HomePage extends StatelessWidget {
  final String nome;
  final Pedido? pedidoAtivo;
  final void Function([Categoria? categoria]) onNovoPedido;
  final VoidCallback onAbrirPedido;

  const HomePage({
    super.key,
    required this.nome,
    required this.pedidoAtivo,
    required this.onNovoPedido,
    required this.onAbrirPedido,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Cabecalho(
          titulo: 'Olá, $nome',
          subtitulo: 'Pronto para resolver uma avaria?',
        ),
        const SizedBox(height: 20),
        _cartaoPedirAjuda(),
        const SizedBox(height: 24),
        const TituloSecao('Categorias rápidas'),

        // Um CategoriaCard por cada categoria da lista.
        // São só 3, por isso usamos um ciclo for dentro do ListView;
        // o ecrã de pedidos usa ListView.builder.
        for (final Categoria c in categorias)
          CategoriaCard(categoria: c, onTap: () => onNovoPedido(c)),

        if (pedidoAtivo != null) ...[
          const SizedBox(height: 10),
          PedidoCard(pedido: pedidoAtivo!, onTap: onAbrirPedido),
        ],
      ],
    );
  }

  // Cartão azul "Pedir ajuda urgente".
  Widget _cartaoPedirAjuda() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Cores.azul,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pedir ajuda urgente',
                  style: TextStyle(
                    color: Cores.branco,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Canalização, eletricidade ou serralharia em minutos.',
                  style: TextStyle(color: Color(0xFFDCE6FF), fontSize: 13),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: () => onNovoPedido(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Cores.branco,
                    foregroundColor: Cores.azul,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Começar pedido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Caixa "18 min / Tempo médio"
          Container(
            width: 86,
            height: 76,
            decoration: BoxDecoration(
              color: const Color(0xFF1D4FC4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '18 min',
                  style: TextStyle(
                    color: Cores.branco,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tempo médio',
                  style: TextStyle(color: Color(0xFFC9D8FF), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
