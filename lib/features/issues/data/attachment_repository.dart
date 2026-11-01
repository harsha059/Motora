import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../domain/attachment_model.dart';

class AttachmentRepository {
  final AppDatabase _db;
  final ImagePicker _picker;

  AttachmentRepository(this._db, [ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  Future<Directory> _getPersistentDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory(p.join(docsDir.path, 'mygarage_attachments'));
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }
    return attachmentsDir;
  }

  Future<IssueAttachmentModel?> captureAndSaveImage({
    required String issueId,
    required ImageSource source,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (picked == null) return null;

    final targetDir = await _getPersistentDirectory();
    final ext = p.extension(picked.path).isNotEmpty ? p.extension(picked.path) : '.jpg';
    final fileName = 'issue_${issueId.substring(0, issueId.length > 8 ? 8 : issueId.length)}_${DateTime.now().millisecondsSinceEpoch}$ext';
    final persistentPath = p.join(targetDir.path, fileName);

    final savedFile = await File(picked.path).copy(persistentPath);

    final id = const Uuid().v4();
    final now = DateTime.now();

    await _db.into(_db.issueAttachments).insert(
          IssueAttachmentsCompanion.insert(
            id: id,
            issueId: issueId,
            localFilePath: savedFile.path,
            fileName: fileName,
            createdAt: now,
          ),
        );

    return IssueAttachmentModel(
      id: id,
      issueId: issueId,
      localFilePath: savedFile.path,
      fileName: fileName,
      createdAt: now,
    );
  }

  Future<IssueAttachmentModel> saveDirectAttachment({
    required String issueId,
    required String sourceFilePath,
  }) async {
    final targetDir = await _getPersistentDirectory();
    final fileName = 'att_${DateTime.now().millisecondsSinceEpoch}_${p.basename(sourceFilePath)}';
    final persistentPath = p.join(targetDir.path, fileName);

    final sourceFile = File(sourceFilePath);
    if (await sourceFile.exists()) {
      await sourceFile.copy(persistentPath);
    }

    final id = const Uuid().v4();
    final now = DateTime.now();

    await _db.into(_db.issueAttachments).insert(
          IssueAttachmentsCompanion.insert(
            id: id,
            issueId: issueId,
            localFilePath: persistentPath,
            fileName: fileName,
            createdAt: now,
          ),
        );

    return IssueAttachmentModel(
      id: id,
      issueId: issueId,
      localFilePath: persistentPath,
      fileName: fileName,
      createdAt: now,
    );
  }

  Stream<List<IssueAttachmentModel>> watchAttachmentsForIssue(String issueId) {
    return (_db.select(_db.issueAttachments)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows
            .map((r) => IssueAttachmentModel(
                  id: r.id,
                  issueId: r.issueId,
                  localFilePath: r.localFilePath,
                  fileName: r.fileName,
                  createdAt: r.createdAt,
                ))
            .toList());
  }

  Future<List<IssueAttachmentModel>> getAttachmentsForIssue(String issueId) async {
    final rows = await (_db.select(_db.issueAttachments)
          ..where((t) => t.issueId.equals(issueId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]))
        .get();

    return rows
        .map((r) => IssueAttachmentModel(
              id: r.id,
              issueId: r.issueId,
              localFilePath: r.localFilePath,
              fileName: r.fileName,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  Future<void> deleteAttachment(String attachmentId) async {
    final row = await (_db.select(_db.issueAttachments)..where((t) => t.id.equals(attachmentId))).getSingleOrNull();
    if (row != null) {
      try {
        final file = File(row.localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      await (_db.delete(_db.issueAttachments)..where((t) => t.id.equals(attachmentId))).go();
    }
  }
}

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AttachmentRepository(db);
});

final issueAttachmentsProvider = StreamProvider.family<List<IssueAttachmentModel>, String>((ref, issueId) {
  final repo = ref.watch(attachmentRepositoryProvider);
  return repo.watchAttachmentsForIssue(issueId);
});
