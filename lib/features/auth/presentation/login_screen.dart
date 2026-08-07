import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/auth_provider.dart';

/// Tela de login — espelha o `LoginForm.tsx` do mfe-auth.
///
/// É um StatefulWidget porque tem estado local (mostrar/ocultar senha).
/// O estado de auth (loading/erro/token) fica no [AuthProvider].
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave do formulário: dá acesso a validar e ler os valores dos campos.
  final _formKey = GlobalKey<ShadFormState>();
  bool _obscure = true;

  Future<void> _submit() async {
    // Captura antes do await (boa prática ao cruzar `async` com `context`).
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);

    // saveAndValidate() roda todos os `validator`; só segue se tudo ok.
    if (!_formKey.currentState!.saveAndValidate()) return;

    final values = _formKey.currentState!.value;
    /*final ok = await auth.login(
      email: (values['email'] as String).trim(),
      password: values['password'] as String,
    )

    if (ok && mounted) router.go('/'); */// logado -> área interna
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    // `watch` = assina o provider: rebuilda quando loading/erro mudam.
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ShadCard(
                title: Text('Entrar', style: theme.textTheme.h3),
                description: const Text('Acesse sua conta FinanceApp'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ShadForm(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        ShadInputFormField(
                          id: 'email',
                          label: const Text('E-mail'),
                          placeholder: const Text('Digite seu e-mail'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Informe o e-mail';
                            if (!v.contains('@')) return 'E-mail inválido';
                            return null; // null = campo válido
                          },
                        ),
                        ShadInputFormField(
                          id: 'password',
                          label: const Text('Senha'),
                          placeholder: const Text('Digite sua senha'),
                          obscureText: _obscure,
                          trailing: _ObscureToggle(
                            obscure: _obscure,
                            onTap: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) =>
                              v.isEmpty ? 'Informe a senha' : null,
                        ),

                        // Mensagem de erro do backend (e-mail/senha inválidos).
                        if (auth.errorMessage != null)
                          Text(
                            auth.errorMessage!,
                            style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.destructive,
                            ),
                          ),

                        ShadButton(
                          // onPressed null enquanto carrega = botão desabilitado
                          onPressed: auth.isLoading ? null : _submit,
                          child: Text(auth.isLoading ? 'Entrando...' : 'Entrar'),
                        ),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Não tem uma conta?',
                              style: theme.textTheme.muted,
                            ),
                            ShadButton.link(
                              onPressed: () {
                                context.read<AuthProvider>().clearError();
                                context.go('/cadastro');
                              },
                              child: const Text('Cadastre-se'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ícone de olho pra mostrar/ocultar a senha (vai no `trailing` do input).
class _ObscureToggle extends StatelessWidget {
  const _ObscureToggle({required this.obscure, required this.onTap});

  final bool obscure;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 18,
        color: theme.colorScheme.mutedForeground,
      ),
    );
  }
}
