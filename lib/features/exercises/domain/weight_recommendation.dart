import '../../profile/domain/user_profile.dart';
import 'exercise_info.dart';

/// Suggests a starting weight for a free-weight exercise, scaled by the
/// person's fitness level and body weight. This is a starting-point
/// estimate meant to be adjusted by feel — not a substitute for proper
/// individual programming — and only applies to exercises that
/// actually use external weight (needsWeight == true).
class WeightRecommendation {
  // Rough bodyweight-multiplier starting points per exercise, tuned
  // conservatively for a first working set at "intermediate" level.
  // Beginner and advanced scale off this baseline.
  static const Map<String, double> _baseMultipliers = {
    'Squats': 0.5,
    'Deadlifts': 0.6,
    'Bench Press': 0.4,
    'Barbell Rows': 0.35,
    'Overhead Shoulder Press': 0.25,
    'Lateral Raises': 0.03,
    'Bicep Curls': 0.08,
    'Tricep Extensions': 0.08,
    'Hip Thrusts': 0.5,
    'Lat Pulldown': 0.35,
    'Goblet Squats': 0.3,
    'Romanian Deadlifts': 0.45,
    'Dumbbell Rows': 0.2,
  };

  static double? recommendedKg({
    required ExerciseInfo exercise,
    required FitnessLevel level,
    required double bodyWeightKg,
  }) {
    if (!exercise.needsWeight) return null;

    final baseMultiplier = _baseMultipliers[exercise.name];
    if (baseMultiplier == null) return null;

    // Beginner starts lighter to build form safely; advanced scales up.
    final levelMultiplier = switch (level) {
      FitnessLevel.beginner => 0.6,
      FitnessLevel.intermediate => 1.0,
      FitnessLevel.advanced => 1.5,
    };

    final raw = bodyWeightKg * baseMultiplier * levelMultiplier;

    // Round to the nearest 2.5kg — realistic plate/dumbbell increments.
    return (raw / 2.5).round() * 2.5;
  }
}
