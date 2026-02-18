import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_stat_card.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_section_header.dart';
import '../../../providers/providers.dart';

/// Staff dashboard overview.
class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);
    final roomsAsync = ref.watch(roomsProvider);
    final isDesktop = Responsive.isDesktop(context);
    final cols = Responsive.gridColumns(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard', style: AppTypography.headlineSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Welcome back! Here\'s what\'s happening today.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Stats row ──
          roomsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.card),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(roomsProvider),
            ),
            data: (rooms) {
              final available = rooms.where((r) => r.status.name == 'available').length;
              final occupied = rooms.where((r) => r.status.name == 'occupied').length;
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: [
                  SizedBox(
                    width: isDesktop ? 240 : double.infinity,
                    child: SSStatCard(
                      title: 'Total Rooms',
                      value: '${rooms.length}',
                      icon: Icons.king_bed_outlined,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? 240 : double.infinity,
                    child: SSStatCard(
                      title: 'Available',
                      value: '$available',
                      icon: Icons.check_circle_outline,
                      color: AppColors.success,
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? 240 : double.infinity,
                    child: SSStatCard(
                      title: 'Occupied',
                      value: '$occupied',
                      icon: Icons.do_not_disturb_on_outlined,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Recent Bookings ──
          const SSSectionHeader(title: 'Recent Bookings'),
          const SizedBox(height: AppSpacing.md),

          bookingsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(bookingsProvider),
            ),
            data: (bookings) {
              final recent = bookings.take(5).toList();
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      AppColors.surfaceVariant,
                    ),
                    columns: const [
                      DataColumn(label: Text('Booking ID')),
                      DataColumn(label: Text('Guest')),
                      DataColumn(label: Text('Room')),
                      DataColumn(label: Text('Check-In')),
                      DataColumn(label: Text('Check-Out')),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: recent.map((b) {
                      return DataRow(cells: [
                        DataCell(Text(
                          b.id.substring(0, 8),
                          style: AppTypography.bodySmall
                              .copyWith(fontFamily: 'monospace'),
                        )),
                        DataCell(Text(b.guestName)),
                        DataCell(Text(b.roomNumber)),
                        DataCell(Text(_fmtDate(b.checkIn))),
                        DataCell(Text(_fmtDate(b.checkOut))),
                        DataCell(SSStatusChip.fromString(b.status.name)),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Room Status ──
          const SSSectionHeader(title: 'Room Status'),
          const SizedBox(height: AppSpacing.md),
          roomsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.card),
            error: (e, _) => const SizedBox.shrink(),
            data: (rooms) {
              return Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.md,
                children: rooms.map((room) {
                  return Container(
                    width: isDesktop ? 200 : (MediaQuery.of(context).size.width - 3 * AppSpacing.lg) / 2,
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
                            Text(
                              room.number,
                              style: AppTypography.titleMedium,
                            ),
                            SSStatusChip.fromString(room.status.name),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          room.type.name.toUpperCase(),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
