import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/vehicle_components.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_pill.dart';
import '../../home/presentation/widgets/quick_add_issue_sheet.dart';
import '../data/issue_repository.dart';
import '../domain/issue_model.dart';
import 'issue_detail_sheet.dart';

enum IssueSortOption {
  mostRecent('Most recently reported', Icons.schedule_rounded),
  oldest('Oldest reported', Icons.history_rounded),
  highestPriority('Highest priority', Icons.crisis_alert_rounded),
  recentlyUpdated('Recently updated', Icons.update_rounded);

  final String label;
  final IconData icon;
  const IssueSortOption(this.label, this.icon);
}

class IssuesScreen extends ConsumerStatefulWidget {
  final String? initialPriorityFilter;

  const IssuesScreen({super.key, this.initialPriorityFilter});

  @override
  ConsumerState<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends ConsumerState<IssuesScreen> {
  IssuePriority? _filterPriority;
  IssueStatus? _filterStatus;
  bool _filterRecurringOnly = false;
  String _searchQuery = '';
  IssueSortOption _currentSort = IssueSortOption.mostRecent;

  // Bulk Selection Mode
  bool _isSelectionMode = false;
  final Set<String> _selectedIssueIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialPriorityFilter != null) {
      final pStr = widget.initialPriorityFilter!.toLowerCase();
      for (final p in IssuePriority.values) {
        if (p.name.toLowerCase() == pStr) {
          _filterPriority = p;
          break;
        }
      }
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIssueIds.clear();
      }
    });
  }

  void _toggleIssueSelected(String id) {
    setState(() {
      if (_selectedIssueIds.contains(id)) {
        _selectedIssueIds.remove(id);
      } else {
        _selectedIssueIds.add(id);
      }
    });
  }

  void _selectAll(List<IssueModel> issues) {
    setState(() {
      _selectedIssueIds.addAll(issues.map((i) => i.id));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIssueIds.clear();
    });
  }

  void _proceedToServicePreparation() {
    if (_selectedIssueIds.isEmpty) return;
    context.push('/service/prepare', extra: _selectedIssueIds.toList());
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sort Issues By',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...IssueSortOption.values.map((option) {
                  final isSelected = _currentSort == option;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      option.icon,
                      color: isSelected ? AppColors.accent : AppColors.secondaryText,
                      size: 20,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? AppColors.accent : AppColors.primaryText,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_rounded, color: AppColors.accent, size: 20)
                        : null,
                    onTap: () {
                      setState(() => _currentSort = option);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final issuesAsync = ref.watch(allIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isSelectionMode ? '${_selectedIssueIds.length} Selected' : 'Garage Issues Log'),
        actions: [
          // Sort Button
          IconButton(
            icon: const Icon(Icons.sort_rounded, color: AppColors.primaryText, size: 22),
            tooltip: 'Sort Issues',
            onPressed: _showSortSheet,
          ),
          // Bulk Selection Mode Toggle
          IconButton(
            icon: Icon(
              _isSelectionMode ? Icons.check_circle_rounded : Icons.checklist_rounded,
              color: _isSelectionMode ? AppColors.accent : AppColors.primaryText,
              size: 22,
            ),
            tooltip: _isSelectionMode ? 'Cancel Selection' : 'Select Multiple',
            onPressed: _toggleSelectionMode,
          ),
          if (!_isSelectionMode)
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
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: TextField(
                style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search title, description, component, remarks...',
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

            // Filter Chips Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              child: Row(
                children: [
                  // Status Filter Chips
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
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: AppColors.cardBorder),
                  const SizedBox(width: 10),

                  // Priority Filter Chips
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
                  const SizedBox(width: 10),
                  Container(width: 1, height: 20, color: AppColors.cardBorder),
                  const SizedBox(width: 10),

                  // Recurring Filter Toggle Chip
                  _buildFilterChip(
                    'Recurring Only',
                    _filterRecurringOnly,
                    () => setState(() => _filterRecurringOnly = !_filterRecurringOnly),
                    activeColor: AppColors.medium,
                    leadingIcon: Icons.replay_rounded,
                  ),
                ],
              ),
            ),

            // Bulk Selection Action Toolbar (when active)
            if (_isSelectionMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                color: AppColors.elevatedSurface,
                child: issuesAsync.when(
                  data: (issues) => Row(
                    children: [
                      TextButton(
                        onPressed: () => _selectAll(issues),
                        child: const Text('Select All', style: TextStyle(color: AppColors.accent, fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: _clearSelection,
                        child: const Text('Clear', style: TextStyle(color: AppColors.secondaryText, fontSize: 13)),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: _selectedIssueIds.isNotEmpty ? _proceedToServicePreparation : null,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                        label: Text('Prepare Service (${_selectedIssueIds.length})'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),

            const Divider(height: 12),

            // Issues List with Sorting & Filters Applied
            Expanded(
              child: issuesAsync.when(
                data: (issues) {
                  // 1. Search across title, description, component name, and technician remarks
                  final filtered = issues.where((item) {
                    if (_filterStatus != null && item.status != _filterStatus) return false;
                    if (_filterPriority != null && item.priority != _filterPriority) return false;
                    if (_filterRecurringOnly && !item.isRecurring) return false;

                    if (_searchQuery.isNotEmpty) {
                      final comp = VehicleComponentsCatalog.getById(item.componentId);
                      final matchesTitle = item.title.toLowerCase().contains(_searchQuery);
                      final matchesDesc = item.description.toLowerCase().contains(_searchQuery);
                      final matchesComp = comp.name.toLowerCase().contains(_searchQuery);
                      final matchesRemarks = (item.technicianRemarks ?? '').toLowerCase().contains(_searchQuery);

                      if (!matchesTitle && !matchesDesc && !matchesComp && !matchesRemarks) {
                        return false;
                      }
                    }
                    return true;
                  }).toList();

                  // 2. Sorting
                  switch (_currentSort) {
                    case IssueSortOption.mostRecent:
                      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                      break;
                    case IssueSortOption.oldest:
                      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                      break;
                    case IssueSortOption.highestPriority:
                      filtered.sort((a, b) => a.priority.index.compareTo(b.priority.index));
                      break;
                    case IssueSortOption.recentlyUpdated:
                      filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
                      break;
                  }

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
                            'Try adjusting your search query or active filters',
                            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _filterStatus = null;
                                _filterPriority = null;
                                _filterRecurringOnly = false;
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Reset All Filters'),
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
                      final isSelected = _selectedIssueIds.contains(issue.id);

                      return GlassCard(
                        onTap: () {
                          if (_isSelectionMode) {
                            _toggleIssueSelected(issue.id);
                          } else {
                            IssueDetailSheet.show(context, issue);
                          }
                        },
                        padding: const EdgeInsets.all(16),
                        borderColor: isSelected ? AppColors.accent : AppColors.cardBorder,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_isSelectionMode) ...[
                                  Checkbox(
                                    value: isSelected,
                                    activeColor: AppColors.accent,
                                    checkColor: AppColors.background,
                                    onChanged: (_) => _toggleIssueSelected(issue.id),
                                  ),
                                  const SizedBox(width: 4),
                                ],
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

                            // Issue Title
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

                            // Short Description
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

                            // Component, Badges & Indicators
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                // Component Tag
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(component.icon, size: 14, color: AppColors.accent),
                                    const SizedBox(width: 5),
                                    Text(
                                      component.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.accent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),

                                // Recurring Issue Badge
                                if (issue.isRecurring)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.medium.withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.medium.withValues(alpha: 0.5), width: 0.8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.replay_rounded, size: 11, color: AppColors.medium),
                                        SizedBox(width: 4),
                                        Text(
                                          'RECURRING',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: AppColors.medium,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Service History / Tech Diagnosed Indicator
                                if (issue.technicianRemarks != null && issue.technicianRemarks!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.elevatedSurface,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.cardBorder, width: 0.8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.build_rounded, size: 10, color: AppColors.secondaryText),
                                        SizedBox(width: 4),
                                        Text(
                                          'TECH REMARKS',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: AppColors.secondaryText,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
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

  Widget _buildFilterChip(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? activeColor,
    IconData? leadingIcon,
  }) {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 13, color: isSelected ? effectiveColor : AppColors.secondaryText),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? effectiveColor : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
