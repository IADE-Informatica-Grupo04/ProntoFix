import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_logo.dart';

/// Ecrã inicial (versão sobre navy do logótipo): proposta de valor e entrada.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color _vidro = Color(0x1FFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PFColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  PFSpacing.margem,
                  PFSpacing.xxl,
                  PFSpacing.margem,
                  PFSpacing.l,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PFLogo(tamanho: 44, escuro: true),
                    const SizedBox(height: PFSpacing.xxxl),
                    const _Selo(texto: '24/7 urgência doméstica'),
                    const SizedBox(height: PFSpacing.l),
                    Text(
                      'Reparações urgentes, a poucos toques.',
                      style: PFText.h1.copyWith(
                        color: PFColors.surface,
                        fontSize: 32,
                        height: 38 / 32,
                      ),
                    ),
                    const SizedBox(height: PFSpacing.m),
                    Text(
                      'Um pedido. Um prestador. Um mapa. Uma solução rápida.',
                      style: PFText.corpo.copyWith(color: PFColors.border),
                    ),
                    const SizedBox(height: PFSpacing.xxl),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PFSpacing.xl),
                      decoration: BoxDecoration(
                        color: _vidro,
                        borderRadius: BorderRadius.circular(PFRadius.cartao),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: PFColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              PFIcons.localizacao,
                              size: 32,
                              color: PFColors.surface,
                            ),
                          ),
                          const SizedBox(height: PFSpacing.l),
                          Row(
                            children: [
                              for (final servico in servicos)
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: const BoxDecoration(
                                          color: _vidro,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          servico.icone,
                                          size: 24,
                                          color: PFColors.surface,
                                        ),
                                      ),
                                      const SizedBox(height: PFSpacing.s),
                                      Text(
                                        servico.nome,
                                        textAlign: TextAlign.center,
                                        style: PFText.secundario.copyWith(
                                          color: PFColors.surface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PFSpacing.l),
                    const Wrap(
                      spacing: PFSpacing.s,
                      runSpacing: PFSpacing.s,
                      children: [
                        _Selo(texto: 'Preço claro', icone: PFIcons.recibo),
                        _Selo(texto: 'Mapa ao vivo', icone: PFIcons.mapa),
                        _Selo(texto: 'QR seguro', icone: PFIcons.qr),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PFSpacing.margem,
                PFSpacing.s,
                PFSpacing.margem,
                PFSpacing.m,
              ),
              child: Column(
                children: [
                  PFButton(
                    texto: 'Começar em 30 segundos',
                    iconeDepois: PFIcons.direita,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.registo),
                  ),
                  const SizedBox(height: PFSpacing.s),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, PFSpacing.alvo),
                      foregroundColor: PFColors.surface,
                    ),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.login),
                    child: Text(
                      'Já tenho conta',
                      style: PFText.corpoForte.copyWith(
                        color: PFColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  final String texto;
  final IconData? icone;

  const _Selo({required this.texto, this.icone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PFSpacing.m,
        vertical: PFSpacing.s,
      ),
      decoration: BoxDecoration(
        color: SplashScreen._vidro,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 16, color: PFColors.accent),
            const SizedBox(width: 6),
          ],
          Text(
            texto,
            style: PFText.secundario.copyWith(
              color: PFColors.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
