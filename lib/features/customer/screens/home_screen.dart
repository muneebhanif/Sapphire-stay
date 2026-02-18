import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_section_header.dart';
import '../../../providers/providers.dart';
import '../widgets/availability_picker.dart';
import '../widgets/hero_section.dart';
import '../widgets/room_card.dart';

/// Customer landing page — conversion-focused design.
///
/// Sections (in order of visual priority):
///   1. Hero banner with CTA
///   2. Availability checker
///   3. Featured rooms
///   4. About teaser
///   5. Services highlights
///   6. Reviews preview
///   7. CTA banner
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // ── 1. Hero Section ──
        const HeroSection(),

        // ── 2. Availability Picker (overlapping hero) ──
        Transform.translate(
          offset: const Offset(0, -40),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.pagePadding(context),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
              child: Responsive(
                mobile: const AvailabilityPicker(compact: true),
                desktop: const AvailabilityPicker(),
              ),
            ),
          ),
        ),

        // ── 3. Featured Rooms ──
        _buildFeaturedRooms(context, ref),

        const SizedBox(height: AppSpacing.xxxl),

        // ── 4. About Teaser ──
        _buildAboutTeaser(context),

        const SizedBox(height: AppSpacing.xxxl),

        // ── 5. Services Highlights ──
        _buildServicesHighlights(context),

        const SizedBox(height: AppSpacing.xxxl),

        // ── 6. Reviews Preview ──
        _buildReviewsPreview(context, ref),

        const SizedBox(height: AppSpacing.xxxl),

        // ── 7. CTA Banner ──
        _buildCtaBanner(context),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildFeaturedRooms(BuildContext context, WidgetRef ref) {
    final featuredRooms = ref.watch(featuredRoomsProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Column(
          children: [
            SSSectionHeader(
              title: 'Featured Rooms',
              subtitle: 'Discover our most popular accommodations',
              actionLabel: 'View All Rooms',
              onAction: () => context.go(RoutePaths.rooms),
            ),
            const SizedBox(height: AppSpacing.lg),
            featuredRooms.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
              error: (e, _) => Text('Error: $e'),
              data: (rooms) => Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                children: rooms
                    .map((room) => SizedBox(
                          width: Responsive.value(
                            context,
                            mobile: double.infinity,
                            tablet: 340.0,
                            desktop: 360.0,
                          ),
                          child: RoomCard(room: room),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTeaser(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      color: AppColors.surfaceVariant,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Image ──
                  Expanded(
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLg),
                      child: Image.network(
                        AppConstants.hotelLobby,
                        height: 400,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  // ── Text ──
                  Expanded(child: _buildAboutContent(context)),
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
                  _buildAboutContent(context),
                ],
              ),
      ),
    );
  }

  Widget _buildAboutContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          'A Legacy of Luxury\nSince 1998',
          style: AppTypography.headlineLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Sapphire Stay Hotel has been a beacon of luxury hospitality for over two '
          'decades. Nestled along the pristine coastline, our hotel combines timeless '
          'elegance with modern comfort to create unforgettable experiences for every guest.',
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: AppSpacing.lg),
        // ── Stats ──
        Row(
          children: [
            _buildStat('25+', 'Years'),
            const SizedBox(width: AppSpacing.xl),
            _buildStat('50K+', 'Guests'),
            const SizedBox(width: AppSpacing.xl),
            _buildStat('4.8', 'Rating'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: () => context.go(RoutePaths.about),
          child: const Text('Learn More'),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.accent,
          ),
        ),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }

  Widget _buildServicesHighlights(BuildContext context) {
    final services = [
      _ServiceItem(Icons.restaurant, 'Fine Dining',
          'World-class cuisine by award-winning chefs'),
      _ServiceItem(
          Icons.spa, 'Spa & Wellness', 'Rejuvenating treatments for mind and body'),
      _ServiceItem(
          Icons.pool, 'Infinity Pool', 'Heated pool with stunning ocean views'),
      _ServiceItem(Icons.room_service, '24/7 Service',
          'Round-the-clock concierge and room service'),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Column(
          children: [
            SSSectionHeader(
              title: 'Hotel Services',
              subtitle: 'Everything you need for a perfect stay',
              alignment: CrossAxisAlignment.center,
              actionLabel: 'All Services',
              onAction: () => context.go(RoutePaths.services),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.lg,
              alignment: WrapAlignment.center,
              children: services
                  .map((s) => _buildServiceCard(context, s))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, _ServiceItem item) {
    final width = Responsive.value<double>(
      context,
      mobile: double.infinity,
      tablet: 250,
      desktop: 260,
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
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(item.icon, color: AppColors.accent, size: 28),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              item.title,
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.description,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsPreview(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(allReviewsProvider);

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
            SSSectionHeader(
              title: 'What Our Guests Say',
              subtitle: 'Real experiences from real guests',
              alignment: CrossAxisAlignment.center,
              actionLabel: 'All Reviews',
              onAction: () => context.go(RoutePaths.reviews),
            ),
            const SizedBox(height: AppSpacing.xl),
            reviewsAsync.when(
              loading: () => const CircularProgressIndicator(
                color: AppColors.accent,
              ),
              error: (e, _) => Text('Error: $e'),
              data: (reviews) => Wrap(
                spacing: AppSpacing.lg,
                runSpacing: AppSpacing.lg,
                alignment: WrapAlignment.center,
                children: reviews.take(3).map((review) {
                  return SizedBox(
                    width: Responsive.value(
                      context,
                      mobile: double.infinity,
                      tablet: 320.0,
                      desktop: 360.0,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Stars ──
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < review.rating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: AppColors.accent,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '"${review.comment}"',
                            style: AppTypography.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.accent,
                                child: Text(
                                  review.guestName[0],
                                  style: AppTypography.labelLarge.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                review.guestName,
                                style: AppTypography.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const NetworkImage(AppConstants.hotelPool),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.primary.withValues(alpha: 0.8),
            BlendMode.darken,
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Text(
              'Ready for an Unforgettable Stay?',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Book your room today and experience the finest hospitality '
              'at Sapphire Stay Hotel.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.white.withValues(alpha: 0.85),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.booking),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.md,
                ),
              ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  final IconData icon;
  final String title;
  final String description;
  const _ServiceItem(this.icon, this.title, this.description);
}
