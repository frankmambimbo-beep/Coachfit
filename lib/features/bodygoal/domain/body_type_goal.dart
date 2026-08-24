import 'package:hive/hive.dart';

part 'body_type_goal.g.dart';

@HiveType(typeId: 60)
enum BodyTypeGoal {
  @HiveField(0)
  vTaper, // broad shoulders, narrow waist
  @HiveField(1)
  bulk, // overall size and mass
  @HiveField(2)
  leanToned, // low body fat, defined muscle
  @HiveField(3)
  cylinder, // balanced, straight-up-and-down frame
  @HiveField(4)
  hourglass, // curves, balanced upper/lower with a defined waist
  @HiveField(5)
  athletic, // general balanced athletic build
}

@HiveType(typeId: 61)
class BodyGoalSelection extends HiveObject {
  @HiveField(0)
  BodyTypeGoal goal;

  @HiveField(1)
  DateTime selectedAt;

  BodyGoalSelection({required this.goal, required this.selectedAt});
}
