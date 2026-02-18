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
import '../../../providers/providers.dart';

/// Admin staff management screen.
class AdminStaffManagementScreen extends ConsumerWidget {
  const AdminStaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final staffAsync = ref.watch(staffListProvider);

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
                    Text('Staff Management',
                        style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('Manage hotel staff accounts and roles.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Add Staff',
                icon: Icons.person_add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Add staff dialog coming soon.')),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: staffAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(staffListProvider),
            ),
            data: (staffList) {
              if (staffList.isEmpty) {
                return const SSEmptyState(
                  icon: Icons.badge_outlined,
                  title: 'No Staff Members',
                  description: 'Add your first staff member to get started.',
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
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: staffList.map((user) {
                        return DataRow(cells: [
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.accent,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: AppTypography.labelSmall
                                        .copyWith(color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(user.name),
                              ],
                            ),
                          ),
                          DataCell(Text(user.email)),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: user.role.name == 'admin'
                                    ? AppColors.accent.withValues(alpha: 0.1)
                                    : AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusFull),
                              ),
                              child: Text(
                                user.role.name.toUpperCase(),
                                style: AppTypography.labelSmall.copyWith(
                                  color: user.role.name == 'admin'
                                      ? AppColors.accent
                                      : AppColors.info,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('Active'),
                              ],
                            ),
                          ),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'role',
                                    child: Text('Change Role')),
                                PopupMenuItem(
                                    value: 'deactivate',
                                    child: Text('Deactivate')),
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete')),
                              ],
                              onSelected: (action) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '$action staff ${user.name}'),
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
