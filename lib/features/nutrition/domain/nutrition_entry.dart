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

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mealType': mealType.name,
        'calories': calories,
        'date': date.toIso8601String(),
      };

  factory NutritionEntry.fromJson(Map<String, dynamic> json) => NutritionEntry(
        id: json['id'] as String,
        name: json['name'] as String,
        mealType: MealType.values.byName(json['mealType'] as String),
        calories: json['calories'] as int,
        date: DateTime.parse(json['date'] as String),
      );
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

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'glassesConsumed': glassesConsumed,
        'dailyGoalGlasses': dailyGoalGlasses,
      };

  factory WaterLog.fromJson(Map<String, dynamic> json) => WaterLog(
        date: DateTime.parse(json['date'] as String),
        glassesConsumed: json['glassesConsumed'] as int,
        dailyGoalGlasses: json['dailyGoalGlasses'] as int,
      );
}
