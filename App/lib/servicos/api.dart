import 'dart:convert';

import 'package:http/http.dart' as http;

import '../modelos/pedido.dart';

// Ligação à API REST do servidor ProntoFix (Node.js + MySQL).
//
// Enquanto o servidor não estiver pronto, "usarDadosFicticios" fica a true:
// as funções não fazem pedidos à rede e a app usa os dados de
// dados/dados_ficticios.dart. Quando o backend estiver pronto, basta mudar
// para false e confirmar o endereço em "enderecoServidor".
class Api {
  static const bool usarDadosFicticios = true;

  // 10.0.2.2 é o "localhost" do computador visto a partir do emulador Android.
  static const String enderecoServidor = 'http://10.0.2.2:3000';

  // Token devolvido pelo login; vai em todos os pedidos seguintes.
  static String? token;

  static Map<String, String> get _cabecalhos => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // POST /auth/login -> true se o email e a palavra-passe estão certos.
  static Future<bool> login(String email, String password, String tipo) async {
    if (usarDadosFicticios) return true;

    final http.Response resposta = await http.post(
      Uri.parse('$enderecoServidor/auth/login'),
      headers: _cabecalhos,
      body: jsonEncode({
        'email': email,
        'password': password,
        'tipo': tipo.toLowerCase(),
      }),
    );
    if (resposta.statusCode != 200) return false;
    token = jsonDecode(resposta.body)['token'];
    return true;
  }

  // POST /auth/register
  static Future<bool> registar(Map<String, dynamic> dados) async {
    if (usarDadosFicticios) return true;

    final http.Response resposta = await http.post(
      Uri.parse('$enderecoServidor/auth/register'),
      headers: _cabecalhos,
      body: jsonEncode(dados),
    );
    return resposta.statusCode == 201 || resposta.statusCode == 200;
  }

  // POST /pedidos
  static Future<void> criarPedido(Pedido pedido) async {
    if (usarDadosFicticios) return;

    await http.post(
      Uri.parse('$enderecoServidor/pedidos'),
      headers: _cabecalhos,
      body: jsonEncode(pedido.toJson()),
    );
  }

  // GET /pedidos/:id -> estado atual do pedido (e posição do prestador)
  static Future<Pedido?> obterPedido(int id) async {
    if (usarDadosFicticios) return null;

    final http.Response resposta = await http.get(
      Uri.parse('$enderecoServidor/pedidos/$id'),
      headers: _cabecalhos,
    );
    if (resposta.statusCode != 200) return null;
    return Pedido.fromJson(jsonDecode(resposta.body));
  }

  // PATCH /pedidos/:id/estado (prestador muda o estado do serviço)
  static Future<void> atualizarEstado(Pedido pedido) async {
    if (usarDadosFicticios) return;

    await http.patch(
      Uri.parse('$enderecoServidor/pedidos/${pedido.id}/estado'),
      headers: _cabecalhos,
      body: jsonEncode({
        'estado': estadosApi[pedido.estado.index],
        'mao_de_obra': pedido.maoDeObra,
        'material': pedido.material,
        'resumo_servico': pedido.resumo,
      }),
    );
  }

  // PATCH /pedidos/:id/cancelar
  static Future<void> cancelarPedido(int id) async {
    if (usarDadosFicticios) return;

    await http.patch(
      Uri.parse('$enderecoServidor/pedidos/$id/cancelar'),
      headers: _cabecalhos,
    );
  }

  // POST /pedidos/:id/chegada -> o servidor confirma o código do QR
  static Future<bool> validarChegada(Pedido pedido, String codigo) async {
    if (usarDadosFicticios) return codigo.trim() == pedido.codigoQr;

    final http.Response resposta = await http.post(
      Uri.parse('$enderecoServidor/pedidos/${pedido.id}/chegada'),
      headers: _cabecalhos,
      body: jsonEncode({'codigo': codigo}),
    );
    return resposta.statusCode == 200;
  }

  // POST /pedidos/:id/avaliacao (com o método de pagamento simulado)
  static Future<void> pagarEAvaliar(Pedido pedido) async {
    if (usarDadosFicticios) return;

    await http.post(
      Uri.parse('$enderecoServidor/pedidos/${pedido.id}/avaliacao'),
      headers: _cabecalhos,
      body: jsonEncode({
        'metodo_pagamento': pedido.metodoPagamento,
        'estrelas': pedido.estrelas,
        'comentario': pedido.comentario,
      }),
    );
  }

  // PATCH /prestadores/:id/disponibilidade
  static Future<void> definirDisponibilidade(bool disponivel) async {
    if (usarDadosFicticios) return;

    await http.patch(
      Uri.parse('$enderecoServidor/prestadores/eu/disponibilidade'),
      headers: _cabecalhos,
      body: jsonEncode({'disponivel': disponivel}),
    );
  }
}
