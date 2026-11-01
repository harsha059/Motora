import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import 'service_visit_model.dart';

class PdfReportGenerator {
  PdfReportGenerator._();

  static Future<pw.Document> generateReport({
    required ServiceVisitDetailModel detail,
  }) async {
    final pdf = pw.Document();
    final visit = detail.visit;
    final issues = detail.issues;

    final dateFormat = DateFormat('dd MMMM yyyy');
    final formattedDate = dateFormat.format(visit.visitDate);

    // Color definitions
    const primaryColor = PdfColor.fromInt(0xFF0B1017);
    const accentColor = PdfColor.fromInt(0xFF00A884);
    const lightGrey = PdfColor.fromInt(0xFFF1F5F9);
    const textDark = PdfColor.fromInt(0xFF1E293B);
    const textMuted = PdfColor.fromInt(0xFF64748B);
    const borderGrey = PdfColor.fromInt(0xFFCBD5E1);

    // Summary counts
    final totalCount = issues.length;
    final resolvedCount = issues.where((i) => i.resolutionStatus == VisitIssueResolution.resolved).length;
    final partiallyResolvedCount = issues.where((i) => i.resolutionStatus == VisitIssueResolution.partiallyResolved).length;
    final unresolvedCount = issues.where((i) => i.resolutionStatus == VisitIssueResolution.notResolved || i.resolutionStatus == VisitIssueResolution.unableToInspect).length;

    final criticalCount = issues.where((i) => i.issuePriority == IssuePriority.critical).length;
    final highCount = issues.where((i) => i.issuePriority == IssuePriority.high).length;
    final mediumCount = issues.where((i) => i.issuePriority == IssuePriority.medium).length;
    final lowCount = issues.where((i) => i.issuePriority == IssuePriority.low).length;

    // Load photo images safely
    final Map<String, List<pw.MemoryImage>> issueImages = {};
    for (final issue in issues) {
      final List<pw.MemoryImage> validImages = [];
      for (final path in issue.photoUrls) {
        try {
          final file = File(path);
          if (file.existsSync()) {
            final bytes = file.readAsBytesSync();
            validImages.add(pw.MemoryImage(bytes));
          }
        } catch (_) {}
      }
      issueImages[issue.id] = validImages;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(visit, formattedDate, primaryColor, accentColor, textMuted),
        footer: (context) => _buildFooter(context, textMuted),
        build: (context) => [
          // Vehicle & Service Overview Box
          _buildOverviewSection(visit, formattedDate, textDark, textMuted, lightGrey, borderGrey, accentColor),
          pw.SizedBox(height: 16),

          // Issues Summary & Priority Distribution
          _buildSummaryStats(totalCount, resolvedCount, partiallyResolvedCount, unresolvedCount, criticalCount, highCount, mediumCount, lowCount, lightGrey, borderGrey, textDark, textMuted),
          pw.SizedBox(height: 20),

          // Detailed Issues List
          pw.Text(
            'DETAILED ISSUE INSPECTION & TECHNICIAN FINDINGS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: textDark,
              letterSpacing: 0.5,
            ),
          ),
          pw.Divider(thickness: 1, color: borderGrey),
          pw.SizedBox(height: 8),

          ...issues.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final issue = entry.value;
            final images = issueImages[issue.id] ?? [];
            return _buildIssueItem(index, issue, images, textDark, textMuted, lightGrey, borderGrey, accentColor);
          }),

          pw.SizedBox(height: 16),

          // Additional Requests Section
          if (visit.additionalRequests != null && visit.additionalRequests!.trim().isNotEmpty) ...[
            _buildAdditionalRequests(visit.additionalRequests!, textDark, textMuted, lightGrey, borderGrey),
            pw.SizedBox(height: 16),
          ],

