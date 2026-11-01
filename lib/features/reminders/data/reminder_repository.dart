import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../vehicle/data/vehicle_repository.dart';
import '../domain/reminder_model.dart';
import '../services/notification_service.dart';

class ReminderRepository {
  final AppDatabase _db;
  final NotificationService _notificationService;

  ReminderRepository(this._db, this._notificationService);

  MaintenanceReminderModel _toDomain(MaintenanceReminder row) {
    return MaintenanceReminderModel(
      id: row.id,
      vehicleId: row.vehicleId,
      title: row.title,
      description: row.description,
      category: ReminderCategory.fromString(row.category),
      reminderType: ReminderType.fromString(row.reminderType),
      dueDate: row.dueDate,
      dueOdometer: row.dueOdometer,
      notificationLeadDays: row.notificationLeadDays,
      recurrenceIntervalKm: row.recurrenceIntervalKm,
      recurrenceIntervalMonths: row.recurrenceIntervalMonths,
      isCompleted: row.isCompleted,
      isSnoozed: row.isSnoozed,
      snoozedUntil: row.snoozedUntil,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
    );
  }

  Stream<List<MaintenanceReminderModel>> watchRemindersForVehicle(
    String vehicleId, {
    bool? includeCompleted,
  }) {
    final query = _db.select(_db.maintenanceReminders)
      ..where((t) => t.vehicleId.equals(vehicleId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.isCompleted, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.dueOdometer, mode: OrderingMode.asc),
      ]);

