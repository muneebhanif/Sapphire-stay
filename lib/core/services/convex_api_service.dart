import 'package:shared_preferences/shared_preferences.dart';
import '../../models/review.dart';
import '../../models/user.dart';
import '../../models/booking_request.dart';
import '../../models/payment_proof.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import '../../models/guest.dart';
import '../../models/invoice.dart';
import '../../models/payment.dart';
import '../../services/api/api_service.dart';
import 'convex_client_provider.dart';
import 'convex_storage_service.dart';

class ConvexBookingRequestService implements BookingRequestService {
  final ConvexClient _client;

  ConvexBookingRequestService(this._client);

  @override
  Future<BookingRequest> createBookingRequest(BookingRequest request) async {
    final userRefs = await _client.query('users:getFirstUsers');
    final customerId = (userRefs as Map)['customerId'];
    final roomId = (userRefs)['roomId']; // using hardcoded room for demo if request logic fails
    final effectiveRoomId = request.roomId.isNotEmpty ? request.roomId : (roomId as String);

    final id = await _client.mutation('bookingRequests:createBookingRequest', {
      'customerId': customerId,
      'roomId': effectiveRoomId,
      'checkIn': request.checkIn.millisecondsSinceEpoch,
      'checkOut': request.checkOut.millisecondsSinceEpoch,
      'guestsCount': request.guestsCount,
      'requestedTotalPkr': request.requestedTotalPkr,
      'notes': request.notes,
    });
    
    return BookingRequest(
      id: id.toString(),
      customerName: request.customerName,
      customerEmail: request.customerEmail,
      customerPhone: request.customerPhone,
      roomId: request.roomId,
      roomNumber: request.roomNumber,
      checkIn: request.checkIn,
      checkOut: request.checkOut,
      guestsCount: request.guestsCount,
      requestedTotalPkr: request.requestedTotalPkr,
      status: BookingRequestStatus.pendingPayment,
      notes: request.notes,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<BookingRequest>> getAllBookingRequests() async {
    final results = await _client.query('bookingRequests:getAllBookingRequests');
    return (results as List).map((r) => _mapToBookingRequest(r as Map<String, dynamic>)).toList();
  }

  BookingRequest _mapToBookingRequest(Map<String, dynamic> data) {
    return BookingRequest(
      id: data['_id'] as String,
      customerName: data['customerName'] as String? ?? 'Unknown',
      customerEmail: data['customerEmail'] as String? ?? '',
      customerPhone: data['customerPhone'] as String? ?? '',
      roomId: data['roomId'] as String? ?? '',
      roomNumber: data['roomNumber'] as String? ?? 'Unassigned',
      checkIn: DateTime.fromMillisecondsSinceEpoch(data['checkIn'] as int),
      checkOut: DateTime.fromMillisecondsSinceEpoch(data['checkOut'] as int),
      guestsCount: data['guestsCount'] as int,
      requestedTotalPkr: data['requestedTotalPkr'] as int,
      status: _mapStatus(data['status'] as String),
      notes: data['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
    );
  }

  BookingRequestStatus _mapStatus(String status) {
    switch (status) {
      case 'pending_payment': return BookingRequestStatus.pendingPayment;
      case 'payment_submitted': return BookingRequestStatus.paymentSubmitted;
      case 'verified': return BookingRequestStatus.verified;
      case 'rejected': return BookingRequestStatus.rejected;
      case 'expired': return BookingRequestStatus.expired;
      default: return BookingRequestStatus.pendingPayment;
    }
  }
}

class ConvexPaymentProofService implements PaymentProofService {
  final ConvexClient _client;
  final ConvexStorageService _storageService;

  ConvexPaymentProofService(this._client, this._storageService);

  @override
  Future<PaymentProof> submitPaymentProof(PaymentProof proof) async {
    final userRefs = await _client.query('users:getFirstUsers');
    final customerId = (userRefs as Map)['customerId'];

    final proofId = await _client.mutation('bookingRequests:submitPaymentProof', {
      'bookingRequestId': proof.bookingRequestId,
      'customerId': customerId,
      'senderNumber': proof.senderNumber,
      'transactionId': proof.transactionId,
      'amountPkr': proof.amountPkr,
      'screenshotStorageId': proof.screenshotUrl, 
      'message': proof.message,
    });
    
    return PaymentProof(
      id: proofId.toString(),
      bookingRequestId: proof.bookingRequestId,
      customerName: proof.customerName,
      senderNumber: proof.senderNumber,
      transactionId: proof.transactionId,
      amountPkr: proof.amountPkr,
      screenshotUrl: _storageService.getImageUrl(proof.screenshotUrl),
      message: proof.message,
      status: PaymentProofStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<PaymentProof>> getAllPaymentProofs() async {
    final results = await _client.query('bookingRequests:getAllPaymentProofs');
    return (results as List).map((p) => _mapToPaymentProof(p as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PaymentProof>> getPendingPaymentProofs() async {
    final results = await _client.query('bookingRequests:getPendingPaymentProofs');
    return (results as List).map((p) => _mapToPaymentProof(p as Map<String, dynamic>)).toList();
  }

  @override
  Future<PaymentProof> reviewPaymentProof(String proofId, {required bool approved, required String staffName, String? rejectionReason}) async {
    final userRefs = await _client.query('users:getFirstUsers');
    final staffId = (userRefs as Map)['staffId'];

    await _client.mutation('bookingRequests:reviewPaymentProof', {
      'proofId': proofId,
      'staffId': staffId,
      'action': approved ? 'approve' : 'reject',
      'rejectionReason': rejectionReason,
    });
    
    return PaymentProof(
      id: proofId,
      bookingRequestId: '',
      customerName: '',
      senderNumber: '',
      amountPkr: 0,
      screenshotUrl: '',
      status: approved ? PaymentProofStatus.approved : PaymentProofStatus.rejected,
      createdAt: DateTime.now(),
      reviewedBy: staffName,
    );
  }

  PaymentProof _mapToPaymentProof(Map<String, dynamic> data) {
    return PaymentProof(
      id: data['_id'] as String,
      bookingRequestId: data['bookingRequestId'] as String,
      customerName: data['customerName'] as String? ?? 'Unknown',
      senderNumber: data['senderNumber'] as String,
      transactionId: data['transactionId'] as String?,
      amountPkr: data['amountPkr'] as int,
      screenshotUrl: _storageService.getImageUrl(data['screenshotStorageId'] as String),
      message: data['message'] as String?,
      status: _mapVerificationStatus(data['verificationStatus'] as String),
      createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int),
      reviewedBy: data['reviewedByName'] as String?,
    );
  }

  PaymentProofStatus _mapVerificationStatus(String status) {
    switch (status) {
      case 'approved': return PaymentProofStatus.approved;
      case 'rejected': return PaymentProofStatus.rejected;
      case 'pending':
      default: return PaymentProofStatus.pending;
    }
  }
}

class ConvexRoomService implements RoomService {
  final ConvexClient _client;
  ConvexRoomService(this._client);

  @override
  Future<List<Room>> getAllRooms() async {
    final results = await _client.query('data:getAllRooms');
    return (results as List).map((r) => Room.fromJson(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<Room> getRoomById(String id) async {
    final result = await _client.query('data:getRoomById', {'id': id});
    return Room.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<List<Room>> getFeaturedRooms() async {
    final results = await _client.query('data:getFeaturedRooms');
    return (results as List).map((r) => Room.fromJson(r as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Room>> checkAvailability(DateTime checkIn, DateTime checkOut) async {
    final rooms = await getAllRooms();
    return rooms.where((r) => r.status == RoomStatus.available).toList();
  }

  @override
  Future<Room> createRoom(Room room) async {
    final result = await _client.mutation('data:createRoom', {
      'roomNumber': room.number,
      'type': room.type.name,
      'floor': room.floor,
      'capacity': room.capacity,
      'pricePkr': room.pricePerNight,
      'status': room.status.name,
      'amenities': room.amenities,
      'imageUrls': room.imageUrls,
    });
    return Room.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<Room> updateRoom(Room room) async {
    final result = await _client.mutation('data:updateRoom', {
      'id': room.id,
      'roomNumber': room.number,
      'type': room.type.name,
      'floor': room.floor,
      'capacity': room.capacity,
      'pricePkr': room.pricePerNight,
      'status': room.status.name,
      'amenities': room.amenities,
      'imageUrls': room.imageUrls,
    });
    return Room.fromJson(result as Map<String, dynamic>);
  }

  @override
  Future<void> deleteRoom(String id) async {
    await _client.mutation('data:deleteRoom', {'id': id});
  }
}

class ConvexBookingService implements BookingService {
  final ConvexClient _client;
  ConvexBookingService(this._client);

  @override
  Future<List<Booking>> getAllBookings() async {
    final results = await _client.query('data:getAllBookings');
    return (results as List).map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
  }

  @override
  Future<Booking> getBookingById(String id) async {
    final all = await getAllBookings();
    return all.firstWhere((b) => b.id == id);
  }

  @override
  Future<Booking> createBooking(Booking booking) async => booking;

  @override
  Future<Booking> updateBookingStatus(String id, BookingStatus status) async {
    final all = await getAllBookings();
    return all.firstWhere((b) => b.id == id);
  }

  @override
  Future<List<Booking>> getBookingsByDate(DateTime date) async => [];

  @override
  Future<List<Booking>> getTodayCheckIns() async => [];

  @override
  Future<List<Booking>> getTodayCheckOuts() async => [];
}

class ConvexGuestService implements GuestService {
  final ConvexClient _client;
  ConvexGuestService(this._client);

  @override
  Future<List<Guest>> getAllGuests() async {
    final results = await _client.query('data:getAllGuests');
    return (results as List).map((g) => Guest.fromJson(g as Map<String, dynamic>)).toList();
  }

  @override
  Future<Guest> getGuestById(String id) async {
    final all = await getAllGuests();
    return all.firstWhere((g) => g.id == id);
  }

  @override
  Future<Guest> createGuest(Guest guest) async {
    await _client.mutation('data:createGuest', {
      'name': guest.name,
      'email': guest.email,
      'phone': guest.phone,
    });
    return guest;
  }

  @override
  Future<Guest> updateGuest(Guest guest) async => guest;

  @override
  Future<void> deleteGuest(String id) async {}
}

class ConvexInvoiceService implements InvoiceService {
  final ConvexClient _client;
  ConvexInvoiceService(this._client);

  @override
  Future<List<Invoice>> getAllInvoices() async {
    final results = await _client.query('data:getAllInvoices');
    return (results as List).map((i) => Invoice.fromJson(i as Map<String, dynamic>)).toList();
  }

  @override
  Future<Invoice> getInvoiceById(String id) async {
    final all = await getAllInvoices();
    return all.firstWhere((i) => i.id == id);
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async => invoice;

  @override
  Future<Invoice> updateInvoiceStatus(String id, InvoiceStatus status) async {
    final all = await getAllInvoices();
    return all.firstWhere((i) => i.id == id);
  }

  @override
  Future<List<Invoice>> getInvoicesByBooking(String bookingId) async {
    final all = await getAllInvoices();
    return all.where((i) => i.bookingId == bookingId).toList();
  }
}

class ConvexPaymentService implements PaymentService {
  final ConvexClient _client;
  ConvexPaymentService(this._client);

  @override
  Future<List<Payment>> getAllPayments() async {
    final results = await _client.query('data:getAllPayments');
    return (results as List).map((p) => Payment.fromJson(p as Map<String, dynamic>)).toList();
  }

  @override
  Future<Payment> recordPayment(Payment payment) async => payment;

  @override
  Future<List<Payment>> getPaymentsByInvoice(String invoiceId) async {
    final all = await getAllPayments();
    return all.where((p) => p.invoiceId == invoiceId).toList();
  }

  @override
  Future<double> getTotalRevenue() async {
    final result = await _client.query('data:getTotalRevenue');
    return (result as num).toDouble();
  }
}

class ConvexReviewService implements ReviewService {
  final ConvexClient _client;
  ConvexReviewService(this._client);

  @override
  Future<List<Review>> getAllReviews() async {
    final results = await _client.query('data:getAllReviews');
    return (results as List)
        .map((r) => Review.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Review> submitReview(Review review) async => review;

  @override
  Future<double> getAverageRating() async {
    final result = await _client.query('data:getAverageRating');
    return (result as num).toDouble();
  }
}

class ConvexStaffManagementService implements StaffManagementService {
  final ConvexClient _client;
  ConvexStaffManagementService(this._client);

  @override
  Future<List<User>> getAllStaff() async {
    final results = await _client.query('data:getStaff');
    return (results as List)
        .map((u) => User.fromJson(u as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<User> createStaff(User user) async {
    await _client.mutation('data:createStaff', {
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
    });
    return user;
  }

  @override
  Future<User> updateStaff(User user) async => user;

  @override
  Future<void> deactivateStaff(String id) async {
    await _client.mutation('data:deactivateStaff', {'id': id});
  }
}

class ConvexReportService implements ReportService {
  final ConvexClient _client;
  ConvexReportService(this._client);

  @override
  Future<Map<String, dynamic>> getBookingReport(DateTime from, DateTime to) async {
    final result = await _client.query('data:getReports');
    return Map<String, dynamic>.from((result as Map)['booking'] as Map);
  }

  @override
  Future<Map<String, dynamic>> getOccupancyReport(DateTime from, DateTime to) async {
    final result = await _client.query('data:getReports');
    return Map<String, dynamic>.from((result as Map)['occupancy'] as Map);
  }

  @override
  Future<Map<String, dynamic>> getRevenueReport(DateTime from, DateTime to) async {
    final result = await _client.query('data:getReports');
    return Map<String, dynamic>.from((result as Map)['revenue'] as Map);
  }
}

class ConvexAuthService implements AuthService {
  final ConvexClient _client;
  User? _currentUser;

  ConvexAuthService(this._client);

  @override
  Future<User?> login(String email, String password) async {
    try {
      final result = await _client.mutation('authQueries:login', {
        'email': email,
        'password': password,
      });
      if (result == null) return null;
      
      final token = result['token'] as String;
      final userMap = result['user'] as Map<String, dynamic>;
      final user = User.fromJson(userMap);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('convex_auth_token', token);
      
      _currentUser = user;
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('convex_auth_token');
      if (token != null) {
        await _client.mutation('authQueries:logout', {'token': token});
      }
      await prefs.remove('convex_auth_token');
    } catch (_) {}
    _currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('convex_auth_token');
      if (token == null || token.isEmpty) return null;
      
      final result = await _client.query('authQueries:getSessionUser', {'token': token});
      if (result == null) return null;
      
      final user = User.fromJson(Map<String, dynamic>.from(result as Map));
      _currentUser = user;
      return user;
    } catch (_) {
      return null;
    }
  }
}

class ConvexGalleryService {
  final ConvexClient _client;
  ConvexGalleryService(this._client);

  Future<List<Map<String, String>>> getGalleryImages() async {
    final results = await _client.query('data:getGalleryImages');
    return (results as List).map((img) {
      final m = img as Map<String, dynamic>;
      return {
        'url': m['url'] as String,
        'caption': m['caption'] as String,
      };
    }).toList();
  }
}

class ConvexHotelServicesService {
  final ConvexClient _client;
  ConvexHotelServicesService(this._client);

  Future<List<Map<String, dynamic>>> getHotelServices() async {
    final results = await _client.query('data:getHotelServices');
    return (results as List).map((s) {
      final m = s as Map<String, dynamic>;
      return {
        'icon': m['icon'] as String,
        'title': m['title'] as String,
        'description': m['description'] as String,
      };
    }).toList();
  }
}

class ConvexSiteConfigService {
  final ConvexClient _client;
  ConvexSiteConfigService(this._client);

  Future<Map<String, String>> getSiteConfig() async {
    final result = await _client.query('data:getSiteConfig');
    final map = result as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as String));
  }
}