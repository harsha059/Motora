import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../data/service_repository.dart';
import '../domain/service_visit_model.dart';

class ServiceVisitDetailScreen extends ConsumerStatefulWidget {
  final String visitId;

  const ServiceVisitDetailScreen({super.key, required this.visitId});

  @override
  ConsumerState<ServiceVisitDetailScreen> createState() => _ServiceVisitDetailScreenState();
}

class _ServiceVisitDetailScreenState extends ConsumerState<ServiceVisitDetailScreen> {
  // Track technician edits locally per visit issue
  final Map<String, TextEditingController> _remarksControllers = {};
  final Map<String, TextEditingController> _workControllers = {};
  final Map<String, TextEditingController> _partsControllers = {};
  final Map<String, VisitIssueResolution> _resolutionStatuses = {};
  final Map<String, bool> _followUpRequiredMap = {};

  bool _isInitialized = false;

  @override
  void dispose() {
    for (final c in _remarksControllers.values) {
      c.dispose();
    }
    for (final c in _workControllers.values) {
      c.dispose();
    }
    for (final c in _partsControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _initControllers(List<ServiceVisitIssueModel> issues) {
    if (_isInitialized) return;
    for (final issue in issues) {
      _remarksControllers[issue.id] = TextEditingController(text: issue.technicianRemarks ?? '');
      _workControllers[issue.id] = TextEditingController(text: issue.workPerformed ?? '');
      _partsControllers[issue.id] = TextEditingController(text: issue.partsReplaced ?? '');
      _resolutionStatuses[issue.id] = issue.resolutionStatus;
      _followUpRequiredMap[issue.id] = issue.followUpRequired;
    }
    _isInitialized = true;
  }

  Future<void> _saveIssueFeedback(ServiceVisitIssueModel issue) async {
    final remarks = _remarksControllers[issue.id]?.text.trim();
    final work = _workControllers[issue.id]?.text.trim();
    final parts = _partsControllers[issue.id]?.text.trim();
    final resolution = _resolutionStatuses[issue.id] ?? VisitIssueResolution.notResolved;
    final followUp = _followUpRequiredMap[issue.id] ?? false;

    await ref.read(serviceRepositoryProvider).updateVisitIssueFeedback(
          visitIssueId: issue.id,
          technicianRemarks: remarks,
          workPerformed: work,
          partsReplaced: parts,
          resolutionStatus: resolution,
          followUpRequired: followUp,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Technician remarks updated'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _showCompleteVisitDialog(ServiceVisitModel visit, List<ServiceVisitIssueModel> issues) async {
    final techNameController = TextEditingController(text: visit.technicianName ?? '');
    final signOffController = TextEditingController(text: visit.signOffDetails ?? '');
    final costController = TextEditingController(text: visit.totalCost != null ? visit.totalCost!.toStringAsFixed(0) : '');

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.statusResolved.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.statusResolved, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete Service Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                        Text('Finalize technician observations & status', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              const Text('Attending Technician Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
              const SizedBox(height: 6),
              TextField(
                controller: techNameController,
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'e.g. Ramesh Kumar (EV Certified Technician)',
                ),
              ),
              const SizedBox(height: 14),

              const Text('Technician Sign-Off Notes / Job Card Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
              const SizedBox(height: 6),
              TextField(
                controller: signOffController,
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'e.g. JC-2024-9812 — Tested all systems OK',
                ),
              ),
              const SizedBox(height: 14),

              const Text('Total Service Cost (Optional ₹)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
              const SizedBox(height: 6),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                decoration: const InputDecoration(hintText: 'e.g. 1850'),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: AppColors.tertiaryText),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Disclaimer: This record represents local driver documentation. Typed sign-offs are for reference and not legally binding signatures.',
                        style: TextStyle(fontSize: 11, color: AppColors.tertiaryText, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Confirm & Finalize Visit', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      final totalCost = double.tryParse(costController.text.trim());
      await ref.read(serviceRepositoryProvider).completeServiceVisit(
            visitId: widget.visitId,
            technicianName: techNameController.text.trim(),
            signOffDetails: signOffController.text.trim().isNotEmpty ? signOffController.text.trim() : null,
            totalCost: totalCost,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.statusResolved,
            content: Text('Service Visit Completed! Master vehicle issues updated.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(serviceVisitDetailProvider(widget.visitId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service Centre Visit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.accent),
            tooltip: 'View & Share PDF Report',
            onPressed: () => context.push('/service/report/${widget.visitId}'),
          ),
        ],
      ),
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return const Center(child: Text('Visit record not found'));
            }

            final visit = detail.visit;
            final issues = detail.issues;
            _initControllers(issues);

            final isCompleted = visit.status == ServiceVisitStatus.completed;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Visit Banner
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: isCompleted ? AppColors.statusResolved.withValues(alpha: 0.4) : AppColors.accent,
                    gradient: AppColors.heroCardGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isCompleted ? AppColors.statusResolved.withValues(alpha: 0.2) : AppColors.accentDim,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCompleted ? AppColors.statusResolved : AppColors.accent,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                isCompleted ? 'VISIT COMPLETED' : 'SERVICE IN PROGRESS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isCompleted ? AppColors.statusResolved : AppColors.accent,
                                ),
                              ),
                            ),
                            Text(
                              DateFormat('dd MMM yyyy').format(visit.visitDate),
                              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          visit.serviceCentre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.speed_rounded, size: 15, color: AppColors.secondaryText),
                            const SizedBox(width: 6),
                            Text(
                              'Odometer: ${visit.odometerReading} km',
                              style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.electric_car_rounded, size: 15, color: AppColors.accent),
                            const SizedBox(width: 6),
                            const Text(
                              'MG Comet EV',
                              style: TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (visit.additionalRequests != null && visit.additionalRequests!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 6),
                          const Text('Additional Inspection Requests:', style: TextStyle(fontSize: 11, color: AppColors.tertiaryText, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(visit.additionalRequests!, style: const TextStyle(fontSize: 13, color: AppColors.primaryText)),
                        ],
                        if (isCompleted && visit.technicianName != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.badge_rounded, size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Text('Attending Tech: ${visit.technicianName}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryText)),
                            ],
                          ),
                          if (visit.signOffDetails != null) ...[
                            const SizedBox(height: 2),
                            Text('Sign-off Note: ${visit.signOffDetails}', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
                          ],
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // PDF Quick Action Bar
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/service/report/${widget.visitId}'),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: AppColors.accent),
                          label: const Text('Generate / Share PDF Report'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accentDim),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (!isCompleted) ...[
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _showCompleteVisitDialog(visit, issues),
                          icon: const Icon(Icons.check_circle_rounded, size: 18),
                          label: const Text('Complete Visit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.background,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Issues Included in Visit
                  Text(
                    'Included Issues & Technician Observations (${issues.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: issues.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      return _buildIssueFeedbackCard(issue, isCompleted);
                    },
                  ),

                  const SizedBox(height: 36),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.critical))),
        ),
      ),
    );
  }

  Widget _buildIssueFeedbackCard(ServiceVisitIssueModel issue, bool isVisitCompleted) {
    final comp = VehicleComponentsCatalog.getById(issue.componentId);
    final remarksController = _remarksControllers[issue.id] ?? TextEditingController();
    final workController = _workControllers[issue.id] ?? TextEditingController();
    final partsController = _partsControllers[issue.id] ?? TextEditingController();
    final currentResolution = _resolutionStatuses[issue.id] ?? issue.resolutionStatus;
    final currentFollowUp = _followUpRequiredMap[issue.id] ?? issue.followUpRequired;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              PriorityBadge(priority: issue.issuePriority, compact: true),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  comp.name,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildResolutionBadge(currentResolution),
            ],
          ),
          const SizedBox(height: 8),

          // Title & Description
          Text(
            issue.issueTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primaryText),
          ),
          if (issue.issueDescription.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(issue.issueDescription, style: const TextStyle(fontSize: 13, color: AppColors.secondaryText, height: 1.3)),
          ],

          // Attached Photos Thumbnails
          if (issue.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: issue.photoUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final file = File(issue.photoUrls[idx]);
                  if (!file.existsSync()) return const SizedBox.shrink();
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(file, width: 60, height: 60, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],

          const Divider(height: 24),

          // Technician Feedback Form Fields
          const Text('Technician Observations / Diagnosis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: remarksController,
            maxLines: 2,
            readOnly: isVisitCompleted,
            style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Record technician diagnosis and findings...',
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Work Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: workController,
                      readOnly: isVisitCompleted,
                      style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'e.g. Software re-flash, realignment...'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Parts Replaced', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: partsController,
                      readOnly: isVisitCompleted,
                      style: const TextStyle(color: AppColors.primaryText, fontSize: 13),
                      decoration: const InputDecoration(hintText: 'e.g. Bushing, none'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Resolution Radio Controls
          const Text('Issue Resolution Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildResolutionOption(issue.id, VisitIssueResolution.resolved, 'Resolved', AppColors.statusResolved, isVisitCompleted),
              _buildResolutionOption(issue.id, VisitIssueResolution.partiallyResolved, 'Partially Resolved', AppColors.statusInProgress, isVisitCompleted),
              _buildResolutionOption(issue.id, VisitIssueResolution.notResolved, 'Not Resolved', AppColors.critical, isVisitCompleted),
              _buildResolutionOption(issue.id, VisitIssueResolution.unableToInspect, 'Unable to Inspect', AppColors.low, isVisitCompleted),
            ],
          ),
          const SizedBox(height: 10),

          // Follow-up required switch
          Row(
            children: [
              Checkbox(
                value: currentFollowUp,
                activeColor: AppColors.accent,
                checkColor: AppColors.background,
                onChanged: isVisitCompleted
                    ? null
                    : (val) {
                        setState(() {
                          _followUpRequiredMap[issue.id] = val ?? false;
                        });
                      },
              ),
              const Expanded(
                child: Text('Further follow-up inspection required on next visit', style: TextStyle(fontSize: 12, color: AppColors.secondaryText)),
              ),
              if (!isVisitCompleted)
                TextButton(
                  onPressed: () => _saveIssueFeedback(issue),
                  child: const Text('Save Note', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResolutionBadge(VisitIssueResolution resolution) {
    Color color;
    String text;
    switch (resolution) {
      case VisitIssueResolution.resolved:
        color = AppColors.statusResolved;
        text = 'Resolved';
        break;
      case VisitIssueResolution.partiallyResolved:
        color = AppColors.statusInProgress;
        text = 'Partially';
        break;
      case VisitIssueResolution.notResolved:
        color = AppColors.critical;
        text = 'Unresolved';
        break;
      case VisitIssueResolution.unableToInspect:
        color = AppColors.low;
        text = 'Uninspected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildResolutionOption(String issueId, VisitIssueResolution target, String label, Color color, bool isReadOnly) {
    final current = _resolutionStatuses[issueId] ?? VisitIssueResolution.notResolved;
    final isSelected = current == target;

    return InkWell(
      onTap: isReadOnly
          ? null
          : () {
              setState(() {
                _resolutionStatuses[issueId] = target;
              });
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.elevatedSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 1.4 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
