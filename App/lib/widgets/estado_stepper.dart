import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Indicador de estado em 4 passos (Atribuído, A caminho, No local, Concluído).
/// O estado nunca é só cor: passos feitos têm visto, o atual tem anel e negrito.
class EstadoStepper extends StatelessWidget {
  final EstadoPedido atual;

  const EstadoStepper({super.key, required this.atual});

  @override
  Widget build(BuildContext context) {
    final bool concluido = atual == EstadoPedido.concluido;
    // Índice do último passo alcançado (-1 se ainda não há prestador).
    final int alcancado = passosEstado.indexOf(atual);
    final int total = passosEstado.length;

    return Semantics(
      label: 'Estado do pedido: ${atual.rotulo}',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < total; i++)
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 26,
                    child: Row(
                      children: [
                        Expanded(
                          child: _Linha(
                            visivel: i > 0,
                            ativa: i <= alcancado,
                          ),
                        ),
                        _Bolinha(
                          feito: i < alcancado || (concluido && i == alcancado),
                          corrente: i == alcancado && !concluido,
                        ),
                        Expanded(
                          child: _Linha(
                            visivel: i < total - 1,
                            ativa: i + 1 <= alcancado,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PFSpacing.s),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      passosEstado[i].rotulo,
                      textAlign: TextAlign.center,
                      style: PFText.secundario.copyWith(
                        color: i <= alcancado
                            ? PFColors.navy
                            : PFColors.textSecondary,
                        fontWeight: i == alcancado
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Bolinha extends StatelessWidget {
  final bool feito;
  final bool corrente;

  const _Bolinha({required this.feito, required this.corrente});

  @override
  Widget build(BuildContext context) {
    if (feito) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: PFColors.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(PFIcons.certo, size: 16, color: PFColors.surface),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: corrente ? PFColors.surface : PFColors.tint,
        shape: BoxShape.circle,
        border: Border.all(
          color: corrente ? PFColors.primary : PFColors.disabled,
          width: corrente ? 3 : 1.5,
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final bool visivel;
  final bool ativa;

  const _Linha({required this.visivel, required this.ativa});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      color: !visivel
          ? Colors.transparent
          : (ativa ? PFColors.primary : PFColors.border),
    );
  }
}
