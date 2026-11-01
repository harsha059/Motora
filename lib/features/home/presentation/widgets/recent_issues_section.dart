import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/vehicle_components.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../issues/domain/issue_model.dart';
import '../../../issues/presentation/issue_detail_sheet.dart';

class RecentIssuesSection extends StatelessWidget {
  final List<IssueModel> issues;
  final VoidCallback onViewAll;
  final VoidCallback onQuickAdd;

  const RecentIssuesSection({
    super.key,
    required this.issues,
    required this.onViewAll,
    required this.onQuickAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Observations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
                color: AppColors.primaryText,
              ),
            ),
            if (issues.isNotEmpty)
              TextButton(
                onPressed: onViewAll,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All'),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        if (issues.isEmpty)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.elevatedSurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No issues reported',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Your MG Comet EV has a clean bill of health.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onQuickAdd,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Record First Issue'),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: issues.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final issue = issues[index];
              final component = VehicleComponentsCatalog.getById(issue.componentId);

              return GlassCard(
                onTap: () => IssueDetailSheet.show(context, issue),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Priority & Status & Date
                    Row(
                      children: [
                        PriorityBadge(priority: issue.priority, compact: true),
                        const SizedBox(width: 8),
                        StatusPill(status: issue.status),
                        const Spacer(),
                        Text(
                          DateFormat('dd MMM').format(issue.dateNoticed),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.tertiaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      issue.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Component Tag
                    Row(
                      children: [
                        Icon(component.icon, size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            component.name,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.tertiaryText),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
