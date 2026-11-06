import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import 'pf_chip.dart';

/// Barra superior: seta "voltar" (44 px), título, subtítulo e, nos fluxos de
/// vários passos, o indicador "1 de 3" com a barra de passos (Style Guide 7.5).
class PFTopBar extends StatelessWidget {
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onVoltar;
  final int? passo;
  final int totalPassos;
  final Widget? trailing;

  const PFTopBar({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.onVoltar,
    this.passo,
    this.totalPassos = 3,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PFSpacing.margem,
        PFSpacing.m,
        PFSpacing.margem,
        PFSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (onVoltar != null) ...[
                _BotaoIcone(
                  icone: PFIcons.voltar,
                  rotulo: 'Voltar',
                  onTap: onVoltar!,
                ),
                const SizedBox(width: PFSpacing.m),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: PFText.h2),
                    if (subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitulo!, style: PFText.secundario),
                    ],
                  ],
                ),
              ),
              if (passo != null) ...[
                const SizedBox(width: PFSpacing.m),
                PFTag(texto: '$passo de $totalPassos'),
              ] else if (trailing != null) ...[
                const SizedBox(width: PFSpacing.m),
                trailing!,
              ],
            ],
          ),
          if (passo != null) ...[
            const SizedBox(height: PFSpacing.m),
            Semantics(
              label: 'Passo $passo de $totalPassos',
              excludeSemantics: true,
              child: Row(
                children: [
                  for (int i = 1; i <= totalPassos; i++) ...[
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              i <= passo! ? PFColors.primary : PFColors.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    if (i < totalPassos) const SizedBox(width: PFSpacing.s),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Botão quadrado de 44 px com ícone (voltar, notificações...).
class PFBotaoIcone extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  const PFBotaoIcone({
    super.key,
    required this.icone,
    required this.rotulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BotaoIcone(icone: icone, rotulo: rotulo, onTap: onTap);
  }
}

class _BotaoIcone extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  const _BotaoIcone({
    required this.icone,
    required this.rotulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: rotulo,
      excludeSemantics: true,
      child: Material(
        color: PFColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PFRadius.botao),
          side: const BorderSide(color: PFColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: PFSpacing.alvo,
            height: PFSpacing.alvo,
            child: Center(
              child: Icon(icone, size: 24, color: PFColors.text),
            ),
          ),
        ),
      ),
    );
  }
}
