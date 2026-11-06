import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_acordeao.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_top_bar.dart';

/// Ajuda: perguntas frequentes e acesso ao suporte (RF29).
class AjudaScreen extends StatelessWidget {
  const AjudaScreen({super.key});

  static const List<PFItemAcordeao> _perguntas = [
    PFItemAcordeao(
      'Quanto tempo demora a chegar um prestador?',
      'Em geral, entre 16 e 20 minutos. Vê a estimativa antes de confirmar e acompanha o prestador no mapa.',
    ),
    PFItemAcordeao(
      'Como sei quanto vou pagar?',
      'Antes de confirmar, mostramos uma estimativa em euros. O valor final só muda se o prestador o confirmar consigo.',
    ),
    PFItemAcordeao(
      'Para que serve o QR de chegada?',
      'Serve para validar o serviço com o prestador. Neste protótipo a validação por QR é apenas simulada.',
    ),
    PFItemAcordeao(
      'Posso cancelar um pedido?',
      'Sim. No acompanhamento, escolha "Cancelar pedido" e confirme. Se precisar de ajuda, fale com o suporte.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: 'Ajuda',
              subtitulo: 'Perguntas frequentes',
              onVoltar: () => Navigator.of(context).maybePop(),
            ),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  PFSpacing.margem,
                  PFSpacing.s,
                  PFSpacing.margem,
                  PFSpacing.l,
                ),
                child: PFAcordeao(itens: _perguntas),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PFSpacing.margem,
                PFSpacing.s,
                PFSpacing.margem,
                PFSpacing.m,
              ),
              child: PFButton(
                texto: 'Falar com o suporte',
                icone: PFIcons.chat,
                onPressed: () => Navigator.of(context).pushNamed(
                  AppRoutes.chat,
                  arguments: 'Suporte ProntoFix',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
