import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../issues/data/issue_repository.dart';
import 'widgets/issue_summary_cards.dart';
import 'widgets/next_service_card.dart';
import 'widgets/quick_add_issue_sheet.dart';
import 'widgets/recent_issues_section.dart';
import 'widgets/vehicle_hero_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Seed sample initial issues on first launch so the dashboard has rich content
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(issueRepositoryProvider).seedInitialDataIfEmpty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final allIssuesAsync = ref.watch(allIssuesProvider);
    final recentIssuesAsync = ref.watch(recentIssuesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.elevatedSurface,
          onRefresh: () async {
            ref.invalidate(allIssuesProvider);
            ref.invalidate(recentIssuesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Welcome & Quick-Add Button
                _buildHeader(context),
                const SizedBox(height: 18),

                // Vehicle Hero Card (MG Comet EV)
                VehicleHeroCard(
                  onInspect3D: () => context.go('/vehicle'),
                ),
                const SizedBox(height: 20),

                // Issue Counters & Severity Summary
                allIssuesAsync.when(
                  data: (issues) => IssueSummaryCards(
                    issues: issues,
                    onViewAllIssues: () => context.go('/issues'),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error loading summary: $e', style: const TextStyle(color: AppColors.critical)),
                  ),
                ),
                const SizedBox(height: 20),

                // Next Service Maintenance Card
                allIssuesAsync.when(
                  data: (issues) {
                    final openCount = issues.where((i) => i.status != IssueStatus.resolved).length;
                    return NextServiceCard(
                      openIssuesCount: openCount,
                      onPrepareService: () => context.go('/service'),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Recent Issues Section
                recentIssuesAsync.when(
                  data: (recent) => RecentIssuesSection(
                    issues: recent,
                    onViewAll: () => context.go('/issues'),
                    onQuickAdd: () => QuickAddIssueSheet.show(context),
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error loading issues: $e', style: const TextStyle(color: AppColors.critical)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => QuickAddIssueSheet.show(context),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final today = DateFormat('EEEE, d MMMM').format(DateTime.now());

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  today.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: AppColors.tertiaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'MyGarage',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                color: AppColors.primaryText,
              ),
            ),
          ],
        ),
        // Fast Action Button to add issue
        IconButton(
          onPressed: () => QuickAddIssueSheet.show(context),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.elevatedSurface,
            side: const BorderSide(color: AppColors.cardBorder),
            padding: const EdgeInsets.all(12),
          ),
          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.accent, size: 22),
          tooltip: 'Quick Add Issue',
        ),
      ],
    );
  }
}
