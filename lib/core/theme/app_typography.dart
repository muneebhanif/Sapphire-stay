import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography scale for StaySite.
///
/// Uses Playfair Display for headings (classic hospitality serif)
/// and Inter for body text (highly legible, modern sans-serif).
///
/// Scale follows Material 3 type system but with custom fonts.
abstract final class AppTypography {
  // ─── Heading Font ────────────────────────────────────────────────
  static String get _headingFamily => GoogleFonts.playfairDisplay().fontFamily!;

  // ─── Body Font ───────────────────────────────────────────────────
  static String get _bodyFamily => GoogleFonts.inter().fontFamily!;

  // ─── Display ─────────────────────────────────────────────────────
  static TextStyle get displayLarge => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 57,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.12,
        color: AppColors.textPrimary,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 45,
        fontWeight: FontWeight.w700,
        height: 1.16,
        color: AppColors.textPrimary,
      );

  static TextStyle get displaySmall => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.22,
        color: AppColors.textPrimary,
      );

  // ─── Headline ────────────────────────────────────────────────────
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: _headingFamily,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // ─── Title ───────────────────────────────────────────────────────
  static TextStyle get titleLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  // ─── Body ────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.textTertiary,
      );

  // ─── Label ───────────────────────────────────────────────────────
  static TextStyle get labelLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: AppColors.textTertiary,
      );

  // ─── Button Text ─────────────────────────────────────────────────
  static TextStyle get buttonLarge => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.5,
      );

  static TextStyle get buttonMedium => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.43,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontFamily: _bodyFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
      );
}
