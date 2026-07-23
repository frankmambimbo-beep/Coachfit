import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// The persistent bottom-navigation shell wrapping all 5 main tabs.
/// go_router's StatefulShellRoute keeps each tab's own navigation
/// stack and scroll position alive when you switch tabs and back —
/// exactly like how Instagram/Spotify tabs remember where you were.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  // Record-type list defining each tab's icon + label in one place
  static const _tabs = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.fitness_center_rounded, label: 'Workout'),
    (icon: Icons.checklist_rounded, label: 'Habits'),
    (icon: Icons.bar_chart_rounded, label: 'Stats'),
    (icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // shows whichever tab is currently active
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the already-active tab resets it to its root screen
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: _tabs.map((t) => BottomNavigationBarItem(icon: Icon(t.icon), label: t.label)).toList(),
      ),
    );
  }
}
