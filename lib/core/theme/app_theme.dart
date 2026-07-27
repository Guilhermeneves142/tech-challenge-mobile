import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'app_colors.dart';

/// Temas shadcn (light/dark) do FinanceApp, construídos a partir dos design
/// tokens em [AppColors]. Usado por `ShadApp` em `app.dart`.
abstract class AppTheme {
  AppTheme._();

  /// Raio padrão dos componentes (token --radius-md = 8px).
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(8));

  static final _textTheme = ShadTextTheme(family: 'Roboto');

  static ShadThemeData get light => ShadThemeData(
        brightness: Brightness.light,
        radius: _radius,
        textTheme: _textTheme,
        colorScheme: const ShadColorScheme(
          background: AppColors.lightBackground,
          foreground: AppColors.lightForeground,
          card: AppColors.lightCard,
          cardForeground: AppColors.lightCardForeground,
          popover: AppColors.lightPopover,
          popoverForeground: AppColors.lightPopoverForeground,
          primary: AppColors.lightPrimary,
          primaryForeground: AppColors.lightPrimaryForeground,
          secondary: AppColors.lightSecondary,
          secondaryForeground: AppColors.lightSecondaryForeground,
          muted: AppColors.lightMuted,
          mutedForeground: AppColors.lightMutedForeground,
          accent: AppColors.lightAccent,
          accentForeground: AppColors.lightAccentForeground,
          destructive: AppColors.lightDestructive,
          destructiveForeground: AppColors.lightDestructiveForeground,
          border: AppColors.lightBorder,
          input: AppColors.lightInput,
          ring: AppColors.lightRing,
          selection: AppColors.brandSecondary,
        ),
      );

  static ShadThemeData get dark => ShadThemeData(
        brightness: Brightness.dark,
        radius: _radius,
        textTheme: _textTheme,
        colorScheme: const ShadColorScheme(
          background: AppColors.darkBackground,
          foreground: AppColors.darkForeground,
          card: AppColors.darkCard,
          cardForeground: AppColors.darkCardForeground,
          popover: AppColors.darkPopover,
          popoverForeground: AppColors.darkPopoverForeground,
          primary: AppColors.darkPrimary,
          primaryForeground: AppColors.darkPrimaryForeground,
          secondary: AppColors.darkSecondary,
          secondaryForeground: AppColors.darkSecondaryForeground,
          muted: AppColors.darkMuted,
          mutedForeground: AppColors.darkMutedForeground,
          accent: AppColors.darkAccent,
          accentForeground: AppColors.darkAccentForeground,
          destructive: AppColors.darkDestructive,
          destructiveForeground: AppColors.darkDestructiveForeground,
          border: AppColors.darkBorder,
          input: AppColors.darkInput,
          ring: AppColors.darkRing,
          selection: AppColors.darkAccent,
        ),
      );
}
