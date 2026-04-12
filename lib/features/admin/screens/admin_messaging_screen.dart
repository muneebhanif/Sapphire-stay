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

/// Admin message monitoring — read-only view of all conversations.
class AdminMessagingScreen extends ConsumerStatefulWidget {
  const AdminMessagingScreen({super.key});

  @override
  ConsumerState<AdminMessagingScreen> createState() =>
      _AdminMessagingScreenState();
}

class _AdminMessagingScreenState extends ConsumerState<AdminMessagingScreen> {
  String? _selectedBookingRequestId;

  @override
  Widget build(BuildContext context) {
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
                          ? 'Message Monitoring'
                          : 'Viewing Conversation',
                      style: AppTypography.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedBookingRequestId == null
                          ? 'Monitor all staff–customer communications'
                          : 'Booking: ${_selectedBookingRequestId!.substring(0, 8)}...',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              if (_selectedBookingRequestId == null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () => setState(() {}),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _selectedBookingRequestId == null
              ? _buildAllConversations()
              : _AdminChatView(
                  bookingRequestId: _selectedBookingRequestId!,
                ),
        ),
      ],
    );
  }

  Widget _buildAllConversations() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(messagingServiceProvider).getAllConversations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SSLoading(type: SSLoadingType.list);
        }
        if (snapshot.hasError) {
          return SSErrorState(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {}),
          );
        }
        final convos = snapshot.data ?? [];
        if (convos.isEmpty) {
          return const SSEmptyState(
            icon: Icons.forum_outlined,
            title: 'No Conversations',
            description: 'No messaging activity yet.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: convos.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (_, i) {
            final c = convos[i];
            final participants = (c['participants'] as List?) ?? [];
            final lastMsg = c['lastMessage'] as String? ?? '';
            final lastFrom = c['lastMessageFrom'] as String? ?? '';
            final totalMsgs = c['totalMessages'] as int? ?? 0;
            final brId = c['bookingRequestId'] as String? ?? '';
            final lastAt = DateTime.fromMillisecondsSinceEpoch(
                c['lastMessageAt'] as int? ?? 0);

            return Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.forum,
                      color: AppColors.accent, size: 20),
                ),
                title: Row(
                  children: [
                    ...participants.take(3).map((p) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Chip(
                            label: Text('${p['name']} (${p['role']})',
                                style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      '$lastFrom: $lastMsg',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booking: ${brId.substring(0, 8)}... · $totalMsgs messages · ${_timeAgo(lastAt)}',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textTertiary),
                onTap: () =>
                    setState(() => _selectedBookingRequestId = brId),
              ),
            );
          },
        );
      },
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

// ─── Admin Chat View (Read-only) ─────────────────────────────────

class _AdminChatView extends ConsumerWidget {
  final String bookingRequestId;
  const _AdminChatView({required this.bookingRequestId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatMessagesProvider(bookingRequestId));

    return messagesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (messages) {
        if (messages.isEmpty) {
          return const Center(child: Text('No messages in this conversation'));
        }
        return Column(
          children: [
            // Monitoring banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              color: AppColors.accent.withValues(alpha: 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility,
                      size: 16,
                      color: AppColors.accent.withValues(alpha: 0.7)),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Admin monitoring — read-only view',
                      style: AppTypography.labelSmall
                          .copyWith(color: AppColors.accent)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final m = messages[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor:
                              m.fromRole == 'staff' || m.fromRole == 'admin'
                                  ? AppColors.primary
                                  : AppColors.accent,
                          child: Text(
                            m.fromName.isNotEmpty
                                ? m.fromName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(m.fromName,
                                      style: AppTypography.labelMedium
                                          .copyWith(
                                              fontWeight: FontWeight.w700)),
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: m.fromRole == 'staff' ||
                                              m.fromRole == 'admin'
                                          ? AppColors.primary
                                              .withValues(alpha: 0.1)
                                          : AppColors.accent
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(m.fromRole,
                                        style: AppTypography.labelSmall
                                            .copyWith(fontSize: 9)),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: AppTypography.labelSmall
                                        .copyWith(
                                            color: AppColors.textTertiary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('→ ${m.toName}',
                                  style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.textTertiary)),
                              const SizedBox(height: 4),
                              Text(m.text,
                                  style: AppTypography.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
