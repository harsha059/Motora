import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../issues/domain/issue_model.dart';

class IssueSummaryCards extends StatelessWidget {
  final List<IssueModel> issues;
  final VoidCallback? onViewAllIssues;

  const IssueSummaryCards({
    super.key,
    required this.issues,
    this.onViewAllIssues,
  });

  @override
  Widget build(BuildContext context) {
    final openIssues = issues.where((i) => i.status != IssueStatus.resolved).toList();
    final criticalCount = openIssues.where((i) => i.priority == IssuePriority.critical).length;
    final highCount = openIssues.where((i) => i.priority == IssuePriority.high).length;

    return Row(
      children: [
        // Total Open Issues Card
        Expanded(
          flex: 4,
          child: GlassCard(
            onTap: onViewAllIssues,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            borderColor: openIssues.isEmpty ? AppColors.cardBorder : AppColors.cardBorderActive,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.accentDim,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.build_circle_rounded, color: AppColors.accent, size: 18),
                    ),
                    const Icon(Icons.arrow_forward_rounded, color: AppColors.tertiaryText, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${openIssues.length}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Active Issues',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Critical Severity Card
        Expanded(
          flex: 3,
          child: GlassCard(
            onTap: onViewAllIssues,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            borderColor: criticalCount > 0 ? AppColors.critical.withValues(alpha: 0.4) : AppColors.cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.dangerous_rounded, color: AppColors.critical, size: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  '$criticalCount',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: criticalCount > 0 ? AppColors.critical : AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Critical',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        // High Severity Card
        Expanded(
          flex: 3,
          child: GlassCard(
            onTap: onViewAllIssues,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            borderColor: highCount > 0 ? AppColors.high.withValues(alpha: 0.4) : AppColors.cardBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.high.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_rounded, color: AppColors.high, size: 18),
                ),
                const SizedBox(height: 12),
                Text(
                  '$highCount',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: highCount > 0 ? AppColors.high : AppColors.primaryText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'High Pri',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
