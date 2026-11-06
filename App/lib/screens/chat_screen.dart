import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/mensagem.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_top_bar.dart';

/// Chat simulado (RF27). Mensagens de exemplo e resposta automática fictícia.
class ChatScreen extends StatefulWidget {
  final String nome;

  const ChatScreen({super.key, required this.nome});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _texto = TextEditingController();
  final ScrollController _rolagem = ScrollController();
  late final List<Mensagem> _mensagens;
  Timer? _resposta;

  bool get _suporte => widget.nome.contains('Suporte');

  @override
  void initState() {
    super.initState();
    _mensagens = _suporte
        ? <Mensagem>[
            const Mensagem(
              texto: 'Olá! Sou o suporte ProntoFix. Como podemos ajudar?',
              minha: false,
              hora: '11:45',
            ),
          ]
        : List<Mensagem>.of(mensagensIniciais);
  }

  @override
  void dispose() {
    _resposta?.cancel();
    _texto.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _irParaFim() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_rolagem.hasClients) return;
      _rolagem.animateTo(
        _rolagem.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _enviar() {
    final String t = _texto.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _mensagens.add(Mensagem(texto: t, minha: true, hora: '11:46'));
      _texto.clear();
    });
    _irParaFim();
    _resposta?.cancel();
    _resposta = Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _mensagens.add(
          Mensagem(
            texto: _suporte
                ? 'Obrigado. Um colega vai responder dentro de momentos.'
                : 'Recebido. Obrigado!',
            minha: false,
            hora: '11:47',
          ),
        );
      });
      _irParaFim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool podeEnviar = _texto.text.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: widget.nome,
              subtitulo: _suporte
                  ? 'Resposta em poucos minutos'
                  : 'Conversa do pedido',
              onVoltar: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView.builder(
                controller: _rolagem,
                padding: const EdgeInsets.symmetric(
                  horizontal: PFSpacing.margem,
                  vertical: PFSpacing.s,
                ),
                itemCount: _mensagens.length,
                itemBuilder: (context, i) => _Balao(mensagem: _mensagens[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PFSpacing.margem,
                PFSpacing.s,
                PFSpacing.margem,
                PFSpacing.m,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _texto,
                      style: PFText.corpo,
                      textInputAction: TextInputAction.send,
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _enviar(),
                      decoration: InputDecoration(
                        hintText: 'Escreva uma mensagem',
                        hintStyle: PFText.corpo.copyWith(
                          color: PFColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: PFColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: PFSpacing.l,
                          vertical: PFSpacing.m,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PFRadius.botao),
                          borderSide: const BorderSide(color: PFColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(PFRadius.botao),
                          borderSide: const BorderSide(
                            color: PFColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: PFSpacing.s),
                  Semantics(
                    button: true,
                    enabled: podeEnviar,
                    label: 'Enviar mensagem',
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: podeEnviar ? _enviar : null,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: podeEnviar
                              ? PFColors.primary
                              : PFColors.disabled,
                          borderRadius: BorderRadius.circular(PFRadius.botao),
                        ),
                        child: const Icon(
                          PFIcons.enviar,
                          size: 24,
                          color: PFColors.surface,
                        ),
                      ),
                    ),
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

class _Balao extends StatelessWidget {
  final Mensagem mensagem;

  const _Balao({required this.mensagem});

  @override
  Widget build(BuildContext context) {
    final bool minha = mensagem.minha;
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: PFSpacing.m),
        padding: const EdgeInsets.symmetric(
          horizontal: PFSpacing.l,
          vertical: PFSpacing.m,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: minha ? PFColors.primary : PFColors.surface,
          borderRadius: BorderRadius.circular(PFRadius.cartao),
          border: minha ? null : Border.all(color: PFColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              mensagem.texto,
              style: PFText.corpo.copyWith(
                color: minha ? PFColors.surface : PFColors.text,
              ),
            ),
            const SizedBox(height: PFSpacing.xs),
            Text(
              mensagem.hora,
              style: PFText.legenda.copyWith(
                color: minha ? PFColors.surface : PFColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
