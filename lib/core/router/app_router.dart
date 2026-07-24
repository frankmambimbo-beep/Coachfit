import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/workout/presentation/workout_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/data/profile_repository.dart';
import 'app_shell.dart';

/// All app navigation is defined here in one place. Riverpod's Provider
/// (not StateNotifierProvider) is used because the router itself is
/// just a plain object we build once — it just *watches* the profile
/// to decide where to redirect.
final routerProvider = Provider<GoRouter>((ref) {
  final hasProfile = ref.watch(profileRepositoryProvider) != null;

  return GoRouter(
    initialLocation: hasProfile ? '/dashboard' : '/onboarding',
    // redirect runs on every navigation attempt and can send the user
    // somewhere else instead — this is what enforces "must onboard first"
    redirect: (context, state) {
      final loggedIn = ref.read(profileRepositoryProvider) != null;
      final goingToOnboarding = state.matchedLocation.startsWith('/onboarding');

      if (!loggedIn && !goingToOnboarding) return '/onboarding';
      if (loggedIn && goingToOnboarding) return '/dashboard';
      return null; // null means "no redirect, proceed as normal"
    },
    routes: [
      GoRoute(path: '/onboarding', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/onboarding/profile',
        builder: (context, state) {
          // Reads the ?guest=true query parameter from the URL
          final isGuest = state.uri.queryParameters['guest'] == 'true';
          return ProfileSetupScreen(isGuest: isGuest);
        },
      ),
      // StatefulShellRoute wraps all 5 tabs in the bottom-nav shell and
      // keeps each tab's state alive when switching between them.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/workout', builder: (context, state) => const WorkoutScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/habits', builder: (context, state) => const HabitsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/stats', builder: (context, state) => const StatsScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen())]),
        ],
      ),
    ],
  );
});
