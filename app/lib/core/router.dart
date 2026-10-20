import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/onboarding/presentation/onboarding_screen.dart';
import 'package:app/features/pairing/presentation/pairing_screen.dart';
import 'package:app/features/home/presentation/home_screen.dart';
import 'package:app/features/telemetry/presentation/telemetry_screen.dart';
import 'package:app/features/component_detail/presentation/component_detail_screen.dart';
import 'package:app/features/alerts/presentation/alerts_screen.dart';
import 'package:app/features/service/presentation/service_screen.dart';
import 'package:app/features/plans/presentation/plans_screen.dart';
import 'package:app/features/comparison/presentation/comparison_screen.dart';
import 'package:app/features/fleet/presentation/fleet_screen.dart';
import 'package:app/features/settings/presentation/settings_screen.dart';

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
      builder: (context, state) => const ServiceScreen(),
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
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.speed_outlined),
            activeIcon: Icon(Icons.speed),
            label: 'Live OBD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            activeIcon: Icon(Icons.local_shipping),
            label: 'Fleet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
