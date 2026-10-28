import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../tema/cores.dart';

// Mapa real (OpenStreetMap) com a morada do cliente e, quando existe,
// a posição do prestador. As etiquetas ("ETA 12 min"...) ficam por cima,
// como no mockup.
class Mapa extends StatelessWidget {
  final double lat;
  final double lng;
  final double? prestadorLat;
  final double? prestadorLng;
  final List<Widget> etiquetas;
  final double altura;

  const Mapa({
    super.key,
    required this.lat,
    required this.lng,
    this.prestadorLat,
    this.prestadorLng,
    this.etiquetas = const [],
    this.altura = 210,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng morada = LatLng(lat, lng);
    final bool temPrestador = prestadorLat != null && prestadorLng != null;
    final LatLng? prestador =
        temPrestador ? LatLng(prestadorLat!, prestadorLng!) : null;

    // Centro do mapa: entre o cliente e o prestador (ou só o cliente).
    final LatLng centro = prestador == null
        ? morada
        : LatLng(
            (lat + prestador.latitude) / 2,
            (lng + prestador.longitude) / 2,
          );

    return Container(
      height: altura,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Cores.linha),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            // A key muda quando o prestador se mexe, para o mapa voltar a
            // centrar-se nas novas posições.
            key: ValueKey('${centro.latitude}${centro.longitude}'),
            options: MapOptions(
              initialCenter: centro,
              initialZoom: prestador == null ? 16 : 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'pt.iade.prontofix',
              ),
              if (prestador != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [prestador, morada],
                      strokeWidth: 5,
                      color: Cores.azul,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: morada,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Cores.vermelho,
                      size: 40,
                    ),
                  ),
                  if (prestador != null)
                    Marker(
                      point: prestador,
                      width: 36,
                      height: 36,
                      child: const CircleAvatar(
                        backgroundColor: Cores.laranja,
                        child: Icon(Icons.build, color: Colors.white, size: 18),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 14,
            top: 14,
            right: 14,
            child: Wrap(spacing: 8, runSpacing: 8, children: etiquetas),
          ),
          const Positioned(
            right: 8,
            bottom: 6,
            child: Text(
              '© OpenStreetMap',
              style: TextStyle(fontSize: 9, color: Cores.cinza),
            ),
          ),
        ],
      ),
    );
  }
}
