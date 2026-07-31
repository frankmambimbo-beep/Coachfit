// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

part of 'workout_session.dart';

class WorkoutSessionAdapter extends TypeAdapter<WorkoutSession> {
  @override
  final int typeId = 32;

  @override
  WorkoutSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSession(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as WorkoutType,
      date: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      exercises: (fields[5] as List).cast<ExerciseEntry>(),
      notes: fields[6] as String,
      xpReward: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSession obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.exercises)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.xpReward);
  }
}

class ExerciseEntryAdapter extends TypeAdapter<ExerciseEntry> {
  @override
  final int typeId = 31;

  @override
  ExerciseEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseEntry(
      name: fields[0] as String,
      sets: fields[1] as int,
      reps: fields[2] as int,
      weightKg: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.sets)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weightKg);
  }
}

class WorkoutTypeAdapter extends TypeAdapter<WorkoutType> {
  @override
  final int typeId = 30;

  @override
  WorkoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutType.strength;
      case 1:
        return WorkoutType.cardio;
      case 2:
        return WorkoutType.flexibility;
      case 3:
        return WorkoutType.sports;
      case 4:
      default:
        return WorkoutType.other;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutType obj) {
    switch (obj) {
      case WorkoutType.strength:
        writer.writeByte(0);
        break;
      case WorkoutType.cardio:
        writer.writeByte(1);
        break;
      case WorkoutType.flexibility:
        writer.writeByte(2);
        break;
      case WorkoutType.sports:
        writer.writeByte(3);
        break;
      case WorkoutType.other:
        writer.writeByte(4);
        break;
    }
  }
}
