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

  const ExerciseInfo({
    required this.name,
    required this.category,
    required this.muscleGroup,
  });

  bool get needsWeight => category == ExerciseCategory.freeWeight;
}
