import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Título de secção (H3). 24 px entre grupos e 8 px dentro do grupo.
class PFTituloSeccao extends StatelessWidget {
  final String texto;
  final double topo;

  const PFTituloSeccao(this.texto, {super.key, this.topo = PFSpacing.xxl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topo, bottom: PFSpacing.s),
      child: Semantics(header: true, child: Text(texto, style: PFText.h3)),
    );
  }
}
