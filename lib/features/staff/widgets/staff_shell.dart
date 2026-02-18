import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/routing/app_router.dart';
import '../../../providers/providers.dart';

/// Sidebar‐based shell for Staff module.
class StaffShell extends ConsumerStatefulWidget {
  final Widget child;
  const StaffShell({super.key, required this.child});

  @override
  ConsumerState<StaffShell> createState() => _StaffShellState();
}

class _StaffShellState extends ConsumerState<StaffShell> {
  bool _drawerOpen = false;

  static const _navItems = [
    _NavItem(Icons.dashboard_outlined, 'Dashboard', RoutePaths.staffDashboard),
    _NavItem(Icons.book_outlined, 'Bookings', RoutePaths.staffBookings),
    _NavItem(Icons.person_add_outlined, 'Walk-in', RoutePaths.staffWalkin),
    _NavItem(Icons.swap_horiz, 'Check In / Out', RoutePaths.staffCheckinOut),
    _NavItem(Icons.receipt_long_outlined, 'Invoices', RoutePaths.staffInvoices),
    _NavItem(Icons.payment_outlined, 'Payments', RoutePaths.staffPayments),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final currentPath = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar (desktop) ──
          if (isDesktop)
            _buildSidebar(currentPath),

          // ── Main content ──
          Expanded(
            child: Column(
              children: [
                _buildTopBar(isDesktop),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
      // ── Drawer (mobile/tablet) ──
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(currentPath)),
    );
  }

  Widget _buildTopBar(bool isDesktop) {
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
            'Staff Portal',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          if (user != null) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'S',
                style: AppTypography.labelSmall.copyWith(color: AppColors.white),
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

  Widget _buildSidebar(String currentPath) {
    return Container(
      width: AppSpacing.sidebarWidth,
      color: AppColors.primary,
      child: Column(
        children: [
          // ── Brand ──
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
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      'Staff Portal',
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

          // ── Nav items ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              children: _navItems.map((item) {
                final selected = currentPath == item.path;
                return _buildNavTile(item, selected);
              }).toList(),
            ),
          ),

          // ── Back to website ──
          const Divider(color: Colors.white12, height: 1),
          ListTile(
            leading: Icon(Icons.language, color: AppColors.white.withValues(alpha: 0.6), size: 20),
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

  Widget _buildNavTile(_NavItem item, bool selected) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent.withValues(alpha: 0.15) : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: selected ? AppColors.accent : AppColors.white.withValues(alpha: 0.7),
          size: 20,
        ),
        title: Text(
          item.label,
          style: AppTypography.bodySmall.copyWith(
            color: selected ? AppColors.accent : AppColors.white.withValues(alpha: 0.9),
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        dense: true,
        selected: selected,
        onTap: () {
          context.go(item.path);
          // Close drawer on mobile
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
