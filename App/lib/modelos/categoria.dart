import 'package:flutter/material.dart';

// Uma categoria de serviço (como a classe Curso da aula de listas).
// Para acrescentar uma categoria nova basta juntar um objeto à lista
// "categorias" em dados/dados_ficticios.dart.
class Categoria {
  final String nome;
  final String letra; // letra do CircleAvatar ("C", "E", "S")
  final String profissional; // "Canalizador", "Eletricista"...
  final IconData icone;
  final Color cor;
  final Color corClara;

  const Categoria({
    required this.nome,
    required this.letra,
    required this.profissional,
    required this.icone,
    required this.cor,
    required this.corClara,
  });
}
