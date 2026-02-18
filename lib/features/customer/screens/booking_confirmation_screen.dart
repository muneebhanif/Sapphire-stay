import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';

/// Booking confirmation screen shown after successful submission.
class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxxl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            // ── Success Icon ──
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 56,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Booking Submitted!',
              style: AppTypography.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              'Thank you for your reservation. Your booking request has been '
              'submitted successfully. You will receive a confirmation email shortly.',
              style: AppTypography.bodyLarge.copyWith(height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Booking Reference ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Column(
                children: [
                  Text(
                    'Booking Reference',
                    style: AppTypography.labelMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'BK-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.accent,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Please save this reference number for your records.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── What's Next ──
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What's Next?", style: AppTypography.titleMedium),
                  const SizedBox(height: AppSpacing.md),
                  _buildStep('1', 'You will receive a confirmation email'),
                  _buildStep('2', 'Our team will verify room availability'),
                  _buildStep('3', 'You will receive a final booking confirmation'),
                  _buildStep('4', 'Present your booking reference at check-in'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Actions ──
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                SSButton(
                  label: 'Back to Home',
                  onPressed: () => context.go(RoutePaths.home),
                ),
                SSButton(
                  label: 'View Rooms',
                  variant: SSButtonVariant.secondary,
                  onPressed: () => context.go(RoutePaths.rooms),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accentDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}
