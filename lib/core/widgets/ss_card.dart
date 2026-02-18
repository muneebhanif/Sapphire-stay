import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable card component with optional image, title, subtitle,
/// and action area.
///
/// Designed for room listings, service cards, and dashboard summaries.
class SSCard extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? subtitle;
  final Widget? body;
  final Widget? footer;
  final VoidCallback? onTap;
  final double? width;
  final double imageHeight;
  final EdgeInsets padding;
  final List<Widget>? badges;

  const SSCard({
    super.key,
    this.imageUrl,
    this.title,
    this.subtitle,
    this.body,
    this.footer,
    this.onTap,
    this.width,
    this.imageHeight = AppSpacing.cardImageHeight,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.badges,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Image ──
              if (imageUrl != null)
                Stack(
                  children: [
                    _buildImage(),
                    if (badges != null && badges!.isNotEmpty)
                      Positioned(
                        top: AppSpacing.sm,
                        left: AppSpacing.sm,
                        child: Wrap(
                          spacing: AppSpacing.xxs,
                          children: badges!,
                        ),
                      ),
                  ],
                ),

              // ── Content ──
              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: AppTypography.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle!,
                        style: AppTypography.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (body != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      body!,
                    ],
                    if (footer != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      footer!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        image: DecorationImage(
          image: NetworkImage(imageUrl!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Small badge chip used on cards (e.g., "Popular", "Best Value").
class SSBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const SSBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.accent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor ?? AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
