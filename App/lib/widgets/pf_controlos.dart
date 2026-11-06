import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Controlo segmentado (Cliente | Prestador, Normal | Hoje | Agora).
/// O segmento selecionado tem fundo branco, texto azul e sombra.
class PFSegmentado extends StatelessWidget {
  final List<String> opcoes;
  final String selecionado;
  final ValueChanged<String> onChanged;

  /// Cor do texto do segmento selecionado (por defeito, azul).
  final Color Function(String opcao)? corSelecionada;

  const PFSegmentado({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.onChanged,
    this.corSelecionada,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PFSpacing.xs),
      decoration: BoxDecoration(
        color: PFColors.border,
        borderRadius: BorderRadius.circular(PFRadius.botao),
      ),
      child: Row(
        children: [
          for (final opcao in opcoes)
            Expanded(
              child: Semantics(
                button: true,
                selected: opcao == selecionado,
                label: opcao,
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(opcao),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: PFSpacing.alvo,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: opcao == selecionado
                          ? PFColors.surface
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: opcao == selecionado
                          ? const [
                              BoxShadow(
                                color: Color(0x1A0B1530),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      opcao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PFText.corpoForte.copyWith(
                        color: opcao == selecionado
                            ? (corSelecionada?.call(opcao) ??
                                PFColors.primaryPressed)
                            : PFColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Interruptor (ex.: "Disponível agora"). Ligado = verde escuro.
class PFSwitch extends StatelessWidget {
  final bool valor;
  final ValueChanged<bool> onChanged;
  final String rotulo;

  const PFSwitch({
    super.key,
    required this.valor,
    required this.onChanged,
    required this.rotulo,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: valor,
      label: rotulo,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!valor),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: PFSpacing.alvo,
            minHeight: PFSpacing.alvo,
          ),
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 32,
              padding: const EdgeInsets.all(3),
              alignment: valor ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: valor ? PFColors.successText : PFColors.disabled,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: PFColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Caixa de seleção com rótulo (ex.: aceitar os termos).
class PFCheckbox extends StatelessWidget {
  final bool valor;
  final ValueChanged<bool> onChanged;
  final Widget rotulo;
  final String rotuloSemantico;

  const PFCheckbox({
    super.key,
    required this.valor,
    required this.onChanged,
    required this.rotulo,
    required this.rotuloSemantico,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: valor,
      label: rotuloSemantico,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(PFRadius.chip),
        onTap: () => onChanged(!valor),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: PFSpacing.alvo),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: valor ? PFColors.primary : PFColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: valor ? PFColors.primary : PFColors.muted,
                    width: 2,
                  ),
                ),
                child: valor
                    ? const Icon(PFIcons.certo, size: 16, color: PFColors.surface)
                    : null,
              ),
              const SizedBox(width: PFSpacing.m),
              Expanded(child: rotulo),
            ],
          ),
        ),
      ),
    );
  }
}
