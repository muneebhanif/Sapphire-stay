import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Standardized text input field with built-in label, validation display,
/// and optional prefix/suffix icons.
///
/// Wraps [TextFormField] with consistent styling so every form
/// in the application looks uniform.
class SSTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  const SSTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──
        Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // ── Input ──
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          maxLines: maxLines,
          autofocus: autofocus,
          focusNode: focusNode,
          onTap: onTap,
          style: AppTypography.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.textTertiary)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
