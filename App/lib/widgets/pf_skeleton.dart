import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'pf_card.dart';

/// Bloco cinzento que pulsa suavemente: carregamento sem ecrã em branco.
class PFSkeleton extends StatefulWidget {
  final double? largura;
  final double altura;
  final double raio;

  const PFSkeleton({
    super.key,
    this.largura,
    this.altura = 16,
    this.raio = 8,
  });

  @override
  State<PFSkeleton> createState() => _PFSkeletonState();
}

class _PFSkeletonState extends State<PFSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _opacidade = Tween<double>(begin: 0.45, end: 1)
      .animate(CurvedAnimation(parent: _controlador, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacidade,
      child: Container(
        width: widget.largura,
        height: widget.altura,
        decoration: BoxDecoration(
          color: PFColors.border,
          borderRadius: BorderRadius.circular(widget.raio),
        ),
      ),
    );
  }
}

/// Lista de cartões de carregamento (placeholder animado).
class PFListaSkeleton extends StatelessWidget {
  final int itens;

  const PFListaSkeleton({super.key, this.itens = 3});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'A carregar',
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          PFSpacing.margem,
          PFSpacing.s,
          PFSpacing.margem,
          PFSpacing.xl,
        ),
        itemCount: itens,
        itemBuilder: (context, indice) => const Padding(
          padding: EdgeInsets.only(bottom: PFSpacing.m),
          child: PFCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PFSkeleton(largura: 44, altura: 44, raio: 22),
                SizedBox(width: PFSpacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PFSkeleton(altura: 18),
                      SizedBox(height: PFSpacing.s),
                      PFSkeleton(largura: 140, altura: 14),
                      SizedBox(height: PFSpacing.m),
                      PFSkeleton(largura: 96, altura: 24, raio: 12),
                    ],
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
