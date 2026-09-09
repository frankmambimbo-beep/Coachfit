import 'exercise_info.dart';

const List<ExerciseInfo> exerciseLibrary = [
  // Bodyweight — no equipment needed unless noted
  ExerciseInfo(name: 'Push-ups', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.chest),
  ExerciseInfo(name: 'Bodyweight Squats', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Lunges', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Glute Bridges', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.glutes),
  ExerciseInfo(name: 'Plank', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.core),
  ExerciseInfo(name: 'Mountain Climbers', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.core),
  ExerciseInfo(name: 'Pull-ups', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.back, requiredEquipment: ['Pull-up Bar']),
  ExerciseInfo(name: 'Dips', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.arms, requiredEquipment: ['Pull-up Bar']),
  ExerciseInfo(name: 'Burpees', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.fullBody),
  ExerciseInfo(name: 'Jumping Jacks', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.cardio),
  ExerciseInfo(name: 'Wall Sit', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),
  ExerciseInfo(name: 'Superman Hold', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.back),
  ExerciseInfo(name: 'Side Plank', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.core),
  ExerciseInfo(name: 'Step-ups', category: ExerciseCategory.bodyweight, muscleGroup: MuscleGroup.legs),

  // Free weight — needs Dumbbells (or Full Gym)
  ExerciseInfo(name: 'Squats', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.legs, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Deadlifts', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.fullBody, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Bench Press', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.chest, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Barbell Rows', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.back, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Overhead Shoulder Press', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.shoulders, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Lateral Raises', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.shoulders, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Bicep Curls', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.arms, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Tricep Extensions', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.arms, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Hip Thrusts', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.glutes, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Lat Pulldown', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.back, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Goblet Squats', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.legs, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Romanian Deadlifts', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.legs, requiredEquipment: ['Dumbbells']),
  ExerciseInfo(name: 'Dumbbell Rows', category: ExerciseCategory.freeWeight, muscleGroup: MuscleGroup.back, requiredEquipment: ['Dumbbells']),

  // Resistance band — needs Resistance Bands (or Full Gym)
  ExerciseInfo(name: 'Band Face Pulls', category: ExerciseCategory.resistanceBand, muscleGroup: MuscleGroup.back, requiredEquipment: ['Resistance Bands']),
  ExerciseInfo(name: 'Band Pull-Aparts', category: ExerciseCategory.resistanceBand, muscleGroup: MuscleGroup.shoulders, requiredEquipment: ['Resistance Bands']),
  ExerciseInfo(name: 'Band Squats', category: ExerciseCategory.resistanceBand, muscleGroup: MuscleGroup.legs, requiredEquipment: ['Resistance Bands']),

  // Cardio — no equipment needed
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
