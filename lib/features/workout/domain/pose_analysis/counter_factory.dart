import 'exercise_counter.dart';
import 'pushup_counter.dart';
import 'squat_counter.dart';
import 'bicep_curl_counter.dart';
import 'plank_counter.dart';

enum TrackableExercise { pushups, squats, bicepCurls, plank }

extension TrackableExerciseLabel on TrackableExercise {
  String get label {
    switch (this) {
      case TrackableExercise.pushups:
        return 'Push-ups';
      case TrackableExercise.squats:
        return 'Squats';
      case TrackableExercise.bicepCurls:
        return 'Bicep Curls';
      case TrackableExercise.plank:
        return 'Plank';
    }
  }
}

ExerciseCounter createCounterFor(TrackableExercise exercise) {
  switch (exercise) {
    case TrackableExercise.pushups:
      return PushupCounter();
    case TrackableExercise.squats:
      return SquatCounter();
    case TrackableExercise.bicepCurls:
      return BicepCurlCounter();
    case TrackableExercise.plank:
      return PlankHoldTracker();
  }
}