          // Technician Sign-off & Disclaimer
          _buildSignOffSection(visit, textDark, textMuted, lightGrey, borderGrey),
        ],
      ),
    );

    return pdf;
  }

  static pw.Widget _buildHeader(
    ServiceVisitModel visit,
    String formattedDate,
    PdfColor primaryColor,
    PdfColor accentColor,
    PdfColor textMuted,
  ) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 1.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MYGARAGE - VEHICLE SERVICE REPORT',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Personal Maintenance & Technician Consultation Record',
                style: pw.TextStyle(fontSize: 9, color: textMuted),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'MG Comet EV',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: accentColor),
              ),
              pw.Text(
                'Date: $formattedDate',
                style: pw.TextStyle(fontSize: 9, color: textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOverviewSection(
    ServiceVisitModel visit,
    String formattedDate,
    PdfColor textDark,
    PdfColor textMuted,
    PdfColor lightGrey,
    PdfColor borderGrey,
    PdfColor accentColor,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        children: [
          pw.Row(
            children: [
              _buildMetaField('VEHICLE', 'MG Comet EV (Plush)', textDark, textMuted),
              _buildMetaField('SERVICE CENTRE', visit.serviceCentre, textDark, textMuted),
              _buildMetaField('ODOMETER', '${visit.odometerReading} km', textDark, textMuted),
              _buildMetaField('VISIT STATUS', visit.status.name.toUpperCase(), textDark, textMuted),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetaField(String label, String value, PdfColor textDark, PdfColor textMuted) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textMuted)),
          pw.SizedBox(height: 2),
          pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryStats(
    int totalCount,
    int resolvedCount,
    int partiallyResolvedCount,
    int unresolvedCount,
    int criticalCount,
    int highCount,
    int mediumCount,
    int lowCount,
    PdfColor lightGrey,
    PdfColor borderGrey,
    PdfColor textDark,
    PdfColor textMuted,
  ) {
    return pw.Row(
      children: [
        // Resolution Stats Box
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: borderGrey, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RESOLUTION SUMMARY', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted)),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill('Total Issues', '$totalCount', textDark),
                    _buildStatPill('Resolved', '$resolvedCount', const PdfColor.fromInt(0xFF10B981)),
                    _buildStatPill('Partially', '$partiallyResolvedCount', const PdfColor.fromInt(0xFF3B82F6)),
                    _buildStatPill('Unresolved', '$unresolvedCount', const PdfColor.fromInt(0xFFEF4444)),
                  ],
                ),
              ],
            ),
          ),
        ),
        pw.SizedBox(width: 10),
        // Priority Distribution Box
        pw.Expanded(
          flex: 5,
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: borderGrey, width: 0.8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('SEVERITY DISTRIBUTION', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: textMuted)),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatPill('Critical', '$criticalCount', const PdfColor.fromInt(0xFFEF4444)),
                    _buildStatPill('High', '$highCount', const PdfColor.fromInt(0xFFF97316)),
                    _buildStatPill('Medium', '$mediumCount', const PdfColor.fromInt(0xFFFBBF24)),
                    _buildStatPill('Low', '$lowCount', const PdfColor.fromInt(0xFF64748B)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildStatPill(String label, String count, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(count, style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: color)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: PdfColor.fromInt(0xFF64748B))),
      ],
    );
  }

  static pw.Widget _buildIssueItem(
    int index,
    ServiceVisitIssueModel issue,
    List<pw.MemoryImage> images,
    PdfColor textDark,
    PdfColor textMuted,
    PdfColor lightGrey,
    PdfColor borderGrey,
    PdfColor accentColor,
  ) {
    final comp = VehicleComponentsCatalog.getById(issue.componentId);

    PdfColor resolutionColor = const PdfColor.fromInt(0xFF64748B);
    String resolutionText = 'UNSPECIFIED';
    switch (issue.resolutionStatus) {
      case VisitIssueResolution.resolved:
        resolutionColor = const PdfColor.fromInt(0xFF10B981);
        resolutionText = 'RESOLVED';
        break;
      case VisitIssueResolution.partiallyResolved:
        resolutionColor = const PdfColor.fromInt(0xFF3B82F6);
        resolutionText = 'PARTIALLY RESOLVED';
        break;
      case VisitIssueResolution.notResolved:
        resolutionColor = const PdfColor.fromInt(0xFFEF4444);
        resolutionText = 'NOT RESOLVED';
        break;
      case VisitIssueResolution.unableToInspect:
        resolutionColor = const PdfColor.fromInt(0xFF64748B);
        resolutionText = 'UNABLE TO INSPECT';
        break;
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header: Index, Priority, Resolution, Component
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF0B1017),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                    ),
                    child: pw.Text('#$index', style: const pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    comp.name,
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: textMuted),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: resolutionColor,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                ),
                child: pw.Text(
                  resolutionText,
                  style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),

          // Title & Description
          pw.Text(
            issue.issueTitle,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: textDark),
          ),
          if (issue.issueDescription.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              issue.issueDescription,
              style: pw.TextStyle(fontSize: 9, color: textDark, lineSpacing: 1.2),
            ),
          ],

          // Attached Photographs
          if (images.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Row(
              children: images.take(3).map((img) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(right: 6),
                  width: 65,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: borderGrey),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  ),
                  child: pw.Image(img, fit: pw.BoxFit.cover),
                );
              }).toList(),
            ),
          ],

          pw.SizedBox(height: 8),

          // Technician Feedback Sub-box
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              border: pw.Border.all(color: borderGrey, width: 0.6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('TECHNICIAN REMARKS & ACTION TAKEN:', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textMuted)),
                pw.SizedBox(height: 3),
                pw.Text(
                  issue.technicianRemarks != null && issue.technicianRemarks!.trim().isNotEmpty
                      ? issue.technicianRemarks!
                      : 'No technician diagnosis recorded.',
                  style: pw.TextStyle(fontSize: 8.5, color: textDark),
                ),
                if (issue.workPerformed != null && issue.workPerformed!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text('Work Done: ${issue.workPerformed}', style: pw.TextStyle(fontSize: 8.5, color: textDark)),
                ],
                if (issue.partsReplaced != null && issue.partsReplaced!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 3),
                  pw.Text('Parts Replaced: ${issue.partsReplaced}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textDark)),
                ],
                if (issue.followUpRequired) ...[
                  pw.SizedBox(height: 3),
                  pw.Text('[!] Further inspection/follow-up required on next visit', style: const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFFF97316))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAdditionalRequests(String requests, PdfColor textDark, PdfColor textMuted, PdfColor lightGrey, PdfColor borderGrey) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('ADDITIONAL INSPECTION REQUESTS', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: textMuted)),
          pw.SizedBox(height: 4),
          pw.Text(requests, style: pw.TextStyle(fontSize: 9, color: textDark)),
        ],
      ),
    );
  }

  static pw.Widget _buildSignOffSection(ServiceVisitModel visit, PdfColor textDark, PdfColor textMuted, PdfColor lightGrey, PdfColor borderGrey) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: lightGrey,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        border: pw.Border.all(color: borderGrey, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ATTENDING TECHNICIAN', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textMuted)),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    visit.technicianName != null && visit.technicianName!.isNotEmpty ? visit.technicianName! : 'Not specified',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textDark),
                  ),
                ],
              ),
              if (visit.signOffDetails != null && visit.signOffDetails!.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('SIGN-OFF NOTE', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: textMuted)),
                    pw.SizedBox(height: 2),
                    pw.Text(visit.signOffDetails!, style: pw.TextStyle(fontSize: 9, color: textDark)),
                  ],
                ),
            ],
          ),
          pw.Divider(thickness: 0.6, color: borderGrey),
          pw.Text(
            'DISCLAIMER: MyGarage is a driver-assisted vehicle issue tracking system. Technician sign-offs and remarks recorded herein represent local maintenance logs and are not legally binding electronic signatures.',
            style: const pw.TextStyle(fontSize: 6.5, color: PdfColor.fromInt(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context, PdfColor textMuted) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColor.fromInt(0xFFE2E8F0), width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generated by MyGarage for MG Comet EV', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
          pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
        ],
      ),
    );
  }
}
