import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../models/messaging.dart';
import '../../../providers/providers.dart';

/// Staff messaging screen — chat with customers about their bookings.
class StaffMessagingScreen extends ConsumerStatefulWidget {
  const StaffMessagingScreen({super.key});

  @override
  ConsumerState<StaffMessagingScreen> createState() =>
      _StaffMessagingScreenState();
}

class _StaffMessagingScreenState extends ConsumerState<StaffMessagingScreen> {
  String? _selectedBookingRequestId;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
          child: Row(
            children: [
              if (_selectedBookingRequestId != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      setState(() => _selectedBookingRequestId = null),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedBookingRequestId == null
                          ? 'Messages'
                          : 'Conversation',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedBookingRequestId == null
                          ? 'Chat with customers about their bookings'
                          : 'Booking: ${_selectedBookingRequestId!.substring(0, 8)}...',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              // New message button
              if (_selectedBookingRequestId == null)
                ElevatedButton.icon(
                  onPressed: () => _showNewMessageDialog(currentUser.id),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Message'),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _selectedBookingRequestId == null
              ? _buildConversationsList(currentUser.id)
              : _StaffChatView(
                  bookingRequestId: _selectedBookingRequestId!,
                  currentUserId: currentUser.id,
                ),
        ),
      ],
    );
  }

  Widget _buildConversationsList(String userId) {
    final convosAsync = ref.watch(conversationsProvider(userId));
    return convosAsync.when(
      loading: () => const SSLoading(type: SSLoadingType.list),
      error: (e, _) => SSErrorState(
        message: e.toString(),
        onRetry: () => ref.invalidate(conversationsProvider(userId)),
      ),
      data: (convos) {
        if (convos.isEmpty) {
          return const SSEmptyState(
            icon: Icons.chat_bubble_outline,
            title: 'No Conversations',
            description:
                'Start a conversation by clicking "New Message" and selecting a booking request.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: convos.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final c = convos[i];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: c.unreadCount > 0
                      ? AppColors.accent
                      : AppColors.border,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: c.unreadCount > 0
                      ? AppColors.accent
                      : AppColors.surfaceVariant,
                  child: Text(
                    c.otherUserName.isNotEmpty
                        ? c.otherUserName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: c.unreadCount > 0
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Row(
                  children: [
                    Text(c.otherUserName, style: AppTypography.titleSmall),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c.otherUserRole,
                          style: AppTypography.labelSmall.copyWith(fontSize: 9)),
                    ),
                    const Spacer(),
                    if (c.unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${c.unreadCount} new',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(c.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      'Booking: ${c.bookingRequestId.substring(0, 8)}... · ${_timeAgo(c.lastMessageAt)}',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                onTap: () => setState(
                    () => _selectedBookingRequestId = c.bookingRequestId),
              ),
            );
          },
        );
      },
    );
  }

  void _showNewMessageDialog(String staffUserId) {
    final bookingReqsAsync = ref.read(bookingRequestsProvider);
    final bookingReqs = bookingReqsAsync.valueOrNull ?? [];

    if (bookingReqs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No booking requests available to message.')),
      );
      return;
    }

    String? selectedBrId;
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Message to Customer'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedBrId,
                  decoration:
                      const InputDecoration(labelText: 'Booking Request'),
                  items: bookingReqs.map((br) {
                    return DropdownMenuItem(
                      value: br.id,
                      child: Text(
                          '${br.customerName} — ${br.id.substring(0, 8)}...'),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedBrId = v),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: msgCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedBrId == null || msgCtrl.text.trim().isEmpty) return;

                final br =
                    bookingReqs.firstWhere((r) => r.id == selectedBrId);

                await ref.read(messagingServiceProvider).sendMessage(
                      bookingRequestId: selectedBrId!,
                      fromUserId: staffUserId,
                      toUserId: br.customerId ?? '',
                      text: msgCtrl.text.trim(),
                    );

                ref.invalidate(conversationsProvider(staffUserId));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message sent!')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Staff Chat View ──────────────────────────────────────────────

class _StaffChatView extends ConsumerStatefulWidget {
  final String bookingRequestId;
  final String currentUserId;
  const _StaffChatView(
      {required this.bookingRequestId, required this.currentUserId});

  @override
  ConsumerState<_StaffChatView> createState() => _StaffChatViewState();
}

class _StaffChatViewState extends ConsumerState<_StaffChatView> {
  final _msgCtrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(chatMessagesProvider(widget.bookingRequestId));

    return Column(
      children: [
        Expanded(
          child: messagesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (messages) {
              ref.read(messagingServiceProvider).markMessagesRead(
                    widget.bookingRequestId,
                    widget.currentUserId,
                  );

              if (messages.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 48, color: AppColors.textTertiary),
                      SizedBox(height: AppSpacing.sm),
                      Text('Start the conversation'),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  final isMe = m.fromUserId == widget.currentUserId;
                  return _MessageBubble(message: m, isMe: isMe);
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                icon: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.white))
                    : const Icon(Icons.send, color: AppColors.white, size: 20),
                onPressed: _sending ? null : _send,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);

    try {
      final convos =
          ref.read(conversationsProvider(widget.currentUserId)).valueOrNull;
      final convo = convos?.firstWhere(
        (c) => c.bookingRequestId == widget.bookingRequestId,
      );

      String toUserId;
      if (convo != null) {
        toUserId = convo.otherUserId;
      } else {
        // Fallback: get customerId from booking request
        final brs = ref.read(bookingRequestsProvider).valueOrNull ?? [];
        final br = brs.firstWhere(
          (r) => r.id == widget.bookingRequestId,
        );
        toUserId = br.customerId ?? '';
      }

      await ref.read(messagingServiceProvider).sendMessage(
            bookingRequestId: widget.bookingRequestId,
            fromUserId: widget.currentUserId,
            toUserId: toUserId,
            text: text,
          );

      _msgCtrl.clear();
      ref.invalidate(chatMessagesProvider(widget.bookingRequestId));
      ref.invalidate(conversationsProvider(widget.currentUserId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.accent.withValues(alpha: 0.12)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                '${message.fromName} · ${message.fromRole}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            Text(message.text, style: AppTypography.bodyMedium),
            const SizedBox(height: 2),
            Text(
              '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textTertiary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
