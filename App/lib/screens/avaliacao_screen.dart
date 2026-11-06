import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/mock_data.dart';
import '../models/prestador.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_top_bar.dart';

/// Avaliação do serviço, em ecrã próprio (RF31). Estrelas vazias por defeito;
/// só se pode enviar depois de escolher pelo menos uma.
class AvaliacaoScreen extends StatefulWidget {
  /// Id do pedido no servidor.
  final int? pedidoId;

  const AvaliacaoScreen({super.key, this.pedidoId});

  @override
  State<AvaliacaoScreen> createState() => _AvaliacaoScreenState();
}

class _AvaliacaoScreenState extends State<AvaliacaoScreen> {
  final TextEditingController _comentario = TextEditingController();
  int _estrelas = 0;
  bool _aEnviar = false;
  Prestador _prestador = prestadorAtribuido;

  @override
  void initState() {
    super.initState();
    _carregarPrestador();
  }

  /// Nome do prestador que fez o serviço (GET /pedidos/:id).
  Future<void> _carregarPrestador() async {
    if (widget.pedidoId == null) return;
    try {
      final p = await Api.pedido(widget.pedidoId!);
      if (mounted && p.prestador != null) {
        setState(() => _prestador = p.prestador!);
      }
    } on ApiException {
      // fica o nome por omissão
    }
  }

  static const List<String> _frases = [
    'Toque numa estrela',
    'Muito mau',
    'Mau',
    'Razoável',
    'Bom',
    'Excelente',
  ];

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _irParaInicio() {
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
  }

  Future<void> _enviar() async {
    setState(() => _aEnviar = true);
    try {
      // POST /pedidos/:id/avaliacao
      if (widget.pedidoId != null) {
        await Api.avaliar(
          widget.pedidoId!,
          _estrelas,
          _comentario.text.trim(),
        );
      }
      if (!mounted) return;
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.sucesso,
        'Obrigado pela sua avaliação.',
      );
      _irParaInicio();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _aEnviar = false);
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? resultado) {
        if (!didPop) _irParaInicio();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PFTopBar(
                titulo: 'Avaliar serviço',
                subtitulo: 'Ajude outros clientes',
                onVoltar: _irParaInicio,
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
                    Center(
                      child: Text(
                        'Como foi o serviço de ${_prestador.nome}?',
                        textAlign: TextAlign.center,
                        style: PFText.h3,
                      ),
                    ),
                    const SizedBox(height: PFSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          Semantics(
                            button: true,
                            selected: i <= _estrelas,
                            label: i == 1 ? '1 estrela' : '$i estrelas',
                            excludeSemantics: true,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _estrelas = i),
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  i <= _estrelas
                                      ? Icons.star_rounded
                                      : PFIcons.estrela,
                                  size: 40,
                                  color: i <= _estrelas
                                      ? PFColors.warning
                                      : PFColors.muted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: PFSpacing.s),
                    Center(
                      child: Text(
                        _frases[_estrelas],
                        style: PFText.corpoForte,
                      ),
                    ),
                    const SizedBox(height: PFSpacing.xl),
                    PFTextField(
                      etiqueta: 'Comentário',
                      dica: 'Diga-nos o que correu bem ou mal',
                      opcional: true,
                      controlador: _comentario,
                      linhas: 3,
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
                child: Column(
                  children: [
                    PFButton(
                      texto: 'Enviar avaliação',
                      carregando: _aEnviar,
                      onPressed: _estrelas > 0 && !_aEnviar ? _enviar : null,
                    ),
                    const SizedBox(height: PFSpacing.s),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize:
                            const Size(double.infinity, PFSpacing.alvo),
                      ),
                      onPressed: _irParaInicio,
                      child: Text(
                        'Saltar',
                        style: PFText.corpoForte.copyWith(
                          color: PFColors.primaryPressed,
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
    );
  }
}
