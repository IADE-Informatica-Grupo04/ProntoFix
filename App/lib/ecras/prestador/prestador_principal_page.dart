import 'dart:async';

import 'package:flutter/material.dart';

import '../../dados/dados_ficticios.dart';
import '../../modelos/pedido.dart';
import '../../servicos/api.dart';
import '../cliente/cliente_principal_page.dart';
import '../perfil_page.dart';
import 'area_prestador_page.dart';
import 'servico_page.dart';
import 'servicos_feitos_page.dart';

// Área do prestador com o menu inferior.
// Guarda o estado partilhado: disponibilidade, pedido proposto,
// números do dia e serviços feitos.
class PrestadorPrincipalPage extends StatefulWidget {
  final String nome;

  const PrestadorPrincipalPage({super.key, required this.nome});

  @override
  State<PrestadorPrincipalPage> createState() => _PrestadorPrincipalPageState();
}

class _PrestadorPrincipalPageState extends State<PrestadorPrincipalPage> {
  int indiceAtual = 0;

  bool disponivel = false;
  Pedido? proposta; // "Novo pedido próximo"
  Timer? timerProposta;

  // Contagem decrescente para responder ao pedido (30 segundos).
  // Se o tempo acabar, o pedido passa ao prestador seguinte.
  static const int tempoResposta = 30;
  int segundosRestantes = tempoResposta;
  Timer? timerContagem;

  int pedidosHoje = 3;
  double ganhosHoje = 120;
  double avaliacao = 4.8;
  final List<Pedido> feitos = [];

  void mudarDisponibilidade(bool valor) {
    setState(() {
      disponivel = valor;
      proposta = null;
    });
    timerProposta?.cancel();
    timerContagem?.cancel();
    Api.definirDisponibilidade(valor); // PATCH /prestadores/:id/disponibilidade

    // Simulação: 3 segundos depois de ficar disponível chega um pedido.
    if (valor) {
      timerProposta = Timer(const Duration(seconds: 3), () {
        if (!mounted || !disponivel) return;
        setState(() {
          proposta = pedidoProximo();
          segundosRestantes = tempoResposta;
        });
        iniciarContagem();
      });
    }
  }

  void iniciarContagem() {
    timerContagem?.cancel();
    timerContagem = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        segundosRestantes--;
      });
      if (segundosRestantes <= 0) {
        timerContagem?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('O pedido expirou e passou a outro prestador.'),
          ),
        );
        recusar();
      }
    });
  }

  void recusar() {
    // Recusado: o pedido passa a outro prestador e chega um novo depois.
    mudarDisponibilidade(disponivel);
  }

  Future<void> aceitar() async {
    final Pedido? pedido = proposta;
    if (pedido == null) return;

    timerContagem?.cancel();
    setState(() {
      pedido.estado = EstadoPedido.atribuido;
      pedido.prestador = widget.nome;
      proposta = null;
    });
    Api.atualizarEstado(pedido); // PATCH /pedidos/:id/estado

    // O ecrã do serviço devolve true quando o prestador o conclui.
    final bool? concluiu = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (context) => ServicoPage(pedido: pedido),
      ),
    );

    if (!mounted) return;
    if (concluiu == true) {
      setState(() {
        feitos.insert(0, pedido);
        pedidosHoje++;
        ganhosHoje += pedido.total ?? 0;
      });
    }
    // Continua disponível: pode chegar o próximo pedido.
    mudarDisponibilidade(disponivel);
  }

  @override
  void dispose() {
    timerProposta?.cancel();
    timerContagem?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      AreaPrestadorPage(
        disponivel: disponivel,
        proposta: proposta,
        segundosRestantes: segundosRestantes,
        tempoResposta: tempoResposta,
        pedidosHoje: pedidosHoje,
        ganhosHoje: ganhosHoje,
        avaliacao: avaliacao,
        onMudarDisponibilidade: mudarDisponibilidade,
        onAceitar: aceitar,
        onRecusar: recusar,
      ),
      ServicosFeitosPage(
        feitos: feitos,
        pedidosHoje: pedidosHoje,
        ganhosHoje: ganhosHoje,
        avaliacao: avaliacao,
      ),
      PerfilPage(nome: widget.nome, tipo: 'Prestador'),
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
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
