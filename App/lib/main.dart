import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'theme/app_theme.dart';

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
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
