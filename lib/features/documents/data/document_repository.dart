import 'dart:io';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../vehicle/data/vehicle_repository.dart';
import '../domain/document_model.dart';

class DocumentRepository {
  final AppDatabase _db;

  DocumentRepository(this._db);

  VehicleDocumentModel _toDomain(VehicleDocument row) {
    return VehicleDocumentModel(
      id: row.id,
      vehicleId: row.vehicleId,
      title: row.title,
      category: DocumentCategory.fromString(row.category),
      localFilePath: row.localFilePath,
      fileName: row.fileName,
      issueDate: row.issueDate,
      expiryDate: row.expiryDate,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }

  Future<String> _getPersistentDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final docsDir = Directory(p.join(appDir.path, 'mygarage_documents'));
    if (!await docsDir.exists()) {
      await docsDir.create(recursive: true);
    }
    return docsDir.path;
  }

  Stream<List<VehicleDocumentModel>> watchDocumentsForVehicle(
    String vehicleId, {
    DocumentCategory? category,
  }) {
    final query = _db.select(_db.vehicleDocuments)
      ..where((t) => t.vehicleId.equals(vehicleId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
      ]);

    if (category != null) {
      query.where((t) => t.category.equals(category.name));
    }

    return query.watch().map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<VehicleDocumentModel>> getDocumentsForVehicle(String vehicleId) async {
    final rows = await (_db.select(_db.vehicleDocuments)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
    return rows.map(_toDomain).toList();
  }

  Future<VehicleDocumentModel?> getDocumentById(String id) async {
    final row = await (_db.select(_db.vehicleDocuments)..where((t) => t.id.equals(id))).getSingleOrNull();
    return row != null ? _toDomain(row) : null;
  }

  Future<String> addDocument({
    required String vehicleId,
    required String title,
    required DocumentCategory category,
    required String sourceFilePath,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? notes,
  }) async {
    final sourceFile = File(sourceFilePath);
    if (!await sourceFile.exists()) {
      throw ArgumentError('Source file does not exist at $sourceFilePath');
    }

    final id = const Uuid().v4();
    final originalFileName = p.basename(sourceFilePath);
    final ext = p.extension(originalFileName).toLowerCase();

    // Enforce supported types
    final allowedExts = ['.pdf', '.jpg', '.jpeg', '.png'];
    if (!allowedExts.contains(ext)) {
      throw ArgumentError('Unsupported file type: $ext. Only PDF, JPG, and PNG are supported.');
    }

    final storageDir = await _getPersistentDocumentsDirectory();
    final targetPath = p.join(storageDir, '${id}_$originalFileName');
    await sourceFile.copy(targetPath);

    final now = DateTime.now();

    await _db.into(_db.vehicleDocuments).insert(
          VehicleDocumentsCompanion.insert(
            id: id,
            vehicleId: vehicleId,
            title: title,
            category: category.name,
            localFilePath: targetPath,
            fileName: originalFileName,
            issueDate: Value(issueDate),
            expiryDate: Value(expiryDate),
            notes: Value(notes),
            createdAt: now,
          ),
        );

    return id;
  }

  Future<void> updateDocument(VehicleDocumentModel doc) async {
    await (_db.update(_db.vehicleDocuments)..where((t) => t.id.equals(doc.id))).write(
          VehicleDocumentsCompanion(
            title: Value(doc.title),
            category: Value(doc.category.name),
            issueDate: Value(doc.issueDate),
            expiryDate: Value(doc.expiryDate),
            notes: Value(doc.notes),
          ),
        );
  }

  Future<void> deleteDocument(String id) async {
    final doc = await getDocumentById(id);
    if (doc != null) {
      try {
        final file = File(doc.localFilePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
      await (_db.delete(_db.vehicleDocuments)..where((t) => t.id.equals(id))).go();
    }
  }

  Future<bool> verifyFileExists(String path) async {
    final file = File(path);
    return file.exists();
  }
}

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DocumentRepository(db);
});

final activeVehicleDocumentsProvider = StreamProvider<List<VehicleDocumentModel>>((ref) {
  final activeVehicleId = ref.watch(activeVehicleIdProvider);
  final repo = ref.watch(documentRepositoryProvider);
  return repo.watchDocumentsForVehicle(activeVehicleId);
});
