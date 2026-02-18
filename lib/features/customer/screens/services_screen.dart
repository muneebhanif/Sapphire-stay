import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../services/mock/mock_data.dart';

/// Hotel services page — displays all available services.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static final _iconMap = {
    'restaurant': Icons.restaurant,
    'spa': Icons.spa,
    'pool': Icons.pool,
    'business': Icons.business_center,
    'car': Icons.directions_car,
    'room_service': Icons.room_service,
    'laundry': Icons.local_laundry_service,
    'concierge': Icons.support_agent,
  };

  @override
  Widget build(BuildContext context) {
    final services = MockData.hotelServices;

    return Column(
      children: [
        // ── Header ──
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.xxl,
          ),
          color: AppColors.primary,
          child: Column(
            children: [
              Text(
                'OUR SERVICES',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Hotel Services & Amenities',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Everything you need for a perfect and comfortable stay',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        // ── Service Cards ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.xxl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              alignment: WrapAlignment.center,
              children: services.map((s) {
                final icon = _iconMap[s['icon']] ?? Icons.star;
                return _buildServiceCard(
                  context,
                  icon: icon,
                  title: s['title'] as String,
                  description: s['description'] as String,
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final width = Responsive.value<double>(
      context,
      mobile: double.infinity,
      tablet: 320,
      desktop: 360,
    );

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(icon, color: AppColors.accent, size: 26),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    description,
                    style: AppTypography.bodySmall.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
