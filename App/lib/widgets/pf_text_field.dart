import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Campo de formulário (Style Guide 7.2): 48 px, raio 14 px.
/// Estados: normal, foco (borda azul), erro (borda vermelha + ícone + texto),
/// sucesso (borda verde + visto) e desativado. Palavra-passe com mostrar/ocultar.
class PFTextField extends StatefulWidget {
  final String etiqueta;
  final String dica;
  final TextEditingController? controlador;
  final bool ocultar;
  final bool opcional;
  final bool sucesso;
  final bool ativo;
  final String? erro;
  final String? ajuda;
  final int linhas;
  final TextInputType? teclado;
  final IconData? iconePrefixo;
  final ValueChanged<String>? onChanged;

  const PFTextField({
    super.key,
    required this.etiqueta,
    required this.dica,
    this.controlador,
    this.ocultar = false,
    this.opcional = false,
    this.sucesso = false,
    this.ativo = true,
    this.erro,
    this.ajuda,
    this.linhas = 1,
    this.teclado,
    this.iconePrefixo,
    this.onChanged,
  });

  @override
  State<PFTextField> createState() => _PFTextFieldState();
}

class _PFTextFieldState extends State<PFTextField> {
  final FocusNode _foco = FocusNode();
  bool _mostrar = false;

  @override
  void initState() {
    super.initState();
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _foco.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool temErro = widget.erro != null;
    final bool focado = _foco.hasFocus;

    Color borda = PFColors.muted;
    double largura = 1;
    if (!widget.ativo) {
      borda = PFColors.border;
    } else if (temErro) {
      borda = PFColors.error;
      largura = 1.5;
    } else if (widget.sucesso) {
      borda = PFColors.successText;
      largura = 1.5;
    } else if (focado) {
      borda = PFColors.primary;
      largura = 1.5;
    }

    Widget? sufixo;
    if (widget.ocultar) {
      sufixo = Semantics(
        button: true,
        label: _mostrar ? 'Ocultar palavra-passe' : 'Mostrar palavra-passe',
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(PFRadius.botao),
          onTap: () => setState(() => _mostrar = !_mostrar),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: PFSpacing.alvo,
              minWidth: PFSpacing.alvo,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _mostrar ? PFIcons.olhoOculto : PFIcons.olho,
                  size: 20,
                  color: PFColors.text,
                ),
                const SizedBox(width: 4),
                Text(
                  _mostrar ? 'Ocultar' : 'Mostrar',
                  style: PFText.secundario.copyWith(
                    color: PFColors.primaryPressed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      );
    } else if (temErro) {
      sufixo = const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(PFIcons.aviso, size: 20, color: PFColors.error),
      );
    } else if (widget.sucesso) {
      sufixo = const Padding(
        padding: EdgeInsets.only(left: 8),
        child: Icon(PFIcons.certo, size: 20, color: PFColors.successText),
      );
    }

    final bool multilinha = widget.linhas > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.etiqueta,
            style: PFText.secundario.copyWith(
              color: PFColors.navy,
              fontWeight: FontWeight.w600,
            ),
            children: [
              if (widget.opcional)
                const TextSpan(
                  text: ' (opcional)',
                  style: TextStyle(
                    color: PFColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: PFSpacing.s),
        Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: PFSpacing.l),
          decoration: BoxDecoration(
            color: widget.ativo ? PFColors.surface : PFColors.background,
            borderRadius: BorderRadius.circular(PFRadius.botao),
            border: Border.all(color: borda, width: largura),
            boxShadow: focado && widget.ativo && !temErro
                ? const [
                    BoxShadow(
                      color: Color(0x332663F2),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment:
                multilinha ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (widget.iconePrefixo != null) ...[
                Padding(
                  padding: EdgeInsets.only(top: multilinha ? 14 : 0),
                  child: Icon(
                    widget.iconePrefixo,
                    size: 20,
                    color: PFColors.textSecondary,
                  ),
                ),
                const SizedBox(width: PFSpacing.m),
              ],
              Expanded(
                child: Semantics(
                  textField: true,
                  label: widget.etiqueta,
                  child: TextField(
                    controller: widget.controlador,
                    focusNode: _foco,
                    enabled: widget.ativo,
                    obscureText: widget.ocultar && !_mostrar,
                    minLines: widget.linhas,
                    maxLines: widget.ocultar
                        ? 1
                        : (multilinha ? widget.linhas + 3 : 1),
                    keyboardType: multilinha
                        ? TextInputType.multiline
                        : widget.teclado,
                    onChanged: widget.onChanged,
                    style: PFText.corpo.copyWith(
                      color: widget.ativo
                          ? PFColors.text
                          : PFColors.textSecondary,
                    ),
                    cursorColor: PFColors.primary,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.dica,
                      hintStyle: PFText.corpo.copyWith(
                        color: PFColors.textSecondary,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              if (sufixo != null) sufixo,
            ],
          ),
        ),
        if (temErro) ...[
          const SizedBox(height: PFSpacing.xs),
          Text(
            widget.erro!,
            style: PFText.secundario.copyWith(color: PFColors.error),
          ),
        ] else if (widget.ajuda != null) ...[
          const SizedBox(height: PFSpacing.xs),
          Text(widget.ajuda!, style: PFText.secundario),
        ],
      ],
    );
  }
}
