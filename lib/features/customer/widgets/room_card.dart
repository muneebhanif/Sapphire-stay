import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_card.dart';
import '../../../models/room.dart';

/// Room card optimized for the customer-facing room listing.
///
/// Shows image, name, type badge, price, capacity, and key amenities.
/// Tapping navigates to the room detail page.
class RoomCard extends StatelessWidget {
  final Room room;

  const RoomCard({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return SSCard(
      imageUrl: room.imageUrls.isNotEmpty ? room.imageUrls.first : null,
      badges: [
        SSBadge(label: room.typeLabel),
        if (room.isFeatured)
          const SSBadge(
            label: 'Featured',
            backgroundColor: AppColors.primary,
            textColor: AppColors.accent,
          ),
      ],
      onTap: () => context.go('/rooms/${room.id}'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Room Name ──
          Text(
            room.name,
            style: AppTypography.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),

          // ── Description preview ──
          Text(
            room.description,
            style: AppTypography.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Amenities (first 3) ──
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xxs,
            children: room.amenities
                .take(3)
                .map(
                  (a) => Chip(
                    label: Text(a, style: AppTypography.labelSmall),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Price & Capacity ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '\$${room.pricePerNight.toStringAsFixed(0)}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    TextSpan(
                      text: ' / night',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),

              // Capacity
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${room.capacity} Guests',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
