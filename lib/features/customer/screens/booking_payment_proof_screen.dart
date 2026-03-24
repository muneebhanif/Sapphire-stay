import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../models/payment_proof.dart';
import '../../../providers/providers.dart';
import '../../../core/services/convex_storage_service.dart';

class BookingPaymentProofScreen extends ConsumerStatefulWidget {
  final String bookingRequestId;
  final int amountPkr;

  const BookingPaymentProofScreen({
    super.key,
    required this.bookingRequestId,
    required this.amountPkr,
  });

  @override
  ConsumerState<BookingPaymentProofScreen> createState() => _BookingPaymentProofScreenState();
}

class _BookingPaymentProofScreenState extends ConsumerState<BookingPaymentProofScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senderController = TextEditingController();
  final _trxController = TextEditingController();
  final _msgController = TextEditingController();

  Uint8List? _imageBytes;
  String? _mimeType;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _mimeType = pickedFile.mimeType ?? 'image/jpeg';
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an Easypaisa screenshot.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final storageService = ref.read(convexStorageServiceProvider);
      final storageId = await storageService.uploadImage(_imageBytes!, _mimeType!);

      if (storageId == null) {
        throw Exception('Failed to upload image to Convex storage');
      }

      final proofService = ref.read(paymentProofServiceProvider);
      await proofService.submitPaymentProof(
        PaymentProof(
          id: '',
          bookingRequestId: widget.bookingRequestId,
          customerName: '', // filled by backend
          senderNumber: _senderController.text.trim(),
          transactionId: _trxController.text.trim(),
          amountPkr: widget.amountPkr,
          screenshotUrl: storageId,
          message: _msgController.text.trim(),
          status: PaymentProofStatus.pending,
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        context.go(RoutePaths.bookingConfirmation);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting payment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Easypaisa Payment',
                  style: AppTypography.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Please send PKR ${widget.amountPkr} to our official Easypaisa number.\nThen, upload the screenshot and details here.',
                  style: AppTypography.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primaryLight),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Easypaisa Number: 0300-1234567\nTitle: StaySite Hotel',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                SSTextField(
                  label: 'Sender Mobile Number',
                  hint: '03001234567',
                  controller: _senderController,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                SSTextField(
                  label: 'Transaction ID (TID) / Optional',
                  hint: 'Enter TID from SMS',
                  controller: _trxController,
                ),
                const SizedBox(height: AppSpacing.md),
                
                Text('Payment Screenshot', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: _imageBytes != null
                        ? Image.memory(_imageBytes!, fit: BoxFit.contain)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file, size: 48, color: AppColors.textSecondary),
                              SizedBox(height: AppSpacing.sm),
                              Text('Tap to upload Easypaisa screenshot'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                SSTextField(
                  label: 'Message (Optional)',
                  controller: _msgController,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),

                SizedBox(
                  width: double.infinity,
                  child: SSButton(
                    label: 'Submit Payment Proof',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
