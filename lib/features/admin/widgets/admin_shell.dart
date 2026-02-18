import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routing/app_router.dart';
import '../../../providers/providers.dart';

/// Sidebar-based shell for Admin module.
class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static const _navItems = [
    _NavItem(Icons.dashboard_outlined, 'Dashboard', RoutePaths.adminDashboard),
    _NavItem(Icons.king_bed_outlined, 'Rooms', RoutePaths.adminRooms),
    _NavItem(Icons.book_outlined, 'Bookings', RoutePaths.adminBookings),
    _NavItem(Icons.people_outline, 'Guests', RoutePaths.adminGuests),
    _NavItem(Icons.swap_horiz, 'Check In / Out', RoutePaths.adminCheckinOut),
    _NavItem(Icons.receipt_long_outlined, 'Invoices', RoutePaths.adminInvoices),
    _NavItem(Icons.payment_outlined, 'Payments', RoutePaths.adminPayments),
    _NavItem(Icons.bar_chart, 'Reports', RoutePaths.adminReports),
    _NavItem(Icons.badge_outlined, 'Staff', RoutePaths.adminStaff),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = Responsive.isDesktop(context);
    final currentPath = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context, ref, currentPath),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context, ref, isDesktop),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop
          ? null
          : Drawer(child: _buildSidebar(context, ref, currentPath)),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref, bool isDesktop) {
    final user = ref.watch(authProvider);
    return Container(
      height: AppSpacing.navBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!isDesktop)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          if (!isDesktop) const SizedBox(width: AppSpacing.sm),
          Text(
            'Admin Portal',
            style: AppTypography.titleMedium.copyWith(color: AppColors.primary),
          ),
          const Spacer(),
          if (user != null) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.accent,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'A',
                style: AppTypography.labelSmall.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isDesktop)
              Text(user.name, style: AppTypography.bodySmall),
          ],
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go(RoutePaths.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, String currentPath) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.primary,
      child: Column(
        children: [
          Container(
            height: AppSpacing.navBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(Icons.hotel, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'StaySite',
                      style: AppTypography.titleSmall
                          .copyWith(color: AppColors.white),
                    ),
                    Text(
                      'Admin Portal',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _navItems.map((item) {
                final selected = currentPath == item.path;
                return _buildNavTile(context, item, selected);
              }).toList(),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: Icon(Icons.language,
                color: AppColors.white.withValues(alpha: 0.6), size: 20),
            title: Text(
              'Back to Website',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.white.withValues(alpha: 0.6),
              ),
            ),
            dense: true,
            onTap: () => context.go(RoutePaths.home),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, _NavItem item, bool selected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent.withValues(alpha: 0.15) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: selected
              ? AppColors.accent
              : AppColors.white.withValues(alpha: 0.7),
          size: 20,
        ),
        title: Text(
          item.label,
          style: AppTypography.bodySmall.copyWith(
            color: selected
                ? AppColors.accent
                : AppColors.white.withValues(alpha: 0.9),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        dense: true,
        selected: selected,
        onTap: () {
          context.go(item.path);
          if (!Responsive.isDesktop(context)) {
            Navigator.of(context).maybePop();
          }
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.label, this.path);
}
