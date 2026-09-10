import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/habit.dart';
import '../../profile/data/profile_repository.dart';

const String habitsBoxName = 'habitsBox';
const int _maxStreakFreezes = 3;

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

  Future<void> updateHabit({
    required String id,
    required String name,
    required HabitCategory category,
    required HabitFrequency frequency,
    List<int> activeDays = const [],
    int xpReward = 10,
  }) async {
    final habit = _box.get(id);
    if (habit == null) return;

    habit.name = name;
    habit.category = category;
    habit.frequency = frequency;
    habit.activeDays = activeDays;
    habit.xpReward = xpReward;

    await habit.save();
    state = _box.values.toList();
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

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

  // Manually spends one freeze to cover a specific missed due-date,
  // preventing that gap from breaking the streak on next recalculation.
  Future<bool> useStreakFreeze(String id, DateTime missedDate) async {
    final habit = _box.get(id);
    if (habit == null || habit.streakFreezesAvailable <= 0) return false;

    final normalized = Habit.dateOnly(missedDate);
    if (habit.freezeUsedDates.any((d) => Habit.dateOnly(d) == normalized)) {
      return false; // already used on this date
    }

    habit.freezeUsedDates.add(normalized);
    habit.streakFreezesAvailable--;
    _recalculateStreak(habit);
    await habit.save();
    state = _box.values.toList();
    return true;
  }

  // Streak calculation now treats a freeze-covered missed day the same
  // as a completed day, so the streak continues through it instead of
  // resetting to 0.
  void _recalculateStreak(Habit habit) {
    int streak = 0;
    DateTime cursor = Habit.dateOnly(DateTime.now());

    while (true) {
      final isDue = habit.frequency == HabitFrequency.daily ||
          habit.activeDays.contains(cursor.weekday);

      if (isDue) {
        final done = habit.completions.any((d) => Habit.dateOnly(d) == cursor);
        final frozen = habit.freezeUsedDates.any((d) => Habit.dateOnly(d) == cursor);

        if (done || frozen) {
          streak++;
        } else {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));

      if (streak > 3650) break;
    }

    habit.currentStreak = streak;
    if (streak > habit.longestStreak) {
      habit.longestStreak = streak;
    }

    // Earn 1 freeze for every 7-day streak milestone reached, capped
    // so freezes don't accumulate indefinitely on a very long streak.
    final earnedFreezes = (streak / 7).floor();
    if (earnedFreezes > 0 && habit.streakFreezesAvailable < _maxStreakFreezes) {
      habit.streakFreezesAvailable =
          (habit.streakFreezesAvailable + 1).clamp(0, _maxStreakFreezes);
    }
  }

  List<Habit> get dueToday => state.where((h) => h.isDueToday).toList();
}
