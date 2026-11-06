import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_controlos.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_logo.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_top_bar.dart';

/// Login simulado. O perfil escolhido decide o ecrã inicial (cliente/prestador).
/// Validação em linha, botão desativado até haver dados (RU07 e RU08).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _palavraPasse = TextEditingController();
  String _perfil = 'Cliente';
  bool _emailTocado = false;
  bool _passeTocada = false;
  bool _tentou = false;
  bool _aEntrar = false;

  @override
  void dispose() {
    _email.dispose();
    _palavraPasse.dispose();
    super.dispose();
  }

  bool get _emailValido =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
  bool get _passeValida => _palavraPasse.text.length >= 6;

  String? get _erroEmail {
    if (!(_emailTocado || _tentou) || _emailValido) return null;
    return _email.text.trim().isEmpty
        ? 'Indique o seu email.'
        : 'Indique um email válido, por exemplo nome@email.pt.';
  }

  String? get _erroPasse {
    if (!(_passeTocada || _tentou) || _passeValida) return null;
    return _palavraPasse.text.isEmpty
        ? 'Indique a palavra-passe.'
        : 'A palavra-passe tem pelo menos 6 caracteres.';
  }

  bool get _preenchido =>
      _email.text.trim().isNotEmpty && _palavraPasse.text.isNotEmpty;

  Future<void> _entrar() async {
    setState(() => _tentou = true);
    if (!_emailValido || !_passeValida) {
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.erro,
        'Não conseguimos iniciar sessão. Verifique os dados.',
      );
      return;
    }

    // POST /auth/login
    setState(() => _aEntrar = true);
    try {
      final utilizador =
          await Api.login(_email.text.trim(), _palavraPasse.text);
      if (!mounted) return;
      // O tipo de conta vem do servidor; avisa se não bate com o escolhido.
      if (utilizador.prestador != (_perfil == 'Prestador')) {
        PFFeedback.mostrar(
          context,
          PFTipoFeedback.info,
          utilizador.prestador
              ? 'Esta conta é de prestador.'
              : 'Esta conta é de cliente.',
        );
      }
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (rota) => false,
        arguments: utilizador.prestador,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _aEntrar = false);
      PFFeedback.mostrar(context, PFTipoFeedback.erro, e.mensagem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PFTopBar(
              titulo: 'Bem-vindo de volta',
              subtitulo: 'Cliente ou prestador, tudo num só login.',
              onVoltar: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  PFSpacing.margem,
                  PFSpacing.s,
                  PFSpacing.margem,
                  PFSpacing.l,
                ),
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: PFLogo(tamanho: 36),
                  ),
                  const SizedBox(height: PFSpacing.xxl),
                  PFSegmentado(
                    opcoes: const ['Cliente', 'Prestador'],
                    selecionado: _perfil,
                    onChanged: (v) => setState(() => _perfil = v),
                  ),
                  const SizedBox(height: PFSpacing.xl),
                  Focus(
                    onFocusChange: (focado) {
                      if (!focado) setState(() => _emailTocado = true);
                    },
                    child: PFTextField(
                      etiqueta: 'Email',
                      dica: 'nome@email.pt',
                      controlador: _email,
                      iconePrefixo: PFIcons.mail,
                      teclado: TextInputType.emailAddress,
                      erro: _erroEmail,
                      sucesso: _emailTocado && _emailValido,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: PFSpacing.l),
                  Focus(
                    onFocusChange: (focado) {
                      if (!focado) setState(() => _passeTocada = true);
                    },
                    child: PFTextField(
                      etiqueta: 'Palavra-passe',
                      dica: 'Pelo menos 6 caracteres',
                      controlador: _palavraPasse,
                      iconePrefixo: PFIcons.cadeado,
                      ocultar: true,
                      erro: _erroPasse,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(height: PFSpacing.s),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(PFSpacing.alvo, PFSpacing.alvo),
                      ),
                      onPressed: () => PFFeedback.mostrar(
                        context,
                        PFTipoFeedback.info,
                        'Enviámos um email para repor a palavra-passe (simulado).',
                      ),
                      child: Text(
                        'Esqueceu-se da palavra-passe?',
                        style: PFText.secundario.copyWith(
                          color: PFColors.primaryPressed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: PFSpacing.s),
                  Row(
                    children: [
                      const Icon(
                        PFIcons.verificado,
                        size: 20,
                        color: PFColors.successText,
                      ),
                      const SizedBox(width: PFSpacing.s),
                      Expanded(
                        child: Text(
                          'Sessão segura · dados fictícios · RGPD',
                          style: PFText.secundario,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PFSpacing.margem,
                PFSpacing.s,
                PFSpacing.margem,
                PFSpacing.m,
              ),
              child: Column(
                children: [
                  PFButton(
                    texto: 'Entrar',
                    iconeDepois: PFIcons.direita,
                    carregando: _aEntrar,
                    onPressed: _preenchido && !_aEntrar ? _entrar : null,
                  ),
                  const SizedBox(height: PFSpacing.s),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, PFSpacing.alvo),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.registo),
                    child: Text(
                      'Criar nova conta',
                      style: PFText.corpoForte.copyWith(
                        color: PFColors.primaryPressed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
