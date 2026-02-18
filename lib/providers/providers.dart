import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/guest.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/review.dart';
import '../models/room.dart';
import '../models/user.dart';
import '../services/api/api_service.dart';
import '../services/mock/mock_service.dart';

/// ─── Service Providers ────────────────────────────────────────────
///
/// These providers expose the mock implementations.
/// When the real backend is ready, swap [Mock*Service] with the
/// HTTP implementation — ZERO changes needed in UI code.

final authServiceProvider = Provider<AuthService>((_) => MockAuthService());
final roomServiceProvider = Provider<RoomService>((_) => MockRoomService());
final bookingServiceProvider = Provider<BookingService>((_) => MockBookingService());
final guestServiceProvider = Provider<GuestService>((_) => MockGuestService());
final invoiceServiceProvider = Provider<InvoiceService>((_) => MockInvoiceService());
final paymentServiceProvider = Provider<PaymentService>((_) => MockPaymentService());
final reviewServiceProvider = Provider<ReviewService>((_) => MockReviewService());
final reportServiceProvider = Provider<ReportService>((_) => MockReportService());
final staffMgmtServiceProvider = Provider<StaffManagementService>(
    (_) => MockStaffManagementService());

/// ─── Auth State ───────────────────────────────────────────────────
///
/// [StateNotifierProvider] tracks the current user session.
/// Navigation guards and role-based UI observe this provider.
class AuthNotifier extends StateNotifier<User?> {
  final AuthService _service;

  AuthNotifier(this._service) : super(null);

  Future<User?> login(String email, String password) async {
    final user = await _service.login(email, password);
    state = user;
    return user;
  }

  void setUser(User user) {
    state = user;
  }

  Future<void> logout() async {
    await _service.logout();
    state = null;
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

/// ─── Room Providers ───────────────────────────────────────────────
final allRoomsProvider = FutureProvider<List<Room>>((ref) {
  return ref.watch(roomServiceProvider).getAllRooms();
});

final featuredRoomsProvider = FutureProvider<List<Room>>((ref) {
  return ref.watch(roomServiceProvider).getFeaturedRooms();
});

final roomDetailProvider = FutureProvider.family<Room, String>((ref, id) {
  return ref.watch(roomServiceProvider).getRoomById(id);
});

/// ─── Booking Providers ────────────────────────────────────────────
final allBookingsProvider = FutureProvider<List<Booking>>((ref) {
  return ref.watch(bookingServiceProvider).getAllBookings();
});

final todayCheckInsProvider = FutureProvider<List<Booking>>((ref) {
  return ref.watch(bookingServiceProvider).getTodayCheckIns();
});

final todayCheckOutsProvider = FutureProvider<List<Booking>>((ref) {
  return ref.watch(bookingServiceProvider).getTodayCheckOuts();
});

/// ─── Guest Providers ──────────────────────────────────────────────
final allGuestsProvider = FutureProvider<List<Guest>>((ref) {
  return ref.watch(guestServiceProvider).getAllGuests();
});

/// ─── Invoice Providers ────────────────────────────────────────────
final allInvoicesProvider = FutureProvider<List<Invoice>>((ref) {
  return ref.watch(invoiceServiceProvider).getAllInvoices();
});

/// ─── Payment Providers ────────────────────────────────────────────
final allPaymentsProvider = FutureProvider<List<Payment>>((ref) {
  return ref.watch(paymentServiceProvider).getAllPayments();
});

final totalRevenueProvider = FutureProvider<double>((ref) {
  return ref.watch(paymentServiceProvider).getTotalRevenue();
});

/// ─── Review Providers ─────────────────────────────────────────────
final allReviewsProvider = FutureProvider<List<Review>>((ref) {
  return ref.watch(reviewServiceProvider).getAllReviews();
});

final averageRatingProvider = FutureProvider<double>((ref) {
  return ref.watch(reviewServiceProvider).getAverageRating();
});

/// ─── Report Providers ─────────────────────────────────────────────
final bookingReportProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(reportServiceProvider).getBookingReport(
        DateTime.now().subtract(const Duration(days: 180)),
        DateTime.now(),
      );
});

final occupancyReportProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(reportServiceProvider).getOccupancyReport(
        DateTime.now().subtract(const Duration(days: 180)),
        DateTime.now(),
      );
});

final revenueReportProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.watch(reportServiceProvider).getRevenueReport(
        DateTime.now().subtract(const Duration(days: 180)),
        DateTime.now(),
      );
});

/// ─── Staff Management Provider ────────────────────────────────────
final allStaffProvider = FutureProvider<List<User>>((ref) {
  return ref.watch(staffMgmtServiceProvider).getAllStaff();
});

/// ─── Convenience aliases (used in screens) ────────────────────────
/// These keep screen code concise while maintaining backward compat.
final roomsProvider = allRoomsProvider;
final bookingsProvider = allBookingsProvider;
final guestsProvider = allGuestsProvider;
final invoicesProvider = allInvoicesProvider;
final paymentsProvider = allPaymentsProvider;
final reviewsProvider = allReviewsProvider;
final staffListProvider = allStaffProvider;
