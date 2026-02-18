import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Shimmer loading placeholder for content areas.
///
/// Provides a polished loading experience instead of
/// a generic spinner. Matches the shape of the content
/// it replaces for smooth visual transitions.
class SSLoading extends StatelessWidget {
  final SSLoadingType type;
  final int itemCount;

  const SSLoading({
    super.key,
    this.type = SSLoadingType.card,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.offWhite,
      child: switch (type) {
        SSLoadingType.card => _buildCardShimmer(),
        SSLoadingType.list => _buildListShimmer(),
        SSLoadingType.table => _buildTableShimmer(),
        SSLoadingType.detail => _buildDetailShimmer(),
      },
    );
  }

  Widget _buildCardShimmer() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: List.generate(
        itemCount,
        (_) => Container(
          width: AppSpacing.maxCardWidth,
          height: 300,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
    );
  }

  Widget _buildListShimmer() {
    return Column(
      children: List.generate(
        itemCount,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableShimmer() {
    return Column(
      children: List.generate(
        itemCount + 1,
        (i) => Container(
          height: i == 0 ? 48 : 56,
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 1),
          color: AppColors.white,
        ),
      ),
    );
  }

  Widget _buildDetailShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.white,
        ),
        const SizedBox(height: AppSpacing.md),
        Container(height: 24, width: 200, color: AppColors.white),
        const SizedBox(height: AppSpacing.sm),
        Container(height: 16, width: double.infinity, color: AppColors.white),
        const SizedBox(height: AppSpacing.xs),
        Container(height: 16, width: 300, color: AppColors.white),
      ],
    );
  }
}

enum SSLoadingType { card, list, table, detail }
