import 'package:equatable/equatable.dart';

/// Room model representing a hotel room.
///
/// [status] maps to visual indicators:
///   available   → green
///   occupied    → red
///   reserved    → amber
///   maintenance → gray
enum RoomStatus { available, occupied, reserved, maintenance }
enum RoomType { standard, deluxe, suite, presidential }

class Room extends Equatable {
  final String id;
  final String number;
  final RoomType type;
  final String name;
  final String description;
  final double pricePerNight;
  final int capacity;
  final int floor;
  final double sizeInSqFt;
  final RoomStatus status;
  final List<String> amenities;
  final List<String> imageUrls;
  final bool isFeatured;

  const Room({
    required this.id,
    required this.number,
    required this.type,
    required this.name,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.floor,
    required this.sizeInSqFt,
    required this.status,
    required this.amenities,
    required this.imageUrls,
    this.isFeatured = false,
  });

  @override
  List<Object?> get props => [id, number, type, name, pricePerNight, capacity, status];

  /// Human-readable type label.
  String get typeLabel => switch (type) {
        RoomType.standard => 'Standard',
        RoomType.deluxe => 'Deluxe',
        RoomType.suite => 'Suite',
        RoomType.presidential => 'Presidential Suite',
      };

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      number: json['number'] as String,
      type: RoomType.values.firstWhere((r) => r.name == json['type']),
      name: json['name'] as String,
      description: json['description'] as String,
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      capacity: json['capacity'] as int,
      floor: json['floor'] as int,
      sizeInSqFt: (json['size_sq_ft'] as num).toDouble(),
      status: RoomStatus.values.firstWhere((r) => r.name == json['status']),
      amenities: List<String>.from(json['amenities'] as List),
      imageUrls: List<String>.from(json['image_urls'] as List),
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'type': type.name,
        'name': name,
        'description': description,
        'price_per_night': pricePerNight,
        'capacity': capacity,
        'floor': floor,
        'size_sq_ft': sizeInSqFt,
        'status': status.name,
        'amenities': amenities,
        'image_urls': imageUrls,
        'is_featured': isFeatured,
      };
}
