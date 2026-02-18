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
import '../../../providers/providers.dart';

/// Admin invoice management screen.
class AdminInvoiceScreen extends ConsumerWidget {
  const AdminInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoicesAsync = ref.watch(invoicesProvider);

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
                    Text('Invoice Management',
                        style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('View, create, and manage all invoices.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Create Invoice',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Create invoice dialog coming soon.')),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: invoicesAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(invoicesProvider),
            ),
            data: (invoices) {
              if (invoices.isEmpty) {
                return const SSEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Invoices',
                  description: 'No invoices have been created yet.',
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
                        DataColumn(label: Text('Invoice #')),
                        DataColumn(label: Text('Guest')),
                        DataColumn(label: Text('Booking')),
                        DataColumn(label: Text('Issued')),
                        DataColumn(label: Text('Due')),
                        DataColumn(label: Text('Items')),
                        DataColumn(label: Text('Total'), numeric: true),
                        DataColumn(label: Text('Tax'), numeric: true),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: invoices.map((inv) {
                        return DataRow(cells: [
                          DataCell(Text(
                            inv.id.substring(0, 8),
                            style: AppTypography.bodySmall
                                .copyWith(fontFamily: 'monospace'),
                          )),
                          DataCell(Text(inv.guestName)),
                          DataCell(Text(inv.bookingId.substring(0, 8))),
                          DataCell(Text(_fmtDate(inv.issueDate))),
                          DataCell(Text(inv.dueDate != null ? _fmtDate(inv.dueDate!) : '—')),
                          DataCell(Text('${inv.lineItems.length}')),
                          DataCell(Text(
                            '\$${inv.total.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.w600),
                          )),
                          DataCell(
                              Text('\$${inv.tax.toStringAsFixed(2)}')),
                          DataCell(SSStatusChip.fromString(inv.status.name)),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'view', child: Text('View')),
                                PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                PopupMenuItem(
                                    value: 'print', child: Text('Print')),
                                PopupMenuItem(
                                    value: 'markPaid',
                                    child: Text('Mark as Paid')),
                                PopupMenuItem(
                                    value: 'void', child: Text('Void')),
                              ],
                              onSelected: (action) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '$action invoice ${inv.id.substring(0, 8)}'),
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

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
