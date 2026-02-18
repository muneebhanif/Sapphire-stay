import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_text_field.dart';

/// Contact page with form, map placeholder, and hotel info.
class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      children: [
        // ── Header ──
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.xxl,
          ),
          color: AppColors.primary,
          child: Column(
            children: [
              Text(
                'CONTACT US',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.accent,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Get In Touch',
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'We\'d love to hear from you',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),

        // ── Content ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.xxl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildForm()),
                      const SizedBox(width: AppSpacing.xxl),
                      Expanded(flex: 2, child: _buildContactInfo()),
                    ],
                  )
                : Column(
                    children: [
                      _buildForm(),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildContactInfo(),
                    ],
                  ),
          ),
        ),

        // ── Map Placeholder ──
        Container(
          height: 400,
          width: double.infinity,
          color: AppColors.surfaceVariant,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, size: 64, color: AppColors.textTertiary),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Map Placeholder',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Google Maps or similar integration will be added here',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send us a Message', style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            SSTextField(
              label: 'Your Name',
              hint: 'John Doe',
              controller: _nameCtrl,
              prefixIcon: Icons.person_outline,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Name is required' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            SSTextField(
              label: 'Email Address',
              hint: 'john@email.com',
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Email is required';
                if (!v!.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            SSTextField(
              label: 'Subject',
              hint: 'How can we help?',
              controller: _subjectCtrl,
              prefixIcon: Icons.subject,
            ),
            const SizedBox(height: AppSpacing.md),
            SSTextField(
              label: 'Message',
              hint: 'Tell us more...',
              controller: _messageCtrl,
              maxLines: 5,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Message is required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            SSButton(
              label: 'Send Message',
              icon: Icons.send,
              isExpanded: true,
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message sent! We\'ll get back to you shortly.'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoCard(
          Icons.location_on_outlined,
          'Address',
          AppConstants.address,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          Icons.phone_outlined,
          'Phone',
          AppConstants.phone,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          Icons.email_outlined,
          'Email',
          AppConstants.email,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          Icons.access_time,
          'Reception Hours',
          '24 hours / 7 days a week',
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.labelLarge),
                const SizedBox(height: 2),
                Text(value, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
