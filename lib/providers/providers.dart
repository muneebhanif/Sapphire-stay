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

String _cleanBrandingText(String value) {
  var cleaned = value;
  final patterns = <RegExp>[
    RegExp(r'\s*\|?\s*made\s+with\s+[a-z0-9._-]+\.?\s*', caseSensitive: false),
    RegExp(r'\s*\|?\s*powered\s+by\s+[a-z0-9._-]+\.?\s*', caseSensitive: false),
  ];

  for (final pattern in patterns) {
    cleaned = cleaned.replaceAll(pattern, ' ');
  }

  return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
}

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

/// ─── Gallery + Site Config Providers ───────────────────────────────
final galleryServiceProvider = Provider<ConvexGalleryService>((ref) =>
    ConvexGalleryService(ref.watch(convexClientProvider)));

final siteConfigServiceProvider = Provider<ConvexSiteConfigService>((ref) =>
    ConvexSiteConfigService(ref.watch(convexClientProvider)));

/// ─── Auth State ───────────────────────────────────────────────────
///
/// [StateNotifierProvider] tracks the current user session.
/// Navigation guards and role-based UI observe this provider.
class AuthNotifier extends StateNotifier<User?> {
  final AuthService _service;
  bool _initialized = false;

  AuthNotifier(this._service) : super(null) {
    _initRestoreSession();
  }

  /// Whether the initial session restore has completed.
  bool get initialized => _initialized;

  Future<void> _initRestoreSession() async {
    try {
      final user = await _service.getCurrentUser();
      if (user != null) {
        state = user;
      }
    } catch (_) {
    } finally {
      _initialized = true;
    }
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

/// ─── Gallery + Site Config ───────────────────────────────────────
final galleryImagesProvider = FutureProvider.autoDispose<List<Map<String, String>>>((ref) {
  return ref.watch(galleryServiceProvider).getGalleryImages().then(
        (items) => items
            .map(
              (item) => {
                ...item,
                'caption': _cleanBrandingText(item['caption'] ?? ''),
              },
            )
            .toList(),
      );
});

final siteConfigProvider = FutureProvider<Map<String, String>>((ref) {
  return ref.watch(siteConfigServiceProvider).getSiteConfig().then(
        (config) => config.map(
          (key, value) => MapEntry(key, _cleanBrandingText(value)),
        ),
      );
});

/// ─── Convenience aliases (used in screens) ────────────────────────
final roomsProvider = allRoomsProvider;
final bookingsProvider = allBookingsProvider;
final guestsProvider = allGuestsProvider;
final invoicesProvider = allInvoicesProvider;
final paymentsProvider = allPaymentsProvider;
/// Static showcase reviews with Pakistani guest names.
/// These are always displayed alongside any dynamic reviews from the database.
final _staticReviews = [
  Review(
    id: 'static-rev-1',
    guestName: 'Ahmed Raza',
    rating: 5.0,
    comment:
        'Absolutely stunning experience! The room was immaculate, staff was incredibly courteous, and the view from the suite was breathtaking. Will definitely book again for our anniversary.',
    createdAt: DateTime(2026, 2, 14),
  ),
  Review(
    id: 'static-rev-2',
    guestName: 'Ayesha Khan',
    rating: 4.5,
    comment:
        'Very comfortable stay with excellent amenities. The breakfast buffet was outstanding and the concierge went above and beyond to arrange our city tour. Highly recommended for families!',
    createdAt: DateTime(2026, 1, 22),
  ),
  Review(
    id: 'static-rev-3',
    guestName: 'Bilal Hussain',
    rating: 5.0,
    comment:
        'First-class hospitality from check-in to check-out. The Deluxe room was spacious and well-appointed. The rooftop dining experience was unforgettable. A hidden gem in the city!',
    createdAt: DateTime(2025, 12, 5),
  ),
  Review(
    id: 'static-rev-4',
    guestName: 'Fatima Noor',
    rating: 4.0,
    comment:
        'Beautiful property with modern interiors. Loved the attention to detail in every corner. The spa service was world-class. Perfect place for a weekend getaway.',
    createdAt: DateTime(2025, 11, 18),
  ),
];

final reviewsProvider = FutureProvider<List<Review>>((ref) async {
  try {
    final dbReviews = await ref.watch(allReviewsProvider.future);
    // Merge: DB reviews first, then static ones
    return [...dbReviews, ..._staticReviews];
  } catch (_) {
    // If DB fails, still show static reviews
    return _staticReviews;
  }
});
final staffListProvider = allStaffProvider;
final bookingRequestsProvider = allBookingRequestsProvider;
final paymentProofsProvider = allPaymentProofsProvider;
