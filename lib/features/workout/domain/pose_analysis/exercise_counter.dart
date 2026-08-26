import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Shared contract every exercise-specific counter implements. The
/// camera screen only ever holds ONE of these at a time — whichever
/// matches the exercise currently selected — so there's no risk of one
/// exercise's movement accidentally incrementing another's count.
abstract class ExerciseCounter {
  int get reps;
  String get exerciseName;

  /// Feeds one frame's pose data in. Returns true if this frame
  /// completed a rep.
  bool processPose(Pose pose);

  void reset();
}
