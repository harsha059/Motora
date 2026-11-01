import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../data/service_repository.dart';
import '../domain/pdf_report_generator.dart';

class ServiceReportPdfScreen extends ConsumerWidget {
  final String visitId;

  const ServiceReportPdfScreen({super.key, required this.visitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(serviceVisitDetailProvider(visitId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('PDF Service Report'),
      ),
      body: SafeArea(
        child: detailAsync.when(
          data: (detail) {
            if (detail == null) {
              return const Center(child: Text('Visit detail record not found'));
            }

            return PdfPreview(
              maxPageWidth: 700,
              build: (format) async {
                final doc = await PdfReportGenerator.generateReport(detail: detail);
                return doc.save();
              },
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: 'MYGARAGE_SERVICE_REPORT_${detail.visit.odometerReading}KM.pdf',
              loadingWidget: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 12),
                    Text('Compiling PDF Service Report...', style: TextStyle(color: AppColors.secondaryText)),
                  ],
                ),
              ),
              allowPrinting: true,
              allowSharing: true,
              actions: [
                PdfPreviewAction(
                  icon: const Icon(Icons.share_rounded, color: AppColors.accent),
                  onPressed: (context, build, pageFormat) async {
                    final bytes = await build(pageFormat);
                    await Printing.sharePdf(
                      bytes: bytes,
                      filename: 'MYGARAGE_SERVICE_REPORT_${detail.visit.odometerReading}KM.pdf',
                    );
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accent)),
          error: (e, _) => Center(child: Text('Error generating PDF: $e', style: const TextStyle(color: AppColors.critical))),
        ),
      ),
    );
  }
}
