import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pf_button.dart';

/// Estado vazio: explica o que falta e orienta o próximo passo.
class PFEstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;
  final String? acaoTexto;
  final VoidCallback? onAcao;

  const PFEstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acaoTexto,
    this.onAcao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PFSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: PFColors.accentBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 32, color: PFColors.navy),
            ),
            const SizedBox(height: PFSpacing.l),
            Text(titulo, textAlign: TextAlign.center, style: PFText.h4),
            const SizedBox(height: PFSpacing.s),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: PFText.corpo.copyWith(color: PFColors.textSecondary),
            ),
            if (acaoTexto != null) ...[
              const SizedBox(height: PFSpacing.xl),
              PFButton(
                texto: acaoTexto!,
                variante: PFVariante.secundario,
                expandir: false,
                onPressed: onAcao,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
