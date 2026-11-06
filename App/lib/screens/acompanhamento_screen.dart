import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_routes.dart';
import '../data/mock_data.dart';
import '../models/pedido.dart';
import '../models/prestador.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/estado_stepper.dart';
import '../widgets/mapa_placeholder.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_chip.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_skeleton.dart';
import '../widgets/pf_top_bar.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/prestador_card.dart';

/// Acompanhamento ao vivo (GET /pedidos/:id a cada 3 s): procurar → atribuído
/// → a caminho → no local (confirmado com o QR) → concluído. Sem barra inferior. Ajuda e cancelar separados (RU09).
class AcompanhamentoScreen extends StatefulWidget {
  /// Id do pedido no servidor.
  final int? pedidoId;

  const AcompanhamentoScreen({super.key, this.pedidoId});

  @override
  State<AcompanhamentoScreen> createState() => _AcompanhamentoScreenState();
}

class _AcompanhamentoScreenState extends State<AcompanhamentoScreen> {
  Pedido? _pedido;
  String? _erro;
  Timer? _atualizacao;

  EstadoPedido get _estado => _pedido?.estado ?? EstadoPedido.procurar;

  /// Prestador vindo do servidor (ou o de exemplo, enquanto não há).
  Prestador get _prestador => _pedido?.prestador ?? prestadorAtribuido;

  String get _total =>
      _pedido?.total != null ? euros(_pedido!.total!) : totalServico;

