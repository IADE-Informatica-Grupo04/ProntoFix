import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/mock_data.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_titulo_seccao.dart';
import '../widgets/pf_top_bar.dart';
import '../widgets/pedido_card.dart';

/// Início do cliente: pedir ajuda em 1 toque, escolher serviço e ver o pedido
/// ativo. O botão principal fica sempre visível (RU01: pedido em ≤ 5 toques).
class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});

  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  List<Pedido> _ativos = [];
  bool _aCarregar = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  /// GET /pedidos — fica só com os pedidos em curso.
  Future<void> _carregar() async {
    try {
      final pedidos = await Api.meusPedidos();
      if (!mounted) return;
      setState(() {
        _ativos = pedidos.where((p) => p.ativo || p.porPagar).toList();
        _erro = null;
        _aCarregar = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _aCarregar = false;
      });
    }
  }

  /// Abre um ecrã e, ao voltar, atualiza os pedidos.
  Future<void> _abrir(String rota, {Object? argumentos}) async {
    await Navigator.of(context).pushNamed(rota, arguments: argumentos);
    if (mounted) _carregar();
  }

  /// A API não tem notificações: mostra o estado do pedido mais recente.
  void _notificacoes() {
    final String texto = _ativos.isEmpty
        ? 'Sem notificações novas.'
        : '${_ativos.first.categoria}: ${_ativos.first.estado.rotulo}.';
    PFFeedback.mostrar(context, PFTipoFeedback.info, texto);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: 'Olá, ${Api.utilizador?.primeiroNome ?? ''}',
              subtitulo: 'O que precisa de reparar?',
              trailing: PFBotaoIcone(
                icone: PFIcons.sino,
                rotulo: 'Notificações',
                onTap: _notificacoes,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _carregar,
                child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PFSpacing.margem,
                  PFSpacing.s,
                  PFSpacing.margem,
                  PFSpacing.l,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(PFSpacing.xl),
                    decoration: BoxDecoration(
                      color: PFColors.primary,
                      borderRadius: BorderRadius.circular(PFRadius.cartao),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precisa de ajuda agora?',
                                style: PFText.h3.copyWith(
                                  color: PFColors.surface,
                                ),
                              ),
                              const SizedBox(height: PFSpacing.xs),
                              Text(
                                'Prestadores verificados chegam em cerca de 18 min.',
                                style: PFText.secundario.copyWith(
                                  color: PFColors.surface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: PFSpacing.m),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0x33FFFFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            PFIcons.verificado,
                            size: 24,
                            color: PFColors.surface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PFTituloSeccao('Escolha o serviço'),
                  Row(
                    children: [
                      for (int i = 0; i < servicos.length; i++) ...[
                        if (i > 0) const SizedBox(width: PFSpacing.m),
                        Expanded(
                          child: _ServicoTile(
                            nome: servicos[i].nome,
                            icone: servicos[i].icone,
                            fundo: servicos[i].corFundo,
                            onTap: () => _abrir(
                              AppRoutes.novoPedido,
                              argumentos: servicos[i].nome,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const PFTituloSeccao('Pedido ativo'),
                  if (_aCarregar)
                    const Center(child: CircularProgressIndicator())
                  else if (_erro != null)
                    PFCard(
                      cor: PFColors.warningBg,
                      corBorda: PFColors.warningBg,
                      onTap: _carregar,
                      child: Text(
                        '$_erro Toque para tentar de novo.',
                        style: PFText.secundario.copyWith(
                          color: PFColors.warningText,
                        ),
                      ),
                    )
                  else if (_ativos.isEmpty)
                    Text(
                      'Sem pedidos em curso.',
                      style: PFText.secundario,
                    )
                  else
                    for (final pedido in _ativos)
                      Padding(
                        padding: const EdgeInsets.only(bottom: PFSpacing.m),
                        child: PedidoCard(
                          pedido: pedido,
                          onTap: () => _abrir(
                            AppRoutes.acompanhamento,
                            argumentos: pedido.id,
                          ),
                        ),
                      ),
                  const SizedBox(height: PFSpacing.l),
                  PFCard(
                    cor: PFColors.successBg,
                    corBorda: PFColors.successBg,
                    child: Row(
                      children: [
                        const Icon(
                          PFIcons.verificado,
                          size: 24,
                          color: PFColors.successText,
                        ),
                        const SizedBox(width: PFSpacing.m),
                        Expanded(
                          child: Text(
                            'Vê o preço estimado antes de confirmar. Sem custos escondidos.',
                            style: PFText.secundario.copyWith(
                              color: PFColors.successText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                PFSpacing.s,
              ),
              child: PFButton(
                texto: 'Pedir ajuda já',
                icone: PFIcons.raio,
                onPressed: () => _abrir(AppRoutes.novoPedido),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicoTile extends StatelessWidget {
  final String nome;
  final IconData icone;
  final Color fundo;
  final VoidCallback onTap;

  const _ServicoTile({
    required this.nome,
    required this.icone,
    required this.fundo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: nome,
      excludeSemantics: true,
      child: Material(
        color: PFColors.surface,
        borderRadius: BorderRadius.circular(PFRadius.cartao),
        child: InkWell(
          borderRadius: BorderRadius.circular(PFRadius.cartao),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: PFSpacing.l,
              horizontal: PFSpacing.s,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PFRadius.cartao),
              border: Border.all(color: PFColors.border),
            ),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: fundo, shape: BoxShape.circle),
                  child: Icon(icone, size: 24, color: PFColors.navy),
                ),
                const SizedBox(height: PFSpacing.s),
                Text(
                  nome,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PFText.secundario.copyWith(
                    color: PFColors.text,
                    fontWeight: FontWeight.w600,
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
