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

/// Admin payments screen.
class AdminPaymentScreen extends ConsumerWidget {
  const AdminPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);

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
                    Text('Payment Management',
                        style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('Track all payments and transactions.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Record Payment',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Record payment dialog coming soon.')),
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: paymentsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(paymentsProvider),
            ),
            data: (payments) {
              if (payments.isEmpty) {
                return const SSEmptyState(
                  icon: Icons.payment_outlined,
                  title: 'No Payments',
                  description: 'No payments have been recorded yet.',
                );
              }

              // ── Summary ──
              final totalAmount =
                  payments.fold<double>(0, (s, p) => s + p.amount);

              return Column(
                children: [
                  // Summary bar
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet,
                            color: AppColors.success),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Total Collected: ',
                            style: AppTypography.bodyMedium),
                        Text(
                          '\$${totalAmount.toStringAsFixed(2)}',
                          style: AppTypography.titleMedium
                              .copyWith(color: AppColors.success),
                        ),
                        const Spacer(),
                        Text(
                          '${payments.length} transaction(s)',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Table
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
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
                            headingRowColor: WidgetStateProperty.all(
                                AppColors.surfaceVariant),
                            columns: const [
                              DataColumn(label: Text('Payment ID')),
                              DataColumn(label: Text('Invoice')),
                              DataColumn(label: Text('Guest')),
                              DataColumn(label: Text('Method')),
                              DataColumn(
                                  label: Text('Amount'), numeric: true),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: payments.map((p) {
                              return DataRow(cells: [
                                DataCell(Text(
                                  p.id.substring(0, 8),
                                  style: AppTypography.bodySmall
                                      .copyWith(fontFamily: 'monospace'),
                                )),
                                DataCell(
                                    Text(p.invoiceId.substring(0, 8))),
                                DataCell(Text(p.guestName)),
                                DataCell(Text(_methodLabel(p.method.name))),
                                DataCell(Text(
                                  '\$${p.amount.toStringAsFixed(2)}',
                                  style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600),
                                )),
                                DataCell(Text(_fmtDate(p.paidAt))),
                                DataCell(
                                    SSStatusChip.fromString(p.status.name)),
                                DataCell(
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert,
                                        size: 18),
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                          value: 'view',
                                          child: Text('View Receipt')),
                                      PopupMenuItem(
                                          value: 'refund',
                                          child: Text('Refund')),
                                    ],
                                    onSelected: (action) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '$action payment ${p.id.substring(0, 8)}'),
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _methodLabel(String m) {
    switch (m) {
      case 'creditCard':
        return 'Credit Card';
      case 'debitCard':
        return 'Debit Card';
      case 'cash':
        return 'Cash';
      case 'bankTransfer':
        return 'Bank Transfer';
      case 'online':
        return 'Online';
      default:
        return m;
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
