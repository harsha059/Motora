enum ReminderCategory {
  service('Service & Inspection'),
  tyre('Tyres & Alignment'),
  insurance('Insurance Renewal'),
  puc('PUC Certificate'),
  warranty('Warranty Inspection'),
  battery('EV Battery Check'),
  custom('Custom Task');

  final String label;
  const ReminderCategory(this.label);

  static ReminderCategory fromString(String val) {
    return ReminderCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => ReminderCategory.custom,
    );
  }
}

enum ReminderType {
  date('Date Based'),
  odometer('Mileage Based'),
  both('Date & Mileage');

  final String label;
  const ReminderType(this.label);

  static ReminderType fromString(String val) {
    return ReminderType.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => ReminderType.date,
    );
  }
}

class MaintenanceReminderModel {
  final String id;
  final String vehicleId;
  final String title;
  final String? description;
  final ReminderCategory category;
  final ReminderType reminderType;
  final DateTime? dueDate;
  final int? dueOdometer;
  final int notificationLeadDays;
  final int? recurrenceIntervalKm;
  final int? recurrenceIntervalMonths;
  final bool isCompleted;
  final bool isSnoozed;
  final DateTime? snoozedUntil;
  final DateTime createdAt;
  final DateTime? completedAt;

  const MaintenanceReminderModel({
    required this.id,
    required this.vehicleId,
    required this.title,
    this.description,
    required this.category,
    required this.reminderType,
    this.dueDate,
    this.dueOdometer,
    this.notificationLeadDays = 7,
    this.recurrenceIntervalKm,
    this.recurrenceIntervalMonths,
    this.isCompleted = false,
    this.isSnoozed = false,
    this.snoozedUntil,
    required this.createdAt,
    this.completedAt,
  });

  bool isOverdue(int currentOdometer, {DateTime? now}) {
    if (isCompleted) return false;
    final current = now ?? DateTime.now();

    // If snoozed and snooze date is still in future, not overdue yet
    if (isSnoozed && snoozedUntil != null && snoozedUntil!.isAfter(current)) {
      return false;
    }

    bool dateOverdue = false;
    if ((reminderType == ReminderType.date || reminderType == ReminderType.both) && dueDate != null) {
      dateOverdue = current.isAfter(dueDate!);
    }

    bool odoOverdue = false;
    if ((reminderType == ReminderType.odometer || reminderType == ReminderType.both) && dueOdometer != null) {
      odoOverdue = currentOdometer >= dueOdometer!;
    }

    return dateOverdue || odoOverdue;
  }

  bool isDueSoon(int currentOdometer, {DateTime? now, int kmThreshold = 500, int dayThreshold = 7}) {
    if (isCompleted || isOverdue(currentOdometer, now: now)) return false;
    final current = now ?? DateTime.now();

    bool dateDueSoon = false;
    if ((reminderType == ReminderType.date || reminderType == ReminderType.both) && dueDate != null) {
      final daysLeft = dueDate!.difference(current).inDays;
      dateDueSoon = daysLeft >= 0 && daysLeft <= (notificationLeadDays > 0 ? notificationLeadDays : dayThreshold);
    }

    bool odoDueSoon = false;
    if ((reminderType == ReminderType.odometer || reminderType == ReminderType.both) && dueOdometer != null) {
      final kmLeft = dueOdometer! - currentOdometer;
      odoDueSoon = kmLeft >= 0 && kmLeft <= kmThreshold;
    }

    return dateDueSoon || odoDueSoon;
  }

  int? remainingKm(int currentOdometer) {
    if (dueOdometer == null) return null;
    return dueOdometer! - currentOdometer;
  }

  int? remainingDays({DateTime? now}) {
    if (dueDate == null) return null;
    final current = now ?? DateTime.now();
    return dueDate!.difference(current).inDays;
  }

  MaintenanceReminderModel copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? description,
    ReminderCategory? category,
    ReminderType? reminderType,
    DateTime? dueDate,
    int? dueOdometer,
    int? notificationLeadDays,
    int? recurrenceIntervalKm,
    int? recurrenceIntervalMonths,
    bool? isCompleted,
    bool? isSnoozed,
    DateTime? snoozedUntil,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return MaintenanceReminderModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      reminderType: reminderType ?? this.reminderType,
      dueDate: dueDate ?? this.dueDate,
      dueOdometer: dueOdometer ?? this.dueOdometer,
      notificationLeadDays: notificationLeadDays ?? this.notificationLeadDays,
      recurrenceIntervalKm: recurrenceIntervalKm ?? this.recurrenceIntervalKm,
      recurrenceIntervalMonths: recurrenceIntervalMonths ?? this.recurrenceIntervalMonths,
      isCompleted: isCompleted ?? this.isCompleted,
      isSnoozed: isSnoozed ?? this.isSnoozed,
      snoozedUntil: snoozedUntil ?? this.snoozedUntil,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'title': title,
        'description': description,
        'category': category.name,
        'reminderType': reminderType.name,
        'dueDate': dueDate?.toIso8601String(),
        'dueOdometer': dueOdometer,
        'notificationLeadDays': notificationLeadDays,
        'recurrenceIntervalKm': recurrenceIntervalKm,
        'recurrenceIntervalMonths': recurrenceIntervalMonths,
        'isCompleted': isCompleted,
        'isSnoozed': isSnoozed,
        'snoozedUntil': snoozedUntil?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory MaintenanceReminderModel.fromJson(Map<String, dynamic> json) => MaintenanceReminderModel(
        id: json['id'] as String,
        vehicleId: json['vehicleId'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        category: ReminderCategory.fromString(json['category'] as String),
        reminderType: ReminderType.fromString(json['reminderType'] as String),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
        dueOdometer: json['dueOdometer'] as int?,
        notificationLeadDays: (json['notificationLeadDays'] as int?) ?? 7,
        recurrenceIntervalKm: json['recurrenceIntervalKm'] as int?,
        recurrenceIntervalMonths: json['recurrenceIntervalMonths'] as int?,
        isCompleted: (json['isCompleted'] as bool?) ?? false,
        isSnoozed: (json['isSnoozed'] as bool?) ?? false,
        snoozedUntil: json['snoozedUntil'] != null ? DateTime.parse(json['snoozedUntil'] as String) : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      );
}
