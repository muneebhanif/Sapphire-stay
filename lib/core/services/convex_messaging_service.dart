import 'package:flutter/foundation.dart';
import '../../models/messaging.dart';
import 'convex_client_provider.dart';

/// Service for messaging & notifications backed by Convex.
class ConvexMessagingService {
  final ConvexClient _client;
  ConvexMessagingService(this._client);

  // ─── Messages ────────────────────────────────────────────────

  Future<void> sendMessage({
    required String bookingRequestId,
    required String fromUserId,
    required String toUserId,
    required String text,
  }) async {
    await _client.mutation('messaging:sendMessage', {
      'bookingRequestId': bookingRequestId,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'text': text,
    });
  }

  Future<void> editMessage(String messageId, String newText) async {
    await _client.mutation('messaging:editMessage', {
      'messageId': messageId,
      'newText': newText,
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _client.mutation('messaging:deleteMessage', {
      'messageId': messageId,
    });
  }

  Future<List<ChatMessage>> getMessagesByBooking(
      String bookingRequestId) async {
    final results = await _client.query('messaging:getMessagesByBooking', {
      'bookingRequestId': bookingRequestId,
    });
    return (results as List)
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<List<Conversation>> getConversationsForUser(String userId) async {
    final results = await _client.query('messaging:getConversationsForUser', {
      'userId': userId,
    });
    return (results as List)
        .map((c) => Conversation.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllConversations() async {
    final results = await _client.query('messaging:getAllConversations');
    return (results as List)
        .map((c) => Map<String, dynamic>.from(c as Map))
        .toList();
  }

  Future<void> markMessagesRead(
      String bookingRequestId, String userId) async {
    await _client.mutation('messaging:markMessagesRead', {
      'bookingRequestId': bookingRequestId,
      'userId': userId,
    });
  }

  // ─── Notifications ───────────────────────────────────────────

  Future<List<AppNotification>> getNotifications(String userId) async {
    final results = await _client.query('messaging:getNotifications', {
      'userId': userId,
    });
    return (results as List)
        .map((n) => AppNotification.fromJson(n as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final result = await _client.query('messaging:getUnreadCount', {
      'userId': userId,
    });
    return result as int? ?? 0;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _client.mutation('messaging:markNotificationRead', {
      'notificationId': notificationId,
    });
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await _client.mutation('messaging:markAllNotificationsRead', {
      'userId': userId,
    });
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? bookingRequestId,
  }) async {
    final args = <String, dynamic>{
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
    };
    if (bookingRequestId != null) {
      args['bookingRequestId'] = bookingRequestId;
    }
    await _client.mutation('messaging:createNotification', args);
  }
}
