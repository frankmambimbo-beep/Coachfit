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

@HiveType(typeId: 31)
class ExerciseEntry {
  @HiveField(0)
  String name;

  @HiveField(1)
  int sets;

  @HiveField(2)
  int reps;

  @HiveField(3)
  double weightKg;

  ExerciseEntry({
    required this.name,
    required this.sets,
    required this.reps,
    this.weightKg = 0,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
      };

  factory ExerciseEntry.fromJson(Map<String, dynamic> json) => ExerciseEntry(
        name: json['name'] as String,
        sets: json['sets'] as int,
        reps: json['reps'] as int,
        weightKg: (json['weightKg'] as num).toDouble(),
      );
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'date': date.toIso8601String(),
        'durationMinutes': durationMinutes,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'notes': notes,
        'xpReward': xpReward,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: json['id'] as String,
        title: json['title'] as String,
        type: WorkoutType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
        durationMinutes: json['durationMinutes'] as int,
        exercises: (json['exercises'] as List)
            .map((e) => ExerciseEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String,
        xpReward: json['xpReward'] as int,
      );
}
