// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

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
      // Habits saved before this update won't have fields 10/11 in
      // their stored binary data — default to 0/empty so existing
      // habits still load without crashing.
      streakFreezesAvailable: fields[10] as int? ?? 0,
      freezeUsedDates: (fields[11] as List?)?.cast<DateTime>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.xpReward)
      ..writeByte(10)
      ..write(obj.streakFreezesAvailable)
      ..writeByte(11)
      ..write(obj.freezeUsedDates);
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
