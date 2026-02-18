import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_button.dart';

/// Date range picker for checking room availability.
///
/// Provides two date inputs (check-in, check-out) and
/// a search button. Can be used inline on the home page
/// or as a standalone widget on the rooms page.
class AvailabilityPicker extends StatefulWidget {
  final ValueChanged<DateTimeRange>? onSearch;
  final bool compact;

  const AvailabilityPicker({
    super.key,
    this.onSearch,
    this.compact = false,
  });

  @override
  State<AvailabilityPicker> createState() => _AvailabilityPickerState();
}

class _AvailabilityPickerState extends State<AvailabilityPicker> {
  DateTime? _checkIn;
  DateTime? _checkOut;

  Future<void> _pickDate({required bool isCheckIn}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn
          ? (_checkIn ?? now)
          : (_checkOut ?? (_checkIn ?? now).add(const Duration(days: 1))),
      firstDate: isCheckIn ? now : (_checkIn ?? now),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.accent,
                  onPrimary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          // Reset check-out if it's before check-in
          if (_checkOut != null && _checkOut!.isBefore(picked)) {
            _checkOut = null;
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  void _handleSearch() {
    if (_checkIn != null && _checkOut != null) {
      widget.onSearch?.call(
        DateTimeRange(start: _checkIn!, end: _checkOut!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(widget.compact ? AppSpacing.md : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: widget.compact ? _buildCompactLayout() : _buildFullLayout(),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Check Availability',
          style: AppTypography.titleMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: _buildDateField('Check-in', _checkIn, true)),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: _buildDateField('Check-out', _checkOut, false)),
            const SizedBox(width: AppSpacing.md),
            SSButton(
              label: 'Search',
              icon: Icons.search,
              onPressed: (_checkIn != null && _checkOut != null)
                  ? _handleSearch
                  : null,
              size: SSButtonSize.large,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildDateField('Check-in', _checkIn, true),
        const SizedBox(height: AppSpacing.sm),
        _buildDateField('Check-out', _checkOut, false),
        const SizedBox(height: AppSpacing.md),
        SSButton(
          label: 'Check Availability',
          icon: Icons.search,
          isExpanded: true,
          onPressed:
              (_checkIn != null && _checkOut != null) ? _handleSearch : null,
        ),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? date, bool isCheckIn) {
    return InkWell(
      onTap: () => _pickDate(isCheckIn: isCheckIn),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.labelSmall),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: date != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: AppTypography.bodyMedium.copyWith(
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
