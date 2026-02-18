import '../../models/room.dart';
import '../../models/booking.dart';
import '../../models/guest.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../models/review.dart';
import '../../models/user.dart';

/// Abstract API service contracts.
///
/// These interfaces define what the backend team must implement.
/// The frontend uses mock implementations during development,
/// and the backend swaps in real HTTP clients later.
///
/// This is the key architectural boundary — UI code never
/// touches HTTP directly; it only depends on these abstractions.

// ─── Auth ──────────────────────────────────────────────────────────
abstract class AuthService {
  Future<User?> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
}

// ─── Rooms ─────────────────────────────────────────────────────────
abstract class RoomService {
  Future<List<Room>> getAllRooms();
  Future<Room> getRoomById(String id);
  Future<List<Room>> getFeaturedRooms();
  Future<List<Room>> checkAvailability(DateTime checkIn, DateTime checkOut);
  Future<Room> createRoom(Room room);
  Future<Room> updateRoom(Room room);
  Future<void> deleteRoom(String id);
}

// ─── Bookings ──────────────────────────────────────────────────────
abstract class BookingService {
  Future<List<Booking>> getAllBookings();
  Future<Booking> getBookingById(String id);
  Future<Booking> createBooking(Booking booking);
  Future<Booking> updateBookingStatus(String id, BookingStatus status);
  Future<List<Booking>> getBookingsByDate(DateTime date);
  Future<List<Booking>> getTodayCheckIns();
  Future<List<Booking>> getTodayCheckOuts();
}

// ─── Guests ────────────────────────────────────────────────────────
abstract class GuestService {
  Future<List<Guest>> getAllGuests();
  Future<Guest> getGuestById(String id);
  Future<Guest> createGuest(Guest guest);
  Future<Guest> updateGuest(Guest guest);
  Future<void> deleteGuest(String id);
}

// ─── Invoices ──────────────────────────────────────────────────────
abstract class InvoiceService {
  Future<List<Invoice>> getAllInvoices();
  Future<Invoice> getInvoiceById(String id);
  Future<Invoice> createInvoice(Invoice invoice);
  Future<Invoice> updateInvoiceStatus(String id, InvoiceStatus status);
  Future<List<Invoice>> getInvoicesByBooking(String bookingId);
}

// ─── Payments ──────────────────────────────────────────────────────
abstract class PaymentService {
  Future<List<Payment>> getAllPayments();
  Future<Payment> recordPayment(Payment payment);
  Future<List<Payment>> getPaymentsByInvoice(String invoiceId);
  Future<double> getTotalRevenue();
}

// ─── Reviews ───────────────────────────────────────────────────────
abstract class ReviewService {
  Future<List<Review>> getAllReviews();
  Future<Review> submitReview(Review review);
  Future<double> getAverageRating();
}

// ─── Reports (Admin only) ──────────────────────────────────────────
abstract class ReportService {
  Future<Map<String, dynamic>> getBookingReport(DateTime from, DateTime to);
  Future<Map<String, dynamic>> getOccupancyReport(DateTime from, DateTime to);
  Future<Map<String, dynamic>> getRevenueReport(DateTime from, DateTime to);
}

// ─── Staff Management (Admin only) ────────────────────────────────
abstract class StaffManagementService {
  Future<List<User>> getAllStaff();
  Future<User> createStaff(User staff);
  Future<User> updateStaff(User staff);
  Future<void> deactivateStaff(String id);
}
