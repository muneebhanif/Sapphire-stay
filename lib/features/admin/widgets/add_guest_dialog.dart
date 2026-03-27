import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../models/guest.dart';
import '../../../providers/providers.dart';

class AddGuestDialog extends ConsumerStatefulWidget {
  const AddGuestDialog({super.key});

  @override
  ConsumerState<AddGuestDialog> createState() => _AddGuestDialogState();
}

class _AddGuestDialogState extends ConsumerState<AddGuestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final guest = Guest(
        id: '',
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        totalStays: 0,
        createdAt: DateTime.now(),
      );
      
      final guestService = ref.read(guestServiceProvider);
      await guestService.createGuest(guest);
      ref.invalidate(guestsProvider);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding guest: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              Text('Add New Guest', style: AppTypography.headlineSmall),
              const SizedBox(height: AppSpacing.md),
              SSTextField(
                label: 'Name',
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SSTextField(
                label: 'Email',
                controller: _emailController,
                validator: (v) => v!.isEmpty || !v.contains('@') ? 'Valid email required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              SSTextField(
                label: 'Phone (Optional)',
                controller: _phoneController,
              ),
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
                    label: _isLoading ? 'Saving...' : 'Save',
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
