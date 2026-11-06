import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/pf_icons.dart';
import 'pf_feedback.dart';

/// Envolve o primeiro passo do pedido: sair a meio pede confirmação (RU03).
/// Intercepta tanto a seta "voltar" como o gesto/botão de voltar do sistema.
class PFFluxoPedido extends StatelessWidget {
  final Widget child;

  const PFFluxoPedido({super.key, required this.child});

  /// Pergunta se quer sair e, se sim, volta ao ecrã principal.
  static Future<void> confirmarSaida(BuildContext context) async {
    final bool sair = await PFDialogo.confirmar(
      context,
      icone: PFIcons.aviso,
      titulo: 'Sair do pedido?',
      texto: 'Se sair agora, os dados do pedido não ficam guardados.',
      textoSeguro: 'Continuar pedido',
      textoAcao: 'Sair',
      destrutivo: true,
    );
    if (sair && context.mounted) {
      Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? resultado) {
        if (!didPop) {
          confirmarSaida(context);
        }
      },
      child: child,
    );
  }
}
