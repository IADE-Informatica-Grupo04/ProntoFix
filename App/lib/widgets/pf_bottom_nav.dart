import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

class _ItemNav {
  final IconData icone;
  final String rotulo;

  const _ItemNav(this.icone, this.rotulo);
}

/// Barra inferior com 4 separadores, todos com ícone e rótulo (RU02).
/// 72 px de altura; o separador ativo ganha fundo azul claro.
class PFBottomNav extends StatelessWidget {
  final int indice;
  final ValueChanged<int> onSelecionar;

  const PFBottomNav({
    super.key,
    required this.indice,
    required this.onSelecionar,
  });

  static const List<_ItemNav> _itens = [
    _ItemNav(PFIcons.casa, 'Início'),
    _ItemNav(PFIcons.lista, 'Pedidos'),
    _ItemNav(PFIcons.relogio, 'Histórico'),
    _ItemNav(PFIcons.utilizador, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(
          PFSpacing.margem,
          0,
          PFSpacing.margem,
          PFSpacing.s,
        ),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: PFColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: PFColors.border),
        ),
        child: Row(
          children: [
            for (int i = 0; i < _itens.length; i++)
              Expanded(
                child: _Item(
                  item: _itens[i],
                  ativo: i == indice,
                  onTap: () => onSelecionar(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final _ItemNav item;
  final bool ativo;
  final VoidCallback onTap;

  const _Item({required this.item, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color cor = ativo ? PFColors.primaryPressed : PFColors.textSecondary;

    return Semantics(
      button: true,
      selected: ativo,
      label: item.rotulo,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: ativo ? PFColors.tint : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icone, size: 24, color: cor),
                const SizedBox(height: 2),
                Text(
                  item.rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PFText.secundario.copyWith(
                    color: cor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
