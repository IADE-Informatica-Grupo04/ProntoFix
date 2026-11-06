import 'package:flutter/material.dart';

import 'models/dados_pedido.dart';
import 'screens/acompanhamento_screen.dart';
import 'screens/ajuda_screen.dart';
import 'screens/avaliacao_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/localizacao_orcamento_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/novo_pedido_screen.dart';
import 'screens/pagamento_screen.dart';
import 'screens/registo_screen.dart';
import 'screens/splash_screen.dart';

/// Nomes das rotas e mapa de rotas da aplicação.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String registo = '/registo';

  /// Estrutura com barra inferior (Início, Pedidos, Histórico, Perfil).
  /// Argumento opcional: bool (true = prestador).
  static const String home = '/home';

  // Fluxo do pedido (sem barra inferior, RU03).
  /// Argumento opcional: String com o nome da categoria.
  static const String novoPedido = '/novo-pedido';

  /// Argumento: DadosPedido.
  static const String localizacao = '/localizacao';

  /// Argumento: int com o id do pedido no servidor.
  static const String acompanhamento = '/acompanhamento';

  /// Argumento opcional: String com o nome da conversa.
  static const String chat = '/chat';
  /// Argumento: int com o id do pedido (pagamento e avaliação).
  static const String pagamento = '/pagamento';
  static const String avaliacao = '/avaliacao';
  static const String ajuda = '/ajuda';

  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    registo: (context) => const RegistoScreen(),
    home: (context) => MainShell(
          prestador:
              (ModalRoute.of(context)?.settings.arguments as bool?) ?? false,
        ),
    novoPedido: (context) => NovoPedidoScreen(
          categoriaInicial:
              ModalRoute.of(context)?.settings.arguments as String?,
        ),
    localizacao: (context) => LocalizacaoOrcamentoScreen(
          dados: (ModalRoute.of(context)?.settings.arguments as DadosPedido?) ??
              const DadosPedido(
                categoria: 'Canalização',
                descricao: 'Fuga na cozinha',
                urgencia: 'Agora',
              ),
        ),
    acompanhamento: (context) => AcompanhamentoScreen(
          pedidoId: ModalRoute.of(context)?.settings.arguments as int?,
        ),
    chat: (context) => ChatScreen(
          nome: (ModalRoute.of(context)?.settings.arguments as String?) ??
              'Conversa',
        ),
    pagamento: (context) => PagamentoScreen(
          pedidoId: ModalRoute.of(context)?.settings.arguments as int?,
        ),
    avaliacao: (context) => AvaliacaoScreen(
          pedidoId: ModalRoute.of(context)?.settings.arguments as int?,
        ),
    ajuda: (context) => const AjudaScreen(),
  };
}
