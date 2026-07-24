import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/habit.dart';
import '../../profile/data/profile_repository.dart';

const String habitsBoxName = 'habitsBox';

// Any widget doing ref.watch(habitsRepositoryProvider) rebuilds
// automatically whenever a habit is added, completed, or deleted.
final habitsRepositoryProvider =
    StateNotifierProvider<HabitsRepository, List<Habit>>((ref) {
  return HabitsRepository(ref);
});

class HabitsRepository extends StateNotifier<List<Habit>> {
  final Ref ref;
  late Box<Habit> _box;

  HabitsRepository(this.ref) : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Habit>(habitsBoxName);
    state = _box.values.toList();
  }

  Future<void> addHabit({
    required String name,
    required HabitCategory category,
    required HabitFrequency frequency,
    List<int> activeDays = const [],
    int xpReward = 10,
  }) async {
    final habit = Habit(
      id: const Uuid().v4(),
      name: name,
      category: category,
      frequency: frequency,
      activeDays: activeDays,
      createdAt: DateTime.now(),
      xpReward: xpReward,
    );
    await _box.put(habit.id, habit);
    state = _box.values.toList();
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  // Toggles today's completion. Marking it done recalculates the streak
  // and awards XP; un-marking (in case of a mis-tap) reverses both.
  Future<void> toggleCompletionToday(String id) async {
    final habit = _box.get(id);
    if (habit == null) return;

    final today = Habit.dateOnly(DateTime.now());
    final alreadyDone =
        habit.completions.any((d) => Habit.dateOnly(d) == today);

    if (alreadyDone) {
      habit.completions.removeWhere((d) => Habit.dateOnly(d) == today);
      ref.read(profileRepositoryProvider.notifier).addXp(-habit.xpReward);
    } else {
      habit.completions.add(today);
      ref.read(profileRepositoryProvider.notifier).addXp(habit.xpReward);
    }

    _recalculateStreak(habit);
    await habit.save();
    state = _box.values.toList();
  }

  // Walks backward day by day from today, counting an unbroken run of
  // completions. Only counts days the habit was actually due, so a
  // "Mon/Wed/Fri" habit isn't penalized for a Tuesday.
  void _recalculateStreak(Habit habit) {
    int streak = 0;
    DateTime cursor = Habit.dateOnly(DateTime.now());

    while (true) {
      final isDue = habit.frequency == HabitFrequency.daily ||
          habit.activeDays.contains(cursor.weekday);

      if (isDue) {
        final done =
            habit.completions.any((d) => Habit.dateOnly(d) == cursor);
        if (done) {
          streak++;
        } else {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));

      if (streak > 3650) break; // safety valve, never loop forever
    }

    habit.currentStreak = streak;
    if (streak > habit.longestStreak) {
      habit.longestStreak = streak;
    }
  }

  List<Habit> get dueToday => state.where((h) => h.isDueToday).toList();
}
