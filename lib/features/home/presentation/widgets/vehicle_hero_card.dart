import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class VehicleHeroCard extends StatelessWidget {
  final VoidCallback? onInspect3D;
  final int openIssuesCount;
  final String? lastServiceVisitText;
  final String? nextServiceReminderText;

  const VehicleHeroCard({
    super.key,
    this.onInspect3D,
    this.openIssuesCount = 0,
    this.lastServiceVisitText,
    this.nextServiceReminderText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onInspect3D,
      padding: const EdgeInsets.all(20),
      gradient: AppColors.heroCardGradient,
      borderColor: AppColors.cardBorderActive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: AppColors.accent),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE VEHICLE',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              // Outstanding Issues Count Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: openIssuesCount > 0
                      ? AppColors.high.withValues(alpha: 0.15)
                      : AppColors.accentDim.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: openIssuesCount > 0
                        ? AppColors.high.withValues(alpha: 0.4)
                        : AppColors.accent.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      openIssuesCount > 0 ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                      size: 13,
                      color: openIssuesCount > 0 ? AppColors.high : AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      openIssuesCount > 0 ? '$openIssuesCount Outstanding' : 'All Clear',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: openIssuesCount > 0 ? AppColors.high : AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title & Model Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MG Comet EV',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plush Edition • Dual Screen Cockpit',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              // Car Icon / Emblem badge
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.elevatedSurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: const Center(
                  child: Icon(
                    Icons.electric_car_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Service Schedule & Telemetry Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.cardBorder, width: 0.8),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    const Text(
                      'Last Service: ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                    ),
                    Expanded(
                      child: Text(
                        lastServiceVisitText ?? 'None logged yet',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event_note_rounded, size: 16, color: AppColors.statusInProgress),
                    const SizedBox(width: 8),
                    const Text(
                      'Next Service: ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
                    ),
                    Expanded(
                      child: Text(
                        nextServiceReminderText ?? '10,000 km / 1st Year Annual EV Inspection',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3D Vehicle Inspection Call-to-action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentDim.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.view_in_ar_rounded, color: AppColors.accent, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Interactive 3D Digital Twin',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        'Tap to rotate, zoom & inspect 101 vehicle components',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accent, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
