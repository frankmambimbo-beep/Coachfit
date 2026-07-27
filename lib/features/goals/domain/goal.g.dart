// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

part of 'goal.dart';

class GoalAdapter extends TypeAdapter<Goal> {
  @override
  final int typeId = 21;

  @override
  Goal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Goal(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as GoalCategory,
      targetValue: fields[3] as double,
      currentValue: fields[4] as double,
      unit: fields[5] as String,
      createdAt: fields[6] as DateTime,
      deadline: fields[7] as DateTime?,
      completed: fields[8] as bool,
      xpReward: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Goal obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.targetValue)
      ..writeByte(4)
      ..write(obj.currentValue)
      ..writeByte(5)
      ..write(obj.unit)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.deadline)
      ..writeByte(8)
      ..write(obj.completed)
      ..writeByte(9)
      ..write(obj.xpReward);
  }
}

class GoalCategoryAdapter extends TypeAdapter<GoalCategory> {
  @override
  final int typeId = 20;

  @override
  GoalCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return GoalCategory.weight;
      case 1:
        return GoalCategory.strength;
      case 2:
        return GoalCategory.endurance;
      case 3:
        return GoalCategory.habit;
      case 4:
      default:
        return GoalCategory.custom;
    }
  }

  @override
  void write(BinaryWriter writer, GoalCategory obj) {
    switch (obj) {
      case GoalCategory.weight:
        writer.writeByte(0);
        break;
      case GoalCategory.strength:
        writer.writeByte(1);
        break;
      case GoalCategory.endurance:
        writer.writeByte(2);
        break;
      case GoalCategory.habit:
        writer.writeByte(3);
        break;
      case GoalCategory.custom:
        writer.writeByte(4);
        break;
    }
  }
}
