import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/pf_icons.dart';
import '../widgets/pf_button.dart';
import '../widgets/pf_controlos.dart';
import '../widgets/pf_feedback.dart';
import '../widgets/pf_text_field.dart';
import '../widgets/pf_top_bar.dart';

/// Registo no servidor (POST /auth/register). Termos obrigatórios; telemóvel opcional.
class RegistoScreen extends StatefulWidget {
  const RegistoScreen({super.key});

  @override
  State<RegistoScreen> createState() => _RegistoScreenState();
}

class _RegistoScreenState extends State<RegistoScreen> {
  final TextEditingController _nome = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _telemovel = TextEditingController();
  final TextEditingController _palavraPasse = TextEditingController();
  String _perfil = 'Cliente';

  /// Especialidade do prestador: tem de ser igual ao nome da categoria
  /// para o servidor lhe atribuir pedidos.
  String _especialidade = 'Canalização';
  bool _termos = false;
  bool _emailTocado = false;
  bool _tentou = false;
  bool _aCriar = false;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _telemovel.dispose();
    _palavraPasse.dispose();
    super.dispose();
  }

  bool get _emailValido =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(_email.text.trim());
  bool get _passeValida => _palavraPasse.text.length >= 6;

  String? get _erroEmail {
    if (!(_emailTocado || _tentou) || _emailValido) return null;
    return 'Indique um email válido, por exemplo nome@email.pt.';
  }

  String? get _erroPasse {
    if (!_tentou || _passeValida) return null;
    return 'A palavra-passe tem pelo menos 6 caracteres.';
  }

  bool get _preenchido =>
      _nome.text.trim().isNotEmpty &&
      _email.text.trim().isNotEmpty &&
      _palavraPasse.text.isNotEmpty &&
      _termos;

  Future<void> _criarConta() async {
    setState(() => _tentou = true);
    if (!_emailValido || !_passeValida) {
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.erro,
        'Não conseguimos criar a conta. Corrija os campos a vermelho.',
      );
      return;
    }

    // POST /auth/register (já devolve a sessão iniciada)
    setState(() => _aCriar = true);
    try {
      final utilizador = await Api.registar(
        nome: _nome.text.trim(),
        email: _email.text.trim(),
        palavraPasse: _palavraPasse.text,
        telefone: _telemovel.text.trim(),
        prestador: _perfil == 'Prestador',
        especialidade: _perfil == 'Prestador' ? _especialidade : null,
      );
      if (!mounted) return;
      PFFeedback.mostrar(
        context,
        PFTipoFeedback.sucesso,
        'Conta criada · bem-vindo ao ProntoFix.',
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (rota) => false,
        arguments: utilizador.prestador,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _aCriar = false);
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
              titulo: 'Criar conta',
              subtitulo: 'Demora menos de 30 segundos.',
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
                  PFSegmentado(
                    opcoes: const ['Cliente', 'Prestador'],
                    selecionado: _perfil,
                    onChanged: (v) => setState(() => _perfil = v),
                  ),
                  if (_perfil == 'Prestador') ...[
                    const SizedBox(height: PFSpacing.l),
                    Text('Especialidade', style: PFText.secundario),
                    const SizedBox(height: PFSpacing.s),
                    PFSegmentado(
                      opcoes: const ['Canalização', 'Eletricidade', 'Serralharia'],
                      selecionado: _especialidade,
                      onChanged: (v) => setState(() => _especialidade = v),
                    ),
                  ],
                  const SizedBox(height: PFSpacing.xl),
                  PFTextField(
                    etiqueta: 'Nome',
                    dica: 'O seu nome',
                    controlador: _nome,
                    iconePrefixo: PFIcons.utilizador,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: PFSpacing.l),
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
                  PFTextField(
                    etiqueta: 'Telemóvel',
                    dica: '9xx xxx xxx',
                    opcional: true,
                    controlador: _telemovel,
                    iconePrefixo: PFIcons.telemovel,
                    teclado: TextInputType.phone,
                    ajuda: 'Só para o prestador o contactar durante o serviço.',
                  ),
                  const SizedBox(height: PFSpacing.l),
                  PFTextField(
                    etiqueta: 'Palavra-passe',
                    dica: 'Pelo menos 6 caracteres',
                    controlador: _palavraPasse,
                    iconePrefixo: PFIcons.cadeado,
                    ocultar: true,
                    erro: _erroPasse,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: PFSpacing.l),
                  PFCheckbox(
                    valor: _termos,
                    onChanged: (v) => setState(() => _termos = v),
                    rotuloSemantico:
                        'Aceito os termos e a política de privacidade',
                    rotulo: Text(
                      'Aceito os termos e a política de privacidade (RGPD).',
                      style: PFText.secundario.copyWith(color: PFColors.text),
                    ),
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
                    texto: 'Criar conta',
                    carregando: _aCriar,
                    onPressed: _preenchido && !_aCriar ? _criarConta : null,
                  ),
                  const SizedBox(height: PFSpacing.s),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, PFSpacing.alvo),
                    ),
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.login),
                    child: Text(
                      'Já tenho conta',
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
