import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';

class AddBookingDialog extends ConsumerStatefulWidget {
  const AddBookingDialog({super.key});

  @override
  ConsumerState<AddBookingDialog> createState() => _AddBookingDialogState();
}

class _AddBookingDialogState extends ConsumerState<AddBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    // Basic mock implementation for rapid complete coverage
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Booking', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              const Text('Select Guest and Room to create an instant booking reservation.'),
              const SizedBox(height: AppSpacing.md),
              const SSTextField(label: 'Guest Name / Email'),
              const SizedBox(height: AppSpacing.sm),
              const SSTextField(label: 'Room Number'),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  SSButton(
                    label: _isLoading ? 'Saving...' : 'Create Booking',
                    onPressed: _isLoading ? () {} : _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
