import 'exercise_counter.dart';
import 'pushup_counter.dart';
import 'squat_counter.dart';
import 'bicep_curl_counter.dart';

/// The full set of exercises the camera can currently track. Adding a
/// new trackable exercise means: write its counter class, add one line
/// here, add one line to the factory below — nothing else changes.
enum TrackableExercise { pushups, squats, bicepCurls }

extension TrackableExerciseLabel on TrackableExercise {
  String get label {
    switch (this) {
      case TrackableExercise.pushups:
        return 'Push-ups';
      case TrackableExercise.squats:
        return 'Squats';
      case TrackableExercise.bicepCurls:
        return 'Bicep Curls';
    }
  }
}

/// Creates a brand-new counter instance for the chosen exercise. Always
/// called fresh when the person picks an exercise, so switching from
/// one exercise to another always starts with a clean, zeroed counter
/// — never carries over state from whatever was tracked before.
ExerciseCounter createCounterFor(TrackableExercise exercise) {
  switch (exercise) {
    case TrackableExercise.pushups:
      return PushupCounter();
    case TrackableExercise.squats:
      return SquatCounter();
    case TrackableExercise.bicepCurls:
      return BicepCurlCounter();
  }
}
