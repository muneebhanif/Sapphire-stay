import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ss_card.dart';
import '../../../../core/widgets/ss_loading.dart';
import '../../../../providers/providers.dart';
import '../../../../core/services/convex_client_provider.dart';

final subscribersProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(convexClientProvider);
  final result = await client.query("data:getSubscribers", {});
  return List<Map<String, dynamic>>.from(result);
});

class AdminSubscribersScreen extends ConsumerWidget {
  const AdminSubscribersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscribersAsync = ref.watch(subscribersProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Newsletter Subscribers', style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: SSCard(
                padding: EdgeInsets.zero,
                child: subscribersAsync.when(
                  loading: () => const SSLoading(),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (subscribers) {
                    if (subscribers.isEmpty) {
                      return const Center(child: Text('No subscribers yet.'));
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: subscribers.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final sub = subscribers[index];
                        final date = DateTime.fromMillisecondsSinceEpoch(
                            ((sub['createdAt'] as num?) ?? DateTime.now().millisecondsSinceEpoch).toInt());
                        
                        return ListTile(
                          leading: const Icon(Icons.email, color: AppColors.accent),
                          title: Text(sub['email'] ?? 'Unknown'),
                          subtitle: Text('Subscribed on: \${date.day}/\${date.month}/\${date.year}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
