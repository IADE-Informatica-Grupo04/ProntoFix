import 'package:flutter/material.dart';

import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../../widgets/cartoes_pedido.dart';
import '../../widgets/componentes.dart';

// Separador "Pedidos" do prestador: resumo em grelha (GridView.builder)
// e lista dos serviços feitos nesta sessão (ListView.builder).
class ServicosFeitosPage extends StatelessWidget {
  final List<Pedido> feitos;
  final int pedidosHoje;
  final double ganhosHoje;
  final double avaliacao;

  const ServicosFeitosPage({
    super.key,
    required this.feitos,
    required this.pedidosHoje,
    required this.ganhosHoje,
    required this.avaliacao,
  });

  @override
  Widget build(BuildContext context) {
    // Dados da grelha: [valor, rótulo, ícone]
    final List<List<dynamic>> resumo = [
      ['$pedidosHoje', 'Pedidos hoje', Icons.assignment_outlined],
      ['€ ${ganhosHoje.round()}', 'Ganhos', Icons.euro],
      [avaliacao.toStringAsFixed(1).replaceAll('.', ','), 'Avaliação', Icons.star_outline],
      ['${feitos.length}', 'Nesta sessão', Icons.check_circle_outline],
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Cabecalho(
            titulo: 'Os meus serviços',
            subtitulo: 'Resumo do dia e serviços concluídos.',
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: resumo.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              return Cartao(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(resumo[index][2] as IconData, color: Cores.azul),
                    const SizedBox(height: 6),
                    Text(
                      resumo[index][0] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      resumo[index][1] as String,
                      style: const TextStyle(fontSize: 12, color: Cores.cinza),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const TituloSecao('Concluídos'),
          Expanded(
            child: feitos.isEmpty
                ? const Text(
                    'Ainda não concluíste serviços nesta sessão.',
                    style: TextStyle(color: Cores.cinza),
                  )
                : ListView.builder(
                    itemCount: feitos.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PedidoCard(pedido: feitos[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
