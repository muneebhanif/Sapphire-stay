import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Standardized button variants for the entire application.
///
/// Avoids style inconsistency by providing predefined button types:
///   • primary   — Gold accent, high emphasis actions (Book Now, Submit)
///   • secondary — Outlined, medium emphasis (Cancel, View Details)
///   • text      — Low emphasis, inline actions
///   • danger    — Destructive actions (Delete, Remove)
///
/// All variants support loading state, disabled state, and icon prefix.
enum SSButtonVariant { primary, secondary, text, danger }
enum SSButtonSize { small, medium, large }

class SSButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final SSButtonVariant variant;
  final SSButtonSize size;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  const SSButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = SSButtonVariant.primary,
    this.size = SSButtonSize.medium,
    this.isLoading = false,
    this.isExpanded = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    final buttonChild = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: _iconSize,
            height: _iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _foregroundColor,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: _iconSize),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label),
      ],
    );

    Widget button;

    switch (variant) {
      case SSButtonVariant.primary:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            padding: _padding,
            minimumSize: _minimumSize,
          ),
          child: buttonChild,
        );
      case SSButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: effectiveOnPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: _padding,
            minimumSize: _minimumSize,
            side: const BorderSide(color: AppColors.border),
          ),
          child: buttonChild,
        );
      case SSButtonVariant.text:
        button = TextButton(
          onPressed: effectiveOnPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.accent,
            padding: _padding,
            minimumSize: _minimumSize,
          ),
          child: buttonChild,
        );
      case SSButtonVariant.danger:
        button = ElevatedButton(
          onPressed: effectiveOnPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
            padding: _padding,
            minimumSize: _minimumSize,
          ),
          child: buttonChild,
        );
    }

    return isExpanded ? SizedBox(width: double.infinity, child: button) : button;
  }

  EdgeInsets get _padding => switch (size) {
        SSButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        SSButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        SSButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      };

  Size get _minimumSize => switch (size) {
        SSButtonSize.small => const Size(60, 32),
        SSButtonSize.medium => const Size(80, 40),
        SSButtonSize.large => const Size(100, 48),
      };

  double get _iconSize => switch (size) {
        SSButtonSize.small => 14,
        SSButtonSize.medium => 18,
        SSButtonSize.large => 20,
      };

  Color get _foregroundColor => switch (variant) {
        SSButtonVariant.primary => AppColors.primary,
        SSButtonVariant.secondary => AppColors.primary,
        SSButtonVariant.text => AppColors.accent,
        SSButtonVariant.danger => AppColors.white,
      };
}
