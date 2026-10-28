import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/categoria.dart';
import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../../widgets/componentes.dart';
import 'confirmar_localizacao_page.dart';

// 04 Criar pedido — categoria, descrição, foto e urgência.
class CriarPedidoPage extends StatefulWidget {
  final Categoria? categoriaInicial;
  final String descricaoInicial; // usado no "Repetir pedido"

  const CriarPedidoPage({
    super.key,
    this.categoriaInicial,
    this.descricaoInicial = '',
  });

  @override
  State<CriarPedidoPage> createState() => _CriarPedidoPageState();
}

class _CriarPedidoPageState extends State<CriarPedidoPage> {
  final TextEditingController descricaoController = TextEditingController();

  Categoria? categoria;
  String urgencia = 'Agora';
  String? fotoPath; // caminho da fotografia escolhida

  @override
  void initState() {
    super.initState();
    // Se o cliente tocou numa categoria na Home, já vem escolhida.
    categoria = widget.categoriaInicial;
    descricaoController.text = widget.descricaoInicial;
  }

  // Pergunta se a foto vem da câmara ou da galeria e guarda o caminho.
  Future<void> escolherFoto() async {
    final ImageSource? origem = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
              if (fotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remover fotografia'),
                  onTap: () {
                    setState(() {
                      fotoPath = null;
                    });
                    Navigator.pop(sheetContext);
                  },
                ),
            ],
          ),
        );
      },
    );
    if (origem == null || !mounted) return;

    final XFile? foto = await ImagePicker().pickImage(
      source: origem,
      maxWidth: 1280,
      imageQuality: 70,
    );
    if (foto != null && mounted) {
      setState(() {
        fotoPath = foto.path;
      });
    }
  }

  Future<void> continuar() async {
    final String descricao = descricaoController.text.trim();

    if (categoria == null) {
      mostrarMensagem(context, 'Escolhe a categoria da avaria.');
      return;
    }
    if (descricao.length < 5) {
      mostrarMensagem(context, 'Descreve o problema em poucas palavras.');
      return;
    }

    // Passa os dados ao ecrã seguinte pelo construtor e espera a resposta.
    final Pedido? pedido = await Navigator.push<Pedido>(
      context,
      MaterialPageRoute<Pedido>(
        builder: (context) => ConfirmarLocalizacaoPage(
          categoria: categoria!,
          descricao: descricao,
          urgencia: urgencia,
          fotoPath: fotoPath,
        ),
      ),
    );

    // Se o pedido foi confirmado, devolve-o à página principal.
    if (pedido != null && mounted) {
      Navigator.pop(context, pedido);
    }
  }

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Cabecalho(
              titulo: 'Criar pedido',
              subtitulo: 'Descreve a avaria e anexa uma foto.',
              mostrarVoltar: true,
            ),
            const SizedBox(height: 20),

            // Categoria
            const TituloSecao('Categoria'),
            GrupoOpcoes(
              opcoes: [for (final c in categorias) c.nome],
              selecionada: categoria?.nome,
              onEscolher: (nome) {
                setState(() {
                  categoria = categorias.firstWhere((c) => c.nome == nome);
                });
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TituloSecao('O que está a acontecer?'),
                  TextField(
                    controller: descricaoController,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      hintText:
                          'Ex.: "O cano começou a pingar e já molhou o chão."',
                      hintStyle: const TextStyle(color: Cores.cinza),
                      filled: true,
                      fillColor: Cores.fundo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Foto da avaria (câmara ou galeria)
            Cartao(
              padding: const EdgeInsets.all(6),
              child: ListTile(
                onTap: escolherFoto,
                leading: fotoPath == null
                    ? const CircleAvatar(
                        backgroundColor: Cores.azulClaro,
                        child: Icon(
                          Icons.photo_camera_outlined,
                          color: Cores.azul,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(fotoPath!),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                title: Text(
                  fotoPath == null
                      ? 'Adicionar fotografia'
                      : 'Fotografia adicionada',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  fotoPath == null ? 'Foto da avaria' : 'Toca para trocar',
                ),
                trailing: const Icon(Icons.add, color: Cores.azul),
              ),
            ),
            const SizedBox(height: 16),

            // Urgência
            Cartao(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TituloSecao('Urgência'),
                  GrupoOpcoes(
                    opcoes: urgencias,
                    selecionada: urgencia,
                    onEscolher: (opcao) {
                      setState(() {
                        urgencia = opcao;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            BotaoPrincipal(texto: 'Continuar', onPressed: continuar),
          ],
        ),
      ),
    );
  }
}
