import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../vehicle/data/vehicle_repository.dart';
import '../data/reminder_repository.dart';
import '../domain/reminder_model.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeVehicle = ref.watch(activeVehicleProvider);
    final remindersAsync = ref.watch(activeVehicleRemindersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Maintenance Reminders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.secondaryText,
          tabs: const [
            Tab(text: 'Upcoming & Overdue'),
            Tab(text: 'Completed History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alert_rounded, color: AppColors.accent),
            tooltip: 'Add Reminder',
            onPressed: () {
              if (activeVehicle != null) {
                _showAddEditReminderSheet(context, ref, vehicleId: activeVehicle.id, currentOdo: activeVehicle.currentOdometer);
              }
            },
          ),
        ],
      ),
      body: activeVehicle == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : remindersAsync.when(
              data: (reminders) {
                final upcoming = reminders.where((r) => !r.isCompleted).toList();
                final completed = reminders.where((r) => r.isCompleted).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingList(upcoming, activeVehicle.currentOdometer),
                    _buildCompletedList(completed),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.critical))),
            ),
    );
  }

  Widget _buildUpcomingList(List<MaintenanceReminderModel> reminders, int currentOdometer) {
    if (reminders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none_rounded, size: 54, color: AppColors.tertiaryText),
            const SizedBox(height: 12),
            const Text('No pending reminders for this vehicle', style: TextStyle(color: AppColors.secondaryText)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                final vehicle = ref.read(activeVehicleProvider);
                if (vehicle != null) {
                  _showAddEditReminderSheet(context, ref, vehicleId: vehicle.id, currentOdo: vehicle.currentOdometer);
                }
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Reminder'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      itemCount: reminders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final isOverdue = reminder.isOverdue(currentOdometer);
        final isDueSoon = reminder.isDueSoon(currentOdometer);

        Color statusColor = AppColors.secondaryText;
        String statusLabel = 'SCHEDULED';
        if (isOverdue) {
          statusColor = AppColors.critical;
          statusLabel = 'OVERDUE';
        } else if (isDueSoon) {
          statusColor = AppColors.warning;
          statusLabel = 'DUE SOON';
        } else if (reminder.isSnoozed) {
          statusColor = AppColors.accent;
          statusLabel = 'SNOOZED';
        }

        return GlassCard(
          borderColor: isOverdue ? AppColors.critical.withValues(alpha: 0.8) : AppColors.cardBorder,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _iconForCategory(reminder.category),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              reminder.category.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.tertiaryText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        if (reminder.description != null && reminder.description!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            reminder.description!,
                            style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText, size: 20),
                    color: AppColors.elevatedSurface,
                    onSelected: (val) {
                      if (val == 'edit') {
                        _showAddEditReminderSheet(context, ref,
                            vehicleId: reminder.vehicleId, currentOdo: currentOdometer, existing: reminder);
                      } else if (val == 'snooze') {
                        ref.read(reminderRepositoryProvider).snoozeReminder(reminder.id, const Duration(days: 7));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reminder snoozed for 7 days')),
                        );
                      } else if (val == 'delete') {
                        ref.read(reminderRepositoryProvider).deleteReminder(reminder.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'snooze',
                        child: Row(
                          children: [
                            Icon(Icons.snooze_rounded, size: 16, color: AppColors.accent),
                            SizedBox(width: 8),
                            Text('Snooze 7 Days'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryText),
                            SizedBox(width: 8),
                            Text('Edit Reminder'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.critical),
                            SizedBox(width: 8),
                            Text('Delete Reminder', style: TextStyle(color: AppColors.critical)),
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
                  if (reminder.dueDate != null)
                    _buildMetaChip(
                      Icons.event_rounded,
                      'Due ${DateFormat('dd MMM yyyy').format(reminder.dueDate!)}',
                      reminder.remainingDays() != null ? '(${reminder.remainingDays()}d left)' : null,
                    ),
                  if (reminder.dueOdometer != null)
                    _buildMetaChip(
                      Icons.speed_rounded,
                      'At ${NumberFormat('#,###').format(reminder.dueOdometer)} km',
                      reminder.remainingKm(currentOdometer) != null
                          ? '(${NumberFormat('#,###').format(reminder.remainingKm(currentOdometer))} km left)'
                          : null,
                    ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      await ref.read(reminderRepositoryProvider).completeReminder(
                            reminder.id,
                            createNextRecurrence: true,
                            currentOdometer: currentOdometer,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              reminder.recurrenceIntervalKm != null || reminder.recurrenceIntervalMonths != null
                                  ? 'Reminder completed & next recurring interval scheduled!'
                                  : 'Reminder completed!',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.accent),
                    label: const Text('Complete', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(List<MaintenanceReminderModel> reminders) {
    if (reminders.isEmpty) {
      return const Center(
        child: Text('No completed reminders yet', style: TextStyle(color: AppColors.secondaryText)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      itemCount: reminders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final reminder = reminders[index];
        final completedStr = reminder.completedAt != null
            ? DateFormat('dd MMM yyyy').format(reminder.completedAt!)
            : 'Done';

        return GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Completed on $completedStr • ${reminder.category.label}',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.tertiaryText, size: 18),
                onPressed: () => ref.read(reminderRepositoryProvider).deleteReminder(reminder.id),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaChip(IconData icon, String text, String? subtext) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
          ],
        ),
        if (subtext != null) ...[
          const SizedBox(height: 2),
          Text(
            subtext,
            style: const TextStyle(fontSize: 10.5, color: AppColors.secondaryText),
          ),
        ],
      ],
    );
  }

  IconData _iconForCategory(ReminderCategory category) {
    switch (category) {
      case ReminderCategory.service:
        return Icons.build_rounded;
      case ReminderCategory.tyre:
        return Icons.donut_large_rounded;
      case ReminderCategory.insurance:
        return Icons.verified_user_rounded;
      case ReminderCategory.puc:
        return Icons.eco_rounded;
      case ReminderCategory.warranty:
        return Icons.shield_rounded;
      case ReminderCategory.battery:
        return Icons.battery_charging_full_rounded;
      case ReminderCategory.custom:
        return Icons.alarm_rounded;
    }
  }

  void _showAddEditReminderSheet(
    BuildContext context,
    WidgetRef ref, {
    required String vehicleId,
    required int currentOdo,
    MaintenanceReminderModel? existing,
  }) {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final odoCtrl = TextEditingController(text: existing?.dueOdometer?.toString() ?? '');
    final leadDaysCtrl = TextEditingController(text: (existing?.notificationLeadDays ?? 7).toString());
    final recKmCtrl = TextEditingController(text: existing?.recurrenceIntervalKm?.toString() ?? '');
    final recMonthsCtrl = TextEditingController(text: existing?.recurrenceIntervalMonths?.toString() ?? '');

    ReminderCategory category = existing?.category ?? ReminderCategory.service;
    ReminderType reminderType = existing?.reminderType ?? ReminderType.both;
    DateTime? dueDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 90));

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
                      isEditing ? 'Edit Reminder' : 'Create Smart Reminder',
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
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Reminder Title',
                    hintText: 'e.g. 10,000 km Service or Insurance Renewal',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<ReminderCategory>(
                        initialValue: category,
                        decoration: const InputDecoration(labelText: 'Category'),
                        dropdownColor: AppColors.elevatedSurface,
                        items: ReminderCategory.values
                            .map((c) => DropdownMenuItem(value: c, child: Text(c.label, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => category = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<ReminderType>(
                        initialValue: reminderType,
                        decoration: const InputDecoration(labelText: 'Trigger Type'),
                        dropdownColor: AppColors.elevatedSurface,
                        items: ReminderType.values
                            .map((t) => DropdownMenuItem(value: t, child: Text(t.label, style: const TextStyle(fontSize: 12))))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => reminderType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (reminderType == ReminderType.date || reminderType == ReminderType.both) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_rounded, color: AppColors.accent),
                    title: Text(
                      dueDate != null
                          ? 'Due Date: ${DateFormat('dd MMMM yyyy').format(dueDate!)}'
                          : 'Select Due Date',
                      style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: dueDate ?? DateTime.now().add(const Duration(days: 30)),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                        );
                        if (picked != null) {
                          setModalState(() => dueDate = picked);
                        }
                      },
                      child: const Text('Pick Date'),
                    ),
                  ),
                ],
                if (reminderType == ReminderType.odometer || reminderType == ReminderType.both) ...[
                  TextField(
                    controller: odoCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Due at Odometer (km)',
                      helperText: 'Current reading: ${NumberFormat('#,###').format(currentOdo)} km',
                      prefixIcon: const Icon(Icons.speed_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: recKmCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Recur Every (km)',
                          hintText: 'e.g. 5000',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: recMonthsCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Recur Every (Months)',
                          hintText: 'e.g. 6 or 12',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: leadDaysCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Notification Lead Time (Days)',
                    hintText: '7',
                    prefixIcon: Icon(Icons.notifications_active_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description / Instructions (Optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a reminder title.')),
                        );
                        return;
                      }

                      final dueOdo = int.tryParse(odoCtrl.text.trim());
                      final leadDays = int.tryParse(leadDaysCtrl.text.trim()) ?? 7;
                      final recKm = int.tryParse(recKmCtrl.text.trim());
                      final recMonths = int.tryParse(recMonthsCtrl.text.trim());
                      final now = DateTime.now();

                      if (isEditing) {
                        final updated = existing.copyWith(
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                          category: category,
                          reminderType: reminderType,
                          dueDate: dueDate,
                          dueOdometer: dueOdo,
                          notificationLeadDays: leadDays,
                          recurrenceIntervalKm: recKm,
                          recurrenceIntervalMonths: recMonths,
                        );
                        await ref.read(reminderRepositoryProvider).updateReminder(updated);
                      } else {
                        final newReminder = MaintenanceReminderModel(
                          id: const Uuid().v4(),
                          vehicleId: vehicleId,
                          title: titleCtrl.text.trim(),
                          description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                          category: category,
                          reminderType: reminderType,
                          dueDate: dueDate,
                          dueOdometer: dueOdo,
                          notificationLeadDays: leadDays,
                          recurrenceIntervalKm: recKm,
                          recurrenceIntervalMonths: recMonths,
                          createdAt: now,
                        );
                        await ref.read(reminderRepositoryProvider).createReminder(newReminder);
                      }

                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: Text(isEditing ? 'Save Changes' : 'Create Reminder'),
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
