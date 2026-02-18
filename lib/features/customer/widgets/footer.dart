import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';

/// Consistent footer for all customer-facing pages.
class CustomerFooter extends StatelessWidget {
  const CustomerFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          isDesktop
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.lg),
          // ── Copyright ──
          Text(
            AppConstants.copyright,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Brand ──
        Expanded(flex: 2, child: _buildBrandSection()),
        const SizedBox(width: AppSpacing.xxl),

        // ── Quick Links ──
        Expanded(child: _buildQuickLinks(context)),
        const SizedBox(width: AppSpacing.xxl),

        // ── Contact ──
        Expanded(child: _buildContactSection()),
        const SizedBox(width: AppSpacing.xxl),

        // ── Newsletter ──
        Expanded(flex: 2, child: _buildNewsletterSection()),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(),
        const SizedBox(height: AppSpacing.xl),
        _buildQuickLinks(context),
        const SizedBox(height: AppSpacing.xl),
        _buildContactSection(),
        const SizedBox(height: AppSpacing.xl),
        _buildNewsletterSection(),
      ],
    );
  }

  Widget _buildBrandSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName.toUpperCase(),
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.accent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          AppConstants.hotelName,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Experience luxury and comfort at its finest. Our hotel offers world-class '
          'amenities and exceptional service in a stunning coastal location.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      ('Home', RoutePaths.home),
      ('Rooms', RoutePaths.rooms),
      ('Services', RoutePaths.services),
      ('Gallery', RoutePaths.gallery),
      ('About Us', RoutePaths.about),
      ('Contact', RoutePaths.contact),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: AppTypography.titleSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.md),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: InkWell(
              onTap: () => context.go(link.$2),
              child: Text(
                link.$1,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: AppTypography.titleSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildContactItem(Icons.phone_outlined, AppConstants.phone),
        const SizedBox(height: AppSpacing.xs),
        _buildContactItem(Icons.email_outlined, AppConstants.email),
        const SizedBox(height: AppSpacing.xs),
        _buildContactItem(Icons.location_on_outlined, AppConstants.address),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsletterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Newsletter',
          style: AppTypography.titleSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Subscribe for exclusive offers and updates.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Your email address',
                  filled: true,
                  fillColor: AppColors.primaryLight,
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Subscribe'),
            ),
          ],
        ),
      ],
    );
  }
}
