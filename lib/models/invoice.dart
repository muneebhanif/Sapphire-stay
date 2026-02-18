import 'package:equatable/equatable.dart';

/// Invoice model linked to a booking.
enum InvoiceStatus { draft, issued, paid, overdue, cancelled }

class Invoice extends Equatable {
  final String id;
  final String bookingId;
  final String guestName;
  final String roomNumber;
  final DateTime issueDate;
  final DateTime? dueDate;
  final double subtotal;
  final double tax;
  final double total;
  final InvoiceStatus status;
  final List<InvoiceLineItem> lineItems;

  const Invoice({
    required this.id,
    required this.bookingId,
    required this.guestName,
    required this.roomNumber,
    required this.issueDate,
    this.dueDate,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.status,
    required this.lineItems,
  });

  @override
  List<Object?> get props => [id, bookingId, total, status];

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      guestName: json['guest_name'] as String,
      roomNumber: json['room_number'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: InvoiceStatus.values.firstWhere((s) => s.name == json['status']),
      lineItems: (json['line_items'] as List)
          .map((e) => InvoiceLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'guest_name': guestName,
        'room_number': roomNumber,
        'issue_date': issueDate.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
        'subtotal': subtotal,
        'tax': tax,
        'total': total,
        'status': status.name,
        'line_items': lineItems.map((e) => e.toJson()).toList(),
      };
}

class InvoiceLineItem extends Equatable {
  final String description;
  final int quantity;
  final double unitPrice;
  final double total;

  const InvoiceLineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object?> get props => [description, quantity, unitPrice, total];

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      description: json['description'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'quantity': quantity,
        'unit_price': unitPrice,
        'total': total,
      };
}
