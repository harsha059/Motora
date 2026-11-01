import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/backup_service.dart';
import '../domain/backup_manifest_model.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isExporting = false;
  bool _isValidating = false;
  File? _lastExportedFile;
  BackupManifest? _lastExportedManifest;

  Future<void> _createBackup() async {
    setState(() => _isExporting = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final backupDir = Directory('${appDir.path}/mygarage_backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final file = await ref.read(backupServiceProvider).createBackupArchive(outputDir: backupDir);
      final validation = await ref.read(backupServiceProvider).validateBackupArchive(file);

      setState(() {
        _isExporting = false;
        _lastExportedFile = file;
        _lastExportedManifest = validation.manifest;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup archive created successfully (${(file.lengthSync() / 1024).toStringAsFixed(1)} KB)'),
          ),
        );
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  Future<void> _selectAndRestoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );

    if (result == null || result.files.single.path == null) return;

    final zipFile = File(result.files.single.path!);
    setState(() => _isValidating = true);

    final validation = await ref.read(backupServiceProvider).validateBackupArchive(zipFile);
    setState(() => _isValidating = false);

    if (!mounted) return;

    if (!validation.isValid || validation.manifest == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Invalid Backup Archive'),
          content: Text(
            validation.errorMessage ?? 'The selected archive failed validation.',
            style: const TextStyle(color: AppColors.critical),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
          ],
        ),
      );
      return;
    }

    final manifest = validation.manifest!;

    // Step 2: Show confirmation dialog with record counts and manifest details
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.settings_backup_restore_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Confirm Restore'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'The backup archive was validated successfully.',
              style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText),
            ),
            const SizedBox(height: 12),
            Text(
              'Created: ${DateFormat('dd MMM yyyy, HH:mm').format(manifest.createdAt)}',
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            Text(
              'App Version: ${manifest.appVersion} (Format v${manifest.formatVersion})',
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 12),
            const Text(
              'Record Summary:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent),
            ),
            const SizedBox(height: 4),
            ...manifest.recordCounts.entries.map(
              (e) => Text('• ${e.key}: ${e.value} records', style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Records will be staged and merged. Existing IDs will be safely preserved without silent deletion.',
                      style: TextStyle(fontSize: 11, color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _performRestore(zipFile);
            },
            child: const Text('Proceed with Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRestore(File zipFile) async {
    setState(() => _isValidating = true);
    final result = await ref.read(backupServiceProvider).restoreBackupArchive(zipFile);
    setState(() => _isValidating = false);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(
              result.isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: result.isSuccess ? AppColors.accent : AppColors.critical,
            ),
            const SizedBox(width: 8),
            Text(result.isSuccess ? 'Restore Complete' : 'Restore Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message, style: const TextStyle(color: AppColors.primaryText)),
            if (result.isSuccess) ...[
              const SizedBox(height: 12),
              Text('• Vehicles Restored: ${result.restoredVehicles}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('• Issues Restored: ${result.restoredIssues}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('• Service Visits Restored: ${result.restoredVisits}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('• Reminders Restored: ${result.restoredReminders}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('• Documents Restored: ${result.restoredDocuments}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              Text('• Odometer Logs Restored: ${result.restoredReadings}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
            ],
            if (result.warnings.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Warnings:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
              ...result.warnings.map(
                (w) => Text('• $w', style: const TextStyle(fontSize: 10.5, color: AppColors.warning)),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Local Backup & Restore'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          children: [
            // Intro Card
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentDim,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.shield_outlined, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline & Privacy First',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Zero cloud reliance. Export encrypted ZIP archives containing your full database, images, and documents.',
                              style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Export Section
            const Text(
              'CREATE BACKUP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.tertiaryText,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Export Complete Garage Archive',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Packages vehicles, odometer logs, issues, service records, reminders, documents, and SHA-256 integrity checksums.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isExporting ? null : _createBackup,
                      icon: _isExporting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                            )
                          : const Icon(Icons.archive_outlined, size: 18),
                      label: Text(_isExporting ? 'Generating Archive...' : 'Create Backup Archive (.zip)'),
                    ),
                  ),
                  if (_lastExportedFile != null && _lastExportedManifest != null) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1, color: AppColors.cardBorder),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Last Backup: ${_lastExportedFile!.path.split(Platform.pathSeparator).last}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_lastExportedManifest!.fileInventory.length} files • ${_lastExportedManifest!.recordCounts.values.fold(0, (a, b) => a + b)} database records',
                      style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Restore Section
            const Text(
              'RESTORE BACKUP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.tertiaryText,
              ),
            ),
            const SizedBox(height: 8),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Restore from Local Archive',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Inspects manifest, verifies SHA-256 integrity checksums, checks version compatibility, and stages records safely.',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _isValidating ? null : _selectAndRestoreBackup,
                      icon: _isValidating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                            )
                          : const Icon(Icons.unarchive_outlined, size: 18, color: AppColors.accent),
                      label: Text(
                        _isValidating ? 'Validating Archive...' : 'Select Archive to Restore',
                        style: const TextStyle(color: AppColors.accent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
