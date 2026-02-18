import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../services/mock/mock_data.dart';

/// Hotel & room image gallery with lightbox overlay.
class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final images = MockData.galleryImages;
    final columns = Responsive.value(context, mobile: 2, tablet: 3, desktop: 4);

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
                'GALLERY',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Visual Tour',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Explore our hotel through stunning images',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        // ── Grid ──
        Padding(
          padding: EdgeInsets.all(Responsive.pagePadding(context)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.2,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return _GalleryItem(
                  imageUrl: img['url']!,
                  caption: img['caption']!,
                  onTap: () => _showLightbox(context, images, index),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  void _showLightbox(
    BuildContext context,
    List<Map<String, String>> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      builder: (context) => _GalleryLightbox(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _GalleryItem extends StatelessWidget {
  final String imageUrl;
  final String caption;
  final VoidCallback onTap;

  const _GalleryItem({
    required this.imageUrl,
    required this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceVariant,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
            // ── Gradient overlay ──
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  caption,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            // ── Hover zoom icon ──
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.zoom_in,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryLightbox extends StatefulWidget {
  final List<Map<String, String>> images;
  final int initialIndex;

  const _GalleryLightbox({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_GalleryLightbox> createState() => _GalleryLightboxState();
}

class _GalleryLightboxState extends State<_GalleryLightbox> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final img = widget.images[_currentIndex];

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: Stack(
        children: [
          // ── Image ──
          Center(
            child: Image.network(
              img['url']!,
              fit: BoxFit.contain,
            ),
          ),

          // ── Caption ──
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            child: Text(
              img['caption']!,
              textAlign: TextAlign.center,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
          ),

          // ── Close ──
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // ── Previous ──
          if (_currentIndex > 0)
            Positioned(
              left: AppSpacing.sm,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
                  onPressed: () => setState(() => _currentIndex--),
                ),
              ),
            ),

          // ── Next ──
          if (_currentIndex < widget.images.length - 1)
            Positioned(
              right: AppSpacing.sm,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios,
                      color: AppColors.white),
                  onPressed: () => setState(() => _currentIndex++),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
