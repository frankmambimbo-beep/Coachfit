import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class ExerciseCounter {
  int get reps;
  String get exerciseName;

  /// True once the counter has finished its warm-up and is actively
  /// watching for reps. False during the initial "hold position" phase.
  bool get isCalibrated;

  /// 0.0–1.0 progress through calibration, for showing a progress
  /// indicator while the person holds their starting position.
  double get calibrationProgress;

  bool processPose(Pose pose);
  void reset();
}
