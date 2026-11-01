import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../issues/data/issue_repository.dart';
import '../../issues/presentation/issue_detail_sheet.dart';

class ServiceScreen extends ConsumerStatefulWidget {
  const ServiceScreen({super.key});

  @override
  ConsumerState<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends ConsumerState<ServiceScreen> {
  final Set<String> _selectedIssueIds = {};

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(allIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Service Centre Preparation'),
      ),
      body: SafeArea(
        child: issuesAsync.when(
          data: (issues) {
            final openIssues = issues.where((i) => i.status != IssueStatus.resolved).toList();
            final resolvedIssues = issues.where((i) => i.status == IssueStatus.resolved).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Checklist Banner Card
                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    gradient: AppColors.heroCardGradient,
                    borderColor: AppColors.cardBorderActive,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentDim,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.checklist_rtl_rounded, color: AppColors.accent, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pre-Service Checklist',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  Text(
                                    'Select items to hand over to the service technician',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedIssueIds.length} of ${openIssues.length} selected for discussion',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_selectedIssueIds.length == openIssues.length) {
                                    _selectedIssueIds.clear();
                                  } else {
                                    _selectedIssueIds.addAll(openIssues.map((e) => e.id));
                                  }
                                });
                              },
                              child: Text(
                                _selectedIssueIds.length == openIssues.length ? 'Deselect All' : 'Select All',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Open Issues Section
                  const Text(
                    'Pending Items to Review',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (openIssues.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.statusResolved, size: 36),
                            const SizedBox(height: 10),
                            const Text(
                              'No pending issues',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'All reported issues have been addressed and resolved.',
                              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: openIssues.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final issue = openIssues[index];
                        final component = VehicleComponentsCatalog.getById(issue.componentId);
                        final isSelected = _selectedIssueIds.contains(issue.id);

                        return GlassCard(
                          borderColor: isSelected ? AppColors.accent : AppColors.cardBorder,
                          backgroundColor: isSelected ? AppColors.accentDim.withValues(alpha: 0.1) : AppColors.surface,
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: isSelected,
                                activeColor: AppColors.accent,
                                checkColor: AppColors.background,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedIssueIds.add(issue.id);
                                    } else {
                                      _selectedIssueIds.remove(issue.id);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => IssueDetailSheet.show(context, issue),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          PriorityBadge(priority: issue.priority, compact: true),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              component.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.secondaryText,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        issue.title,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        issue.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12.5, color: AppColors.secondaryText),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.statusResolved),
                                tooltip: 'Mark as Resolved',
                                onPressed: () async {
                                  await ref.read(issueRepositoryProvider).updateIssueStatus(issue.id, IssueStatus.resolved);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Issue marked as resolved')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 28),

                  // Resolved History
                  if (resolvedIssues.isNotEmpty) ...[
                    Text(
                      'Previously Resolved (${resolvedIssues.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resolvedIssues.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final issue = resolvedIssues[index];
                        return GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: AppColors.statusResolved, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  issue.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.secondaryText,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await ref.read(issueRepositoryProvider).updateIssueStatus(issue.id, IssueStatus.open);
                                },
                                child: const Text('Reopen', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          ),
          error: (e, _) => Center(
            child: Text('Error: $e', style: const TextStyle(color: AppColors.critical)),
          ),
        ),
      ),
    );
  }
}
