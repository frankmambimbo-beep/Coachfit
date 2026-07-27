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

  // e.g. targetValue=5, unit="kg" for "lose 5kg"; targetValue=20, unit="workouts"
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
}
