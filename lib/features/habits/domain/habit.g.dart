// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner. If you ever get a machine with the Flutter SDK installed,
// you can delete this and run the real code generator instead.

part of 'habit.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 10;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as HabitCategory,
      frequency: fields[3] as HabitFrequency,
      activeDays: (fields[4] as List).cast<int>(),
      createdAt: fields[5] as DateTime,
      completions: (fields[6] as List).cast<DateTime>(),
      currentStreak: fields[7] as int,
      longestStreak: fields[8] as int,
      xpReward: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.activeDays)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.completions)
      ..writeByte(7)
      ..write(obj.currentStreak)
      ..writeByte(8)
      ..write(obj.longestStreak)
      ..writeByte(9)
      ..write(obj.xpReward);
  }
}

class HabitCategoryAdapter extends TypeAdapter<HabitCategory> {
  @override
  final int typeId = 11;

  @override
  HabitCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitCategory.fitness;
      case 1:
        return HabitCategory.nutrition;
      case 2:
        return HabitCategory.mindfulness;
      case 3:
        return HabitCategory.sleep;
      case 4:
      default:
        return HabitCategory.other;
    }
  }

  @override
  void write(BinaryWriter writer, HabitCategory obj) {
    switch (obj) {
      case HabitCategory.fitness:
        writer.writeByte(0);
        break;
      case HabitCategory.nutrition:
        writer.writeByte(1);
        break;
      case HabitCategory.mindfulness:
        writer.writeByte(2);
        break;
      case HabitCategory.sleep:
        writer.writeByte(3);
        break;
      case HabitCategory.other:
        writer.writeByte(4);
        break;
    }
  }
}

class HabitFrequencyAdapter extends TypeAdapter<HabitFrequency> {
  @override
  final int typeId = 12;

  @override
  HabitFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitFrequency.daily;
      case 1:
      default:
        return HabitFrequency.specificDays;
    }
  }

  @override
  void write(BinaryWriter writer, HabitFrequency obj) {
    switch (obj) {
      case HabitFrequency.daily:
        writer.writeByte(0);
        break;
      case HabitFrequency.specificDays:
        writer.writeByte(1);
        break;
    }
  }
}
