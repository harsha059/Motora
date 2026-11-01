import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/issues/presentation/issues_screen.dart';
import '../../features/service/presentation/prepare_service_screen.dart';
import '../../features/service/presentation/service_report_pdf_screen.dart';
import '../../features/service/presentation/service_screen.dart';
import '../../features/service/presentation/service_visit_detail_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/vehicle/presentation/vehicle_screen.dart';
import '../../features/backup/presentation/backup_restore_screen.dart';
import '../../features/documents/presentation/document_vault_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/vehicle/presentation/odometer_log_screen.dart';
import '../../features/vehicle/presentation/vehicle_management_screen.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // 1. Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          // 2. Vehicle (3D & Component Inspector)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vehicle',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: VehicleScreen(),
                ),
              ),
            ],
          ),
          // 3. Issues
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/issues',
                pageBuilder: (context, state) {
                  final priorityStr = state.uri.queryParameters['priority'];
                  return NoTransitionPage(
                    child: IssuesScreen(initialPriorityFilter: priorityStr),
                  );
                },
              ),
            ],
          ),
          // 4. Service (with prepare, visit detail, and report subroutes)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/service',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ServiceScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'prepare',
                    builder: (context, state) {
                      final preselected = state.extra as List<String>?;
                      return PrepareServiceScreen(preselectedIssueIds: preselected);
                    },
                  ),
                  GoRoute(
                    path: 'visit/:id',
                    builder: (context, state) {
                      final visitId = state.pathParameters['id']!;
                      return ServiceVisitDetailScreen(visitId: visitId);
                    },
                  ),
                  GoRoute(
                    path: 'report/:id',
                    builder: (context, state) {
                      final visitId = state.pathParameters['id']!;
                      return ServiceReportPdfScreen(visitId: visitId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // 5. Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/vehicles',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const VehicleManagementScreen(),
      ),
      GoRoute(
        path: '/odometer',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OdometerLogScreen(),
      ),
      GoRoute(
        path: '/reminders',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/documents',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DocumentVaultScreen(),
      ),
      GoRoute(
        path: '/backup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BackupRestoreScreen(),
      ),
    ],
  );
});
