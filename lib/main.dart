import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/domain/user_profile.dart';
import 'features/habits/domain/habit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Profile adapters (Phase 1)
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(FitnessLevelAdapter());
  Hive.registerAdapter(PrimaryGoalAdapter());
  Hive.registerAdapter(WorkoutLocationAdapter());

  // Habit adapters (Phase 2)
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(HabitCategoryAdapter());
  Hive.registerAdapter(HabitFrequencyAdapter());

  await Hive.openBox<UserProfile>('profileBox');
  await Hive.openBox<Habit>('habitsBox');

  runApp(const ProviderScope(child: CoachFitApp()));
}

class CoachFitApp extends StatelessWidget {
  const CoachFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CoachFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
