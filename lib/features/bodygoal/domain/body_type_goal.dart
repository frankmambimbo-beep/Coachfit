import 'package:hive/hive.dart';

part 'body_type_goal.g.dart';

@HiveType(typeId: 60)
enum BodyTypeGoal {
  @HiveField(0)
  vTaper,
  @HiveField(1)
  bulk,
  @HiveField(2)
  leanToned,
  @HiveField(3)
  cylinder,
  @HiveField(4)
  hourglass,
  @HiveField(5)
  athletic,
  @HiveField(6)
  pear,
  @HiveField(7)
  apple,
  @HiveField(8)
  diamond,
  @HiveField(9)
  spoon,
}

@HiveType(typeId: 61)
class BodyGoalSelection extends HiveObject {
  @HiveField(0)
  BodyTypeGoal goal;

  @HiveField(1)
  DateTime selectedAt;

  BodyGoalSelection({required this.goal, required this.selectedAt});

  Map<String, dynamic> toJson() => {
        'goal': goal.name,
        'selectedAt': selectedAt.toIso8601String(),
      };

  factory BodyGoalSelection.fromJson(Map<String, dynamic> json) => BodyGoalSelection(
        goal: BodyTypeGoal.values.byName(json['goal'] as String),
        selectedAt: DateTime.parse(json['selectedAt'] as String),
      );
}
