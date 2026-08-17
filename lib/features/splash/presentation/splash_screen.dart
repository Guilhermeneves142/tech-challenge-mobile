import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tela de carregamento (splash) exibida enquanto a sessão é restaurada.
///
/// Aula (animações nativas do Flutter — requisito da Fase 03): em vez de um
/// único `AnimationController`, aqui usamos VÁRIOS, cada um responsável por
/// uma camada de movimento independente:
/// - `_entrance` roda UMA VEZ (logo e textos aparecendo em cascata).
/// - `_ambient` fica em loop contínuo (linhas de tendência rolando ao fundo).
/// - `_pulse` fica em loop de ida-e-volta (o halo "respirando" atrás do logo).
/// - `_dots` fica em loop contínuo (os 3 pontinhos de carregamento).
/// Separar em controllers diferentes deixa cada animação simples de entender
/// e ajustar sem mexer nas outras.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    _pulse.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.brandTertiary, AppColors.brandPrimary],
          ),
        ),
        child: Stack(
          children: [
            // Camada 1: linhas de tendência ao fundo (rolagem contínua suave).
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _ambient,
                builder: (context, _) => CustomPaint(
                  painter: _TrendLinesPainter(_ambient.value),
                ),
              ),
            ),

            // Camada 2: conteúdo central (logo, título, dots).
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AnimatedLogo(entrance: _entrance, pulse: _pulse),
                  const SizedBox(height: 28),
                  _EntranceText(
                    entrance: _entrance,
                    interval: const Interval(0.35, 0.75, curve: Curves.easeOut),
                    child: const Text(
                      'FinanceApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _EntranceText(
                    entrance: _entrance,
                    interval: const Interval(0.55, 0.95, curve: Curves.easeOut),
                    child: Text(
                      'Gerencie suas finanças',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 44),
                  _LoadingDots(controller: _dots),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Logo com entrada em "elastic bounce" + halo que pulsa continuamente atrás.
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.entrance, required this.pulse});

  final AnimationController entrance;
  final AnimationController pulse;

  @override
  Widget build(BuildContext context) {
    final scaleIn = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.0, 0.65, curve: Curves.elasticOut),
    );
    final fadeIn = CurvedAnimation(
      parent: entrance,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([entrance, pulse]),
      builder: (context, child) {
        final haloScale = 1.0 + (pulse.value * 0.18);
        final haloOpacity = 0.15 + (pulse.value * 0.25);

        return Opacity(
          opacity: fadeIn.value,
          child: Transform.scale(
            scale: 0.4 + (scaleIn.value * 0.6),
            child: SizedBox(
              width: 140,
              height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Halo externo "respirando".
                  Transform.scale(
                    scale: haloScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: haloOpacity),
                      ),
                    ),
                  ),
                  child!,
                ],
              ),
            ),
          ),
        );
      },
      // `child` construído uma vez só (não recalcula a cada frame) — o ícone
      // em si não muda, só o halo ao redor dele.
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: const Icon(
          Icons.account_balance_wallet_rounded,
          size: 40,
          color: AppColors.brandPrimary,
        ),
      ),
    );
  }
}

/// Texto que entra com fade + leve deslocamento para cima, num trecho
/// (`interval`) específico da animação de entrada — cria o efeito "cascata".
class _EntranceText extends StatelessWidget {
  const _EntranceText({
    required this.entrance,
    required this.interval,
    required this.child,
  });

  final AnimationController entrance;
  final Interval interval;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(parent: entrance, curve: interval);

    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - anim.value) * 12),
          child: child,
        ),
      ),
    );
  }
}

/// Três pontinhos com uma "onda" de escala/opacidade defasada entre eles —
/// substitui o spinner genérico por algo com mais identidade visual.
class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Cada ponto usa a mesma onda senoidal, com uma defasagem de
            // tempo (`i * 0.2`) — dá o efeito de "onda" entre os 3 pontos.
            final t = (controller.value + (i * 0.2)) % 1.0;
            final wave = (math.sin(t * 2 * math.pi) + 1) / 2; // 0..1
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Opacity(
                opacity: 0.4 + (wave * 0.6),
                child: Transform.scale(
                  scale: 0.7 + (wave * 0.4),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Desenha linhas de tendência (estilo gráfico de mercado) rolando devagar ao
/// fundo — reforça a identidade de app financeiro em vez do clichê genérico
/// de "bolhas" borradas. Puro `CustomPainter`, sem imagens/dependências.
class _TrendLinesPainter extends CustomPainter {
  _TrendLinesPainter(this.t); // t = progresso 0..1 do loop ambiente

  final double t;

  // Pontos normalizados (0..1) de uma linha em zigue-zague ascendente.
  static const _points = [
    Offset(0.00, 0.75),
    Offset(0.10, 0.60),
    Offset(0.18, 0.68),
    Offset(0.28, 0.48),
    Offset(0.37, 0.58),
    Offset(0.47, 0.38),
    Offset(0.56, 0.46),
    Offset(0.65, 0.28),
    Offset(0.75, 0.36),
    Offset(0.85, 0.20),
    Offset(0.93, 0.27),
    Offset(1.00, 0.14),
  ];

  Path _buildPath(double width, double dx, double baseline, double amplitude) {
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final p = _points[i];
      final x = p.dx * width + dx;
      final y = baseline - amplitude / 2 + p.dy * amplitude;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path;
  }

  void _drawLine(
    Canvas canvas,
    Size size, {
    required double speed,
    required double baselineFrac,
    required double amplitude,
    required double opacity,
    required double strokeWidth,
  }) {
    // Rolagem contínua para a esquerda; duas cópias lado a lado garantem que
    // o padrão pareça "sem costura" ao voltar para o início do loop.
    final scroll = (t * speed) % 1.0;
    final dx = -scroll * size.width;
    final baseline = size.height * baselineFrac;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas
      ..drawPath(_buildPath(size.width, dx, baseline, amplitude), paint)
      ..drawPath(
        _buildPath(size.width, dx + size.width, baseline, amplitude),
        paint,
      );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Duas linhas com velocidades/alturas diferentes -> leve sensação de
    // profundidade (parallax), sem chamar atenção demais.
    _drawLine(
      canvas,
      size,
      speed: 0.55,
      baselineFrac: 0.20,
      amplitude: size.height * 0.10,
      opacity: 0.10,
      strokeWidth: 2.2,
    );
    _drawLine(
      canvas,
      size,
      speed: 0.35,
      baselineFrac: 0.66,
      amplitude: size.height * 0.08,
      opacity: 0.07,
      strokeWidth: 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _TrendLinesPainter oldDelegate) =>
      oldDelegate.t != t;
}
