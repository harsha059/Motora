import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/issues/presentation/issues_screen.dart';
import '../../features/service/presentation/service_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/vehicle/presentation/vehicle_screen.dart';
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
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: IssuesScreen(),
                ),
              ),
            ],
          ),
          // 4. Service
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/service',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ServiceScreen(),
                ),
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
    ],
  );
});
