import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/providers.dart';

/// Consistent footer for all customer-facing pages.
/// Contact info and branding now come from the database.
class CustomerFooter extends ConsumerWidget {
  const CustomerFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Responsive.isDesktop(context);
    final configAsync = ref.watch(siteConfigProvider);

    final copyright = configAsync.whenOrNull(
      data: (c) => c['copyright'],
    ) ?? AppConstants.copyright;

    return Container(
      color: AppColors.primary,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxl,
      ),
      child: Column(
        children: [
          isDesktop
              ? _buildDesktopLayout(context, ref)
              : _buildMobileLayout(context, ref),
          const SizedBox(height: AppSpacing.xl),
          const Divider(color: AppColors.primaryLight),
          const SizedBox(height: AppSpacing.lg),
          // ── Copyright ──
          Text(
            copyright,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Brand ──
        Expanded(flex: 2, child: _buildBrandSection(ref)),
        const SizedBox(width: AppSpacing.xxl),

        // ── Quick Links ──
        Expanded(child: _buildQuickLinks(context)),
        const SizedBox(width: AppSpacing.xxl),

        // ── Contact ──
        Expanded(child: _buildContactSection(ref)),
        const SizedBox(width: AppSpacing.xxl),

        // ── Newsletter ──
        Expanded(flex: 2, child: const _NewsletterSection()),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandSection(ref),
        const SizedBox(height: AppSpacing.xl),
        _buildQuickLinks(context),
        const SizedBox(height: AppSpacing.xl),
        _buildContactSection(ref),
        const SizedBox(height: AppSpacing.xl),
        const _NewsletterSection(),
      ],
    );
  }

  Widget _buildBrandSection(WidgetRef ref) {
    final configAsync = ref.watch(siteConfigProvider);
    final hotelName = configAsync.whenOrNull(
      data: (c) => c['hotel_name'],
    ) ?? AppConstants.hotelName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.appName.toUpperCase(),
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.accent,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          hotelName,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Comfortable and clean rooms for your stay in Muzaffarabad.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      ('Home', RoutePaths.home),
      ('Rooms', RoutePaths.rooms),
      ('Gallery', RoutePaths.gallery),
      ('About Us', RoutePaths.about),
      ('Contact', RoutePaths.contact),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Links',
          style: AppTypography.titleSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.md),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: InkWell(
              onTap: () => context.go(link.$2),
              child: Text(
                link.$1,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(WidgetRef ref) {
    final configAsync = ref.watch(siteConfigProvider);
    final phone = configAsync.whenOrNull(data: (c) => c['phone']) ?? AppConstants.phone;
    final email = configAsync.whenOrNull(data: (c) => c['email']) ?? AppConstants.email;
    final address = configAsync.whenOrNull(data: (c) => c['address']) ?? AppConstants.address;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact',
          style: AppTypography.titleSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildContactItem(Icons.phone_outlined, phone),
        const SizedBox(height: AppSpacing.xs),
        _buildContactItem(Icons.email_outlined, email),
        const SizedBox(height: AppSpacing.xs),
        _buildContactItem(Icons.location_on_outlined, address),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsletterSection extends ConsumerStatefulWidget {
  const _NewsletterSection();

  @override
  ConsumerState<_NewsletterSection> createState() => _NewsletterSectionState();
}

class _NewsletterSectionState extends ConsumerState<_NewsletterSection> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _message = 'Please enter a valid email');
      return;
    }
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      final client = ref.read(convexClientProvider);
      await client.mutation("data:subscribeNewsletter", {"email": email});
      setState(() {
        _message = 'Subscribed successfully!';
        _emailController.clear();
      });
    } catch (e) {
      setState(() => _message = 'Failed to subscribe');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget _buildNewsletterSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Newsletter',
          style: AppTypography.titleSmall.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Subscribe for exclusive offers and updates.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Your email address',
                  filled: true,
                  fillColor: AppColors.primaryLight,
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            ElevatedButton(
              onPressed: _isLoading ? null : _subscribe,
              child: _isLoading 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Text('Subscribe'),
            ),
          ],
        ),
        if (_message != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _message!,
            style: AppTypography.bodySmall.copyWith(
              color: _message!.contains('success') ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildNewsletterSection(context);
  }
}
