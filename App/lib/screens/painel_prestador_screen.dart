import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/pedido.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_card.dart';
import '../widgets/pf_chip.dart';
import '../widgets/pf_controlos.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_titulo_seccao.dart';
import '../widgets/pf_top_bar.dart';
import '../widgets/pedido_card.dart';

/// Painel do prestador, ligado ao servidor (ver Documentação da API):
/// - ao abrir envia a localização e a disponibilidade
///   (PATCH /prestadores/me/localizacao e /disponibilidade);
/// - o servidor atribui os pedidos automaticamente ao prestador livre mais
///   próximo; aqui aparecem os pedidos ativos (GET /prestadores/me/pedidos);
/// - atribuido → "Aceitar" (POST /pedidos/:id/aceitar) → a caminho:
///   mostra o QR que o cliente lê para confirmar a chegada;
/// - no local → "Começar serviço" (em_curso) → "Concluir" com o preço final
///   (PATCH /pedidos/:id/estado).
/// Atualiza sozinho a cada 4 segundos.
class PainelPrestadorScreen extends StatefulWidget {
  const PainelPrestadorScreen({super.key});

  @override
  State<PainelPrestadorScreen> createState() => _PainelPrestadorScreenState();
}

class _PainelPrestadorScreenState extends State<PainelPrestadorScreen> {
  bool _disponivel = true;

  /// Pedido ativo mais recente (o que se mostra em destaque).
  Pedido? _servico;

  /// Outros pedidos ativos deste prestador.
  List<Pedido> _outros = [];

  bool _aCarregar = true;
  bool _aProcessar = false;
  String? _erro;
  Timer? _atualizacao;

