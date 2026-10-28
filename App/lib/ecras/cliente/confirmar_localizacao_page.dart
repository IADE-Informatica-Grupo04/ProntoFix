import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/categoria.dart';
import '../../modelos/pedido.dart';
import '../../servicos/api.dart';
import '../../servicos/localizacao.dart';
import '../../tema/cores.dart';
import '../../widgets/componentes.dart';
import '../../widgets/mapa.dart';

// 05 Confirmar localização — morada (GPS) e estimativa de preço e chegada.
class ConfirmarLocalizacaoPage extends StatefulWidget {
  final Categoria categoria;
  final String descricao;
  final String urgencia;
  final String? fotoPath;

  const ConfirmarLocalizacaoPage({
    super.key,
    required this.categoria,
    required this.descricao,
    required this.urgencia,
    this.fotoPath,
  });

  @override
  State<ConfirmarLocalizacaoPage> createState() =>
      _ConfirmarLocalizacaoPageState();
}

class _ConfirmarLocalizacaoPageState extends State<ConfirmarLocalizacaoPage> {
  bool aCarregar = true; // enquanto o GPS responde
  bool aEnviar = false;
  bool moradaAproximada = false;

  String morada = moradaPorOmissao;
  String moradaDetalhe = moradaDetalhePorOmissao;
  double lat = latPorOmissao;
  double lng = lngPorOmissao;

  @override
  void initState() {
    super.initState();
    carregarLocalizacao();
  }

  Future<void> carregarLocalizacao() async {
    final Localizacao local = await obterLocalizacao();
    if (!mounted) return;
    setState(() {
      morada = local.morada;
      moradaDetalhe = local.detalhe;
      lat = local.lat;
      lng = local.lng;
      moradaAproximada = local.aproximada;
      aCarregar = false;
    });
  }

  Future<void> alterarMorada() async {
    final TextEditingController controller =
        TextEditingController(text: morada);

    final String? nova = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Alterar morada'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Rua e localidade',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (nova != null && nova.trim().isNotEmpty && mounted) {
      setState(() {
        morada = nova.trim();
        moradaAproximada = false;
      });
    }
  }

  Future<void> confirmar() async {
    final List<int> preco = estimarPreco(widget.categoria, widget.urgencia);
    final List<int> chegada = estimarChegada(widget.urgencia);

    final Pedido pedido = Pedido(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      categoria: widget.categoria,
      descricao: widget.descricao,
      urgencia: widget.urgencia,
      morada: morada,
      moradaDetalhe: moradaDetalhe,
      lat: lat,
      lng: lng,
      fotoPath: widget.fotoPath,
      precoMin: preco[0],
      precoMax: preco[1],
      etaMin: chegada[0],
      etaMax: chegada[1],
      data: DateTime.now(),
    );

    setState(() {
      aEnviar = true;
    });
    await Api.criarPedido(pedido); // POST /pedidos
    if (!mounted) return;

    // Devolve o pedido criado ao ecrã anterior.
    Navigator.pop(context, pedido);
  }

  @override
  Widget build(BuildContext context) {
    final List<int> preco = estimarPreco(widget.categoria, widget.urgencia);
    final List<int> chegada = estimarChegada(widget.urgencia);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Cabecalho(
              titulo: 'Confirmar localização',
              subtitulo: 'Revê a morada e a estimativa antes de confirmar.',
              mostrarVoltar: true,
            ),
            const SizedBox(height: 20),
            if (aCarregar)
              const Cartao(
                child: SizedBox(
                  height: 178,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text(
                        'A obter a tua localização…',
                        style: TextStyle(color: Cores.cinza),
                      ),
                    ],
                  ),
                ),
              )
            else
              Mapa(
                lat: lat,
                lng: lng,
                etiquetas: [
                  moradaAproximada
                      ? const Etiqueta(
                          texto: 'Confirma a morada',
                          cor: Cores.laranja,
                          corFundo: Cores.laranjaClaro,
                        )
                      : const Etiqueta(
                          texto: 'Morada verificada',
                          corFundo: Cores.branco,
                        ),
                  Etiqueta(
                    texto: 'ETA ${chegada[0]} min',
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
                          morada,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Cores.texto,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: alterarMorada,
                        child: const Text('Alterar'),
                      ),
                    ],
                  ),
                  Text(
                    moradaDetalhe,
                    style: const TextStyle(fontSize: 13, color: Cores.cinza),
                  ),
                  const SizedBox(height: 18),
                  const Text('Estimativa', style: TextStyle(color: Cores.cinza)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _caixaEstimativa(
                          '€ ${preco[0]} - € ${preco[1]}',
                          Cores.azul,
                          Cores.azulClaro,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _caixaEstimativa(
                          chegada[0] >= 60
                              ? '${chegada[0] ~/ 60} - ${chegada[1] ~/ 60} h'
                              : '${chegada[0]} - ${chegada[1]} min',
                          Cores.laranja,
                          Cores.laranjaClaro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sem custos escondidos: só pagas depois do serviço.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Cores.cinza),
            ),
            const SizedBox(height: 16),
            BotaoPrincipal(
              texto: aEnviar ? 'A enviar…' : 'Confirmar pedido',
              onPressed: aCarregar || aEnviar ? null : confirmar,
            ),
          ],
        ),
      ),
    );
  }

  Widget _caixaEstimativa(String texto, Color cor, Color corFundo) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
    );
  }
}
