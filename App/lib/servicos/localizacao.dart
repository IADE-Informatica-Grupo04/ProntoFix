import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../dados/dados_ficticios.dart';

// Resultado de pedir a localização ao telemóvel.
class Localizacao {
  final String morada;
  final String detalhe;
  final double lat;
  final double lng;
  final bool aproximada; // true quando não foi possível usar o GPS

  const Localizacao({
    required this.morada,
    required this.detalhe,
    required this.lat,
    required this.lng,
    this.aproximada = false,
  });
}

// Obtém a posição atual pelo GPS e converte-a numa morada (RF03).
// Se o GPS estiver desligado ou sem permissão, devolve a morada fictícia
// e o ecrã pede ao cliente para a confirmar.
Future<Localizacao> obterLocalizacao() async {
  const Localizacao porOmissao = Localizacao(
    morada: moradaPorOmissao,
    detalhe: moradaDetalhePorOmissao,
    lat: latPorOmissao,
    lng: lngPorOmissao,
    aproximada: true,
  );

  try {
    if (!await Geolocator.isLocationServiceEnabled()) return porOmissao;

    LocationPermission permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied ||
        permissao == LocationPermission.deniedForever) {
      return porOmissao;
    }

    final Position posicao = await Geolocator.getCurrentPosition();

    // Coordenadas -> morada (rua, número, localidade, código postal)
    String morada = 'Localização atual';
    String detalhe =
        '${posicao.latitude.toStringAsFixed(4)}, ${posicao.longitude.toStringAsFixed(4)}';
    try {
      final List<Placemark> locais = await placemarkFromCoordinates(
        posicao.latitude,
        posicao.longitude,
      );
      if (locais.isNotEmpty) {
        final Placemark l = locais.first;
        morada = '${l.street ?? ''}, ${l.locality ?? ''}';
        detalhe = 'Cód. ${l.postalCode ?? '—'}';
      }
    } catch (_) {
      // sem conversão para morada: ficam as coordenadas
    }

    return Localizacao(
      morada: morada,
      detalhe: detalhe,
      lat: posicao.latitude,
      lng: posicao.longitude,
    );
  } catch (_) {
    return porOmissao;
  }
}
