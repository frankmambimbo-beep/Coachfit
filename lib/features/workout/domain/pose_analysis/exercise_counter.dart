import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class ExerciseCounter {
  int get reps;
  String get exerciseName;
  bool get isCalibrated;
  double get calibrationProgress;

  /// True for hold-duration exercises (like Plank), where `reps`
  /// represents seconds held rather than a rep count. The camera
  /// screen uses this to decide whether to show a rep number or a
  /// mm:ss timer.
  bool get isHoldBased => false;

  bool processPose(Pose pose);
  void reset();
}
