import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 50)
enum MoodLevel {
  @HiveField(0)
  terrible,
  @HiveField(1)
  bad,
  @HiveField(2)
  okay,
  @HiveField(3)
  good,
  @HiveField(4)
  great,
}

@HiveType(typeId: 51)
class MoodEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  MoodLevel mood;

  @HiveField(2)
  String journalText;

  @HiveField(3)
  DateTime date;

  MoodEntry({
    required this.id,
    required this.mood,
    this.journalText = '',
    required this.date,
  });

  static DateTime dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
