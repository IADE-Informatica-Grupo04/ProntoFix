import 'package:flutter/material.dart';

import '../models/prestador.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import 'pf_card.dart';

/// Cartão de confiança do prestador (RF25): selo "Verificado", avaliação,
/// número de serviços e chegada, sempre visíveis antes de qualquer decisão.
class PrestadorCard extends StatelessWidget {
  final Prestador prestador;
  final Widget? rodape;

  const PrestadorCard({super.key, required this.prestador, this.rodape});

  @override
  Widget build(BuildContext context) {
    return PFCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: PFColors.tint,
                child: Icon(
                  PFIcons.utilizador,
                  size: 28,
                  color: PFColors.primaryPressed,
                ),
              ),
              const SizedBox(width: PFSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(prestador.nome, style: PFText.h4),
                    Text(prestador.profissao, style: PFText.secundario),
                    if (prestador.verificado) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            PFIcons.verificado,
                            size: 16,
                            color: PFColors.successText,
                          ),
                          const SizedBox(width: PFSpacing.xs),
                          Text(
                            'Verificado',
                            style: PFText.secundario.copyWith(
                              color: PFColors.successText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: PFSpacing.m),
          Wrap(
            spacing: PFSpacing.l,
            runSpacing: PFSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    PFIcons.estrela,
                    size: 16,
                    color: PFColors.warningText,
                  ),
                  const SizedBox(width: PFSpacing.xs),
                  Text(
                    prestador.avaliacaoTexto,
                    style: PFText.secundario.copyWith(
                      color: PFColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: PFSpacing.xs),
                  Text('(${prestador.numAvaliacoes})', style: PFText.secundario),
                ],
              ),
              Text(
                '${prestador.servicos} serviços',
                style: PFText.secundario.copyWith(
                  color: PFColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${prestador.etaMinutos} min',
                style: PFText.secundario.copyWith(
                  color: PFColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (rodape != null) ...[
            const SizedBox(height: PFSpacing.l),
            rodape!,
          ],
        ],
      ),
    );
  }
}
