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

  // NEW: updates title/category/target/unit/deadline/xp in place.
  // Deliberately does NOT touch currentValue or completed — editing
  // the goal's definition shouldn't wipe out progress already logged
  // toward it.
  Future<void> updateGoal({
    required String id,
    required String title,
    required GoalCategory category,
    required double targetValue,
    required String unit,
    DateTime? deadline,
    int xpReward = 50,
  }) async {
    final goal = _box.get(id);
    if (goal == null) return;

    goal.title = title;
    goal.category = category;
    goal.targetValue = targetValue;
    goal.unit = unit;
    goal.deadline = deadline;
    goal.xpReward = xpReward;

    // If editing the target down below what's already been logged,
    // re-check completion status so it stays consistent.
    final wasCompleted = goal.completed;
    if (!wasCompleted && goal.currentValue >= goal.targetValue) {
      goal.completed = true;
      ref.read(profileRepositoryProvider.notifier).addXp(goal.xpReward);
    }

    await goal.save();
    state = _box.values.toList();
  }

  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
    state = _box.values.toList();
  }

  Future<void> addProgress(String id, double delta) async {
    final goal = _box.get(id);
    if (goal == null) return;

    final wasCompleted = goal.completed;
    goal.currentValue = (goal.currentValue + delta).clamp(0, goal.targetValue);

    if (!wasCompleted && goal.currentValue >= goal.targetValue) {
      goal.completed = true;
      ref.read(profileRepositoryProvider.notifier).addXp(goal.xpReward);
    } else if (wasCompleted && goal.currentValue < goal.targetValue) {
      goal.completed = false;
      ref.read(profileRepositoryProvider.notifier).addXp(-goal.xpReward);
    }

    await goal.save();
    state = _box.values.toList();
  }
}
