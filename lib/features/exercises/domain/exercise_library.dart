import 'exercise_info.dart';

// A broad reference library covering bodyweight, free-weight, band,
// and cardio movements across all major muscle groups. Body-type
// routines (body_type_catalog.dart) pull ordered subsets from this
// list rather than hardcoding exercise names separately.
const List<ExerciseInfo> exerciseLibrary = [
  // Bodyweight
  ExerciseInfo(name: 'Push-ups', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.chest),
  ExerciseInfo(name: 'Bodyweight Squats', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Lunges', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Glute Bridges', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.glutes),
  ExerciseInfo(name: 'Plank', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.core),
  ExerciseInfo(name: 'Mountain Climbers', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.core),
  ExerciseInfo(name: 'Pull-ups', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.back),
  ExerciseInfo(name: 'Dips', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.arms),
  ExerciseInfo(name: 'Burpees', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.fullBody),
  ExerciseInfo(name: 'Jumping Jacks', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.cardio),
  ExerciseInfo(name: 'Wall Sit', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Superman Hold', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.back),
  ExerciseInfo(name: 'Side Plank', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.core),
  ExerciseInfo(name: 'Step-ups', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),

  // Free weight (dumbbell / barbell)
  ExerciseInfo(name: 'Squats', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Deadlifts', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.fullBody),
  ExerciseInfo(name: 'Bench Press', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.chest),
  ExerciseInfo(name: 'Barbell Rows', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.back),
  ExerciseInfo(name: 'Overhead Shoulder Press', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.shoulders),
  ExerciseInfo(name: 'Lateral Raises', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.shoulders),
  ExerciseInfo(name: 'Bicep Curls', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.arms),
  ExerciseInfo(name: 'Tricep Extensions', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.arms),
  ExerciseInfo(name: 'Hip Thrusts', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.glutes),
  ExerciseInfo(name: 'Lat Pulldown', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.back),
  ExerciseInfo(name: 'Goblet Squats', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Romanian Deadlifts', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Dumbbell Rows', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.back),

  // Resistance band
  ExerciseInfo(name: 'Band Face Pulls', category: ExerciseCategory.resistanceBand, muscleGroup: MuscleGroup.back),
  ExerciseInfo(name: 'Band Pull-Aparts', category: ExerciseCategory.resistanceBand, muscleGroup: MuscleGroup.shoulders),
  ExerciseInfo(name: 'Band Squats', category: ExerciseCategory.resistanceBand, muscleGroup: MuscleGroup.legs),

  // Cardio
  ExerciseInfo(name: 'Jump Rope', category: ExerciseCategory.cardio, muscleGroup: MuscleGroup.cardio),
  ExerciseInfo(name: 'Sprints', category: ExerciseCategory.cardio, muscleGroup: MuscleGroup.cardio),
  ExerciseInfo(name: 'Cycling', category: ExerciseCategory.cardio, muscleGroup: MuscleGroup.cardio),
  ExerciseInfo(name: 'HIIT Intervals', category: ExerciseCategory.cardio, muscleGroup: MuscleGroup.cardio),
];

ExerciseInfo? findExercise(String name) {
  try {
    return exerciseLibrary.firstWhere((e) => e.name == name);
  } catch (_) {
    return null;
  }
}
