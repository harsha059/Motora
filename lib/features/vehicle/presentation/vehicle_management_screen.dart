import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/vehicle_repository.dart';
import '../domain/vehicle_model.dart';

class VehicleManagementScreen extends ConsumerWidget {
  const VehicleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(allVehiclesProvider);
    final activeVehicleId = ref.watch(activeVehicleIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Garage Vehicles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            tooltip: 'Add Vehicle',
            onPressed: () => _showAddEditVehicleDialog(context, ref),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 54, color: AppColors.tertiaryText),
                  const SizedBox(height: 12),
                  const Text('No vehicles found', style: TextStyle(color: AppColors.secondaryText)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditVehicleDialog(context, ref),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Vehicle'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final isActive = vehicle.id == activeVehicleId;

              return GlassCard(
                borderColor: isActive ? AppColors.accent : AppColors.cardBorder,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.accentDim : AppColors.elevatedSurface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isActive ? AppColors.accent : AppColors.cardBorder,
                            ),
                          ),
                          child: Icon(
                            vehicle.vehicleType.toLowerCase().contains('ev') ||
                                    vehicle.vehicleType.toLowerCase().contains('electric')
                                ? Icons.electric_car_rounded
                                : Icons.directions_car_rounded,
                            color: isActive ? AppColors.accent : AppColors.secondaryText,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    vehicle.nickname,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentDim,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                                      ),
                                      child: const Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.accent,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${vehicle.manufacturer} ${vehicle.model} • ${vehicle.variant}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              if (vehicle.registrationNumber != null && vehicle.registrationNumber!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  vehicle.registrationNumber!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.tertiaryText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText),
                          color: AppColors.elevatedSurface,
                          onSelected: (val) {
                            if (val == 'select') {
                              ref.read(activeVehicleIdProvider.notifier).selectVehicle(vehicle.id);
                            } else if (val == 'edit') {
                              _showAddEditVehicleDialog(context, ref, vehicle: vehicle);
                            } else if (val == 'delete') {
                              _confirmDeleteVehicle(context, ref, vehicle, vehicles.length);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!isActive)
                              const PopupMenuItem(
                                value: 'select',
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.accent),
                                    SizedBox(width: 10),
                                    Text('Set as Active'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryText),
                                  SizedBox(width: 10),
                                  Text('Edit Details'),
                                ],
                              ),
                            ),
                            if (vehicles.length > 1)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.critical),
                                    SizedBox(width: 10),
                                    Text('Delete Vehicle', style: TextStyle(color: AppColors.critical)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatChip(
                          Icons.speed_rounded,
                          '${NumberFormat('#,###').format(vehicle.currentOdometer)} km',
                        ),
                        _buildStatChip(
                          Icons.calendar_today_rounded,
                          vehicle.modelYear != null ? '${vehicle.modelYear}' : 'Year N/A',
                        ),
                        _buildStatChip(
                          Icons.category_outlined,
                          vehicle.vehicleType,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(child: Text('Error loading vehicles: $e', style: const TextStyle(color: AppColors.critical))),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.tertiaryText),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  void _confirmDeleteVehicle(BuildContext context, WidgetRef ref, VehicleModel vehicle, int totalCount) {
    if (totalCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete the only vehicle in your garage.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Delete ${vehicle.nickname}?'),
        content: Text(
          'Are you sure you want to delete this vehicle?\n\n'
          'All vehicle-specific logs, service visits, and records associated with this vehicle will be removed.\n'
          'This action cannot be undone.',
          style: const TextStyle(color: AppColors.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(vehicleRepositoryProvider).deleteVehicle(vehicle.id);
                // If active vehicle was deleted, switch to first remaining
                final remaining = await ref.read(vehicleRepositoryProvider).getAllVehicles();
                if (remaining.isNotEmpty) {
                  ref.read(activeVehicleIdProvider.notifier).selectVehicle(remaining.first.id);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${vehicle.nickname} deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting vehicle: $e')),
                  );
                }
              }
            },
            child: const Text('Delete Vehicle'),
          ),
        ],
      ),
    );
  }

  void _showAddEditVehicleDialog(BuildContext context, WidgetRef ref, {VehicleModel? vehicle}) {
    final isEditing = vehicle != null;
    final nicknameCtrl = TextEditingController(text: vehicle?.nickname ?? '');
    final makeCtrl = TextEditingController(text: vehicle?.manufacturer ?? '');
    final modelCtrl = TextEditingController(text: vehicle?.model ?? '');
    final variantCtrl = TextEditingController(text: vehicle?.variant ?? '');
    final regCtrl = TextEditingController(text: vehicle?.registrationNumber ?? '');
    final yearCtrl = TextEditingController(text: vehicle?.modelYear?.toString() ?? '');
    final odoCtrl = TextEditingController(text: vehicle?.currentOdometer.toString() ?? '0');
    String vehicleType = vehicle?.vehicleType ?? 'Electric (EV)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEditing ? 'Edit Vehicle' : 'Add New Vehicle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nickname (e.g. Comet EV, Daily City Car)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: makeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Make / Manufacturer',
                          hintText: 'e.g. MG, Hyundai',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: modelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Model',
                          hintText: 'e.g. Comet EV',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: variantCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Variant',
                          hintText: 'e.g. Plush, Exclusive',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: regCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Registration No.',
                          hintText: 'e.g. KA 01 MG 2024',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: yearCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Model Year',
                          hintText: '2024',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: odoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Current Odometer (km)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: vehicleType,
                  decoration: const InputDecoration(
                    labelText: 'Powertrain Type',
                    prefixIcon: Icon(Icons.bolt_rounded),
                  ),
                  dropdownColor: AppColors.elevatedSurface,
                  items: const [
                    DropdownMenuItem(value: 'Electric (EV)', child: Text('Electric (EV)')),
                    DropdownMenuItem(value: 'ICE Petrol/Diesel', child: Text('ICE Petrol/Diesel')),
                    DropdownMenuItem(value: 'Strong Hybrid', child: Text('Strong Hybrid')),
                    DropdownMenuItem(value: 'Plug-in Hybrid (PHEV)', child: Text('Plug-in Hybrid (PHEV)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => vehicleType = val);
                    }
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nicknameCtrl.text.trim().isEmpty || makeCtrl.text.trim().isEmpty || modelCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in nickname, manufacturer, and model.')),
                        );
                        return;
                      }

                      final now = DateTime.now();
                      final odo = int.tryParse(odoCtrl.text.trim()) ?? 0;
                      final year = int.tryParse(yearCtrl.text.trim());

                      if (isEditing) {
                        final updated = vehicle.copyWith(
                          nickname: nicknameCtrl.text.trim(),
                          manufacturer: makeCtrl.text.trim(),
                          model: modelCtrl.text.trim(),
                          variant: variantCtrl.text.trim(),
                          registrationNumber: regCtrl.text.trim().isNotEmpty ? regCtrl.text.trim() : null,
                          modelYear: year,
                          currentOdometer: odo,
                          vehicleType: vehicleType,
                          updatedAt: now,
                        );
                        await ref.read(vehicleRepositoryProvider).updateVehicle(updated);
                      } else {
                        final newId = const Uuid().v4();
                        final newVehicle = VehicleModel(
                          id: newId,
                          nickname: nicknameCtrl.text.trim(),
                          manufacturer: makeCtrl.text.trim(),
                          model: modelCtrl.text.trim(),
                          variant: variantCtrl.text.trim(),
                          registrationNumber: regCtrl.text.trim().isNotEmpty ? regCtrl.text.trim() : null,
                          modelYear: year,
                          currentOdometer: odo,
                          vehicleType: vehicleType,
                          createdAt: now,
                          updatedAt: now,
                        );
                        await ref.read(vehicleRepositoryProvider).createVehicle(newVehicle);
                        ref.read(activeVehicleIdProvider.notifier).selectVehicle(newId);
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(isEditing ? 'Save Changes' : 'Add Vehicle to Garage'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
