import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import 'pf_card.dart';

class PFItemAcordeao {
  final String titulo;
  final String texto;

  const PFItemAcordeao(this.titulo, this.texto);
}

/// Acordeão (perguntas frequentes): um item aberto de cada vez.
class PFAcordeao extends StatefulWidget {
  final List<PFItemAcordeao> itens;

  const PFAcordeao({super.key, required this.itens});

  @override
  State<PFAcordeao> createState() => _PFAcordeaoState();
}

class _PFAcordeaoState extends State<PFAcordeao> {
  int? _aberto;

  @override
  Widget build(BuildContext context) {
    return PFCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (int i = 0; i < widget.itens.length; i++) ...[
            Semantics(
              button: true,
              label: widget.itens[i].titulo,
              excludeSemantics: true,
              child: InkWell(
                onTap: () => setState(() => _aberto = _aberto == i ? null : i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PFSpacing.l,
                      vertical: PFSpacing.m,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.itens[i].titulo,
                            style: PFText.corpoForte,
                          ),
                        ),
                        const SizedBox(width: PFSpacing.m),
                        Icon(
                          _aberto == i ? PFIcons.cima : PFIcons.baixo,
                          size: 20,
                          color: PFColors.text,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_aberto == i)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  PFSpacing.l,
                  0,
                  PFSpacing.l,
                  PFSpacing.l,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.itens[i].texto,
                    style: PFText.corpo.copyWith(color: PFColors.textSecondary),
                  ),
                ),
              ),
            if (i < widget.itens.length - 1)
              const Divider(height: 1, color: PFColors.border),
          ],
        ],
      ),
    );
  }
}
