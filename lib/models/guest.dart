import 'package:equatable/equatable.dart';

/// Guest record for hotel management.
class Guest extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? idNumber;
  final String? nationality;
  final String? address;
  final int totalStays;
  final DateTime createdAt;

  const Guest({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.idNumber,
    this.nationality,
    this.address,
    this.totalStays = 0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, email, phone];

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      idNumber: json['id_number'] as String?,
      nationality: json['nationality'] as String?,
      address: json['address'] as String?,
      totalStays: json['total_stays'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'id_number': idNumber,
        'nationality': nationality,
        'address': address,
        'total_stays': totalStays,
        'created_at': createdAt.toIso8601String(),
      };
}
