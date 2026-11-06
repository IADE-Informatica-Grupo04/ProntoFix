import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/pedido.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import 'pf_card.dart';
import 'pf_chip.dart';

/// Etiqueta de estado do pedido. Cada uma tem texto próprio (a cor só reforça).
PFTag tagDoEstado(EstadoPedido estado, {String? sufixo}) {
  final String extra = sufixo != null ? ' · $sufixo' : '';
  switch (estado) {
    case EstadoPedido.procurar:
      return const PFTag(texto: 'A procurar prestador');
    case EstadoPedido.atribuido:
      return PFTag(texto: 'Prestador atribuído$extra');
    case EstadoPedido.aCaminho:
      return PFTag(texto: 'A caminho$extra', tipo: PFTagTipo.aviso);
    case EstadoPedido.noLocal:
      return const PFTag(texto: 'No local');
    case EstadoPedido.concluido:
      return const PFTag(
        texto: 'Concluído',
        tipo: PFTagTipo.sucesso,
        icone: PFIcons.certo,
      );
    case EstadoPedido.cancelado:
      return const PFTag(
        texto: 'Cancelado',
        tipo: PFTagTipo.erro,
        icone: PFIcons.fechar,
      );
  }
}

/// Cartão de um pedido: ícone da categoria, título, data, estado e preço.
class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onTap;
  final String? sufixoEstado;

  /// Etiqueta própria (ex.: "Agendado"); por defeito deriva do estado.
  final Widget? etiqueta;

  const PedidoCard({
    super.key,
    required this.pedido,
    this.onTap,
    this.sufixoEstado,
    this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    final servico = servicos.firstWhere(
      (s) => s.nome == pedido.categoria,
      orElse: () => servicos.first,
    );

    return PFCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: servico.corFundo,
              shape: BoxShape.circle,
            ),
            child: Icon(servico.icone, size: 24, color: PFColors.navy),
          ),
          const SizedBox(width: PFSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PFText.h4,
                ),
                const SizedBox(height: 2),
                Text(
                  '${pedido.categoria} · ${pedido.data}',
                  style: PFText.secundario,
                ),
                const SizedBox(height: PFSpacing.s),
                Wrap(
                  spacing: PFSpacing.s,
                  runSpacing: PFSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    etiqueta ?? tagDoEstado(pedido.estado, sufixo: sufixoEstado),
                    Text(pedido.preco, style: PFText.corpoForte),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: PFSpacing.s),
            const Padding(
              padding: EdgeInsets.only(top: PFSpacing.m),
              child: Icon(
                PFIcons.direita,
                size: 20,
                color: PFColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
