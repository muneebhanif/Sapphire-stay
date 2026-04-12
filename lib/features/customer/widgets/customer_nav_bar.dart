import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/messaging.dart';
import '../../../providers/providers.dart';

/// Top navigation bar for the customer-facing (public) module.
///
/// Desktop: Horizontal links + CTA button + avatar/notifications when logged in
/// Mobile:  Hamburger menu with slide-out drawer
class CustomerNavBar extends ConsumerWidget {
  const CustomerNavBar({super.key});

  static final _navItems = [
    _NavItem('Home', RoutePaths.home),
    _NavItem('Rooms', RoutePaths.rooms),
    _NavItem('Gallery', RoutePaths.gallery),
    _NavItem('About', RoutePaths.about),
    _NavItem('Contact', RoutePaths.contact),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Container(
      height: AppSpacing.navBarHeight,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          // ── Logo ──
          _buildLogo(context),
          const Spacer(),

          // ── Navigation Items (desktop only) ──
          if (Responsive.isDesktop(context)) ...[
            ..._navItems.map((item) => _buildNavItem(context, item)),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.booking),
              child: const Text('Book Now'),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Show avatar + notifications when logged in, login button otherwise
            if (user != null) ...[
              // Notification bell
              _NotificationBell(userId: user.id),
              const SizedBox(width: AppSpacing.xs),
              // Messages
              _MessagesBadge(userId: user.id),
              const SizedBox(width: AppSpacing.sm),
              // User avatar dropdown
              _UserAvatarMenu(user: user),
            ] else
              TextButton(
                onPressed: () => context.go(RoutePaths.login),
                child: Text(
                  'Login / Sign Up',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],

          // ── Mobile hamburger ──
          if (!Responsive.isDesktop(context)) ...[
            if (user != null) ...[
              _NotificationBell(userId: user.id, compact: true),
              _MessagesBadge(userId: user.id, compact: true),
              const SizedBox(width: AppSpacing.xs),
            ],
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(RoutePaths.home),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Center(
              child: Text(
                'S',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            AppConstants.appName.toUpperCase(),
            style: AppTypography.titleLarge.copyWith(
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, _NavItem item) {
    final currentPath = GoRouterState.of(context).uri.path;
    final isActive = currentPath == item.path;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: TextButton(
        onPressed: () => context.go(item.path),
        style: TextButton.styleFrom(
          foregroundColor: isActive ? AppColors.accent : AppColors.textPrimary,
        ),
        child: Text(
          item.label,
          style: AppTypography.labelLarge.copyWith(
            color: isActive ? AppColors.accent : AppColors.textPrimary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ─── User Avatar Menu ──────────────────────────────────────────────

class _UserAvatarMenu extends ConsumerWidget {
  final dynamic user;
  const _UserAvatarMenu({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = _getInitials(user.name);

    return PopupMenuButton<String>(
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              user.name.split(' ').first,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.keyboard_arrow_down,
                size: 18, color: AppColors.primary.withValues(alpha: 0.6)),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user.name, style: AppTypography.titleSmall),
              Text(user.email,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.role.name.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'messages',
          child: Row(
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text('Messages', style: AppTypography.bodyMedium),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'notifications',
          child: Row(
            children: [
              Icon(Icons.notifications_outlined,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Text('Notifications', style: AppTypography.bodyMedium),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 18, color: AppColors.error),
              const SizedBox(width: 10),
              Text('Logout',
                  style:
                      AppTypography.bodyMedium.copyWith(color: AppColors.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'messages':
            _showMessagesDialog(context, ref, user.id);
            break;
          case 'notifications':
            _showNotificationsDialog(context, ref, user.id);
            break;
          case 'logout':
            ref.read(authProvider.notifier).logout();
            context.go(RoutePaths.home);
            break;
        }
      },
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _showMessagesDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => _ConversationsDialog(userId: userId),
    );
  }

  void _showNotificationsDialog(
      BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => _NotificationsDialog(userId: userId),
    );
  }
}

// ─── Notification Bell ─────────────────────────────────────────────

class _NotificationBell extends ConsumerWidget {
  final String userId;
  final bool compact;
  const _NotificationBell({required this.userId, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(unreadNotificationCountProvider(userId));
    final count = countAsync.valueOrNull ?? 0;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            count > 0
                ? Icons.notifications_active
                : Icons.notifications_outlined,
            color: count > 0 ? AppColors.accent : AppColors.textSecondary,
            size: compact ? 20 : 22,
          ),
          tooltip: 'Notifications',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => _NotificationsDialog(userId: userId),
            );
          },
        ),
        if (count > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                count > 9 ? '9+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Messages Badge ────────────────────────────────────────────────

class _MessagesBadge extends ConsumerWidget {
  final String userId;
  final bool compact;
  const _MessagesBadge({required this.userId, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convosAsync = ref.watch(conversationsProvider(userId));
    final unread = convosAsync.valueOrNull
            ?.fold<int>(0, (s, c) => s + c.unreadCount) ??
        0;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            unread > 0
                ? Icons.chat_bubble
                : Icons.chat_bubble_outline,
            color: unread > 0 ? AppColors.accent : AppColors.textSecondary,
            size: compact ? 18 : 20,
          ),
          tooltip: 'Messages',
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => _ConversationsDialog(userId: userId),
            );
          },
        ),
        if (unread > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unread > 9 ? '9+' : '$unread',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Notifications Dialog ──────────────────────────────────────────

class _NotificationsDialog extends ConsumerWidget {
  final String userId;
  const _NotificationsDialog({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider(userId));

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450, maxHeight: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications, color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Notifications',
                      style: AppTypography.titleMedium
                          .copyWith(color: AppColors.white)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(messagingServiceProvider)
                          .markAllNotificationsRead(userId);
                      ref.invalidate(notificationsProvider(userId));
                      ref.invalidate(unreadNotificationCountProvider(userId));
                    },
                    child: Text('Mark all read',
                        style: AppTypography.labelSmall
                            .copyWith(color: AppColors.accent)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white,
                        size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: notifsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (notifs) {
                  if (notifs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_none,
                              size: 48, color: AppColors.textTertiary),
                          SizedBox(height: AppSpacing.sm),
                          Text('No notifications yet'),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: notifs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = notifs[i];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: n.isRead
                              ? AppColors.surfaceVariant
                              : AppColors.accent.withValues(alpha: 0.15),
                          child: Icon(
                            _iconForType(n.type),
                            size: 18,
                            color: n.isRead
                                ? AppColors.textTertiary
                                : AppColors.accent,
                          ),
                        ),
                        title: Text(n.title,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: n.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                            )),
                        subtitle: Text(n.body,
                            style: AppTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        trailing: Text(
                          _timeAgo(n.createdAt),
                          style: AppTypography.labelSmall
                              .copyWith(color: AppColors.textTertiary),
                        ),
                        dense: true,
                        onTap: () async {
                          if (!n.isRead) {
                            await ref
                                .read(messagingServiceProvider)
                                .markNotificationRead(n.id);
                            ref.invalidate(notificationsProvider(userId));
                            ref.invalidate(
                                unreadNotificationCountProvider(userId));
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'booking_approved':
        return Icons.check_circle;
      case 'booking_rejected':
        return Icons.cancel;
      case 'payment_verified':
        return Icons.verified;
      case 'new_message':
        return Icons.chat;
      default:
        return Icons.info;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}

// ─── Conversations Dialog ──────────────────────────────────────────

class _ConversationsDialog extends ConsumerStatefulWidget {
  final String userId;
  const _ConversationsDialog({required this.userId});

  @override
  ConsumerState<_ConversationsDialog> createState() =>
      _ConversationsDialogState();
}

class _ConversationsDialogState extends ConsumerState<_ConversationsDialog> {
  String? _selectedBookingRequestId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 560),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusLg)),
              ),
              child: Row(
                children: [
                  if (_selectedBookingRequestId != null)
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: AppColors.white),
                      onPressed: () =>
                          setState(() => _selectedBookingRequestId = null),
                    ),
                  Icon(
                    _selectedBookingRequestId == null
                        ? Icons.chat_bubble
                        : Icons.chat,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _selectedBookingRequestId == null
                        ? 'Messages'
                        : 'Conversation',
                    style: AppTypography.titleMedium
                        .copyWith(color: AppColors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon:
                        const Icon(Icons.close, color: AppColors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _selectedBookingRequestId == null
                  ? _buildConversationsList()
                  : _ChatView(
                      bookingRequestId: _selectedBookingRequestId!,
                      currentUserId: widget.userId,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final convosAsync = ref.watch(conversationsProvider(widget.userId));
    return convosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (convos) {
        if (convos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_outline,
                    size: 48, color: AppColors.textTertiary),
                SizedBox(height: AppSpacing.sm),
                Text('No conversations yet'),
                SizedBox(height: AppSpacing.xs),
                Text('Messages from staff will appear here',
                    style: TextStyle(color: AppColors.textTertiary)),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.sm),
          itemCount: convos.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final c = convos[i];
            return ListTile(
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
                  Expanded(
                    child: Text(c.otherUserName,
                        style: AppTypography.labelLarge),
                  ),
                  if (c.unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${c.unreadCount}',
                          style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              subtitle: Text(c.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall),
              trailing: Text(
                _timeAgo(c.lastMessageAt),
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.textTertiary),
              ),
              onTap: () => setState(
                  () => _selectedBookingRequestId = c.bookingRequestId),
            );
          },
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

// ─── Chat View ─────────────────────────────────────────────────────

class _ChatView extends ConsumerStatefulWidget {
  final String bookingRequestId;
  final String currentUserId;
  const _ChatView(
      {required this.bookingRequestId, required this.currentUserId});

  @override
  ConsumerState<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends ConsumerState<_ChatView> {
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
              // Mark as read
              ref.read(messagingServiceProvider).markMessagesRead(
                    widget.bookingRequestId,
                    widget.currentUserId,
                  );

              if (messages.isEmpty) {
                return const Center(
                    child: Text('No messages yet. Start the conversation!'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  final isMe = m.fromUserId == widget.currentUserId;
                  return _ChatBubble(message: m, isMe: isMe);
                },
              );
            },
          ),
        ),
        // Input
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surface,
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
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    isDense: true,
                  ),
                  maxLines: 2,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: _sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send, color: AppColors.accent),
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
      // Determine recipient — get convos to find the other user
      final convos = ref
          .read(conversationsProvider(widget.currentUserId))
          .valueOrNull;
      final convo = convos?.firstWhere(
        (c) => c.bookingRequestId == widget.bookingRequestId,
        orElse: () => convos!.first,
      );

      if (convo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No conversation partner found.')),
          );
        }
        return;
      }

      await ref.read(messagingServiceProvider).sendMessage(
            bookingRequestId: widget.bookingRequestId,
            fromUserId: widget.currentUserId,
            toUserId: convo.otherUserId,
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

// ─── Chat Bubble ───────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
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
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.fromName,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Text(message.text, style: AppTypography.bodyMedium),
            const SizedBox(height: 2),
            Text(
              _formatTime(message.createdAt),
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.textTertiary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Mobile navigation drawer for the customer module.
class CustomerDrawer extends ConsumerWidget {
  const CustomerDrawer({super.key});

  static final _navItems = [
    _NavItem('Home', RoutePaths.home),
    _NavItem('Rooms', RoutePaths.rooms),
    _NavItem('Gallery', RoutePaths.gallery),
    _NavItem('About', RoutePaths.about),
    _NavItem('Contact', RoutePaths.contact),
    _NavItem('Reviews', RoutePaths.reviews),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── User Info or Logo ──
            if (user != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: AppTypography.titleSmall),
                          Text(user.email,
                              style: AppTypography.bodySmall
                                  .copyWith(color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName.toUpperCase(),
                      style: AppTypography.titleLarge.copyWith(
                        letterSpacing: 3,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      AppConstants.hotelName,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            const Divider(),

            // ── Nav Links ──
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: _navItems
                    .map((item) => ListTile(
                          title: Text(item.label),
                          onTap: () {
                            Navigator.pop(context);
                            context.go(item.path);
                          },
                        ))
                    .toList(),
              ),
            ),

            // ── CTA ──
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(RoutePaths.booking);
                    },
                    child: const Text('Book Now'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (user != null)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authProvider.notifier).logout();
                        context.go(RoutePaths.home);
                      },
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                    )
                  else
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go(RoutePaths.login);
                      },
                      child: const Text('Login / Sign Up'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String path;
  const _NavItem(this.label, this.path);
}
