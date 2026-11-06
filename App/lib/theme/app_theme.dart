import 'package:flutter/material.dart';

/// Paleta do Style Guide (secção 3). O azul é a cor de ação, o ciano é o
/// realce da marca. As variantes "Text" só se usam em texto (contraste AA).
class PFColors {
  PFColors._();

  // Marca
  static const Color primary = Color(0xFF2663F2);
  static const Color primaryHover = Color(0xFF1F57DB);
  static const Color primaryPressed = Color(0xFF1B4DD0);
  static const Color accent = Color(0xFF21D1EB);
  static const Color tint = Color(0xFFE8EFFF);
  static const Color navy = Color(0xFF0B1530);

  // Semântica
  static const Color success = Color(0xFF22B573);
  static const Color successText = Color(0xFF12804F);
  static const Color successBg = Color(0xFFE6F6EE);
  static const Color warning = Color(0xFFF59C36);
  static const Color warningText = Color(0xFFA85A00);
  static const Color warningBg = Color(0xFFFFF1DE);
  static const Color error = Color(0xFFC62F3B);
  static const Color errorBg = Color(0xFFFCE8EA);

  // Neutros e estados
  static const Color text = Color(0xFF1F2633);
  static const Color textSecondary = Color(0xFF5B6577);
  static const Color background = Color(0xFFF4F7FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE4EAF3);
  static const Color disabled = Color(0xFFC9D2E0);
  static const Color muted = Color(0xFF7D8799); // só ícones decorativos e bordas

  // Apoio (fundos claros de ilustrações)
  static const Color accentBg = Color(0xFFE0F8FC);
  static const Color mapa = Color(0xFFE3ECFB);
}

/// Escala de espaçamento (base de 8 px) e margem lateral de 20 px.
class PFSpacing {
  PFSpacing._();

  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Margem lateral dos ecrãs.
  static const double margem = 20;

  /// Alvo de toque mínimo (WCAG / RU05).
  static const double alvo = 44;
}

/// Raios: chip 8 px, botão 14 px, cartão 20 px.
class PFRadius {
  PFRadius._();

  static const double chip = 8;
  static const double botao = 14;
  static const double cartao = 20;
}

/// Escala tipográfica do Style Guide (secção 4): Inter, corpo a 16 px.
class PFText {
  PFText._();

  static const String _familia = 'Inter';

  /// H1 28/34 Bold: valores de destaque (preço, chegada).
  static const TextStyle h1 = TextStyle(
    fontFamily: _familia,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    color: PFColors.navy,
  );

  /// H2 24/30 Bold: título de ecrã.
  static const TextStyle h2 = TextStyle(
    fontFamily: _familia,
    fontSize: 24,
    height: 30 / 24,
    fontWeight: FontWeight.w700,
    color: PFColors.navy,
  );

  /// H3 20/26 Semibold: secções.
  static const TextStyle h3 = TextStyle(
    fontFamily: _familia,
    fontSize: 20,
    height: 26 / 20,
    fontWeight: FontWeight.w600,
    color: PFColors.navy,
  );

  /// H4 18/24 Semibold: títulos de cartão.
  static const TextStyle h4 = TextStyle(
    fontFamily: _familia,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    color: PFColors.navy,
  );

  /// Corpo 16/24 Regular: texto corrente.
  static const TextStyle corpo = TextStyle(
    fontFamily: _familia,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    color: PFColors.text,
  );

  /// Corpo forte 16/24 Semibold: etiquetas e valores.
  static const TextStyle corpoForte = TextStyle(
    fontFamily: _familia,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: PFColors.text,
  );

  /// Secundário 14/20 Medium: apoio e dados secundários (mínimo para informação).
  static const TextStyle secundario = TextStyle(
    fontFamily: _familia,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: PFColors.textSecondary,
  );

  /// Botão 16/20 Bold.
  static const TextStyle botao = TextStyle(
    fontFamily: _familia,
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    color: PFColors.surface,
  );

  /// Legenda 12/16 Medium: só apoio não essencial.
  static const TextStyle legenda = TextStyle(
    fontFamily: _familia,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: PFColors.textSecondary,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final esquema = ColorScheme.fromSeed(
      seedColor: PFColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: PFColors.primary,
      error: PFColors.error,
      surface: PFColors.surface,
      onSurface: PFColors.text,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: esquema,
      scaffoldBackgroundColor: PFColors.background,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: PFColors.primary,
      ),
    );
  }
}
