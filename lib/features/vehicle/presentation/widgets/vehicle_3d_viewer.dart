import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:interactive_3d/interactive_3d.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/mesh_component_mapper.dart';

class Vehicle3dViewer extends StatefulWidget {
  final String modelAssetPath;
  final String? selectedMeshName;
  final void Function(String componentId, String meshName) onComponentSelected;
  final VoidCallback onClearSelection;
  final Interactive3dController? controller;

  const Vehicle3dViewer({
    super.key,
    required this.modelAssetPath,
    required this.onComponentSelected,
    required this.onClearSelection,
    this.selectedMeshName,
    this.controller,
  });

  @override
  State<Vehicle3dViewer> createState() => _Vehicle3dViewerState();
}

class _Vehicle3dViewerState extends State<Vehicle3dViewer> {
  late final Interactive3dController _internalController;
  Interactive3dController get _effectiveController => widget.controller ?? _internalController;

  bool _isModelLoaded = false;
  String? _loadError;

  // Solid background matching #0B1017
  static const List<double> _backgroundColor = [0.043, 0.063, 0.090, 1.0];
  // Accent glow color #36E1BD (RGBA 0.0-1.0)
  static const List<double> _selectionColor = [0.21, 0.88, 0.74, 1.0];

  @override
  void initState() {
    super.initState();
    _internalController = Interactive3dController();
  }

  void _handleSelectionChanged(List<EntityData> entities) {
    if (entities.isEmpty) {
      widget.onClearSelection();
      return;
    }

    final tapped = entities.last;
    final componentId = MeshComponentMapper.mapMeshToComponentId(tapped.name);
    widget.onComponentSelected(componentId, tapped.name);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Stack(
        children: [
          // 3D Canvas
          Interactive3d(
            controller: _effectiveController,
            modelPath: widget.modelAssetPath,
            solidBackgroundColor: _backgroundColor,
            selectionColor: _selectionColor,
            defaultZoom: 1.0,
            onSelectionChanged: _handleSelectionChanged,
            onModelLoaded: () {
              if (mounted) {
                setState(() {
                  _isModelLoaded = true;
                  _loadError = null;
                });
              }
            },
            onModelLoadError: (error, stack) {
              if (kDebugMode) {
                print('3D Model load error: $error\n$stack');
              }
              if (mounted) {
                setState(() {
                  _loadError = error.toString();
                });
              }
            },
            loadingWidget: _buildLoadingWidget(),
            errorBuilder: (context, error) => _buildErrorWidget(error.toString()),
          ),

          // Prototype Badge (Honest labeling as requested)
          Positioned(
            top: 12,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 0.8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.view_in_ar_rounded, size: 13, color: AppColors.accent),
                  SizedBox(width: 5),
                  Text(
                    'MG Comet EV • 3D Prototype',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Camera Zoom & Reset Controls
          if (_isModelLoaded && _loadError == null)
            Positioned(
              top: 12,
              right: 14,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primaryText),
                      tooltip: 'Zoom In',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () => _effectiveController.zoomBy(0.25),
                    ),
                    Container(height: 1, width: 24, color: AppColors.cardBorder),
                    IconButton(
                      icon: const Icon(Icons.remove_rounded, size: 18, color: AppColors.primaryText),
                      tooltip: 'Zoom Out',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () => _effectiveController.zoomBy(-0.25),
                    ),
                    Container(height: 1, width: 24, color: AppColors.cardBorder),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, size: 18, color: AppColors.accent),
                      tooltip: 'Reset View',
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                      onPressed: () => _effectiveController.resetCamera(),
                    ),
                  ],
                ),
              ),
            ),

          // Gesture Hint
          if (_isModelLoaded && _loadError == null)
            Positioned(
              bottom: 12,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_outlined, size: 12, color: AppColors.secondaryText),
                    SizedBox(width: 4),
                    Text(
                      'Drag: Rotate • Pinch: Zoom',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.secondaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accentDim,
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading 3D Digital Twin...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Initializing Google Filament Engine',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.critical, size: 36),
            const SizedBox(height: 12),
            const Text(
              '3D View Unavailable',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