    if (includeCompleted == false) {
      query.where((t) => t.isCompleted.equals(false));
    }

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<MaintenanceReminderModel>> getRemindersForVehicle(String vehicleId) async {
    final rows = await (_db.select(_db.maintenanceReminders)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.isCompleted, mode: OrderingMode.asc),
            (t) => OrderingTerm(expression: t.dueDate, mode: OrderingMode.asc),
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  Future<MaintenanceReminderModel?> getReminderById(String id) async {
    final row = await (_db.select(_db.maintenanceReminders)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Future<void> createReminder(MaintenanceReminderModel reminder) async {
    await _db.into(_db.maintenanceReminders).insert(
          MaintenanceRemindersCompanion.insert(
            id: reminder.id,
            vehicleId: reminder.vehicleId,
            title: reminder.title,
            description: Value(reminder.description),
            category: reminder.category.name,
            reminderType: reminder.reminderType.name,
            dueDate: Value(reminder.dueDate),
            dueOdometer: Value(reminder.dueOdometer),
            notificationLeadDays: Value(reminder.notificationLeadDays),
            recurrenceIntervalKm: Value(reminder.recurrenceIntervalKm),
            recurrenceIntervalMonths: Value(reminder.recurrenceIntervalMonths),
            isCompleted: Value(reminder.isCompleted),
            isSnoozed: Value(reminder.isSnoozed),
            snoozedUntil: Value(reminder.snoozedUntil),
            createdAt: reminder.createdAt,
            completedAt: Value(reminder.completedAt),
          ),
        );

    await _notificationService.scheduleReminderNotification(reminder);
  }

  Future<void> updateReminder(MaintenanceReminderModel reminder) async {
    await (_db.update(_db.maintenanceReminders)..where((t) => t.id.equals(reminder.id))).write(
          MaintenanceRemindersCompanion(
            title: Value(reminder.title),
            description: Value(reminder.description),
            category: Value(reminder.category.name),
            reminderType: Value(reminder.reminderType.name),
            dueDate: Value(reminder.dueDate),
            dueOdometer: Value(reminder.dueOdometer),
            notificationLeadDays: Value(reminder.notificationLeadDays),
            recurrenceIntervalKm: Value(reminder.recurrenceIntervalKm),
            recurrenceIntervalMonths: Value(reminder.recurrenceIntervalMonths),
            isCompleted: Value(reminder.isCompleted),
            isSnoozed: Value(reminder.isSnoozed),
            snoozedUntil: Value(reminder.snoozedUntil),
            completedAt: Value(reminder.completedAt),
          ),
        );

    await _notificationService.cancelReminderNotification(reminder.id);
    if (!reminder.isCompleted) {
      await _notificationService.scheduleReminderNotification(reminder);
    }
  }

  Future<void> completeReminder(
    String id, {
    bool createNextRecurrence = true,
    int? currentOdometer,
  }) async {
    final existing = await getReminderById(id);
    if (existing == null) return;

    final now = DateTime.now();

    await (_db.update(_db.maintenanceReminders)..where((t) => t.id.equals(id))).write(
          MaintenanceRemindersCompanion(
            isCompleted: const Value(true),
            isSnoozed: const Value(false),
            completedAt: Value(now),
          ),
        );

    await _notificationService.cancelReminderNotification(id);

    // Auto-create next recurring cycle if requested and recurrence intervals are set
    if (createNextRecurrence &&
        (existing.recurrenceIntervalKm != null || existing.recurrenceIntervalMonths != null)) {
      DateTime? nextDueDate;
      if (existing.recurrenceIntervalMonths != null && existing.recurrenceIntervalMonths! > 0) {
        final baseDate = existing.dueDate ?? now;
        nextDueDate = DateTime(
          baseDate.year,
          baseDate.month + existing.recurrenceIntervalMonths!,
          baseDate.day,
        );
      }

      int? nextDueOdo;
      if (existing.recurrenceIntervalKm != null && existing.recurrenceIntervalKm! > 0) {
        final baseOdo = currentOdometer ?? existing.dueOdometer ?? 0;
        nextDueOdo = baseOdo + existing.recurrenceIntervalKm!;
      }

      final nextReminder = MaintenanceReminderModel(
        id: const Uuid().v4(),
        vehicleId: existing.vehicleId,
        title: existing.title,
        description: existing.description,
        category: existing.category,
        reminderType: existing.reminderType,
        dueDate: nextDueDate,
        dueOdometer: nextDueOdo,
        notificationLeadDays: existing.notificationLeadDays,
        recurrenceIntervalKm: existing.recurrenceIntervalKm,
        recurrenceIntervalMonths: existing.recurrenceIntervalMonths,
        isCompleted: false,
        createdAt: now,
      );

      await createReminder(nextReminder);
    }
  }

  Future<void> snoozeReminder(String id, Duration duration) async {
    final snoozedUntil = DateTime.now().add(duration);
    await (_db.update(_db.maintenanceReminders)..where((t) => t.id.equals(id))).write(
          MaintenanceRemindersCompanion(
            isSnoozed: const Value(true),
            snoozedUntil: Value(snoozedUntil),
          ),
        );

    await _notificationService.cancelReminderNotification(id);
  }

  Future<void> deleteReminder(String id) async {
    await _notificationService.cancelReminderNotification(id);
    await (_db.delete(_db.maintenanceReminders)..where((t) => t.id.equals(id))).go();
  }

  Future<void> seedInitialRemindersIfEmpty(String vehicleId, int currentOdometer) async {
    final count = await (_db.select(_db.maintenanceReminders)..where((t) => t.vehicleId.equals(vehicleId))).get();
    if (count.isEmpty) {
      final now = DateTime.now();

      await createReminder(
        MaintenanceReminderModel(
          id: 'seed-rem-1',
          vehicleId: vehicleId,
          title: '10,000 km / 1st Year Annual EV Inspection',
          description: 'High-voltage battery diagnostics, suspension torque check, motor coolant inspection.',
          category: ReminderCategory.service,
          reminderType: ReminderType.both,
          dueDate: now.add(const Duration(days: 90)),
          dueOdometer: 10000,
          notificationLeadDays: 14,
          recurrenceIntervalKm: 10000,
          recurrenceIntervalMonths: 12,
          createdAt: now,
        ),
      );

      await createReminder(
        MaintenanceReminderModel(
          id: 'seed-rem-2',
          vehicleId: vehicleId,
          title: 'Tyre Rotation & Pressure Calibration',
          description: 'Front-to-rear cross rotation to ensure even tread wear across all 4 tyres.',
          category: ReminderCategory.tyre,
          reminderType: ReminderType.odometer,
          dueOdometer: 5000,
          notificationLeadDays: 7,
          recurrenceIntervalKm: 5000,
          createdAt: now,
        ),
      );

      await createReminder(
        MaintenanceReminderModel(
          id: 'seed-rem-3',
          vehicleId: vehicleId,
          title: 'EV Comprehensive Insurance Renewal',
          description: 'Zero depreciation insurance renewal before policy expiry date.',
          category: ReminderCategory.insurance,
          reminderType: ReminderType.date,
          dueDate: now.add(const Duration(days: 45)),
          notificationLeadDays: 15,
          recurrenceIntervalMonths: 12,
          createdAt: now,
        ),
      );
    }
  }
}

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final notifService = ref.watch(notificationServiceProvider);
  return ReminderRepository(db, notifService);
});

final activeVehicleRemindersProvider = StreamProvider<List<MaintenanceReminderModel>>((ref) {
  final activeVehicleId = ref.watch(activeVehicleIdProvider);
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchRemindersForVehicle(activeVehicleId);
});

final activeVehicleUpcomingRemindersProvider = StreamProvider<List<MaintenanceReminderModel>>((ref) {
  final activeVehicleId = ref.watch(activeVehicleIdProvider);
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.watchRemindersForVehicle(activeVehicleId, includeCompleted: false);
});
