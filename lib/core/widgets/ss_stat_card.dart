import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Statistic card for dashboards.
///
/// Displays a metric with label, value, icon, and optional
/// trend indicator (+/- percentage).
class SSStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final String? trend;
  final bool isPositiveTrend;

  const SSStatCard({
    super.key,
    String? label,
    String? title,
    required this.value,
    required this.icon,
    Color? iconColor,
    Color? color,
    this.backgroundColor,
    this.trend,
    this.isPositiveTrend = true,
  })  : label = label ?? title ?? '',
        iconColor = iconColor ?? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.accent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AppColors.accent,
                  size: AppSpacing.iconLg,
                ),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: isPositiveTrend
                        ? AppColors.successLight
                        : AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 14,
                        color: isPositiveTrend
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: AppTypography.labelSmall.copyWith(
                          color: isPositiveTrend
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
