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

/// Admin dashboard with full overview.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final guestsAsync = ref.watch(guestsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Dashboard', style: AppTypography.headlineSmall),
          const SizedBox(height: 2),
          Text(
            'Complete hotel overview and management.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Stat Cards ──
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              _statBox(isDesktop, roomsAsync.whenOrNull(
                data: (rooms) => SSStatCard(
                  title: 'Total Rooms',
                  value: '${rooms.length}',
                  icon: Icons.king_bed_outlined,
                  color: AppColors.info,
                ),
              )),
              _statBox(isDesktop, bookingsAsync.whenOrNull(
                data: (bookings) => SSStatCard(
                  title: 'Bookings',
                  value: '${bookings.length}',
                  icon: Icons.book_outlined,
                  color: AppColors.accent,
                ),
              )),
              _statBox(isDesktop, guestsAsync.whenOrNull(
                data: (guests) => SSStatCard(
                  title: 'Guests',
                  value: '${guests.length}',
                  icon: Icons.people_outline,
                  color: AppColors.success,
                ),
              )),
              _statBox(isDesktop, paymentsAsync.whenOrNull(
                data: (payments) {
                  final total = payments.fold<double>(0, (s, p) => s + p.amount);
                  return SSStatCard(
                    title: 'Revenue',
                    value: '\$${total.toStringAsFixed(0)}',
                    icon: Icons.attach_money,
                    color: AppColors.warning,
                  );
                },
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Room Occupancy ──
          const SSSectionHeader(title: 'Room Occupancy'),
          const SizedBox(height: AppSpacing.md),
          roomsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.card),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(roomsProvider),
            ),
            data: (rooms) {
              final statusCounts = <String, int>{};
              for (final r in rooms) {
                statusCounts[r.status.name] =
                    (statusCounts[r.status.name] ?? 0) + 1;
              }
              return _buildOccupancyBar(statusCounts, rooms.length);
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
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(AppColors.surfaceVariant),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Guest')),
                      DataColumn(label: Text('Room')),
                      DataColumn(label: Text('Check-In')),
                      DataColumn(label: Text('Check-Out')),
                      DataColumn(label: Text('Total'), numeric: true),
                      DataColumn(label: Text('Status')),
                    ],
                    rows: bookings.take(5).map((b) {
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
                        DataCell(Text('\$${b.totalAmount.toStringAsFixed(2)}')),
                        DataCell(SSStatusChip.fromString(b.status.name)),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statBox(bool isDesktop, Widget? child) {
    return SizedBox(
      width: isDesktop ? 220 : double.infinity,
      child: child ??
          const SSStatCard(
            title: 'Loading...',
            value: '—',
            icon: Icons.hourglass_empty,
            color: AppColors.textTertiary,
          ),
    );
  }

  Widget _buildOccupancyBar(Map<String, int> counts, int total) {
    final colors = {
      'available': AppColors.success,
      'occupied': AppColors.warning,
      'reserved': AppColors.info,
      'maintenance': AppColors.error,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: SizedBox(
              height: 24,
              child: Row(
                children: counts.entries.map((e) {
                  return Expanded(
                    flex: e.value,
                    child: Container(
                      color: colors[e.key] ?? AppColors.textTertiary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Legend
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: counts.entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[e.key] ?? AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${e.key[0].toUpperCase()}${e.key.substring(1)}: ${e.value}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
