import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Section header with optional "View All" / action button.
///
/// Used across customer pages (Featured Rooms, Services, etc.)
/// and admin/staff dashboards.
class SSSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final CrossAxisAlignment alignment;

  const SSSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.headlineMedium,
              ),
            ),
            if (actionLabel != null)
              TextButton(
                onPressed: onAction,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionLabel!,
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: AppColors.accent,
                    ),
                  ],
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTypography.bodyMedium,
          ),
        ],
      ],
    );
  }
}
