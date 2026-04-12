import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../models/invoice.dart';
import '../../../providers/providers.dart';
import '../widgets/add_invoice_dialog.dart';

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
                  showDialog(
                    context: context,
                    builder: (context) => const AddInvoiceDialog(),
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
                            CurrencyUtils.formatPkr(inv.total.round()),
                            style: AppTypography.bodySmall
                                .copyWith(fontWeight: FontWeight.w600),
                          )),
                          DataCell(
                              Text(CurrencyUtils.formatPkr(inv.tax.round()))),
                          DataCell(SSStatusChip.fromString(inv.status.name)),
                          DataCell(
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 18),
                              itemBuilder: (_) => const [
                                PopupMenuItem(value: 'view', child: Text('View')),
                                PopupMenuItem(value: 'print', child: Text('Print')),
                                PopupMenuItem(value: 'markPaid', child: Text('Mark as Paid')),
                                PopupMenuItem(value: 'void', child: Text('Void')),
                              ],
                              onSelected: (action) async {
                                if (action == 'print') {
                                  await _printInvoice(inv, context);
                                } else if (action == 'view') {
                                  _showInvoiceViewDialog(context, inv);
                                } else if (action == 'markPaid') {
                                  await ref.read(invoiceServiceProvider).updateInvoiceStatus(inv.id, InvoiceStatus.paid);
                                  ref.invalidate(invoicesProvider);
                                } else if (action == 'void') {
                                  await ref.read(invoiceServiceProvider).updateInvoiceStatus(inv.id, InvoiceStatus.cancelled);
                                  ref.invalidate(invoicesProvider);
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
            },
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  void _showInvoiceViewDialog(BuildContext context, Invoice inv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Invoice ${inv.id.substring(0, 8)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest: ${inv.guestName}'),
              Text('Status: ${inv.status.name.toUpperCase()}'),
              Text('Total: PKR ${inv.total}'),
              const SizedBox(height: 10),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...inv.lineItems.map((item) => Text('- ${item.description} x${item.quantity} (PKR ${item.total})'))
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))
        ],
      ),
    );
  }

  Future<void> _printInvoice(Invoice inv, BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Sapphire Stay Hotel', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
                      pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Billed To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text(inv.guestName),
                          pw.Text('Invoice ID: ${inv.id.substring(0, 8)}'),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Date issued: ${_fmtDate(inv.issueDate)}'),
                          pw.Text('Due date: ${inv.dueDate != null ? _fmtDate(inv.dueDate!) : 'N/A'}'),
                          pw.Text('Status: ${inv.status.name.toUpperCase()}'),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 30),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 1, child: pw.Text('QTY', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('PRICE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      pw.Expanded(flex: 2, child: pw.Text('AMOUNT', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                  ...inv.lineItems.map((item) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        child: pw.Row(
                          children: [
                            pw.Expanded(flex: 3, child: pw.Text(item.description)),
                            pw.Expanded(flex: 1, child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.right)),
                            pw.Expanded(flex: 2, child: pw.Text(CurrencyUtils.formatPkr(item.unitPrice.round()), textAlign: pw.TextAlign.right)),
                            pw.Expanded(flex: 2, child: pw.Text(CurrencyUtils.formatPkr(item.total.round()), textAlign: pw.TextAlign.right)),
                          ],
                        ),
                      )),
                  pw.SizedBox(height: 20),
                  pw.Divider(color: PdfColors.grey400),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.end,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text('Subtotal: ${CurrencyUtils.formatPkr(inv.subtotal.round())}'),
                          pw.Text('Tax: ${CurrencyUtils.formatPkr(inv.tax.round())}'),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            'TOTAL: ${CurrencyUtils.formatPkr(inv.total.round())}',
                            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.Spacer(),
                  pw.Center(
                    child: pw.Text('Thank you for choosing Sapphire Stay Hotel!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600)),
                  ),
                ],
              ),
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Invoice_${inv.id.substring(0, 8)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
