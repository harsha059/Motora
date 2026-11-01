import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/vehicle_components.dart';
import '../../../../core/database/app_database.dart';
import '../../../issues/data/attachment_repository.dart';
import '../../../issues/data/issue_repository.dart';
import '../../../issues/domain/issue_model.dart';

class QuickAddIssueSheet extends ConsumerStatefulWidget {
  final String? initialComponentId;

  const QuickAddIssueSheet({super.key, this.initialComponentId});

  static Future<void> show(BuildContext context, {String? initialComponentId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickAddIssueSheet(initialComponentId: initialComponentId),
    );
  }

  @override
  ConsumerState<QuickAddIssueSheet> createState() => _QuickAddIssueSheetState();
}

class _QuickAddIssueSheetState extends ConsumerState<QuickAddIssueSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _selectedComponentId;
  IssuePriority _selectedPriority = IssuePriority.medium;
  IssueFrequency _selectedFrequency = IssueFrequency.sometimes;
  DateTime _dateNoticed = DateTime.now();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedComponentId = widget.initialComponentId ??
        VehicleComponentsCatalog.mgCometComponents.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  final List<XFile> _pendingPhotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _pendingPhotos.add(picked));
    }
  }

  void _removePhoto(int index) {
    setState(() => _pendingPhotos.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final issueId = const Uuid().v4();
      final newIssue = IssueModel(
        id: issueId,
        vehicleId: 'mg_comet_ev',
        componentId: _selectedComponentId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _selectedPriority,
        dateNoticed: _dateNoticed,
        frequency: _selectedFrequency,
        status: IssueStatus.open,
        createdAt: now,
        updatedAt: now,
      );

      await ref.read(issueRepositoryProvider).createIssue(newIssue);

      // Save all attached photos to persistent storage
      for (final photo in _pendingPhotos) {
        await ref.read(attachmentRepositoryProvider).saveDirectAttachment(
              issueId: issueId,
              sourceFilePath: photo.path,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.elevatedSurface,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Issue recorded for MG Comet EV',
                    style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.critical,
            content: Text('Failed to save issue: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
        border: Border(
          top: BorderSide(color: AppColors.cardBorder, width: 1.5),
          left: BorderSide(color: AppColors.cardBorder, width: 0.8),
          right: BorderSide(color: AppColors.cardBorder, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle & Header
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.accentDim,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_alert_rounded, color: AppColors.accent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Record Vehicle Issue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        Text(
                          'MG Comet EV • Service Log',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Input
                      const Text(
                        'Issue Title',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'e.g. Infotainment screen turns off intermittently',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please describe the issue title';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Component Selection
                      const Text(
                        'Vehicle Component',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedSurface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedComponentId,
                            isExpanded: true,
                            dropdownColor: AppColors.elevatedSurface,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accent),
                            items: VehicleComponentsCatalog.mgCometComponents.map((c) {
                              return DropdownMenuItem<String>(
                                value: c.id,
                                child: Row(
                                  children: [
                                    Icon(c.icon, size: 18, color: AppColors.accent),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(
                                          color: AppColors.primaryText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        c.category,
                                        style: const TextStyle(
                                          color: AppColors.secondaryText,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedComponentId = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Priority Selection
                      const Text(
                        'Priority Level',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: IssuePriority.values.map((priority) {
                          final isSelected = _selectedPriority == priority;
                          Color color;
                          String text;
                          switch (priority) {
                            case IssuePriority.critical:
                              color = AppColors.critical;
                              text = 'Critical';
                              break;
                            case IssuePriority.high:
                              color = AppColors.high;
                              text = 'High';
                              break;
                            case IssuePriority.medium:
                              color = AppColors.medium;
                              text = 'Medium';
                              break;
                            case IssuePriority.low:
                              color = AppColors.low;
                              text = 'Low';
                              break;
                          }
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: InkWell(
                                onTap: () => setState(() => _selectedPriority = priority),
                                borderRadius: BorderRadius.circular(8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? color.withValues(alpha: 0.2) : AppColors.elevatedSurface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? color : AppColors.cardBorder,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      text,
                                      style: TextStyle(
                                        color: isSelected ? color : AppColors.secondaryText,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),

                      // Frequency & Date Row
                      Row(
                        children: [
                          // Frequency
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Frequency',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.elevatedSurface,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<IssueFrequency>(
                                      value: _selectedFrequency,
                                      isExpanded: true,
                                      dropdownColor: AppColors.elevatedSurface,
                                      items: const [
                                        DropdownMenuItem(
                                          value: IssueFrequency.always,
                                          child: Text('Always', style: TextStyle(color: AppColors.primaryText, fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: IssueFrequency.sometimes,
                                          child: Text('Sometimes', style: TextStyle(color: AppColors.primaryText, fontSize: 13)),
                                        ),
                                        DropdownMenuItem(
                                          value: IssueFrequency.rarely,
                                          child: Text('Rarely', style: TextStyle(color: AppColors.primaryText, fontSize: 13)),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedFrequency = val);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Date First Noticed
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'First Noticed',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _dateNoticed,
                                      firstDate: DateTime(2022),
                                      lastDate: DateTime.now(),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: AppColors.accent,
                                              onPrimary: AppColors.background,
                                              surface: AppColors.surface,
                                              onSurface: AppColors.primaryText,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      setState(() => _dateNoticed = picked);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                                    decoration: BoxDecoration(
                                      color: AppColors.elevatedSurface,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accent),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            DateFormat('dd MMM yyyy').format(_dateNoticed),
                                            style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Description
                      const Text(
                        'Detailed Observations & Symptoms',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Add notes about vehicle speed, battery level, weather, or specific conditions when this occurs...',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please add a brief description';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Photo Attachments Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Attach Photographs',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.camera_alt_rounded, size: 20, color: AppColors.accent),
                                tooltip: 'Take Photo',
                                onPressed: () => _pickPhoto(ImageSource.camera),
                              ),
                              IconButton(
                                icon: const Icon(Icons.photo_library_rounded, size: 20, color: AppColors.accent),
                                tooltip: 'Pick from Gallery',
                                onPressed: () => _pickPhoto(ImageSource.gallery),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_pendingPhotos.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 75,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _pendingPhotos.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final photo = _pendingPhotos[index];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(photo.path),
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 3,
                                    right: 3,
                                    child: InkWell(
                                      onTap: () => _removePhoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black87,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.background,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text('Save Issue to Garage'),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
