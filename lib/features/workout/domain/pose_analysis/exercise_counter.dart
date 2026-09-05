import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class ExerciseCounter {
  int get reps;
  String get exerciseName;
  bool get isCalibrated;
  double get calibrationProgress;

  bool processPose(Pose pose);
  void reset();
}
