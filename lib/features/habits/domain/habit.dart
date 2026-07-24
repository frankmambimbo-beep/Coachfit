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

  // Only used when frequency == specificDays.
  // Uses DateTime.weekday convention: Monday=1 ... Sunday=7.
  @HiveField(4)
  List<int> activeDays;

  @HiveField(5)
  DateTime createdAt;

  // Each completed day is stored normalized to midnight (year/month/day
  // only), so "did I complete this today" is a simple equality check.
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

  // Strips the time component so date comparisons are reliable.
  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool get isCompletedToday {
    final today = dateOnly(DateTime.now());
    return completions.any((d) => dateOnly(d) == today);
  }

  // Whether this habit is "due" today, based on its frequency.
  bool get isDueToday {
    if (frequency == HabitFrequency.daily) return true;
    return activeDays.contains(DateTime.now().weekday);
  }
}
