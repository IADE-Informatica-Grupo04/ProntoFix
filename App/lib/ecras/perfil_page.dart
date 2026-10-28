import 'package:flutter/material.dart';

import '../tema/cores.dart';
import '../widgets/componentes.dart';

// Perfil (igual para cliente e prestador).
class PerfilPage extends StatefulWidget {
  final String nome;
  final String tipo; // "Cliente" ou "Prestador"

  const PerfilPage({super.key, required this.nome, required this.tipo});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  bool notificacoes = true;
  bool partilharLocalizacao = true;

  void terminarSessao() {
    // Volta ao ecrã inicial e limpa a pilha de páginas.
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Cabecalho(titulo: 'Perfil', subtitulo: 'A tua conta ProntoFix.'),
        const SizedBox(height: 20),
        Cartao(
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Cores.azulClaro,
                child: Text(
                  widget.nome.isEmpty ? '?' : widget.nome[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Cores.azul,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Etiqueta(texto: widget.tipo),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Cartao(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Notificações'),
                value: notificacoes,
                onChanged: (value) {
                  setState(() {
                    notificacoes = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Partilhar localização nos pedidos'),
                value: partilharLocalizacao,
                onChanged: (value) {
                  setState(() {
                    partilharLocalizacao = value;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield_outlined),
                title: const Text('Privacidade e RGPD'),
                subtitle: const Text('Todos os dados desta versão são fictícios.'),
                onTap: () => mostrarMensagem(
                  context,
                  'Usamos a localização só durante um pedido.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: terminarSessao,
          icon: const Icon(Icons.logout, color: Cores.vermelho),
          label: const Text(
            'Terminar sessão',
            style: TextStyle(color: Cores.vermelho),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            side: const BorderSide(color: Cores.vermelho),
          ),
        ),
      ],
    );
  }
}
