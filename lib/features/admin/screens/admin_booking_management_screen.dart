import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../models/booking.dart';
import '../../../providers/providers.dart';

/// Admin booking management screen with full CRUD.
class AdminBookingManagementScreen extends ConsumerStatefulWidget {
  const AdminBookingManagementScreen({super.key});

  @override
  ConsumerState<AdminBookingManagementScreen> createState() =>
      _AdminBookingManagementScreenState();
}

class _AdminBookingManagementScreenState
    extends ConsumerState<AdminBookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _tabs = const [
    'All',
    'Pending',
    'Confirmed',
    'Checked In',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Booking Management',
                        style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('View, manage and modify all bookings.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'New Booking',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('New booking dialog coming soon.')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: AppTypography.labelMedium,
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(
          child: bookingsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(bookingsProvider),
            ),
            data: (bookings) {
              return TabBarView(
                controller: _tabCtrl,
                children: _tabs.map((tab) {
                  final filtered = tab == 'All'
                      ? bookings
                      : bookings.where((b) {
                          final map = {
                            'Pending': 'pending',
                            'Confirmed': 'confirmed',
                            'Checked In': 'checkedIn',
                            'Completed': 'completed',
                            'Cancelled': 'cancelled',
                          };
                          return b.status.name == map[tab];
                        }).toList();

                  if (filtered.isEmpty) {
                    return const SSEmptyState(
                      icon: Icons.book_outlined,
                      title: 'No Bookings',
                      description: 'No bookings in this category.',
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
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
                            DataColumn(label: Text('Nights')),
                            DataColumn(label: Text('Total'), numeric: true),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: filtered.map((b) {
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
                              DataCell(Text('${b.nights}')),
                              DataCell(Text(
                                '\$${b.totalAmount.toStringAsFixed(2)}',
                              )),
                              DataCell(SSStatusChip.fromString(b.status.name)),
                              DataCell(
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, size: 18),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'view',
                                        child: Text('View Details')),
                                    const PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
                                    if (b.status != BookingStatus.cancelled &&
                                        b.status != BookingStatus.completed)
                                      const PopupMenuItem(
                                          value: 'cancel',
                                          child: Text('Cancel')),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete')),
                                  ],
                                  onSelected: (action) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '$action booking ${b.id.substring(0, 8)}'),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
