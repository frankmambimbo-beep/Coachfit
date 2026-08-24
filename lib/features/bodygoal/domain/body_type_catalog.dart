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

// A static reference catalog — not stored in Hive, since it doesn't
// change per-user. Only the user's *selected* goal is persisted.
const Map<BodyTypeGoal, BodyTypeInfo> bodyTypeCatalog = {
  BodyTypeGoal.vTaper: BodyTypeInfo(
    title: 'V-Taper',
    description: 'Broad, defined shoulders and back with a narrow waist.',
    recommendedExercises: [
      'Pull-ups / Lat pulldowns',
      'Overhead shoulder press',
      'Lateral raises',
      'Wide-grip rows',
      'Planks / core work (keeps the waist tight, not bulky)',
    ],
  ),
  BodyTypeGoal.bulk: BodyTypeInfo(
    title: 'Bulk',
    description: 'Overall size and mass across the whole body.',
    recommendedExercises: [
      'Squats',
      'Deadlifts',
      'Bench press',
      'Barbell rows',
      'Progressive overload on compound lifts, higher calorie intake',
    ],
  ),
  BodyTypeGoal.leanToned: BodyTypeInfo(
    title: 'Lean & Toned',
    description: 'Low body fat with visible muscle definition.',
    recommendedExercises: [
      'Push-ups',
      'Bodyweight circuits',
      'Light-to-moderate weight, higher reps',
      'Cardio intervals (HIIT)',
      'Consistent habit-based training over bulk lifting',
    ],
  ),
  BodyTypeGoal.cylinder: BodyTypeInfo(
    title: 'Cylinder',
    description: 'A balanced, straight frame with even proportions top to bottom.',
    recommendedExercises: [
      'Full-body compound lifts',
      'Squats',
      'Rows',
      'Overhead press',
      'Balanced training — no single muscle group emphasized over another',
    ],
  ),
  BodyTypeGoal.hourglass: BodyTypeInfo(
    title: 'Hourglass',
    description: 'Balanced upper and lower body with a defined waist.',
    recommendedExercises: [
      'Hip thrusts / glute bridges',
      'Squats',
      'Shoulder press (builds the upper frame)',
      'Core work — obliques and waist definition',
      'Lunges',
    ],
  ),
  BodyTypeGoal.athletic: BodyTypeInfo(
    title: 'Athletic',
    description: 'A balanced, functional build for general performance.',
    recommendedExercises: [
      'Mixed strength + cardio training',
      'Push-ups',
      'Squats',
      'Sprints / interval running',
      'Mobility and core work',
    ],
  ),
};
