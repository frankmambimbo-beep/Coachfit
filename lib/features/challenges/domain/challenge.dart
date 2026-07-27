import 'package:hive/hive.dart';

part 'challenge.g.dart';

@HiveType(typeId: 22)
enum ChallengeCategory {
  @HiveField(0)
  fitness,
  @HiveField(1)
  nutrition,
  @HiveField(2)
  mindfulness,
  @HiveField(3)
  discipline,
}

// A challenge the user has actually joined. The catalog of available
// challenges to join lives separately in challenge_templates.dart (plain
// Dart, not Hive) — this class only represents an active/joined instance.
@HiveType(typeId: 23)
class Challenge extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String templateId;

  @HiveField(2)
  String title;

  @HiveField(3)
  ChallengeCategory category;

  @HiveField(4)
  int durationDays;

  @HiveField(5)
  DateTime startedAt;

  // Each check-in day stored normalized to midnight, same pattern as Habit.
  @HiveField(6)
  List<DateTime> checkIns;

  @HiveField(7)
  bool completed;

  @HiveField(8)
  int xpReward;

  Challenge({
    required this.id,
    required this.templateId,
    required this.title,
    required this.category,
    required this.durationDays,
    required this.startedAt,
    List<DateTime>? checkIns,
    this.completed = false,
    this.xpReward = 100,
  }) : checkIns = checkIns ?? [];

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool get isCheckedInToday {
    final today = dateOnly(DateTime.now());
    return checkIns.any((d) => dateOnly(d) == today);
  }

  int get daysCompleted => checkIns.length;

  double get progress =>
      durationDays <= 0 ? 0 : (daysCompleted / durationDays).clamp(0, 1).toDouble();

  // The challenge expires if more calendar days have passed since it
  // started than its duration allows, and it still isn't finished.
  bool get isExpired =>
      !completed &&
      DateTime.now().difference(startedAt).inDays >= durationDays &&
      daysCompleted < durationDays;
}
