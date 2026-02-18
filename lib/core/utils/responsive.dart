import 'package:flutter/material.dart';

/// Responsive breakpoints and utilities.
///
/// Breakpoints:
///   • Mobile:  < 768px
///   • Tablet:  768px – 1199px
///   • Desktop: ≥ 1200px
///
/// Usage:
///   ```dart
///   Responsive(
///     mobile: MobileLayout(),
///     tablet: TabletLayout(),
///     desktop: DesktopLayout(),
///   )
///   ```
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  // ─── Breakpoint Constants ──────────────────────────────────────
  static const double mobileBreakpoint  = 768.0;
  static const double tabletBreakpoint  = 1200.0;

  // ─── Static Helpers ────────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  /// Returns the appropriate value based on screen width.
  /// Useful for inline responsive values (padding, font sizes, etc.).
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  /// Returns appropriate horizontal page padding for current breakpoint.
  static double pagePadding(BuildContext context) => value(
        context,
        mobile: 16.0,
        tablet: 32.0,
        desktop: 64.0,
      );

  /// Returns number of grid columns for current breakpoint.
  static int gridColumns(BuildContext context) => value(
        context,
        mobile: 1,
        tablet: 2,
        desktop: 3,
      );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint) {
          return desktop;
        }
        if (constraints.maxWidth >= mobileBreakpoint) {
          return tablet ?? desktop;
        }
        return mobile;
      },
    );
  }
}
