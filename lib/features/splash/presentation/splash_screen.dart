import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tela de carregamento (splash) exibida enquanto a sessão é restaurada.
///
/// Aula (animação nativa do Flutter — requisito da Fase 03):
/// - `AnimationController` = o "motor" da animação (roda de 0.0 a 1.0).
/// - `SingleTickerProviderStateMixin` fornece o "ticker" (sincroniza com os
///   frames da tela — 60fps).
/// - `..repeat(reverse: true)` faz o valor ir e voltar em loop (efeito pulso).
/// - `AnimatedBuilder` reconstrói só o miolo animado a cada frame.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  // Curvas suaves derivadas do mesmo controller.
  late final Animation<double> _scale = Tween(begin: 0.9, end: 1.12).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );
  late final Animation<double> _glow = Tween(begin: 0.15, end: 0.4).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose(); // libera o motor da animação (evita leak)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Fundo em gradiente verde da marca.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.brandTertiary, // #3a5a40
              AppColors.brandPrimary, // #3b783a
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícone que pulsa dentro de um "halo" branco translúcido.
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: _glow.value),
                    ),
                    child: Transform.scale(scale: _scale.value, child: child),
                  );
                },
                // `child` é construído UMA vez e reaproveitado (performance).
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 44,
                    color: AppColors.brandPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'FinanceApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gerencie suas finanças',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 44),
              const SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
