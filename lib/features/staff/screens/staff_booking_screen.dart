import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../models/booking.dart';
import '../../../providers/providers.dart';
import '../../admin/widgets/add_booking_dialog.dart';

/// Staff bookings management screen.
class StaffBookingScreen extends ConsumerStatefulWidget {
  const StaffBookingScreen({super.key});

  @override
  ConsumerState<StaffBookingScreen> createState() => _StaffBookingScreenState();
}

class _StaffBookingScreenState extends ConsumerState<StaffBookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  final _tabs = const ['All', 'Pending', 'Confirmed', 'Checked In', 'Completed', 'Cancelled'];

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
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bookings', style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Manage guest bookings',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              SSButton(
                label: 'New Booking',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddBookingDialog(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Tabs ──
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

        // ── Content ──
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
                          final statusMap = {
                            'Pending': 'pending',
                            'Confirmed': 'confirmed',
                            'Checked In': 'checkedIn',
                            'Completed': 'completed',
                            'Cancelled': 'cancelled',
                          };
                          return b.status.name == statusMap[tab];
                        }).toList();

                  if (filtered.isEmpty) {
                    return const SSEmptyState(
                      icon: Icons.book_outlined,
                      title: 'No Bookings',
                      description: 'No bookings found in this category.',
                    );
                  }

                  return _buildBookingTable(filtered);
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingTable(List<Booking> bookings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Container(
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
              DataColumn(label: Text('Booking ID')),
              DataColumn(label: Text('Guest')),
              DataColumn(label: Text('Room')),
              DataColumn(label: Text('Check-In')),
              DataColumn(label: Text('Check-Out')),
              DataColumn(label: Text('Nights')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: bookings.map((b) {
              return DataRow(cells: [
                DataCell(Text(
                  b.id.substring(0, 8),
                  style: AppTypography.bodySmall.copyWith(fontFamily: 'monospace'),
                )),
                DataCell(Text(b.guestName)),
                DataCell(Text(b.roomNumber)),
                DataCell(Text(_fmtDate(b.checkIn))),
                DataCell(Text(_fmtDate(b.checkOut))),
                DataCell(Text('${b.nights}')),
                DataCell(Text(CurrencyUtils.formatPkr(b.totalAmount.round()))),
                DataCell(SSStatusChip.fromString(b.status.name)),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      if (b.status == BookingStatus.pending)
                        const PopupMenuItem(value: 'confirm', child: Text('Confirm')),
                      if (b.status == BookingStatus.confirmed)
                        const PopupMenuItem(value: 'checkin', child: Text('Check In')),
                      if (b.status == BookingStatus.checkedIn)
                        const PopupMenuItem(value: 'checkout', child: Text('Check Out')),
                      if (b.status != BookingStatus.cancelled &&
                          b.status != BookingStatus.completed)
                        const PopupMenuItem(value: 'cancel', child: Text('Cancel')),
                    ],
                    onSelected: (action) async {
                      if (action == 'view') {
                        _showBookingViewDialog(context, b);
                      } else if (action == 'confirm') {
                        await ref.read(bookingServiceProvider).updateBookingStatus(b.id, BookingStatus.confirmed);
                        _invalidateBookings(ref);
                      } else if (action == 'checkin') {
                        await ref.read(bookingServiceProvider).updateBookingStatus(b.id, BookingStatus.checkedIn);
                        _invalidateBookings(ref);
                      } else if (action == 'checkout') {
                        await ref.read(bookingServiceProvider).updateBookingStatus(b.id, BookingStatus.completed);
                        _invalidateBookings(ref);
                      } else if (action == 'cancel') {
                        await ref.read(bookingServiceProvider).updateBookingStatus(b.id, BookingStatus.cancelled);
                        _invalidateBookings(ref);
                      }
                    },
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _showBookingViewDialog(BuildContext context, Booking b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Booking ${b.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest: ${b.guestName}'),
              Text('Room ID: ${b.roomId}'),
              Text('Status: ${b.status.name.toUpperCase()}'),
              Text('Check-in: ${_fmtDate(b.checkIn)}'),
              Text('Check-out: ${_fmtDate(b.checkOut)}'),
              Text('Nights: ${b.nights}'),
              Text('Guests: ${b.guests}'),
              const SizedBox(height: 10),
              Text('Total Amount: PKR ${b.totalAmount.round()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
        ],
      ),
    );
  }

  void _invalidateBookings(WidgetRef ref) {
    ref.invalidate(todayCheckInsProvider);
    ref.invalidate(todayCheckOutsProvider);
    ref.invalidate(allBookingsProvider);
  }
}

