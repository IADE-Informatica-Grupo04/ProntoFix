import 'package:flutter/material.dart';

import '../servicos/api.dart';
import '../tema/cores.dart';
import '../widgets/componentes.dart';
import 'cliente/cliente_principal_page.dart';
import 'prestador/prestador_principal_page.dart';

// 02 Login — Form + TextFormField + validação (aula de formulários).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String tipo = 'Cliente'; // "Cliente" ou "Prestador"
  bool esconderPassword = true;

  Future<void> entrar() async {
    final bool valido = formKey.currentState?.validate() ?? false;
    if (!valido) return;

    final String email = emailController.text.trim();

    // POST /auth/login (com dados fictícios aceita sempre).
    final bool ok = await Api.login(email, passwordController.text, tipo);
    if (!mounted) return;
    if (!ok) {
      mostrarMensagem(context, 'Email ou palavra-passe incorretos.');
      return;
    }

    // Sem servidor ainda: usamos a parte do email antes do @ como nome.
    final String nome = nomeDoEmail(email);

    // pushReplacement: a página de login sai da pilha, para o botão
    // "voltar" do telemóvel não regressar ao login.
    if (tipo == 'Cliente') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ClientePrincipalPage(nome: nome),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PrestadorPrincipalPage(nome: nome),
        ),
      );
    }
  }

  String nomeDoEmail(String email) {
    final String parte = email.split('@').first.split('.').first;
    if (parte.isEmpty) return 'Utilizador';
    return parte[0].toUpperCase() + parte.substring(1);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Cabecalho(
                titulo: 'Entrar na tua conta',
                subtitulo: 'Cliente ou prestador, tudo num só login.',
              ),
              const SizedBox(height: 20),

              // Cartão com os círculos e a escolha do tipo de conta
              Cartao(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 90,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 4,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Cores.azulClaro,
                            ),
                          ),
                          Positioned(
                            left: 66,
                            top: 14,
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Cores.cianoClaro,
                            ),
                          ),
                          Positioned(
                            left: 150,
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: Cores.laranjaClaro,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GrupoOpcoes(
                          opcoes: const ['Cliente', 'Prestador'],
                          selecionada: tipo,
                          onEscolher: (opcao) {
                            setState(() {
                              tipo = opcao;
                            });
                          },
                        ),
                        const Etiqueta(
                          texto: 'Sessão segura',
                          cor: Cores.verde,
                          corFundo: Cores.verdeClaro,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Campos do formulário
              Cartao(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email', style: TextStyle(color: Cores.cinza)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: campo('teu.email@dominio.com'),
                      validator: (value) {
                        final String email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Introduz o email.';
                        }
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Introduz um email válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Palavra-passe',
                      style: TextStyle(color: Cores.cinza),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: passwordController,
                      obscureText: esconderPassword,
                      decoration: campo('••••••••••').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              esconderPassword = !esconderPassword;
                            });
                          },
                          icon: Icon(
                            esconderPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'A palavra-passe tem pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              BotaoPrincipal(texto: 'Entrar', onPressed: entrar),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/registo');
                  },
                  child: const Text(
                    'Criar nova conta',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Cores.azul,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Estilo dos campos de texto (usado no login e no registo).
InputDecoration campo(String dica) {
  return InputDecoration(
    hintText: dica,
    hintStyle: const TextStyle(color: Cores.cinza),
    filled: true,
    fillColor: Cores.fundo,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Cores.linha),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Cores.linha),
    ),
  );
}
