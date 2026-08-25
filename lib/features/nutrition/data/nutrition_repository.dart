import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../domain/nutrition_entry.dart';

const String nutritionBoxName = 'nutritionBox';
const String waterBoxName = 'waterBox';

final nutritionRepositoryProvider =
    StateNotifierProvider<NutritionRepository, List<NutritionEntry>>((ref) {
  return NutritionRepository();
});

class NutritionRepository extends StateNotifier<List<NutritionEntry>> {
  late Box<NutritionEntry> _box;

  NutritionRepository() : super([]) {
    _init();
  }

  void _init() {
    _box = Hive.box<NutritionEntry>(nutritionBoxName);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addEntry({
    required String name,
    required MealType mealType,
    required int calories,
    DateTime? date,
  }) async {
    final entry = NutritionEntry(
      id: const Uuid().v4(),
      name: name,
      mealType: mealType,
      calories: calories,
      date: date ?? DateTime.now(),
    );
    await _box.put(entry.id, entry);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  List<NutritionEntry> entriesForDay(DateTime day) {
    final target = DateTime(day.year, day.month, day.day);
    return state.where((e) {
      final d = e.date;
      return DateTime(d.year, d.month, d.day) == target;
    }).toList();
  }

  int caloriesForDay(DateTime day) =>
      entriesForDay(day).fold(0, (sum, e) => sum + e.calories);
}

final waterRepositoryProvider =
    StateNotifierProvider<WaterRepository, WaterLog>((ref) {
  return WaterRepository();
});

class WaterRepository extends StateNotifier<WaterLog> {
  late Box<WaterLog> _box;

  WaterRepository() : super(WaterLog(date: WaterLog.dateOnly(DateTime.now()))) {
    _init();
  }

  String get _todayKey =>
      WaterLog.dateOnly(DateTime.now()).toIso8601String();

  void _init() {
    _box = Hive.box<WaterLog>(waterBoxName);
    final existing = _box.get(_todayKey);
    if (existing != null) {
      state = existing;
    } else {
      state = WaterLog(date: WaterLog.dateOnly(DateTime.now()));
    }
  }

  Future<void> addGlass() async {
    state.glassesConsumed += 1;
    await _box.put(_todayKey, state);
    state = _box.get(_todayKey)!;
  }

  Future<void> removeGlass() async {
    if (state.glassesConsumed > 0) {
      state.glassesConsumed -= 1;
      await _box.put(_todayKey, state);
      state = _box.get(_todayKey)!;
    }
  }

  Future<void> setGoal(int glasses) async {
    state.dailyGoalGlasses = glasses;
    await _box.put(_todayKey, state);
    state = _box.get(_todayKey)!;
  }

  // Used by the Stats screen to chart the last 7 days of water intake.
  // Days with no logged entry (the box has no key for that date) are
  // returned as a WaterLog with 0 glasses, so the chart always has a
  // full 7-day range instead of gaps.
  List<WaterLog> last7Days() {
    final today = WaterLog.dateOnly(DateTime.now());
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final existing = _box.get(day.toIso8601String());
      return existing ?? WaterLog(date: day, glassesConsumed: 0);
    });
  }
}
