import 'package:equatable/equatable.dart';

enum BookingRequestStatus {
  pendingPayment,
  paymentSubmitted,
  verified,
  rejected,
  expired,
}

class BookingRequest extends Equatable {
  final String id;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String roomId;
  final String roomNumber;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestsCount;
  final int requestedTotalPkr;
  final BookingRequestStatus status;
  final String? notes;
  final DateTime createdAt;

  const BookingRequest({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.roomId,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.guestsCount,
    required this.requestedTotalPkr,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, roomId, checkIn, checkOut, status];
}
