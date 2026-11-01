import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mygarage/core/database/app_database.dart';
import 'package:mygarage/features/issues/data/issue_repository.dart';
import 'package:mygarage/features/issues/domain/issue_model.dart';

void main() {
  late AppDatabase db;
  late IssueRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = IssueRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('IssueRepository Tests', () {
    test('Initial database is empty, seedInitialDataIfEmpty populates sample issues', () async {
      final initialIssues = await repository.watchAllIssues().first;
      expect(initialIssues, isEmpty);

      await repository.seedInitialDataIfEmpty();

      final seededIssues = await repository.watchAllIssues().first;
      expect(seededIssues.length, equals(3));
      expect(seededIssues.any((i) => i.vehicleId == 'mg_comet_ev'), isTrue);
    });

    test('Create, retrieve and update issue status', () async {
      final now = DateTime.now();
      final testIssue = IssueModel(
        id: 'test-issue-1',
        vehicleId: 'mg_comet_ev',
        componentId: 'battery_pack',
        title: 'Battery thermal management warning',
        description: 'High temperature alert during DC fast charging',
        priority: IssuePriority.critical,
        dateNoticed: now,
        frequency: IssueFrequency.always,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createIssue(testIssue);

      var issues = await repository.watchAllIssues().first;
      expect(issues.length, equals(1));
      expect(issues.first.title, equals('Battery thermal management warning'));
      expect(issues.first.priority, equals(IssuePriority.critical));

      // Update status to in progress
      await repository.updateIssueStatus('test-issue-1', IssueStatus.inProgress);
      issues = await repository.watchAllIssues().first;
      expect(issues.first.status, equals(IssueStatus.inProgress));

      // Delete issue
      await repository.deleteIssue('test-issue-1');
      issues = await repository.watchAllIssues().first;
      expect(issues, isEmpty);
    });
  });
}
