import '../../models/room.dart';
import '../../models/booking.dart';
import '../../models/guest.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../models/review.dart';
import '../../models/user.dart';
import '../api/api_service.dart';
import 'mock_data.dart';

/// Simulated network delay to mimic real API behavior.
/// This ensures the UI properly handles loading states during development.
Future<T> _simulateDelay<T>(T value) async {
  await Future.delayed(const Duration(milliseconds: 600));
  return value;
}

// ─── Auth Mock ─────────────────────────────────────────────────────
class MockAuthService implements AuthService {
  User? _currentUser;

  @override
  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.contains('admin')) return _currentUser = MockData.adminUser;
    if (email.contains('staff')) return _currentUser = MockData.staffUser;

    return null;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async => _simulateDelay(_currentUser);
}

// ─── Room Mock ─────────────────────────────────────────────────────
class MockRoomService implements RoomService {
  @override
  Future<List<Room>> getAllRooms() => _simulateDelay(MockData.rooms);

  @override
  Future<Room> getRoomById(String id) => _simulateDelay(
        MockData.rooms.firstWhere((r) => r.id == id),
      );

  @override
  Future<List<Room>> getFeaturedRooms() => _simulateDelay(
        MockData.rooms.where((r) => r.isFeatured).toList(),
      );

  @override
  Future<List<Room>> checkAvailability(DateTime checkIn, DateTime checkOut) =>
      _simulateDelay(
        MockData.rooms
            .where((r) => r.status == RoomStatus.available)
            .toList(),
      );

  @override
  Future<Room> createRoom(Room room) => _simulateDelay(room);

  @override
  Future<Room> updateRoom(Room room) => _simulateDelay(room);

  @override
  Future<void> deleteRoom(String id) => _simulateDelay(null);
}

// ─── Booking Mock ──────────────────────────────────────────────────
class MockBookingService implements BookingService {
  @override
  Future<List<Booking>> getAllBookings() => _simulateDelay(MockData.bookings);

  @override
  Future<Booking> getBookingById(String id) => _simulateDelay(
        MockData.bookings.firstWhere((b) => b.id == id),
      );

  @override
  Future<Booking> createBooking(Booking booking) => _simulateDelay(booking);

  @override
  Future<Booking> updateBookingStatus(String id, BookingStatus status) async {
    final booking = MockData.bookings.firstWhere((b) => b.id == id);
    return _simulateDelay(booking);
  }

  @override
  Future<List<Booking>> getBookingsByDate(DateTime date) => _simulateDelay(
        MockData.bookings
            .where((b) =>
                b.checkIn.isBefore(date.add(const Duration(days: 1))) &&
                b.checkOut.isAfter(date))
            .toList(),
      );

  @override
  Future<List<Booking>> getTodayCheckIns() => _simulateDelay(
        MockData.bookings
            .where((b) => b.status == BookingStatus.confirmed)
            .toList(),
      );

  @override
  Future<List<Booking>> getTodayCheckOuts() => _simulateDelay(
        MockData.bookings
            .where((b) => b.status == BookingStatus.checkedIn)
            .toList(),
      );
}

// ─── Guest Mock ────────────────────────────────────────────────────
class MockGuestService implements GuestService {
  @override
  Future<List<Guest>> getAllGuests() => _simulateDelay(MockData.guests);

  @override
  Future<Guest> getGuestById(String id) => _simulateDelay(
        MockData.guests.firstWhere((g) => g.id == id),
      );

  @override
  Future<Guest> createGuest(Guest guest) => _simulateDelay(guest);

  @override
  Future<Guest> updateGuest(Guest guest) => _simulateDelay(guest);

  @override
  Future<void> deleteGuest(String id) => _simulateDelay(null);
}

// ─── Invoice Mock ──────────────────────────────────────────────────
class MockInvoiceService implements InvoiceService {
  @override
  Future<List<Invoice>> getAllInvoices() => _simulateDelay(MockData.invoices);

  @override
  Future<Invoice> getInvoiceById(String id) => _simulateDelay(
        MockData.invoices.firstWhere((i) => i.id == id),
      );

