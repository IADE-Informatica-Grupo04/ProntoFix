import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/mock_data.dart';
import '../models/pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_chip.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_top_bar.dart';

/// Passo 3 de 3: pagamento (simulado). A avaliação é um ecrã separado (RF31).
class PagamentoScreen extends StatefulWidget {
  /// Id do pedido no servidor.
  final int? pedidoId;

  const PagamentoScreen({super.key, this.pedidoId});

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  static const List<String> _metodos = ['MB Way', 'Cartão', 'Dinheiro'];
  String _metodo = 'MB Way';
  bool _aPagar = false;

  /// Pedido concluído, com os valores definidos pelo prestador.
  Pedido? _pedido;

  String get _total =>
      _pedido?.total != null ? euros(_pedido!.total!) : totalServico;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  /// GET /pedidos/:id
  Future<void> _carregar() async {
    if (widget.pedidoId == null) return;
    try {
      final p = await Api.pedido(widget.pedidoId!);
      if (mounted) setState(() => _pedido = p);
    } on ApiException catch (e) {
      if (mounted) PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  Future<void> _pagar() async {
    final bool confirmar = await PFDialogo.confirmar(
      context,
      icone: PFIcons.cartao,
      titulo: 'Confirmar pagamento?',
      texto: 'Vai pagar $_total com $_metodo.',
      textoSeguro: 'Voltar',
      textoAcao: 'Pagar',
    );
    if (!confirmar || !mounted) return;
    setState(() => _aPagar = true);
    try {
      // A API ainda não tem rota de pagamento: fica simulado na app.
      if (widget.pedidoId != null) {
        await Api.pagar(widget.pedidoId!, _metodo);
      }
      if (!mounted) return;
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.sucesso,
        'Pagamento de $_total concluído.',
      );
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.avaliacao,
        arguments: widget.pedidoId,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _aPagar = false);
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: 'Pagamento',
              subtitulo:
                  'Serviço de ${(_pedido?.categoria ?? 'reparação').toLowerCase()}',
              passo: 3,
              onVoltar: _aPagar ? null : () => Navigator.of(context).maybePop(),
            ),
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
                    child: Column(
                      children: [
                        _LinhaRecibo(
                          'Estimativa',
                          _pedido?.precoEstimado != null
                              ? euros(_pedido!.precoEstimado!)
                              : '—',
                        ),
                        const SizedBox(height: PFSpacing.m),
                        _LinhaRecibo(
                          'Preço final do prestador',
                          _pedido?.precoFinal != null
                              ? euros(_pedido!.precoFinal!)
                              : '—',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: PFSpacing.m),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: PFColors.border,
                          ),
                        ),
                        _LinhaRecibo('Total', _total, forte: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: PFSpacing.xl),
                  Text('Método de pagamento', style: PFText.corpoForte),
                  const SizedBox(height: PFSpacing.s),
                  Wrap(
                    spacing: PFSpacing.s,
                    runSpacing: PFSpacing.s,
                    children: [
                      for (final m in _metodos)
                        PFChip(
                          texto: m,
                          selecionado: _metodo == m,
                          onTap: _aPagar
                              ? null
                              : () => setState(() => _metodo = m),
                        ),
                    ],
                  ),
                  const SizedBox(height: PFSpacing.xl),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        PFIcons.verificado,
                        size: 20,
                        color: PFColors.successText,
                      ),
                      const SizedBox(width: PFSpacing.s),
                      Expanded(
                        child: Text(
                          'Pagamento simulado. Não é cobrado nenhum valor real.',
                          style: PFText.secundario,
                        ),
                      ),
                    ],
                  ),
                ],
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
                texto: 'Pagar $totalServico',
                carregando: _aPagar,
                onPressed: _aPagar ? null : _pagar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinhaRecibo extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool forte;

  const _LinhaRecibo(this.rotulo, this.valor, {this.forte = false});

  @override
  Widget build(BuildContext context) {
    final TextStyle estilo = forte ? PFText.h3 : PFText.corpo;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(rotulo, style: estilo),
        Text(valor, style: estilo),
      ],
    );
  }
}
