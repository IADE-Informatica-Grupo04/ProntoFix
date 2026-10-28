import 'package:flutter/material.dart';

import '../dados/dados_ficticios.dart';
import '../servicos/api.dart';
import '../widgets/componentes.dart';
import 'cliente/cliente_principal_page.dart';
import 'login_page.dart';
import 'prestador/prestador_principal_page.dart';

// Criar conta — formulário completo como no Exemplo 4 da aula:
// TextFormField, DropdownButtonFormField, SwitchListTile e CheckboxListTile.
class RegistoPage extends StatefulWidget {
  const RegistoPage({super.key});

  @override
  State<RegistoPage> createState() => _RegistoPageState();
}

class _RegistoPageState extends State<RegistoPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nomeController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telefoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String tipo = 'Cliente';
  String? categoria; // só para prestadores
  bool receberNotificacoes = true;
  bool aceitarTermos = false;

  Future<void> criarConta() async {
    final bool camposValidos = formKey.currentState?.validate() ?? false;

    if (!aceitarTermos) {
      mostrarMensagem(context, 'Aceita os termos e o RGPD para continuar.');
      return;
    }
    if (!camposValidos) return;

    // POST /auth/register
    final bool ok = await Api.registar({
      'nome': nomeController.text.trim(),
      'email': emailController.text.trim(),
      'telefone': telefoneController.text.trim(),
      'password': passwordController.text,
      'tipo': tipo.toLowerCase(),
      'categoria': categoria,
      'notificacoes': receberNotificacoes,
    });
    if (!mounted) return;
    if (!ok) {
      mostrarMensagem(context, 'Não foi possível criar a conta.');
      return;
    }

    final String nome = nomeController.text.trim().split(' ').first;

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

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    telefoneController.dispose();
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
                titulo: 'Criar conta',
                subtitulo: 'Demora menos de 30 segundos.',
                mostrarVoltar: true,
              ),
              const SizedBox(height: 20),
              Cartao(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TituloSecao('Tipo de conta'),
                    GrupoOpcoes(
                      opcoes: const ['Cliente', 'Prestador'],
                      selecionada: tipo,
                      onEscolher: (opcao) {
                        setState(() {
                          tipo = opcao;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Cartao(
                child: Column(
                  children: [
                    TextFormField(
                      controller: nomeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: campo('Nome e apelido'),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'Introduz um nome válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: campo('Email'),
                      validator: (value) {
                        final String email = value?.trim() ?? '';
                        if (!email.contains('@') || !email.contains('.')) {
                          return 'Introduz um email válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telefoneController,
                      keyboardType: TextInputType.phone,
                      decoration: campo('Telemóvel'),
                      validator: (value) {
                        final String numero =
                            (value ?? '').replaceAll(' ', '');
                        if (numero.length != 9 ||
                            int.tryParse(numero) == null) {
                          return 'O número tem 9 dígitos.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: campo('Palavra-passe (mín. 6 caracteres)'),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Usa pelo menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),

                    // Só os prestadores escolhem o serviço que prestam
                    if (tipo == 'Prestador') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: campo('Serviço que prestas'),
                        items: [
                          for (final c in categorias)
                            DropdownMenuItem(
                              value: c.nome,
                              child: Text(c.nome),
                            ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            categoria = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Escolhe uma categoria.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Receber notificações'),
                value: receberNotificacoes,
                onChanged: (value) {
                  setState(() {
                    receberNotificacoes = value;
                  });
                },
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Aceito os termos e o uso da localização durante os '
                  'pedidos (RGPD).',
                  style: TextStyle(fontSize: 14),
                ),
                value: aceitarTermos,
                onChanged: (value) {
                  setState(() {
                    aceitarTermos = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              BotaoPrincipal(texto: 'Criar conta', onPressed: criarConta),
            ],
          ),
        ),
      ),
    );
  }
}
