import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../domain/body_type_goal.dart';

const String bodyGoalBoxName = 'bodyGoalBox';
const String bodyGoalKey = 'current';

final bodyGoalRepositoryProvider =
    StateNotifierProvider<BodyGoalRepository, BodyTypeGoal?>((ref) {
  return BodyGoalRepository();
});

class BodyGoalRepository extends StateNotifier<BodyTypeGoal?> {
  late Box<BodyGoalSelection> _box;

  BodyGoalRepository() : super(null) {
    _init();
  }

  void _init() {
    _box = Hive.box<BodyGoalSelection>(bodyGoalBoxName);
    state = _box.get(bodyGoalKey)?.goal;
  }

  Future<void> selectGoal(BodyTypeGoal goal) async {
    await _box.put(
      bodyGoalKey,
      BodyGoalSelection(goal: goal, selectedAt: DateTime.now()),
    );
    state = goal;
  }
}
