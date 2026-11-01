import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/service_visit_model.dart';

class ServiceRepository {
  final AppDatabase _db;

  ServiceRepository(this._db);

  ServiceVisitModel _visitToDomain(ServiceVisit row) {
    return ServiceVisitModel(
      id: row.id,
      vehicleId: row.vehicleId,
      serviceCentre: row.serviceCentre,
      visitDate: row.visitDate,
      odometerReading: row.odometerReading,
      status: row.status,
      additionalRequests: row.additionalRequests,
      technicianName: row.technicianName,
      signOffDetails: row.signOffDetails,
      totalCost: row.totalCost,
      createdAt: row.createdAt,
      completedAt: row.completedAt,
    );
  }

  Stream<List<ServiceVisitModel>> watchAllVisits({String? vehicleId}) {
    final query = _db.select(_db.serviceVisits)
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watch().map((rows) => rows.map(_visitToDomain).toList());
  }

  Stream<List<ServiceVisitModel>> watchCompletedVisits({String? vehicleId}) {
    final query = _db.select(_db.serviceVisits)
      ..where((t) => t.status.equalsValue(ServiceVisitStatus.completed))
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
      ]);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watch().map((rows) => rows.map(_visitToDomain).toList());
  }

  Stream<ServiceVisitModel?> watchActiveVisit({String? vehicleId}) {
    final query = _db.select(_db.serviceVisits)
      ..where((t) => t.status.equalsValue(ServiceVisitStatus.inProgress))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(1);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watchSingleOrNull().map((row) => row != null ? _visitToDomain(row) : null);
  }

  Future<String> createServiceVisit({
    required String serviceCentre,
    required DateTime visitDate,
    required int odometerReading,
    required List<String> selectedIssueIds,
    String? additionalRequests,
    String vehicleId = 'mg_comet_ev',
  }) async {
    final visitId = const Uuid().v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      // 1. Insert Visit Record
      await _db.into(_db.serviceVisits).insert(
            ServiceVisitsCompanion.insert(
              id: visitId,
              vehicleId: Value(vehicleId),
              serviceCentre: serviceCentre,
              visitDate: visitDate,
              odometerReading: odometerReading,
              status: const Value(ServiceVisitStatus.inProgress),
              additionalRequests: Value(additionalRequests),
              createdAt: now,
            ),
          );

      // 2. Link each selected issue
      for (final issueId in selectedIssueIds) {
        final visitIssueId = const Uuid().v4();
        await _db.into(_db.serviceVisitIssues).insert(
              ServiceVisitIssuesCompanion.insert(
                id: visitIssueId,
                serviceVisitId: visitId,
                issueId: issueId,
                resolutionStatus: const Value(VisitIssueResolution.notResolved),
                followUpRequired: const Value(false),
                createdAt: now,
              ),
            );

        // Update issue status to inProgress
        await (_db.update(_db.issues)..where((t) => t.id.equals(issueId))).write(
              IssuesCompanion(
                status: const Value(IssueStatus.inProgress),
                updatedAt: Value(now),
              ),
            );
      }
    });

    return visitId;
  }

  Stream<ServiceVisitDetailModel?> watchVisitDetail(String visitId) {
    final visitQuery = _db.select(_db.serviceVisits)..where((t) => t.id.equals(visitId));

    return visitQuery.watchSingleOrNull().asyncMap((visitRow) async {
      if (visitRow == null) return null;

      final visit = _visitToDomain(visitRow);

      // Get visit issues
      final visitIssuesRows = await (_db.select(_db.serviceVisitIssues)..where((t) => t.serviceVisitId.equals(visitId))).get();

      final List<ServiceVisitIssueModel> visitIssues = [];

      for (final vIssue in visitIssuesRows) {
        final issueRow = await (_db.select(_db.issues)..where((t) => t.id.equals(vIssue.issueId))).getSingleOrNull();

        // Get persistent attachments for this issue
        final attachments = await (_db.select(_db.issueAttachments)..where((t) => t.issueId.equals(vIssue.issueId))).get();
        final photoPaths = attachments.map((a) => a.localFilePath).toList();

        visitIssues.add(
          ServiceVisitIssueModel(
            id: vIssue.id,
            serviceVisitId: vIssue.serviceVisitId,
            issueId: vIssue.issueId,
            issueTitle: issueRow?.title ?? 'Unknown Issue',
            issueDescription: issueRow?.description ?? '',
            componentId: issueRow?.componentId ?? 'general',
            issuePriority: issueRow?.priority ?? IssuePriority.medium,
            photoUrls: photoPaths,
            technicianRemarks: vIssue.technicianRemarks,
            workPerformed: vIssue.workPerformed,
            partsReplaced: vIssue.partsReplaced,
            resolutionStatus: vIssue.resolutionStatus,
            followUpRequired: vIssue.followUpRequired,
            createdAt: vIssue.createdAt,
          ),
        );
      }

      return ServiceVisitDetailModel(
        visit: visit,
        issues: visitIssues,
      );
    });
  }

  Future<void> updateVisitIssueFeedback({
    required String visitIssueId,
    String? technicianRemarks,
    String? workPerformed,
    String? partsReplaced,
    required VisitIssueResolution resolutionStatus,
    required bool followUpRequired,
  }) async {
    await (_db.update(_db.serviceVisitIssues)..where((t) => t.id.equals(visitIssueId))).write(
          ServiceVisitIssuesCompanion(
            technicianRemarks: Value(technicianRemarks),
            workPerformed: Value(workPerformed),
            partsReplaced: Value(partsReplaced),
            resolutionStatus: Value(resolutionStatus),
            followUpRequired: Value(followUpRequired),
          ),
        );
  }

  Future<void> completeServiceVisit({
    required String visitId,
    required String technicianName,
    String? signOffDetails,
    double? totalCost,
  }) async {
    final now = DateTime.now();

    await _db.transaction(() async {
      // 1. Mark visit as completed
      await (_db.update(_db.serviceVisits)..where((t) => t.id.equals(visitId))).write(
            ServiceVisitsCompanion(
              status: const Value(ServiceVisitStatus.completed),
              technicianName: Value(technicianName),
              signOffDetails: Value(signOffDetails),
              totalCost: Value(totalCost),
              completedAt: Value(now),
            ),
          );

      // 2. Fetch all issues in this visit and update their master issue status accordingly
      final visitIssues = await (_db.select(_db.serviceVisitIssues)..where((t) => t.serviceVisitId.equals(visitId))).get();

      for (final vIssue in visitIssues) {
        IssueStatus masterStatus;
        switch (vIssue.resolutionStatus) {
          case VisitIssueResolution.resolved:
            masterStatus = IssueStatus.resolved;
            break;
          case VisitIssueResolution.partiallyResolved:
            masterStatus = IssueStatus.inProgress;
            break;
          case VisitIssueResolution.notResolved:
          case VisitIssueResolution.unableToInspect:
            masterStatus = IssueStatus.open;
            break;
        }

        await (_db.update(_db.issues)..where((t) => t.id.equals(vIssue.issueId))).write(
              IssuesCompanion(
                status: Value(masterStatus),
                technicianRemarks: Value(vIssue.technicianRemarks),
                resolutionNotes: Value(vIssue.workPerformed),
                updatedAt: Value(now),
              ),
            );
      }
    });
  }
  Stream<ServiceVisitModel?> watchLatestCompletedVisit({String? vehicleId}) {
    final query = _db.select(_db.serviceVisits)
      ..where((t) => t.status.equalsValue(ServiceVisitStatus.completed))
      ..orderBy([
        (t) => OrderingTerm(expression: t.completedAt, mode: OrderingMode.desc),
      ])
      ..limit(1);

    if (vehicleId != null) {
      query.where((t) => t.vehicleId.equals(vehicleId));
    }

    return query.watchSingleOrNull().map((row) => row != null ? _visitToDomain(row) : null);
  }
}

final serviceRepositoryProvider = Provider<ServiceRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ServiceRepository(db);
});

final allServiceVisitsProvider = StreamProvider<List<ServiceVisitModel>>((ref) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.watchAllVisits();
});

final completedServiceVisitsProvider = StreamProvider<List<ServiceVisitModel>>((ref) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.watchCompletedVisits();
});

final latestCompletedVisitProvider = StreamProvider<ServiceVisitModel?>((ref) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.watchLatestCompletedVisit();
});

final activeServiceVisitProvider = StreamProvider<ServiceVisitModel?>((ref) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.watchActiveVisit();
});

final serviceVisitDetailProvider = StreamProvider.family<ServiceVisitDetailModel?, String>((ref, visitId) {
  final repo = ref.watch(serviceRepositoryProvider);
  return repo.watchVisitDetail(visitId);
});
