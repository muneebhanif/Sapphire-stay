import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/booking.dart';
import '../models/guest.dart';
import '../models/invoice.dart';
import '../models/payment.dart';
import '../models/review.dart';
import '../models/room.dart';
import '../models/user.dart';
import '../models/booking_request.dart';
import '../models/payment_proof.dart';
import '../services/api/api_service.dart';
import '../core/services/convex_api_service.dart';
import '../core/services/convex_client_provider.dart';
import '../core/services/convex_storage_service.dart';

/// ─── Service Providers ────────────────────────────────────────────
///
/// All providers now use Convex-backed implementations.
/// No mock data anywhere — everything comes from the database.

final authServiceProvider = Provider<AuthService>((ref) =>
    ConvexAuthService(ref.watch(convexClientProvider)));
final roomServiceProvider = Provider<RoomService>((ref) => ConvexRoomService(ref.watch(convexClientProvider)));
final bookingServiceProvider = Provider<BookingService>((ref) => ConvexBookingService(ref.watch(convexClientProvider)));
final guestServiceProvider = Provider<GuestService>((ref) => ConvexGuestService(ref.watch(convexClientProvider)));
final invoiceServiceProvider = Provider<InvoiceService>((ref) => ConvexInvoiceService(ref.watch(convexClientProvider)));
final paymentServiceProvider = Provider<PaymentService>((ref) => ConvexPaymentService(ref.watch(convexClientProvider)));
final reviewServiceProvider = Provider<ReviewService>((ref) => ConvexReviewService(ref.watch(convexClientProvider)));
final reportServiceProvider = Provider<ReportService>((ref) => ConvexReportService(ref.watch(convexClientProvider)));
final staffMgmtServiceProvider = Provider<StaffManagementService>(
    (ref) => ConvexStaffManagementService(ref.watch(convexClientProvider)));
final bookingRequestServiceProvider = Provider<BookingRequestService>((ref) {
  final client = ref.watch(convexClientProvider);
  return ConvexBookingRequestService(client);
});

final paymentProofServiceProvider = Provider<PaymentProofService>((ref) {
  final client = ref.watch(convexClientProvider);
  final storage = ref.watch(convexStorageServiceProvider);
  return ConvexPaymentProofService(client, storage);
});

/// ─── Gallery, Services, Site Config Providers ─────────────────────
final galleryServiceProvider = Provider<ConvexGalleryService>((ref) =>
    ConvexGalleryService(ref.watch(convexClientProvider)));

final hotelServicesServiceProvider = Provider<ConvexHotelServicesService>((ref) =>
    ConvexHotelServicesService(ref.watch(convexClientProvider)));

final siteConfigServiceProvider = Provider<ConvexSiteConfigService>((ref) =>
    ConvexSiteConfigService(ref.watch(convexClientProvider)));

/// ─── Auth State ───────────────────────────────────────────────────
///
/// [StateNotifierProvider] tracks the current user session.
/// Navigation guards and role-based UI observe this provider.
class AuthNotifier extends StateNotifier<User?> {
  final AuthService _service;

  AuthNotifier(this._service) : super(null) {
    _initRestoreSession();
  }

  Future<void> _initRestoreSession() async {
    try {
      final user = await _service.getCurrentUser();
      if (user != null) {
        state = user;
      }
    } catch (_) {}
  }

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

/// ─── Booking Request + Payment Proof Providers ───────────────────
final allBookingRequestsProvider = FutureProvider<List<BookingRequest>>((ref) {
  return ref.watch(bookingRequestServiceProvider).getAllBookingRequests();
});

final allPaymentProofsProvider = FutureProvider<List<PaymentProof>>((ref) {
  return ref.watch(paymentProofServiceProvider).getAllPaymentProofs();
});

final pendingPaymentProofsProvider = FutureProvider<List<PaymentProof>>((ref) {
  return ref.watch(paymentProofServiceProvider).getPendingPaymentProofs();
});

/// ─── Gallery, Services, Site Config ──────────────────────────────
final galleryImagesProvider = FutureProvider<List<Map<String, String>>>((ref) {
  return ref.watch(galleryServiceProvider).getGalleryImages();
});

final hotelServicesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(hotelServicesServiceProvider).getHotelServices();
});

final siteConfigProvider = FutureProvider<Map<String, String>>((ref) {
  return ref.watch(siteConfigServiceProvider).getSiteConfig();
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
final bookingRequestsProvider = allBookingRequestsProvider;
final paymentProofsProvider = allPaymentProofsProvider;
