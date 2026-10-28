import '../dados/dados_ficticios.dart';
import 'categoria.dart';

// Etapas de um pedido, pela ordem em que acontecem.
// "cancelado" fica no fim porque pode acontecer antes do prestador sair.
enum EstadoPedido { aProcura, atribuido, aCaminho, noLocal, concluido, cancelado }

// Texto que aparece no ecrã para cada estado.
String textoDoEstado(EstadoPedido estado) {
  switch (estado) {
    case EstadoPedido.aProcura:
      return 'À procura';
    case EstadoPedido.atribuido:
      return 'Atribuído';
    case EstadoPedido.aCaminho:
      return 'A caminho';
    case EstadoPedido.noLocal:
      return 'No local';
    case EstadoPedido.concluido:
      return 'Concluído';
    case EstadoPedido.cancelado:
      return 'Cancelado';
  }
}

// Nome do estado como o servidor o envia ("a_caminho"...).
const List<String> estadosApi = [
  'criado',
  'atribuido',
  'a_caminho',
  'no_local',
  'concluido',
  'cancelado',
];

// Um pedido de reparação.
// Os campos que mudam durante o serviço (estado, eta, total...) não são
// final: o ecrã altera-os dentro de setState().
class Pedido {
  final int id;
  final Categoria categoria;
  final String descricao;
  final String urgencia; // "Normal", "Hoje" ou "Agora"
  final String morada;
  final String moradaDetalhe;
  final double lat; // coordenadas da morada do cliente
  final double lng;
  final String? fotoPath; // fotografia da avaria (caminho no telemóvel)
  final int precoMin;
  final int precoMax;
  final int etaMin;
  final int etaMax;
  final DateTime data;
  final String cliente;

  EstadoPedido estado;
  String? prestador; // nome do prestador, quando já há um
  String? prestadorTelefone;
  double? prestadorLat; // posição do prestador durante a viagem
  double? prestadorLng;
  bool prestadorFavorito;
  int eta; // minutos que faltam até o prestador chegar
  double? maoDeObra; // valores finais, definidos pelo prestador
  double? material;
  String? resumo;
  String? metodoPagamento;
  int estrelas; // 0 = ainda não avaliado
  String comentario;

  Pedido({
    required this.id,
    required this.categoria,
    required this.descricao,
    required this.urgencia,
    required this.morada,
    required this.moradaDetalhe,
    required this.lat,
    required this.lng,
    required this.precoMin,
    required this.precoMax,
    required this.etaMin,
    required this.etaMax,
    required this.data,
    this.cliente = 'Cliente',
    this.fotoPath,
    this.estado = EstadoPedido.aProcura,
    this.prestador,
    this.prestadorTelefone,
    this.prestadorLat,
    this.prestadorLng,
    this.prestadorFavorito = false,
    this.eta = 0,
    this.maoDeObra,
    this.material,
    this.resumo,
    this.metodoPagamento,
    this.estrelas = 0,
    this.comentario = '',
  });

  // Total = mão de obra + material (null enquanto não há valor final).
  double? get total {
    if (maoDeObra == null) return null;
    return maoDeObra! + (material ?? 0);
  }

  // Código do QR de chegada: só serve para este pedido.
  String get codigoQr => 'PFX-$id';

  bool get emCurso =>
      estado != EstadoPedido.concluido && estado != EstadoPedido.cancelado;

  // Pode cancelar-se sem custos antes de o prestador sair.
  bool get podeCancelar =>
      estado == EstadoPedido.aProcura || estado == EstadoPedido.atribuido;

  // "Fuga na cozinha. O cano..." -> "Fuga na cozinha"
  String get titulo {
    final String primeiraFrase = descricao.split('.').first.trim();
    if (primeiraFrase.isEmpty) return categoria.nome;
    if (primeiraFrase.length > 28) {
      return '${primeiraFrase.substring(0, 26)}…';
    }
    return primeiraFrase;
  }

  // ---------------- JSON (para a API REST) ----------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoria': categoria.nome,
      'descricao': descricao,
      'urgencia': urgencia,
      'morada': morada,
      'morada_detalhe': moradaDetalhe,
      'lat': lat,
      'lng': lng,
      'estado': estadosApi[estado.index],
      'mao_de_obra': maoDeObra,
      'material': material,
      'resumo_servico': resumo,
      'metodo_pagamento': metodoPagamento,
      'estrelas': estrelas,
      'comentario': comentario,
    };
  }

  factory Pedido.fromJson(Map<String, dynamic> json) {
    final int indiceEstado = estadosApi.indexOf(json['estado'] ?? 'criado');
    return Pedido(
      id: json['id'],
      categoria: categoriaPorNome(json['categoria'] ?? ''),
      descricao: json['descricao'] ?? '',
      urgencia: json['urgencia'] ?? 'Agora',
      morada: json['morada'] ?? '',
      moradaDetalhe: json['morada_detalhe'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      precoMin: json['preco_min'] ?? 0,
      precoMax: json['preco_max'] ?? 0,
      etaMin: json['eta_min'] ?? 0,
      etaMax: json['eta_max'] ?? 0,
      data: DateTime.tryParse(json['criado_em'] ?? '') ?? DateTime.now(),
      cliente: json['cliente_nome'] ?? 'Cliente',
      estado: EstadoPedido.values[indiceEstado < 0 ? 0 : indiceEstado],
      prestador: json['prestador_nome'],
      prestadorTelefone: json['prestador_telefone'],
      prestadorLat: (json['prestador_lat'] as num?)?.toDouble(),
      prestadorLng: (json['prestador_lng'] as num?)?.toDouble(),
      eta: json['eta_atual'] ?? 0,
      maoDeObra: (json['mao_de_obra'] as num?)?.toDouble(),
      material: (json['material'] as num?)?.toDouble(),
      resumo: json['resumo_servico'],
      metodoPagamento: json['metodo_pagamento'],
      estrelas: json['estrelas'] ?? 0,
      comentario: json['comentario'] ?? '',
    );
  }
}
