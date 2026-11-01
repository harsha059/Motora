import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../home/presentation/widgets/quick_add_issue_sheet.dart';
import '../../issues/data/issue_repository.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issuesAsync = ref.watch(allIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MG Comet EV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'MyGarage',
                applicationVersion: 'Sprint 0 Build',
                children: const [
                  Text('MG Comet EV Digital Twin & Component Diagnostics module.'),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3D Canvas Preview Card (Sprint 1 Ready)
              GlassCard(
                padding: const EdgeInsets.all(24),
                borderColor: AppColors.cardBorderActive,
                gradient: AppColors.heroCardGradient,
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.08),
                            border: Border.all(color: AppColors.accentDim, width: 1.5),
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.view_in_ar_rounded,
                            size: 50,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '3D Digital Twin Viewer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Interactive 3D GLB/GLTF renderer with 360° rotation, pinch-to-zoom, and component mesh inspection scheduled for Sprint 1.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.build_circle_rounded, size: 14, color: AppColors.accent),
                          SizedBox(width: 6),
                          Text(
                            'Sprint 1 Implementation Target',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Component Inspector Catalog
              const Text(
                'Component Architecture Catalog',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Select any vehicle component to view registered issues or log a new observation.',
                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
              ),
              const SizedBox(height: 14),

              issuesAsync.when(
                data: (issues) {
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: VehicleComponentsCatalog.mgCometComponents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final comp = VehicleComponentsCatalog.mgCometComponents[index];
                      final compIssues = issues
                          .where((i) => i.componentId == comp.id && i.status != IssueStatus.resolved)
                          .toList();

                      return GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: compIssues.isNotEmpty
                                    ? AppColors.high.withValues(alpha: 0.15)
                                    : AppColors.elevatedSurface,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                comp.icon,
                                size: 20,
                                color: compIssues.isNotEmpty ? AppColors.high : AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comp.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comp.category,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                            if (compIssues.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.highDim,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${compIssues.length} open',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.high,
                                  ),
                                ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, size: 20, color: AppColors.accent),
                              tooltip: 'Report issue for ${comp.name}',
                              onPressed: () {
                                QuickAddIssueSheet.show(context, initialComponentId: comp.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: const TextStyle(color: AppColors.critical)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
