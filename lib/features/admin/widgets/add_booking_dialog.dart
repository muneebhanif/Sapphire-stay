import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../providers/providers.dart';
import '../../../models/room.dart';

class AddBookingDialog extends ConsumerStatefulWidget {
  const AddBookingDialog({super.key});

  @override
  ConsumerState<AddBookingDialog> createState() => _AddBookingDialogState();
}

class _AddBookingDialogState extends ConsumerState<AddBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController(text: '1');
  
  Room? _selectedRoom;
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;

  int get _calculatedTotal {
    if (_selectedRoom == null) return 0;
    final nights = _checkOut.difference(_checkIn).inDays;
    return (nights > 0 ? nights : 1) * _selectedRoom!.pricePerNight.round();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a room.')));
      return;
    }
    setState(() => _isLoading = true);
    
    try {
      final user = ref.read(authProvider);
      
      await ref.read(bookingServiceProvider).createWalkInBooking(
        guestName: _nameCtrl.text.trim(),
        guestEmail: _emailCtrl.text.trim(),
        guestPhone: _phoneCtrl.text.trim(),
        roomId: _selectedRoom!.id,
        checkIn: _checkIn,
        checkOut: _checkOut,
        guestsCount: int.tryParse(_guestsCtrl.text) ?? 1,
        totalPkr: _calculatedTotal,
        staffId: user?.id,
      );
      
      ref.invalidate(bookingsProvider);

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Walk-in booking created and fully paid!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _selectDates() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _checkIn, end: _checkOut),
    );
    if (range != null) {
      setState(() {
        _checkIn = range.start;
        _checkOut = range.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Instant Walk-In Booking', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                const Text('Creates a confirmed booking and records a paid cash invoice.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.md),
                SSTextField(
                  label: 'Guest Name',
                  controller: _nameCtrl,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                SSTextField(
                  label: 'Guest Email',
                  controller: _emailCtrl,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                SSTextField(
                  label: 'Guest Phone',
                  controller: _phoneCtrl,
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                roomsAsync.when(
                  data: (rooms) => DropdownButtonFormField<Room>(
                    decoration: const InputDecoration(labelText: 'Select Room', border: OutlineInputBorder()),
                    value: _selectedRoom,
                    items: rooms.map((r) => DropdownMenuItem(value: r, child: Text('${r.number} - ${r.type.name}'))).toList(),
                    onChanged: (v) => setState(() => _selectedRoom = v),
                    validator: (v) => v == null ? 'Required' : null,
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading rooms: $e'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: SSTextField(
                        label: 'Guests Count',
                        controller: _guestsCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.date_range),
                        label: Text('${_checkIn.day}/${_checkIn.month} - ${_checkOut.day}/${_checkOut.month}'),
                        onPressed: _selectDates,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Total: Rs. $_calculatedTotal', style: AppTypography.titleLarge.copyWith(color: AppColors.accent)),
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
                      label: _isLoading ? 'Saving...' : 'Create Walk-In & Mark Paid',
                      onPressed: _isLoading ? () {} : _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
