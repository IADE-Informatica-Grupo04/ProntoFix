import 'prestador.dart';

/// Estados de um pedido, pela ordem em que acontecem (cancelado é um desvio).
enum EstadoPedido {
  procurar,
  atribuido,
  aCaminho,
  noLocal,
  concluido,
  cancelado,
}

/// Os 4 passos mostrados no indicador de estado do acompanhamento.
const List<EstadoPedido> passosEstado = [
  EstadoPedido.atribuido,
  EstadoPedido.aCaminho,
  EstadoPedido.noLocal,
  EstadoPedido.concluido,
];

extension EstadoPedidoTexto on EstadoPedido {
  String get rotulo {
    switch (this) {
      case EstadoPedido.procurar:
        return 'A procurar prestador';
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
}

/// Converte o estado que vem do servidor no estado da app.
///   criado -> procurar · atribuido · a_caminho -> aCaminho
///   no_local / em_curso -> noLocal · concluido · cancelado
EstadoPedido estadoDoServidor(String? estado) {
  switch (estado) {
    case 'atribuido':
      return EstadoPedido.atribuido;
    case 'a_caminho':
      return EstadoPedido.aCaminho;
    case 'no_local':
    case 'em_curso':
      return EstadoPedido.noLocal;
    case 'concluido':
      return EstadoPedido.concluido;
    case 'cancelado':
      return EstadoPedido.cancelado;
    default: // 'criado'
      return EstadoPedido.procurar;
  }
}

/// Pedido de reparação.
/// Os 7 primeiros campos são os do protótipo; os restantes vêm do servidor
/// (objeto Pedido da documentação da API, em snake_case).
class Pedido {
  final int id;
  final String titulo;
  final String categoria;
  final EstadoPedido estado;

  /// Nome do prestador (visão do cliente) ou do cliente (visão do prestador).
  final String contraparte;
  final String data;
  final String preco;

  // ---- dados do servidor ----
  /// Estado tal como vem da API ('criado', 'atribuido', ..., 'em_curso').
  final String estadoApi;
  final int? categoriaId;
  final String descricao;
  final String urgencia;
  final String morada;
  final double? latitude;
  final double? longitude;
  final double? precoEstimado;
  final int? tempoEstimadoMin;
  final double? precoFinal;

  /// Só vem nas respostas ao prestador (é ele que mostra o QR).
  final String? codigoQr;

  /// O pagamento não tem rota na API: fica registado só na app.
  final bool pago;
  final int? estrelas;
  final String clienteNome;
  final String? clienteTelefone;
  final Prestador? prestador;
  final double? prestadorLatitude;
  final double? prestadorLongitude;

  const Pedido({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.estado,
    required this.contraparte,
    required this.data,
    required this.preco,
    this.estadoApi = '',
    this.categoriaId,
    this.descricao = '',
    this.urgencia = 'Agora',
    this.morada = '',
    this.latitude,
    this.longitude,
    this.precoEstimado,
    this.tempoEstimadoMin,
    this.precoFinal,
    this.codigoQr,
    this.pago = false,
    this.estrelas,
    this.clienteNome = '',
    this.clienteTelefone,
    this.prestador,
    this.prestadorLatitude,
    this.prestadorLongitude,
  });

  bool get ativo =>
      estado != EstadoPedido.concluido && estado != EstadoPedido.cancelado;

  /// Concluído mas ainda sem pagamento nem avaliação (cliente).
  bool get porPagar =>
      estado == EstadoPedido.concluido && !pago && estrelas == null;

  /// O prestador já confirmou o início do trabalho (estado em_curso).
  bool get emCurso => estadoApi == 'em_curso';

  /// Valor a pagar: o preço final, ou a estimativa se ainda não houver.
  double? get total => precoFinal ?? precoEstimado;

  /// Lê um pedido do JSON da API. [vistaPrestador] decide quem é a
  /// "contraparte" mostrada nos cartões (o cliente ou o prestador).
  /// [pago] vem do registo local de pagamentos.
  factory Pedido.fromJson(Map<String, dynamic> json,
      {bool vistaPrestador = false, bool pago = false}) {
    final String categoria = (json['categoria'] ?? '') as String;
    final EstadoPedido estado = estadoDoServidor(json['estado'] as String?);
    final double? precoEstimado = _numero(json['preco_estimado']);
    final double? precoFinal = _numero(json['preco_final']);
    final int? tempo = (json['tempo_estimado_min'] as num?)?.toInt();
    final String descricao = (json['descricao'] ?? '') as String;

    final String? nomePrestador = json['prestador_nome'] as String?;
    final Prestador? prestador = nomePrestador == null
        ? null
        : Prestador(
            id: (json['tecnico_id'] as num?)?.toInt(),
            nome: nomePrestador,
            profissao: profissaoDe(categoria),
            avaliacao: _numero(json['prestador_avaliacao']) ?? 0,
            numAvaliacoes: 0,
            servicos: 0,
            etaMinutos: tempo ?? 15,
            telefone: json['prestador_telefone'] as String?,
          );

    String preco;
    if (precoFinal != null) {
      preco = euros(precoFinal);
    } else if (estado == EstadoPedido.cancelado) {
      preco = euros(0);
    } else if (precoEstimado != null) {
      preco = '≈ ${euros(precoEstimado)}';
    } else {
      preco = '—';
    }

    return Pedido(
      id: (json['id'] as num).toInt(),
      titulo: _titulo(descricao, categoria),
      categoria: categoria,
      estado: estado,
      contraparte: vistaPrestador
          ? (json['cliente_nome'] ?? 'Cliente') as String
          : (nomePrestador ?? 'A procurar prestador'),
      data: dataCurta(DateTime.tryParse('${json['criado_em'] ?? ''}')),
      preco: preco,
      estadoApi: (json['estado'] ?? '') as String,
      categoriaId: (json['categoria_id'] as num?)?.toInt(),
      descricao: descricao,
      morada: (json['morada'] ?? '') as String,
      latitude: _numero(json['latitude']),
      longitude: _numero(json['longitude']),
      precoEstimado: precoEstimado,
      tempoEstimadoMin: tempo,
      precoFinal: precoFinal,
      codigoQr: json['codigo_qr'] as String?,
      pago: pago,
      estrelas: (json['estrelas'] as num?)?.toInt(),
      clienteNome: (json['cliente_nome'] ?? '') as String,
      clienteTelefone: json['cliente_telefone'] as String?,
      prestador: prestador,
      prestadorLatitude: _numero(json['prestador_latitude']),
      prestadorLongitude: _numero(json['prestador_longitude']),
    );
  }
}

/// "Canalização" -> "Canalizador", para o cartão do prestador.
String profissaoDe(String categoria) {
  switch (categoria) {
    case 'Canalização':
      return 'Canalizador';
    case 'Eletricidade':
      return 'Eletricista';
    case 'Serralharia':
      return 'Serralheiro';
    default:
      return categoria.isEmpty ? 'Prestador' : categoria;
  }
}

/// Primeira frase da descrição, curta, para o título do cartão.
String _titulo(String descricao, String categoria) {
  final String frase = descricao.split('.').first.trim();
  if (frase.isEmpty) return categoria;
  return frase.length > 40 ? '${frase.substring(0, 38)}…' : frase;
}

/// O MySQL pode devolver números como texto ("42.00"); aceitamos os dois.
double? _numero(dynamic valor) {
  if (valor == null) return null;
  if (valor is num) return valor.toDouble();
  return double.tryParse(valor.toString());
}

/// 42 -> "42,00 €"
String euros(double valor) =>
    '${valor.toStringAsFixed(2).replaceAll('.', ',')} €';

/// "Hoje, 11:40", "Ontem, 19:15" ou "18 out, 08:30".
String dataCurta(DateTime? data) {
  if (data == null) return '';
  final DateTime d = data.toLocal();
  final String hora =
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final DateTime hoje = DateTime.now();
  final DateTime dia = DateTime(d.year, d.month, d.day);
  final int diferenca =
      DateTime(hoje.year, hoje.month, hoje.day).difference(dia).inDays;
  if (diferenca == 0) return 'Hoje, $hora';
  if (diferenca == 1) return 'Ontem, $hora';
  const List<String> meses = [
    'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
    'jul', 'ago', 'set', 'out', 'nov', 'dez',
  ];
  return '${d.day.toString().padLeft(2, '0')} ${meses[d.month - 1]}, $hora';
}
