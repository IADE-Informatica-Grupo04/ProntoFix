import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_chip.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_top_bar.dart';

/// Perfil: dados da conta, definições simuladas, ajuda e terminar sessão.
class PerfilScreen extends StatelessWidget {
  final bool prestador;

  const PerfilScreen({super.key, required this.prestador});

  void _emBreve(BuildContext context) {
    PFFeedback.mostrar(
      context,
      PFTipoFeedback.info,
      'Esta opção fica para a versão final.',
    );
  }

  Future<void> _terminarSessao(BuildContext context) async {
    final bool sair = await PFDialogo.confirmar(
      context,
      icone: PFIcons.sair,
      titulo: 'Terminar sessão?',
      texto: 'Vai voltar ao ecrã inicial.',
      textoSeguro: 'Ficar',
      textoAcao: 'Terminar sessão',
      destrutivo: true,
    );
    if (sair && context.mounted) {
      Api.terminarSessao(); // apaga o token da sessão
      Navigator.of(context)
          .pushNamedAndRemoveUntil(AppRoutes.splash, (rota) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dados da conta com sessão iniciada (vêm do login no servidor).
    final String nome = Api.utilizador?.nome ?? '—';
    final String email = Api.utilizador?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PFTopBar(titulo: 'Perfil'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PFSpacing.margem,
                  PFSpacing.s,
                  PFSpacing.margem,
                  PFSpacing.l,
                ),
                children: [
                  PFCard(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: PFColors.tint,
                          child: Text(
                            nome.isEmpty ? '?' : nome.substring(0, 1),
                            style: PFText.h3.copyWith(
                              color: PFColors.primaryPressed,
                            ),
                          ),
                        ),
                        const SizedBox(width: PFSpacing.l),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nome, style: PFText.h3),
                              const SizedBox(height: 2),
                              Text(email, style: PFText.secundario),
                              const SizedBox(height: PFSpacing.s),
                              PFTag(
                                texto: prestador
                                    ? 'Prestador verificado'
                                    : 'Cliente',
                                tipo: prestador
                                    ? PFTagTipo.sucesso
                                    : PFTagTipo.info,
                                icone:
                                    prestador ? PFIcons.verificado : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PFSpacing.l),
                  PFCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _Linha(
                          icone: PFIcons.localizacao,
                          texto: prestador ? 'Zonas de atuação' : 'Moradas',
                          onTap: () => _emBreve(context),
                        ),
                        const _Divisor(),
                        _Linha(
                          icone: PFIcons.cartao,
                          texto: prestador ? 'Recebimentos' : 'Pagamentos',
                          onTap: () => _emBreve(context),
                        ),
                        const _Divisor(),
                        _Linha(
                          icone: PFIcons.sino,
                          texto: 'Notificações',
                          onTap: () => _emBreve(context),
                        ),
                        const _Divisor(),
                        _Linha(
                          icone: PFIcons.ajuda,
                          texto: 'Ajuda',
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.ajuda),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PFSpacing.xxl),
                  PFButton(
                    texto: 'Terminar sessão',
                    icone: PFIcons.sair,
                    variante: PFVariante.contornoDestrutivo,
                    onPressed: () => _terminarSessao(context),
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

class _Divisor extends StatelessWidget {
  const _Divisor();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: PFColors.border);
  }
}

class _Linha extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;

  const _Linha({
    required this.icone,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: PFSpacing.l),
          child: Row(
            children: [
              Icon(icone, size: 24, color: PFColors.primaryPressed),
              const SizedBox(width: PFSpacing.l),
              Expanded(child: Text(texto, style: PFText.corpoForte)),
              const Icon(PFIcons.direita, size: 20, color: PFColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
