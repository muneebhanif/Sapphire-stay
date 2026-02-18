import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../providers/providers.dart';

/// Walk-in registration screen for staff.
class StaffWalkinScreen extends ConsumerStatefulWidget {
  const StaffWalkinScreen({super.key});

  @override
  ConsumerState<StaffWalkinScreen> createState() => _StaffWalkinScreenState();
}

class _StaffWalkinScreenState extends ConsumerState<StaffWalkinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalityCtrl = TextEditingController();
  final _idCtrl = TextEditingController();

  String? _selectedRoom;
  int _nights = 1;
  int _guests = 1;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _nationalityCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Walk-in Registration', style: AppTypography.headlineSmall),
          const SizedBox(height: 2),
          Text(
            'Register a guest who arrives without a prior booking.',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Guest Information ──
                  _sectionTitle('Guest Information'),
                  const SizedBox(height: AppSpacing.md),
                  _buildResponsiveRow(isDesktop, [
                    SSTextField(
                      label: 'Full Name',
                      hint: 'John Doe',
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    SSTextField(
                      label: 'Email',
                      hint: 'john@email.com',
                      controller: _emailCtrl,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  _buildResponsiveRow(isDesktop, [
                    SSTextField(
                      label: 'Phone',
                      hint: '+1 234 567 890',
                      controller: _phoneCtrl,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    SSTextField(
                      label: 'Nationality',
                      hint: 'e.g. American',
                      controller: _nationalityCtrl,
                      prefixIcon: Icons.flag_outlined,
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  SSTextField(
                    label: 'ID / Passport Number',
                    hint: 'AB1234567',
                    controller: _idCtrl,
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Room Selection ──
                  _sectionTitle('Room Selection'),
                  const SizedBox(height: AppSpacing.md),

                  roomsAsync.when(
                    loading: () => const SSLoading(type: SSLoadingType.card),
                    error: (e, _) => SSErrorState(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(roomsProvider),
                    ),
                    data: (rooms) {
                      final available = rooms
                          .where((r) => r.status.name == 'available')
                          .toList();

                      return Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRoom,
                          decoration: const InputDecoration(
                            labelText: 'Available Room',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          items: available.map((room) {
                            return DropdownMenuItem(
                              value: room.id,
                              child: Text(
                                '${room.number} — ${room.type.name.toUpperCase()} (\$${room.pricePerNight}/night)',
                              ),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedRoom = v),
                          validator: (v) =>
                              v == null ? 'Select a room' : null,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),
                  _buildResponsiveRow(isDesktop, [
                    _buildCounter('Number of Nights', _nights, (v) {
                      setState(() => _nights = v);
                    }),
                    _buildCounter('Number of Guests', _guests, (v) {
                      setState(() => _guests = v);
                    }),
                  ]),

                  const SizedBox(height: AppSpacing.xxl),

                  // ── Submit ──
                  Row(
                    children: [
                      SSButton(
                        label: 'Register & Check In',
                        icon: Icons.how_to_reg,
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Walk-in guest registered and checked in successfully!',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SSButton(
                        label: 'Clear',
                        variant: SSButtonVariant.secondary,
                        onPressed: () {
                          _formKey.currentState?.reset();
                          _nameCtrl.clear();
                          _emailCtrl.clear();
                          _phoneCtrl.clear();
                          _nationalityCtrl.clear();
                          _idCtrl.clear();
                          setState(() {
                            _selectedRoom = null;
                            _nights = 1;
                            _guests = 1;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.accent, width: 2),
        ),
      ),
      child: Text(title, style: AppTypography.titleMedium),
    );
  }

  Widget _buildResponsiveRow(bool isDesktop, List<Widget> children) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .map((c) => Expanded(child: c))
            .expand((w) => [w, const SizedBox(width: AppSpacing.md)])
            .toList()
          ..removeLast(),
      );
    }
    return Column(
      children: children
          .expand((w) => [w, const SizedBox(height: AppSpacing.md)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildCounter(String label, int value, ValueChanged<int> onChanged) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.labelMedium),
                Text('$value', style: AppTypography.titleLarge),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}
