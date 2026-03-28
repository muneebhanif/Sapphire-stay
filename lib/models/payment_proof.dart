import 'package:equatable/equatable.dart';

enum PaymentProofStatus { pending, approved, rejected }

class PaymentProof extends Equatable {
  final String id;
  final String bookingRequestId;
  final String customerName;
  final String senderNumber;
  final String? transactionId;
  final int amountPkr;
  final String screenshotUrl;
  final String? message;
  final PaymentProofStatus status;
  final DateTime createdAt;
  final String? reviewedBy;

  /// The Convex user ID of the customer.
  /// Required when submitting a new proof so the backend knows
  /// which customer to associate the payment with.
  final String? customerId;

  const PaymentProof({
    required this.id,
    required this.bookingRequestId,
    required this.customerName,
    required this.senderNumber,
    this.transactionId,
    required this.amountPkr,
    required this.screenshotUrl,
    this.message,
    required this.status,
    required this.createdAt,
    this.reviewedBy,
    this.customerId,
  });

  @override
  List<Object?> get props => [id, bookingRequestId, status, createdAt];
}
