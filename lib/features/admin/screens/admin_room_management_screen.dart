import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/ss_button.dart';
import '../../../core/widgets/ss_status_chip.dart';
import '../../../core/widgets/ss_loading.dart';
import '../../../core/widgets/ss_error_state.dart';
import '../../../core/widgets/ss_empty_state.dart';
import '../../../core/widgets/ss_text_field.dart';
import '../../../models/room.dart';
import '../../../providers/providers.dart';
import '../../../core/services/convex_storage_service.dart';

/// Admin room management — CRUD operations on rooms.
class AdminRoomManagementScreen extends ConsumerWidget {
  const AdminRoomManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomsProvider);
    final isDesktop = Responsive.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Room Management', style: AppTypography.headlineSmall),
                    const SizedBox(height: 2),
                    Text('Manage hotel rooms, status, and pricing.',
                        style: AppTypography.bodySmall),
                  ],
                ),
              ),
              SSButton(
                label: 'Add Room',
                icon: Icons.add,
                size: SSButtonSize.small,
                onPressed: () => _showAddRoomDialog(context, ref),
              ),
            ],
          ),
        ),
        Expanded(
          child: roomsAsync.when(
            loading: () => const SSLoading(type: SSLoadingType.table),
            error: (e, _) => SSErrorState(
              message: e.toString(),
              onRetry: () => ref.invalidate(roomsProvider),
            ),
            data: (rooms) {
              if (rooms.isEmpty) {
                return const SSEmptyState(
                  icon: Icons.king_bed_outlined,
                  title: 'No Rooms',
                  description: 'Add your first room to get started.',
                );
              }

              if (isDesktop) {
                return _buildTable(context, ref, rooms);
              }

              return _buildCards(context, ref, rooms);
            },
          ),
        ),
      ],
    );
  }

  void _showAddRoomDialog(BuildContext context, WidgetRef ref) {
    final numberCtrl = TextEditingController();
    final floorCtrl = TextEditingController(text: '1');
    final capacityCtrl = TextEditingController(text: '2');
    final priceCtrl = TextEditingController(text: '5000');
    final amenitiesCtrl = TextEditingController(text: 'WiFi, TV, AC');
    String selectedType = 'standard';
    final formKey = GlobalKey<FormState>();
    List<Uint8List> imageBytesList = [];
    List<String> mimeTypes = [];
    bool isSaving = false;

    Future<void> pickImages(StateSetter setDialogState) async {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final selected = pickedFiles.take(6).toList();
        final bytesList = <Uint8List>[];
        final types = <String>[];
        for (final file in selected) {
          bytesList.add(await file.readAsBytes());
          types.add(file.mimeType ?? 'image/jpeg');
        }
        setDialogState(() {
          imageBytesList = bytesList;
          mimeTypes = types;
        });

        if (pickedFiles.length > 6 && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Only first 6 images were selected.')),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add New Room'),
          content: SizedBox(
            width: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SSTextField(
                      label: 'Room Number',
                      hint: '101',
                      controller: numberCtrl,
                      prefixIcon: Icons.meeting_room_outlined,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Room Type',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'standard', child: Text('Standard')),
                        DropdownMenuItem(
                            value: 'deluxe', child: Text('Deluxe')),
                        DropdownMenuItem(
                            value: 'suite', child: Text('Suite')),
                        DropdownMenuItem(
                            value: 'presidential',
                            child: Text('Presidential')),
                      ],
                      onChanged: (v) =>
                          setDialogState(() => selectedType = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: SSTextField(
                            label: 'Floor',
                            hint: '1',
                            controller: floorCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SSTextField(
                            label: 'Capacity',
                            hint: '2',
                            controller: capacityCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SSTextField(
                      label: 'Price per Night (PKR)',
                      hint: '5000',
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SSTextField(
                      label: 'Amenities (comma-separated)',
                      hint: 'WiFi, TV, AC, Mini Bar',
                      controller: amenitiesCtrl,
                      prefixIcon: Icons.star_outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Room Images (Optional, up to 6)', style: AppTypography.labelLarge),
                    const SizedBox(height: AppSpacing.xs),
                    GestureDetector(
                      onTap: () => pickImages(setDialogState),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 200),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: imageBytesList.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: List.generate(imageBytesList.length, (index) {
                                    return Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                          child: Image.memory(
                                            imageBytesList[index],
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: InkWell(
                                            onTap: () {
                                              setDialogState(() {
                                                imageBytesList.removeAt(index);
                                                mimeTypes.removeAt(index);
                                              });
                                            },
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.black54,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              child: const Icon(
                                                Icons.close,
                                                size: 14,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.upload_file, size: 48, color: AppColors.textSecondary),
                                  SizedBox(height: AppSpacing.sm),
                                  Text('Tap to upload room photos'),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setDialogState(() => isSaving = true);

                      final imageUrls = <String>[];
                      if (imageBytesList.isNotEmpty) {
                        try {
                          final storageService = ref.read(convexStorageServiceProvider);
                          for (var i = 0; i < imageBytesList.length; i++) {
                            final storageId = await storageService.uploadImage(
                              imageBytesList[i],
                              mimeTypes[i],
                            );
                            if (storageId != null) {
                              imageUrls.add(storageService.getImageUrl(storageId));
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to upload image: $e')),
                            );
                          }
                        }
                      }

                      final room = Room(
                        id: '',
                        number: numberCtrl.text.trim(),
                        type: RoomType.values.firstWhere(
                          (t) => t.name == selectedType,
                          orElse: () => RoomType.standard,
                        ),
                        name: 'Room ${numberCtrl.text.trim()}',
                        description:
                            'Experience luxury in our beautifully appointed $selectedType room.',
                        pricePerNight:
                            double.tryParse(priceCtrl.text.trim()) ?? 5000,
                        capacity:
                            int.tryParse(capacityCtrl.text.trim()) ?? 2,
                        floor: int.tryParse(floorCtrl.text.trim()) ?? 1,
                        sizeInSqFt: 400,
                        status: RoomStatus.available,
                        amenities: amenitiesCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        imageUrls: imageUrls.take(6).toList(),
                        isFeatured: false,
                      );

                      try {
                        await ref
                            .read(roomServiceProvider)
                            .createRoom(room);
                        ref.invalidate(roomsProvider);
                        ref.invalidate(featuredRoomsProvider);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Room ${room.number} created successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create room: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditRoomDialog(BuildContext context, WidgetRef ref, Room room) {
    final numberCtrl = TextEditingController(text: room.number);
    final floorCtrl = TextEditingController(text: '${room.floor}');
    final capacityCtrl = TextEditingController(text: '${room.capacity}');
    final priceCtrl = TextEditingController(text: room.pricePerNight.toStringAsFixed(0));
    final amenitiesCtrl = TextEditingController(text: room.amenities.join(', '));
    String selectedType = room.type.name;
    final formKey = GlobalKey<FormState>();

    final existingUrls = List<String>.from(room.imageUrls);
    final List<Uint8List> newImageBytesList = [];
    final List<String> newMimeTypes = [];
    bool isSaving = false;

    Future<void> pickImages(StateSetter setDialogState) async {
      final remaining = 6 - (existingUrls.length + newImageBytesList.length);
      if (remaining <= 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 6 images allowed per room.')),
          );
        }
        return;
      }

      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      final selected = pickedFiles.take(remaining).toList();
      final bytesList = <Uint8List>[];
      final types = <String>[];

      for (final file in selected) {
        bytesList.add(await file.readAsBytes());
        types.add(file.mimeType ?? 'image/jpeg');
      }

      setDialogState(() {
        newImageBytesList.addAll(bytesList);
        newMimeTypes.addAll(types);
      });
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit Room ${room.number}'),
          content: SizedBox(
            width: 520,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SSTextField(
                      label: 'Room Number',
                      hint: '101',
                      controller: numberCtrl,
                      prefixIcon: Icons.meeting_room_outlined,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(labelText: 'Room Type'),
                      items: const [
                        DropdownMenuItem(value: 'standard', child: Text('Standard')),
                        DropdownMenuItem(value: 'deluxe', child: Text('Deluxe')),
                        DropdownMenuItem(value: 'suite', child: Text('Suite')),
                        DropdownMenuItem(value: 'presidential', child: Text('Presidential')),
                      ],
                      onChanged: (v) => setDialogState(() => selectedType = v ?? selectedType),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: SSTextField(
                            label: 'Floor',
                            hint: '1',
                            controller: floorCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: SSTextField(
                            label: 'Capacity',
                            hint: '2',
                            controller: capacityCtrl,
                            keyboardType: TextInputType.number,
                            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SSTextField(
                      label: 'Price per Night (PKR)',
                      hint: '5000',
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.attach_money,
                      validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SSTextField(
                      label: 'Amenities (comma-separated)',
                      hint: 'WiFi, TV, AC',
                      controller: amenitiesCtrl,
                      prefixIcon: Icons.star_outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Room Images (max 6)', style: AppTypography.labelLarge),
                        TextButton.icon(
                          onPressed: () => pickImages(setDialogState),
                          icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                          label: const Text('Add Images'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 120),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ...List.generate(existingUrls.length, (index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  child: Image.network(
                                    existingUrls[index],
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 90,
                                      height: 90,
                                      color: AppColors.border,
                                      child: const Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: InkWell(
                                    onTap: () => setDialogState(() => existingUrls.removeAt(index)),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          ...List.generate(newImageBytesList.length, (index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  child: Image.memory(
                                    newImageBytesList[index],
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: InkWell(
                                    onTap: () => setDialogState(() {
                                      newImageBytesList.removeAt(index);
                                      newMimeTypes.removeAt(index);
                                    }),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setDialogState(() => isSaving = true);

                      final uploadedUrls = <String>[];
                      if (newImageBytesList.isNotEmpty) {
                        try {
                          final storageService = ref.read(convexStorageServiceProvider);
                          for (var i = 0; i < newImageBytesList.length; i++) {
                            final storageId = await storageService.uploadImage(
                              newImageBytesList[i],
                              newMimeTypes[i],
                            );
                            if (storageId != null) {
                              uploadedUrls.add(storageService.getImageUrl(storageId));
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to upload image: $e')),
                            );
                          }
                        }
                      }

                      final updated = Room(
                        id: room.id,
                        number: numberCtrl.text.trim(),
                        type: RoomType.values.firstWhere(
                          (t) => t.name == selectedType,
                          orElse: () => room.type,
                        ),
                        name: 'Room ${numberCtrl.text.trim()}',
                        description: room.description,
                        pricePerNight: double.tryParse(priceCtrl.text.trim()) ?? room.pricePerNight,
                        capacity: int.tryParse(capacityCtrl.text.trim()) ?? room.capacity,
                        floor: int.tryParse(floorCtrl.text.trim()) ?? room.floor,
                        sizeInSqFt: room.sizeInSqFt,
                        status: room.status,
                        amenities: amenitiesCtrl.text
                            .split(',')
                            .map((e) => e.trim())
                            .where((e) => e.isNotEmpty)
                            .toList(),
                        imageUrls: [...existingUrls, ...uploadedUrls].take(6).toList(),
                        isFeatured: room.isFeatured,
                      );

                      try {
                        await ref.read(roomServiceProvider).updateRoom(updated);
                        ref.invalidate(roomsProvider);
                        ref.invalidate(featuredRoomsProvider);
                        ref.invalidate(roomDetailProvider(room.id));
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Room ${updated.number} updated successfully!'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSaving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to update room: $e'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleRoomAction(
      BuildContext context, WidgetRef ref, Room room, String action) async {
    if (action == 'edit') {
      _showEditRoomDialog(context, ref, room);
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete Room'),
          content: Text('Are you sure you want to delete Room ${room.number}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await ref.read(roomServiceProvider).deleteRoom(room.id);
          ref.invalidate(roomsProvider);
          ref.invalidate(featuredRoomsProvider);
          ref.invalidate(roomDetailProvider(room.id));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Room ${room.number} deleted.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete room: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    } else if (action == 'status') {
      final newStatus = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text('Change Status - Room ${room.number}'),
          children: ['available', 'occupied', 'reserved', 'maintenance']
              .map((s) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, s),
                    child: Text(s.toUpperCase()),
                  ))
              .toList(),
        ),
      );

      if (newStatus != null) {
        try {
          final updated = Room(
            id: room.id,
            number: room.number,
            type: room.type,
            name: room.name,
            description: room.description,
            pricePerNight: room.pricePerNight,
            capacity: room.capacity,
            floor: room.floor,
            sizeInSqFt: room.sizeInSqFt,
            status: RoomStatus.values.firstWhere((s) => s.name == newStatus),
            amenities: room.amenities,
            imageUrls: room.imageUrls,
            isFeatured: room.isFeatured,
          );
          await ref.read(roomServiceProvider).updateRoom(updated);
          ref.invalidate(roomsProvider);
          ref.invalidate(featuredRoomsProvider);
          ref.invalidate(roomDetailProvider(room.id));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Room ${room.number} status changed to ${newStatus.toUpperCase()}.'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update: $e'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildTable(BuildContext context, WidgetRef ref, List<Room> rooms) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
            columns: const [
              DataColumn(label: Text('Room #')),
              DataColumn(label: Text('Type')),
              DataColumn(label: Text('Floor')),
              DataColumn(label: Text('Capacity')),
              DataColumn(label: Text('Price/Night'), numeric: true),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Amenities')),
              DataColumn(label: Text('Actions')),
            ],
            rows: rooms.map((r) {
              return DataRow(cells: [
                DataCell(Text(r.number, style: AppTypography.titleSmall)),
                DataCell(Text(r.type.name.toUpperCase())),
                DataCell(Text('${r.floor}')),
                DataCell(Text('${r.capacity}')),
                DataCell(Text('PKR ${r.pricePerNight.toStringAsFixed(0)}')),
                DataCell(SSStatusChip.fromString(r.status.name)),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      r.amenities.take(3).join(', '),
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ),
                DataCell(
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit Room')),
                      PopupMenuItem(value: 'status', child: Text('Change Status')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (action) =>
                        _handleRoomAction(context, ref, r, action),
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCards(BuildContext context, WidgetRef ref, List<Room> rooms) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: rooms.length,
      itemBuilder: (_, i) {
        final r = rooms[i];
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Room ${r.number}', style: AppTypography.titleMedium),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SSStatusChip.fromString(r.status.name),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 18),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'edit', child: Text('Edit Room')),
                          PopupMenuItem(
                              value: 'status', child: Text('Change Status')),
                          PopupMenuItem(
                              value: 'delete', child: Text('Delete')),
                        ],
                        onSelected: (action) =>
                            _handleRoomAction(context, ref, r, action),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                  '${r.type.name.toUpperCase()} • Floor ${r.floor} • Up to ${r.capacity} guests',
                  style: AppTypography.bodySmall),
              const SizedBox(height: AppSpacing.xs),
              Text('PKR ${r.pricePerNight.toStringAsFixed(0)} / night',
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.accent)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: r.amenities.take(4).map((a) {
                  return Chip(
                    label: Text(a, style: const TextStyle(fontSize: 10)),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
