import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/workout_session.dart';
import '../../profile/data/profile_repository.dart';

const String workoutsBoxName = 'workoutsBox';

final workoutRepositoryProvider =
    StateNotifierProvider<WorkoutRepository, List<WorkoutSession>>((ref) {
  return WorkoutRepository(ref);
});

class WorkoutRepository extends StateNotifier<List<WorkoutSession>> {
  final Ref ref;
  late Box<WorkoutSession> _box;

  WorkoutRepository(this.ref) : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<WorkoutSession>(workoutsBoxName);
    // Most recent first, so history and "last workout" lookups are easy.
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addSession({
    required String title,
    required WorkoutType type,
    required DateTime date,
    int durationMinutes = 0,
    required List<ExerciseEntry> exercises,
    String notes = '',
  }) async {
    // A bit more XP for a fuller session — rewards effort, not just
    // showing up, while still guaranteeing a minimum for any logged workout.
    final xp = 20 + (exercises.length * 5).clamp(0, 60);

    final session = WorkoutSession(
      id: const Uuid().v4(),
      title: title,
      type: type,
      date: date,
      durationMinutes: durationMinutes,
      exercises: exercises,
      notes: notes,
      xpReward: xp,
    );
    await _box.put(session.id, session);
    ref.read(profileRepositoryProvider.notifier).addXp(xp);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteSession(String id) async {
    final session = _box.get(id);
    if (session != null) {
      // Reverse the XP so deleting a mistaken entry doesn't leave a
      // permanent, unearned bump in the user's level.
      ref.read(profileRepositoryProvider.notifier).addXp(-session.xpReward);
    }
    await _box.delete(id);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  WorkoutSession? get lastSession => state.isEmpty ? null : state.first;
}
