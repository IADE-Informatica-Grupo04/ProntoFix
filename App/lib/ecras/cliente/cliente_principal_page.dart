import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/categoria.dart';
import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../perfil_page.dart';
import 'acompanhamento_page.dart';
import 'criar_pedido_page.dart';
import 'home_page.dart';
import 'mapa_page.dart';
import 'pedidos_page.dart';

// Área do cliente com o menu inferior (BottomNavigationBar).
//
// Esta página guarda o estado que é partilhado pelos separadores:
// o pedido em curso e o histórico. Os separadores recebem esses dados
// pelo construtor e avisam esta página através de funções (callbacks).
class ClientePrincipalPage extends StatefulWidget {
  final String nome;

  const ClientePrincipalPage({super.key, required this.nome});

  @override
  State<ClientePrincipalPage> createState() => _ClientePrincipalPageState();
}

class _ClientePrincipalPageState extends State<ClientePrincipalPage> {
  int indiceAtual = 0;
  Pedido? pedidoAtivo;
  final List<Pedido> historico = pedidosAntigos();

  // 1. Abre o "Criar pedido" e espera o pedido criado (Navigator.push
  //    com resposta, como no exemplo 2 da aula de navegação).
  // 2. Depois abre logo o acompanhamento.
  Future<void> novoPedido([Categoria? categoria, String descricao = '']) async {
    if (pedidoAtivo != null) {
      abrirAcompanhamento();
      return;
    }

    final Pedido? criado = await Navigator.push<Pedido>(
      context,
      MaterialPageRoute<Pedido>(
        builder: (context) => CriarPedidoPage(
          categoriaInicial: categoria,
          descricaoInicial: descricao,
        ),
      ),
    );

    if (!mounted || criado == null) return;
    setState(() {
      pedidoAtivo = criado;
    });
    abrirAcompanhamento();
  }

  Future<void> abrirAcompanhamento() async {
    final Pedido? pedido = pedidoAtivo;
    if (pedido == null) return;

    // O acompanhamento devolve true quando o pedido foi pago e avaliado.
    final bool? terminou = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => AcompanhamentoPage(pedido: pedido),
      ),
    );

    if (!mounted) return;
    setState(() {
      if (terminou == true) {
        historico.insert(0, pedido);
        pedidoAtivo = null;
      }
      // mesmo sem terminar (voltou atrás), o pedido pode ter mudado:
      // o setState volta a desenhar a Home com os dados novos.
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      HomePage(
        nome: widget.nome,
        pedidoAtivo: pedidoAtivo,
        onNovoPedido: novoPedido,
        onAbrirPedido: abrirAcompanhamento,
      ),
      PedidosPage(
        pedidoAtivo: pedidoAtivo,
        historico: historico,
        onAbrirPedido: abrirAcompanhamento,
        // "Repetir pedido": abre o Criar pedido já preenchido
        onRepetir: (antigo) => novoPedido(antigo.categoria, antigo.descricao),
      ),
      MapaPage(pedidoAtivo: pedidoAtivo, onAbrirPedido: abrirAcompanhamento),
      PerfilPage(nome: widget.nome, tipo: 'Cliente'),
    ];

    return Scaffold(
      body: SafeArea(child: paginas[indiceAtual]),
      bottomNavigationBar: MenuInferior(
        indiceAtual: indiceAtual,
        onTap: (novoIndice) {
          setState(() {
            indiceAtual = novoIndice;
          });
        },
        itens: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Mapa'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Menu inferior com o aspeto do Figma (barra branca arredondada).
// Por dentro é o BottomNavigationBar normal da aula.
class MenuInferior extends StatelessWidget {
  final int indiceAtual;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> itens;

  const MenuInferior({
    super.key,
    required this.indiceAtual,
    required this.onTap,
    required this.itens,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Cores.branco,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Cores.linha),
        ),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: indiceAtual,
          onTap: onTap,
          items: itens,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Cores.branco,
          elevation: 0,
          selectedItemColor: Cores.azul,
          unselectedItemColor: Cores.cinza,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
