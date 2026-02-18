import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Status chip used throughout the application to display
/// booking status, room status, payment status, etc.
///
/// Color-coded for instant recognition.
enum SSStatusType { available, occupied, reserved, maintenance, checkedIn, pending, confirmed, cancelled, completed, paid, unpaid, draft, issued, overdue }

class SSStatusChip extends StatelessWidget {
  final SSStatusType status;
  final String? label;

  const SSStatusChip({
    super.key,
    required this.status,
    this.label,
  });

  /// Convenience factory that accepts a status name string.
  factory SSStatusChip.fromString(String statusName, {Key? key, String? label}) {
    final type = SSStatusType.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => SSStatusType.pending,
    );
    return SSStatusChip(key: key, status: type, label: label);
  }

  /// Allow constructing with a dynamic [status] (String or SSStatusType).
  static SSStatusChip adaptive({Key? key, required dynamic status, String? label}) {
    if (status is SSStatusType) {
      return SSStatusChip(key: key, status: status, label: label);
    }
    return SSStatusChip.fromString(status.toString(), key: key, label: label);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label ?? _defaultLabel,
        style: AppTypography.labelSmall.copyWith(
          color: _textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _defaultLabel => switch (status) {
        SSStatusType.available => 'Available',
        SSStatusType.occupied => 'Occupied',
        SSStatusType.reserved => 'Reserved',
        SSStatusType.maintenance => 'Maintenance',
        SSStatusType.checkedIn => 'Checked In',
        SSStatusType.pending => 'Pending',
        SSStatusType.confirmed => 'Confirmed',
        SSStatusType.cancelled => 'Cancelled',
        SSStatusType.completed => 'Completed',
        SSStatusType.paid => 'Paid',
        SSStatusType.unpaid => 'Unpaid',
        SSStatusType.draft => 'Draft',
        SSStatusType.issued => 'Issued',
        SSStatusType.overdue => 'Overdue',
      };

  Color get _backgroundColor => switch (status) {
        SSStatusType.available || SSStatusType.confirmed || SSStatusType.paid || SSStatusType.completed => AppColors.successLight,
        SSStatusType.occupied || SSStatusType.cancelled || SSStatusType.unpaid || SSStatusType.overdue => AppColors.errorLight,
        SSStatusType.reserved || SSStatusType.pending || SSStatusType.draft => AppColors.warningLight,
        SSStatusType.maintenance => AppColors.surfaceVariant,
        SSStatusType.checkedIn || SSStatusType.issued => AppColors.infoLight,
      };

  Color get _textColor => switch (status) {
        SSStatusType.available || SSStatusType.confirmed || SSStatusType.paid || SSStatusType.completed => AppColors.success,
        SSStatusType.occupied || SSStatusType.cancelled || SSStatusType.unpaid || SSStatusType.overdue => AppColors.error,
        SSStatusType.reserved || SSStatusType.pending || SSStatusType.draft => AppColors.warning,
        SSStatusType.maintenance => AppColors.textSecondary,
        SSStatusType.checkedIn || SSStatusType.issued => AppColors.info,
      };
}
