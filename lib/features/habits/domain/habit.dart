import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 11)
enum HabitCategory {
  @HiveField(0)
  fitness,
  @HiveField(1)
  nutrition,
  @HiveField(2)
  mindfulness,
  @HiveField(3)
  sleep,
  @HiveField(4)
  other,
}

@HiveType(typeId: 12)
enum HabitFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  specificDays,
}

@HiveType(typeId: 10)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  HabitCategory category;

  @HiveField(3)
  HabitFrequency frequency;

  @HiveField(4)
  List<int> activeDays;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<DateTime> completions;

  @HiveField(7)
  int currentStreak;

  @HiveField(8)
  int longestStreak;

  @HiveField(9)
  int xpReward;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.frequency,
    this.activeDays = const [],
    required this.createdAt,
    List<DateTime>? completions,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.xpReward = 10,
  }) : completions = completions ?? [];

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool get isCompletedToday {
    final today = dateOnly(DateTime.now());
    return completions.any((d) => dateOnly(d) == today);
  }

  bool get isDueToday {
    if (frequency == HabitFrequency.daily) return true;
    return activeDays.contains(DateTime.now().weekday);
  }

  // Used by the backup/export feature to serialize this habit into
  // plain JSON-compatible data.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category.name,
        'frequency': frequency.name,
        'activeDays': activeDays,
        'createdAt': createdAt.toIso8601String(),
        'completions': completions.map((d) => d.toIso8601String()).toList(),
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'xpReward': xpReward,
      };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
        id: json['id'] as String,
        name: json['name'] as String,
        category: HabitCategory.values.byName(json['category'] as String),
        frequency: HabitFrequency.values.byName(json['frequency'] as String),
        activeDays: (json['activeDays'] as List).cast<int>(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        completions: (json['completions'] as List)
            .map((d) => DateTime.parse(d as String))
            .toList(),
        currentStreak: json['currentStreak'] as int,
        longestStreak: json['longestStreak'] as int,
        xpReward: json['xpReward'] as int,
      );
}
