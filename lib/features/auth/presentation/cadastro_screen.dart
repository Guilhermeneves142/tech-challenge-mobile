import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../providers/auth_provider.dart';

/// Tela de cadastro — espelha o `CadastroForm.tsx` do mfe-auth
/// (nome + e-mail + senha + confirmação, com validação de senhas iguais).
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<ShadFormState>();
  // Controller na senha pra o campo "confirmar" conseguir comparar o valor.
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose(); // libera o controller (evita leak)
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final router = GoRouter.of(context);

    if (!_formKey.currentState!.saveAndValidate()) return;

    final values = _formKey.currentState!.value;
    final ok = await auth.register(
      name: (values['name'] as String).trim(),
      email: (values['email'] as String).trim(),
      password: values['password'] as String,
    );

    if (ok && mounted) router.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
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
                title: Text('Criar conta', style: theme.textTheme.h3),
                description: const Text('Comece a usar o FinanceApp grátis'),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ShadForm(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 16,
                      children: [
                        ShadInputFormField(
                          id: 'name',
                          label: const Text('Nome completo'),
                          placeholder: const Text('Digite seu nome'),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              v.trim().isEmpty ? 'Informe seu nome' : null,
                        ),
                        ShadInputFormField(
                          id: 'email',
                          label: const Text('E-mail'),
                          placeholder: const Text('Digite seu e-mail'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v.trim().isEmpty) return 'Informe o e-mail';
                            if (!v.contains('@')) return 'E-mail inválido';
                            return null;
                          },
                        ),
                        ShadInputFormField(
                          id: 'password',
                          label: const Text('Senha'),
                          placeholder: const Text('Mínimo 6 caracteres'),
                          controller: _passwordController,
                          obscureText: _obscure,
                          trailing: _ObscureToggle(
                            obscure: _obscure,
                            onTap: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v.isEmpty) return 'Informe a senha';
                            if (v.length < 6) return 'Mínimo de 6 caracteres';
                            return null;
                          },
                        ),
                        ShadInputFormField(
                          id: 'confirm',
                          label: const Text('Confirmar senha'),
                          placeholder: const Text('Repita a senha'),
                          obscureText: _obscure,
                          validator: (v) {
                            if (v.isEmpty) return 'Confirme a senha';
                            if (v != _passwordController.text) {
                              return 'As senhas não coincidem';
                            }
                            return null;
                          },
                        ),

                        if (auth.errorMessage != null)
                          Text(
                            auth.errorMessage!,
                            style: theme.textTheme.small.copyWith(
                              color: theme.colorScheme.destructive,
                            ),
                          ),

                        ShadButton(
                          onPressed: auth.isLoading ? null : _submit,
                          child: Text(
                            auth.isLoading ? 'Criando conta...' : 'Criar conta',
                          ),
                        ),

                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Já tem uma conta?',
                              style: theme.textTheme.muted,
                            ),
                            ShadButton.link(
                              onPressed: () {
                                context.read<AuthProvider>().clearError();
                                context.go('/login');
                              },
                              child: const Text('Entrar'),
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
