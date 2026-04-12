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
import '../../../models/payment_proof.dart';
import '../../../providers/providers.dart';
import '../widgets/add_payment_dialog.dart';

/// Admin payments screen.
class AdminPaymentScreen extends ConsumerWidget {
  const AdminPaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentsProvider);
    final pendingProofsAsync = ref.watch(pendingPaymentProofsProvider);
    final currentUser = ref.watch(authProvider);

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
                    Text(
                        'Track all payments, verify proofs, and manage transactions.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Record Payment',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const AddPaymentDialog(),
                  );
                },
              ),
            ],
          ),
        ),

        // ── Pending Payment Proofs Section ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: _buildPendingProofsSection(
            context,
            ref,
            pendingProofsAsync,
            staffName: currentUser?.name ?? 'Admin',
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

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
                          CurrencyUtils.formatPkr(totalAmount.round()),
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
                                DataCell(
                                    Text(_methodLabel(p.method.name))),
                                DataCell(Text(
                                  CurrencyUtils.formatPkr(p.amount.round()),
                                  style: AppTypography.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600),
                                )),
                                DataCell(Text(_fmtDate(p.paidAt))),
                                DataCell(SSStatusChip.fromString(
                                    p.status.name)),
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

  Widget _buildPendingProofsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PaymentProof>> pendingProofsAsync, {
    required String staffName,
  }) {
    return pendingProofsAsync.when(
      loading: () => const LinearProgressIndicator(color: AppColors.accent),
      error: (e, _) => SSErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(pendingPaymentProofsProvider),
      ),
      data: (proofs) {
        return Container(
          width: double.infinity,
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
                children: [
                  Text('Pending Easypaisa Proofs',
                      style: AppTypography.titleMedium),
                  const SizedBox(width: AppSpacing.sm),
                  SSStatusChip.fromString('pending',
                      label: '${proofs.length} pending'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (proofs.isEmpty)
                Text('No pending payment proof submissions.',
                    style: AppTypography.bodySmall)
              else
                ...proofs.map((proof) => Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(proof.customerName,
                                  style: AppTypography.labelLarge),
                              Text(
                                  CurrencyUtils.formatPkr(proof.amountPkr),
                                  style: AppTypography.labelLarge
                                      .copyWith(color: AppColors.accent)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text('Sender: ${proof.senderNumber}',
                              style: AppTypography.bodySmall),
                          if ((proof.transactionId ?? '').isNotEmpty)
                            Text('Txn: ${proof.transactionId}',
                                style: AppTypography.bodySmall),
                          const SizedBox(height: AppSpacing.sm),

                          // Payment proof image preview
                          GestureDetector(
                            onTap: () => _showImageDialog(
                                context, proof.screenshotUrl),
                            child: Container(
                              height: 150,
                              width: 150,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                                child: Image.network(
                                  proof.screenshotUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child:
                                          CircularProgressIndicator(
                                              strokeWidth: 2),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Center(
                                    child: Icon(Icons.broken_image,
                                        color:
                                            AppColors.textTertiary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          if ((proof.message ?? '').isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text('Message: ${proof.message}',
                                style: AppTypography.bodySmall),
                          ],
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              SSButton(
                                label: 'Approve',
                                icon: Icons.check,
                                size: SSButtonSize.small,
                                onPressed: () => _reviewProof(
                                  context,
                                  ref,
                                  proof,
                                  approved: true,
                                  staffName: staffName,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              SSButton(
                                label: 'Reject',
                                icon: Icons.close,
                                size: SSButtonSize.small,
                                variant: SSButtonVariant.danger,
                                onPressed: () => _reviewProof(
                                  context,
                                  ref,
                                  proof,
                                  approved: false,
                                  staffName: staffName,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  void _showImageDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppSpacing.radiusMd),
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image,
                          size: 48, color: AppColors.textTertiary),
                      SizedBox(height: AppSpacing.sm),
                      Text('Failed to load image'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reviewProof(
    BuildContext context,
    WidgetRef ref,
    PaymentProof proof, {
    required bool approved,
    required String staffName,
  }) async {
    await ref.read(paymentProofServiceProvider).reviewPaymentProof(
          proof.id,
          approved: approved,
          staffName: staffName,
          rejectionReason:
              approved ? null : 'Verification failed by admin.',
        );

    ref.invalidate(pendingPaymentProofsProvider);
    ref.invalidate(allPaymentProofsProvider);
    ref.invalidate(allBookingRequestsProvider);
    ref.invalidate(paymentsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approved
              ? 'Payment proof approved and booking verified.'
              : 'Payment proof rejected.'),
        ),
      );
    }
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
