import 'package:flutter/material.dart';

import '../../modelos/pedido.dart';
import '../../tema/cores.dart';
import '../../widgets/componentes.dart';

// 08 Área do prestador — disponibilidade, resumo do dia e pedido próximo.
class AreaPrestadorPage extends StatelessWidget {
  final bool disponivel;
  final Pedido? proposta;
  final int segundosRestantes;
  final int tempoResposta;
  final int pedidosHoje;
  final double ganhosHoje;
  final double avaliacao;
  final ValueChanged<bool> onMudarDisponibilidade;
  final VoidCallback onAceitar;
  final VoidCallback onRecusar;

  const AreaPrestadorPage({
    super.key,
    required this.disponivel,
    required this.proposta,
    required this.segundosRestantes,
    required this.tempoResposta,
    required this.pedidosHoje,
    required this.ganhosHoje,
    required this.avaliacao,
    required this.onMudarDisponibilidade,
    required this.onAceitar,
    required this.onRecusar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Cabecalho(
          titulo: 'Área do prestador',
          subtitulo: 'Disponibilidade, pedidos e resumo do dia.',
        ),
        const SizedBox(height: 20),

        // Disponível agora + interruptor
        Cartao(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disponivel ? 'Disponível agora' : 'Indisponível',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Recebe pedidos próximos automaticamente.',
                      style: TextStyle(fontSize: 13, color: Cores.cinza),
                    ),
                  ],
                ),
              ),
              Switch(
                value: disponivel,
                activeTrackColor: Cores.verde,
                onChanged: onMudarDisponibilidade,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Resumo do dia (cartão azul)
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Cores.azul,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoje',
                style: TextStyle(color: Color(0xFFDCE6FF), fontSize: 12),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _numero('$pedidosHoje', 'pedidos'),
                  _numero('€ ${ganhosHoje.round()}', 'ganhos'),
                  _numero(
                    avaliacao.toStringAsFixed(1).replaceAll('.', ','),
                    'avaliação',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Novo pedido próximo (só aparece quando há uma proposta)
        if (proposta != null)
          _cartaoProposta(proposta!)
        else
          Cartao(
            child: Row(
              children: [
                Icon(
                  disponivel ? Icons.hourglass_top : Icons.power_settings_new,
                  color: Cores.cinza,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    disponivel
                        ? 'À espera de pedidos perto de ti…'
                        : 'Ativa a disponibilidade para receber pedidos.',
                    style: const TextStyle(color: Cores.cinza),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Hoje ainda
        const Cartao(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TituloSecao('Hoje ainda'),
              _LinhaCinzenta('2 serviços agendados'),
              SizedBox(height: 8),
              _LinhaCinzenta('1 visita por confirmar'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _numero(String valor, String rotulo) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            valor,
            style: const TextStyle(
              color: Cores.branco,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(rotulo, style: const TextStyle(color: Color(0xFFDCE6FF))),
        ],
      ),
    );
  }

  Widget _cartaoProposta(Pedido p) {
    return Cartao(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Novo pedido próximo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              // Contagem decrescente: fica vermelha nos últimos 10 segundos
              Etiqueta(
                texto: '00:${segundosRestantes.toString().padLeft(2, '0')}',
                cor: segundosRestantes <= 10 ? Cores.vermelho : Cores.azul,
                corFundo: segundosRestantes <= 10
                    ? const Color(0xFFFDECEC)
                    : Cores.azulClaro,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${p.categoria.nome} • 1,8 km • morada confirmada',
            style: const TextStyle(fontSize: 13, color: Cores.cinza),
          ),
          const SizedBox(height: 4),
          Text(p.titulo, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: segundosRestantes / tempoResposta,
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Etiqueta(
                texto: '€ ${p.precoMin} - € ${p.precoMax}',
                cor: Cores.laranja,
                corFundo: Cores.laranjaClaro,
              ),
              const Spacer(),
              TextButton(onPressed: onRecusar, child: const Text('Recusar')),
              const SizedBox(width: 6),
              FilledButton(
                onPressed: onAceitar,
                style: FilledButton.styleFrom(
                  backgroundColor: Cores.azul,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Aceitar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinhaCinzenta extends StatelessWidget {
  final String texto;

  const _LinhaCinzenta(this.texto);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Cores.fundo,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(texto, style: const TextStyle(color: Cores.cinza)),
    );
  }
}
