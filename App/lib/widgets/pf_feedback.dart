import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import 'pf_button.dart';

/// Tipos de feedback do Style Guide 7.6: sucesso (verde), aviso (laranja),
/// erro (vermelho) e informação (azul). Cada um leva ícone + texto.
enum PFTipoFeedback { sucesso, aviso, erro, info }

class _EstiloFeedback {
  final Color fundo;
  final Color texto;
  final IconData icone;

  const _EstiloFeedback(this.fundo, this.texto, this.icone);
}

class PFFeedback {
  PFFeedback._();

  static _EstiloFeedback _estilo(PFTipoFeedback tipo) {
    switch (tipo) {
      case PFTipoFeedback.sucesso:
        return const _EstiloFeedback(
          PFColors.successBg,
          PFColors.successText,
          PFIcons.certo,
        );
      case PFTipoFeedback.aviso:
        return const _EstiloFeedback(
          PFColors.warningBg,
          PFColors.warningText,
          PFIcons.aviso,
        );
      case PFTipoFeedback.erro:
        return const _EstiloFeedback(
          PFColors.errorBg,
          PFColors.error,
          PFIcons.fechar,
        );
      case PFTipoFeedback.info:
        return const _EstiloFeedback(
          PFColors.tint,
          PFColors.primaryPressed,
          PFIcons.info,
        );
    }
  }

  /// Mostra uma mensagem curta no fundo do ecrã, com ícone e texto.
  static void mostrar(
    BuildContext context,
    PFTipoFeedback tipo,
    String mensagem, {
    String? acaoTexto,
    VoidCallback? onAcao,
  }) {
    final estilo = _estilo(tipo);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: estilo.fundo,
        elevation: 0,
        duration: Duration(seconds: acaoTexto != null ? 6 : 4),
        margin: const EdgeInsets.fromLTRB(
          PFSpacing.margem,
          0,
          PFSpacing.margem,
          PFSpacing.l,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PFRadius.botao),
          side: BorderSide(color: estilo.texto),
        ),
        content: Row(
          children: [
            Icon(estilo.icone, size: 24, color: estilo.texto),
            const SizedBox(width: PFSpacing.m),
            Expanded(
              child: Text(
                mensagem,
                style: PFText.secundario.copyWith(
                  color: estilo.texto,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        action: acaoTexto == null
            ? null
            : SnackBarAction(
                label: acaoTexto,
                textColor: estilo.texto,
                onPressed: onAcao ?? () {},
              ),
      ),
    );
  }
}

/// Diálogo de confirmação para ações críticas (RU09). A opção segura fica à
/// esquerda, com o mesmo peso visual, e os botões separados por 16 px.
class PFDialogo {
  PFDialogo._();

  static Future<bool> confirmar(
    BuildContext context, {
    required String titulo,
    required String texto,
    required String textoSeguro,
    required String textoAcao,
    bool destrutivo = false,
    IconData? icone,
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: PFColors.surface,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: PFSpacing.margem,
          vertical: PFSpacing.xxl,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PFRadius.cartao),
        ),
        child: Padding(
          padding: const EdgeInsets.all(PFSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icone != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: PFColors.tint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icone, size: 24, color: PFColors.primaryPressed),
                ),
                const SizedBox(height: PFSpacing.l),
              ],
              Text(titulo, style: PFText.h4),
              const SizedBox(height: PFSpacing.s),
              Text(
                texto,
                style: PFText.corpo.copyWith(color: PFColors.textSecondary),
              ),
              const SizedBox(height: PFSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PFButton(
                      texto: textoSeguro,
                      variante: PFVariante.contorno,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: PFSpacing.l),
                  Expanded(
                    child: PFButton(
                      texto: textoAcao,
                      variante: destrutivo
                          ? PFVariante.destrutivo
                          : PFVariante.primario,
                      onPressed: () => Navigator.of(ctx).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return resultado ?? false;
  }
}
