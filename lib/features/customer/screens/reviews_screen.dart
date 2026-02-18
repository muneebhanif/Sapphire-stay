import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../models/review.dart';
import '../../../providers/providers.dart';

/// Reviews page showing guest reviews.
class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider);

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
                'TESTIMONIALS',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Guest Reviews',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'What our guests say about their experience',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        // ── Reviews List ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.xxl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: reviewsAsync.when(
              loading: () => const SSLoading(type: SSLoadingType.list),
              error: (e, _) => SSErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(reviewsProvider),
              ),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const SSEmptyState(
                    icon: Icons.rate_review_outlined,
                    title: 'No Reviews Yet',
                    description: 'Be the first guest to leave a review!',
                  );
                }
                return Column(
                  children: [
                    // ── Average rating summary ──
                    _buildRatingSummary(reviews),
                    const SizedBox(height: AppSpacing.xxl),
                    // ── Individual reviews ──
                    ...reviews.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _ReviewCard(review: r),
                    )),
                  ],
                );
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildRatingSummary(List<Review> reviews) {
    final avg = reviews.fold<double>(
          0,
          (sum, r) => sum + r.rating,
        ) /
        reviews.length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: AppTypography.displayMedium.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < avg.round() ? Icons.star : Icons.star_border,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                '${reviews.length} review${reviews.length != 1 ? 's' : ''}',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primary,
                child: Text(
                  review.guestName.isNotEmpty
                      ? review.guestName[0].toUpperCase()
                      : '?',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.guestName, style: AppTypography.titleSmall),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: AppColors.accent,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _formatDate(review.createdAt),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(review.comment, style: AppTypography.bodyMedium),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
