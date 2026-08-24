import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/workout/presentation/workout_screen.dart';
import '../../features/workout/presentation/add_workout_screen.dart';
import '../../features/workout/presentation/pushup_camera_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/habits/presentation/add_habit_screen.dart';
import '../../features/goals/presentation/goals_screen.dart';
import '../../features/goals/presentation/add_goal_screen.dart';
import '../../features/challenges/presentation/challenges_screen.dart';
import '../../features/nutrition/presentation/nutrition_screen.dart';
import '../../features/nutrition/presentation/add_nutrition_screen.dart';
import '../../features/mood/presentation/mood_screen.dart';
import '../../features/mood/presentation/log_mood_screen.dart';
import '../../features/bodygoal/presentation/body_goal_screen.dart';
import '../../features/stats/presentation/stats_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/domain/user_profile.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
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
      builder: (context, state) => const ProfileSetupScreen(),
      routes: [
        GoRoute(
          path: 'body-goal',
          builder: (context, state) => const BodyGoalScreen(fromOnboarding: true),
        ),
      ],
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen()),
        GoRoute(
          path: '/workout',
          builder: (context, state) => const WorkoutScreen(),
          routes: [
            GoRoute(
                path: 'add',
                builder: (context, state) => const AddWorkoutScreen()),
            GoRoute(
                path: 'pushups',
                builder: (context, state) => const PushupCameraScreen()),
          ],
        ),
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
          path: '/goals',
          builder: (context, state) => const GoalsScreen(),
          routes: [
            GoRoute(
                path: 'add',
                builder: (context, state) => const AddGoalScreen()),
          ],
        ),
        GoRoute(
            path: '/challenges',
            builder: (context, state) => const ChallengesScreen()),
        GoRoute(
          path: '/nutrition',
          builder: (context, state) => const NutritionScreen(),
          routes: [
            GoRoute(
                path: 'add',
                builder: (context, state) => const AddNutritionScreen()),
          ],
        ),
        GoRoute(
          path: '/mood',
          builder: (context, state) => const MoodScreen(),
          routes: [
            GoRoute(
                path: 'log',
                builder: (context, state) => const LogMoodScreen()),
          ],
        ),
        GoRoute(
            path: '/stats', builder: (context, state) => const StatsScreen()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
          routes: [
            GoRoute(
              path: 'body-goal',
              builder: (context, state) => const BodyGoalScreen(fromOnboarding: false),
            ),
          ],
        ),
      ],
    ),
  ],
);
