// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

part of 'nutrition_entry.dart';

class NutritionEntryAdapter extends TypeAdapter<NutritionEntry> {
  @override
  final int typeId = 41;

  @override
  NutritionEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionEntry(
      id: fields[0] as String,
      name: fields[1] as String,
      mealType: fields[2] as MealType,
      calories: fields[3] as int,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.mealType)
      ..writeByte(3)
      ..write(obj.calories)
      ..writeByte(4)
      ..write(obj.date);
  }
}

class WaterLogAdapter extends TypeAdapter<WaterLog> {
  @override
  final int typeId = 42;

  @override
  WaterLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WaterLog(
      date: fields[0] as DateTime,
      glassesConsumed: fields[1] as int,
      dailyGoalGlasses: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WaterLog obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.glassesConsumed)
      ..writeByte(2)
      ..write(obj.dailyGoalGlasses);
  }
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 40;

  @override
  MealType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      case 3:
      default:
        return MealType.snack;
    }
  }

  @override
  void write(BinaryWriter writer, MealType obj) {
    switch (obj) {
      case MealType.breakfast:
        writer.writeByte(0);
        break;
      case MealType.lunch:
        writer.writeByte(1);
        break;
      case MealType.dinner:
        writer.writeByte(2);
        break;
      case MealType.snack:
        writer.writeByte(3);
        break;
    }
  }
}
