import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/componentes.dart';

// Abre a app de chamadas do telemóvel.
Future<void> ligar(BuildContext context, String telefone) async {
  final bool abriu = await launchUrl(Uri(scheme: 'tel', path: telefone));
  if (!abriu && context.mounted) {
    mostrarMensagem(context, 'Não foi possível ligar para $telefone.');
  }
}

// Abre a app de mensagens (SMS) com o número já preenchido.
Future<void> enviarMensagem(BuildContext context, String telefone) async {
  final bool abriu = await launchUrl(Uri(scheme: 'sms', path: telefone));
  if (!abriu && context.mounted) {
    mostrarMensagem(context, 'Não foi possível abrir as mensagens.');
  }
}

// Abre o Google Maps com a rota até à morada (prestador).
Future<void> abrirRota(BuildContext context, double lat, double lng) async {
  final Uri endereco = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
  );
  final bool abriu =
      await launchUrl(endereco, mode: LaunchMode.externalApplication);
  if (!abriu && context.mounted) {
    mostrarMensagem(context, 'Não foi possível abrir a rota.');
  }
}
