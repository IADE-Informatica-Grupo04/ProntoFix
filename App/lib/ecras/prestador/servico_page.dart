import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/pedido.dart';
import '../../servicos/api.dart';
import '../../servicos/contacto.dart';
import '../../tema/cores.dart';
import '../../widgets/cartoes_pedido.dart';
import '../../widgets/componentes.dart';
import '../../widgets/mapa.dart';

// Serviço aceite pelo prestador (Guião 2): rota, QR de chegada e conclusão.
class ServicoPage extends StatefulWidget {
  final Pedido pedido;

  const ServicoPage({super.key, required this.pedido});

  @override
  State<ServicoPage> createState() => _ServicoPageState();
}

class _ServicoPageState extends State<ServicoPage> {
  void iniciarViagem() {
    setState(() {
      widget.pedido.estado = EstadoPedido.aCaminho;
    });
    Api.atualizarEstado(widget.pedido);
  }

  // Mostra o QR Code que o cliente lê com a câmara (RF07).
  Future<void> mostrarQr() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mostra este QR ao cliente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: QrImageView(
                  data: widget.pedido.codigoQr,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.pedido.codigoQr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'O cliente lê o código na app dele para confirmar a chegada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Cores.cinza),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('O cliente confirmou'),
            ),
          ],
        );
      },
    );
    if (!mounted) return;
    // Com servidor, é o servidor que muda para "no local" quando o cliente
    // lê o QR; aqui simulamos essa confirmação.
    setState(() {
      widget.pedido.estado = EstadoPedido.noLocal;
      widget.pedido.prestadorLat = widget.pedido.lat;
      widget.pedido.prestadorLng = widget.pedido.lng;
    });
  }

  // Formulário do valor final (mão de obra, material e o que foi feito).
  Future<void> concluir() async {
    final bool? concluiu = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _DialogoValorFinal(pedido: widget.pedido),
    );
    if (concluiu != true || !mounted) return;

    setState(() {
      widget.pedido.estado = EstadoPedido.concluido;
    });
    await Api.atualizarEstado(widget.pedido); // PATCH /pedidos/:id/estado
    if (!mounted) return;

    mostrarMensagem(
      context,
      'Serviço concluído: ${euros(widget.pedido.total ?? 0)}. '
      'O cliente vai pagar e avaliar.',
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final Pedido p = widget.pedido;
    final bool emViagem =
        p.estado == EstadoPedido.atribuido || p.estado == EstadoPedido.aCaminho;

    Widget botao;
    if (p.estado == EstadoPedido.atribuido) {
      botao = BotaoPrincipal(texto: 'Iniciar viagem', onPressed: iniciarViagem);
    } else if (p.estado == EstadoPedido.aCaminho) {
      botao = BotaoPrincipal(
        texto: 'Cheguei • mostrar QR',
        onPressed: mostrarQr,
      );
    } else {
      botao = BotaoPrincipal(texto: 'Concluir serviço', onPressed: concluir);
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Cabecalho(
              titulo: 'Serviço atual',
              subtitulo: 'Rota, QR de chegada e conclusão.',
              mostrarVoltar: true,
            ),
            const SizedBox(height: 20),
            Mapa(
              lat: p.lat,
              lng: p.lng,
              prestadorLat: emViagem ? p.prestadorLat : null,
              prestadorLng: emViagem ? p.prestadorLng : null,
              etiquetas: [
                Etiqueta(texto: p.cliente, cor: Cores.texto, corFundo: Cores.branco),
                Etiqueta(
                  texto: textoDoEstado(p.estado),
                  cor: Cores.verde,
                  corFundo: Cores.verdeClaro,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.categoria.nome,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (emViagem)
                        TextButton.icon(
                          onPressed: () => abrirRota(context, p.lat, p.lng),
                          icon: const Icon(Icons.navigation_outlined),
                          label: const Text('Rota'),
                        ),
                    ],
                  ),
                  Text(p.descricao),
                  const SizedBox(height: 8),
                  Text(
                    '${p.morada} • ${p.moradaDetalhe}',
                    style: const TextStyle(fontSize: 13, color: Cores.cinza),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Estimativa dada ao cliente: € ${p.precoMin} - € ${p.precoMax}',
                    style: const TextStyle(fontSize: 13, color: Cores.cinza),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            BarraEstado(estado: p.estado),
            const SizedBox(height: 24),
            botao,
          ],
        ),
      ),
    );
  }
}

// Janela com um pequeno formulário para o valor final do serviço.
// Guarda os valores no pedido e devolve true.
class _DialogoValorFinal extends StatefulWidget {
  final Pedido pedido;

  const _DialogoValorFinal({required this.pedido});

  @override
  State<_DialogoValorFinal> createState() => _DialogoValorFinalState();
}

class _DialogoValorFinalState extends State<_DialogoValorFinal> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController maoDeObraController = TextEditingController();
  final TextEditingController materialController =
      TextEditingController(text: '0');
  final TextEditingController resumoController = TextEditingController();

  double? lerValor(String texto) {
    return double.tryParse(texto.trim().replaceAll(',', '.'));
  }

  String? validarValor(String? value) {
    final double? numero = lerValor(value ?? '');
    if (numero == null || numero < 0) {
      return 'Introduz um valor válido.';
    }
    return null;
  }

  void concluir() {
    if (!formKey.currentState!.validate()) return;
    widget.pedido.maoDeObra = lerValor(maoDeObraController.text);
    widget.pedido.material = lerValor(materialController.text);
    widget.pedido.resumo = resumoController.text.trim();
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    maoDeObraController.dispose();
    materialController.dispose();
    resumoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Valor final do serviço'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Estimativa: € ${widget.pedido.precoMin} - € ${widget.pedido.precoMax}',
                style: const TextStyle(color: Cores.cinza),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: maoDeObraController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Mão de obra (€)',
                  border: OutlineInputBorder(),
                ),
                validator: validarValor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: materialController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Material (€)',
                  border: OutlineInputBorder(),
                ),
                validator: validarValor,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: resumoController,
                decoration: const InputDecoration(
                  labelText: 'O que foi feito',
                  hintText: 'Ex.: Cano substituído + teste de fuga',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 3) {
                    return 'Descreve o serviço em poucas palavras.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: concluir, child: const Text('Concluir')),
      ],
    );
  }
}
