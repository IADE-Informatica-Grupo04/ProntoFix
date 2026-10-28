import 'package:flutter/material.dart';

import '../tema/cores.dart';
import '../widgets/componentes.dart';

// 01 Splash — primeiro ecrã da app (fundo escuro).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.azulNoite,
      body: Stack(
        children: [
          // Círculos decorativos do fundo (Stack + Positioned)
          const Positioned(
            top: -40,
            right: -60,
            child: CircleAvatar(radius: 110, backgroundColor: Color(0xFF1C4E67)),
          ),
          const Positioned(
            top: 110,
            left: 30,
            child: CircleAvatar(radius: 30, backgroundColor: Color(0xFF2A3A55)),
          ),
          const Positioned(
            bottom: 20,
            left: -70,
            child: CircleAvatar(radius: 110, backgroundColor: Color(0xFF3A3F4B)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Etiqueta(
                    texto: '24/7 urgência doméstica',
                    cor: Cores.branco,
                    corFundo: Color(0xFF2A3A55),
                  ),
                  const Spacer(),
                  const Text(
                    'ProntoFix',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Cores.branco,
                    ),
                  ),
                  const Text(
                    'Reparações urgentes ao domicílio',
                    style: TextStyle(fontSize: 16, color: Color(0xFFC9D3E3)),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Um pedido. Um prestador. Um mapa.',
                    style: TextStyle(fontSize: 26, color: Color(0xFFD9E3F2)),
                  ),
                  const SizedBox(height: 24),
                  _cartaoServicos(),
                  const SizedBox(height: 20),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Etiqueta(texto: 'Preço estimado'),
                      Etiqueta(
                        texto: 'Mapa ao vivo',
                        cor: Color(0xFF0E7C8C),
                        corFundo: Cores.cianoClaro,
                      ),
                      Etiqueta(
                        texto: 'QR seguro',
                        cor: Cores.laranja,
                        corFundo: Cores.laranjaClaro,
                      ),
                    ],
                  ),
                  const Spacer(),
                  BotaoPrincipal(
                    texto: 'Começar em 30 segundos',
                    onPressed: () => Navigator.pushNamed(context, '/registo'),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: const Text(
                        'Já tenho conta',
                        style: TextStyle(
                          color: Cores.branco,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cartão com os círculos e as três categorias.
  Widget _cartaoServicos() {
    return Container(
      height: 170,
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Cores.azulNoiteCartao,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2E4266)),
      ),
      child: const Stack(
        children: [
          Positioned(
            left: 40,
            top: 0,
            child: CircleAvatar(radius: 46, backgroundColor: Color(0xFF2D4FA8)),
          ),
          Positioned(
            left: 110,
            top: -14,
            child: CircleAvatar(radius: 30, backgroundColor: Color(0xFF237A99)),
          ),
          Positioned(
            left: 160,
            top: 30,
            child: CircleAvatar(radius: 20, backgroundColor: Color(0xFF7A5E52)),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Canalização • Eletricidade • Serralharia',
              style: TextStyle(
                color: Cores.branco,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
