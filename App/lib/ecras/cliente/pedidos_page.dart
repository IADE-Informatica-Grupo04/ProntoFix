import 'dart:io';

import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../../widgets/cartoes_pedido.dart';
import '../../widgets/componentes.dart';

// Separador "Pedidos": pedido em curso + histórico (Guião 3).
// O histórico usa ListView.builder (aula de listas).
class PedidosPage extends StatelessWidget {
  final Pedido? pedidoAtivo;
  final List<Pedido> historico;
  final VoidCallback onAbrirPedido;
  final ValueChanged<Pedido> onRepetir;

  const PedidosPage({
    super.key,
    required this.pedidoAtivo,
    required this.historico,
    required this.onAbrirPedido,
    required this.onRepetir,
  });

  // Abre o detalhe e espera a resposta: "repetir" ou nada.
  Future<void> abrirDetalhe(BuildContext context, Pedido pedido) async {
    final String? resposta = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (context) => DetalhePedidoPage(pedido: pedido),
      ),
    );
    if (resposta == 'repetir') onRepetir(pedido);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Cabecalho(
            titulo: 'Os meus pedidos',
            subtitulo: 'Estado, data e prestador.',
          ),
          const SizedBox(height: 20),
          if (pedidoAtivo != null) ...[
            const TituloSecao('Em curso'),
            PedidoCard(pedido: pedidoAtivo!, onTap: onAbrirPedido),
            const SizedBox(height: 20),
          ],
          const TituloSecao('Anteriores'),
          Expanded(
            child: ListView.builder(
              itemCount: historico.length,
              itemBuilder: (context, index) {
                final Pedido pedido = historico[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PedidoCard(
                    pedido: pedido,
                    onTap: () => abrirDetalhe(context, pedido),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Detalhe de um pedido antigo: valores, avaliação, prestador favorito
// e "Repetir pedido".
class DetalhePedidoPage extends StatefulWidget {
  final Pedido pedido;

  const DetalhePedidoPage({super.key, required this.pedido});

  @override
  State<DetalhePedidoPage> createState() => _DetalhePedidoPageState();
}

class _DetalhePedidoPageState extends State<DetalhePedidoPage> {
  @override
  Widget build(BuildContext context) {
    final Pedido pedido = widget.pedido;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Cabecalho(
              titulo: pedido.categoria.nome,
              subtitulo: dataCurta(pedido.data),
              mostrarVoltar: true,
            ),
            const SizedBox(height: 20),
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('O problema', style: TextStyle(color: Cores.cinza)),
                  const SizedBox(height: 4),
                  Text(pedido.descricao, style: const TextStyle(fontSize: 15)),
                  if (pedido.fotoPath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(pedido.fotoPath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const Divider(height: 28, color: Cores.linha),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined, color: Cores.cinza),
                      const SizedBox(width: 8),
                      Expanded(child: Text(pedido.morada)),
                    ],
                  ),
                ],
              ),
            ),
            if (pedido.prestador != null) ...[
              const SizedBox(height: 16),
              Cartao(
                padding: const EdgeInsets.all(6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Cores.azulClaro,
                    child: Text(
                      pedido.prestador![0],
                      style: const TextStyle(color: Cores.azul),
                    ),
                  ),
                  title: Text(pedido.prestador!),
                  subtitle: Text(pedido.categoria.profissional),
                  trailing: IconButton(
                    tooltip: 'Prestador favorito',
                    onPressed: () {
                      setState(() {
                        pedido.prestadorFavorito = !pedido.prestadorFavorito;
                      });
                    },
                    icon: Icon(
                      pedido.prestadorFavorito
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Cores.vermelho,
                    ),
                  ),
                ),
              ),
            ],
            if (pedido.total != null) ...[
              const SizedBox(height: 16),
              Cartao(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _linha('Mão de obra', euros(pedido.maoDeObra ?? 0)),
                    const SizedBox(height: 6),
                    _linha('Material', euros(pedido.material ?? 0)),
                    const Divider(height: 24, color: Cores.linha),
                    _linha('Total pago', euros(pedido.total!)),
                    if (pedido.metodoPagamento != null)
                      Text(
                        'Pago com ${pedido.metodoPagamento}',
                        style: const TextStyle(color: Cores.cinza),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Icon(
                            i <= pedido.estrelas
                                ? Icons.star
                                : Icons.star_border,
                            color: Cores.laranja,
                          ),
                      ],
                    ),
                    if (pedido.comentario.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('"${pedido.comentario}"'),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            BotaoPrincipal(
              texto: 'Repetir pedido',
              onPressed: () => Navigator.pop(context, 'repetir'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linha(String rotulo, String valor) {
    return Row(
      children: [
        Expanded(child: Text(rotulo)),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
