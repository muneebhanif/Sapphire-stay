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
import '../../../models/room.dart';
import '../../../providers/providers.dart';

/// Admin room management — CRUD operations on rooms.
class AdminRoomManagementScreen extends ConsumerWidget {
  const AdminRoomManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Management', style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('Manage hotel rooms, status, and pricing.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Add Room',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add room dialog coming soon.')),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: roomsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(roomsProvider),
            ),
            data: (rooms) {
              if (rooms.isEmpty) {
                return const SSEmptyState(
                  icon: Icons.king_bed_outlined,
                  title: 'No Rooms',
                  description: 'Add your first room to get started.',
                );
              }

              if (isDesktop) {
                return _buildTable(context, rooms);
              }

              return _buildCards(context, rooms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTable(BuildContext context, List<Room> rooms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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
              DataColumn(label: Text('Room #')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Floor')),
              DataColumn(label: Text('Capacity')),
              DataColumn(label: Text('Price/Night'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Amenities')),
              DataColumn(label: Text('Actions')),
            ],
            rows: rooms.map((r) {
              return DataRow(cells: [
                DataCell(Text(r.number, style: AppTypography.titleSmall)),
                DataCell(Text(r.type.name.toUpperCase())),
                DataCell(Text('${r.floor}')),
                DataCell(Text('${r.capacity}')),
                DataCell(Text('\$${r.pricePerNight.toStringAsFixed(0)}')),
                DataCell(SSStatusChip.fromString(r.status.name)),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      r.amenities.take(3).join(', '),
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'status', child: Text('Change Status')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (action) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$action room ${r.number}')),
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
  }

  Widget _buildCards(BuildContext context, List<Room> rooms) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: rooms.length,
      itemBuilder: (_, i) {
        final r = rooms[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                  Text('Room ${r.number}', style: AppTypography.titleMedium),
                  SSStatusChip.fromString(r.status.name),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('${r.type.name.toUpperCase()} • Floor ${r.floor} • Up to ${r.capacity} guests',
                  style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('\$${r.pricePerNight.toStringAsFixed(0)} / night',
                  style: AppTypography.titleSmall.copyWith(color: AppColors.accent)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: r.amenities.take(4).map((a) {
                  return Chip(
                    label: Text(a, style: const TextStyle(fontSize: 10)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
