import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/attachment_model.dart';

class PhotoAttachmentPicker extends StatelessWidget {
  final List<IssueAttachmentModel> attachments;
  final void Function(ImageSource source) onPickImage;
  final void Function(String attachmentId) onRemoveAttachment;

  const PhotoAttachmentPicker({
    super.key,
    required this.attachments,
    required this.onPickImage,
    required this.onRemoveAttachment,
  });

  void _showSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Attach Photo Evidence',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.accent, size: 20),
                ),
                title: const Text('Capture with Camera', style: TextStyle(color: AppColors.primaryText)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppColors.accent, size: 20),
                ),
                title: const Text('Select from Gallery', style: TextStyle(color: AppColors.primaryText)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onPickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(filePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(32),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_rounded, color: AppColors.critical, size: 48),
                      SizedBox(height: 12),
                      Text('Image file not found on device', style: TextStyle(color: AppColors.secondaryText)),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Photographic Evidence',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showSourceDialog(context),
              icon: const Icon(Icons.add_a_photo_rounded, size: 16),
              label: const Text('Add Photo', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (attachments.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.elevatedSurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.tertiaryText),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'No photos attached. Photos help technicians accurately diagnose symptoms.',
                    style: TextStyle(fontSize: 12, color: AppColors.tertiaryText),
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 85,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == attachments.length) {
                  return InkWell(
                    onTap: () => _showSourceDialog(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 85,
                      decoration: BoxDecoration(
                        color: AppColors.elevatedSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: AppColors.accent, size: 24),
                          SizedBox(height: 4),
                          Text('Add', style: TextStyle(fontSize: 11, color: AppColors.secondaryText)),
                        ],
                      ),
                    ),
                  );
                }

                final att = attachments[index];
                final file = File(att.localFilePath);
                final fileExists = file.existsSync();

                return Stack(
                  children: [
                    InkWell(
                      onTap: () => _showImagePreview(context, att.localFilePath),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 85,
                        height: 85,
                        decoration: BoxDecoration(
                          color: AppColors.elevatedSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: fileExists
                              ? Image.file(file, fit: BoxFit.cover)
                              : const Center(
                                  child: Icon(Icons.broken_image_rounded, color: AppColors.critical, size: 24),
                                ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => onRemoveAttachment(att.id),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
