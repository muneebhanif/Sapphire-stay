import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
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

  // Booking details
  String? _selectedRoomId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _requestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          validator: (v) =>
              v == null || v.isEmpty ? 'Phone number is required' : null,
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
                        '${r.name} — \$${r.pricePerNight.toStringAsFixed(0)}/night'),
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
                '\$${total.toStringAsFixed(2)}',
                isHighlight: true,
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
    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isSubmitting = false);
      context.go(RoutePaths.bookingConfirmation);
    }
  }
}
