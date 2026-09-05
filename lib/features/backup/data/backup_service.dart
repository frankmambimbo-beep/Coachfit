import 'dart:convert';
import 'package:hive/hive.dart';

import '../../profile/domain/user_profile.dart';
import '../../habits/domain/habit.dart';
import '../../goals/domain/goal.dart';
import '../../challenges/domain/challenge.dart';
import '../../workout/domain/workout_session.dart';
import '../../nutrition/domain/nutrition_entry.dart';
import '../../mood/domain/mood_entry.dart';
import '../../bodygoal/domain/body_type_goal.dart';

/// Bundles every Hive box into one JSON-serializable snapshot for
/// backup/export, and can restore that same snapshot back into Hive.
/// Purely local — the JSON never leaves the device unless the person
/// chooses to copy/share it themselves (e.g. pasting into a notes app
/// or emailing it to themselves for safekeeping).
class BackupService {
  static const int backupFormatVersion = 1;

  static Map<String, dynamic> exportAll() {
    final profileBox = Hive.box<UserProfile>('profileBox');
    final habitsBox = Hive.box<Habit>('habitsBox');
    final goalsBox = Hive.box<Goal>('goalsBox');
    final challengesBox = Hive.box<Challenge>('challengesBox');
    final workoutsBox = Hive.box<WorkoutSession>('workoutsBox');
    final nutritionBox = Hive.box<NutritionEntry>('nutritionBox');
    final waterBox = Hive.box<WaterLog>('waterBox');
    final moodBox = Hive.box<MoodEntry>('moodBox');
    final bodyGoalBox = Hive.box<BodyGoalSelection>('bodyGoalBox');

    return {
      'backupFormatVersion': backupFormatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': profileBox.values.map((p) => p.toJson()).toList(),
      'habits': habitsBox.values.map((h) => h.toJson()).toList(),
      'goals': goalsBox.values.map((g) => g.toJson()).toList(),
      'challenges': challengesBox.values.map((c) => c.toJson()).toList(),
      'workouts': workoutsBox.values.map((w) => w.toJson()).toList(),
      'nutrition': nutritionBox.values.map((n) => n.toJson()).toList(),
      'water': waterBox.keys
          .map((k) => {'key': k, 'value': waterBox.get(k)!.toJson()})
          .toList(),
      'moods': moodBox.values.map((m) => m.toJson()).toList(),
      'bodyGoal': bodyGoalBox.keys
          .map((k) => {'key': k, 'value': bodyGoalBox.get(k)!.toJson()})
          .toList(),
    };
  }

  static String exportAsString() => jsonEncode(exportAll());

  /// Restores a previously exported snapshot. This REPLACES all
  /// current data in every box — meant for restoring onto a fresh
  /// install, not merging with existing data.
  static Future<void> restoreFromJson(String jsonString) async {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    final version = data['backupFormatVersion'];
    if (version != backupFormatVersion) {
      throw FormatException(
        'This backup was made with a different app version (format $version) '
        'and cannot be safely restored by this version.',
      );
    }

    final profileBox = Hive.box<UserProfile>('profileBox');
    final habitsBox = Hive.box<Habit>('habitsBox');
    final goalsBox = Hive.box<Goal>('goalsBox');
    final challengesBox = Hive.box<Challenge>('challengesBox');
    final workoutsBox = Hive.box<WorkoutSession>('workoutsBox');
    final nutritionBox = Hive.box<NutritionEntry>('nutritionBox');
    final waterBox = Hive.box<WaterLog>('waterBox');
    final moodBox = Hive.box<MoodEntry>('moodBox');
    final bodyGoalBox = Hive.box<BodyGoalSelection>('bodyGoalBox');

    await profileBox.clear();
    await habitsBox.clear();
    await goalsBox.clear();
    await challengesBox.clear();
    await workoutsBox.clear();
    await nutritionBox.clear();
    await waterBox.clear();
    await moodBox.clear();
    await bodyGoalBox.clear();

    for (final p in (data['profile'] as List)) {
      final profile = UserProfile.fromJson(p as Map<String, dynamic>);
      await profileBox.put('current_profile', profile);
    }
    for (final h in (data['habits'] as List)) {
      final habit = Habit.fromJson(h as Map<String, dynamic>);
      await habitsBox.put(habit.id, habit);
    }
    for (final g in (data['goals'] as List)) {
      final goal = Goal.fromJson(g as Map<String, dynamic>);
      await goalsBox.put(goal.id, goal);
    }
    for (final c in (data['challenges'] as List)) {
      final challenge = Challenge.fromJson(c as Map<String, dynamic>);
      await challengesBox.put(challenge.id, challenge);
    }
    for (final w in (data['workouts'] as List)) {
      final session = WorkoutSession.fromJson(w as Map<String, dynamic>);
      await workoutsBox.put(session.id, session);
    }
    for (final n in (data['nutrition'] as List)) {
      final entry = NutritionEntry.fromJson(n as Map<String, dynamic>);
      await nutritionBox.put(entry.id, entry);
    }
    for (final w in (data['water'] as List)) {
      final entry = w as Map<String, dynamic>;
      final log = WaterLog.fromJson(entry['value'] as Map<String, dynamic>);
      await waterBox.put(entry['key'] as String, log);
    }
    for (final m in (data['moods'] as List)) {
      final entry = MoodEntry.fromJson(m as Map<String, dynamic>);
      await moodBox.put(entry.id, entry);
    }
    for (final b in (data['bodyGoal'] as List)) {
      final entry = b as Map<String, dynamic>;
      final selection = BodyGoalSelection.fromJson(entry['value'] as Map<String, dynamic>);
      await bodyGoalBox.put(entry['key'] as String, selection);
    }
  }
}
