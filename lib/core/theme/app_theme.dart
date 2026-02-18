import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Application-wide [ThemeData] factory.
///
/// Provides both light and dark themes built on top of our
/// color, typography, and spacing tokens. All widgets should
/// inherit from the theme rather than specifying inline styles.
abstract final class AppTheme {
  // ─── Light Theme ─────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.textOnPrimary,
          secondary: AppColors.accent,
          onSecondary: AppColors.textOnAccent,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.white,
          outline: AppColors.border,
        ),

        // ── Text Theme ──
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headlineLarge,
          headlineMedium: AppTypography.headlineMedium,
          headlineSmall: AppTypography.headlineSmall,
          titleLarge: AppTypography.titleLarge,
          titleMedium: AppTypography.titleMedium,
          titleSmall: AppTypography.titleSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),

        // ── AppBar ──
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: AppTypography.titleLarge,
        ),

        // ── Card ──
        cardTheme: CardThemeData(
          color: AppColors.cardSurface,
          elevation: AppSpacing.cardElevation,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),

        // ── Elevated Button ──
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            textStyle: AppTypography.buttonMedium,
          ),
        ),

        // ── Outlined Button ──
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            side: const BorderSide(color: AppColors.border),
            textStyle: AppTypography.buttonMedium,
          ),
        ),

        // ── Text Button ──
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            textStyle: AppTypography.buttonMedium,
          ),
        ),

        // ── Input Decoration ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          labelStyle: AppTypography.bodyMedium,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),

        // ── Divider ──
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),

        // ── Chip ──
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          labelStyle: AppTypography.labelMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
        ),

        // ── Data Table ──
        dataTableTheme: DataTableThemeData(
          headingTextStyle: AppTypography.labelLarge,
          dataTextStyle: AppTypography.bodyMedium,
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
          dividerThickness: 1,
        ),

        // ── Dialog ──
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.dialogSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          titleTextStyle: AppTypography.headlineSmall,
        ),

        // ── Snackbar ──
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Tab Bar ──
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.accent,
          labelStyle: AppTypography.labelLarge,
          unselectedLabelStyle: AppTypography.labelLarge,
        ),
      );

  // ─── Dark Theme ──────────────────────────────────────────────────
  static ThemeData get dark => light.copyWith(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.primary,
          secondary: AppColors.accentLight,
          onSecondary: AppColors.primary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          error: AppColors.error,
          onError: AppColors.white,
          outline: AppColors.textTertiary,
        ),
        cardTheme: light.cardTheme.copyWith(
          color: AppColors.darkCard,
        ),
        appBarTheme: light.appBarTheme.copyWith(
          backgroundColor: AppColors.darkSurface,
          foregroundColor: AppColors.darkTextPrimary,
        ),
      );
}
