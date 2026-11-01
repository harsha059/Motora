import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interactive_3d/interactive_3d.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../home/presentation/widgets/quick_add_issue_sheet.dart';
import '../../issues/data/issue_repository.dart';
import '../domain/mesh_component_mapper.dart';
import 'widgets/component_selection_panel.dart';
import 'widgets/vehicle_3d_viewer.dart';

class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  final Interactive3dController _controller = Interactive3dController();

  String? _selectedMeshName;
  String? _selectedComponentId;

  // Local asset path configured in pubspec.yaml
  static const String _modelAssetPath = 'assets/models/car_concept.glb';

  void _onComponentSelected(String componentId, String meshName) {
    setState(() {
      _selectedComponentId = componentId;
      _selectedMeshName = meshName;
    });
  }

  void _onClearSelection() {
    setState(() {
      _selectedComponentId = null;
      _selectedMeshName = null;
    });
    _controller.clearSelections();
  }

  void _selectFromChip(String componentId) {
    final meshes = MeshComponentMapper.getMeshesForComponent(componentId);
    setState(() {
      _selectedComponentId = componentId;
      _selectedMeshName = meshes.isNotEmpty ? meshes.first : componentId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(allIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('MG Comet EV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText),
            tooltip: 'Model Information',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.elevatedSurface,
                  title: const Row(
                    children: [
                      Icon(Icons.view_in_ar_rounded, color: AppColors.accent),
                      SizedBox(width: 10),
                      Text('3D Vehicle Digital Twin', style: TextStyle(fontSize: 18, color: AppColors.primaryText)),
                    ],
                  ),
                  content: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sprint 1 Implementation Note:',
                        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.accent, fontSize: 13),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'This interactive 3D viewer is rendered using Google Filament on Android via the interactive_3d package.\n\n'
                        'The vehicle geometry utilizes an open-source Khronos Group automotive concept model with 101 distinct, independently named meshes mapped to MG Comet EV subcomponents (Powertrain, Brakes, Battery, Steering, Lighting, Doors, and Cockpit).\n\n'
                        'Touch Gestures:\n'
                        '• Single Finger: 360° Orbit & Rotate\n'
                        '• Pinch: Dynamic Zoom In/Out\n'
                        '• Tap Mesh: Select & Highlight Component',
                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Got It'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: issuesAsync.when(
          data: (allIssues) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3D Canvas Container
                  Container(
                    height: 340,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(
                        color: _selectedComponentId != null ? AppColors.accent : AppColors.cardBorder,
                        width: _selectedComponentId != null ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _selectedComponentId != null
                              ? AppColors.accent.withValues(alpha: 0.15)
                              : Colors.black.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Vehicle3dViewer(
                      modelAssetPath: _modelAssetPath,
                      controller: _controller,
                      selectedMeshName: _selectedMeshName,
                      onComponentSelected: _onComponentSelected,
                      onClearSelection: _onClearSelection,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Component Selection Panel
                  ComponentSelectionPanel(
                    selectedMeshName: _selectedMeshName,
                    selectedComponentId: _selectedComponentId,
                    allIssues: allIssues,
                    onClearSelection: _onClearSelection,
                    onResetCamera: () => _controller.resetCamera(),
                  ),
                  const SizedBox(height: 20),

                  // Quick Component Focus Chips
                  const Text(
                    'Quick Component Focus',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: VehicleComponentsCatalog.mgCometComponents.map((comp) {
                        final isSelected = _selectedComponentId == comp.id;
                        final compIssues = allIssues
                            .where((i) => i.componentId == comp.id && i.status != IssueStatus.resolved)
                            .length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => _selectFromChip(comp.id),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.accentDim : AppColors.elevatedSurface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? AppColors.accent : AppColors.cardBorder,
                                  width: isSelected ? 1.2 : 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    comp.icon,
                                    size: 15,
                                    color: isSelected ? AppColors.accent : AppColors.secondaryText,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    comp.name.split('(').first.trim(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? AppColors.accent : AppColors.primaryText,
                                    ),
                                  ),
                                  if (compIssues > 0) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.highDim,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '$compIssues',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.high,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Component Catalog with Issue Counts
                  const Text(
                    'All Vehicle Components',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tap any item to highlight in 3D and review associated telemetry.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 12),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: VehicleComponentsCatalog.mgCometComponents.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final comp = VehicleComponentsCatalog.mgCometComponents[index];
                      final isSelected = _selectedComponentId == comp.id;
                      final compIssues = allIssues
                          .where((i) => i.componentId == comp.id && i.status != IssueStatus.resolved)
                          .toList();

                      return GlassCard(
                        onTap: () => _selectFromChip(comp.id),
                        borderColor: isSelected ? AppColors.accent : AppColors.cardBorder,
                        backgroundColor: isSelected
                            ? AppColors.accentDim.withValues(alpha: 0.12)
                            : AppColors.surface,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: compIssues.isNotEmpty
                                    ? AppColors.high.withValues(alpha: 0.15)
                                    : AppColors.elevatedSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                comp.icon,
                                size: 18,
                                color: compIssues.isNotEmpty ? AppColors.high : AppColors.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    comp.name,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? AppColors.accent : AppColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comp.category,
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                                  ),
                                ],
                              ),
                            ),
                            if (compIssues.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.highDim,
                                  borderRadius: BorderRadius.circular(10),
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
                              icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.accent),
                              tooltip: 'Report issue for ${comp.name}',
                              onPressed: () {
                                QuickAddIssueSheet.show(context, initialComponentId: comp.id);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: AppColors.critical)),
          ),
        ),
      ),
    );
  }
}
