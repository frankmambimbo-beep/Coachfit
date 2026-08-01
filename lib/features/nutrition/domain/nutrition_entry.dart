import 'package:hive/hive.dart';

part 'nutrition_entry.g.dart';

@HiveType(typeId: 40)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
}

@HiveType(typeId: 41)
class NutritionEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  MealType mealType;

  @HiveField(3)
  int calories;

  @HiveField(4)
  DateTime date;

  NutritionEntry({
    required this.id,
    required this.name,
    required this.mealType,
    required this.calories,
    required this.date,
  });
}

@HiveType(typeId: 42)
class WaterLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int glassesConsumed;

  @HiveField(2)
  int dailyGoalGlasses;

  WaterLog({
    required this.date,
    this.glassesConsumed = 0,
    this.dailyGoalGlasses = 8,
  });

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
