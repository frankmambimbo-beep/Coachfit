import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 20)
enum GoalCategory {
  @HiveField(0)
  weight,
  @HiveField(1)
  strength,
  @HiveField(2)
  endurance,
  @HiveField(3)
  habit,
  @HiveField(4)
  custom,
}

@HiveType(typeId: 21)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  GoalCategory category;

  @HiveField(3)
  double targetValue;

  @HiveField(4)
  double currentValue;

  @HiveField(5)
  String unit;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? deadline;

  @HiveField(8)
  bool completed;

  @HiveField(9)
  int xpReward;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.targetValue,
    this.currentValue = 0,
    required this.unit,
    required this.createdAt,
    this.deadline,
    this.completed = false,
    this.xpReward = 50,
  });

  double get progress =>
      targetValue <= 0 ? 0 : (currentValue / targetValue).clamp(0, 1).toDouble();

  bool get isOverdue =>
      !completed && deadline != null && DateTime.now().isAfter(deadline!);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'unit': unit,
        'createdAt': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
        'completed': completed,
        'xpReward': xpReward,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'] as String,
        title: json['title'] as String,
        category: GoalCategory.values.byName(json['category'] as String),
        targetValue: (json['targetValue'] as num).toDouble(),
        currentValue: (json['currentValue'] as num).toDouble(),
        unit: json['unit'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
        completed: json['completed'] as bool,
        xpReward: json['xpReward'] as int,
      );
}
