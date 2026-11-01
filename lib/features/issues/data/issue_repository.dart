import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../vehicle/data/vehicle_repository.dart';
import '../domain/issue_model.dart';

class IssueRepository {
  final AppDatabase _db;

  IssueRepository(this._db);

  IssueModel _toDomain(Issue row) {
    List<String> photos = [];
    if (row.photoUrlsJson != null && row.photoUrlsJson!.isNotEmpty) {
      try {
        final decoded = jsonDecode(row.photoUrlsJson!);
        if (decoded is List) {
          photos = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    return IssueModel(
      id: row.id,
      vehicleId: row.vehicleId,
      componentId: row.componentId,
      title: row.title,
      description: row.description,
      priority: row.priority,
      dateNoticed: row.dateNoticed,
      frequency: row.frequency,
      photoUrls: photos,
      status: row.status,
      technicianRemarks: row.technicianRemarks,
      resolutionNotes: row.resolutionNotes,
      isRecurring: row.isRecurring,
      parentIssueId: row.parentIssueId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Stream<List<IssueModel>> watchAllIssues({String? vehicleId}) {
    final query = _db.select(_db.issues)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<List<IssueModel>> watchRecentIssues({int limit = 5, String? vehicleId}) {
    final query = _db.select(_db.issues)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Stream<List<IssueModel>> watchOpenIssues({String? vehicleId}) {
    final query = _db.select(_db.issues)
      ..where((t) => t.status.equalsValue(IssueStatus.open) | t.status.equalsValue(IssueStatus.inProgress))
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.asc),
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<void> createIssue(IssueModel issue) async {
    await _db.into(_db.issues).insert(
          IssuesCompanion.insert(
            id: issue.id,
            vehicleId: Value(issue.vehicleId),
            componentId: issue.componentId,
            title: issue.title,
            description: issue.description,
            priority: issue.priority,
            dateNoticed: issue.dateNoticed,
            frequency: issue.frequency,
            photoUrlsJson: Value(issue.photoUrls.isNotEmpty ? jsonEncode(issue.photoUrls) : null),
            status: Value(issue.status),
            technicianRemarks: Value(issue.technicianRemarks),
            resolutionNotes: Value(issue.resolutionNotes),
            isRecurring: Value(issue.isRecurring),
            parentIssueId: Value(issue.parentIssueId),
            createdAt: issue.createdAt,
            updatedAt: issue.updatedAt,
          ),
        );
  }

  Future<void> updateIssue(IssueModel issue) async {
    await (_db.update(_db.issues)..where((t) => t.id.equals(issue.id))).write(
          IssuesCompanion(
            title: Value(issue.title),
            description: Value(issue.description),
            componentId: Value(issue.componentId),
            priority: Value(issue.priority),
            dateNoticed: Value(issue.dateNoticed),
            frequency: Value(issue.frequency),
            status: Value(issue.status),
            technicianRemarks: Value(issue.technicianRemarks),
            resolutionNotes: Value(issue.resolutionNotes),
            photoUrlsJson: Value(issue.photoUrls.isNotEmpty ? jsonEncode(issue.photoUrls) : null),
            isRecurring: Value(issue.isRecurring),
            parentIssueId: Value(issue.parentIssueId),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> updateIssueStatus(String id, IssueStatus status) async {
    await (_db.update(_db.issues)..where((t) => t.id.equals(id))).write(
          IssuesCompanion(
            status: Value(status),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> markIssueAsRecurring(String id, {String? parentIssueId}) async {
    await (_db.update(_db.issues)..where((t) => t.id.equals(id))).write(
          IssuesCompanion(
            isRecurring: const Value(true),
            parentIssueId: Value(parentIssueId),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  Future<void> reopenIssue(String id, {String? reopenReason}) async {
    final existing = await (_db.select(_db.issues)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existing == null) return;

    final now = DateTime.now();
    String updatedRemarks = existing.technicianRemarks ?? '';
    if (reopenReason != null && reopenReason.trim().isNotEmpty) {
      final dateTag = '[Reopened on ${now.day}/${now.month}/${now.year}]';
      updatedRemarks = updatedRemarks.isEmpty
          ? '$dateTag $reopenReason'
          : '$updatedRemarks\n$dateTag $reopenReason';
    }

    await (_db.update(_db.issues)..where((t) => t.id.equals(id))).write(
          IssuesCompanion(
            status: const Value(IssueStatus.open),
            isRecurring: const Value(true),
            technicianRemarks: Value(updatedRemarks.isNotEmpty ? updatedRemarks : existing.technicianRemarks),
            updatedAt: Value(now),
          ),
        );
  }

  Future<List<IssueServiceHistoryRecord>> getHistoricalServiceVisitsForIssue(String issueId) async {
    final visitIssues = await (_db.select(_db.serviceVisitIssues)..where((t) => t.issueId.equals(issueId))).get();
    final List<IssueServiceHistoryRecord> records = [];

    for (final vi in visitIssues) {
      final visit = await (_db.select(_db.serviceVisits)..where((t) => t.id.equals(vi.serviceVisitId))).getSingleOrNull();
      if (visit != null) {
        records.add(IssueServiceHistoryRecord(
          visitId: visit.id,
          serviceCentre: visit.serviceCentre,
          visitDate: visit.visitDate,
          odometerReading: visit.odometerReading,
          technicianName: visit.technicianName,
          technicianRemarks: vi.technicianRemarks,
          workPerformed: vi.workPerformed,
          partsReplaced: vi.partsReplaced,
          resolutionStatus: vi.resolutionStatus,
          followUpRequired: vi.followUpRequired,
          isCompleted: visit.status == ServiceVisitStatus.completed,
        ));
      }
    }

    records.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return records;
  }

  Future<void> deleteIssue(String id) async {
    await (_db.delete(_db.issues)..where((t) => t.id.equals(id))).go();
  }

  Future<void> seedInitialDataIfEmpty() async {
    final count = await _db.issues.count().getSingle();
    if (count == 0) {
      final now = DateTime.now();
      await createIssue(
        IssueModel(
          id: 'seed-issue-1',
          vehicleId: 'mg_comet_ev',
          componentId: 'infotainment_displays',
          title: 'Infotainment display flickers during high regen braking',
          description: 'The driver cluster dual 10.25" screen occasionally shows a brief flash/flicker when regenerative braking initiates heavily in Level 3.',
          priority: IssuePriority.high,
          dateNoticed: now.subtract(const Duration(days: 4)),
          frequency: IssueFrequency.sometimes,
          status: IssueStatus.open,
          createdAt: now.subtract(const Duration(days: 4)),
          updatedAt: now.subtract(const Duration(days: 4)),
        ),
      );

      await createIssue(
        IssueModel(
          id: 'seed-issue-2',
          vehicleId: 'mg_comet_ev',
          componentId: 'rear_suspension',
          title: 'Slight squeak from rear suspension over speed bumps',
          description: 'Noticed a faint metallic rubber squeak coming from the rear axle when navigating tall residential speed humps at low speeds.',
          priority: IssuePriority.medium,
          dateNoticed: now.subtract(const Duration(days: 8)),
          frequency: IssueFrequency.always,
          status: IssueStatus.open,
          createdAt: now.subtract(const Duration(days: 8)),
          updatedAt: now.subtract(const Duration(days: 8)),
        ),
      );

      await createIssue(
        IssueModel(
          id: 'seed-issue-3',
          vehicleId: 'mg_comet_ev',
          componentId: 'charging_port',
          title: 'Emblem charging flap requires firm press to release',
          description: 'Front MG emblem charging port latch sometimes does not pop open on first push when car is unlocked.',
          priority: IssuePriority.low,
          dateNoticed: now.subtract(const Duration(days: 12)),
          frequency: IssueFrequency.rarely,
          status: IssueStatus.open,
          createdAt: now.subtract(const Duration(days: 12)),
          updatedAt: now.subtract(const Duration(days: 12)),
        ),
      );
    }
  }
}

final issueRepositoryProvider = Provider<IssueRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return IssueRepository(db);
});

final allIssuesProvider = StreamProvider<List<IssueModel>>((ref) {
  final repo = ref.watch(issueRepositoryProvider);
  final activeVehicleId = ref.watch(activeVehicleIdProvider);
  return repo.watchAllIssues(vehicleId: activeVehicleId);
});

final recentIssuesProvider = StreamProvider<List<IssueModel>>((ref) {
  final repo = ref.watch(issueRepositoryProvider);
  final activeVehicleId = ref.watch(activeVehicleIdProvider);
  return repo.watchRecentIssues(limit: 5, vehicleId: activeVehicleId);
});

final openIssuesProvider = StreamProvider<List<IssueModel>>((ref) {
  final repo = ref.watch(issueRepositoryProvider);
  final activeVehicleId = ref.watch(activeVehicleIdProvider);
  return repo.watchOpenIssues(vehicleId: activeVehicleId);
});

final issueServiceHistoryProvider = FutureProvider.family<List<IssueServiceHistoryRecord>, String>((ref, issueId) {
  final repo = ref.watch(issueRepositoryProvider);
  return repo.getHistoricalServiceVisitsForIssue(issueId);
});
