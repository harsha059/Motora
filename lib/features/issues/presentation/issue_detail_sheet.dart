import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_pill.dart';
import '../data/attachment_repository.dart';
import '../data/issue_repository.dart';
import '../domain/issue_model.dart';
import 'widgets/photo_attachment_picker.dart';

class IssueDetailSheet extends ConsumerWidget {
  final IssueModel issue;

  const IssueDetailSheet({super.key, required this.issue});

  static Future<void> show(BuildContext context, IssueModel issue) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IssueDetailSheet(issue: issue),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final component = VehicleComponentsCatalog.getById(issue.componentId);
    final attachmentsAsync = ref.watch(issueAttachmentsProvider(issue.id));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        PriorityBadge(priority: issue.priority),
                        const SizedBox(width: 8),
                        StatusPill(status: issue.status),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.critical),
                    tooltip: 'Delete Issue',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppColors.elevatedSurface,
                          title: const Text('Delete Issue?', style: TextStyle(color: AppColors.primaryText)),
                          content: const Text(
                            'Are you sure you want to remove this issue report from your garage records?',
                            style: TextStyle(color: AppColors.secondaryText),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await ref.read(issueRepositoryProvider).deleteIssue(issue.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Issue removed from log')),
                          );
                        }
                      }
                    },
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Component Badge Card
                    GlassCard(
                      backgroundColor: AppColors.elevatedSurface,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentDim,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(component.icon, color: AppColors.accent, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  component.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'MG Comet EV • ${component.category}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Meta Row
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            backgroundColor: AppColors.elevatedSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('FIRST NOTICED', style: TextStyle(fontSize: 10, color: AppColors.tertiaryText, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM yyyy').format(issue.dateNoticed),
                                  style: const TextStyle(fontSize: 13, color: AppColors.primaryText, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassCard(
                            backgroundColor: AppColors.elevatedSurface,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('OCCURRENCE', style: TextStyle(fontSize: 10, color: AppColors.tertiaryText, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  issue.frequency.name.toUpperCase(),
                                  style: const TextStyle(fontSize: 13, color: AppColors.primaryText, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Description Section
                    const Text(
                      'Observations & Symptoms',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        issue.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primaryText,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Photo Attachments Section
                    attachmentsAsync.when(
                      data: (attachments) => PhotoAttachmentPicker(
                        attachments: attachments,
                        onPickImage: (source) async {
                          await ref.read(attachmentRepositoryProvider).captureAndSaveImage(
                                issueId: issue.id,
                                source: source,
                              );
                        },
                        onRemoveAttachment: (id) async {
                          await ref.read(attachmentRepositoryProvider).deleteAttachment(id);
                        },
                      ),
                      loading: () => const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),

                    // Past Technician History if any
                    if (issue.technicianRemarks != null && issue.technicianRemarks!.isNotEmpty) ...[
                      const Text(
                        'Past Technician Remarks',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorderActive),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.engineering_rounded, size: 16, color: AppColors.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Technician Diagnosis',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              issue.technicianRemarks!,
                              style: const TextStyle(fontSize: 13, color: AppColors.primaryText, height: 1.4),
                            ),
                            if (issue.resolutionNotes != null && issue.resolutionNotes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Divider(height: 1),
                              const SizedBox(height: 8),
                              Text(
                                'Work Performed: ${issue.resolutionNotes}',
                                style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Change Status Action
                    const Text(
                      'Update Issue Status',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusButton(context, ref, IssueStatus.open, 'Open', AppColors.statusOpen),
                        const SizedBox(width: 8),
                        _buildStatusButton(context, ref, IssueStatus.inProgress, 'In Progress', AppColors.statusInProgress),
                        const SizedBox(width: 8),
                        _buildStatusButton(context, ref, IssueStatus.resolved, 'Resolved', AppColors.statusResolved),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    WidgetRef ref,
    IssueStatus targetStatus,
    String label,
    Color color,
  ) {
    final isSelected = issue.status == targetStatus;
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? color.withValues(alpha: 0.18) : Colors.transparent,
          side: BorderSide(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: () async {
          await ref.read(issueRepositoryProvider).updateIssueStatus(issue.id, targetStatus);
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
