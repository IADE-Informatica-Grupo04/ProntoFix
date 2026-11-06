import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Chip selecionável (categoria, método de pagamento). Alvo de toque de 44 px.
/// O estado selecionado não depende só da cor: tem fundo, borda mais grossa,
/// texto a negrito e um visto.
class PFChip extends StatelessWidget {
  final String texto;
  final IconData? icone;
  final bool selecionado;
  final VoidCallback? onTap;

  const PFChip({
    super.key,
    required this.texto,
    this.icone,
    this.selecionado = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = selecionado ? PFColors.primaryPressed : PFColors.text;

    return Semantics(
      button: true,
      selected: selecionado,
      label: texto,
      excludeSemantics: true,
      child: Material(
        color: selecionado ? PFColors.tint : PFColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PFRadius.chip),
          side: BorderSide(
            color: selecionado ? PFColors.primary : PFColors.disabled,
            width: selecionado ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: PFSpacing.alvo),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: PFSpacing.s,
              ),
              child: Center(
                widthFactor: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icone != null) ...[
                      Icon(icone, size: 20, color: fg),
                      const SizedBox(width: PFSpacing.s),
                    ],
                    Flexible(
                      child: Text(
                        texto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PFText.secundario.copyWith(
                          color: fg,
                          fontWeight:
                              selecionado ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (selecionado) ...[
                      const SizedBox(width: 6),
                      Icon(PFIcons.certo, size: 16, color: fg),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tipos de etiqueta de estado (Style Guide 7.4).
enum PFTagTipo { info, aviso, sucesso, erro }

/// Etiqueta de estado. Tem sempre texto próprio; a cor só reforça.
class PFTag extends StatelessWidget {
  final String texto;
  final PFTagTipo tipo;
  final IconData? icone;

  const PFTag({
    super.key,
    required this.texto,
    this.tipo = PFTagTipo.info,
    this.icone,
  });

  @override
  Widget build(BuildContext context) {
    late final Color fundo;
    late final Color fg;
    switch (tipo) {
      case PFTagTipo.info:
        fundo = PFColors.tint;
        fg = PFColors.primaryPressed;
      case PFTagTipo.aviso:
        fundo = PFColors.warningBg;
        fg = PFColors.warningText;
      case PFTagTipo.sucesso:
        fundo = PFColors.successBg;
        fg = PFColors.successText;
      case PFTagTipo.erro:
        fundo = PFColors.errorBg;
        fg = PFColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PFSpacing.m, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 16, color: fg),
            const SizedBox(width: PFSpacing.xs),
          ],
          Flexible(
            child: Text(
              texto,
              style: PFText.secundario.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
