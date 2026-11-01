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
import '../domain/recurring_issue_detector.dart';
import 'widgets/photo_attachment_picker.dart';
import 'widgets/recurring_issue_suggestion_banner.dart';

class IssueDetailSheet extends ConsumerStatefulWidget {
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
  ConsumerState<IssueDetailSheet> createState() => _IssueDetailSheetState();
}

class _IssueDetailSheetState extends ConsumerState<IssueDetailSheet> {
  bool _dismissedRecurringSuggestion = false;

  void _showReopenDialog() {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.elevatedSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.replay_rounded, color: AppColors.medium, size: 24),
            SizedBox(width: 8),
            Text('Reopen Resolved Issue', style: TextStyle(color: AppColors.primaryText, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This issue will be marked as Open and flagged as Recurring. Historical service records and technician remarks will be preserved.',
              style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: noteController,
              maxLines: 2,
              style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
              decoration: const InputDecoration(
                labelText: 'Return Reason / Notes (optional)',
                hintText: 'e.g. Squeal returned after 800 km in wet weather',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.medium,
              foregroundColor: AppColors.background,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(issueRepositoryProvider).reopenIssue(
                    widget.issue.id,
                    reopenReason: noteController.text.trim(),
                  );
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppColors.elevatedSurface,
                    content: Text('Issue reopened as Recurring. Ready for upcoming service visit.'),
                  ),
                );
              }
            },
            child: const Text('Confirm & Reopen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final component = VehicleComponentsCatalog.getById(issue.componentId);
    final attachmentsAsync = ref.watch(issueAttachmentsProvider(issue.id));
    final historyAsync = ref.watch(issueServiceHistoryProvider(issue.id));
    final allIssuesAsync = ref.watch(allIssuesProvider);

    // Check for recurring candidate
    RecurringMatch? recurringMatch;
    if (!issue.isRecurring && !_dismissedRecurringSuggestion) {
      allIssuesAsync.whenData((allIssues) {
        recurringMatch = RecurringIssueDetector.detectRecurringCandidate(
          newTitle: issue.title,
          newComponentId: issue.componentId,
          excludeIssueId: issue.id,
          existingIssues: allIssues,
        );
      });
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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
            // Header: Badges & Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        PriorityBadge(priority: issue.priority),
                        StatusPill(status: issue.status),
                        if (issue.isRecurring)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.medium.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.medium, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.replay_rounded, size: 12, color: AppColors.medium),
                                SizedBox(width: 4),
                                Text(
                                  'RECURRING',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.medium,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
                    // Recurring Suggestion Banner if detected
                    if (recurringMatch != null) ...[
                      RecurringIssueSuggestionBanner(
                        match: recurringMatch!,
                        onLinkToPrevious: () async {
                          await ref.read(issueRepositoryProvider).markIssueAsRecurring(
                                issue.id,
                                parentIssueId: recurringMatch!.matchedIssue.id,
                              );
                          setState(() => _dismissedRecurringSuggestion = true);
                        },
                        onMarkRecurring: () async {
                          await ref.read(issueRepositoryProvider).markIssueAsRecurring(issue.id);
                          setState(() => _dismissedRecurringSuggestion = true);
                        },
                        onIgnore: () => setState(() => _dismissedRecurringSuggestion = true),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Title
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
                    const SizedBox(height: 16),

                    // Meta Info Cards
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
                                const Text('FREQUENCY', style: TextStyle(fontSize: 10, color: AppColors.tertiaryText, fontWeight: FontWeight.w700)),
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

                    // Past Technician Remarks
                    if (issue.technicianRemarks != null && issue.technicianRemarks!.isNotEmpty) ...[
                      const Text(
                        'Attending Technician Remarks',
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
                            const Row(
                              children: [
                                Icon(Icons.engineering_rounded, size: 16, color: AppColors.accent),
                                SizedBox(width: 8),
                                Text(
                                  'Technician Diagnosis',
                                  style: TextStyle(
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

                    // Previous Service Visits Section
                    historyAsync.when(
                      data: (historyRecords) {
                        if (historyRecords.isEmpty) return const SizedBox.shrink();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Service Visit Records',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...historyRecords.map((rec) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.elevatedSurface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rec.serviceCentre,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd MMM yyyy').format(rec.visitDate),
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.tertiaryText),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '${rec.odometerReading} km',
                                          style: const TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600),
                                        ),
                                        if (rec.technicianName != null) ...[
                                          const Text(' • ', style: TextStyle(color: AppColors.tertiaryText, fontSize: 11)),
                                          Text(
                                            rec.technicianName!,
                                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),

                    // Issue Lifecycle Timeline
                    const Text(
                      'Lifecycle Timeline',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTimeline(issue),
                    const SizedBox(height: 24),

                    // Reopen Action (for Resolved issues)
                    if (issue.status == IssueStatus.resolved) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showReopenDialog,
                          icon: const Icon(Icons.replay_rounded, size: 18),
                          label: const Text('Reopen Issue (Recurring Symptom)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.medium,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Update Issue Status Controls
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

  Widget _buildTimeline(IssueModel issue) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _buildTimelineStep(
            icon: Icons.flag_rounded,
            color: AppColors.accent,
            title: 'Reported by Car Owner',
            date: issue.createdAt,
            subtitle: 'Logged against ${VehicleComponentsCatalog.getById(issue.componentId).name}',
            isLast: issue.technicianRemarks == null && issue.status == IssueStatus.open,
          ),
          if (issue.technicianRemarks != null && issue.technicianRemarks!.isNotEmpty)
            _buildTimelineStep(
              icon: Icons.engineering_rounded,
              color: AppColors.statusInProgress,
              title: 'Technician Inspected & Diagnosed',
              date: issue.updatedAt,
              subtitle: issue.resolutionNotes ?? 'Remarks saved to visit record',
              isLast: issue.status != IssueStatus.resolved && !issue.isRecurring,
            ),
          if (issue.status == IssueStatus.resolved)
            _buildTimelineStep(
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              title: 'Resolution Completed',
              date: issue.updatedAt,
              subtitle: 'Marked resolved during vehicle service',
              isLast: !issue.isRecurring,
            ),
          if (issue.isRecurring)
            _buildTimelineStep(
              icon: Icons.replay_rounded,
              color: AppColors.medium,
              title: 'Recurring Incident Logged',
              date: issue.updatedAt,
              subtitle: 'Preserved historical service context',
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required Color color,
    required String title,
    required DateTime date,
    required String subtitle,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(icon, size: 14, color: color),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: AppColors.cardBorder,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                    Text(DateFormat('dd MMM yy').format(date), style: const TextStyle(fontSize: 11, color: AppColors.tertiaryText)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.secondaryText)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    WidgetRef ref,
    IssueStatus targetStatus,
    String label,
    Color color,
  ) {
    final isSelected = widget.issue.status == targetStatus;
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
          await ref.read(issueRepositoryProvider).updateIssueStatus(widget.issue.id, targetStatus);
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
