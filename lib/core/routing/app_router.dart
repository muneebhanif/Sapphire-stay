import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_booking_management_screen.dart';
import '../../features/admin/screens/admin_guest_management_screen.dart';
import '../../features/admin/screens/admin_invoice_screen.dart';
import '../../features/admin/screens/admin_payment_screen.dart';
import '../../features/admin/screens/admin_reports_screen.dart';
import '../../features/admin/screens/admin_room_management_screen.dart';
import '../../features/admin/screens/admin_staff_management_screen.dart';
import '../../features/admin/screens/admin_checkin_checkout_screen.dart';
import '../../features/admin/widgets/admin_shell.dart';
import '../../features/customer/screens/about_screen.dart';
import '../../features/customer/screens/booking_confirmation_screen.dart';
import '../../features/customer/screens/booking_screen.dart';
import '../../features/customer/screens/contact_screen.dart';
import '../../features/customer/screens/gallery_screen.dart';
import '../../features/customer/screens/home_screen.dart';
import '../../features/customer/screens/room_detail_screen.dart';
import '../../features/customer/screens/rooms_screen.dart';
import '../../features/customer/screens/reviews_screen.dart';
import '../../features/customer/screens/services_screen.dart';
import '../../features/customer/widgets/customer_shell.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/staff/screens/staff_dashboard_screen.dart';
import '../../features/staff/screens/staff_booking_screen.dart';
import '../../features/staff/screens/staff_walkin_screen.dart';
import '../../features/staff/screens/staff_checkin_checkout_screen.dart';
import '../../features/staff/screens/staff_invoice_screen.dart';
import '../../features/staff/screens/staff_payment_screen.dart';
import '../../features/staff/widgets/staff_shell.dart';

/// Centralized route path constants.
///
/// Grouping paths here prevents typo bugs and gives IDE
/// autocompletion when navigating.
abstract final class RoutePaths {
  // ── Customer ──
  static const String home = '/';
  static const String about = '/about';
  static const String rooms = '/rooms';
  static const String roomDetail = '/rooms/:id';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String gallery = '/gallery';
  static const String services = '/services';
  static const String contact = '/contact';
  static const String reviews = '/reviews';

  // ── Auth ──
  static const String login = '/login';

  // ── Staff ──
  static const String staffDashboard = '/staff';
  static const String staffBookings = '/staff/bookings';
  static const String staffWalkin = '/staff/walkin';
  static const String staffCheckinCheckout = '/staff/checkin-checkout';
  static const String staffCheckinOut = staffCheckinCheckout; // alias
  static const String staffInvoice = '/staff/invoices';
  static const String staffInvoices = staffInvoice; // alias
  static const String staffPayments = '/staff/payments';

  // ── Admin ──
  static const String adminDashboard = '/admin';
  static const String adminRooms = '/admin/rooms';
  static const String adminBookings = '/admin/bookings';
  static const String adminGuests = '/admin/guests';
  static const String adminCheckinCheckout = '/admin/checkin-checkout';
  static const String adminCheckinOut = adminCheckinCheckout; // alias
  static const String adminInvoices = '/admin/invoices';
  static const String adminPayments = '/admin/payments';
  static const String adminReports = '/admin/reports';
  static const String adminStaff = '/admin/staff';
}

/// GoRouter provider — reactive to auth state changes.
///
/// Using [GoRouter] because:
///   1. Declarative, URL-based routing ideal for web (deep linking, browser back button).
///   2. ShellRoute enables persistent layouts (sidebar, nav bar) per module.
///   3. Redirect guards integrate cleanly with Riverpod auth state.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    debugLogDiagnostics: true,

    // ── Error page ──
    errorPageBuilder: (context, state) => MaterialPage(
      key: state.pageKey,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '404 — Page Not Found',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RoutePaths.home),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    ),

    routes: [
      // ─── Customer Module (public, with shared shell) ──────────
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.about,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AboutScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.rooms,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RoomsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.roomDetail,
            pageBuilder: (context, state) => NoTransitionPage(
              child: RoomDetailScreen(roomId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: RoutePaths.booking,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookingScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.bookingConfirmation,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookingConfirmationScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.gallery,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: GalleryScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.services,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ServicesScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.contact,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.reviews,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ReviewsScreen(),
            ),
          ),
        ],
      ),

      // ─── Auth ──────────────────────────────────────────────────
      GoRoute(
        path: RoutePaths.login,
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginScreen(),
        ),
      ),

      // ─── Staff Module (restricted, with sidebar shell) ────────
      ShellRoute(
        builder: (context, state, child) => StaffShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.staffDashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.staffBookings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffBookingScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.staffWalkin,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffWalkinScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.staffCheckinCheckout,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffCheckinCheckoutScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.staffInvoice,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffInvoiceScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.staffPayments,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StaffPaymentScreen(),
            ),
          ),
        ],
      ),

      // ─── Admin Module (full access, with sidebar shell) ───────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.adminDashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminDashboardScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminRooms,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminRoomManagementScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminBookings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminBookingManagementScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminGuests,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminGuestManagementScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminCheckinCheckout,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminCheckinCheckoutScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminInvoices,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminInvoiceScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminPayments,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminPaymentScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminReports,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminReportsScreen(),
            ),
          ),
          GoRoute(
            path: RoutePaths.adminStaff,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AdminStaffManagementScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
