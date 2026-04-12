import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/config/payment_env.dart';
import '../../../core/services/convex_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../models/booking_request.dart';
import '../../../models/payment_proof.dart';
import '../../../providers/providers.dart';

/// Booking request form with validation.
///
/// Multi-step approach:
///   Step 1 — Guest details
///   Step 2 — Room selection + dates
///   Step 3 — Review & submit
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Guest info controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _requestsController = TextEditingController();
  final _senderNumberController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _proofUrlController = TextEditingController();
  final _paymentMessageController = TextEditingController();

  // Booking details
  String? _selectedRoomId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  bool _isSubmitting = false;

  Uint8List? _imageBytes;
  String? _mimeType;

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requestsController.dispose();
    _senderNumberController.dispose();
    _transactionIdController.dispose();
    _proofUrlController.dispose();
    _paymentMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomIdFromQuery = GoRouterState.of(context).uri.queryParameters['roomId'];
    if (_selectedRoomId == null && roomIdFromQuery != null && roomIdFromQuery.isNotEmpty) {
      _selectedRoomId = roomIdFromQuery;
    }

    final user = ref.watch(authProvider);
    if (user == null) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.pagePadding(context),
          vertical: AppSpacing.xl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56, color: AppColors.textTertiary),
                const SizedBox(height: AppSpacing.md),
                Text('Login Required', style: AppTypography.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Please login or sign up before booking a room.',
                  style: AppTypography.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                SSButton(
                  label: 'Login / Sign Up',
                  icon: Icons.login,
                  onPressed: () => context.go(RoutePaths.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xl,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Text(
              'Book Your Stay',
              style: AppTypography.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Fill in the details below to reserve your room',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Stepper Indicators ──
            _buildStepIndicators(),
            const SizedBox(height: AppSpacing.xl),

            // ── Form ──
            Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: switch (_currentStep) {
                  0 => _buildGuestDetailsStep(),
                  1 => _buildRoomSelectionStep(),
                  2 => _buildReviewStep(),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Navigation Buttons ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  SSButton(
                    label: 'Previous',
                    variant: SSButtonVariant.secondary,
                    icon: Icons.arrow_back,
                    onPressed: () => setState(() => _currentStep--),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentStep < 2)
                  SSButton(
                    label: 'Next',
                    icon: Icons.arrow_forward,
                    onPressed: _handleNext,
                  )
                else
                  SSButton(
                    label: 'Submit Booking',
                    icon: Icons.check,
                    isLoading: _isSubmitting,
                    onPressed: _handleSubmit,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    final steps = ['Guest Details', 'Room & Dates', 'Review'];

    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == _currentStep;
        final isCompleted = i < _currentStep;

        return Expanded(
          child: Row(
            children: [
              // ── Step circle ──
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success
                      : isActive
                          ? AppColors.accent
                          : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: AppColors.white)
                      : Text(
                          '${i + 1}',
                          style: AppTypography.labelMedium.copyWith(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  steps[i],
                  style: AppTypography.labelMedium.copyWith(
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (i < steps.length - 1)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Icon(Icons.chevron_right,
                      size: 16, color: AppColors.textTertiary),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildGuestDetailsStep() {
    return Column(
      key: const ValueKey('step-0'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Guest Information', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.lg),
        SSTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          controller: _nameController,
          prefixIcon: Icons.person_outline,
          validator: (v) =>
              v == null || v.isEmpty ? 'Name is required' : null,
        ),
        const SizedBox(height: AppSpacing.md),
        SSTextField(
          label: 'Email Address',
          hint: 'your@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Email is required';
            if (!v.contains('@')) return 'Enter a valid email';
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.md),
        SSTextField(
          label: 'Phone Number',
          hint: '+1 (555) 000-0000',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Phone number is required';
            if (!RegExp(r'^[\d\+\-\(\) ]+$').hasMatch(v)) return 'Enter a valid phone number';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoomSelectionStep() {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Column(
      key: const ValueKey('step-1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Room & Dates', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.lg),

        // ── Room Dropdown ──
        Text('Select Room', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        roomsAsync.when(
          loading: () => const LinearProgressIndicator(color: AppColors.accent),
          error: (e, _) => Text('Error loading rooms: $e'),
          data: (rooms) => DropdownButtonFormField<String>(
            value: _selectedRoomId,
            decoration: const InputDecoration(
              hintText: 'Choose a room',
            ),
            items: rooms
                .where((r) => r.status.name == 'available')
                .map(
                  (r) => DropdownMenuItem(
                    value: r.id,
                    child: Text(
                        '${r.name} — PKR ${r.pricePerNight.toStringAsFixed(0)}/night'),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _selectedRoomId = v),
            validator: (v) => v == null ? 'Please select a room' : null,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Dates ──
        Row(
          children: [
            Expanded(child: _buildDatePicker('Check-in', _checkIn, true)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildDatePicker('Check-out', _checkOut, false)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Guests ──
        Text('Number of Guests', style: AppTypography.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            IconButton(
              onPressed: _guests > 1
                  ? () => setState(() => _guests--)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '$_guests',
              style: AppTypography.titleLarge,
            ),
            IconButton(
              onPressed: _guests < 6
                  ? () => setState(() => _guests++)
                  : null,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Special Requests ──
        SSTextField(
          label: 'Special Requests (Optional)',
          hint: 'Any special requirements?',
          controller: _requestsController,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isCheckIn) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? now,
          firstDate: isCheckIn ? now : (_checkIn ?? now),
          lastDate: now.add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() {
            if (isCheckIn) {
              _checkIn = picked;
              if (_checkOut != null && _checkOut!.isBefore(picked)) {
                _checkOut = null;
              }
            } else {
              _checkOut = picked;
            }
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon:
              const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Select date',
          style: AppTypography.bodyLarge.copyWith(
            color: date != null ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    final roomsAsync = ref.watch(allRoomsProvider);
    final selectedRoom = roomsAsync.whenOrNull(
      data: (rooms) => _selectedRoomId != null
          ? rooms.firstWhere((r) => r.id == _selectedRoomId)
          : null,
    );

    final nights =
        _checkIn != null && _checkOut != null
            ? _checkOut!.difference(_checkIn!).inDays
            : 0;
    final total = selectedRoom != null ? selectedRoom.pricePerNight * nights : 0.0;
    final totalPkr = total.round();

    return Column(
      key: const ValueKey('step-2'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Review Your Booking', style: AppTypography.titleLarge),
        const SizedBox(height: AppSpacing.lg),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guest Details', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _buildReviewRow('Name', _nameController.text),
              _buildReviewRow('Email', _emailController.text),
              _buildReviewRow('Phone', _phoneController.text),
              const Divider(height: AppSpacing.xl),
              Text('Booking Details', style: AppTypography.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              _buildReviewRow('Room', selectedRoom?.name ?? 'Not selected'),
              _buildReviewRow(
                'Check-in',
                _checkIn != null
                    ? '${_checkIn!.day}/${_checkIn!.month}/${_checkIn!.year}'
                    : 'Not selected',
              ),
              _buildReviewRow(
                'Check-out',
                _checkOut != null
                    ? '${_checkOut!.day}/${_checkOut!.month}/${_checkOut!.year}'
                    : 'Not selected',
              ),
              _buildReviewRow('Guests', '$_guests'),
              _buildReviewRow('Nights', '$nights'),
              if (_requestsController.text.isNotEmpty)
                _buildReviewRow('Special Requests', _requestsController.text),
              const Divider(height: AppSpacing.xl),
              _buildReviewRow(
                'Total Amount',
                CurrencyUtils.formatPkr(totalPkr),
                isHighlight: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Easypaisa Payment Details', style: AppTypography.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    _buildReviewRow('Account Title', PaymentEnv.easypaisaAccountTitle),
                    _buildReviewRow(
                      'Account Number',
                      PaymentEnv.easypaisaAccountNumber.isEmpty
                          ? 'Configure FLUTTER_EASYPAISA_ACCOUNT_NUMBER'
                          : PaymentEnv.easypaisaAccountNumber,
                    ),
                    _buildReviewRow('Amount to Send', CurrencyUtils.formatPkr(totalPkr)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SSTextField(
                label: 'Sender Easypaisa Number',
                hint: '03XXXXXXXXX',
                controller: _senderNumberController,
                prefixIcon: Icons.phone_android,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Sender number is required';
                  final cleanPhone = v.replaceAll(RegExp(r'\D'), '');
                  if (cleanPhone.length < 10) return 'Enter a valid 11-digit number';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SSTextField(
                label: 'Transaction ID (Optional)',
                hint: 'EPX-123456',
                controller: _transactionIdController,
                prefixIcon: Icons.confirmation_number_outlined,
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
                label: 'Message to Staff (Optional)',
                hint: 'Please confirm and book for us.',
                controller: _paymentMessageController,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodyMedium),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              style: isHighlight
                  ? AppTypography.titleLarge.copyWith(color: AppColors.accent)
                  : AppTypography.labelLarge,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep == 1) {
      if (_selectedRoomId != null && _checkIn != null && _checkOut != null) {
        setState(() => _currentStep++);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please complete all required fields'),
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    final user = ref.read(authProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login before booking.')),
        );
      }
      context.go(RoutePaths.login);
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an Easypaisa payment screenshot')),
      );
      return;
    }

    final rooms = await ref.read(allRoomsProvider.future);
    final selectedRoom = rooms.firstWhere((r) => r.id == _selectedRoomId);
    final nights = _checkOut!.difference(_checkIn!).inDays;
    final totalPkr = (selectedRoom.pricePerNight * nights).round();

    setState(() => _isSubmitting = true);

    try {
      // Step 1: Create booking request (also creates guest user)
      final bookingRequest = BookingRequest(
        id: 'br-${DateTime.now().millisecondsSinceEpoch}',
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        roomId: selectedRoom.id,
        roomNumber: selectedRoom.number,
        checkIn: _checkIn!,
        checkOut: _checkOut!,
        guestsCount: _guests,
        requestedTotalPkr: totalPkr,
        status: BookingRequestStatus.pendingPayment,
        notes: _requestsController.text.trim().isEmpty
            ? null
            : _requestsController.text.trim(),
        createdAt: DateTime.now(),
      );

      final created = await ref
          .read(bookingRequestServiceProvider)
          .createBookingRequest(bookingRequest);

      debugPrint('[BookingScreen] Booking request created: ${created.id}, customerId: ${created.customerId}');

      // Step 2: Upload the Easypaisa screenshot
      final storageService = ref.read(convexStorageServiceProvider);
      final storageId = await storageService.uploadImage(_imageBytes!, _mimeType!);
      
      if (storageId == null) {
        throw Exception('Failed to upload payment screenshot');
      }

      debugPrint('[BookingScreen] Image uploaded: $storageId');

      // Step 3: Submit payment proof — pass customerId so we avoid
      //         calling the admin-restricted getAllBookingRequests.
      final proof = PaymentProof(
        id: '',
        bookingRequestId: created.id,
        customerName: _nameController.text.trim(),
        customerId: created.customerId,
        senderNumber: _senderNumberController.text.trim(),
        transactionId: _transactionIdController.text.trim().isEmpty
            ? null
            : _transactionIdController.text.trim(),
        amountPkr: totalPkr,
        screenshotUrl: storageId,
        message: _paymentMessageController.text.trim().isEmpty
            ? null
            : _paymentMessageController.text.trim(),
        status: PaymentProofStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref.read(paymentProofServiceProvider).submitPaymentProof(proof);

      debugPrint('[BookingScreen] Payment proof submitted successfully');

      ref.invalidate(allBookingRequestsProvider);
      ref.invalidate(allPaymentProofsProvider);
      ref.invalidate(pendingPaymentProofsProvider);
    } catch (e) {
      debugPrint('[BookingScreen] ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      context.go(RoutePaths.bookingConfirmation);
    }
  }
}
