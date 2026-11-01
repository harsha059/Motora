import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/database/app_database.dart';
import '../../issues/data/issue_repository.dart';
import '../../service/data/service_repository.dart';
import 'widgets/active_defect_radar.dart';
import 'widgets/next_service_card.dart';
import 'widgets/quick_add_issue_sheet.dart';
import 'widgets/quick_dashboard_actions.dart';
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

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final allIssuesAsync = ref.watch(allIssuesProvider);
    final recentIssuesAsync = ref.watch(recentIssuesProvider);
    final latestVisitAsync = ref.watch(latestCompletedVisitProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor: AppColors.elevatedSurface,
          onRefresh: () async {
            ref.invalidate(allIssuesProvider);
            ref.invalidate(recentIssuesProvider);
            ref.invalidate(latestCompletedVisitProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Time-based Greeting & Vehicle Identifier & Odometer
                latestVisitAsync.when(
                  data: (latestVisit) => _buildHeader(
                    context,
                    odometerReading: latestVisit?.odometerReading ?? 4850,
                  ),
                  loading: () => _buildHeader(context, odometerReading: 4850),
                  error: (_, _) => _buildHeader(context, odometerReading: 4850),
                ),
                const SizedBox(height: 18),

                // Vehicle Hero Card (MG Comet EV)
                allIssuesAsync.when(
                  data: (issues) {
                    final openCount = issues.where((i) => i.status != IssueStatus.resolved).length;
                    final latestVisit = latestVisitAsync.value;
                    final lastServiceStr = latestVisit != null
                        ? '${DateFormat('dd MMM yyyy').format(latestVisit.visitDate)} (${NumberFormat('#,###').format(latestVisit.odometerReading)} km)'
                        : 'None logged yet';

                    return VehicleHeroCard(
                      openIssuesCount: openCount,
                      lastServiceVisitText: lastServiceStr,
                      nextServiceReminderText: '10,000 km / 1st Year Annual EV Inspection',
                      onInspect3D: () => context.go('/vehicle'),
                    );
                  },
                  loading: () => VehicleHeroCard(
                    onInspect3D: () => context.go('/vehicle'),
                  ),
                  error: (_, _) => VehicleHeroCard(
                    onInspect3D: () => context.go('/vehicle'),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Actions: Log Issue & Prepare for Service
                QuickDashboardActions(
                  onLogIssue: () => QuickAddIssueSheet.show(context),
                  onPrepareService: () => context.push('/service/prepare'),
                ),
                const SizedBox(height: 18),

                // Active Defect Radar (Signature MyGarage Feature)
                allIssuesAsync.when(
                  data: (issues) => ActiveDefectRadar(
                    allIssues: issues,
                    onPriorityTap: (priority) {
                      context.go('/issues?priority=${priority.name}');
                    },
                  ),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                  error: (e, _) => Center(
                    child: Text('Error loading radar: $e', style: const TextStyle(color: AppColors.critical)),
                  ),
                ),
                const SizedBox(height: 20),

                // Next Service Maintenance Card
                allIssuesAsync.when(
                  data: (issues) {
                    final openCount = issues.where((i) => i.status != IssueStatus.resolved).length;
                    return NextServiceCard(
                      openIssuesCount: openCount,
                      onPrepareService: () => context.push('/service/prepare'),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: 24),

                // Recent Issues Section (Latest 5 or Empty State)
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

  Widget _buildHeader(BuildContext context, {required int odometerReading}) {
    final greeting = _getTimeGreeting();
    final odoFormatted = NumberFormat('#,###').format(odometerReading);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  '$greeting • MG COMET EV'.toUpperCase(),
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
            Row(
              children: [
                const Text(
                  'MyGarage',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accentDim.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'KA 01 MG 2024',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Odometer Pill Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.elevatedSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ODOMETER',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.tertiaryText,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed_rounded, size: 14, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text(
                    '$odoFormatted km',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
