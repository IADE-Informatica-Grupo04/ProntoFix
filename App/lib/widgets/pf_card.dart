import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cartão branco com raio de 20 px e borda suave (Style Guide, secção 5).
class PFCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? cor;
  final Color? corBorda;

  const PFCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(PFSpacing.l),
    this.onTap,
    this.cor,
    this.corBorda,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cor ?? PFColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(PFRadius.cartao),
        side: BorderSide(color: corBorda ?? PFColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
