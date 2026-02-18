import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../models/room.dart';
import '../../../providers/providers.dart';
import '../widgets/availability_picker.dart';
import '../widgets/room_card.dart';

/// Room listing page with filters and availability check.
class RoomsScreen extends ConsumerStatefulWidget {
  const RoomsScreen({super.key});

  @override
  ConsumerState<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends ConsumerState<RoomsScreen> {
  RoomType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(allRoomsProvider);

    return Column(
      children: [
        // ── Page Header ──
        _buildHeader(context),

        // ── Filters + Availability ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
            vertical: AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
            child: Column(
              children: [
                // ── Room Type Filter ──
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      _buildFilterChip('Standard', RoomType.standard),
                      _buildFilterChip('Deluxe', RoomType.deluxe),
                      _buildFilterChip('Suite', RoomType.suite),
                      _buildFilterChip('Presidential', RoomType.presidential),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Room Grid ──
                roomsAsync.when(
                  loading: () => const SSLoading(type: SSLoadingType.card),
                  error: (e, _) => SSErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(allRoomsProvider),
                  ),
                  data: (rooms) {
                    final filtered = _selectedType == null
                        ? rooms
                        : rooms.where((r) => r.type == _selectedType).toList();

                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Column(
                          children: [
                            Icon(Icons.hotel_outlined,
                                size: 64, color: AppColors.textTertiary),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No rooms found for this category',
                              style: AppTypography.bodyLarge,
                            ),
                          ],
                        ),
                      );
                    }

                    return Wrap(
                      spacing: AppSpacing.lg,
                      runSpacing: AppSpacing.lg,
                      children: filtered.map((room) {
                        return SizedBox(
                          width: Responsive.value(
                            context,
                            mobile: double.infinity,
                            tablet: 340.0,
                            desktop: 370.0,
                          ),
                          child: RoomCard(room: room),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),

        // ── Availability Checker ──
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.pagePadding(context),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const AvailabilityPicker(),
          ),
        ),

        const SizedBox(height: AppSpacing.xxxl),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.pagePadding(context),
        vertical: AppSpacing.xxl,
      ),
      color: AppColors.primary,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'OUR ROOMS',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.accent,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Find Your Perfect Room',
              style: AppTypography.headlineLarge.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose from our range of beautifully appointed rooms and suites',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, RoomType? type) {
    final isSelected = _selectedType == type;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedType = type),
        selectedColor: AppColors.accent,
        labelStyle: AppTypography.labelMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
    );
  }
}
