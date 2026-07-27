import 'package:flutter/material.dart';

/// Design tokens do FinanceApp (fonte da verdade: @vandrei/finance-ui `tokens.css`).
///
/// Estes valores espelham os tokens semânticos shadcn usados nos apps React,
/// para manter paridade visual entre web e mobile.
abstract class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────
  static const brandPrimary = Color(0xFF3B783A);
  static const brandSecondary = Color(0xFFC3DB99);
  static const brandTertiary = Color(0xFF3A5A40);
  static const brandBackground = Color(0xFFF8F6F0);

  // ── Feedback (compartilhado light/dark, com variações no dark) ──────────
  static const success = Color(0xFF198754);
  static const successLight = Color(0xFFD4EDDA);
  static const error = Color(0xFFDC3545);
  static const errorLight = Color(0xFFF8D7DA);
  static const warning = Color(0xFFFD7E14);
  static const warningLight = Color(0xFFFFF3CD);
  static const info = Color(0xFF0D6EFD);
  static const infoLight = Color(0xFFCFE2FF);

  // ── Neutral scale (Gray 100→900) ────────────────────────────────────────
  static const gray100 = Color(0xFFF5F5F5);
  static const gray200 = Color(0xFFE5E5E5);
  static const gray300 = Color(0xFFD4D4D4);
  static const gray400 = Color(0xFFA3A3A3);
  static const gray500 = Color(0xFF737373);
  static const gray600 = Color(0xFF525252);
  static const gray700 = Color(0xFF404040);
  static const gray800 = Color(0xFF262626);
  static const gray900 = Color(0xFF171717);

  // ── Semantic shadcn — LIGHT ─────────────────────────────────────────────
  static const lightBackground = Color(0xFFF8F6F0);
  static const lightForeground = Color(0xFF171717);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardForeground = Color(0xFF171717);
  static const lightPopover = Color(0xFFFFFFFF);
  static const lightPopoverForeground = Color(0xFF171717);
  static const lightPrimary = Color(0xFF3B783A);
  static const lightPrimaryForeground = Color(0xFFFFFFFF);
  static const lightSecondary = Color(0xFFC3DB99);
  static const lightSecondaryForeground = Color(0xFF3A5A40);
  static const lightMuted = Color(0xFFDAD7CD);
  static const lightMutedForeground = Color(0xFF737373);
  static const lightAccent = Color(0xFFC3DB99);
  static const lightAccentForeground = Color(0xFF3A5A40);
  static const lightDestructive = Color(0xFFDC3545);
  static const lightDestructiveForeground = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFD4D4D4);
  static const lightInput = Color(0xFFD4D4D4);
  static const lightRing = Color(0xFF3B783A);

  // ── Semantic shadcn — DARK ──────────────────────────────────────────────
  static const darkBackground = Color(0xFF1E1E1E);
  static const darkForeground = Color(0xFFF5F5F5);
  static const darkCard = Color(0xFF171717);
  static const darkCardForeground = Color(0xFFF5F5F5);
  static const darkPopover = Color(0xFF171717);
  static const darkPopoverForeground = Color(0xFFF5F5F5);
  static const darkPrimary = Color(0xFF6B9E6A);
  static const darkPrimaryForeground = Color(0xFFFFFFFF);
  static const darkSecondary = Color(0xFF262626);
  static const darkSecondaryForeground = Color(0xFFD4D4D4);
  static const darkMuted = Color(0xFF262626);
  static const darkMutedForeground = Color(0xFFA3A3A3);
  static const darkAccent = Color(0xFF4A7050);
  static const darkAccentForeground = Color(0xFFFFFFFF);
  static const darkDestructive = Color(0xFFE85D6A);
  static const darkDestructiveForeground = Color(0xFFFFFFFF);
  static const darkBorder = Color(0xFF404040);
  static const darkInput = Color(0xFF404040);
  static const darkRing = Color(0xFF6B9E6A);
}
