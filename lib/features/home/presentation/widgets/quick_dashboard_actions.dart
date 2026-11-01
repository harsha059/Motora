import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';

class QuickDashboardActions extends StatelessWidget {
  final VoidCallback onLogIssue;
  final VoidCallback onPrepareService;

  const QuickDashboardActions({
    super.key,
    required this.onLogIssue,
    required this.onPrepareService,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. Log Issue Action
        Expanded(
          child: GlassCard(
            onTap: onLogIssue,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            borderColor: AppColors.accent.withValues(alpha: 0.5),
            gradient: LinearGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.16),
                AppColors.elevatedSurface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppColors.background,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Log Issue',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        'Photo & Symptom',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. Prepare for Service Action
        Expanded(
          child: GlassCard(
            onTap: onPrepareService,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            borderColor: AppColors.cardBorderActive,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Icon(
                    Icons.checklist_rtl_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Prepare Visit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        'Service Checklist',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
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
