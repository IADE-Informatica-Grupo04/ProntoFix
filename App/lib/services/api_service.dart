import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pedido.dart';

/// Endereço do servidor.
///
/// Por omissão usa 10.0.2.2, que é o "localhost" do computador visto a
/// partir do emulador Android. Num telemóvel verdadeiro, usar o IP do
/// computador na rede Wi-Fi:
///   flutter run --dart-define=API_URL=http://192.168.1.20:3000
const String enderecoApi = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

/// Erro devolvido pela API, já com uma mensagem pronta a mostrar.
class ApiException implements Exception {
  final String mensagem;
  final int? codigo;

  const ApiException(this.mensagem, [this.codigo]);

  @override
  String toString() => mensagem;
}

/// Utilizador com sessão iniciada.
class Utilizador {
  final int id;
  final String nome;
  final String email;
  final String? telefone;
  final bool prestador;
  final String? especialidade;

  const Utilizador({
    required this.id,
    required this.nome,
    required this.email,
    required this.prestador,
    this.telefone,
    this.especialidade,
  });

  String get primeiroNome => nome.trim().split(' ').first;

  factory Utilizador.fromJson(Map<String, dynamic> json) => Utilizador(
        id: json['id'] as int,
        nome: (json['nome'] ?? '') as String,
        email: (json['email'] ?? '') as String,
        telefone: json['telefone'] as String?,
        prestador: json['tipo'] == 'tecnico' || json['tipo'] == 'prestador',
        especialidade: json['especialidade'] as String?,
      );
}

/// Estimativa devolvida por POST /pedidos/estimativa (ecrã CL5).
class Estimativa {
  final double precoEstimado;

  /// null quando não há prestador livre da categoria.
  final int? tempoEstimadoMin;

  const Estimativa(this.precoEstimado, this.tempoEstimadoMin);

  String get precoTexto => '≈ ${euros(precoEstimado)}';

  String get chegadaTexto => tempoEstimadoMin == null
      ? 'Sem prestadores livres agora: o pedido fica à espera.'
      : 'Chegada em cerca de $tempoEstimadoMin min.';
}

/// Localização usada enquanto a app não tem GPS (o mapa é ilustrativo).
/// Fica em Lisboa, perto dos prestadores de exemplo do populate.sql.
const double latitudeDemo = 38.7223;
const double longitudeDemo = -9.1393;

/// Ligação à API REST do ProntoFix.
///
/// Todos os pedidos HTTP da app passam por aqui: os ecrãs só chamam
/// estas funções e mostram o resultado (ou a mensagem de erro).
class Api {
  Api._();

  /// Token JWT e utilizador da sessão atual.
  static String? token;
  static Utilizador? utilizador;

  static bool get sessaoIniciada => token != null;

  static void terminarSessao() {
    token = null;
    utilizador = null;
    _categorias = null;
  }

  // -------------------------------------------------------------- base

  static Future<dynamic> _pedido(
    String metodo,
    String caminho, {
    Map<String, dynamic>? corpo,
  }) async {
    final Uri url = Uri.parse('$enderecoApi$caminho');
    final Map<String, String> cabecalhos = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    http.Response resposta;
    try {
      final String? json = corpo == null ? null : jsonEncode(corpo);
      switch (metodo) {
        case 'POST':
          resposta = await http.post(url, headers: cabecalhos, body: json);
          break;
        case 'PATCH':
          resposta = await http.patch(url, headers: cabecalhos, body: json);
          break;
        default:
          resposta = await http.get(url, headers: cabecalhos);
      }
    } on Exception {
      // Servidor desligado, endereço errado, sem rede...
      throw const ApiException(
          'Sem ligação ao servidor. Confirme que o servidor está ligado.');
    }

    dynamic dados;
    try {
      final String texto = utf8.decode(resposta.bodyBytes);
      dados = texto.isEmpty ? null : jsonDecode(texto);
    } on FormatException {
      throw ApiException(
          'Resposta inválida do servidor (${resposta.statusCode}).',
          resposta.statusCode);
    }

    if (resposta.statusCode >= 200 && resposta.statusCode < 300) {
      return dados;
    }
    if (resposta.statusCode == 401 && token != null) {
      terminarSessao();
    }
    final String mensagem = dados is Map && dados['erro'] is String
        ? dados['erro'] as String
        : 'Ocorreu um erro (${resposta.statusCode}). Tente de novo.';
    throw ApiException(mensagem, resposta.statusCode);
  }

  static Future<dynamic> _get(String caminho) => _pedido('GET', caminho)
      .timeout(const Duration(seconds: 15), onTimeout: _demorou);

  static Future<dynamic> _post(String caminho, [Map<String, dynamic>? corpo]) =>
      _pedido('POST', caminho, corpo: corpo)
          .timeout(const Duration(seconds: 15), onTimeout: _demorou);

  static Future<dynamic> _patch(String caminho,
          [Map<String, dynamic>? corpo]) =>
      _pedido('PATCH', caminho, corpo: corpo)
          .timeout(const Duration(seconds: 15), onTimeout: _demorou);

  static Never _demorou() =>
      throw const ApiException('O servidor demorou demasiado a responder.');

  static bool get _vistaPrestador => utilizador?.prestador ?? false;

  /// Pagamentos feitos nesta sessão (a API ainda não tem rota de pagamento).
  static final Set<int> _pagos = <int>{};

  static Pedido _lerPedido(dynamic json) {
    final Map<String, dynamic> mapa = json as Map<String, dynamic>;
    return Pedido.fromJson(mapa,
        vistaPrestador: _vistaPrestador,
        pago: _pagos.contains((mapa['id'] as num).toInt()));
  }

