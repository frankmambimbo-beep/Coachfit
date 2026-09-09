/// Static reference data — not stored in Hive, since the library itself
/// doesn't change per-user. Used by both the body-goal catalog (to
/// build ordered routines) and the workout logger (to know which
/// exercises need a weight and which don't).
enum ExerciseCategory { bodyweight, freeWeight, resistanceBand, cardio }

enum MuscleGroup { chest, back, shoulders, arms, legs, glutes, core, fullBody, cardio }

class ExerciseInfo {
  final String name;
  final ExerciseCategory category;
  final MuscleGroup muscleGroup;

  /// Any ONE of these being present in the person's onboarding
  /// equipment list makes this exercise available. Empty means no
  /// special equipment needed beyond bodyweight. 'Full Gym' always
  /// satisfies any requirement (checked separately, not listed here).
  final List<String> requiredEquipment;

  const ExerciseInfo({
    required this.name,
    required this.category,
    required this.muscleGroup,
    this.requiredEquipment = const [],
  });

  bool get needsWeight => category == ExerciseCategory.freeWeight;

  /// Whether this exercise can actually be done with what the person
  /// said they have access to during onboarding.
  bool isAvailableWith(List<String> userEquipment) {
    if (requiredEquipment.isEmpty) return true;
    if (userEquipment.contains('Full Gym')) return true;
    return userEquipment.any((e) => requiredEquipment.contains(e));
  }
}
