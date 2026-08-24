// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

part of 'body_type_goal.dart';

class BodyGoalSelectionAdapter extends TypeAdapter<BodyGoalSelection> {
  @override
  final int typeId = 61;

  @override
  BodyGoalSelection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BodyGoalSelection(
      goal: fields[0] as BodyTypeGoal,
      selectedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BodyGoalSelection obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.goal)
      ..writeByte(1)
      ..write(obj.selectedAt);
  }
}

class BodyTypeGoalAdapter extends TypeAdapter<BodyTypeGoal> {
  @override
  final int typeId = 60;

  @override
  BodyTypeGoal read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BodyTypeGoal.vTaper;
      case 1:
        return BodyTypeGoal.bulk;
      case 2:
        return BodyTypeGoal.leanToned;
      case 3:
        return BodyTypeGoal.cylinder;
      case 4:
        return BodyTypeGoal.hourglass;
      case 5:
      default:
        return BodyTypeGoal.athletic;
    }
  }

  @override
  void write(BinaryWriter writer, BodyTypeGoal obj) {
    switch (obj) {
      case BodyTypeGoal.vTaper:
        writer.writeByte(0);
        break;
      case BodyTypeGoal.bulk:
        writer.writeByte(1);
        break;
      case BodyTypeGoal.leanToned:
        writer.writeByte(2);
        break;
      case BodyTypeGoal.cylinder:
        writer.writeByte(3);
        break;
      case BodyTypeGoal.hourglass:
        writer.writeByte(4);
        break;
      case BodyTypeGoal.athletic:
        writer.writeByte(5);
        break;
    }
  }
}
