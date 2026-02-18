import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';

/// Full-width hero banner for the home page.
///
/// Features:
///   • Background image with dark overlay for text readability
///   • Animated headline and tagline
///   • Primary CTA (Book Now) + secondary CTA (Explore Rooms)
///   • Responsive layout (stacks on mobile)
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final height = Responsive.value<double>(
      context,
      mobile: 500,
      tablet: 550,
      desktop: 650,
    );

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage(AppConstants.heroImage),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primary.withValues(alpha: 0.65),
            BlendMode.darken,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Overline ──
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    'WELCOME TO ${AppConstants.hotelName.toUpperCase()}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Headline ──
                Text(
                  AppConstants.tagline,
                  style: Responsive.value(
                    context,
                    mobile: AppTypography.displaySmall,
                    desktop: AppTypography.displayLarge,
                  ).copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Subheadline ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Text(
                    'Indulge in world-class amenities, breathtaking views, and impeccable '
                    'service at our award-winning coastal retreat.',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── CTAs ──
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => context.go(RoutePaths.booking),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text('Book Your Stay'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.go(RoutePaths.rooms),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        side: const BorderSide(color: AppColors.white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      child: const Text('Explore Rooms'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
