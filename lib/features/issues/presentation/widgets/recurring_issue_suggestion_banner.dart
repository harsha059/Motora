import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/recurring_issue_detector.dart';

class RecurringIssueSuggestionBanner extends StatelessWidget {
  final RecurringMatch match;
  final VoidCallback onLinkToPrevious;
  final VoidCallback onMarkRecurring;
  final VoidCallback onIgnore;

  const RecurringIssueSuggestionBanner({
    super.key,
    required this.match,
    required this.onLinkToPrevious,
    required this.onMarkRecurring,
    required this.onIgnore,
  });

  @override
  Widget build(BuildContext context) {
    final prior = match.matchedIssue;
    final dateStr = match.previousServiceDate != null
        ? DateFormat('dd MMM yyyy').format(match.previousServiceDate!)
        : 'Prior record';

    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.medium.withValues(alpha: 0.6),
      gradient: LinearGradient(
        colors: [
          AppColors.medium.withValues(alpha: 0.12),
          AppColors.elevatedSurface,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Warning / Replay Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.medium.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.replay_rounded, color: AppColors.medium, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible Recurring Issue Detected',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.medium,
                        letterSpacing: 0.1,
                      ),
                    ),
                    Text(
                      'Symptoms match a previously serviced defect on this component',
                      style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.tertiaryText),
                tooltip: 'Dismiss suggestion',
                onPressed: onIgnore,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Context Details Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.cardBorder, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        prior.title,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        '${match.previousOccurrences} prior on component',
                        style: const TextStyle(fontSize: 10, color: AppColors.accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$dateStr • ',
                      style: const TextStyle(fontSize: 11, color: AppColors.tertiaryText),
                    ),
                    Text(
                      match.previousResolutionStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: match.matchedIssue.status == IssueStatus.resolved
                            ? AppColors.accent
                            : AppColors.high,
                      ),
                    ),
                  ],
                ),
                if (match.previousTechnicianRemarks != null && match.previousTechnicianRemarks!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Prior Tech Observation: "${match.previousTechnicianRemarks}"',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.secondaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Link to Previous, Mark Recurring, Ignore
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              OutlinedButton.icon(
                onPressed: onLinkToPrevious,
                icon: const Icon(Icons.link_rounded, size: 14, color: AppColors.medium),
                label: const Text('Link to Prior Issue', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.medium,
                  side: const BorderSide(color: AppColors.medium, width: 1.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              ElevatedButton.icon(
                onPressed: onMarkRecurring,
                icon: const Icon(Icons.repeat_rounded, size: 14),
                label: const Text('Mark as Recurring', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.medium,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              TextButton(
                onPressed: onIgnore,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.secondaryText,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Ignore', style: TextStyle(fontSize: 11.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
