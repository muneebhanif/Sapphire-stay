import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../providers/providers.dart';

/// Room detail page with full description, gallery, amenities,
/// and booking CTA.
class RoomDetailScreen extends ConsumerWidget {
  final String roomId;

  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomDetailProvider(roomId));

    return roomAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: SSLoading(type: SSLoadingType.detail),
      ),
      error: (e, _) => SSErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(roomDetailProvider(roomId)),
      ),
      data: (room) {
        final isDesktop = Responsive.isDesktop(context);

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Breadcrumb ──
                Row(
                  children: [
                    InkWell(
                      onTap: () => context.go(RoutePaths.rooms),
                      child: Text(
                        'Rooms',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      child: Icon(Icons.chevron_right,
                          size: 16, color: AppColors.textTertiary),
                    ),
                    Text(room.name, style: AppTypography.bodyMedium),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Image ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  child: Image.network(
                    room.imageUrls.isNotEmpty ? room.imageUrls.first : '',
                    height: isDesktop ? 500 : 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: isDesktop ? 500 : 300,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.image_not_supported, size: 64),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Content ──
                isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildDetails(room)),
                          const SizedBox(width: AppSpacing.xxl),
                          Expanded(flex: 1, child: _buildBookingCard(context, room)),
                        ],
                      )
                    : Column(
                        children: [
                          _buildDetails(room),
                          const SizedBox(height: AppSpacing.lg),
                          _buildBookingCard(context, room),
                        ],
                      ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetails(dynamic room) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Type Badge + Name ──
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Text(
            room.typeLabel,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.accentDark,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(room.name, style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.md),

        // ── Quick Info ──
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _buildInfoItem(Icons.square_foot, '${room.sizeInSqFt.toInt()} sq ft'),
            _buildInfoItem(Icons.person_outline, 'Up to ${room.capacity} guests'),
            _buildInfoItem(Icons.layers_outlined, 'Floor ${room.floor}'),
            _buildInfoItem(Icons.meeting_room_outlined, 'Room ${room.number}'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const Divider(),
        const SizedBox(height: AppSpacing.lg),

        // ── Description ──
        Text('About This Room', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(
          room.description,
          style: AppTypography.bodyLarge.copyWith(height: 1.8),
        ),
        const SizedBox(height: AppSpacing.lg),

        // ── Amenities ──
        Text('Amenities', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: room.amenities
              .map<Widget>(
                (a) => Chip(
                  avatar: const Icon(Icons.check_circle,
                      size: 16, color: AppColors.success),
                  label: Text(a),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, dynamic room) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Price ──
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$${room.pricePerNight.toStringAsFixed(0)}',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                TextSpan(
                  text: ' / night',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),

          // ── Summary ──
          _buildSummaryRow('Room Type', room.typeLabel),
          _buildSummaryRow('Max Guests', '${room.capacity}'),
          _buildSummaryRow('Room Size', '${room.sizeInSqFt.toInt()} sq ft'),
          const SizedBox(height: AppSpacing.lg),

          // ── CTA ──
          SSButton(
            label: 'Book This Room',
            isExpanded: true,
            size: SSButtonSize.large,
            onPressed: () => context.go(RoutePaths.booking),
          ),
          const SizedBox(height: AppSpacing.xs),
          SSButton(
            label: 'Contact Us',
            variant: SSButtonVariant.secondary,
            isExpanded: true,
            onPressed: () => context.go(RoutePaths.contact),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xxs),
        Text(text, style: AppTypography.bodyMedium),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          Text(value, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
