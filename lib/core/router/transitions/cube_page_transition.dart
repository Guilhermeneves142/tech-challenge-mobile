import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Transição 3D estilo "Cubo" (PowerPoint, anos 2010): a tela nova entra
/// girando como se fosse a face seguinte de um cubo, enquanto a tela
/// anterior gira para longe no mesmo eixo — dá a ilusão de girar um cubo
/// em vez de só trocar de tela.
CustomTransitionPage<T> buildCubeTransitionPage<T>({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enter = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
      );
      final exit = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOutCubic,
      );

      return AnimatedBuilder(
        animation: Listenable.merge([enter, exit]),
        child: child,
        builder: (context, child) {
          // Página sendo coberta por outra (ex.: Dashboard quando abre
          // Transações): gira para longe pivotando na borda direita.
          final isExiting = exit.value > 0;
          final angle = isExiting
              ? exit.value * (math.pi / 2)
              : (1 - enter.value) * (-math.pi / 2);

          return Transform(
            alignment: isExiting ? Alignment.centerRight : Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0018) // perspectiva, dá o efeito 3D
              ..rotateY(angle),
            child: Opacity(
              opacity: isExiting ? (1 - exit.value).clamp(0.0, 1.0) : 1,
              child: child,
            ),
          );
        },
      );
    },
  );
}
