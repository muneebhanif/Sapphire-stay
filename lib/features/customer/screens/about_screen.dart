import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';

/// About page — hotel story, mission, and team highlights.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Page Header ──
        _buildPageHeader(context),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Story Section ──
        _buildStorySection(context),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Values Section ──
        _buildValuesSection(context),
        const SizedBox(height: AppSpacing.xxxl),

        // ── Stats Section ──
        _buildStatsSection(context),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildPageHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage(AppConstants.hotelExterior),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primary.withValues(alpha: 0.7),
            BlendMode.darken,
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'ABOUT US',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Our Story',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Text(
                'Discover the history, values, and people behind Sapphire Stay Hotel — '
                'your home away from home.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.white.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorySection(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Image.network(
                        AppConstants.hotelLobby,
                        height: 450,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  Expanded(child: _buildStoryText()),
                ],
              )
            : Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: Image.network(
                      AppConstants.hotelLobby,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStoryText(),
                ],
              ),
      ),
    );
  }

  Widget _buildStoryText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A Heritage of Excellence',
          style: AppTypography.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Founded in 1998, Sapphire Stay Hotel began as a family vision to create a '
          'hospitality experience that transcends the ordinary. What started as a boutique '
          'property with just 20 rooms has grown into a premier destination renowned '
          'for its impeccable service and stunning architecture.',
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Today, our hotel stands as a testament to the enduring values of warmth, '
          'attention to detail, and genuine care for every guest who walks through our doors. '
          'We believe that true luxury is not just about opulent surroundings — it\'s about '
          'creating moments that become cherished memories.',
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Our dedicated team of hospitality professionals works tirelessly to ensure that '
          'every aspect of your stay exceeds expectations, from the moment you arrive until '
          'your departure.',
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
      ],
    );
  }

  Widget _buildValuesSection(BuildContext context) {
    final values = [
      _ValueItem(
        Icons.favorite_border,
        'Guest First',
        'Every decision we make starts with our guests\' comfort and satisfaction.',
      ),
      _ValueItem(
        Icons.eco_outlined,
        'Sustainability',
        'Committed to eco-friendly practices and minimizing our environmental footprint.',
      ),
      _ValueItem(
        Icons.handshake_outlined,
        'Integrity',
        'Transparent, honest, and fair in all our interactions with guests and partners.',
      ),
      _ValueItem(
        Icons.auto_awesome_outlined,
        'Excellence',
        'Continuously raising the bar in service quality and guest experience.',
      ),
    ];

    return Container(
      color: AppColors.surfaceVariant,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Column(
          children: [
            Text(
              'OUR VALUES',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'What Drives Us',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              alignment: WrapAlignment.center,
              children: values.map((v) {
                return SizedBox(
                  width: Responsive.value<double>(
                    context,
                    mobile: double.infinity,
                    tablet: 280,
                    desktop: 260,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Icon(v.icon, size: 36, color: AppColors.accent),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          v.title,
                          style: AppTypography.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          v.description,
                          style: AppTypography.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    final stats = [
      _StatItem('25+', 'Years of Excellence'),
      _StatItem('50K+', 'Happy Guests'),
      _StatItem('100+', 'Expert Staff'),
      _StatItem('15+', 'Awards Won'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Wrap(
          spacing: AppSpacing.xxl,
          runSpacing: AppSpacing.lg,
          alignment: WrapAlignment.center,
          children: stats.map((s) {
            return SizedBox(
              width: Responsive.value<double>(
                context,
                mobile: 140,
                desktop: 200,
              ),
              child: Column(
                children: [
                  Text(
                    s.value,
                    style: AppTypography.displaySmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    s.label,
                    style: AppTypography.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ValueItem {
  final IconData icon;
  final String title;
  final String description;
  const _ValueItem(this.icon, this.title, this.description);
}

class _StatItem {
  final String value;
  final String label;
  const _StatItem(this.value, this.label);
}