  @override
  Future<Invoice> createInvoice(Invoice invoice) => _simulateDelay(invoice);

  @override
  Future<Invoice> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final invoice = MockData.invoices.firstWhere((i) => i.id == id);
    return _simulateDelay(invoice);
  }

  @override
  Future<List<Invoice>> getInvoicesByBooking(String bookingId) => _simulateDelay(
        MockData.invoices.where((i) => i.bookingId == bookingId).toList(),
      );
}

// ─── Payment Mock ──────────────────────────────────────────────────
class MockPaymentService implements PaymentService {
  @override
  Future<List<Payment>> getAllPayments() => _simulateDelay(MockData.payments);

  @override
  Future<Payment> recordPayment(Payment payment) => _simulateDelay(payment);

  @override
  Future<List<Payment>> getPaymentsByInvoice(String invoiceId) => _simulateDelay(
        MockData.payments.where((p) => p.invoiceId == invoiceId).toList(),
      );

  @override
  Future<double> getTotalRevenue() => _simulateDelay(
        MockData.payments
            .where((p) => p.status == PaymentStatus.completed)
            .fold(0.0, (sum, p) => sum + p.amount),
      );
}

// ─── Review Mock ───────────────────────────────────────────────────
class MockReviewService implements ReviewService {
  @override
  Future<List<Review>> getAllReviews() => _simulateDelay(MockData.reviews);

  @override
  Future<Review> submitReview(Review review) => _simulateDelay(review);

  @override
  Future<double> getAverageRating() => _simulateDelay(
        MockData.reviews.fold(0.0, (sum, r) => sum + r.rating) /
            MockData.reviews.length,
      );
}

// ─── Report Mock ───────────────────────────────────────────────────
class MockReportService implements ReportService {
  @override
  Future<Map<String, dynamic>> getBookingReport(DateTime from, DateTime to) =>
      _simulateDelay({
        'total_bookings': 156,
        'confirmed': 98,
        'cancelled': 12,
        'pending': 46,
        'trend': [
          {'month': 'Sep', 'count': 22},
          {'month': 'Oct', 'count': 28},
          {'month': 'Nov', 'count': 35},
          {'month': 'Dec', 'count': 42},
          {'month': 'Jan', 'count': 38},
          {'month': 'Feb', 'count': 31},
        ],
      });

  @override
  Future<Map<String, dynamic>> getOccupancyReport(DateTime from, DateTime to) =>
      _simulateDelay({
        'average_occupancy': 72.5,
        'current_occupancy': 68.0,
        'total_rooms': 6,
        'occupied_rooms': 4,
        'trend': [
          {'month': 'Sep', 'rate': 65.0},
          {'month': 'Oct', 'rate': 70.0},
          {'month': 'Nov', 'rate': 78.0},
          {'month': 'Dec', 'rate': 85.0},
          {'month': 'Jan', 'rate': 72.0},
          {'month': 'Feb', 'rate': 68.0},
        ],
      });

  @override
  Future<Map<String, dynamic>> getRevenueReport(DateTime from, DateTime to) =>
      _simulateDelay({
        'total_revenue': 127450.0,
        'monthly_average': 21241.67,
        'trend': [
          {'month': 'Sep', 'amount': 18200.0},
          {'month': 'Oct', 'amount': 21500.0},
          {'month': 'Nov', 'amount': 24800.0},
          {'month': 'Dec', 'amount': 28900.0},
          {'month': 'Jan', 'amount': 22050.0},
          {'month': 'Feb', 'amount': 12000.0},
        ],
      });
}

// ─── Staff Management Mock ─────────────────────────────────────────
class MockStaffManagementService implements StaffManagementService {
  @override
  Future<List<User>> getAllStaff() => _simulateDelay(MockData.staffList);

  @override
  Future<User> createStaff(User staff) => _simulateDelay(staff);

  @override
  Future<User> updateStaff(User staff) => _simulateDelay(staff);

  @override
  Future<void> deactivateStaff(String id) => _simulateDelay(null);
}
