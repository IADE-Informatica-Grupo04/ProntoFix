import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/pedido.dart';
import '../../servicos/api.dart';
import '../../tema/cores.dart';
import '../../widgets/componentes.dart';

// 07 Finalizar serviço — pagamento simulado e avaliação do prestador.
class FinalizarServicoPage extends StatefulWidget {
  final Pedido pedido;

  const FinalizarServicoPage({super.key, required this.pedido});

  @override
  State<FinalizarServicoPage> createState() => _FinalizarServicoPageState();
}

class _FinalizarServicoPageState extends State<FinalizarServicoPage> {
  final TextEditingController comentarioController = TextEditingController();

  String metodo = 'MB Way';
  int estrelas = 0;

  Future<void> pagar() async {
    if (estrelas == 0) {
      mostrarMensagem(context, 'Escolhe de 1 a 5 estrelas para avaliar.');
      return;
    }

    // Guarda o pagamento e a avaliação no próprio pedido.
    widget.pedido.metodoPagamento = metodo;
    widget.pedido.estrelas = estrelas;
    widget.pedido.comentario = comentarioController.text.trim();
    await Api.pagarEAvaliar(widget.pedido); // POST /pedidos/:id/avaliacao
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Cores.verde, size: 48),
          title: const Text('Obrigado!'),
          content: Text(
            'Pagamento de ${euros(widget.pedido.total ?? 0)} por $metodo '
            '(simulado) e avaliação enviados.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.pedido.total ?? 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Cabecalho(
              titulo: 'Finalizar serviço',
              subtitulo: 'Pagamento simulado e avaliação do prestador.',
              mostrarVoltar: true,
            ),
            const SizedBox(height: 20),

            // Resumo do serviço
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Serviço concluído',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Cores.texto,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.pedido.resumo ?? widget.pedido.titulo,
                    style: const TextStyle(fontSize: 13, color: Cores.cinza),
                  ),
                  const Divider(height: 28, color: Cores.linha),
                  _linha('Mão de obra', euros(widget.pedido.maoDeObra ?? 0)),
                  const SizedBox(height: 8),
                  _linha('Material', euros(widget.pedido.material ?? 0)),
                  const Divider(height: 28, color: Cores.linha),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total a pagar',
                          style: TextStyle(color: Cores.cinza),
                        ),
                      ),
                      Text(
                        euros(total),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Cores.texto,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Método de pagamento
            const TituloSecao('Método de pagamento'),
            GrupoOpcoes(
              opcoes: metodosPagamento,
              selecionada: metodo,
              onEscolher: (opcao) {
                setState(() {
                  metodo = opcao;
                });
              },
            ),
            const SizedBox(height: 20),

            // Avaliação
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TituloSecao('Avaliar prestador'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 5 estrelas: cheias até à escolhida
                      for (int i = 1; i <= 5; i++)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              estrelas = i;
                            });
                          },
                          icon: Icon(
                            i <= estrelas ? Icons.star : Icons.star_border,
                            color: Cores.laranja,
                            size: 36,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: comentarioController,
                    decoration: InputDecoration(
                      hintText: 'Escreve um comentário rápido',
                      hintStyle: const TextStyle(color: Cores.cinza),
                      filled: true,
                      fillColor: Cores.fundo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Cores.linha),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            BotaoPrincipal(texto: 'Pagar e enviar avaliação', onPressed: pagar),
          ],
        ),
      ),
    );
  }

  Widget _linha(String rotulo, String valor) {
    return Row(
      children: [
        Expanded(child: Text(rotulo)),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
