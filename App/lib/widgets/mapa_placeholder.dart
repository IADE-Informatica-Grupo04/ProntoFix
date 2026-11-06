import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';

/// Mapa simulado (sem serviços externos): ruas desenhadas, marcador da morada
/// e, opcionalmente, o prestador e o seu trajeto. Marcadores de 44 px (RM07).
class MapaPlaceholder extends StatelessWidget {
  final double altura;
  final bool mostrarPrestador;
  final List<Widget> sobreposicoes;

  const MapaPlaceholder({
    super.key,
    this.altura = 240,
    this.mostrarPrestador = false,
    this.sobreposicoes = const [],
  });

  static const double _marcador = 44;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: mostrarPrestador
          ? 'Mapa com a sua morada e o prestador a caminho'
          : 'Mapa com a sua morada',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PFRadius.cartao),
        child: SizedBox(
          height: altura,
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, caixa) {
              final double l = caixa.maxWidth;
              final double a = caixa.maxHeight;
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _MapaPainter(mostrarRota: mostrarPrestador),
                    ),
                  ),
                  if (mostrarPrestador)
                    Positioned(
                      left: l * 0.25 - _marcador / 2,
                      top: a * 0.78 - _marcador / 2,
                      child: Container(
                        width: _marcador,
                        height: _marcador,
                        decoration: BoxDecoration(
                          color: PFColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: PFColors.surface, width: 3),
                        ),
                        child: const Icon(
                          PFIcons.chaveInglesa,
                          size: 22,
                          color: PFColors.navy,
                        ),
                      ),
                    ),
                  Positioned(
                    left: l * 0.64 - _marcador / 2,
                    top: a * 0.5 - _marcador / 2,
                    child: Container(
                      width: _marcador,
                      height: _marcador,
                      decoration: BoxDecoration(
                        color: PFColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: PFColors.surface, width: 3),
                      ),
                      child: const Icon(
                        PFIcons.localizacao,
                        size: 22,
                        color: PFColors.surface,
                      ),
                    ),
                  ),
                  ...sobreposicoes,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MapaPainter extends CustomPainter {
  final bool mostrarRota;

  const _MapaPainter({required this.mostrarRota});

  @override
  void paint(Canvas canvas, Size size) {
    final double l = size.width;
    final double a = size.height;

    canvas.drawRect(Offset.zero & size, Paint()..color = PFColors.mapa);

    // Parque
    canvas.drawCircle(
      Offset(l * 0.84, a * 0.2),
      l * 0.13,
      Paint()..color = PFColors.successBg,
    );

    final Paint rua = Paint()
      ..color = PFColors.surface
      ..strokeCap = StrokeCap.round;

    rua.strokeWidth = 14;
    canvas.drawLine(Offset(0, a * 0.3), Offset(l, a * 0.3), rua);
    canvas.drawLine(Offset(0, a * 0.78), Offset(l, a * 0.78), rua);
    rua.strokeWidth = 10;
    canvas.drawLine(Offset(l * 0.25, 0), Offset(l * 0.25, a), rua);
    canvas.drawLine(Offset(l * 0.64, 0), Offset(l * 0.64, a), rua);
    rua.strokeWidth = 8;
    canvas.drawLine(Offset(l * 0.9, 0), Offset(l * 0.45, a), rua);

    if (mostrarRota) {
      final Paint rota = Paint()
        ..color = PFColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final Path caminho = Path()
        ..moveTo(l * 0.25, a * 0.78)
        ..lineTo(l * 0.64, a * 0.78)
        ..lineTo(l * 0.64, a * 0.5);
      canvas.drawPath(caminho, rota);
    }
  }

  @override
  bool shouldRepaint(covariant _MapaPainter antigo) =>
      antigo.mostrarRota != mostrarRota;
}