  static List<Pedido> _lerLista(dynamic json) =>
      (json as List).map(_lerPedido).toList();

  // ------------------------------------------------------------ sessão

  static void _guardarSessao(dynamic json) {
    token = json['token'] as String;
    utilizador =
        Utilizador.fromJson(json['utilizador'] as Map<String, dynamic>);
  }

  /// POST /auth/login
  static Future<Utilizador> login(String email, String palavraPasse) async {
    _guardarSessao(await _post('/auth/login', {
      'email': email,
      'password': palavraPasse,
    }));
    return utilizador!;
  }

  /// POST /auth/register — [especialidade] é obrigatória para prestadores.
  static Future<Utilizador> registar({
    required String nome,
    required String email,
    required String palavraPasse,
    required bool prestador,
    String? telefone,
    String? especialidade,
  }) async {
    _guardarSessao(await _post('/auth/register', {
      'nome': nome,
      'email': email,
      'password': palavraPasse,
      'tipo': prestador ? 'prestador' : 'cliente',
      if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
      if (especialidade != null) 'especialidade': especialidade,
    }));
    return utilizador!;
  }

  // -------------------------------------------------------- categorias

  static Map<String, int>? _categorias;

  /// GET /categorias — devolve o id da categoria com este nome.
  static Future<int> idDaCategoria(String nome) async {
    if (_categorias == null) {
      final List lista = await _get('/categorias') as List;
      _categorias = {
        for (final c in lista) c['nome'] as String: (c['id'] as num).toInt(),
      };
    }
    final int? id = _categorias![nome];
    if (id == null) throw ApiException('Categoria desconhecida: $nome');
    return id;
  }

  // ----------------------------------------------------------- cliente

  /// POST /pedidos/estimativa {categoria_id, latitude, longitude}
  static Future<Estimativa> estimativa(String categoria,
      {double latitude = latitudeDemo, double longitude = longitudeDemo}) async {
    final json = await _post('/pedidos/estimativa', {
      'categoria_id': await idDaCategoria(categoria),
      'latitude': latitude,
      'longitude': longitude,
    });
    return Estimativa(
      (json['preco_estimado'] as num).toDouble(),
      (json['tempo_estimado_min'] as num?)?.toInt(),
    );
  }

  /// POST /pedidos — o servidor atribui logo o prestador livre mais próximo.
  static Future<Pedido> criarPedido({
    required String categoria,
    required String descricao,
    required String morada,
    double latitude = latitudeDemo,
    double longitude = longitudeDemo,
  }) async {
    return _lerPedido(await _post('/pedidos', {
      'categoria_id': await idDaCategoria(categoria),
      'descricao': descricao.isEmpty ? categoria : descricao,
      'morada': morada,
      'latitude': latitude,
      'longitude': longitude,
    }));
  }

  /// GET /pedidos (cliente) ou GET /prestadores/me/pedidos (prestador).
  static Future<List<Pedido>> meusPedidos() async => _lerLista(
      await _get(_vistaPrestador ? '/prestadores/me/pedidos' : '/pedidos'));

  /// GET /pedidos/:id
  static Future<Pedido> pedido(int id) async =>
      _lerPedido(await _get('/pedidos/$id'));

  /// PATCH /pedidos/:id/cancelar
  static Future<Pedido> cancelar(int id) async =>
      _lerPedido(await _patch('/pedidos/$id/cancelar'));

  /// POST /pedidos/:id/chegada {codigo} — o código lido do QR do prestador.
  static Future<Pedido> confirmarChegada(int id, String codigo) async =>
      _lerPedido(await _post('/pedidos/$id/chegada', {'codigo': codigo.trim()}));

  /// Pagamento simulado: a API não tem rota de pagamento, por isso fica
  /// registado só nesta sessão da app.
  static Future<void> pagar(int id, String metodo) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _pagos.add(id);
  }

  /// POST /pedidos/:id/avaliacao {estrelas, comentario}
  static Future<void> avaliar(int id, int estrelas, String comentario) async {
    await _post('/pedidos/$id/avaliacao', {
      'estrelas': estrelas,
      if (comentario.isNotEmpty) 'comentario': comentario,
    });
  }

  // --------------------------------------------------------- prestador

  /// POST /pedidos/:id/aceitar — atribuido → a_caminho (devolve o codigo_qr).
  static Future<Pedido> aceitar(int id) async =>
      _lerPedido(await _post('/pedidos/$id/aceitar'));

  /// PATCH /pedidos/:id/estado {estado: 'em_curso'} — só depois de no_local.
  static Future<Pedido> iniciarServico(int id) async =>
      _lerPedido(await _patch('/pedidos/$id/estado', {'estado': 'em_curso'}));

  /// PATCH /pedidos/:id/estado {estado: 'concluido', preco_final}
  /// Sem [precoFinal], o servidor usa o preço estimado.
  static Future<Pedido> concluir(int id, [double? precoFinal]) async =>
      _lerPedido(await _patch('/pedidos/$id/estado', {
        'estado': 'concluido',
        if (precoFinal != null) 'preco_final': precoFinal,
      }));

  /// PATCH /prestadores/me/disponibilidade {disponivel}
  static Future<void> definirDisponibilidade(bool disponivel) async {
    await _patch('/prestadores/me/disponibilidade', {'disponivel': disponivel});
  }

  /// PATCH /prestadores/me/localizacao {latitude, longitude}
  static Future<void> atualizarLocalizacao(
      {double latitude = latitudeDemo, double longitude = longitudeDemo}) async {
    await _patch('/prestadores/me/localizacao', {
      'latitude': latitude,
      'longitude': longitude,
    });
  }
}
