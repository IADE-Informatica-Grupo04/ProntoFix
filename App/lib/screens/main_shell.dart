import 'package:flutter/material.dart';

import '../widgets/pf_bottom_nav.dart';
import 'historico_screen.dart';
import 'home_cliente_screen.dart';
import 'painel_prestador_screen.dart';
import 'pedidos_screen.dart';
import 'perfil_screen.dart';

/// Estrutura com barra inferior: Início, Pedidos, Histórico e Perfil.
/// Cliente e prestador usam os mesmos separadores e ícones (consistência);
/// só o conteúdo muda. A barra desaparece no fluxo do pedido (RU03), porque
/// esses ecrãs são abertos por cima desta estrutura.
class MainShell extends StatefulWidget {
  final bool prestador;

  const MainShell({super.key, this.prestador = false});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    // Os separadores com dados do servidor só são criados quando se abrem,
    // para irem buscar os dados atualizados de cada vez (e pararem de
    // atualizar quando se sai deles).
    final separadores = <Widget>[
      _indice == 0
          ? (widget.prestador
              ? const PainelPrestadorScreen()
              : const HomeClienteScreen())
          : const SizedBox.shrink(),
      _indice == 1
          ? PedidosScreen(prestador: widget.prestador)
          : const SizedBox.shrink(),
      _indice == 2
          ? HistoricoScreen(prestador: widget.prestador)
          : const SizedBox.shrink(),
      PerfilScreen(prestador: widget.prestador),
    ];

    return Scaffold(
      body: IndexedStack(index: _indice, children: separadores),
      bottomNavigationBar: SafeArea(
        top: false,
        child: PFBottomNav(
          indice: _indice,
          onSelecionar: (i) => setState(() => _indice = i),
        ),
      ),
    );
  }
}
