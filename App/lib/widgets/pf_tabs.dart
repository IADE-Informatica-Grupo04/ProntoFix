import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Separadores no topo (ex.: Ativos | Agendados). O ativo tem sublinhado azul.
class PFTabs extends StatelessWidget {
  final List<String> rotulos;
  final int indice;
  final ValueChanged<int> onChanged;

  const PFTabs({
    super.key,
    required this.rotulos,
    required this.indice,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(PFRadius.botao),
      child: Container(
        decoration: BoxDecoration(
          color: PFColors.surface,
          border: Border.all(color: PFColors.border),
          borderRadius: BorderRadius.circular(PFRadius.botao),
        ),
        child: Row(
          children: [
            for (int i = 0; i < rotulos.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == indice,
                  label: rotulos[i],
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => onChanged(i),
                    child: Container(
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: i == indice
                                ? PFColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        rotulos[i],
                        style: PFText.corpoForte.copyWith(
                          color: i == indice
                              ? PFColors.primaryPressed
                              : PFColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
