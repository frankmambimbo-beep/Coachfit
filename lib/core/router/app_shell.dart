import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The persistent bottom-navigation shell wrapping all 5 main tabs.
/// `child` is whatever screen the current route resolves to; we figure
/// out which tab is "selected" by checking the current URL location.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home', path: '/dashboard'),
    (icon: Icons.fitness_center_rounded, label: 'Workout', path: '/workout'),
    (icon: Icons.checklist_rounded, label: 'Habits', path: '/habits'),
    (icon: Icons.bar_chart_rounded, label: 'Stats', path: '/stats'),
    (icon: Icons.person_rounded, label: 'Profile', path: '/profile'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _tabs.indexWhere((t) => location.startsWith(t.path));
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) => context.go(_tabs[index].path),
        items: _tabs
            .map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label))
            .toList(),
      ),
    );
  }
}
