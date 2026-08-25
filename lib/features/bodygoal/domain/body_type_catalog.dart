import 'body_type_goal.dart';

class BodyTypeInfo {
  final String title;
  final String description;
  final List<String> recommendedExercises;

  const BodyTypeInfo({
    required this.title,
    required this.description,
    required this.recommendedExercises,
  });
}

// Each list is ordered the way a real session would run: big compound
// movements first (while energy is highest), isolation/accessory work
// after, core or cardio last. Names match exercise_library.dart exactly
// so they stay linked to weight recommendations when logged.
const Map<BodyTypeGoal, BodyTypeInfo> bodyTypeCatalog = {
  BodyTypeGoal.vTaper: BodyTypeInfo(
    title: 'V-Taper',
    description: 'Broad, defined shoulders and back with a narrow waist.',
    recommendedExercises: [
      'Pull-ups',
      'Barbell Rows',
      'Overhead Shoulder Press',
      'Lateral Raises',
      'Plank',
    ],
  ),
  BodyTypeGoal.bulk: BodyTypeInfo(
    title: 'Bulk',
    description: 'Overall size and mass across the whole body.',
    recommendedExercises: [
      'Squats',
      'Deadlifts',
      'Bench Press',
      'Barbell Rows',
      'Overhead Shoulder Press',
    ],
  ),
  BodyTypeGoal.leanToned: BodyTypeInfo(
    title: 'Lean & Toned',
    description: 'Low body fat with visible muscle definition.',
    recommendedExercises: [
      'Burpees',
      'Push-ups',
      'Bodyweight Squats',
      'Mountain Climbers',
      'HIIT Intervals',
    ],
  ),
  BodyTypeGoal.cylinder: BodyTypeInfo(
    title: 'Cylinder',
    description: 'A balanced, straight frame with even proportions top to bottom.',
    recommendedExercises: [
      'Squats',
      'Bench Press',
      'Barbell Rows',
      'Overhead Shoulder Press',
      'Plank',
    ],
  ),
  BodyTypeGoal.hourglass: BodyTypeInfo(
    title: 'Hourglass',
    description: 'Balanced upper and lower body with a defined waist.',
    recommendedExercises: [
      'Hip Thrusts',
      'Squats',
      'Romanian Deadlifts',
      'Overhead Shoulder Press',
      'Side Plank',
    ],
  ),
  BodyTypeGoal.athletic: BodyTypeInfo(
    title: 'Athletic',
    description: 'A balanced, functional build for general performance.',
    recommendedExercises: [
      'Squats',
      'Push-ups',
      'Sprints',
      'Mountain Climbers',
      'Plank',
    ],
  ),
  BodyTypeGoal.pear: BodyTypeInfo(
    title: 'Pear',
    description: 'Fuller hips and thighs — building the upper body to balance the frame.',
    recommendedExercises: [
      'Overhead Shoulder Press',
      'Bench Press',
      'Barbell Rows',
      'Lateral Raises',
      'Plank',
    ],
  ),
  BodyTypeGoal.apple: BodyTypeInfo(
    title: 'Apple',
    description: 'Weight carried mostly in the midsection — building a trimmer core.',
    recommendedExercises: [
      'Deadlifts',
      'Squats',
      'HIIT Intervals',
      'Mountain Climbers',
      'Plank',
    ],
  ),
  BodyTypeGoal.diamond: BodyTypeInfo(
    title: 'Diamond',
    description: 'Weight carried centrally with narrower shoulders and hips — building width top and bottom.',
    recommendedExercises: [
      'Lateral Raises',
      'Overhead Shoulder Press',
      'Squats',
      'Hip Thrusts',
      'Plank',
    ],
  ),
  BodyTypeGoal.spoon: BodyTypeInfo(
    title: 'Spoon',
    description: 'Fuller hips and thighs with a naturally defined waist — building the upper body and core.',
    recommendedExercises: [
      'Bench Press',
      'Barbell Rows',
      'Overhead Shoulder Press',
      'Plank',
      'Step-ups',
    ],
  ),
};
