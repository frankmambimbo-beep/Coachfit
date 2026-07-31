import 'package:hive/hive.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 30)
enum WorkoutType {
  @HiveField(0)
  strength,
  @HiveField(1)
  cardio,
  @HiveField(2)
  flexibility,
  @HiveField(3)
  sports,
  @HiveField(4)
  other,
}

// A single exercise within a session. Not a HiveObject on its own —
// it's embedded inside WorkoutSession.exercises, so it only needs a
// plain @HiveType, not extends HiveObject.
@HiveType(typeId: 31)
class ExerciseEntry {
  @HiveField(0)
  String name;

  @HiveField(1)
  int sets;

  @HiveField(2)
  int reps;

  // Weight in kg. 0 for bodyweight exercises.
  @HiveField(3)
  double weightKg;

  ExerciseEntry({
    required this.name,
    required this.sets,
    required this.reps,
    this.weightKg = 0,
  });
}

@HiveType(typeId: 32)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  WorkoutType type;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  int durationMinutes;

  @HiveField(5)
  List<ExerciseEntry> exercises;

  @HiveField(6)
  String notes;

  @HiveField(7)
  int xpReward;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.durationMinutes = 0,
    List<ExerciseEntry>? exercises,
    this.notes = '',
    this.xpReward = 30,
  }) : exercises = exercises ?? [];

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);
}
