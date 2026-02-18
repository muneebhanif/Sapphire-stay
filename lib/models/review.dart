import 'package:equatable/equatable.dart';

/// Guest review / feedback model.
class Review extends Equatable {
  final String id;
  final String guestName;
  final String? guestAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.guestName,
    this.guestAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, guestName, rating, comment];

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      guestName: json['guest_name'] as String,
      guestAvatarUrl: json['guest_avatar_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'guest_name': guestName,
        'guest_avatar_url': guestAvatarUrl,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };
}