  @override
  void initState() {
    super.initState();
    _carregar();
    // "Tempo real": pergunta o estado ao servidor a cada 3 segundos.
    _atualizacao = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _carregar(),
    );
  }

  @override
  void dispose() {
    _atualizacao?.cancel();
    super.dispose();
  }

  /// GET /pedidos/:id
  Future<void> _carregar() async {
    final int? id = widget.pedidoId;
    if (id == null) {
      setState(() => _erro = 'Pedido não indicado.');
      return;
    }
    try {
      final Pedido novo = await Api.pedido(id);
      if (!mounted) return;
      final EstadoPedido? antes = _pedido?.estado;
      setState(() {
        _pedido = novo;
        _erro = null;
      });
      if (antes != null && antes != novo.estado) _avisarMudanca(novo);
      if (!novo.ativo) _atualizacao?.cancel();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.mensagem);
    }
  }

  /// Mensagem curta quando o estado muda (notificação dentro da app).
  void _avisarMudanca(Pedido p) {
    final String nome = p.prestador?.primeiroNome ?? 'O prestador';
    final String? texto = switch (p.estado) {
      EstadoPedido.atribuido => '$nome aceitou o seu pedido.',
      EstadoPedido.aCaminho => '$nome está a caminho.',
      EstadoPedido.noLocal => '$nome chegou ao local.',
      EstadoPedido.concluido => 'Serviço concluído.',
      EstadoPedido.cancelado => 'Pedido cancelado.',
      EstadoPedido.procurar => null,
    };
    if (texto != null) {
      PFFeedback.mostrar(context, PFTipoFeedback.sucesso, texto);
    }
  }

  void _irParaInicio() {
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.home));
  }

  Future<void> _cancelar() async {
    final bool cancelar = await PFDialogo.confirmar(
      context,
      icone: PFIcons.aviso,
      titulo: 'Cancelar o pedido?',
      texto: 'O prestador deixa de ir a caminho. Pode fazer um novo pedido quando quiser.',
      textoSeguro: 'Manter pedido',
      textoAcao: 'Cancelar pedido',
      destrutivo: true,
    );
    if (!cancelar || !mounted || _pedido == null) return;
    try {
      await Api.cancelar(_pedido!.id); // PATCH /pedidos/:id/cancelar
      if (!mounted) return;
      PFFeedback.mostrar(context, PFTipoFeedback.aviso, 'Pedido cancelado.');
      _irParaInicio();
    } on ApiException catch (e) {
      if (!mounted) return;
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  /// POST /pedidos/:id/chegada {codigo} — o cliente lê o QR do prestador.
  Future<void> _confirmarChegada() async {
    final Pedido? p = _pedido;
    if (p == null) return;
    final String? codigo = await showDialog<String>(
      context: context,
      builder: (_) => const _DialogoCodigoQr(),
    );
    if (codigo == null || codigo.trim().isEmpty || !mounted) return;
    try {
      final Pedido novo = await Api.confirmarChegada(p.id, codigo);
      if (!mounted) return;
      setState(() => _pedido = novo);
      PFFeedback.mostrar(
          context, PFTipoFeedback.sucesso, 'Chegada confirmada.');
    } on ApiException catch (e) {
      if (!mounted) return;
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  void _pagarOuAvaliar() {
    final Pedido? p = _pedido;
    if (p == null) return;
    Navigator.of(context).pushNamed(
      p.pago ? AppRoutes.avaliacao : AppRoutes.pagamento,
      arguments: p.id,
    );
  }

  String get _titulo {
    switch (_estado) {
      case EstadoPedido.procurar:
        return 'A procurar o prestador mais próximo…';
      case EstadoPedido.atribuido:
        return '${_prestador.primeiroNome} vai atender o pedido';
      case EstadoPedido.aCaminho:
        return '${_prestador.primeiroNome} chega em ${(_pedido?.tempoEstimadoMin ?? _prestador.etaMinutos)} min';
      case EstadoPedido.noLocal:
        return '${_prestador.primeiroNome} está à sua porta';
      case EstadoPedido.concluido:
        return 'Serviço concluído';
      case EstadoPedido.cancelado:
        return 'Pedido cancelado';
    }
  }

  /// Botão de baixo: muda com o estado que vem do servidor.
  Widget _botaoInferior() {
    switch (_estado) {
      case EstadoPedido.procurar:
        return const PFButton(
          texto: 'A procurar prestador…',
          carregando: true,
          onPressed: null,
        );
      case EstadoPedido.atribuido:
      case EstadoPedido.aCaminho:
      case EstadoPedido.noLocal:
        return PFButton(
          texto: 'Falar com ${_prestador.primeiroNome}',
          icone: PFIcons.chat,
          variante: PFVariante.secundario,
          onPressed: () => Navigator.of(context).pushNamed(
            AppRoutes.chat,
            arguments: _prestador.nome,
          ),
        );
      case EstadoPedido.concluido:
        if (_pedido?.estrelas != null) {
          return PFButton(texto: 'Voltar ao início', onPressed: _irParaInicio);
        }
        return PFButton(
          texto: _pedido?.pago == true ? 'Avaliar serviço' : 'Pagar $_total',
          icone: _pedido?.pago == true ? PFIcons.estrela : PFIcons.cartao,
          onPressed: _pagarOuAvaliar,
        );
      case EstadoPedido.cancelado:
        return PFButton(texto: 'Voltar ao início', onPressed: _irParaInicio);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool procura = _estado == EstadoPedido.procurar;
    final bool concluido = _estado == EstadoPedido.concluido;
    final bool prestadorVisivel = _estado == EstadoPedido.aCaminho ||
        _estado == EstadoPedido.noLocal;

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
                titulo: 'A sua reparação',
                subtitulo: _estado.rotulo,
                onVoltar: _irParaInicio,
                trailing: const PFTag(
                  texto: 'Ao vivo',
                  tipo: PFTagTipo.sucesso,
                  icone: PFIcons.localizacao,
                ),
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
                    MapaPlaceholder(
                      altura: 200,
                      mostrarPrestador: prestadorVisivel,
                    ),
                    const SizedBox(height: PFSpacing.l),
                    Text(_titulo, style: PFText.h2),
                    const SizedBox(height: PFSpacing.l),
                    if (_erro != null) ...[
                      PFCard(
                        cor: PFColors.warningBg,
                        corBorda: PFColors.warningBg,
                        child: Text(
                          _erro!,
                          style: PFText.secundario.copyWith(
                            color: PFColors.warningText,
                          ),
                        ),
                      ),
                      const SizedBox(height: PFSpacing.l),
                    ],
                    if (!procura) ...[
                      EstadoStepper(atual: _estado),
                      const SizedBox(height: PFSpacing.l),
                      PrestadorCard(
                        prestador: _prestador,
                        rodape: Row(
                          children: [
                            Expanded(
                              child: PFButton(
                                texto: 'Ligar',
                                icone: PFIcons.telefone,
                                variante: PFVariante.contorno,
                                onPressed: () => PFFeedback.mostrar(
                                  context,
                                  PFTipoFeedback.info,
                                  _prestador.telefone == null
                                      ? 'A ligar a ${_prestador.nome} (simulado).'
                                      : 'Ligar a ${_prestador.nome}: ${_prestador.telefone}',
                                ),
                              ),
                            ),
                            const SizedBox(width: PFSpacing.m),
                            Expanded(
                              child: PFButton(
                                texto: 'Mensagem',
                                icone: PFIcons.chat,
                                variante: PFVariante.contorno,
                                onPressed: () =>
                                    Navigator.of(context).pushNamed(
                                  AppRoutes.chat,
                                  arguments: _prestador.nome,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else
                      const PFCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PFSkeleton(altura: 20, largura: 180),
                            SizedBox(height: PFSpacing.m),
                            PFSkeleton(altura: 14),
                            SizedBox(height: PFSpacing.s),
                            PFSkeleton(altura: 14, largura: 120),
                          ],
                        ),
                      ),
                    if (!procura &&
                        !concluido &&
                        _estado != EstadoPedido.cancelado) ...[
                      const SizedBox(height: PFSpacing.l),
                      // Chegada confirmada com o QR que o prestador mostra.
                      PFButton(
                        texto: _estado == EstadoPedido.aCaminho
                            ? 'Confirmar chegada (QR)'
                            : 'Chegada confirmada',
                        icone: PFIcons.qr,
                        variante: PFVariante.secundario,
                        onPressed: _estado == EstadoPedido.aCaminho
                            ? _confirmarChegada
                            : null,
                      ),
                    ],
                    if (!concluido && _estado != EstadoPedido.cancelado) ...[
                      const SizedBox(height: PFSpacing.xl),
                      PFButton(
                        texto: 'Ajuda',
                        icone: PFIcons.ajuda,
                        variante: PFVariante.contorno,
                        onPressed: () =>
                            Navigator.of(context).pushNamed(AppRoutes.ajuda),
                      ),
                      // Só se cancela antes de o prestador sair.
                      // A API deixa cancelar até o serviço começar (em_curso).
                      if (_pedido != null && !_pedido!.emCurso) ...[
                        const SizedBox(height: PFSpacing.l),
                        PFButton(
                          texto: 'Cancelar pedido',
                          variante: PFVariante.contornoDestrutivo,
                          onPressed: _cancelar,
                        ),
                      ],
                    ],
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
                child: _botaoInferior(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Janela para introduzir o código do QR que o prestador mostra no ecrã.
/// (A leitura com a câmara pode ser acrescentada com o pacote mobile_scanner;
/// por agora o código pode ser colado ou escrito.)
class _DialogoCodigoQr extends StatefulWidget {
  const _DialogoCodigoQr();

  @override
  State<_DialogoCodigoQr> createState() => _DialogoCodigoQrState();
}

class _DialogoCodigoQrState extends State<_DialogoCodigoQr> {
  final TextEditingController _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  Future<void> _colar() async {
    final ClipboardData? dados = await Clipboard.getData(Clipboard.kTextPlain);
    if (dados?.text != null) setState(() => _codigo.text = dados!.text!.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar chegada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peça ao prestador para mostrar o código QR e introduza o código.',
            style: PFText.secundario,
          ),
          const SizedBox(height: PFSpacing.l),
          PFTextField(
            etiqueta: 'Código',
            dica: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
            controlador: _codigo,
            iconePrefixo: PFIcons.qr,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: PFSpacing.s),
          TextButton(onPressed: _colar, child: const Text('Colar código')),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _codigo.text.trim().isEmpty
              ? null
              : () => Navigator.of(context).pop(_codigo.text.trim()),
          child: const Text('Confirmar'),
        ),
      ],
    );
  }
}
