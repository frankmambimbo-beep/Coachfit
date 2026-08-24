import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/domain/user_profile.dart';
import 'features/habits/domain/habit.dart';
import 'features/goals/domain/goal.dart';
import 'features/challenges/domain/challenge.dart';
import 'features/workout/domain/workout_session.dart';
import 'features/nutrition/domain/nutrition_entry.dart';
import 'features/mood/domain/mood_entry.dart';

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

  // Goal adapters (Phase 3)
  Hive.registerAdapter(GoalAdapter());
  Hive.registerAdapter(GoalCategoryAdapter());

  // Challenge adapters (Phase 3)
  Hive.registerAdapter(ChallengeAdapter());
  Hive.registerAdapter(ChallengeCategoryAdapter());

  // Workout adapters (Phase 4)
  Hive.registerAdapter(WorkoutTypeAdapter());
  Hive.registerAdapter(ExerciseEntryAdapter());
  Hive.registerAdapter(WorkoutSessionAdapter());

  // Nutrition adapters (Phase 6)
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(NutritionEntryAdapter());
  Hive.registerAdapter(WaterLogAdapter());

  // Mood adapters (Phase 6)
  Hive.registerAdapter(MoodLevelAdapter());
  Hive.registerAdapter(MoodEntryAdapter());

  await Hive.openBox<UserProfile>('profileBox');
  await Hive.openBox<Habit>('habitsBox');
  await Hive.openBox<Goal>('goalsBox');
  await Hive.openBox<Challenge>('challengesBox');
  await Hive.openBox<WorkoutSession>('workoutsBox');
  await Hive.openBox<NutritionEntry>('nutritionBox');
  await Hive.openBox<WaterLog>('waterBox');
  await Hive.openBox<MoodEntry>('moodBox');

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
