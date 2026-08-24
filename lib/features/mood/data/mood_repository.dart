import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/mood_entry.dart';

const String moodBoxName = 'moodBox';

final moodRepositoryProvider =
    StateNotifierProvider<MoodRepository, List<MoodEntry>>((ref) {
  return MoodRepository();
});

class MoodRepository extends StateNotifier<List<MoodEntry>> {
  late Box<MoodEntry> _box;

  MoodRepository() : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<MoodEntry>(moodBoxName);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  MoodEntry? get todayEntry {
    final today = MoodEntry.dateOnly(DateTime.now());
    try {
      return state.firstWhere((e) => MoodEntry.dateOnly(e.date) == today);
    } catch (_) {
      return null;
    }
  }

  // One check-in per day: if today's entry already exists, this
  // updates it in place instead of creating a duplicate.
  Future<void> logToday({required MoodLevel mood, String journalText = ''}) async {
    final existing = todayEntry;

    if (existing != null) {
      existing.mood = mood;
      existing.journalText = journalText;
      await existing.save();
    } else {
      final entry = MoodEntry(
        id: const Uuid().v4(),
        mood: mood,
        journalText: journalText,
        date: DateTime.now(),
      );
      await _box.put(entry.id, entry);
    }

    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }
}
