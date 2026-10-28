import 'package:flutter/material.dart';

import '../modelos/categoria.dart';
import '../modelos/pedido.dart';
import '../tema/cores.dart';

// Dados fictícios usados enquanto o servidor (API REST) não está pronto.
// Quando houver backend, estas listas passam a vir da API.

const List<Categoria> categorias = [
  Categoria(
    nome: 'Canalização',
    letra: 'C',
    profissional: 'Canalizador',
    icone: Icons.water_drop_outlined,
    cor: Cores.azul,
    corClara: Cores.azulClaro,
  ),
  Categoria(
    nome: 'Eletricidade',
    letra: 'E',
    profissional: 'Eletricista',
    icone: Icons.bolt,
    cor: Cores.laranja,
    corClara: Cores.laranjaClaro,
  ),
  Categoria(
    nome: 'Serralharia',
    letra: 'S',
    profissional: 'Serralheiro',
    icone: Icons.key_outlined,
    cor: Cores.verde,
    corClara: Cores.verdeClaro,
  ),
];

// Procura uma categoria pelo nome (usado ao ler JSON da API).
Categoria categoriaPorNome(String nome) {
  for (final Categoria c in categorias) {
    if (c.nome.toLowerCase() == nome.toLowerCase()) return c;
  }
  return categorias[0];
}

// Morada usada quando o GPS não está disponível (ex.: emulador).
const String moradaPorOmissao = 'Rua Exemplo, Lisboa';
const String moradaDetalhePorOmissao = 'Número 12 • 2º andar • Cód. 1500-001';
const double latPorOmissao = 38.7223;
const double lngPorOmissao = -9.1393;

const List<String> urgencias = ['Normal', 'Hoje', 'Agora'];

const List<String> metodosPagamento = ['MB Way', 'Cartão', 'Dinheiro'];

// Estimativa de preço (em euros) consoante a categoria e a urgência.
List<int> estimarPreco(Categoria categoria, String urgencia) {
  int minimo = 35;
  int maximo = 50;
  if (categoria.nome == 'Eletricidade') {
    minimo = 40;
    maximo = 55;
  } else if (categoria.nome == 'Serralharia') {
    minimo = 45;
    maximo = 65;
  }
  if (urgencia == 'Normal') {
    minimo -= 10;
    maximo -= 10;
  } else if (urgencia == 'Hoje') {
    minimo -= 5;
    maximo -= 5;
  }
  return [minimo, maximo];
}

// Estimativa de chegada (em minutos) consoante a urgência.
List<int> estimarChegada(String urgencia) {
  if (urgencia == 'Normal') return [120, 180];
  if (urgencia == 'Hoje') return [45, 60];
  return [16, 20];
}

// Pedidos antigos do cliente, para o histórico.
List<Pedido> pedidosAntigos() {
  return [
    Pedido(
      id: 101,
      categoria: categorias[1],
      descricao: 'Disjuntor da cozinha dispara sempre',
      urgencia: 'Hoje',
      morada: 'Rua Exemplo, Lisboa',
      moradaDetalhe: 'Número 12 • 2º andar • Cód. 1500-001',
      lat: latPorOmissao,
      lng: lngPorOmissao,
      precoMin: 35,
      precoMax: 50,
      etaMin: 45,
      etaMax: 60,
      data: DateTime(2026, 10, 15, 19, 40),
      estado: EstadoPedido.concluido,
      prestador: 'Ana Ribeiro',
      maoDeObra: 38,
      material: 8.5,
      resumo: 'Disjuntor substituído',
      metodoPagamento: 'MB Way',
      estrelas: 5,
      comentario: 'Muito rápida e simpática.',
    ),
    Pedido(
      id: 100,
      categoria: categorias[2],
      descricao: 'Porta trancada com a chave do lado de dentro',
      urgencia: 'Agora',
      morada: 'Rua Exemplo, Lisboa',
      moradaDetalhe: 'Número 12 • 2º andar • Cód. 1500-001',
      lat: latPorOmissao,
      lng: lngPorOmissao,
      precoMin: 45,
      precoMax: 65,
      etaMin: 16,
      etaMax: 20,
      data: DateTime(2026, 9, 18, 23, 5),
      estado: EstadoPedido.concluido,
      prestador: 'Rui Almeida',
      maoDeObra: 45,
      material: 0,
      resumo: 'Abertura de porta sem danos',
      metodoPagamento: 'Cartão',
      estrelas: 4,
    ),
  ];
}

// Pedido que aparece ao prestador quando fica disponível.
Pedido pedidoProximo() {
  return Pedido(
    id: 205,
    categoria: categorias[0],
    descricao: 'Fuga na cozinha. O cano debaixo do lava-loiça está a pingar.',
    urgencia: 'Agora',
    morada: 'Rua da Graça, 54, Lisboa',
    moradaDetalhe: '3º esq. • Cód. 1170-165',
    lat: 38.7185,
    lng: -9.1310,
    cliente: 'Marta Gonçalves',
    precoMin: 45,
    precoMax: 60,
    etaMin: 10,
    etaMax: 14,
    data: DateTime.now(),
    eta: 12,
    // o prestador começa a cerca de 1,8 km do cliente
    prestadorLat: 38.7040,
    prestadorLng: -9.1420,
  );
}

// Posição do prestador quando aceita um pedido (a ~1,8 km da morada).
List<double> posicaoInicialPrestador(double lat, double lng) {
  return [lat - 0.012, lng - 0.010];
}

// Ponto entre a posição atual e o destino (t = 0 no início, 1 no fim).
// Serve para simular o prestador a aproximar-se no mapa.
List<double> aproximar(double lat, double lng, double latDestino,
    double lngDestino, double t) {
  return [lat + (latDestino - lat) * t, lng + (lngDestino - lng) * t];
}

// Formatação simples em português.
String euros(double valor) {
  return '€ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

String dataCurta(DateTime d) {
  const List<String> meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  final String hora = d.hour.toString().padLeft(2, '0');
  final String minuto = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${meses[d.month - 1]} • $hora:$minuto';
}
