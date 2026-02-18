import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';

/// Top navigation bar for the customer-facing (public) module.
///
/// Desktop: Horizontal links + CTA button
/// Mobile:  Hamburger menu with slide-out drawer
class CustomerNavBar extends StatelessWidget {
  const CustomerNavBar({super.key});

  static final _navItems = [
    _NavItem('Home', RoutePaths.home),
    _NavItem('Rooms', RoutePaths.rooms),
    _NavItem('Services', RoutePaths.services),
    _NavItem('Gallery', RoutePaths.gallery),
    _NavItem('About', RoutePaths.about),
    _NavItem('Contact', RoutePaths.contact),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.navBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // ── Logo ──
          _buildLogo(context),
          const Spacer(),

          // ── Navigation Items (desktop only) ──
          if (Responsive.isDesktop(context)) ...[
            ..._navItems.map((item) => _buildNavItem(context, item)),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.booking),
              child: const Text('Book Now'),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: () => context.go(RoutePaths.login),
              child: Text(
                'Staff Login',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],

          // ── Mobile hamburger ──
          if (!Responsive.isDesktop(context))
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(RoutePaths.home),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            AppConstants.appName.toUpperCase(),
            style: AppTypography.titleLarge.copyWith(
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isActive = currentPath == item.path;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: TextButton(
        onPressed: () => context.go(item.path),
        style: TextButton.styleFrom(
          foregroundColor: isActive ? AppColors.accent : AppColors.textPrimary,
        ),
        child: Text(
          item.label,
          style: AppTypography.labelLarge.copyWith(
            color: isActive ? AppColors.accent : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Mobile navigation drawer for the customer module.
class CustomerDrawer extends StatelessWidget {
  const CustomerDrawer({super.key});

  static final _navItems = [
    _NavItem('Home', RoutePaths.home),
    _NavItem('Rooms', RoutePaths.rooms),
    _NavItem('Services', RoutePaths.services),
    _NavItem('Gallery', RoutePaths.gallery),
    _NavItem('About', RoutePaths.about),
    _NavItem('Contact', RoutePaths.contact),
    _NavItem('Reviews', RoutePaths.reviews),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.appName.toUpperCase(),
                    style: AppTypography.titleLarge.copyWith(
                      letterSpacing: 3,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    AppConstants.hotelName,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),

            // ── Nav Links ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: _navItems
                    .map((item) => ListTile(
                          title: Text(item.label),
                          onTap: () {
                            Navigator.pop(context);
                            context.go(item.path);
                          },
                        ))
                    .toList(),
              ),
            ),

            // ── CTA ──
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.booking);
                    },
                    child: const Text('Book Now'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.login);
                    },
                    child: const Text('Staff Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String path;
  const _NavItem(this.label, this.path);
}
