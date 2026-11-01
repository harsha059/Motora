import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import 'issue_model.dart';

class RecurringMatch {
  final IssueModel matchedIssue;
  final double similarityScore;
  final String matchReason;
  final int previousOccurrences;
  final DateTime? previousServiceDate;
  final String? previousTechnicianRemarks;
  final String previousResolutionStatus;

  const RecurringMatch({
    required this.matchedIssue,
    required this.similarityScore,
    required this.matchReason,
    required this.previousOccurrences,
    this.previousServiceDate,
    this.previousTechnicianRemarks,
    required this.previousResolutionStatus,
  });
}

class ComponentRecurrenceInfo {
  final String componentId;
  final String componentName;
  final int totalIssuesCount;
  final int recurringIssuesCount;
  final List<IssueModel> issues;

  const ComponentRecurrenceInfo({
    required this.componentId,
    required this.componentName,
    required this.totalIssuesCount,
    required this.recurringIssuesCount,
    required this.issues,
  });
}

class RecurringIssueDetector {
  RecurringIssueDetector._();

  static const Set<String> _stopWords = {
    'the', 'a', 'an', 'is', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'and',
    'when', 'from', 'during', 'over', 'under', 'into', 'after', 'before', 'not',
    'my', 'car', 'vehicle', 'ev', 'mg', 'comet', 'issue', 'problem', 'getting',
    'some', 'very', 'slight', 'severe', 'intermittent', 'constant', 'keeps'
  };

  /// Normalizes text by removing non-alphanumeric chars, lowercasing, and filtering stop words.
  static List<String> normalizeTokens(String text) {
    final cleaned = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    final rawTokens = cleaned.split(RegExp(r'\s+')).where((t) => t.trim().isNotEmpty);
    return rawTokens.where((t) => t.length > 2 && !_stopWords.contains(t)).toList();
  }

  /// Calculates similarity between two titles using token overlap (Jaccard) and substring matching.
  static double computeSimilarity(String title1, String title2) {
    if (title1.trim().isEmpty || title2.trim().isEmpty) return 0.0;

    final t1 = title1.trim().toLowerCase();
    final t2 = title2.trim().toLowerCase();

    // Exact or direct containment match
    if (t1 == t2) return 1.0;
    if (t1.contains(t2) || t2.contains(t1)) return 0.85;

    final tokens1 = normalizeTokens(title1).toSet();
    final tokens2 = normalizeTokens(title2).toSet();

    if (tokens1.isEmpty || tokens2.isEmpty) return 0.0;

    final intersection = tokens1.intersection(tokens2).length;
    final union = tokens1.union(tokens2).length;

    if (union == 0) return 0.0;

    final jaccard = intersection / union;

    // Check stem/prefix overlaps (e.g., 'squeak' and 'squeaking')
    int stemMatches = 0;
    for (final tok1 in tokens1) {
      for (final tok2 in tokens2) {
        if (tok1 != tok2 && (tok1.startsWith(tok2) || tok2.startsWith(tok1))) {
          if (tok1.length >= 4 && tok2.length >= 4) {
            stemMatches++;
          }
        }
      }
    }

    final stemBoost = (stemMatches * 0.25).clamp(0.0, 0.4);
    return (jaccard + stemBoost).clamp(0.0, 1.0);
  }

  /// Detects whether an issue under composition or review is a potential recurrence of a prior issue.
  static RecurringMatch? detectRecurringCandidate({
    required String newTitle,
    required String newComponentId,
    String? excludeIssueId,
    required List<IssueModel> existingIssues,
  }) {
    if (newTitle.trim().isEmpty || newComponentId.trim().isEmpty) return null;

    // Filter candidate prior issues on the SAME component
    final componentPriorIssues = existingIssues.where((issue) {
      if (issue.id == excludeIssueId) return false;
      return issue.componentId == newComponentId;
    }).toList();

    if (componentPriorIssues.isEmpty) return null;

    final totalComponentOccurrences = componentPriorIssues.length;

    RecurringMatch? bestMatch;
    double highestScore = 0.0;

    for (final prior in componentPriorIssues) {
      final similarity = computeSimilarity(newTitle, prior.title);

      // Prior issues qualify if:
      // 1. Same component AND high title similarity (>= 0.30)
      // 2. OR same component AND prior was resolved/partially resolved/marked recurring
      final bool priorWasResolvedOrRecurring = prior.status == IssueStatus.resolved ||
          prior.status == IssueStatus.inProgress ||
          prior.isRecurring ||
          prior.technicianRemarks != null;

      final bool isMatch = similarity >= 0.30 || (similarity >= 0.20 && priorWasResolvedOrRecurring);

      if (isMatch && similarity > highestScore) {
        highestScore = similarity;

        String resStatusText;
        switch (prior.status) {
          case IssueStatus.resolved:
            resStatusText = 'Previously Resolved';
            break;
          case IssueStatus.inProgress:
            resStatusText = 'In Progress (Partially Resolved)';
            break;
          case IssueStatus.open:
            resStatusText = 'Open / Unresolved';
            break;
        }

        final compName = VehicleComponentsCatalog.getById(newComponentId).name;
        final reason = priorWasResolvedOrRecurring
            ? 'Same component ($compName) with similar symptoms previously serviced.'
            : 'Matching component ($compName) with related symptom history.';

        bestMatch = RecurringMatch(
          matchedIssue: prior,
          similarityScore: similarity,
          matchReason: reason,
          previousOccurrences: totalComponentOccurrences,
          previousServiceDate: prior.updatedAt,
          previousTechnicianRemarks: prior.technicianRemarks,
          previousResolutionStatus: resStatusText,
        );
      }
    }

    return bestMatch;
  }

  /// Generates a summary of recurring and repeat issues grouped by vehicle component.
  static List<ComponentRecurrenceInfo> getComponentRecurrenceSummary(List<IssueModel> issues) {
    final Map<String, List<IssueModel>> grouped = {};

    for (final issue in issues) {
      grouped.putIfAbsent(issue.componentId, () => []).add(issue);
    }

    final List<ComponentRecurrenceInfo> summary = [];

    grouped.forEach((componentId, componentIssues) {
      final recurringCount = componentIssues.where((i) => i.isRecurring || componentIssues.length > 1).length;
      final comp = VehicleComponentsCatalog.getById(componentId);

      summary.add(
        ComponentRecurrenceInfo(
          componentId: componentId,
          componentName: comp.name,
          totalIssuesCount: componentIssues.length,
          recurringIssuesCount: recurringCount,
          issues: componentIssues,
        ),
      );
    });

    summary.sort((a, b) => b.recurringIssuesCount.compareTo(a.recurringIssuesCount));
    return summary;
  }
}
