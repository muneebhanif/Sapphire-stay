import 'package:equatable/equatable.dart';

/// Booking model for reservation management.
///
/// Lifecycle: pending → confirmed → checked_in → completed
///                   → cancelled (from pending or confirmed)
enum BookingStatus { pending, confirmed, checkedIn, completed, cancelled }

class Booking extends Equatable {
  final String id;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String roomId;
  final String roomNumber;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalAmount;
  final BookingStatus status;
  final String? specialRequests;
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    required this.roomId,
    required this.roomNumber,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalAmount,
    required this.status,
    this.specialRequests,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, guestName, roomId, checkIn, checkOut, status];

  /// Number of nights for this booking.
  int get nights => checkOut.difference(checkIn).inDays;

  String get statusLabel => switch (status) {
        BookingStatus.pending => 'Pending',
        BookingStatus.confirmed => 'Confirmed',
        BookingStatus.checkedIn => 'Checked In',
        BookingStatus.completed => 'Completed',
        BookingStatus.cancelled => 'Cancelled',
      };

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      guestName: json['guest_name'] as String,
      guestEmail: json['guest_email'] as String,
      guestPhone: json['guest_phone'] as String,
      roomId: json['room_id'] as String,
      roomNumber: json['room_number'] as String,
      roomType: json['room_type'] as String,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      guests: json['guests'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: BookingStatus.values.firstWhere((b) => b.name == json['status']),
      specialRequests: json['special_requests'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guest_name': guestName,
        'guest_email': guestEmail,
        'guest_phone': guestPhone,
        'room_id': roomId,
        'room_number': roomNumber,
        'room_type': roomType,
        'check_in': checkIn.toIso8601String(),
        'check_out': checkOut.toIso8601String(),
        'guests': guests,
        'total_amount': totalAmount,
        'status': status.name,
        'special_requests': specialRequests,
        'created_at': createdAt.toIso8601String(),
      };
}
