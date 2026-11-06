import 'package:flutter/material.dart';

import '../models/pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_estado_vazio.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_skeleton.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_top_bar.dart';
import '../widgets/pedido_card.dart';

/// Histórico com carregamento simulado (skeleton), pesquisa e estado vazio.
class HistoricoScreen extends StatefulWidget {
  final bool prestador;

  const HistoricoScreen({super.key, required this.prestador});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  final TextEditingController _pesquisa = TextEditingController();
  bool _carregado = false;
  String? _erro;

  /// Pedidos terminados (concluídos ou cancelados) vindos do servidor.
  List<Pedido> _historico = [];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void dispose() {
    _pesquisa.dispose();
    super.dispose();
  }

  /// GET /pedidos (a API só dá histórico ao cliente; ao prestador
  /// devolve apenas os pedidos ativos).
  Future<void> _carregar() async {
    try {
      final lista = await Api.meusPedidos();
      if (!mounted) return;
      setState(() {
        _historico = lista.where((p) => !p.ativo).toList();
        _erro = null;
        _carregado = true;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _carregado = true;
      });
    }
  }

  List<Pedido> get _filtrados {
    final base = _historico;
    final termo = _pesquisa.text.trim().toLowerCase();
    if (termo.isEmpty) return base;
    return base
        .where((p) =>
            p.titulo.toLowerCase().contains(termo) ||
            p.categoria.toLowerCase().contains(termo) ||
            p.contraparte.toLowerCase().contains(termo))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PFTopBar(titulo: 'Histórico'),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PFSpacing.margem,
                PFSpacing.s,
                PFSpacing.margem,
                PFSpacing.l,
              ),
              child: PFTextField(
                etiqueta: 'Pesquisar',
                dica: 'Serviço ou prestador',
                controlador: _pesquisa,
                iconePrefixo: PFIcons.pesquisa,
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: !_carregado
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: PFSpacing.margem,
                      ),
                      child: PFListaSkeleton(itens: 4),
                    )
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
                          icone: PFIcons.pesquisa,
                          titulo: _historico.isEmpty
                              ? 'Ainda sem histórico'
                              : 'Sem resultados',
                          texto: _historico.isEmpty
                              ? (widget.prestador
                                  ? 'Os serviços terminados ainda não vêm do servidor (a API só lista os pedidos ativos do prestador).'
                                  : 'Os pedidos terminados aparecem aqui.')
                              : 'Tente outro nome de serviço ou de prestador.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            PFSpacing.margem,
                            0,
                            PFSpacing.margem,
                            PFSpacing.l,
                          ),
                          itemCount: lista.length,
                          itemBuilder: (context, i) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: PFSpacing.m),
                            child: PedidoCard(
                              pedido: lista[i],
                              onTap: () => PFFeedback.mostrar(
                                context,
                                PFTipoFeedback.info,
                                'O detalhe do pedido fica para a versão final.',
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
