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
  @HiveField(6)
  pear, // fuller lower body, want to build/balance upper body
  @HiveField(7)
  apple, // weight carried in the midsection, want a trimmer waist
  @HiveField(8)
  diamond, // weight carried centrally, narrower shoulders/hips
  @HiveField(9)
  spoon, // fuller hips/thighs with a defined waist
}
