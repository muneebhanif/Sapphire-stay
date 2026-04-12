import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';

import '../../../core/utils/currency_utils.dart';

/// Booking confirmation screen shown after successful submission.
class BookingConfirmationScreen extends StatelessWidget {
  final int? totalPkr;
  final int? guestsCount;
  final String? roomName;
  final String? guestName;

  const BookingConfirmationScreen({
    super.key,
    this.totalPkr,
    this.guestsCount,
    this.roomName,
    this.guestName,
  });

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
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  if (guestName != null) ...[
                    _buildInvoiceRow('Guest Name:', guestName!),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  if (roomName != null) ...[
                    _buildInvoiceRow('Room:', roomName!),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  if (guestsCount != null) ...[
                    _buildInvoiceRow('Guests:', '$guestsCount'),
                    const SizedBox(height: AppSpacing.xs),
                  ],
                  if (totalPkr != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _buildInvoiceRow('Total Amount:', CurrencyUtils.formatPkr(totalPkr!), isHighlight: true),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pending_actions, color: AppColors.error, size: 20),
                          SizedBox(width: AppSpacing.sm),
                          Text('Payment Verification Pending', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
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
                  _buildStep('1', 'Your payment proof will be verified by staff'),
                  _buildStep('2', 'Once verified, your booking will be confirmed'),
                  _buildStep('3', 'An invoice will be generated and sent via notification'),
                  _buildStep('4', 'You can track progress in your profile drawer'),
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

  Widget _buildInvoiceRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(
          value,
          style: TextStyle(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight ? AppColors.accent : null,
            fontSize: isHighlight ? 16 : null,
          ),
        ),
      ],
    );
  }
}
