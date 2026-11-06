import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../data/mock_data.dart';
import '../models/dados_pedido.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_chip.dart';
import '../widgets/pf_controlos.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_fluxo_pedido.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_top_bar.dart';

/// Passo 1 de 3: o que se passa. Sem barra inferior (RU03); sair a meio pede
/// confirmação. Pedido possível em: abrir → descrever → Continuar → Confirmar.
class NovoPedidoScreen extends StatefulWidget {
  final String? categoriaInicial;

  const NovoPedidoScreen({super.key, this.categoriaInicial});

  @override
  State<NovoPedidoScreen> createState() => _NovoPedidoScreenState();
}

class _NovoPedidoScreenState extends State<NovoPedidoScreen> {
  final TextEditingController _descricao = TextEditingController();
  late String _categoria = widget.categoriaInicial ?? servicos.first.nome;
  String _urgencia = 'Agora';
  bool _temFoto = false;

  @override
  void dispose() {
    _descricao.dispose();
    super.dispose();
  }

  void _continuar() {
    Navigator.of(context).pushNamed(
      AppRoutes.localizacao,
      arguments: DadosPedido(
        categoria: _categoria,
        descricao: _descricao.text.trim(),
        urgencia: _urgencia,
      ),
    );
  }

  Future<void> _escolherFoto() async {
    final String? escolha = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: PFColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(PFRadius.cartao),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(PFSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Adicionar foto', style: PFText.h3),
              const SizedBox(height: PFSpacing.s),
              _OpcaoFoto(
                icone: PFIcons.camara,
                texto: 'Tirar foto',
                onTap: () => Navigator.of(ctx).pop('foto'),
              ),
              _OpcaoFoto(
                icone: PFIcons.galeria,
                texto: 'Escolher da galeria',
                onTap: () => Navigator.of(ctx).pop('foto'),
              ),
              _OpcaoFoto(
                icone: PFIcons.direita,
                texto: 'Saltar',
                onTap: () => Navigator.of(ctx).pop('saltar'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted) return;
    if (escolha == 'foto') {
      setState(() => _temFoto = true);
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.sucesso,
        'Foto adicionada (simulado).',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool podeContinuar = _descricao.text.trim().isNotEmpty;

    return PFFluxoPedido(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              PFTopBar(
                titulo: 'Novo pedido',
                subtitulo: 'Diga-nos o que se passa',
                passo: 1,
                onVoltar: () => PFFluxoPedido.confirmarSaida(context),
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
                    Text('Serviço', style: PFText.corpoForte),
                    const SizedBox(height: PFSpacing.s),
                    Wrap(
                      spacing: PFSpacing.s,
                      runSpacing: PFSpacing.s,
                      children: [
                        for (final s in servicos)
                          PFChip(
                            texto: s.nome,
                            icone: s.icone,
                            selecionado: _categoria == s.nome,
                            onTap: () => setState(() => _categoria = s.nome),
                          ),
                      ],
                    ),
                    const SizedBox(height: PFSpacing.xl),
                    PFTextField(
                      etiqueta: 'O que se passa?',
                      dica: 'Ex.: fuga de água debaixo do lava-loiça',
                      controlador: _descricao,
                      linhas: 3,
                      ajuda: 'Uma frase curta chega.',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: PFSpacing.xl),
                    Row(
                      children: [
                        Text('Foto', style: PFText.corpoForte),
                        const SizedBox(width: PFSpacing.s),
                        Text('(opcional)', style: PFText.secundario),
                      ],
                    ),
                    const SizedBox(height: PFSpacing.s),
                    _CaixaFoto(
                      temFoto: _temFoto,
                      onAdicionar: _escolherFoto,
                      onRemover: () => setState(() => _temFoto = false),
                    ),
                    const SizedBox(height: PFSpacing.xl),
                    Text('Urgência', style: PFText.corpoForte),
                    const SizedBox(height: PFSpacing.s),
                    PFSegmentado(
                      opcoes: const ['Normal', 'Hoje', 'Agora'],
                      selecionado: _urgencia,
                      onChanged: (v) => setState(() => _urgencia = v),
                      corSelecionada: (opcao) => opcao == 'Agora'
                          ? PFColors.warningText
                          : PFColors.primaryPressed,
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
                  texto: 'Continuar',
                  iconeDepois: PFIcons.direita,
                  onPressed: podeContinuar ? _continuar : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpcaoFoto extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;

  const _OpcaoFoto({
    required this.icone,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PFRadius.botao),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Row(
          children: [
            Icon(icone, size: 24, color: PFColors.primaryPressed),
            const SizedBox(width: PFSpacing.l),
            Text(texto, style: PFText.corpoForte),
          ],
        ),
      ),
    );
  }
}

class _CaixaFoto extends StatelessWidget {
  final bool temFoto;
  final VoidCallback onAdicionar;
  final VoidCallback onRemover;

  const _CaixaFoto({
    required this.temFoto,
    required this.onAdicionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    if (temFoto) {
      return Container(
        padding: const EdgeInsets.all(PFSpacing.m),
        decoration: BoxDecoration(
          color: PFColors.surface,
          borderRadius: BorderRadius.circular(PFRadius.cartao),
          border: Border.all(color: PFColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: PFColors.tint,
                borderRadius: BorderRadius.circular(PFRadius.botao),
              ),
              child: const Icon(
                PFIcons.imagem,
                size: 28,
                color: PFColors.primaryPressed,
              ),
            ),
            const SizedBox(width: PFSpacing.m),
            Expanded(
              child: Text('Foto adicionada', style: PFText.corpoForte),
            ),
            TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(PFSpacing.alvo, PFSpacing.alvo),
              ),
              onPressed: onRemover,
              child: Text(
                'Remover',
                style: PFText.secundario.copyWith(
                  color: PFColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Semantics(
      button: true,
      label: 'Adicionar foto',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onAdicionar,
        child: CustomPaint(
          painter: const _BordaTracejada(),
          child: Container(
            height: 96,
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  PFIcons.camara,
                  size: 24,
                  color: PFColors.primaryPressed,
                ),
                const SizedBox(width: PFSpacing.s),
                Text(
                  'Adicionar foto',
                  style: PFText.corpoForte.copyWith(
                    color: PFColors.primaryPressed,
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

class _BordaTracejada extends CustomPainter {
  const _BordaTracejada();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pincel = Paint()
      ..color = PFColors.muted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final Path caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(PFRadius.cartao),
        ),
      );
    for (final metrica in caminho.computeMetrics()) {
      double distancia = 0;
      while (distancia < metrica.length) {
        final double fim = distancia + 6;
        canvas.drawPath(metrica.extractPath(distancia, fim), pincel);
        distancia += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter antigo) => false;
}
