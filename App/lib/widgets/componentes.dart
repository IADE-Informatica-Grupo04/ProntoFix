import 'package:flutter/material.dart';

import '../tema/cores.dart';

// Widgets reutilizáveis do ProntoFix.
// Cada um é um StatelessWidget: recebe os dados pelo construtor e
// desenha sempre da mesma forma (ideia da aula "widgets reutilizáveis").

// ---------------------------------------------------------------------
// Cabeçalho: título, subtítulo e o avatar "PF" no canto.
// ---------------------------------------------------------------------
class Cabecalho extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool mostrarVoltar;

  const Cabecalho({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.mostrarVoltar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mostrarVoltar)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: Cores.branco,
                side: const BorderSide(color: Cores.linha),
              ),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Cores.texto,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitulo,
                style: const TextStyle(fontSize: 13, color: Cores.cinza),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Cores.branco,
          child: Text(
            'PF',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Cores.azul,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Cartão branco com cantos arredondados e borda clara.
// ---------------------------------------------------------------------
class Cartao extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color cor;

  const Cartao({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.cor = Cores.branco,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Cores.linha),
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------
// Etiqueta (chip) colorida: "Em curso", "ETA 12 min", "€ 45 - € 60"...
// ---------------------------------------------------------------------
class Etiqueta extends StatelessWidget {
  final String texto;
  final Color cor;
  final Color corFundo;

  const Etiqueta({
    super.key,
    required this.texto,
    this.cor = Cores.azul,
    this.corFundo = Cores.azulClaro,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cor,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Botão azul principal (52 de altura, largura toda).
// ---------------------------------------------------------------------
class BotaoPrincipal extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;

  const BotaoPrincipal({super.key, required this.texto, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Cores.azul,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: Text(texto),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Grupo de opções (ChoiceChip): categoria, urgência, método de pagamento.
// ---------------------------------------------------------------------
class GrupoOpcoes extends StatelessWidget {
  final List<String> opcoes;
  final String? selecionada;
  final ValueChanged<String> onEscolher;

  const GrupoOpcoes({
    super.key,
    required this.opcoes,
    required this.selecionada,
    required this.onEscolher,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final String opcao in opcoes)
          ChoiceChip(
            label: Text(opcao),
            selected: opcao == selecionada,
            showCheckmark: false,
            onSelected: (_) => onEscolher(opcao),
            backgroundColor: Cores.branco,
            selectedColor: Cores.azulClaro,
            side: BorderSide(
              color: opcao == selecionada ? Cores.azulClaro : Cores.linha,
            ),
            shape: const StadiumBorder(),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: opcao == selecionada ? Cores.azul : Cores.cinza,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Título pequeno de secção ("Categoria", "Urgência"...).
// ---------------------------------------------------------------------
class TituloSecao extends StatelessWidget {
  final String texto;

  const TituloSecao(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Cores.texto,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Mensagem rápida no fundo do ecrã (SnackBar), usada em vários sítios.
// ---------------------------------------------------------------------
void mostrarMensagem(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(texto)),
  );
}
