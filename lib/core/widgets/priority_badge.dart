import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../database/app_database.dart';

class PriorityBadge extends StatelessWidget {
  final IssuePriority priority;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.compact = false,
  });

  Color get color {
    switch (priority) {
      case IssuePriority.critical:
        return AppColors.critical;
      case IssuePriority.high:
        return AppColors.high;
      case IssuePriority.medium:
        return AppColors.medium;
      case IssuePriority.low:
        return AppColors.low;
    }
  }

  String get label {
    switch (priority) {
      case IssuePriority.critical:
        return 'CRITICAL';
      case IssuePriority.high:
        return 'HIGH';
      case IssuePriority.medium:
        return 'MEDIUM';
      case IssuePriority.low:
        return 'LOW';
    }
  }

  IconData get icon {
    switch (priority) {
      case IssuePriority.critical:
        return Icons.error_outline_rounded;
      case IssuePriority.high:
        return Icons.warning_amber_rounded;
      case IssuePriority.medium:
        return Icons.info_outline_rounded;
      case IssuePriority.low:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 9.5 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
