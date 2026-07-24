import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/workout/presentation/workout_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/habits/presentation/add_habit_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/domain/user_profile.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Must match the type used in main.dart's Hive.openBox<UserProfile>(...)
    // exactly, or Hive throws a "box already open with different type" error.
    final box = Hive.box<UserProfile>('profileBox');
    final hasProfile = box.isNotEmpty;
    final onboarding = state.matchedLocation == '/' ||
        state.matchedLocation == '/onboarding';

    if (!hasProfile && !onboarding) return '/';
    if (hasProfile && onboarding) return '/dashboard';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ProfileSetupScreen()),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen()),
        GoRoute(
            path: '/workout',
            builder: (context, state) => const WorkoutScreen()),
        GoRoute(
          path: '/habits',
          builder: (context, state) => const HabitsScreen(),
          routes: [
            GoRoute(
                path: 'add',
                builder: (context, state) => const AddHabitScreen()),
          ],
        ),
        GoRoute(
            path: '/stats', builder: (context, state) => const StatsScreen()),
        GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);
