import 'package:flutter/widgets.dart';

/// Categoria de serviço disponível na aplicação (ex.: Canalização).
class Servico {
  final String nome;
  final IconData icone;
  final Color corFundo;

  const Servico({
    required this.nome,
    required this.icone,
    required this.corFundo,
  });
}
