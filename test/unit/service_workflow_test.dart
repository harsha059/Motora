import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygarage/core/database/app_database.dart';
import 'package:mygarage/features/issues/data/attachment_repository.dart';
import 'package:mygarage/features/issues/data/issue_repository.dart';
import 'package:mygarage/features/issues/domain/issue_model.dart';
import 'package:mygarage/features/service/data/service_repository.dart';
import 'package:mygarage/features/service/domain/pdf_report_generator.dart';
import 'package:mygarage/features/service/domain/service_visit_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late IssueRepository issueRepo;
  late ServiceRepository serviceRepo;
  late AttachmentRepository attachmentRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    issueRepo = IssueRepository(db);
    serviceRepo = ServiceRepository(db);
    attachmentRepo = AttachmentRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Sprint 2 Service Visit & Documentation Tests', () {
    // 1. Creating a service visit
    test('1. Creating a service visit initializes record with inProgress status', () async {
      final visitDate = DateTime(2026, 11, 15);
      final visitId = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Service Point Bangalore Central',
        visitDate: visitDate,
        odometerReading: 12450,
        selectedIssueIds: [],
        additionalRequests: 'Check tire pressure and wheel alignment',
      );

      final activeVisit = await serviceRepo.watchActiveVisit().first;
      expect(activeVisit, isNotNull);
      expect(activeVisit!.id, equals(visitId));
      expect(activeVisit.serviceCentre, equals('MG Service Point Bangalore Central'));
      expect(activeVisit.odometerReading, equals(12450));
      expect(activeVisit.status, equals(ServiceVisitStatus.inProgress));
      expect(activeVisit.additionalRequests, equals('Check tire pressure and wheel alignment'));
    });

    // 2. Linking multiple issues to a visit
    test('2. Linking multiple issues to a visit sets issue statuses to inProgress', () async {
      final now = DateTime.now();
      final issue1 = IssueModel(
        id: 'issue-101',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Slow AC charging speed',
        description: 'Takes 8+ hours on 3.3kW charger',
        priority: IssuePriority.high,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      );
      final issue2 = IssueModel(
        id: 'issue-102',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Front brake caliper squeal',
        description: 'Loud squeal when decelerating at slow speeds',
        priority: IssuePriority.critical,
        dateNoticed: now,
        frequency: IssueFrequency.sometimes,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      );

      await issueRepo.createIssue(issue1);
      await issueRepo.createIssue(issue2);

      final visitId = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Authorized Workshop Indiranagar',
        visitDate: now,
        odometerReading: 8500,
        selectedIssueIds: ['issue-101', 'issue-102'],
      );

      final detail = await serviceRepo.watchVisitDetail(visitId).first;
      expect(detail, isNotNull);
      expect(detail!.issues.length, equals(2));
      expect(detail.issues.map((i) => i.issueId), containsAll(['issue-101', 'issue-102']));

      // Verify master issues transitioned to inProgress
      final allIssues = await issueRepo.watchAllIssues().first;
      final i1 = allIssues.firstWhere((i) => i.id == 'issue-101');
      final i2 = allIssues.firstWhere((i) => i.id == 'issue-102');
      expect(i1.status, equals(IssueStatus.inProgress));
      expect(i2.status, equals(IssueStatus.inProgress));
    });

    // 3. Saving technician remarks
    test('3. Saving technician remarks and resolution progress updates visit issues', () async {
      final now = DateTime.now();
      await issueRepo.createIssue(IssueModel(
        id: 'issue-201',
        vehicleId: 'mg_comet_ev',
        componentId: 'infotainment_screen',
        title: 'Touchscreen freeze',
        description: 'Display freezes when CarPlay is connected',
        priority: IssuePriority.medium,
        dateNoticed: now,
        frequency: IssueFrequency.sometimes,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));

      final visitId = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Service Tech Center',
        visitDate: now,
        odometerReading: 5400,
        selectedIssueIds: ['issue-201'],
      );

      final detailInitial = await serviceRepo.watchVisitDetail(visitId).first;
      final visitIssue = detailInitial!.issues.first;

      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: visitIssue.id,
        technicianRemarks: 'Inspected MCU software version; flashed latest firmware patch v2.4.',
        workPerformed: 'Reflashed head unit firmware and cleared error logs',
        partsReplaced: 'None (software only)',
        resolutionStatus: VisitIssueResolution.resolved,
        followUpRequired: false,
      );

      final detailUpdated = await serviceRepo.watchVisitDetail(visitId).first;
      final updatedIssue = detailUpdated!.issues.first;
      expect(updatedIssue.technicianRemarks, contains('flashed latest firmware patch'));
      expect(updatedIssue.workPerformed, contains('Reflashed head unit'));
      expect(updatedIssue.partsReplaced, equals('None (software only)'));
      expect(updatedIssue.resolutionStatus, equals(VisitIssueResolution.resolved));
      expect(updatedIssue.followUpRequired, isFalse);
    });

    // 4. Updating issue resolution status on visit completion
    test('4. Completing service visit maps resolution statuses to master issues correctly', () async {
      final now = DateTime.now();
      // Setup 3 issues
      await issueRepo.createIssue(IssueModel(
        id: 'res-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Brake pads worn',
        description: 'Rear pads thinning',
        priority: IssuePriority.high,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));
      await issueRepo.createIssue(IssueModel(
        id: 'res-2',
        vehicleId: 'mg_comet_ev',
        componentId: 'steering',
        title: 'Steering alignment pull',
        description: 'Slight drift to left on highway',
        priority: IssuePriority.medium,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));
      await issueRepo.createIssue(IssueModel(
        id: 'res-3',
        vehicleId: 'mg_comet_ev',
        componentId: 'suspension',
        title: 'Suspension thud noise',
        description: 'Knocking over speed breakers',
        priority: IssuePriority.critical,
        dateNoticed: now,
        frequency: IssueFrequency.sometimes,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));

      final visitId = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Service South',
        visitDate: now,
        odometerReading: 9200,
        selectedIssueIds: ['res-1', 'res-2', 'res-3'],
      );

      final detail = await serviceRepo.watchVisitDetail(visitId).first;
      final vi1 = detail!.issues.firstWhere((i) => i.issueId == 'res-1');
      final vi2 = detail.issues.firstWhere((i) => i.issueId == 'res-2');
      final vi3 = detail.issues.firstWhere((i) => i.issueId == 'res-3');

      // res-1: Resolved
      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: vi1.id,
        technicianRemarks: 'Replaced rear brake pads',
        resolutionStatus: VisitIssueResolution.resolved,
        followUpRequired: false,
      );
      // res-2: Partially resolved (test drive required)
      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: vi2.id,
        technicianRemarks: 'Toe adjusted, slight drift remains',
        resolutionStatus: VisitIssueResolution.partiallyResolved,
        followUpRequired: true,
      );
      // res-3: Not resolved (parts on backorder)
      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: vi3.id,
        technicianRemarks: 'Bushing damaged; replacement part awaiting dispatch',
        resolutionStatus: VisitIssueResolution.notResolved,
        followUpRequired: true,
      );

      // Complete visit
      await serviceRepo.completeServiceVisit(
        visitId: visitId,
        technicianName: 'Rajesh Kumar (Senior Technician)',
        signOffDetails: 'Job card #MG-55829',
        totalCost: 4500.0,
      );

      // Check visit status
      final activeVisit = await serviceRepo.watchActiveVisit().first;
      expect(activeVisit, isNull);

      final completedVisits = await serviceRepo.watchCompletedVisits().first;
      expect(completedVisits.length, equals(1));
      expect(completedVisits.first.technicianName, equals('Rajesh Kumar (Senior Technician)'));

      // Check master issues
      final issues = await issueRepo.watchAllIssues().first;
      final updated1 = issues.firstWhere((i) => i.id == 'res-1');
      final updated2 = issues.firstWhere((i) => i.id == 'res-2');
      final updated3 = issues.firstWhere((i) => i.id == 'res-3');

      expect(updated1.status, equals(IssueStatus.resolved));
      expect(updated2.status, equals(IssueStatus.inProgress));
      expect(updated3.status, equals(IssueStatus.open));
    });

    // 5. Carrying unresolved issues into future service visits
    test('5. Carrying unresolved and partially resolved issues into subsequent service visits', () async {
      final now = DateTime.now();
      await issueRepo.createIssue(IssueModel(
        id: 'carry-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Cell balancing anomaly',
        description: 'Imbalance detected in pack #2',
        priority: IssuePriority.critical,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));

      // Visit 1: Not resolved
      final visit1 = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Workshop 1',
        visitDate: now,
        odometerReading: 4000,
        selectedIssueIds: ['carry-1'],
      );
      final d1 = await serviceRepo.watchVisitDetail(visit1).first;
      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: d1!.issues.first.id,
        technicianRemarks: 'Special diagnostic tool needed from HQ',
        resolutionStatus: VisitIssueResolution.notResolved,
        followUpRequired: true,
      );
      await serviceRepo.completeServiceVisit(
        visitId: visit1,
        technicianName: 'Tech Alpha',
      );

      // Issue carry-1 should still be unresolved and open
      final openIssuesAfterV1 = await issueRepo.watchOpenIssues().first;
      expect(openIssuesAfterV1.any((i) => i.id == 'carry-1'), isTrue);

      // Visit 2: Select carry-1 again
      final visit2 = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Workshop 2',
        visitDate: now.add(const Duration(days: 7)),
        odometerReading: 4250,
        selectedIssueIds: ['carry-1'],
      );
      final d2 = await serviceRepo.watchVisitDetail(visit2).first;
      expect(d2!.issues.length, equals(1));
      expect(d2.issues.first.issueId, equals('carry-1'));

      // Visit 2 resolves it
      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: d2.issues.first.id,
        technicianRemarks: 'BMS firmware calibration completed successfully',
        resolutionStatus: VisitIssueResolution.resolved,
        followUpRequired: false,
      );
      await serviceRepo.completeServiceVisit(
        visitId: visit2,
        technicianName: 'Tech Beta',
      );

      // Now issue carry-1 is resolved and no longer in open issues
      final openIssuesAfterV2 = await issueRepo.watchOpenIssues().first;
      expect(openIssuesAfterV2.any((i) => i.id == 'carry-1'), isFalse);
    });

    // 6. Persisting photo attachment paths
    test('6. Persisting photo attachment records and query by issue', () async {
      final now = DateTime.now();
      const issueId = 'photo-test-issue';

      // Insert attachment directly via drift database
      final attId = 'att-uuid-1';
      final testPath = '${Directory.systemTemp.path}/test_photo.jpg';

      await db.into(db.issueAttachments).insert(
            IssueAttachmentsCompanion.insert(
              id: attId,
              issueId: issueId,
              localFilePath: testPath,
              fileName: 'test_photo.jpg',
              createdAt: now,
            ),
          );

      final attachments = await attachmentRepo.getAttachmentsForIssue(issueId);
      expect(attachments.length, equals(1));
      expect(attachments.first.id, equals(attId));
      expect(attachments.first.localFilePath, equals(testPath));
      expect(attachments.first.fileName, equals('test_photo.jpg'));

      // Delete attachment
      await attachmentRepo.deleteAttachment(attId);
      final attachmentsAfterDelete = await attachmentRepo.getAttachmentsForIssue(issueId);
      expect(attachmentsAfterDelete, isEmpty);
    });

    // 7. Generating a PDF with multiple issues
    test('7. Generating multi-page PDF service report completes with valid bytes', () async {
      final visitDate = DateTime(2026, 11, 10);
      final visit = ServiceVisitModel(
        id: 'pdf-visit-01',
        vehicleId: 'mg_comet_ev',
        serviceCentre: 'MG Service Flagship Bengaluru',
        visitDate: visitDate,
        odometerReading: 15300,
        status: ServiceVisitStatus.completed,
        additionalRequests: '1. Check tire pressures\n2. Clean AC cabin filter',
        technicianName: 'Vikram Seth (Master Tech)',
        signOffDetails: 'Job Card #BLR-2026-9942',
        totalCost: 6200.0,
        createdAt: visitDate,
        completedAt: visitDate.add(const Duration(hours: 4)),
      );

      final issues = [
        ServiceVisitIssueModel(
          id: 'v-iss-1',
          serviceVisitId: 'pdf-visit-01',
          issueId: 'iss-1',
          issueTitle: 'Brake squeaking on regenerative slowdown',
          issueDescription: 'High-pitched frequency heard whenever regeneration engages above 40 km/h.',
          componentId: 'brakes',
          issuePriority: IssuePriority.critical,
          photoUrls: [],
          technicianRemarks: 'Cleaned front disc caliper clips and resurfaced pads with anti-squeal compound.',
          workPerformed: 'Brake pad surface cleaning & lube application',
          partsReplaced: 'Brake caliper clips (part #MG-BRK-401)',
          resolutionStatus: VisitIssueResolution.resolved,
          followUpRequired: false,
          createdAt: visitDate,
        ),
        ServiceVisitIssueModel(
          id: 'v-iss-2',
          serviceVisitId: 'pdf-visit-01',
          issueId: 'iss-2',
          issueTitle: 'HVAC blower fan vibration',
          issueDescription: 'Dashboard vibrates noticeably when AC fan speed is set to level 3 or 4.',
          componentId: 'climate_control',
          issuePriority: IssuePriority.high,
          photoUrls: [],
          technicianRemarks: 'Blower fan motor bearing shows minor play. Ordered replacement motor under warranty.',
          workPerformed: 'Cleaned leaf debris from blower box; inspected motor housing',
          partsReplaced: 'None (replacement on order)',
          resolutionStatus: VisitIssueResolution.partiallyResolved,
          followUpRequired: true,
          createdAt: visitDate,
        ),
      ];

      final detail = ServiceVisitDetailModel(
        visit: visit,
        issues: issues,
      );

      final pdfDoc = await PdfReportGenerator.generateReport(detail: detail);
      expect(pdfDoc, isNotNull);

      final bytes = await pdfDoc.save();
      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(1000));
      // PDF header magic bytes "%PDF-"
      final magic = String.fromCharCodes(bytes.sublist(0, 5));
      expect(magic, equals('%PDF-'));
    });

    // 8. Preserving existing issue history
    test('8. Preserving original issue creation date, noticed date, and metadata across visits', () async {
      final originalCreated = DateTime(2026, 10, 1, 9, 30);
      final dateNoticed = DateTime(2026, 9, 28, 14, 0);

      final originalIssue = IssueModel(
        id: 'hist-issue-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Thermal cutoff during peak sun charging',
        description: 'Charge cuts off when ambient temperature exceeds 38 deg C',
        priority: IssuePriority.critical,
        dateNoticed: dateNoticed,
        frequency: IssueFrequency.sometimes,
        status: IssueStatus.open,
        createdAt: originalCreated,
        updatedAt: originalCreated,
      );

      await issueRepo.createIssue(originalIssue);

      // Create service visit on later date
      final visitDate = DateTime(2026, 11, 2);
      final visitId = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Workshop North',
        visitDate: visitDate,
        odometerReading: 11000,
        selectedIssueIds: ['hist-issue-1'],
      );

      final detail = await serviceRepo.watchVisitDetail(visitId).first;
      await serviceRepo.updateVisitIssueFeedback(
        visitIssueId: detail!.issues.first.id,
        technicianRemarks: 'Replaced radiator coolant pump sensor',
        workPerformed: 'Coolant circuit flushed and sensor renewed',
        resolutionStatus: VisitIssueResolution.resolved,
        followUpRequired: false,
      );

      await serviceRepo.completeServiceVisit(
        visitId: visitId,
        technicianName: 'Suresh Raina',
      );

      // Fetch master issue and assert original metadata is intact
      final allIssues = await issueRepo.watchAllIssues().first;
      final savedIssue = allIssues.firstWhere((i) => i.id == 'hist-issue-1');

      expect(savedIssue.createdAt, equals(originalCreated));
      expect(savedIssue.dateNoticed, equals(dateNoticed));
      expect(savedIssue.vehicleId, equals('mg_comet_ev'));
      expect(savedIssue.componentId, equals('battery_pack'));
      expect(savedIssue.status, equals(IssueStatus.resolved));
      expect(savedIssue.technicianRemarks, equals('Replaced radiator coolant pump sensor'));
    });
  });
}
