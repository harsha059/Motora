import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../database/app_database.dart';

class StatusPill extends StatelessWidget {
  final IssueStatus status;

  const StatusPill({
    super.key,
    required this.status,
  });

  Color get color {
    switch (status) {
      case IssueStatus.open:
        return AppColors.statusOpen;
      case IssueStatus.inProgress:
        return AppColors.statusInProgress;
      case IssueStatus.resolved:
        return AppColors.statusResolved;
    }
  }

  String get label {
    switch (status) {
      case IssueStatus.open:
        return 'Open';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
