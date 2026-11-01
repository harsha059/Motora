import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../vehicle/data/vehicle_repository.dart';
import '../data/document_repository.dart';
import '../domain/document_model.dart';

class DocumentVaultScreen extends ConsumerStatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  ConsumerState<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends ConsumerState<DocumentVaultScreen> {
  DocumentCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final activeVehicle = ref.watch(activeVehicleProvider);
    final documentsAsync = ref.watch(activeVehicleDocumentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Document Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            tooltip: 'Import Document',
            onPressed: () {
              if (activeVehicle != null) {
                _showAddDocumentDialog(context, ref, activeVehicle.id);
              }
            },
          ),
        ],
      ),
      body: activeVehicle == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : Column(
              children: [
                // Category Filter Bar
                _buildCategoryFilter(),

                // Document List
                Expanded(
                  child: documentsAsync.when(
                    data: (documents) {
                      final filtered = _selectedCategory == null
                          ? documents
                          : documents.where((d) => d.category == _selectedCategory).toList();

                      if (filtered.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_open_rounded, size: 54, color: AppColors.tertiaryText),
                              const SizedBox(height: 12),
                              Text(
                                _selectedCategory == null
                                    ? 'No vehicle documents stored yet'
                                    : 'No documents in ${_selectedCategory!.label}',
                                style: const TextStyle(color: AppColors.secondaryText),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => _showAddDocumentDialog(context, ref, activeVehicle.id),
                                icon: const Icon(Icons.upload_file_rounded),
                                label: const Text('Upload Document'),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          return _buildDocumentCard(context, ref, doc);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.critical))),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip('All Documents', null),
          ...DocumentCategory.values.map((c) => _buildFilterChip(c.label, c)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, DocumentCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.background : AppColors.secondaryText,
          ),
        ),
        backgroundColor: AppColors.elevatedSurface,
        selectedColor: AppColors.accent,
        checkmarkColor: AppColors.background,
        side: BorderSide(color: isSelected ? AppColors.accent : AppColors.cardBorder),
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Widget _buildDocumentCard(BuildContext context, WidgetRef ref, VehicleDocumentModel doc) {
    final isExpired = doc.isExpired();
    final isExpiring = doc.isExpiringSoon();

    Color expiryColor = AppColors.accent;
    String expiryLabel = 'VALID';

    if (isExpired) {
      expiryColor = AppColors.critical;
      expiryLabel = 'EXPIRED';
    } else if (isExpiring) {
      expiryColor = AppColors.warning;
      final days = doc.daysUntilExpiry();
      expiryLabel = days != null ? 'EXPIRES IN ${days}D' : 'EXPIRING SOON';
    }

    final isFileAvailable = File(doc.localFilePath).existsSync();

    return GlassCard(
      borderColor: isExpired ? AppColors.critical.withValues(alpha: 0.7) : AppColors.cardBorder,
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: () => _openDocumentPreview(context, doc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: doc.isPdf
                        ? AppColors.critical.withValues(alpha: 0.15)
                        : AppColors.accentDim,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    doc.isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                    color: doc.isPdf ? AppColors.critical : AppColors.accent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doc.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (doc.expiryDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: expiryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                expiryLabel,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: expiryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${doc.category.label} • ${doc.fileName}',
                        style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.secondaryText, size: 20),
                  color: AppColors.elevatedSurface,
                  onSelected: (val) {
                    if (val == 'view') {
                      _openDocumentPreview(context, doc);
                    } else if (val == 'delete') {
                      ref.read(documentRepositoryProvider).deleteDocument(doc.id);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 16, color: AppColors.primaryText),
                          SizedBox(width: 8),
                          Text('View Document'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.critical),
                          SizedBox(width: 8),
                          Text('Delete Document', style: TextStyle(color: AppColors.critical)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (doc.issueDate != null)
                  Text(
                    'Issued: ${DateFormat('dd MMM yyyy').format(doc.issueDate!)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.tertiaryText),
                  ),
                if (doc.expiryDate != null)
                  Text(
                    'Expires: ${DateFormat('dd MMM yyyy').format(doc.expiryDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isExpired || isExpiring ? FontWeight.w700 : FontWeight.w500,
                      color: isExpired
                          ? AppColors.critical
                          : isExpiring
                              ? AppColors.warning
                              : AppColors.secondaryText,
                    ),
                  ),
                if (!isFileAvailable)
                  const Text(
                    '[File missing on disk]',
                    style: TextStyle(fontSize: 11, color: AppColors.critical, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openDocumentPreview(BuildContext context, VehicleDocumentModel doc) {
    final file = File(doc.localFilePath);
    if (!file.existsSync()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('File Not Found'),
          content: Text(
            'The file "${doc.fileName}" could not be located in application storage.\n\nPath: ${doc.localFilePath}',
            style: const TextStyle(color: AppColors.secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (doc.isImage) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  child: Image.file(file),
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: Colors.black54),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      );
    } else if (doc.isPdf) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(doc.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('File: ${doc.fileName}', style: const TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 8),
              Text('Category: ${doc.category.label}', style: const TextStyle(color: AppColors.secondaryText)),
              if (doc.expiryDate != null) ...[
                const SizedBox(height: 8),
                Text('Expiry: ${DateFormat('dd MMMM yyyy').format(doc.expiryDate!)}',
                    style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(ctx);
                final bytes = await file.readAsBytes();
                await Printing.sharePdf(bytes: bytes, filename: doc.fileName);
              },
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text('Share / Open PDF'),
            ),
          ],
        ),
      );
    }
  }

  void _showAddDocumentDialog(BuildContext context, WidgetRef ref, String vehicleId) {
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DocumentCategory category = DocumentCategory.rc;
    DateTime? issueDate;
    DateTime? expiryDate;
    String? pickedFilePath;
    String? pickedFileName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Store Vehicle Document',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // File selector box
                InkWell(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (result != null && result.files.single.path != null) {
                      setModalState(() {
                        pickedFilePath = result.files.single.path!;
                        pickedFileName = result.files.single.name;
                        if (titleCtrl.text.isEmpty) {
                          titleCtrl.text = pickedFileName!.replaceAll(RegExp(r'\.[^.]+$'), '');
                        }
                      });
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: pickedFilePath != null ? AppColors.accent : AppColors.cardBorder,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          pickedFilePath != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                          color: pickedFilePath != null ? AppColors.accent : AppColors.tertiaryText,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pickedFileName ?? 'Tap to pick PDF, JPG, or PNG',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: pickedFilePath != null ? AppColors.accent : AppColors.secondaryText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
                    hintText: 'e.g. Registration Certificate, Insurance 2025',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DocumentCategory>(
                  initialValue: category,
                  decoration: const InputDecoration(labelText: 'Document Category'),
                  dropdownColor: AppColors.elevatedSurface,
                  items: DocumentCategory.values
                      .map((c) => DropdownMenuItem(value: c, child: Text(c.label, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: issueDate ?? DateTime.now(),
                            firstDate: DateTime(2010),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) setModalState(() => issueDate = picked);
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accent),
                        label: Text(
                          issueDate != null ? DateFormat('dd/MM/yyyy').format(issueDate!) : 'Issue Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: expiryDate ?? DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 15)),
                          );
                          if (picked != null) setModalState(() => expiryDate = picked);
                        },
                        icon: const Icon(Icons.event_busy_rounded, size: 16, color: AppColors.warning),
                        label: Text(
                          expiryDate != null ? DateFormat('dd/MM/yyyy').format(expiryDate!) : 'Expiry Date',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Policy No. (Optional)',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (pickedFilePath == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select a document file.')),
                        );
                        return;
                      }
                      if (titleCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a document title.')),
                        );
                        return;
                      }

                      try {
                        await ref.read(documentRepositoryProvider).addDocument(
                              vehicleId: vehicleId,
                              title: titleCtrl.text.trim(),
                              category: category,
                              sourceFilePath: pickedFilePath!,
                              issueDate: issueDate,
                              expiryDate: expiryDate,
                              notes: notesCtrl.text.trim().isNotEmpty ? notesCtrl.text.trim() : null,
                            );

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Document safely saved to encrypted local storage')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Store Document'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
