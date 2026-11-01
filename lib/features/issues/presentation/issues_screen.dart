import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_pill.dart';
import '../../home/presentation/widgets/quick_add_issue_sheet.dart';
import '../data/issue_repository.dart';
import 'issue_detail_sheet.dart';

class IssuesScreen extends ConsumerStatefulWidget {
  const IssuesScreen({super.key});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  IssuePriority? _filterPriority;
  IssueStatus? _filterStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(allIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Garage Issues Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.accent),
            tooltip: 'Add Issue',
            onPressed: () => QuickAddIssueSheet.show(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filters bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search issues or components...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),

            // Horizontal Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: Row(
                children: [
                  // Status Filter: All / Open / In Progress / Resolved
                  _buildFilterChip('All Status', _filterStatus == null, () {
                    setState(() => _filterStatus = null);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterChip('Open', _filterStatus == IssueStatus.open, () {
                    setState(() => _filterStatus = _filterStatus == IssueStatus.open ? null : IssueStatus.open);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterChip('In Progress', _filterStatus == IssueStatus.inProgress, () {
                    setState(() => _filterStatus = _filterStatus == IssueStatus.inProgress ? null : IssueStatus.inProgress);
                  }),
                  const SizedBox(width: 6),
                  _buildFilterChip('Resolved', _filterStatus == IssueStatus.resolved, () {
                    setState(() => _filterStatus = _filterStatus == IssueStatus.resolved ? null : IssueStatus.resolved);
                  }),
                  const SizedBox(width: 14),
                  Container(width: 1, height: 20, color: AppColors.cardBorder),
                  const SizedBox(width: 14),

                  // Priority Filter
                  _buildFilterChip('Critical', _filterPriority == IssuePriority.critical, () {
                    setState(() => _filterPriority = _filterPriority == IssuePriority.critical ? null : IssuePriority.critical);
                  }, activeColor: AppColors.critical),
                  const SizedBox(width: 6),
                  _buildFilterChip('High', _filterPriority == IssuePriority.high, () {
                    setState(() => _filterPriority = _filterPriority == IssuePriority.high ? null : IssuePriority.high);
                  }, activeColor: AppColors.high),
                  const SizedBox(width: 6),
                  _buildFilterChip('Medium', _filterPriority == IssuePriority.medium, () {
                    setState(() => _filterPriority = _filterPriority == IssuePriority.medium ? null : IssuePriority.medium);
                  }, activeColor: AppColors.medium),
                  const SizedBox(width: 6),
                  _buildFilterChip('Low', _filterPriority == IssuePriority.low, () {
                    setState(() => _filterPriority = _filterPriority == IssuePriority.low ? null : IssuePriority.low);
                  }, activeColor: AppColors.low),
                ],
              ),
            ),
            const Divider(height: 16),

            // Issues List
            Expanded(
              child: issuesAsync.when(
                data: (issues) {
                  // Apply filters
                  final filtered = issues.where((item) {
                    if (_filterStatus != null && item.status != _filterStatus) return false;
                    if (_filterPriority != null && item.priority != _filterPriority) return false;
                    if (_searchQuery.isNotEmpty) {
                      final comp = VehicleComponentsCatalog.getById(item.componentId);
                      final matchesTitle = item.title.toLowerCase().contains(_searchQuery);
                      final matchesDesc = item.description.toLowerCase().contains(_searchQuery);
                      final matchesComp = comp.name.toLowerCase().contains(_searchQuery);
                      if (!matchesTitle && !matchesDesc && !matchesComp) return false;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_alt_off_rounded, size: 48, color: AppColors.secondaryText.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching issues found',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try resetting your search query or filters',
                            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final issue = filtered[index];
                      final component = VehicleComponentsCatalog.getById(issue.componentId);

                      return GlassCard(
                        onTap: () => IssueDetailSheet.show(context, issue),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                PriorityBadge(priority: issue.priority, compact: true),
                                const SizedBox(width: 8),
                                StatusPill(status: issue.status),
                                const Spacer(),
                                Text(
                                  DateFormat('dd MMM yyyy').format(issue.dateNoticed),
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.tertiaryText),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              issue.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryText,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              issue.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.secondaryText,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(component.icon, size: 14, color: AppColors.accent),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    component.name,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.elevatedSurface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    issue.frequency.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.tertiaryText,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? activeColor}) {
    final effectiveColor = activeColor ?? AppColors.accent;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor.withValues(alpha: 0.16) : AppColors.elevatedSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? effectiveColor : AppColors.cardBorder,
            width: isSelected ? 1.2 : 0.8,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? effectiveColor : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }
}
