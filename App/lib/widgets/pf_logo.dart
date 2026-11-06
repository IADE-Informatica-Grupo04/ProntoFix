import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Marca: chave inglesa num quadrado arredondado com gradiente azul para ciano.
class PFLogoMarca extends StatelessWidget {
  final double tamanho;

  const PFLogoMarca({super.key, this.tamanho = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamanho,
      height: tamanho,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tamanho * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PFColors.primary, PFColors.accent],
        ),
      ),
      child: Icon(
        PFIcons.chaveInglesa,
        size: tamanho * 0.55,
        color: PFColors.surface,
      ),
    );
  }
}

/// Logótipo horizontal: marca + "Pronto" (navy ou branco) + "Fix" (azul ou ciano).
class PFLogo extends StatelessWidget {
  final double tamanho;
  final bool escuro;

  const PFLogo({super.key, this.tamanho = 40, this.escuro = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'ProntoFix',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PFLogoMarca(tamanho: tamanho),
          SizedBox(width: tamanho * 0.3),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Pronto',
                  style: TextStyle(
                    color: escuro ? PFColors.surface : PFColors.navy,
                  ),
                ),
                TextSpan(
                  text: 'Fix',
                  style: TextStyle(
                    color: escuro ? PFColors.accent : PFColors.primary,
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: tamanho * 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
