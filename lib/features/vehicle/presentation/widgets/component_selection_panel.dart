import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/vehicle_components.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../home/presentation/widgets/quick_add_issue_sheet.dart';
import '../../../issues/domain/issue_model.dart';
import '../../../issues/presentation/issue_detail_sheet.dart';

class ComponentSelectionPanel extends StatelessWidget {
  final String? selectedMeshName;
  final String? selectedComponentId;
  final List<IssueModel> allIssues;
  final VoidCallback onClearSelection;
  final VoidCallback? onResetCamera;

  const ComponentSelectionPanel({
    super.key,
    required this.selectedMeshName,
    required this.selectedComponentId,
    required this.allIssues,
    required this.onClearSelection,
    this.onResetCamera,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedComponentId == null) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderColor: AppColors.cardBorder,
        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentDim,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.touch_app_rounded, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Interactive 3D Mesh Inspection',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap wheels, battery, doors or cockpit to inspect and log issues.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (onResetCamera != null)
              IconButton(
                icon: const Icon(Icons.center_focus_strong_rounded, color: AppColors.secondaryText, size: 20),
                tooltip: 'Reset Camera View',
                onPressed: onResetCamera,
              ),
          ],
        ),
      );
    }

    final component = VehicleComponentsCatalog.getById(selectedComponentId!);
    final componentIssues = allIssues
        .where((i) => i.componentId == selectedComponentId && i.status != IssueStatus.resolved)
        .toList();

    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.accent,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentDim,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(component.icon, color: AppColors.accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            component.name,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.elevatedSurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            component.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '3D Mesh: ${selectedMeshName ?? selectedComponentId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.tertiaryText,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText, size: 20),
                tooltip: 'Deselect',
                onPressed: onClearSelection,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Issues on this component
          if (componentIssues.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevatedSurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.statusResolved, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'No open issues registered for this component',
                    style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                  ),
                ],
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${componentIssues.length} Active Issue(s) on this Component:',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.high,
                  ),
                ),
                const SizedBox(height: 6),
                ...componentIssues.take(2).map((issue) {
                  return InkWell(
                    onTap: () => IssueDetailSheet.show(context, issue),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          PriorityBadge(priority: issue.priority, compact: true),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              issue.title,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.primaryText,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.tertiaryText),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          const SizedBox(height: 14),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                QuickAddIssueSheet.show(context, initialComponentId: selectedComponentId);
              },
              icon: const Icon(Icons.add_alert_rounded, size: 18),
              label: Text('Report Issue on ${component.category}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
