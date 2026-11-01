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

@DriftDatabase(tables: [Issues])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'mygarage_database');
  }
}
