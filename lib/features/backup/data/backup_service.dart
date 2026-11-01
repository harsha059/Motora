import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/backup_manifest_model.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  static const String currentFormatVersion = '1.0.0';
  static const String currentAppVersion = '1.0.0';

  String _calculateSha256(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }

  Future<File> createBackupArchive({required Directory outputDir}) async {
    final archive = Archive();

    // 1. Fetch all records from database
    final vehicles = await _db.select(_db.vehicles).get();
    final readings = await _db.select(_db.odometerReadings).get();
    final issues = await _db.select(_db.issues).get();
    final serviceVisits = await _db.select(_db.serviceVisits).get();
    final visitIssues = await _db.select(_db.serviceVisitIssues).get();
    final attachments = await _db.select(_db.issueAttachments).get();
    final reminders = await _db.select(_db.maintenanceReminders).get();
    final documents = await _db.select(_db.vehicleDocuments).get();

    final dbData = {
      'vehicles': vehicles
          .map((v) => {
                'id': v.id,
                'nickname': v.nickname,
                'manufacturer': v.manufacturer,
                'model': v.model,
                'variant': v.variant,
                'registrationNumber': v.registrationNumber,
                'modelYear': v.modelYear,
                'purchaseDate': v.purchaseDate?.toIso8601String(),
                'currentOdometer': v.currentOdometer,
                'vehicleType': v.vehicleType,
                'imagePath': v.imagePath,
                'model3dAssetPath': v.model3dAssetPath,
                'createdAt': v.createdAt.toIso8601String(),
                'updatedAt': v.updatedAt.toIso8601String(),
              })
          .toList(),
      'odometerReadings': readings
          .map((r) => {
                'id': r.id,
                'vehicleId': r.vehicleId,
                'reading': r.reading,
                'readingDate': r.readingDate.toIso8601String(),
                'notes': r.notes,
                'isCorrection': r.isCorrection,
                'createdAt': r.createdAt.toIso8601String(),
              })
          .toList(),
      'issues': issues
          .map((i) => {
                'id': i.id,
                'vehicleId': i.vehicleId,
                'componentId': i.componentId,
                'title': i.title,
                'description': i.description,
                'priority': i.priority.index,
                'dateNoticed': i.dateNoticed.toIso8601String(),
                'frequency': i.frequency.index,
                'photoUrlsJson': i.photoUrlsJson,
                'status': i.status.index,
                'technicianRemarks': i.technicianRemarks,
                'resolutionNotes': i.resolutionNotes,
                'isRecurring': i.isRecurring,
                'parentIssueId': i.parentIssueId,
                'createdAt': i.createdAt.toIso8601String(),
                'updatedAt': i.updatedAt.toIso8601String(),
              })
          .toList(),
      'serviceVisits': serviceVisits
          .map((s) => {
                'id': s.id,
                'vehicleId': s.vehicleId,
                'serviceCentre': s.serviceCentre,
                'visitDate': s.visitDate.toIso8601String(),
                'odometerReading': s.odometerReading,
                'status': s.status.index,
                'additionalRequests': s.additionalRequests,
                'technicianName': s.technicianName,
                'signOffDetails': s.signOffDetails,
                'totalCost': s.totalCost,
                'createdAt': s.createdAt.toIso8601String(),
                'completedAt': s.completedAt?.toIso8601String(),
              })
          .toList(),
      'serviceVisitIssues': visitIssues
          .map((vi) => {
                'id': vi.id,
                'serviceVisitId': vi.serviceVisitId,
                'issueId': vi.issueId,
                'technicianRemarks': vi.technicianRemarks,
                'workPerformed': vi.workPerformed,
                'partsReplaced': vi.partsReplaced,
                'resolutionStatus': vi.resolutionStatus.index,
                'followUpRequired': vi.followUpRequired,
                'createdAt': vi.createdAt.toIso8601String(),
              })
          .toList(),
      'issueAttachments': attachments
          .map((a) => {
                'id': a.id,
                'issueId': a.issueId,
                'localFilePath': a.localFilePath,
                'fileName': a.fileName,
                'createdAt': a.createdAt.toIso8601String(),
              })
          .toList(),
      'maintenanceReminders': reminders
          .map((m) => {
                'id': m.id,
                'vehicleId': m.vehicleId,
                'title': m.title,
                'description': m.description,
                'category': m.category,
                'reminderType': m.reminderType,
                'dueDate': m.dueDate?.toIso8601String(),
                'dueOdometer': m.dueOdometer,
                'notificationLeadDays': m.notificationLeadDays,
                'recurrenceIntervalKm': m.recurrenceIntervalKm,
                'recurrenceIntervalMonths': m.recurrenceIntervalMonths,
                'isCompleted': m.isCompleted,
                'isSnoozed': m.isSnoozed,
                'snoozedUntil': m.snoozedUntil?.toIso8601String(),
                'createdAt': m.createdAt.toIso8601String(),
                'completedAt': m.completedAt?.toIso8601String(),
              })
          .toList(),
      'vehicleDocuments': documents
          .map((d) => {
                'id': d.id,
                'vehicleId': d.vehicleId,
                'title': d.title,
                'category': d.category,
                'localFilePath': d.localFilePath,
                'fileName': d.fileName,
                'issueDate': d.issueDate?.toIso8601String(),
                'expiryDate': d.expiryDate?.toIso8601String(),
                'notes': d.notes,
                'createdAt': d.createdAt.toIso8601String(),
              })
          .toList(),
    };

    // 2. Encode database json
    final dbJsonStr = const JsonEncoder.withIndent('  ').convert(dbData);
    final dbBytes = utf8.encode(dbJsonStr);
    final dbChecksum = _calculateSha256(dbBytes);

    archive.addFile(ArchiveFile('database.json', dbBytes.length, dbBytes));

    // 3. Collect physical files and build inventory
    final List<BackupFileEntry> fileInventory = [];

    // Helper to package files
    Future<void> packageFile(String filePath, String relativePathPrefix) async {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final hash = _calculateSha256(bytes);
        final baseName = p.basename(filePath);
        final archivePath = '$relativePathPrefix/$baseName';

        archive.addFile(ArchiveFile(archivePath, bytes.length, bytes));
        fileInventory.add(
          BackupFileEntry(
            relativePath: archivePath,
            sha256: hash,
            sizeBytes: bytes.length,
          ),
        );
      }
    }

    for (final att in attachments) {
      await packageFile(att.localFilePath, 'files/attachments');
    }

    for (final doc in documents) {
      await packageFile(doc.localFilePath, 'files/documents');
    }

    // 4. Create manifest.json
    final recordCounts = {
      'vehicles': vehicles.length,
      'odometerReadings': readings.length,
      'issues': issues.length,
      'serviceVisits': serviceVisits.length,
      'serviceVisitIssues': visitIssues.length,
      'issueAttachments': attachments.length,
      'maintenanceReminders': reminders.length,
      'vehicleDocuments': documents.length,
    };

    final manifest = BackupManifest(
      formatVersion: currentFormatVersion,
      appVersion: currentAppVersion,
      createdAt: DateTime.now(),
      recordCounts: recordCounts,
      fileInventory: fileInventory,
      databaseChecksum: dbChecksum,
    );

    final manifestJson = const JsonEncoder.withIndent('  ').convert(manifest.toJson());
    final manifestBytes = utf8.encode(manifestJson);
    archive.addFile(ArchiveFile('manifest.json', manifestBytes.length, manifestBytes));

    // 5. Encode archive to ZIP
    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final outputFile = File(p.join(outputDir.path, 'mygarage_backup_$timestamp.zip'));
    await outputFile.writeAsBytes(zipBytes);

    return outputFile;
  }

  Future<BackupValidationResult> validateBackupArchive(File zipFile) async {
    if (!await zipFile.exists()) {
      return const BackupValidationResult(
        isValid: false,
        errorMessage: 'Backup archive file does not exist on disk.',
      );
    }

    try {
      final bytes = await zipFile.readAsBytes();
      if (bytes.isEmpty) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Backup archive is empty (0 bytes).',
        );
      }

      final archive = ZipDecoder().decodeBytes(bytes);

      // Path traversal security check
      for (final file in archive) {
        if (file.name.contains('..') || file.name.startsWith('/') || file.name.startsWith('\\')) {
          return const BackupValidationResult(
            isValid: false,
            errorMessage: 'Security violation: Archive contains relative or absolute path traversal.',
          );
        }
      }

      // Check manifest
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        return const BackupValidationResult(
          isValid: false,
          errorMessage: 'Corrupt archive: Missing manifest.json.',
        );
      }

      final manifestContent = utf8.decode(manifestFile.content as List<int>);
      final manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
      final manifest = BackupManifest.fromJson(manifestJson);

      if (manifest.formatVersion != currentFormatVersion) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Unsupported backup format version: ${manifest.formatVersion}. Expected $currentFormatVersion.',
          manifest: manifest,
        );
      }

      // Check database.json
      final dbFile = archive.findFile('database.json');
      if (dbFile == null) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Corrupt archive: Missing database.json.',
          manifest: manifest,
        );
      }

      final actualDbHash = _calculateSha256(dbFile.content as List<int>);
      if (actualDbHash != manifest.databaseChecksum) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Database integrity checksum mismatch! The archive data may be altered or corrupted.',
          manifest: manifest,
        );
      }

      // Check file inventory
      final List<String> corrupted = [];
      for (final entry in manifest.fileInventory) {
        final archived = archive.findFile(entry.relativePath);
        if (archived == null) {
          corrupted.add(entry.relativePath);
          continue;
        }
        final content = archived.content as List<int>;
        final hash = _calculateSha256(content);
        if (hash != entry.sha256) {
          corrupted.add(entry.relativePath);
        }
      }

      if (corrupted.isNotEmpty) {
        return BackupValidationResult(
          isValid: false,
          errorMessage: 'Integrity check failed for ${corrupted.length} archived files.',
          manifest: manifest,
          corruptedFiles: corrupted,
        );
      }

      final totalRecords = manifest.recordCounts.values.fold<int>(0, (sum, count) => sum + count);

      return BackupValidationResult(
        isValid: true,
        manifest: manifest,
        totalFiles: manifest.fileInventory.length,
        totalRecords: totalRecords,
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        errorMessage: 'Failed to inspect or decode backup archive: $e',
      );
    }
  }

  Future<BackupRestoreResult> restoreBackupArchive(
    File zipFile, {
    bool overwrite = false,
  }) async {
    final validation = await validateBackupArchive(zipFile);
    if (!validation.isValid || validation.manifest == null) {
      return BackupRestoreResult(
        isSuccess: false,
        message: validation.errorMessage ?? 'Archive validation failed.',
      );
    }

    try {
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final dbFile = archive.findFile('database.json')!;
      final dbJsonStr = utf8.decode(dbFile.content as List<int>);
      final dbData = jsonDecode(dbJsonStr) as Map<String, dynamic>;

      final appDir = await getApplicationDocumentsDirectory();
      final docsDir = Directory(p.join(appDir.path, 'mygarage_documents'));
      final attachDir = Directory(p.join(appDir.path, 'mygarage_attachments'));
      if (!await docsDir.exists()) await docsDir.create(recursive: true);
      if (!await attachDir.exists()) await attachDir.create(recursive: true);

      // Restore physical files to target directories
      for (final file in archive) {
        if (file.isFile && file.name.startsWith('files/')) {
          final targetDir = file.name.startsWith('files/documents') ? docsDir : attachDir;
          final baseName = p.basename(file.name);
          final destFile = File(p.join(targetDir.path, baseName));
          await destFile.writeAsBytes(file.content as List<int>);
        }
      }

      final List<String> warnings = [];

      // Restore database inside a transaction
      await _db.transaction(() async {
        // 1. Vehicles
        final vehiclesList = (dbData['vehicles'] as List? ?? []);
        for (final item in vehiclesList) {
          final v = item as Map<String, dynamic>;
          final id = v['id'] as String;
          final existing = await (_db.select(_db.vehicles)..where((t) => t.id.equals(id))).getSingleOrNull();
          if (existing != null && !overwrite) {
            warnings.add('Vehicle $id (${v['nickname']}) already exists; preserved existing record.');
            continue;
          }

          await _db.into(_db.vehicles).insertOnConflictUpdate(
                VehiclesCompanion.insert(
                  id: id,
                  nickname: v['nickname'] as String,
                  manufacturer: v['manufacturer'] as String,
                  model: v['model'] as String,
                  variant: v['variant'] as String,
                  registrationNumber: Value(v['registrationNumber'] as String?),
                  modelYear: Value(v['modelYear'] as int?),
                  purchaseDate: Value(v['purchaseDate'] != null ? DateTime.parse(v['purchaseDate'] as String) : null),
                  currentOdometer: Value((v['currentOdometer'] as int?) ?? 0),
                  vehicleType: Value((v['vehicleType'] as String?) ?? 'Electric (EV)'),
                  imagePath: Value(v['imagePath'] as String?),
                  model3dAssetPath: Value(v['model3dAssetPath'] as String?),
                  createdAt: DateTime.parse(v['createdAt'] as String),
                  updatedAt: DateTime.parse(v['updatedAt'] as String),
                ),
              );
        }

        // 2. Odometer Readings
        final readingsList = (dbData['odometerReadings'] as List? ?? []);
        for (final item in readingsList) {
          final r = item as Map<String, dynamic>;
          final id = r['id'] as String;
          await _db.into(_db.odometerReadings).insertOnConflictUpdate(
                OdometerReadingsCompanion.insert(
                  id: id,
                  vehicleId: r['vehicleId'] as String,
                  reading: r['reading'] as int,
                  readingDate: DateTime.parse(r['readingDate'] as String),
                  notes: Value(r['notes'] as String?),
                  isCorrection: Value((r['isCorrection'] as bool?) ?? false),
                  createdAt: DateTime.parse(r['createdAt'] as String),
                ),
              );
        }

        // 3. Issues
        final issuesList = (dbData['issues'] as List? ?? []);
        for (final item in issuesList) {
          final i = item as Map<String, dynamic>;
          final id = i['id'] as String;
          await _db.into(_db.issues).insertOnConflictUpdate(
                IssuesCompanion.insert(
                  id: id,
                  vehicleId: Value(i['vehicleId'] as String? ?? 'mg_comet_ev'),
                  componentId: i['componentId'] as String,
                  title: i['title'] as String,
                  description: i['description'] as String,
                  priority: IssuePriority.values[i['priority'] as int],
                  dateNoticed: DateTime.parse(i['dateNoticed'] as String),
                  frequency: IssueFrequency.values[i['frequency'] as int],
                  photoUrlsJson: Value(i['photoUrlsJson'] as String?),
                  status: Value(IssueStatus.values[i['status'] as int]),
                  technicianRemarks: Value(i['technicianRemarks'] as String?),
                  resolutionNotes: Value(i['resolutionNotes'] as String?),
                  isRecurring: Value((i['isRecurring'] as bool?) ?? false),
                  parentIssueId: Value(i['parentIssueId'] as String?),
                  createdAt: DateTime.parse(i['createdAt'] as String),
                  updatedAt: DateTime.parse(i['updatedAt'] as String),
                ),
              );
        }

        // 4. Service Visits
        final visitsList = (dbData['serviceVisits'] as List? ?? []);
        for (final item in visitsList) {
          final s = item as Map<String, dynamic>;
          final id = s['id'] as String;
          await _db.into(_db.serviceVisits).insertOnConflictUpdate(
                ServiceVisitsCompanion.insert(
                  id: id,
                  vehicleId: Value(s['vehicleId'] as String? ?? 'mg_comet_ev'),
                  serviceCentre: s['serviceCentre'] as String,
                  visitDate: DateTime.parse(s['visitDate'] as String),
                  odometerReading: s['odometerReading'] as int,
                  status: Value(ServiceVisitStatus.values[s['status'] as int]),
                  additionalRequests: Value(s['additionalRequests'] as String?),
                  technicianName: Value(s['technicianName'] as String?),
                  signOffDetails: Value(s['signOffDetails'] as String?),
                  totalCost: Value((s['totalCost'] as num?)?.toDouble()),
                  createdAt: DateTime.parse(s['createdAt'] as String),
                  completedAt: Value(s['completedAt'] != null ? DateTime.parse(s['completedAt'] as String) : null),
                ),
              );
        }

        // 5. Service Visit Issues
        final viList = (dbData['serviceVisitIssues'] as List? ?? []);
        for (final item in viList) {
          final vi = item as Map<String, dynamic>;
          final id = vi['id'] as String;
          await _db.into(_db.serviceVisitIssues).insertOnConflictUpdate(
                ServiceVisitIssuesCompanion.insert(
                  id: id,
                  serviceVisitId: vi['serviceVisitId'] as String,
                  issueId: vi['issueId'] as String,
                  technicianRemarks: Value(vi['technicianRemarks'] as String?),
                  workPerformed: Value(vi['workPerformed'] as String?),
                  partsReplaced: Value(vi['partsReplaced'] as String?),
                  resolutionStatus: Value(VisitIssueResolution.values[vi['resolutionStatus'] as int]),
                  followUpRequired: Value((vi['followUpRequired'] as bool?) ?? false),
                  createdAt: DateTime.parse(vi['createdAt'] as String),
                ),
              );
        }

        // 6. Issue Attachments
        final attList = (dbData['issueAttachments'] as List? ?? []);
        for (final item in attList) {
          final a = item as Map<String, dynamic>;
          final id = a['id'] as String;
          await _db.into(_db.issueAttachments).insertOnConflictUpdate(
                IssueAttachmentsCompanion.insert(
                  id: id,
                  issueId: a['issueId'] as String,
                  localFilePath: a['localFilePath'] as String,
                  fileName: a['fileName'] as String,
                  createdAt: DateTime.parse(a['createdAt'] as String),
                ),
              );
        }

        // 7. Maintenance Reminders
        final remList = (dbData['maintenanceReminders'] as List? ?? []);
        for (final item in remList) {
          final m = item as Map<String, dynamic>;
          final id = m['id'] as String;
          await _db.into(_db.maintenanceReminders).insertOnConflictUpdate(
                MaintenanceRemindersCompanion.insert(
                  id: id,
                  vehicleId: m['vehicleId'] as String,
                  title: m['title'] as String,
                  description: Value(m['description'] as String?),
                  category: m['category'] as String,
                  reminderType: m['reminderType'] as String,
                  dueDate: Value(m['dueDate'] != null ? DateTime.parse(m['dueDate'] as String) : null),
                  dueOdometer: Value(m['dueOdometer'] as int?),
                  notificationLeadDays: Value((m['notificationLeadDays'] as int?) ?? 7),
                  recurrenceIntervalKm: Value(m['recurrenceIntervalKm'] as int?),
                  recurrenceIntervalMonths: Value(m['recurrenceIntervalMonths'] as int?),
                  isCompleted: Value((m['isCompleted'] as bool?) ?? false),
                  isSnoozed: Value((m['isSnoozed'] as bool?) ?? false),
                  snoozedUntil: Value(m['snoozedUntil'] != null ? DateTime.parse(m['snoozedUntil'] as String) : null),
                  createdAt: DateTime.parse(m['createdAt'] as String),
                  completedAt: Value(m['completedAt'] != null ? DateTime.parse(m['completedAt'] as String) : null),
                ),
              );
        }

        // 8. Vehicle Documents
        final docList = (dbData['vehicleDocuments'] as List? ?? []);
        for (final item in docList) {
          final d = item as Map<String, dynamic>;
          final id = d['id'] as String;
          await _db.into(_db.vehicleDocuments).insertOnConflictUpdate(
                VehicleDocumentsCompanion.insert(
                  id: id,
                  vehicleId: d['vehicleId'] as String,
                  title: d['title'] as String,
                  category: d['category'] as String,
                  localFilePath: d['localFilePath'] as String,
                  fileName: d['fileName'] as String,
                  issueDate: Value(d['issueDate'] != null ? DateTime.parse(d['issueDate'] as String) : null),
                  expiryDate: Value(d['expiryDate'] != null ? DateTime.parse(d['expiryDate'] as String) : null),
                  notes: Value(d['notes'] as String?),
                  createdAt: DateTime.parse(d['createdAt'] as String),
                ),
              );
        }
      });

      return BackupRestoreResult(
        isSuccess: true,
        message: 'Restoration completed successfully.',
        restoredVehicles: (dbData['vehicles'] as List? ?? []).length,
        restoredIssues: (dbData['issues'] as List? ?? []).length,
        restoredVisits: (dbData['serviceVisits'] as List? ?? []).length,
        restoredReminders: (dbData['maintenanceReminders'] as List? ?? []).length,
        restoredDocuments: (dbData['vehicleDocuments'] as List? ?? []).length,
        restoredReadings: (dbData['odometerReadings'] as List? ?? []).length,
        warnings: warnings,
      );
    } catch (e) {
      return BackupRestoreResult(
        isSuccess: false,
        message: 'Failed to restore database records: $e',
      );
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupService(db);
});
