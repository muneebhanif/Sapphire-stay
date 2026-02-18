import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable data table with sorting, pagination placeholder,
/// and consistent styling.
///
/// Wraps [DataTable] with our design system tokens and adds
/// common features expected in admin/staff dashboards.
class SSDataTable<T> extends StatelessWidget {
  final List<String> columns;
  final List<T> rows;
  final List<DataCell> Function(T item) cellBuilder;
  final ValueChanged<T>? onRowTap;
  final bool showHeader;
  final String? emptyMessage;

  const SSDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.cellBuilder,
    this.onRowTap,
    this.showHeader = true,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
            columns: columns
                .map(
                  (col) => DataColumn(
                    label: Text(
                      col,
                      style: AppTypography.labelLarge,
                    ),
                  ),
                )
                .toList(),
            rows: rows
                .map(
                  (item) => DataRow(
                    onSelectChanged:
                        onRowTap != null ? (_) => onRowTap!(item) : null,
                    cells: cellBuilder(item),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: AppSpacing.md),
          Text(
            emptyMessage ?? 'No data available',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