  @override
  void initState() {
    super.initState();
    _entrarEmServico();
    _atualizacao = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _carregar(),
    );
  }

  @override
  void dispose() {
    _atualizacao?.cancel();
    super.dispose();
  }

  /// Só técnicos disponíveis e com localização recebem pedidos.
  Future<void> _entrarEmServico() async {
    try {
      await Api.atualizarLocalizacao(); // sem GPS: localização de exemplo
      await Api.definirDisponibilidade(_disponivel);
    } on ApiException catch (e) {
      if (mounted) setState(() => _erro = e.mensagem);
    }
    await _carregar();
  }

  /// GET /prestadores/me/pedidos
  Future<void> _carregar() async {
    try {
      final ativos = await Api.meusPedidos();
      if (!mounted) return;
      final Pedido? anterior = _servico;
      setState(() {
        _servico = ativos.isEmpty ? null : ativos.first;
        _outros = ativos.skip(1).toList();
        _erro = null;
        _aCarregar = false;
      });
      _avisar(anterior, _servico);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _aCarregar = false;
      });
    }
  }

  /// Avisa quando chega um pedido novo ou o cliente confirma a chegada.
  void _avisar(Pedido? antes, Pedido? agora) {
    if (agora == null) return;
    if (antes?.id != agora.id && agora.estadoApi == 'atribuido') {
      PFFeedback.mostrar(
          context, PFTipoFeedback.info, 'Novo pedido de ${agora.clienteNome}.');
    } else if (antes?.id == agora.id &&
        antes?.estadoApi == 'a_caminho' &&
        agora.estadoApi == 'no_local') {
      PFFeedback.mostrar(context, PFTipoFeedback.sucesso,
          'O cliente confirmou a sua chegada.');
    }
  }

  /// Executa uma ação no servidor, mostra o erro se falhar e recarrega.
  Future<void> _executar(
    Future<void> Function() acao, {
    String? sucesso,
  }) async {
    setState(() => _aProcessar = true);
    try {
      await acao();
      if (!mounted) return;
      if (sucesso != null) {
        PFFeedback.mostrar(context, PFTipoFeedback.sucesso, sucesso);
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
    await _carregar();
    if (mounted) setState(() => _aProcessar = false);
  }

  void _mudarDisponibilidade(bool valor) {
    if (_aProcessar) return;
    setState(() => _disponivel = valor);
    _executar(() => Api.definirDisponibilidade(valor));
  }

  /// Botão do serviço: avança para o estado seguinte.
  void _avancar(Pedido s) {
    switch (s.estadoApi) {
      case 'atribuido':
        _executar(
          () => Api.aceitar(s.id),
          sucesso: 'Pedido aceite. Está a caminho.',
        );
        break;
      case 'no_local':
        _executar(
          () => Api.iniciarServico(s.id),
          sucesso: 'Serviço iniciado.',
        );
        break;
      case 'em_curso':
        _concluir(s);
        break;
      default:
        break;
    }
  }

  /// Pede o preço final e conclui o serviço.
  Future<void> _concluir(Pedido s) async {
    final double? preco = await showDialog<double>(
      context: context,
      builder: (_) => _DialogoValorFinal(pedido: s),
    );
    if (preco == null || !mounted) return;
    _executar(
      () => Api.concluir(s.id, preco),
      sucesso: 'Serviço concluído. O cliente vai pagar e avaliar.',
    );
  }

  String? _textoBotao(String estado) {
    switch (estado) {
      case 'atribuido':
        return 'Aceitar e ir a caminho';
      case 'no_local':
        return 'Começar serviço';
      case 'em_curso':
        return 'Concluir serviço';
      default:
        return null; // a_caminho: espera que o cliente leia o QR
    }
  }

  Future<void> _copiarCodigo(String codigo) async {
    await Clipboard.setData(ClipboardData(text: codigo));
    if (!mounted) return;
    PFFeedback.mostrar(context, PFTipoFeedback.info, 'Código copiado.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: 'Olá, ${Api.utilizador?.primeiroNome ?? ''}',
              subtitulo: 'Painel do prestador',
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
                    if (_erro != null) ...[
                      PFCard(
                        cor: PFColors.warningBg,
                        corBorda: PFColors.warningBg,
                        onTap: _entrarEmServico,
                        child: Text(
                          '$_erro Toque para tentar de novo.',
                          style: PFText.secundario.copyWith(
                            color: PFColors.warningText,
                          ),
                        ),
                      ),
                      const SizedBox(height: PFSpacing.l),
                    ],
                    PFCard(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Disponível agora', style: PFText.h4),
                                const SizedBox(height: 2),
                                Text(
                                  _disponivel
                                      ? 'Ligado · a receber pedidos'
                                      : 'Desligado · sem novos pedidos',
                                  style: PFText.secundario.copyWith(
                                    color: _disponivel
                                        ? PFColors.successText
                                        : PFColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PFSwitch(
                            valor: _disponivel,
                            rotulo: 'Disponível agora',
                            onChanged: _mudarDisponibilidade,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: PFSpacing.m),
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
                            'Os pedidos são atribuídos automaticamente ao prestador livre mais próximo.',
                            style: PFText.secundario,
                          ),
                        ),
                      ],
                    ),
                    PFTituloSeccao(
                      _servico == null
                          ? 'Novo pedido'
                          : _servico!.estadoApi == 'atribuido'
                              ? 'Novo pedido atribuído'
                              : 'Serviço em curso',
                    ),
                    if (_aCarregar)
                      const Center(child: CircularProgressIndicator())
                    else if (_servico != null)
                      _cartaoServico(_servico!)
                    else if (!_disponivel)
                      PFCard(
                        cor: PFColors.warningBg,
                        corBorda: PFColors.warningBg,
                        child: Row(
                          children: [
                            const Icon(
                              PFIcons.aviso,
                              size: 24,
                              color: PFColors.warningText,
                            ),
                            const SizedBox(width: PFSpacing.m),
                            Expanded(
                              child: Text(
                                'Está indisponível. Ligue a disponibilidade para receber pedidos.',
                                style: PFText.corpoForte.copyWith(
                                  color: PFColors.warningText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const PFCard(
                        child: Text(
                          'Sem pedidos por agora. Esta página atualiza sozinha.',
                          style: PFText.corpo,
                        ),
                      ),
                    if (_outros.isNotEmpty) ...[
                      const PFTituloSeccao('Outros pedidos ativos'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _outros.length,
                        itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.only(bottom: PFSpacing.m),
                          child: PedidoCard(pedido: _outros[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartaoServico(Pedido s) {
    final String? botao = _textoBotao(s.estadoApi);
    final String? codigo = s.codigoQr;
    return PFCard(
      corBorda: PFColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              s.estadoApi == 'em_curso'
                  ? const PFTag(texto: 'Em curso', tipo: PFTagTipo.info)
                  : tagDoEstado(s.estado),
              const Spacer(),
              Text(s.preco, style: PFText.corpoForte),
            ],
          ),
          const SizedBox(height: PFSpacing.m),
          Text(s.titulo, style: PFText.h3),
          const SizedBox(height: 2),
          Text(
            '${s.categoria} · ${s.clienteNome}',
            style: PFText.secundario,
          ),
          if (s.morada.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(s.morada, style: PFText.secundario),
          ],
          if (s.clienteTelefone != null) ...[
            const SizedBox(height: 2),
            Text('Tel.: ${s.clienteTelefone}', style: PFText.secundario),
          ],
          if (s.tempoEstimadoMin != null && s.estadoApi == 'atribuido') ...[
            const SizedBox(height: 2),
            Text('Chegada estimada: ${s.tempoEstimadoMin} min',
                style: PFText.secundario),
          ],
          // A caminho: o cliente lê este QR para confirmar a chegada.
          if (s.estadoApi == 'a_caminho' && codigo != null) ...[
            const SizedBox(height: PFSpacing.l),
            Text('Mostre este QR ao cliente quando chegar.',
                style: PFText.corpoForte),
            const SizedBox(height: PFSpacing.m),
            Center(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(PFSpacing.s),
                child: QrImageView(data: codigo, size: 200),
              ),
            ),
            const SizedBox(height: PFSpacing.s),
            Center(
              child: SelectableText(codigo, style: PFText.legenda),
            ),
            const SizedBox(height: PFSpacing.s),
            PFButton(
              texto: 'Copiar código',
              icone: PFIcons.qr,
              variante: PFVariante.contorno,
              onPressed: () => _copiarCodigo(codigo),
            ),
          ],
          if (botao != null) ...[
            const SizedBox(height: PFSpacing.l),
            PFButton(
              texto: botao,
              icone: s.estadoApi == 'atribuido'
                  ? PFIcons.navegacao
                  : PFIcons.certo,
              carregando: _aProcessar,
              onPressed: _aProcessar ? null : () => _avancar(s),
            ),
          ],
        ],
      ),
    );
  }
}

/// Janela para o preço final do serviço (por omissão, a estimativa).
/// Devolve o valor escolhido.
class _DialogoValorFinal extends StatefulWidget {
  final Pedido pedido;

  const _DialogoValorFinal({required this.pedido});

  @override
  State<_DialogoValorFinal> createState() => _DialogoValorFinalState();
}

class _DialogoValorFinalState extends State<_DialogoValorFinal> {
  late final TextEditingController _preco = TextEditingController(
    text: widget.pedido.precoEstimado?.toStringAsFixed(2).replaceAll('.', ',') ??
        '',
  );
  bool _tentou = false;

  @override
  void dispose() {
    _preco.dispose();
    super.dispose();
  }

  double? get _valor => double.tryParse(_preco.text.trim().replaceAll(',', '.'));

  String? get _erro {
    if (!_tentou) return null;
    final double? v = _valor;
    return v == null || v < 0 ? 'Indique um valor válido.' : null;
  }

  void _confirmar() {
    setState(() => _tentou = true);
    final double? v = _valor;
    if (v == null || v < 0) return;
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PFColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(PFSpacing.xl),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Preço final', style: PFText.h3),
              const SizedBox(height: PFSpacing.xs),
              Text(
                'Estimativa dada ao cliente: ${widget.pedido.preco}',
                style: PFText.secundario,
              ),
              const SizedBox(height: PFSpacing.l),
              PFTextField(
                etiqueta: 'Preço final (€)',
                dica: 'Ex.: 45',
                controlador: _preco,
                iconePrefixo: PFIcons.dinheiro,
                teclado: const TextInputType.numberWithOptions(decimal: true),
                erro: _erro,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: PFSpacing.xl),
              PFButton(
                texto: 'Concluir serviço',
                icone: PFIcons.certo,
                onPressed: _preco.text.trim().isEmpty ? null : _confirmar,
              ),
              const SizedBox(height: PFSpacing.s),
              PFButton(
                texto: 'Voltar',
                variante: PFVariante.contorno,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
