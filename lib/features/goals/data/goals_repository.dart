import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/goal.dart';
import '../../profile/data/profile_repository.dart';

const String goalsBoxName = 'goalsBox';

final goalsRepositoryProvider =
    StateNotifierProvider<GoalsRepository, List<Goal>>((ref) {
  return GoalsRepository(ref);
});

class GoalsRepository extends StateNotifier<List<Goal>> {
  final Ref ref;
  late Box<Goal> _box;

  GoalsRepository(this.ref) : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<Goal>(goalsBoxName);
    state = _box.values.toList();
  }

  Future<void> addGoal({
    required String title,
    required GoalCategory category,
    required double targetValue,
    required String unit,
    DateTime? deadline,
    int xpReward = 50,
  }) async {
    final goal = Goal(
      id: const Uuid().v4(),
      title: title,
      category: category,
      targetValue: targetValue,
      unit: unit,
      createdAt: DateTime.now(),
      deadline: deadline,
      xpReward: xpReward,
    );
    await _box.put(goal.id, goal);
    state = _box.values.toList();
  }

  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  // Adds `delta` to the goal's progress (can be negative to correct a
  // mis-tap). Awards XP exactly once, the moment it first hits target.
  Future<void> addProgress(String id, double delta) async {
    final goal = _box.get(id);
    if (goal == null) return;

    final wasCompleted = goal.completed;
    goal.currentValue = (goal.currentValue + delta).clamp(0, goal.targetValue);

    if (!wasCompleted && goal.currentValue >= goal.targetValue) {
      goal.completed = true;
      ref.read(profileRepositoryProvider.notifier).addXp(goal.xpReward);
    } else if (wasCompleted && goal.currentValue < goal.targetValue) {
      // Reversed below target (e.g. accidental over-tap correction)
      goal.completed = false;
      ref.read(profileRepositoryProvider.notifier).addXp(-goal.xpReward);
    }

    await goal.save();
    state = _box.values.toList();
  }
}
