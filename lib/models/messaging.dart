import 'package:equatable/equatable.dart';

/// A single chat message between staff and customer.
class ChatMessage extends Equatable {
  final String id;
  final String bookingRequestId;
  final String fromUserId;
  final String toUserId;
  final String fromName;
  final String toName;
  final String fromRole;
  final String text;
  final DateTime createdAt;
  final DateTime? readAt;

  const ChatMessage({
    required this.id,
    required this.bookingRequestId,
    required this.fromUserId,
    required this.toUserId,
    required this.fromName,
    required this.toName,
    required this.fromRole,
    required this.text,
    required this.createdAt,
    this.readAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] as String,
      bookingRequestId: json['bookingRequestId'] as String,
      fromUserId: json['fromUserId'] as String,
      toUserId: json['toUserId'] as String,
      fromName: json['fromName'] as String? ?? 'Unknown',
      toName: json['toName'] as String? ?? 'Unknown',
      fromRole: json['fromRole'] as String? ?? 'customer',
      text: json['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      readAt: json['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['readAt'] as int)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, bookingRequestId, fromUserId, text, createdAt];
}

/// A conversation summary.
class Conversation extends Equatable {
  final String bookingRequestId;
  final String otherUserId;
  final String otherUserName;
  final String otherUserRole;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final int totalMessages;

  const Conversation({
    required this.bookingRequestId,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserRole,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.totalMessages,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      bookingRequestId: json['bookingRequestId'] as String,
      otherUserId: json['otherUserId'] as String? ?? '',
      otherUserName: json['otherUserName'] as String? ?? 'Unknown',
      otherUserRole: json['otherUserRole'] as String? ?? 'customer',
      lastMessage: json['lastMessage'] as String? ?? '',
      lastMessageAt:
          DateTime.fromMillisecondsSinceEpoch(json['lastMessageAt'] as int),
      unreadCount: json['unreadCount'] as int? ?? 0,
      totalMessages: json['totalMessages'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [bookingRequestId, otherUserId, unreadCount];
}

/// An app notification for a user.
class AppNotification extends Equatable {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? bookingRequestId;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.bookingRequestId,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      bookingRequestId: json['bookingRequestId'] as String?,
      readAt: json['readAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['readAt'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    );
  }

  @override
  List<Object?> get props => [id, type, title, readAt];
}
