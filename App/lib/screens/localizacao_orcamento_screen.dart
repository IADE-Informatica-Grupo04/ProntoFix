import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../models/dados_pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/mapa_placeholder.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_top_bar.dart';

/// Passo 2 de 3: localização e estimativa. Pede permissão de GPS com
/// alternativa por escrito (RM02) e mostra o preço antes de confirmar.
class LocalizacaoOrcamentoScreen extends StatefulWidget {
  final DadosPedido dados;

  const LocalizacaoOrcamentoScreen({super.key, required this.dados});

  @override
  State<LocalizacaoOrcamentoScreen> createState() =>
      _LocalizacaoOrcamentoScreenState();
}

class _LocalizacaoOrcamentoScreenState
    extends State<LocalizacaoOrcamentoScreen> {
  static const String _moradaGps = 'Rua das Flores 24, 2.º Esq., Lisboa';

  final TextEditingController _morada = TextEditingController();
  bool _tentou = false;
  bool _aEnviar = false;

  /// Estimativa pedida ao servidor (POST /pedidos/estimativa).
  Estimativa? _estimativa;
  String? _erroEstimativa;

  @override
  void initState() {
    super.initState();
    _carregarEstimativa();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pedirPermissao());
  }

  Future<void> _carregarEstimativa() async {
    try {
      // POST /pedidos/estimativa {categoria_id, latitude, longitude}
      final e = await Api.estimativa(widget.dados.categoria);
      if (mounted) setState(() => _estimativa = e);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erroEstimativa = e.mensagem);
    }
  }

  @override
  void dispose() {
    _morada.dispose();
    super.dispose();
  }

  Future<void> _pedirPermissao() async {
    if (!mounted) return;
    final bool permitir = await PFDialogo.confirmar(
      context,
      icone: PFIcons.localizacao,
      titulo: 'Usar a sua localização?',
      texto:
          'Usamos o GPS para enviar o prestador certo. Se preferir, escreva a morada.',
      textoSeguro: 'Escrever morada',
      textoAcao: 'Permitir',
    );
    if (!mounted) return;
    if (permitir) {
      setState(() => _morada.text = _moradaGps);
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.sucesso,
        'Localização encontrada.',
      );
    } else {
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.info,
        'Sem problema. Escreva a morada abaixo.',
      );
    }
  }

  bool get _moradaTemNumero => RegExp(r'\d').hasMatch(_morada.text);

  String? get _erroMorada {
    if (!_tentou) return null;
    if (_morada.text.trim().isEmpty) return 'Indique a morada.';
    if (!_moradaTemNumero) return 'Indique o número da porta.';
    return null;
  }

  Future<void> _confirmar() async {
    setState(() => _tentou = true);
    if (_erroMorada != null) return;

    // POST /pedidos — o servidor guarda o pedido, atribui o prestador
    // livre mais próximo e devolve o id.
    setState(() => _aEnviar = true);
    try {
      final pedido = await Api.criarPedido(
        categoria: widget.dados.categoria,
        descricao: widget.dados.descricao,
        morada: _morada.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.acompanhamento,
        ModalRoute.withName(AppRoutes.home),
        arguments: pedido.id,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _aEnviar = false);
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = widget.dados;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: 'Onde e quanto',
              subtitulo: '${dados.categoria} · ${dados.urgencia}',
              passo: 2,
              onVoltar: () => Navigator.of(context).maybePop(),
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
                  const MapaPlaceholder(altura: 180),
                  const SizedBox(height: PFSpacing.l),
                  PFTextField(
                    etiqueta: 'Morada',
                    dica: 'Rua e número da porta',
                    controlador: _morada,
                    iconePrefixo: PFIcons.localizacao,
                    erro: _erroMorada,
                    ajuda: 'Pode usar o GPS ou escrever a morada.',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: PFSpacing.s),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(PFSpacing.alvo, PFSpacing.alvo),
                      ),
                      onPressed: _pedirPermissao,
                      icon: const Icon(
                        PFIcons.navegacao,
                        size: 20,
                        color: PFColors.primaryPressed,
                      ),
                      label: Text(
                        'Usar a minha localização',
                        style: PFText.secundario.copyWith(
                          color: PFColors.primaryPressed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: PFSpacing.l),
                  PFCard(
                    corBorda: PFColors.primary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Estimativa', style: PFText.secundario),
                        const SizedBox(height: PFSpacing.xs),
                        Text(
                          _estimativa?.precoTexto ??
                              (_erroEstimativa == null ? 'A calcular…' : '—'),
                          style: PFText.h1.copyWith(color: PFColors.text),
                        ),
                        const SizedBox(height: PFSpacing.s),
                        Row(
                          children: [
                            const Icon(
                              PFIcons.relogio,
                              size: 20,
                              color: PFColors.textSecondary,
                            ),
                            const SizedBox(width: PFSpacing.s),
                            Expanded(
                              child: Text(
                                _estimativa?.chegadaTexto ??
                                    _erroEstimativa ??
                                    'A calcular…',
                                style: PFText.corpoForte,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: PFSpacing.m),
                        Text(
                          'Sem custos escondidos: o valor final só muda se o prestador o confirmar consigo.',
                          style: PFText.secundario,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: PFSpacing.l),
                  PFCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('O seu pedido', style: PFText.secundario),
                        const SizedBox(height: PFSpacing.xs),
                        Text(
                          dados.descricao.isEmpty
                              ? dados.categoria
                              : dados.descricao,
                          style: PFText.corpoForte,
                        ),
                      ],
                    ),
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
                texto: 'Confirmar pedido',
                icone: PFIcons.certo,
                carregando: _aEnviar,
                onPressed: _aEnviar ? null : _confirmar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
