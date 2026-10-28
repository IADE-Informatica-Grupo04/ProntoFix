import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../tema/cores.dart';

// Lê o QR Code que o prestador mostra à chegada (RF07).
// Devolve o código lido com Navigator.pop (como no exemplo 2 da aula).
// Também dá para escrever o código à mão (emulador sem câmara).
class LerQrPage extends StatefulWidget {
  // Só para a demonstração: código certo, para simular a leitura.
  final String? codigoDemo;

  const LerQrPage({super.key, this.codigoDemo});

  @override
  State<LerQrPage> createState() => _LerQrPageState();
}

class _LerQrPageState extends State<LerQrPage> {
  bool jaLeu = false; // evita devolver o código duas vezes

  void devolver(String codigo) {
    if (jaLeu) return;
    jaLeu = true;
    Navigator.pop(context, codigo);
  }

  Future<void> escreverCodigo() async {
    final TextEditingController controller = TextEditingController();

    final String? codigo = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Escrever código'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Código (ex.: PFX-1234)',
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
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (codigo != null && codigo.trim().isNotEmpty && mounted) {
      devolver(codigo.trim().toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Ler QR de chegada'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Câmara a ler códigos QR
          MobileScanner(
            onDetect: (captura) {
              if (captura.barcodes.isEmpty) return;
              final String? valor = captura.barcodes.first.rawValue;
              if (valor != null) devolver(valor);
            },
          ),
          // Moldura no centro
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Cores.ciano, width: 3),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Aponta a câmara para o QR do prestador.',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: escreverCodigo,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Cores.azul,
                        ),
                        child: const Text('Escrever código à mão'),
                      ),
                    ),
                    if (widget.codigoDemo != null)
                      TextButton(
                        onPressed: () => devolver(widget.codigoDemo!),
                        child: Text(
                          'Demonstração: simular leitura (${widget.codigoDemo})',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
