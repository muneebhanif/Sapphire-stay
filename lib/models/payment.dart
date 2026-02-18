import 'package:equatable/equatable.dart';

/// Payment record associated with an invoice.
enum PaymentMethod { cash, creditCard, debitCard, bankTransfer, online }
enum PaymentStatus { pending, completed, failed, refunded }

class Payment extends Equatable {
  final String id;
  final String invoiceId;
  final String bookingId;
  final String guestName;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime paidAt;
  final String? transactionRef;

  const Payment({
    required this.id,
    required this.invoiceId,
    required this.bookingId,
    required this.guestName,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
    this.transactionRef,
  });

  @override
  List<Object?> get props => [id, invoiceId, amount, status];

  String get methodLabel => switch (method) {
        PaymentMethod.cash => 'Cash',
        PaymentMethod.creditCard => 'Credit Card',
        PaymentMethod.debitCard => 'Debit Card',
        PaymentMethod.bankTransfer => 'Bank Transfer',
        PaymentMethod.online => 'Online',
      };

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      bookingId: json['booking_id'] as String,
      guestName: json['guest_name'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere((m) => m.name == json['method']),
      status: PaymentStatus.values.firstWhere((s) => s.name == json['status']),
      paidAt: DateTime.parse(json['paid_at'] as String),
      transactionRef: json['transaction_ref'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoice_id': invoiceId,
        'booking_id': bookingId,
        'guest_name': guestName,
        'amount': amount,
        'method': method.name,
        'status': status.name,
        'paid_at': paidAt.toIso8601String(),
        'transaction_ref': transactionRef,
      };
}
