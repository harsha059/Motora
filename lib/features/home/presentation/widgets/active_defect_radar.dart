import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/vehicle_components.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../issues/domain/issue_model.dart';

class ActiveDefectRadar extends StatelessWidget {
  final List<IssueModel> allIssues;
  final ValueChanged<IssuePriority>? onPriorityTap;

  const ActiveDefectRadar({
    super.key,
    required this.allIssues,
    this.onPriorityTap,
  });

  @override
  Widget build(BuildContext context) {
    // Open / in-progress issues only
    final activeIssues = allIssues.where((i) => i.status != IssueStatus.resolved).toList();

    final criticalIssues = activeIssues.where((i) => i.priority == IssuePriority.critical).toList();
    final highIssues = activeIssues.where((i) => i.priority == IssuePriority.high).toList();
    final mediumIssues = activeIssues.where((i) => i.priority == IssuePriority.medium).toList();
    final lowIssues = activeIssues.where((i) => i.priority == IssuePriority.low).toList();

    final totalActive = activeIssues.length;

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderColor: totalActive > 0
          ? (criticalIssues.isNotEmpty ? AppColors.critical.withValues(alpha: 0.4) : AppColors.cardBorderActive)
          : AppColors.cardBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radar Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: criticalIssues.isNotEmpty
                          ? AppColors.critical
                          : (totalActive > 0 ? AppColors.accent : const Color(0xFF10B981)),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (criticalIssues.isNotEmpty ? AppColors.critical : AppColors.accent).withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ACTIVE DEFECT RADAR',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: totalActive > 0 ? AppColors.elevatedSurface : AppColors.accentDim.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: totalActive > 0 ? AppColors.cardBorder : AppColors.accent.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  totalActive == 0
                      ? 'ALL SYSTEMS NOMINAL'
                      : '$totalActive ${totalActive == 1 ? 'DEFECT' : 'DEFECTS'} LOGGED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: totalActive == 0 ? AppColors.accent : AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Horizontal Segmented Severity Bar
          _buildSegmentedSeverityBar(
            total: totalActive,
            criticalCount: criticalIssues.length,
            highCount: highIssues.length,
            mediumCount: mediumIssues.length,
            lowCount: lowIssues.length,
          ),
          const SizedBox(height: 16),

          // Priority Summaries with Component Names
          if (totalActive == 0)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 20, color: Color(0xFF10B981)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'No outstanding vehicle defects. MG Comet EV is in pristine operating order.',
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (criticalIssues.isNotEmpty)
              _buildPriorityRow(
                priority: IssuePriority.critical,
                count: criticalIssues.length,
                issues: criticalIssues,
                color: AppColors.critical,
                label: 'Critical',
              ),
            if (highIssues.isNotEmpty)
              _buildPriorityRow(
                priority: IssuePriority.high,
                count: highIssues.length,
                issues: highIssues,
                color: AppColors.high,
                label: 'High',
              ),
            if (mediumIssues.isNotEmpty)
              _buildPriorityRow(
                priority: IssuePriority.medium,
                count: mediumIssues.length,
                issues: mediumIssues,
                color: AppColors.medium,
                label: 'Medium',
              ),
            if (lowIssues.isNotEmpty)
              _buildPriorityRow(
                priority: IssuePriority.low,
                count: lowIssues.length,
                issues: lowIssues,
                color: AppColors.low,
                label: 'Low',
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentedSeverityBar({
    required int total,
    required int criticalCount,
    required int highCount,
    required int mediumCount,
    required int lowCount,
  }) {
    if (total == 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Container(
          height: 10,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00A884), Color(0xFF36E1BD)],
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 10,
        width: double.infinity,
        color: AppColors.elevatedSurface,
        child: Row(
          children: [
            if (criticalCount > 0)
              Expanded(
                flex: criticalCount,
                child: Container(color: AppColors.critical),
              ),
            if (highCount > 0)
              Expanded(
                flex: highCount,
                child: Container(color: AppColors.high),
              ),
            if (mediumCount > 0)
              Expanded(
                flex: mediumCount,
                child: Container(color: AppColors.medium),
              ),
            if (lowCount > 0)
              Expanded(
                flex: lowCount,
                child: Container(color: AppColors.low),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityRow({
    required IssuePriority priority,
    required int count,
    required List<IssueModel> issues,
    required Color color,
    required String label,
  }) {
    // Unique component names
    final compNames = issues
        .map((i) => VehicleComponentsCatalog.getById(i.componentId).name)
        .toSet()
        .toList();

    final componentSummary = compNames.join(', ');

    return InkWell(
      onTap: () => onPriorityTap?.call(priority),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              '$count $label',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '—',
              style: TextStyle(color: AppColors.tertiaryText, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                componentSummary,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.tertiaryText),
          ],
        ),
      ),
    );
  }
}
