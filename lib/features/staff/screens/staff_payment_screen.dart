import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../providers/providers.dart';

/// Staff payments screen.
class StaffPaymentScreen extends ConsumerWidget {
  const StaffPaymentScreen({super.key});

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
                    Text('Payments', style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text(
                      'Track and record payments.',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              SSButton(
                label: 'Record Payment',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Record payment dialog coming soon.')),
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
                        DataColumn(label: Text('Payment ID')),
                        DataColumn(label: Text('Invoice')),
                        DataColumn(label: Text('Guest')),
                        DataColumn(label: Text('Method')),
                        DataColumn(label: Text('Amount'), numeric: true),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: payments.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(
                            p.id.substring(0, 8),
                            style: AppTypography.bodySmall
                                .copyWith(fontFamily: 'monospace'),
                          )),
                          DataCell(Text(p.invoiceId.substring(0, 8))),
                          DataCell(Text(p.guestName)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _methodIcon(p.method.name),
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(_methodLabel(p.method.name)),
                              ],
                            ),
                          ),
                          DataCell(Text(
                            '\$${p.amount.toStringAsFixed(2)}',
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.w600),
                          )),
                          DataCell(Text(_fmtDate(p.paidAt))),
                          DataCell(SSStatusChip.fromString(p.status.name)),
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

  IconData _methodIcon(String method) {
    switch (method) {
      case 'creditCard':
        return Icons.credit_card;
      case 'debitCard':
        return Icons.credit_card_outlined;
      case 'cash':
        return Icons.money;
      case 'bankTransfer':
        return Icons.account_balance;
      case 'online':
        return Icons.language;
      default:
        return Icons.payment;
    }
  }

  String _methodLabel(String method) {
    switch (method) {
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
        return method;
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
