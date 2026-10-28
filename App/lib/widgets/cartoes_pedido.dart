import 'package:flutter/material.dart';

import '../dados/dados_ficticios.dart';
import '../modelos/categoria.dart';
import '../modelos/pedido.dart';
import '../tema/cores.dart';
import 'componentes.dart';

// ---------------------------------------------------------------------
// Cartão de uma categoria ("Categorias rápidas" da Home).
// Igual em espírito ao CursoCard da aula: um objeto -> um widget.
// ---------------------------------------------------------------------
class CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onTap;

  const CategoriaCard({
    super.key,
    required this.categoria,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Cores.branco,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Cores.linha),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: categoria.corClara,
          child: Text(
            categoria.letra,
            style: TextStyle(
              color: categoria.cor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          categoria.nome,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Cores.texto,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Cores.cinza),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Cartão de um pedido: título, prestador/ETA, estado e barra de progresso.
// ---------------------------------------------------------------------
class PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback? onTap;

  const PedidoCard({super.key, required this.pedido, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Frase de baixo muda consoante o estado.
    String detalhe;
    if (pedido.estado == EstadoPedido.aProcura) {
      detalhe = 'À procura de prestador';
    } else if (pedido.estado == EstadoPedido.aCaminho) {
      detalhe = 'Prestador a caminho • ETA ${pedido.eta} min';
    } else if (pedido.estado == EstadoPedido.concluido) {
      detalhe = '${pedido.prestador} • ${dataCurta(pedido.data)}';
    } else if (pedido.estado == EstadoPedido.cancelado) {
      detalhe = 'Cancelado • ${dataCurta(pedido.data)}';
    } else {
      detalhe = '${pedido.prestador} • ${textoDoEstado(pedido.estado)}';
    }

    final bool emCurso = pedido.emCurso;
    // 5 etapas: aProcura (0) ... concluido (4)
    final double progresso = (pedido.estado.index + 1) / 5;

    return GestureDetector(
      onTap: onTap,
      child: Cartao(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    pedido.titulo,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Cores.texto,
                    ),
                  ),
                ),
                if (emCurso)
                  const Etiqueta(texto: 'Em curso')
                else if (pedido.estado == EstadoPedido.cancelado)
                  const Etiqueta(
                    texto: 'Cancelado',
                    cor: Cores.vermelho,
                    corFundo: Color(0xFFFDECEC),
                  )
                else
                  Etiqueta(
                        texto: pedido.total == null
                            ? 'Concluído'
                            : euros(pedido.total!),
                        cor: Cores.verde,
                        corFundo: Cores.verdeClaro,
                      ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              detalhe,
              style: const TextStyle(fontSize: 13, color: Cores.cinza),
            ),
            if (emCurso) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progresso,
                  minHeight: 8,
                  color: Cores.azul,
                  backgroundColor: Cores.fundo,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// "Estado do pedido": Atribuído → A caminho → No local → Concluído.
// ---------------------------------------------------------------------
class BarraEstado extends StatelessWidget {
  final EstadoPedido estado;

  const BarraEstado({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    const List<EstadoPedido> passos = [
      EstadoPedido.atribuido,
      EstadoPedido.aCaminho,
      EstadoPedido.noLocal,
      EstadoPedido.concluido,
    ];

    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TituloSecao('Estado do pedido'),
          Row(
            children: [
              for (int i = 0; i < passos.length; i++) ...[
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 9,
                        backgroundColor: estado.index >= passos[i].index
                            ? Cores.azul
                            : Cores.linha,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        textoDoEstado(passos[i]),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: estado == passos[i]
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: estado.index >= passos[i].index
                              ? Cores.texto
                              : Cores.cinza,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
