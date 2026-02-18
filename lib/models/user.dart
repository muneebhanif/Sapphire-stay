import 'package:equatable/equatable.dart';

/// User model representing any authenticated user in the system.
///
/// [role] determines route access:
///   • customer — public module only
///   • staff    — staff dashboard (no analytics/staff management)
///   • admin    — full system access
enum UserRole { customer, staff, admin }

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, email, phone, role, avatarUrl, createdAt, isActive];

  /// Factory constructor for JSON deserialization (backend integration ready).
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'avatar_url': avatarUrl,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive,
      };
}
