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

  bool get isExpired =>
      !completed &&
      DateTime.now().difference(startedAt).inDays >= durationDays &&
      daysCompleted < durationDays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateId': templateId,
        'title': title,
        'category': category.name,
        'durationDays': durationDays,
        'startedAt': startedAt.toIso8601String(),
        'checkIns': checkIns.map((d) => d.toIso8601String()).toList(),
        'completed': completed,
        'xpReward': xpReward,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        id: json['id'] as String,
        templateId: json['templateId'] as String,
        title: json['title'] as String,
        category: ChallengeCategory.values.byName(json['category'] as String),
        durationDays: json['durationDays'] as int,
        startedAt: DateTime.parse(json['startedAt'] as String),
        checkIns: (json['checkIns'] as List)
            .map((d) => DateTime.parse(d as String))
            .toList(),
        completed: json['completed'] as bool,
        xpReward: json['xpReward'] as int,
      );
}
