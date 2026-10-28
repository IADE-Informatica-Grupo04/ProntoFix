import 'package:flutter/material.dart';

import 'ecras/login_page.dart';
import 'ecras/registo_page.dart';
import 'ecras/splash_page.dart';
import 'tema/cores.dart';

void main() {
  runApp(const ProntoFixApp());
}

class ProntoFixApp extends StatelessWidget {
  const ProntoFixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProntoFix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Cores.azul),
        scaffoldBackgroundColor: Cores.fundo,
        useMaterial3: true,
      ),
      // Rotas nomeadas (aula de navegação, exemplo 3).
      // As áreas do cliente e do prestador abrem-se com
      // MaterialPageRoute, porque recebem dados pelo construtor.
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/registo': (context) => const RegistoPage(),
      },
    );
  }
}
