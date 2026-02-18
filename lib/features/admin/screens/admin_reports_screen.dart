import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_stat_card.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_section_header.dart';
import '../../../providers/providers.dart';

/// Admin reports and analytics screen.
class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final bookingsAsync = ref.watch(bookingsProvider);
    final paymentsAsync = ref.watch(paymentsProvider);
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reports & Analytics', style: AppTypography.headlineSmall),
          const SizedBox(height: 2),
          Text('Hotel performance insights and statistics.',
              style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.lg),

          // ── Key Metrics ──
          const SSSectionHeader(title: 'Key Metrics'),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              SizedBox(
                width: isDesktop ? 220 : double.infinity,
                child: roomsAsync.when(
                  loading: () => const SSStatCard(
                    title: 'Occupancy Rate',
                    value: '—',
                    icon: Icons.hotel,
                    color: AppColors.info,
                  ),
                  error: (_, __) => const SSStatCard(
                    title: 'Occupancy Rate',
                    value: 'Error',
                    icon: Icons.hotel,
                    color: AppColors.error,
                  ),
                  data: (rooms) {
                    final occupied =
                        rooms.where((r) => r.status.name == 'occupied').length;
                    final rate = rooms.isNotEmpty
                        ? (occupied / rooms.length * 100).toStringAsFixed(0)
                        : '0';
                    return SSStatCard(
                      title: 'Occupancy Rate',
                      value: '$rate%',
                      icon: Icons.hotel,
                      color: AppColors.info,
                    );
                  },
                ),
              ),
              SizedBox(
                width: isDesktop ? 220 : double.infinity,
                child: bookingsAsync.when(
                  loading: () => const SSStatCard(
                    title: 'Total Bookings',
                    value: '—',
                    icon: Icons.book,
                    color: AppColors.accent,
                  ),
                  error: (_, __) => const SSStatCard(
                    title: 'Total Bookings',
                    value: 'Error',
                    icon: Icons.book,
                    color: AppColors.error,
                  ),
                  data: (bookings) => SSStatCard(
                    title: 'Total Bookings',
                    value: '${bookings.length}',
                    icon: Icons.book,
                    color: AppColors.accent,
                  ),
                ),
              ),
              SizedBox(
                width: isDesktop ? 220 : double.infinity,
                child: paymentsAsync.when(
                  loading: () => const SSStatCard(
                    title: 'Total Revenue',
                    value: '—',
                    icon: Icons.attach_money,
                    color: AppColors.success,
                  ),
                  error: (_, __) => const SSStatCard(
                    title: 'Total Revenue',
                    value: 'Error',
                    icon: Icons.attach_money,
                    color: AppColors.error,
                  ),
                  data: (payments) {
                    final total =
                        payments.fold<double>(0, (s, p) => s + p.amount);
                    return SSStatCard(
                      title: 'Total Revenue',
                      value: '\$${total.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: AppColors.success,
                    );
                  },
                ),
              ),
              SizedBox(
                width: isDesktop ? 220 : double.infinity,
                child: bookingsAsync.when(
                  loading: () => const SSStatCard(
                    title: 'Avg. Stay',
                    value: '—',
                    icon: Icons.timelapse,
                    color: AppColors.warning,
                  ),
                  error: (_, __) => const SSStatCard(
                    title: 'Avg. Stay',
                    value: 'Error',
                    icon: Icons.timelapse,
                    color: AppColors.error,
                  ),
                  data: (bookings) {
                    final avg = bookings.isNotEmpty
                        ? (bookings.fold<int>(0, (s, b) => s + b.nights) /
                                bookings.length)
                            .toStringAsFixed(1)
                        : '0';
                    return SSStatCard(
                      title: 'Avg. Stay',
                      value: '$avg nights',
                      icon: Icons.timelapse,
                      color: AppColors.warning,
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // ── Room type breakdown ──
          const SSSectionHeader(title: 'Bookings by Room Type'),
          const SizedBox(height: AppSpacing.md),
          bookingsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.card),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(bookingsProvider),
            ),
            data: (bookings) {
              // Approximate grouping by room number convention
              final typeCounts = <String, int>{};
              for (final b in bookings) {
                final type = b.roomNumber.startsWith('1')
                    ? 'Standard'
                    : b.roomNumber.startsWith('2')
                        ? 'Deluxe'
                        : b.roomNumber.startsWith('3')
                            ? 'Suite'
                            : 'Presidential';
                typeCounts[type] = (typeCounts[type] ?? 0) + 1;
              }

              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: typeCounts.entries.map((e) {
                    final pct = (e.value / bookings.length * 100)
                        .toStringAsFixed(0);
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(e.key,
                                style: AppTypography.bodyMedium),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull),
                              child: LinearProgressIndicator(
                                value: e.value / bookings.length,
                                minHeight: 20,
                                backgroundColor:
                                    AppColors.surfaceVariant,
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${e.value} ($pct%)',
                              style: AppTypography.bodySmall,
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xxl),

          // ── Revenue chart placeholder ──
          const SSSectionHeader(title: 'Revenue Trend'),
          const SizedBox(height: AppSpacing.md),
          Container(
            height: 260,
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bar_chart,
                      size: 48, color: AppColors.textTertiary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Chart Placeholder',
                    style: AppTypography.titleMedium
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Integrate fl_chart or syncfusion_flutter_charts for interactive charts.',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
