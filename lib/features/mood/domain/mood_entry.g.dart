// GENERATED CODE - manually written to mirror what `hive_generator` would
// normally produce, since this project builds from a phone and can't run
// build_runner.

part of 'mood_entry.dart';

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 51;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      id: fields[0] as String,
      mood: fields[1] as MoodLevel,
      journalText: fields[2] as String,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mood)
      ..writeByte(2)
      ..write(obj.journalText)
      ..writeByte(3)
      ..write(obj.date);
  }
}

class MoodLevelAdapter extends TypeAdapter<MoodLevel> {
  @override
  final int typeId = 50;

  @override
  MoodLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MoodLevel.terrible;
      case 1:
        return MoodLevel.bad;
      case 2:
        return MoodLevel.okay;
      case 3:
        return MoodLevel.good;
      case 4:
      default:
        return MoodLevel.great;
    }
  }

  @override
  void write(BinaryWriter writer, MoodLevel obj) {
    switch (obj) {
      case MoodLevel.terrible:
        writer.writeByte(0);
        break;
      case MoodLevel.bad:
        writer.writeByte(1);
        break;
      case MoodLevel.okay:
        writer.writeByte(2);
        break;
      case MoodLevel.good:
        writer.writeByte(3);
        break;
      case MoodLevel.great:
        writer.writeByte(4);
        break;
    }
  }
}
