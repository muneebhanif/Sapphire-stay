import 'package:flutter/material.dart';

/// Centralized color palette for StaySite.
///
/// Design rationale:
///   • Primary (deep navy) conveys trust, professionalism — standard in hospitality.
///   • Accent (warm gold) adds luxury without being gaudy.
///   • Neutral grays provide hierarchy without visual noise.
///   • Semantic colors (success/warning/error) follow universal conventions.
///
/// Usage: Always reference [AppColors] instead of inline Color values.
abstract final class AppColors {
  // ─── Brand Primaries ─────────────────────────────────────────────
  static const Color primary = Color(0xFF0F1B2D);
  static const Color primaryLight = Color(0xFF1A2D47);
  static const Color primaryDark = Color(0xFF0A1220);

  // ─── Accent / Gold ───────────────────────────────────────────────
  static const Color accent = Color(0xFFC9A96E);
  static const Color accentLight = Color(0xFFDFC599);
  static const Color accentDark = Color(0xFFB08D4F);

  // ─── Neutrals ────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F7F4);
  static const Color backgroundLight = Color(0xFFF5F3EF);
  static const Color border = Color(0xFFE0DCD5);
  static const Color divider = Color(0xFFEAE7E1);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFF1A1A1A);

  // ─── Surfaces ────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F3EF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color dialogSurface = Color(0xFFFFFFFF);

  // ─── Semantic ────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error = Color(0xFFC62828);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ─── Dark Theme Overrides ────────────────────────────────────────
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // ─── Status Colors (for bookings, rooms) ─────────────────────────
  static const Color statusAvailable = Color(0xFF2E7D32);
  static const Color statusOccupied = Color(0xFFC62828);
  static const Color statusReserved = Color(0xFFF57F17);
  static const Color statusMaintenance = Color(0xFF6B6B6B);
  static const Color statusCheckedIn = Color(0xFF1565C0);
}
