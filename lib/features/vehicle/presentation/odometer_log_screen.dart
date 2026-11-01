import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/odometer_repository.dart';
import '../data/vehicle_repository.dart';

class OdometerLogScreen extends ConsumerWidget {
  const OdometerLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeVehicle = ref.watch(activeVehicleProvider);
    final historyAsync = ref.watch(activeVehicleOdometerHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Odometer Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            tooltip: 'Log Reading',
            onPressed: () {
              if (activeVehicle != null) {
                _showAddReadingDialog(context, ref, activeVehicle.id, activeVehicle.currentOdometer);
              }
            },
          ),
        ],
      ),
      body: activeVehicle == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                // Top vehicle summary hero
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeVehicle.nickname.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: AppColors.tertiaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${NumberFormat('#,###').format(activeVehicle.currentOdometer)} km',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Current Recorded Odometer',
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddReadingDialog(
                            context,
                            ref,
                            activeVehicle.id,
                            activeVehicle.currentOdometer,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('New Entry'),
                        ),
                      ],
                    ),
                  ),
                ),

                // History List
                Expanded(
                  child: historyAsync.when(
                    data: (readings) {
                      if (readings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.speed_rounded, size: 50, color: AppColors.tertiaryText),
                              const SizedBox(height: 12),
                              const Text('No odometer readings logged yet', style: TextStyle(color: AppColors.secondaryText)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _showAddReadingDialog(
                                  context,
                                  ref,
                                  activeVehicle.id,
                                  activeVehicle.currentOdometer,
                                ),
                                child: const Text('Log Initial Reading'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        itemCount: readings.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = readings[index];
                          final dateStr = DateFormat('dd MMM yyyy').format(item.readingDate);
                          final kmStr = NumberFormat('#,###').format(item.reading);

                          return GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: item.isCorrection
                                        ? AppColors.warning.withValues(alpha: 0.15)
                                        : AppColors.elevatedSurface,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    item.isCorrection ? Icons.build_circle_outlined : Icons.speed_rounded,
                                    color: item.isCorrection ? AppColors.warning : AppColors.accent,
                                    size: 20,
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
                                            '$kmStr km',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primaryText,
                                            ),
                                          ),
                                          if (item.isCorrection) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.warning.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'CORRECTION',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.warning,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.notes != null && item.notes!.isNotEmpty
                                            ? '$dateStr • ${item.notes}'
                                            : dateStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (item.distanceDelta != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: item.distanceDelta! >= 0
                                          ? AppColors.accentDim
                                          : AppColors.critical.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.distanceDelta! >= 0
                                          ? '+${NumberFormat('#,###').format(item.distanceDelta)} km'
                                          : '${NumberFormat('#,###').format(item.distanceDelta)} km',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: item.distanceDelta! >= 0 ? AppColors.accent : AppColors.critical,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.critical))),
                  ),
                ),
              ],
            ),
    );
  }

  void _showAddReadingDialog(BuildContext context, WidgetRef ref, String vehicleId, int currentOdo) {
    final readingCtrl = TextEditingController(text: currentOdo > 0 ? (currentOdo + 100).toString() : '');
    final notesCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isCorrection = false;

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Log Odometer Reading',
                    style: TextStyle(
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
                controller: readingCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Odometer Reading (km)',
                  helperText: 'Previous reading: ${NumberFormat('#,###').format(currentOdo)} km',
                  prefixIcon: const Icon(Icons.speed_rounded),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_rounded, color: AppColors.accent),
                title: Text(
                  'Date: ${DateFormat('dd MMMM yyyy').format(selectedDate)}',
                  style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: const Text('Change Date'),
                ),
              ),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g. Service visit, road trip check',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: isCorrection,
                activeColor: AppColors.warning,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Explicit correction / cluster reset',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                ),
                subtitle: const Text(
                  'Enable only if correcting a typo or replacing an instrument cluster.',
                  style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                ),
                onChanged: (val) {
                  setModalState(() => isCorrection = val ?? false);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final reading = int.tryParse(readingCtrl.text.trim());
                    if (reading == null || reading <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid positive odometer reading.')),
                      );
                      return;
                    }

                    try {
                      await ref.read(odometerRepositoryProvider).addReading(
                            vehicleId: vehicleId,
                            reading: reading,
                            readingDate: selectedDate,
                            notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                            isCorrection: isCorrection,
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logged ${NumberFormat('#,###').format(reading)} km successfully')),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString().replaceAll('ArgumentError: ', ''))),
                        );
                      }
                    }
                  },
                  child: const Text('Save Odometer Reading'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
