import 'dart:async';

import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/pedido.dart';
import '../../servicos/api.dart';
import '../../servicos/contacto.dart';
import '../../tema/cores.dart';
import '../../widgets/cartoes_pedido.dart';
import '../../widgets/componentes.dart';
import '../../widgets/mapa.dart';
import 'finalizar_servico_page.dart';
import 'ler_qr_page.dart';

// 06 Prestador a caminho — estado do pedido em tempo real (RF05, RF06).
//
// Enquanto não há servidor, um Timer simula o que o servidor faria:
// a cada 3 segundos o pedido avança, o prestador aproxima-se no mapa e a
// interface é atualizada com setState() (evento → estado → rebuild).
// Com servidor, o Timer chama Api.obterPedido() em vez de simular.
class AcompanhamentoPage extends StatefulWidget {
  final Pedido pedido;

  const AcompanhamentoPage({super.key, required this.pedido});

  @override
  State<AcompanhamentoPage> createState() => _AcompanhamentoPageState();
}

class _AcompanhamentoPageState extends State<AcompanhamentoPage> {
  Timer? timer;
  int segundosNoLocal = 0;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (_) => avancar());
  }

  Future<void> avancar() async {
    final Pedido p = widget.pedido;

    // Com servidor: pede o estado atual (GET /pedidos/:id).
    if (!Api.usarDadosFicticios) {
      final Pedido? atual = await Api.obterPedido(p.id);
      if (atual == null || !mounted) return;
      setState(() {
        p.estado = atual.estado;
        p.prestador = atual.prestador;
        p.prestadorTelefone = atual.prestadorTelefone;
        p.prestadorLat = atual.prestadorLat;
        p.prestadorLng = atual.prestadorLng;
        p.eta = atual.eta;
        p.maoDeObra = atual.maoDeObra;
        p.material = atual.material;
        p.resumo = atual.resumo;
      });
      return;
    }

    // Sem servidor: simulação.
    setState(() {
      if (p.estado == EstadoPedido.aProcura) {
        final List<double> inicio = posicaoInicialPrestador(p.lat, p.lng);
        p.estado = EstadoPedido.atribuido;
        p.prestador = 'João M.';
        p.prestadorTelefone = '912345678';
        p.prestadorLat = inicio[0];
        p.prestadorLng = inicio[1];
        p.eta = 12;
        mostrarMensagem(context, 'João M. aceitou o teu pedido.');
      } else if (p.estado == EstadoPedido.atribuido) {
        p.estado = EstadoPedido.aCaminho;
      } else if (p.estado == EstadoPedido.aCaminho && p.eta > 0) {
        // Aproxima-se um quarto do caminho que falta.
        final List<double> nova = aproximar(
          p.prestadorLat!,
          p.prestadorLng!,
          p.lat,
          p.lng,
          p.eta <= 3 ? 1 : 0.25,
        );
        p.prestadorLat = nova[0];
        p.prestadorLng = nova[1];
        p.eta = p.eta - 3 < 0 ? 0 : p.eta - 3;
        if (p.eta == 0) {
          mostrarMensagem(context, 'O prestador chegou. Lê o QR de chegada.');
        }
      } else if (p.estado == EstadoPedido.noLocal) {
        segundosNoLocal += 3;
        if (segundosNoLocal >= 9) {
          p.estado = EstadoPedido.concluido;
          p.maoDeObra = 32;
          p.material = 10;
          p.resumo = 'Cano substituído + teste de fuga';
        }
      }
    });
  }

  // Lê o QR do prestador e confirma a chegada (RF07).
  Future<void> lerQr() async {
    final String? codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute<String>(
        builder: (context) => LerQrPage(
          codigoDemo: Api.usarDadosFicticios ? widget.pedido.codigoQr : null,
        ),
      ),
    );
    if (codigo == null || !mounted) return;

    final bool valido = await Api.validarChegada(widget.pedido, codigo);
    if (!mounted) return;

    if (valido) {
      setState(() {
        widget.pedido.estado = EstadoPedido.noLocal;
        widget.pedido.eta = 0;
        widget.pedido.prestadorLat = widget.pedido.lat;
        widget.pedido.prestadorLng = widget.pedido.lng;
      });
      mostrarMensagem(context, 'Chegada confirmada. Bom serviço!');
    } else {
      mostrarMensagem(
        context,
        'Este código não é do prestador do teu pedido.',
      );
    }
  }

  Future<void> cancelar() async {
    final bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar pedido?'),
          content: const Text(
            'Podes cancelar sem custos enquanto o prestador não sai.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Manter'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: Cores.vermelho),
              child: const Text('Cancelar pedido'),
            ),
          ],
        );
      },
    );
    if (confirmar != true || !mounted) return;

    await Api.cancelarPedido(widget.pedido.id);
    if (!mounted) return;
    setState(() {
      widget.pedido.estado = EstadoPedido.cancelado;
    });
    timer?.cancel();
    Navigator.pop(context, true); // o pedido terminou (cancelado)
  }

  Future<void> pagar() async {
    final bool? pago = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => FinalizarServicoPage(pedido: widget.pedido),
      ),
    );
    if (pago == true && mounted) {
      Navigator.pop(context, true); // avisa a página principal
    }
  }

  @override
  void dispose() {
    timer?.cancel(); // parar o Timer quando o ecrã fecha
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Pedido p = widget.pedido;

    String titulo = 'Prestador a caminho';
    if (p.estado == EstadoPedido.aProcura) titulo = 'À procura de prestador';
    if (p.estado == EstadoPedido.atribuido) titulo = 'Prestador atribuído';
    if (p.estado == EstadoPedido.noLocal) titulo = 'Serviço em curso';
    if (p.estado == EstadoPedido.concluido) titulo = 'Serviço concluído';

    final bool mostrarPrestadorNoMapa = p.estado == EstadoPedido.atribuido ||
        p.estado == EstadoPedido.aCaminho;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Cabecalho(
              titulo: titulo,
              subtitulo: 'Segue o estado do serviço em tempo real.',
              mostrarVoltar: true,
            ),
            const SizedBox(height: 20),
            Mapa(
              lat: p.lat,
              lng: p.lng,
              prestadorLat: mostrarPrestadorNoMapa ? p.prestadorLat : null,
              prestadorLng: mostrarPrestadorNoMapa ? p.prestadorLng : null,
              etiquetas: [
                Etiqueta(
                  texto: p.prestador == null
                      ? 'A procurar…'
                      : '${p.prestador} • ${p.categoria.profissional}',
                  cor: Cores.texto,
                  corFundo: Cores.branco,
                ),
                if (mostrarPrestadorNoMapa)
                  Etiqueta(
                    texto: p.eta > 0 ? 'ETA ${p.eta} min' : 'Chegou',
                    cor: Cores.verde,
                    corFundo: Cores.verdeClaro,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (p.estado == EstadoPedido.aProcura)
              const Cartao(
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'A contactar os prestadores mais próximos…',
                        style: TextStyle(color: Cores.cinza),
                      ),
                    ),
                  ],
                ),
              )
            else
              BarraEstado(estado: p.estado),
            const SizedBox(height: 16),
            _cartaoAcoes(),
          ],
        ),
      ),
    );
  }

  // Botões que mudam consoante o estado.
  Widget _cartaoAcoes() {
    final Pedido p = widget.pedido;

    if (p.estado == EstadoPedido.concluido) {
      return BotaoPrincipal(texto: 'Pagar e avaliar', onPressed: pagar);
    }

    return Cartao(
      child: Column(
        children: [
          if (p.prestadorTelefone != null)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ligar(context, p.prestadorTelefone!),
                    icon: const Icon(Icons.call_outlined),
                    label: const Text('Ligar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        enviarMensagem(context, p.prestadorTelefone!),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Mensagem'),
                  ),
                ),
              ],
            ),
          if (p.estado == EstadoPedido.aCaminho) ...[
            const SizedBox(height: 12),
            BotaoPrincipal(
              texto: p.eta == 0 ? 'Ler QR de chegada' : 'QR disponível',
              onPressed: lerQr,
            ),
          ],
          if (p.estado == EstadoPedido.noLocal)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'O prestador está a trabalhar. No fim confirmas o valor.',
                style: TextStyle(color: Cores.cinza),
              ),
            ),
          if (p.estado == EstadoPedido.aProcura)
            const Text(
              'Assim que alguém aceitar, vês aqui o nome e o tempo de chegada.',
              style: TextStyle(color: Cores.cinza),
            ),
          if (p.podeCancelar) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: cancelar,
              style: TextButton.styleFrom(foregroundColor: Cores.vermelho),
              child: const Text('Cancelar pedido'),
            ),
          ],
        ],
      ),
    );
  }
}
