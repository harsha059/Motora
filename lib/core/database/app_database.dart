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

@DriftDatabase(tables: [Issues, ServiceVisits, ServiceVisitIssues, IssueAttachments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 2;

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
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mygarage_database');
  }
}
