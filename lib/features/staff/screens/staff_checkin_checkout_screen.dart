import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../models/booking.dart';
import '../../../providers/providers.dart';

/// Check-in / check-out management screen.
class StaffCheckinCheckoutScreen extends ConsumerWidget {
  const StaffCheckinCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final isDesktop = Responsive.isDesktop(context);

    return bookingsAsync.when(
      loading: () => const SSLoading(type: SSLoadingType.table),
      error: (e, _) => SSErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(bookingsProvider),
      ),
      data: (bookings) {
        final checkinReady = bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList();
        final checkoutReady = bookings
            .where((b) => b.status == BookingStatus.checkedIn)
            .toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check-In / Check-Out', style: AppTypography.headlineSmall),
              const SizedBox(height: 2),
              Text(
                'Manage guest arrivals and departures.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Ready for Check-In ──
              _buildSection(
                context,
                title: 'Ready for Check-In',
                icon: Icons.login,
                color: AppColors.success,
                bookings: checkinReady,
                actionLabel: 'Check In',
                actionIcon: Icons.how_to_reg,
                emptyMessage: 'No bookings ready for check-in.',
                isDesktop: isDesktop,
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ── Ready for Check-Out ──
              _buildSection(
                context,
                title: 'Ready for Check-Out',
                icon: Icons.logout,
                color: AppColors.warning,
                bookings: checkoutReady,
                actionLabel: 'Check Out',
                actionIcon: Icons.exit_to_app,
                emptyMessage: 'No guests to check out.',
                isDesktop: isDesktop,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<Booking> bookings,
    required String actionLabel,
    required IconData actionIcon,
    required String emptyMessage,
    required bool isDesktop,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: AppTypography.titleLarge),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Text(
                '${bookings.length}',
                style: AppTypography.labelSmall.copyWith(color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        if (bookings.isEmpty)
          SSEmptyState(
            icon: icon,
            title: emptyMessage,
          )
        else
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: bookings.map((b) {
              return Container(
                width: isDesktop ? 360 : double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(b.guestName, style: AppTypography.titleSmall),
                        SSStatusChip.fromString(b.status.name),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
                    _infoRow('Room', b.roomNumber),
                    _infoRow('Check-In', _fmtDate(b.checkIn)),
                    _infoRow('Check-Out', _fmtDate(b.checkOut)),
                    _infoRow('Nights', '${b.nights}'),
                    _infoRow('Total', '\$${b.totalAmount.toStringAsFixed(2)}'),
                    const SizedBox(height: AppSpacing.md),
                    SSButton(
                      label: actionLabel,
                      icon: actionIcon,
                      isExpanded: true,
                      size: SSButtonSize.small,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '$actionLabel completed for ${b.guestName}',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
