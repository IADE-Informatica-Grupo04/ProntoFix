import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_estado_vazio.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_tabs.dart';
import '../widgets/pf_top_bar.dart';
import '../widgets/pedido_card.dart';

/// Lista de pedidos em curso, em dois separadores: Ativos e Agendados.
class PedidosScreen extends StatefulWidget {
  final bool prestador;

  const PedidosScreen({super.key, required this.prestador});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  int _separador = 0;
  List<Pedido> _pedidos = [];
  bool _aCarregar = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  /// GET /pedidos (cliente) ou GET /prestadores/me/pedidos (prestador).
  Future<void> _carregar() async {
    try {
      final lista = await Api.meusPedidos();
      if (!mounted) return;
      setState(() {
        _pedidos = lista;
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

  /// Pedido "agendado": urgência Normal ou Hoje e o prestador ainda não saiu.
  bool _agendado(Pedido p) =>
      p.urgencia != 'Agora' &&
      (p.estado == EstadoPedido.procurar || p.estado == EstadoPedido.atribuido);

  /// Em curso, ou concluído mas ainda por pagar (cliente).
  bool _emCurso(Pedido p) =>
      p.ativo ||
      (!widget.prestador && p.porPagar);

  List<Pedido> get _lista {
    final emCurso = _pedidos.where(_emCurso);
    return _separador == 0
        ? emCurso.where((p) => !_agendado(p)).toList()
        : emCurso.where(_agendado).toList();
  }

  Future<void> _abrir(Pedido pedido) async {
    if (widget.prestador) {
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.info,
        'Gira este serviço no separador Início.',
      );
      return;
    }
    await Navigator.of(context).pushNamed(
      AppRoutes.acompanhamento,
      arguments: pedido.id,
    );
    if (mounted) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _lista;
    final bool ativos = _separador == 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PFTopBar(titulo: 'Pedidos'),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PFSpacing.margem,
                PFSpacing.s,
                PFSpacing.margem,
                PFSpacing.l,
              ),
              child: PFTabs(
                rotulos: const ['Ativos', 'Agendados'],
                indice: _separador,
                onChanged: (i) => setState(() => _separador = i),
              ),
            ),
            Expanded(
              child: _aCarregar
                  ? const Center(child: CircularProgressIndicator())
                  : _erro != null
                  ? PFEstadoVazio(
                      icone: PFIcons.aviso,
                      titulo: 'Sem ligação',
                      texto: _erro!,
                      acaoTexto: 'Tentar de novo',
                      onAcao: _carregar,
                    )
                  : lista.isEmpty
                  ? PFEstadoVazio(
                      icone: ativos ? PFIcons.lista : PFIcons.relogio,
                      titulo: ativos
                          ? 'Sem pedidos ativos'
                          : 'Sem pedidos agendados',
                      texto: widget.prestador
                          ? 'Quando aceitar um pedido, ele aparece aqui.'
                          : 'Quando precisar de ajuda, peça em poucos toques.',
                      acaoTexto: widget.prestador ? null : 'Pedir ajuda já',
                      onAcao: widget.prestador
                          ? null
                          : () async {
                              await Navigator.of(context)
                                  .pushNamed(AppRoutes.novoPedido);
                              if (mounted) _carregar();
                            },
                    )
                  : RefreshIndicator(
                    onRefresh: _carregar,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        PFSpacing.margem,
                        0,
                        PFSpacing.margem,
                        PFSpacing.l,
                      ),
                      itemCount: lista.length,
                      itemBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.only(bottom: PFSpacing.m),
                        child: PedidoCard(
                          pedido: lista[i],
                          onTap: () => _abrir(lista[i]),
                        ),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
