import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Variantes de botão do Style Guide (7.1).
enum PFVariante {
  primario,
  secundario,
  contorno,
  destrutivo,

  /// Contorno vermelho: ação crítica de menor peso (ex.: "Cancelar pedido").
  contornoDestrutivo,
}

class _CoresBotao {
  final Color fundo;
  final Color texto;
  final Color? borda;

  const _CoresBotao(this.fundo, this.texto, [this.borda]);
}

/// Botão com 48 px de altura mínima e raio de 14 px. Estados: normal, hover,
/// pressionado, foco (contorno ciano), desativado (onPressed nulo) e a carregar.
class PFButton extends StatefulWidget {
  final String texto;
  final VoidCallback? onPressed;
  final PFVariante variante;
  final IconData? icone;
  final IconData? iconeDepois;
  final bool carregando;
  final bool expandir;

  const PFButton({
    super.key,
    required this.texto,
    required this.onPressed,
    this.variante = PFVariante.primario,
    this.icone,
    this.iconeDepois,
    this.carregando = false,
    this.expandir = true,
  });

  @override
  State<PFButton> createState() => _PFButtonState();
}

class _PFButtonState extends State<PFButton> {
  bool _hover = false;
  bool _pressionado = false;
  bool _foco = false;

  _CoresBotao _cores(bool ativo) {
    if (widget.carregando) {
      return const _CoresBotao(Color(0xFF3A6DEB), PFColors.surface);
    }
    switch (widget.variante) {
      case PFVariante.primario:
        if (!ativo) {
          return const _CoresBotao(PFColors.border, PFColors.textSecondary);
        }
        return _CoresBotao(
          _pressionado
              ? PFColors.primaryPressed
              : (_hover ? PFColors.primaryHover : PFColors.primary),
          PFColors.surface,
        );
      case PFVariante.secundario:
        if (!ativo) {
          return const _CoresBotao(PFColors.border, PFColors.textSecondary);
        }
        return _CoresBotao(
          _pressionado
              ? const Color(0xFFD3E0FF)
              : (_hover ? const Color(0xFFDDE7FF) : PFColors.tint),
          PFColors.primaryPressed,
        );
      case PFVariante.contorno:
        if (!ativo) {
          return const _CoresBotao(
            PFColors.surface,
            PFColors.textSecondary,
            PFColors.disabled,
          );
        }
        return _CoresBotao(
          _pressionado
              ? PFColors.tint
              : (_hover ? const Color(0xFFF3F6FF) : PFColors.surface),
          PFColors.primary,
          PFColors.primary,
        );
      case PFVariante.destrutivo:
        if (!ativo) {
          return const _CoresBotao(PFColors.border, PFColors.textSecondary);
        }
        return _CoresBotao(
          _pressionado
              ? const Color(0xFF9E2530)
              : (_hover ? const Color(0xFFB02A35) : PFColors.error),
          PFColors.surface,
        );
      case PFVariante.contornoDestrutivo:
        if (!ativo) {
          return const _CoresBotao(
            PFColors.surface,
            PFColors.textSecondary,
            PFColors.disabled,
          );
        }
        return _CoresBotao(
          _pressionado
              ? PFColors.errorBg
              : (_hover ? const Color(0xFFFEF3F4) : PFColors.surface),
          PFColors.error,
          PFColors.error,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool ativo = widget.onPressed != null && !widget.carregando;
    final cores = _cores(ativo);
    final raio = BorderRadius.circular(PFRadius.botao);

    final conteudo = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.carregando) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(cores.texto),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (widget.icone != null) ...[
          Icon(widget.icone, size: 20, color: cores.texto),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.texto,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PFText.botao.copyWith(color: cores.texto),
          ),
        ),
        if (widget.iconeDepois != null) ...[
          const SizedBox(width: 8),
          Icon(widget.iconeDepois, size: 20, color: cores.texto),
        ],
      ],
    );

    return Semantics(
      button: true,
      enabled: ativo,
      label: widget.texto,
      excludeSemantics: true,
      child: SizedBox(
        width: widget.expandir ? double.infinity : null,
        child: Container(
          // Contorno ciano quando o botão tem foco (teclado / acessibilidade).
          foregroundDecoration: BoxDecoration(
            borderRadius: raio,
            border: Border.all(
              color: _foco ? PFColors.accent : Colors.transparent,
              width: 3,
            ),
          ),
          child: Material(
            color: cores.fundo,
            shape: RoundedRectangleBorder(
              borderRadius: raio,
              side: cores.borda == null
                  ? BorderSide.none
                  : BorderSide(color: cores.borda!, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: ativo ? widget.onPressed : null,
              onHover: (v) => setState(() => _hover = v),
              onHighlightChanged: (v) => setState(() => _pressionado = v),
              onFocusChange: (v) => setState(() => _foco = v),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PFSpacing.l,
                    vertical: PFSpacing.m,
                  ),
                  child: Center(widthFactor: 1, child: conteudo),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
