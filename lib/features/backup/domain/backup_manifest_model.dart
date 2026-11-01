class BackupFileEntry {
  final String relativePath;
  final String sha256;
  final int sizeBytes;

  const BackupFileEntry({
    required this.relativePath,
    required this.sha256,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'relativePath': relativePath,
        'sha256': sha256,
        'sizeBytes': sizeBytes,
      };

  factory BackupFileEntry.fromJson(Map<String, dynamic> json) => BackupFileEntry(
        relativePath: json['relativePath'] as String,
        sha256: json['sha256'] as String,
        sizeBytes: json['sizeBytes'] as int,
      );
}

class BackupManifest {
  final String formatVersion;
  final String appVersion;
  final DateTime createdAt;
  final Map<String, int> recordCounts;
  final List<BackupFileEntry> fileInventory;
  final String databaseChecksum;

  const BackupManifest({
    required this.formatVersion,
    required this.appVersion,
    required this.createdAt,
    required this.recordCounts,
    required this.fileInventory,
    required this.databaseChecksum,
  });

  Map<String, dynamic> toJson() => {
        'formatVersion': formatVersion,
        'appVersion': appVersion,
        'createdAt': createdAt.toIso8601String(),
        'recordCounts': recordCounts,
        'fileInventory': fileInventory.map((e) => e.toJson()).toList(),
        'databaseChecksum': databaseChecksum,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        formatVersion: json['formatVersion'] as String,
        appVersion: json['appVersion'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        recordCounts: Map<String, int>.from(json['recordCounts'] as Map),
        fileInventory: (json['fileInventory'] as List)
            .map((e) => BackupFileEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        databaseChecksum: json['databaseChecksum'] as String,
      );
}

class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final BackupManifest? manifest;
  final List<String> corruptedFiles;
  final int totalFiles;
  final int totalRecords;

  const BackupValidationResult({
    required this.isValid,
    this.errorMessage,
    this.manifest,
    this.corruptedFiles = const [],
    this.totalFiles = 0,
    this.totalRecords = 0,
  });
}

class BackupRestoreResult {
  final bool isSuccess;
  final String message;
  final int restoredVehicles;
  final int restoredIssues;
  final int restoredVisits;
  final int restoredReminders;
  final int restoredDocuments;
  final int restoredReadings;
  final List<String> warnings;

  const BackupRestoreResult({
    required this.isSuccess,
    required this.message,
    this.restoredVehicles = 0,
    this.restoredIssues = 0,
    this.restoredVisits = 0,
    this.restoredReminders = 0,
    this.restoredDocuments = 0,
    this.restoredReadings = 0,
    this.warnings = const [],
  });
}
