import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

enum IssuePriority {
  critical,
  high,
  medium,
  low,
}

enum IssueFrequency {
  always,
  sometimes,
  rarely,
}

enum IssueStatus {
  open,
  inProgress,
  resolved,
}

enum ServiceVisitStatus {
  draft,
  inProgress,
  completed,
}

enum VisitIssueResolution {
  resolved,
  partiallyResolved,
  notResolved,
  unableToInspect,
}

class Issues extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().withDefault(const Constant('mg_comet_ev'))();
  TextColumn get componentId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get priority => intEnum<IssuePriority>()();
  DateTimeColumn get dateNoticed => dateTime()();
  IntColumn get frequency => intEnum<IssueFrequency>()();
  TextColumn get photoUrlsJson => text().nullable()();
  IntColumn get status => intEnum<IssueStatus>().withDefault(const Constant(0))();
  TextColumn get technicianRemarks => text().nullable()();
  TextColumn get resolutionNotes => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get parentIssueId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ServiceVisits extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text().withDefault(const Constant('mg_comet_ev'))();
  TextColumn get serviceCentre => text()();
  DateTimeColumn get visitDate => dateTime()();
  IntColumn get odometerReading => integer()();
  IntColumn get status => intEnum<ServiceVisitStatus>().withDefault(const Constant(1))(); // default inProgress
  TextColumn get additionalRequests => text().nullable()();
  TextColumn get technicianName => text().nullable()();
  TextColumn get signOffDetails => text().nullable()();
  RealColumn get totalCost => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ServiceVisitIssues extends Table {
  TextColumn get id => text()();
  TextColumn get serviceVisitId => text()();
  TextColumn get issueId => text()();
  TextColumn get technicianRemarks => text().nullable()();
  TextColumn get workPerformed => text().nullable()();
  TextColumn get partsReplaced => text().nullable()();
  IntColumn get resolutionStatus => intEnum<VisitIssueResolution>().withDefault(const Constant(2))(); // default notResolved
  BoolColumn get followUpRequired => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class IssueAttachments extends Table {
  TextColumn get id => text()();
  TextColumn get issueId => text()();
  TextColumn get localFilePath => text()();
  TextColumn get fileName => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Vehicles extends Table {
  TextColumn get id => text()();
  TextColumn get nickname => text()();
  TextColumn get manufacturer => text()();
  TextColumn get model => text()();
  TextColumn get variant => text()();
  TextColumn get registrationNumber => text().nullable()();
  IntColumn get modelYear => integer().nullable()();
  DateTimeColumn get purchaseDate => dateTime().nullable()();
  IntColumn get currentOdometer => integer().withDefault(const Constant(0))();
  TextColumn get vehicleType => text().withDefault(const Constant('Electric (EV)'))();
  TextColumn get imagePath => text().nullable()();
  TextColumn get model3dAssetPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class OdometerReadings extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  IntColumn get reading => integer()();
  DateTimeColumn get readingDate => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isCorrection => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class MaintenanceReminders extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();
  TextColumn get reminderType => text()(); // 'date', 'odometer', or 'both'
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get dueOdometer => integer().nullable()();
  IntColumn get notificationLeadDays => integer().withDefault(const Constant(7))();
  IntColumn get recurrenceIntervalKm => integer().nullable()();
  IntColumn get recurrenceIntervalMonths => integer().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get isSnoozed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get snoozedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class VehicleDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleId => text()();
  TextColumn get title => text()();
  TextColumn get category => text()();
  TextColumn get localFilePath => text()();
  TextColumn get fileName => text()();
  DateTimeColumn get issueDate => dateTime().nullable()();
  DateTimeColumn get expiryDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [
  Issues,
  ServiceVisits,
  ServiceVisitIssues,
  IssueAttachments,
  Vehicles,
  OdometerReadings,
  MaintenanceReminders,
  VehicleDocuments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(serviceVisits);
            await m.createTable(serviceVisitIssues);
            await m.createTable(issueAttachments);
          }
          if (from < 3) {
            await m.addColumn(issues, issues.isRecurring);
            await m.addColumn(issues, issues.parentIssueId);
          }
          if (from < 4) {
            await m.createTable(vehicles);
            await m.createTable(odometerReadings);
            await m.createTable(maintenanceReminders);
            await m.createTable(vehicleDocuments);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mygarage_database');
  }
}
