import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../models/guest.dart';
import '../../../providers/providers.dart';

/// Admin guest management screen.
class AdminGuestManagementScreen extends ConsumerWidget {
  const AdminGuestManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guestsAsync = ref.watch(guestsProvider);

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
                    Text('Guest Management', style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('View and manage guest profiles.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Add Guest',
                icon: Icons.person_add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add guest dialog coming soon.')),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: guestsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(guestsProvider),
            ),
            data: (guests) {
              if (guests.isEmpty) {
                return const SSEmptyState(
                  icon: Icons.people_outline,
                  title: 'No Guests',
                  description: 'No guest records found.',
                );
              }

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
                      headingRowColor:
                          WidgetStateProperty.all(AppColors.surfaceVariant),
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Phone')),
                        DataColumn(label: Text('Nationality')),
                        DataColumn(label: Text('Total Stays'), numeric: true),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: guests.map((g) {
                        return DataRow(cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    g.name.isNotEmpty
                                        ? g.name[0].toUpperCase()
                                        : '?',
                                    style: AppTypography.labelSmall
                                        .copyWith(color: AppColors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(g.name),
                              ],
                            ),
                          ),
                          DataCell(Text(g.email)),
                          DataCell(Text(g.phone)),
                          DataCell(Text(g.nationality ?? '—')),
                          DataCell(Text('${g.totalStays}')),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'view', child: Text('View Profile')),
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'bookings',
                                    child: Text('View Bookings')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Delete')),
                              ],
                              onSelected: (action) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('$action guest ${g.name}'),
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
            },
          ),
        ),
      ],
    );
  }
}
