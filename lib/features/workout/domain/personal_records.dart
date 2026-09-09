import 'workout_session.dart';

class PersonalRecord {
  final String exerciseName;
  final double bestWeightKg;
  final int bestReps;
  final DateTime achievedAt;

  const PersonalRecord({
    required this.exerciseName,
    required this.bestWeightKg,
    required this.bestReps,
    required this.achievedAt,
  });
}

/// Scans all logged workout sessions and finds each exercise's best
/// weight lifted and best single-set rep count. Pure derived data —
/// nothing stored separately, always computed fresh from existing
/// workout history so it can never drift out of sync.
List<PersonalRecord> calculatePersonalRecords(List<WorkoutSession> sessions) {
  final Map<String, PersonalRecord> records = {};

  for (final session in sessions) {
    for (final exercise in session.exercises) {
      final existing = records[exercise.name];

      final isNewWeightRecord = existing == null || exercise.weightKg > existing.bestWeightKg;
      final isNewRepRecord = existing == null || exercise.reps > existing.bestReps;

      if (isNewWeightRecord || isNewRepRecord) {
        records[exercise.name] = PersonalRecord(
          exerciseName: exercise.name,
          bestWeightKg: isNewWeightRecord ? exercise.weightKg : existing!.bestWeightKg,
          bestReps: isNewRepRecord ? exercise.reps : existing!.bestReps,
          achievedAt: session.date,
        );
      }
    }
  }

  final list = records.values.toList()
    ..sort((a, b) => b.achievedAt.compareTo(a.achievedAt));
  return list;
}
