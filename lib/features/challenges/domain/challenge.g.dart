// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

part of 'challenge.dart';

class ChallengeAdapter extends TypeAdapter<Challenge> {
  @override
  final int typeId = 23;

  @override
  Challenge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Challenge(
      id: fields[0] as String,
      templateId: fields[1] as String,
      title: fields[2] as String,
      category: fields[3] as ChallengeCategory,
      durationDays: fields[4] as int,
      startedAt: fields[5] as DateTime,
      checkIns: (fields[6] as List).cast<DateTime>(),
      completed: fields[7] as bool,
      xpReward: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Challenge obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.templateId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.durationDays)
      ..writeByte(5)
      ..write(obj.startedAt)
      ..writeByte(6)
      ..write(obj.checkIns)
      ..writeByte(7)
      ..write(obj.completed)
      ..writeByte(8)
      ..write(obj.xpReward);
  }
}

class ChallengeCategoryAdapter extends TypeAdapter<ChallengeCategory> {
  @override
  final int typeId = 22;

  @override
  ChallengeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ChallengeCategory.fitness;
      case 1:
        return ChallengeCategory.nutrition;
      case 2:
        return ChallengeCategory.mindfulness;
      case 3:
      default:
        return ChallengeCategory.discipline;
    }
  }

  @override
  void write(BinaryWriter writer, ChallengeCategory obj) {
    switch (obj) {
      case ChallengeCategory.fitness:
        writer.writeByte(0);
        break;
      case ChallengeCategory.nutrition:
        writer.writeByte(1);
        break;
      case ChallengeCategory.mindfulness:
        writer.writeByte(2);
        break;
      case ChallengeCategory.discipline:
        writer.writeByte(3);
        break;
    }
  }
}
