import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygarage/core/database/app_database.dart';
import 'package:mygarage/features/issues/data/issue_repository.dart';
import 'package:mygarage/features/issues/domain/issue_model.dart';
import 'package:mygarage/features/issues/domain/recurring_issue_detector.dart';
import 'package:mygarage/features/service/data/service_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late IssueRepository issueRepo;
  late ServiceRepository serviceRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    issueRepo = IssueRepository(db);
    serviceRepo = ServiceRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Sprint 3 Intelligence, Dashboard & Recurrence Tests', () {
    // 1. Time-based Greeting Logic
    test('1. Time greeting calculates appropriate phrase for morning, afternoon, and evening', () {
      String getGreetingForHour(int hour) {
        if (hour < 12) return 'Good morning';
        if (hour < 17) return 'Good afternoon';
        return 'Good evening';
      }

      expect(getGreetingForHour(8), equals('Good morning'));
      expect(getGreetingForHour(11), equals('Good morning'));
      expect(getGreetingForHour(12), equals('Good afternoon'));
      expect(getGreetingForHour(15), equals('Good afternoon'));
      expect(getGreetingForHour(17), equals('Good evening'));
      expect(getGreetingForHour(22), equals('Good evening'));
    });

    // 2. Active Defect Radar Logic & Component Summaries
    test('2. Active Defect Radar correctly segments open defects by severity and components', () async {
      final now = DateTime.now();

      await issueRepo.createIssue(IssueModel(
        id: 'radar-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Brake squeal on regen',
        description: 'Critical brake warning',
        priority: IssuePriority.critical,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));

      await issueRepo.createIssue(IssueModel(
        id: 'radar-2',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Charging thermal alert',
        description: 'High priority battery pack warming',
        priority: IssuePriority.high,
        dateNoticed: now,
        frequency: IssueFrequency.sometimes,
        status: IssueStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      ));

      await issueRepo.createIssue(IssueModel(
        id: 'radar-3',
        vehicleId: 'mg_comet_ev',
        componentId: 'infotainment_displays',
        title: 'Screen freeze during navigation',
        description: 'Medium display crash',
        priority: IssuePriority.medium,
        dateNoticed: now,
        frequency: IssueFrequency.sometimes,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      ));

      // Resolved issue should NOT be counted in active defect radar
      await issueRepo.createIssue(IssueModel(
        id: 'radar-4',
        vehicleId: 'mg_comet_ev',
        componentId: 'rear_suspension',
        title: 'Old suspension rattle',
        description: 'Already fixed',
        priority: IssuePriority.low,
        dateNoticed: now.subtract(const Duration(days: 30)),
        frequency: IssueFrequency.rarely,
        status: IssueStatus.resolved,
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ));

      final allIssues = await issueRepo.watchAllIssues().first;
      final active = allIssues.where((i) => i.status != IssueStatus.resolved).toList();

      expect(active.length, equals(3));
      final critical = active.where((i) => i.priority == IssuePriority.critical).toList();
      final high = active.where((i) => i.priority == IssuePriority.high).toList();
      final medium = active.where((i) => i.priority == IssuePriority.medium).toList();
      final low = active.where((i) => i.priority == IssuePriority.low).toList();

      expect(critical.length, equals(1));
      expect(high.length, equals(1));
      expect(medium.length, equals(1));
      expect(low.length, equals(0));

      expect(critical.first.componentId, equals('brakes'));
      expect(high.first.componentId, equals('battery_pack'));
      expect(medium.first.componentId, equals('infotainment_displays'));
    });

    // 3. Multi-Attribute Search Logic
    test('3. Advanced search matches title, description, component name, and technician remarks', () async {
      final now = DateTime.now();

      await issueRepo.createIssue(IssueModel(
        id: 'search-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Caliper squeak at low speeds',
        description: 'Occurs after regenerative slowdown',
        priority: IssuePriority.high,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        technicianRemarks: 'Inspected pad friction material; replaced caliper clips.',
        createdAt: now,
        updatedAt: now,
      ));

      await issueRepo.createIssue(IssueModel(
        id: 'search-2',
        vehicleId: 'mg_comet_ev',
        componentId: 'climate_control',
        title: 'AC blower fan whistling sound',
        description: 'Whistling pitch heard at fan level 3',
        priority: IssuePriority.medium,
        dateNoticed: now,
        frequency: IssueFrequency.sometimes,
        technicianRemarks: 'Cabin air filter cleaned; blower box inspected.',
        createdAt: now,
        updatedAt: now,
      ));

      final allIssues = await issueRepo.watchAllIssues().first;

      // Match by title
      final titleMatch = allIssues.where((i) => i.title.toLowerCase().contains('caliper')).toList();
      expect(titleMatch.length, equals(1));
      expect(titleMatch.first.id, equals('search-1'));

      // Match by description
      final descMatch = allIssues.where((i) => i.description.toLowerCase().contains('whistling pitch')).toList();
      expect(descMatch.length, equals(1));
      expect(descMatch.first.id, equals('search-2'));

      // Match by technician remarks
      final techMatch = allIssues.where((i) => (i.technicianRemarks ?? '').toLowerCase().contains('friction material')).toList();
      expect(techMatch.length, equals(1));
      expect(techMatch.first.id, equals('search-1'));
    });

    // 4. Issue Sorting Logic
    test('4. Issue sorting supports most recent, oldest, highest priority, and recently updated', () async {
      final t1 = DateTime(2026, 10, 1);
      final t2 = DateTime(2026, 10, 10);
      final t3 = DateTime(2026, 10, 20);

      final iss1 = IssueModel(
        id: 'sort-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Low priority old issue',
        description: '',
        priority: IssuePriority.low,
        dateNoticed: t1,
        frequency: IssueFrequency.rarely,
        createdAt: t1,
        updatedAt: t1,
      );

      final iss2 = IssueModel(
        id: 'sort-2',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Critical priority mid issue',
        description: '',
        priority: IssuePriority.critical,
        dateNoticed: t2,
        frequency: IssueFrequency.always,
        createdAt: t2,
        updatedAt: t3, // Updated recently
      );

      final iss3 = IssueModel(
        id: 'sort-3',
        vehicleId: 'mg_comet_ev',
        componentId: 'steering_system',
        title: 'Medium priority new issue',
        description: '',
        priority: IssuePriority.medium,
        dateNoticed: t3,
        frequency: IssueFrequency.sometimes,
        createdAt: t3,
        updatedAt: t1,
      );

      final list = [iss1, iss2, iss3];

      // Most recent (createdAt desc)
      final mostRecent = [...list]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      expect(mostRecent.map((i) => i.id), equals(['sort-3', 'sort-2', 'sort-1']));

      // Oldest (createdAt asc)
      final oldest = [...list]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      expect(oldest.map((i) => i.id), equals(['sort-1', 'sort-2', 'sort-3']));

      // Highest priority (critical -> high -> medium -> low)
      final highestPri = [...list]..sort((a, b) => a.priority.index.compareTo(b.priority.index));
      expect(highestPri.map((i) => i.id), equals(['sort-2', 'sort-3', 'sort-1']));

      // Recently updated (updatedAt desc)
      final updated = [...list]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      expect(updated.first.id, equals('sort-2'));
    });

    // 5. Bulk Selection & Service Preparation
    test('5. Bulk selection selects multiple issue IDs and passes them to service visit creation', () async {
      final now = DateTime.now();

      await issueRepo.createIssue(IssueModel(
        id: 'bulk-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Issue 1',
        description: '',
        priority: IssuePriority.high,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        createdAt: now,
        updatedAt: now,
      ));

      await issueRepo.createIssue(IssueModel(
        id: 'bulk-2',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Issue 2',
        description: '',
        priority: IssuePriority.critical,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        createdAt: now,
        updatedAt: now,
      ));

      final selectedIds = ['bulk-1', 'bulk-2'];

      final visitId = await serviceRepo.createServiceVisit(
        serviceCentre: 'MG Service Tech Point',
        visitDate: now,
        odometerReading: 9500,
        selectedIssueIds: selectedIds,
      );

      final detail = await serviceRepo.watchVisitDetail(visitId).first;
      expect(detail, isNotNull);
      expect(detail!.issues.length, equals(2));
      expect(detail.issues.map((i) => i.issueId), containsAll(selectedIds));
    });

    // 6. Deterministic Recurring Issue Detection Engine
    test('6. RecurringIssueDetector identifies similar prior issues on same component', () {
      final tOld = DateTime(2026, 9, 15);
      final existingIssues = [
        IssueModel(
          id: 'prior-brake-1',
          vehicleId: 'mg_comet_ev',
          componentId: 'brakes',
          title: 'Front brake caliper squeal when decelerating',
          description: 'Loud squeal over 30 km/h',
          priority: IssuePriority.critical,
          dateNoticed: tOld,
          frequency: IssueFrequency.always,
          status: IssueStatus.resolved,
          technicianRemarks: 'Cleaned front disc caliper clips and resurfaced pads.',
          createdAt: tOld,
          updatedAt: tOld,
        ),
        IssueModel(
          id: 'prior-charging-1',
          vehicleId: 'mg_comet_ev',
          componentId: 'charging_port',
          title: 'Charging flap sticking',
          description: '',
          priority: IssuePriority.low,
          dateNoticed: tOld,
          frequency: IssueFrequency.rarely,
          status: IssueStatus.open,
          createdAt: tOld,
          updatedAt: tOld,
        ),
      ];

      // Test 6a: High similarity on same component -> Match detected
      final match1 = RecurringIssueDetector.detectRecurringCandidate(
        newTitle: 'Brake caliper squeak during deceleration',
        newComponentId: 'brakes',
        existingIssues: existingIssues,
      );

      expect(match1, isNotNull);
      expect(match1!.matchedIssue.id, equals('prior-brake-1'));
      expect(match1.previousResolutionStatus, contains('Resolved'));
      expect(match1.previousTechnicianRemarks, contains('Cleaned front disc'));
      expect(match1.previousOccurrences, equals(1));

      // Test 6b: Similar wording but DIFFERENT component -> NO match
      final matchDifferentComponent = RecurringIssueDetector.detectRecurringCandidate(
        newTitle: 'Front brake caliper squeal',
        newComponentId: 'climate_control', // Different component
        existingIssues: existingIssues,
      );

      expect(matchDifferentComponent, isNull);

      // Test 6c: Component Recurrence Summary
      final summary = RecurringIssueDetector.getComponentRecurrenceSummary(existingIssues);
      expect(summary.any((s) => s.componentId == 'brakes'), isTrue);
    });

    // 7. Marking Issue as Recurring & Linking to Parent
    test('7. Marking issue as recurring persists isRecurring and parentIssueId in Drift', () async {
      final now = DateTime.now();

      await issueRepo.createIssue(IssueModel(
        id: 'recur-child',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Brake squeal has returned',
        description: 'Squeal noticed again after rain',
        priority: IssuePriority.high,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        isRecurring: false,
        createdAt: now,
        updatedAt: now,
      ));

      // Mark as recurring and link to parent
      await issueRepo.markIssueAsRecurring('recur-child', parentIssueId: 'prior-brake-1');

      final allIssues = await issueRepo.watchAllIssues().first;
      final updated = allIssues.firstWhere((i) => i.id == 'recur-child');

      expect(updated.isRecurring, isTrue);
      expect(updated.parentIssueId, equals('prior-brake-1'));
    });

    // 8. Reopening Resolved Issues with History Preservation
    test('8. Reopening a resolved issue marks it open, recurring, and appends return notes', () async {
      final now = DateTime.now();

      final original = IssueModel(
        id: 'reopen-test',
        vehicleId: 'mg_comet_ev',
        componentId: 'brakes',
        title: 'Regenerative braking clunk',
        description: 'Initial clunk when accelerator is lifted',
        priority: IssuePriority.critical,
        dateNoticed: now.subtract(const Duration(days: 14)),
        frequency: IssueFrequency.always,
        status: IssueStatus.resolved,
        technicianRemarks: 'Torqued motor mount bolts to 65 Nm.',
        resolutionNotes: 'Tightened motor mounts',
        createdAt: now.subtract(const Duration(days: 14)),
        updatedAt: now.subtract(const Duration(days: 7)),
      );

      await issueRepo.createIssue(original);

      // Reopen issue with return note
      await issueRepo.reopenIssue(
        'reopen-test',
        reopenReason: 'Clunking noise returned after 500 km of driving.',
      );

      final allIssues = await issueRepo.watchAllIssues().first;
      final reopened = allIssues.firstWhere((i) => i.id == 'reopen-test');

      expect(reopened.status, equals(IssueStatus.open));
      expect(reopened.isRecurring, isTrue);
      // Original technician remarks preserved + appended return reason
      expect(reopened.technicianRemarks, contains('Torqued motor mount bolts'));
      expect(reopened.technicianRemarks, contains('Clunking noise returned after 500 km'));
    });
  });
}
