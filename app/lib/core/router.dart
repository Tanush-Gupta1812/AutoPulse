import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:app/features/pairing/presentation/pairing_screen.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/telemetry/presentation/telemetry_screen.dart';
import 'package:app/features/component_detail/presentation/component_detail_screen.dart';
import 'package:app/features/alerts/presentation/alerts_screen.dart';
import 'package:app/features/plans/presentation/plans_screen.dart';
import 'package:app/features/comparison/presentation/comparison_screen.dart';
import 'package:app/features/fleet/presentation/fleet_screen.dart';
import 'package:app/features/settings/presentation/settings_screen.dart';
import 'package:app/theme/app_tokens.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/pair',
      builder: (context, state) => const PairingScreen(),
    ),
    GoRoute(
      path: '/component/:name',
      builder: (context, state) {
        final name = state.pathParameters['name'] ?? 'Battery';
        return ComponentDetailScreen(componentName: name.replaceAll('_', ' '));
      },
    ),
    GoRoute(
      path: '/service',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      path: '/plans',
      builder: (context, state) => const PlansScreen(),
    ),
    GoRoute(
      path: '/comparison',
      builder: (context, state) => const ComparisonScreen(),
    ),

    // Shell Route for persistent 5-tab BottomNavigationBar
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/telemetry',
          builder: (context, state) => const TelemetryScreen(),
        ),
        GoRoute(
          path: '/alerts',
          builder: (context, state) => const AlertsScreen(),
        ),
        GoRoute(
          path: '/fleet',
          builder: (context, state) => const FleetScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child, super.key});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/telemetry')) return 1;
    if (location.startsWith('/alerts')) return 2;
    if (location.startsWith('/fleet')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/telemetry');
        break;
      case 2:
        context.go('/alerts');
        break;
      case 3:
        context.go('/fleet');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTokens.darkSurface : AppTokens.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTokens.darkBorder : AppTokens.lightBorder,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(index, context),
          elevation: 0,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedItemColor: isDark ? AppTokens.darkTextPrimary : AppTokens.lightTextPrimary,
          unselectedItemColor: isDark ? AppTokens.darkTextMuted : AppTokens.lightTextMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.shield_outlined, size: 20),
              activeIcon: Icon(Icons.shield, size: 20),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_rounded, size: 20),
              activeIcon: Icon(Icons.show_chart_rounded, size: 20),
              label: 'Telemetry',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none_rounded, size: 20),
              activeIcon: Icon(Icons.notifications_rounded, size: 20),
              label: 'Alerts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined, size: 20),
              activeIcon: Icon(Icons.directions_car_filled_rounded, size: 20),
              label: 'Fleet',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded, size: 20),
              activeIcon: Icon(Icons.tune_rounded, size: 20),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
