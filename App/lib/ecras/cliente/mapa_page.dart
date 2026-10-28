import 'package:flutter/material.dart';

import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../../widgets/componentes.dart';
import '../../widgets/mapa.dart';

// Separador "Mapa": mostra o pedido em curso no mapa.
class MapaPage extends StatelessWidget {
  final Pedido? pedidoAtivo;
  final VoidCallback onAbrirPedido;

  const MapaPage({
    super.key,
    required this.pedidoAtivo,
    required this.onAbrirPedido,
  });

  @override
  Widget build(BuildContext context) {
    final Pedido? p = pedidoAtivo;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Cabecalho(
          titulo: 'Mapa',
          subtitulo: 'O teu pedido em tempo real.',
        ),
        const SizedBox(height: 20),
        if (p == null)
          const Cartao(
            child: Column(
              children: [
                Icon(Icons.map_outlined, size: 48, color: Cores.azul),
                SizedBox(height: 12),
                Text(
                  'Nada para acompanhar',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'Quando fizeres um pedido, vês aqui onde está o prestador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Cores.cinza),
                ),
              ],
            ),
          )
        else ...[
          Mapa(
            altura: 360,
            lat: p.lat,
            lng: p.lng,
            prestadorLat: p.estado == EstadoPedido.aCaminho ? p.prestadorLat : null,
            prestadorLng: p.estado == EstadoPedido.aCaminho ? p.prestadorLng : null,
            etiquetas: [
              Etiqueta(texto: textoDoEstado(p.estado), corFundo: Cores.branco),
              if (p.estado == EstadoPedido.aCaminho && p.eta > 0)
                Etiqueta(
                  texto: 'ETA ${p.eta} min',
                  cor: Cores.verde,
                  corFundo: Cores.verdeClaro,
                ),
            ],
          ),
          const SizedBox(height: 16),
          BotaoPrincipal(texto: 'Ver detalhes do pedido', onPressed: onAbrirPedido),
        ],
      ],
    );
  }
}
