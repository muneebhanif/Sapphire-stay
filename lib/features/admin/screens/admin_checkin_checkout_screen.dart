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

/// Admin check-in / check-out management.
class AdminCheckinCheckoutScreen extends ConsumerWidget {
  const AdminCheckinCheckoutScreen({super.key});

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
        final arrivals =
            bookings.where((b) => b.status == BookingStatus.confirmed).toList();
        final departures =
            bookings.where((b) => b.status == BookingStatus.checkedIn).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Check-In / Check-Out', style: AppTypography.headlineSmall),
              const SizedBox(height: 2),
              Text(
                'Manage arrivals and departures across the hotel.',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Summary cards ──
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  _summaryCard(
                    'Arrivals Today',
                    '${arrivals.length}',
                    Icons.login,
                    AppColors.success,
                    isDesktop,
                  ),
                  _summaryCard(
                    'Departures Today',
                    '${departures.length}',
                    Icons.logout,
                    AppColors.warning,
                    isDesktop,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Arrivals table ──
              Text('Pending Arrivals', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.md),
              _buildBookingTable(context, arrivals, 'Check In', Icons.how_to_reg),

              const SizedBox(height: AppSpacing.xxl),

              // ── Departures table ──
              Text('Pending Departures', style: AppTypography.titleLarge),
              const SizedBox(height: AppSpacing.md),
              _buildBookingTable(
                  context, departures, 'Check Out', Icons.exit_to_app),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDesktop,
  ) {
    return Container(
      width: isDesktop ? 260 : double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodySmall),
              Text(value,
                  style: AppTypography.headlineMedium
                      .copyWith(color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingTable(
    BuildContext context,
    List<Booking> bookings,
    String actionLabel,
    IconData actionIcon,
  ) {
    if (bookings.isEmpty) {
      return SSEmptyState(
        icon: actionIcon,
        title: 'No ${actionLabel == 'Check In' ? 'arrivals' : 'departures'} pending.',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
          columns: const [
            DataColumn(label: Text('Guest')),
            DataColumn(label: Text('Room')),
            DataColumn(label: Text('Check-In')),
            DataColumn(label: Text('Check-Out')),
            DataColumn(label: Text('Nights')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Action')),
          ],
          rows: bookings.map((b) {
            return DataRow(cells: [
              DataCell(Text(b.guestName)),
              DataCell(Text(b.roomNumber)),
              DataCell(Text(_fmtDate(b.checkIn))),
              DataCell(Text(_fmtDate(b.checkOut))),
              DataCell(Text('${b.nights}')),
              DataCell(SSStatusChip.fromString(b.status.name)),
              DataCell(
                SSButton(
                  label: actionLabel,
                  icon: actionIcon,
                  size: SSButtonSize.small,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('$actionLabel completed for ${b.guestName}'),
                      ),
                    );
                  },
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
