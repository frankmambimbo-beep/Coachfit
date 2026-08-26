import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'exercise_counter.dart';
import 'rep_state_tracker.dart';

class SquatCounter implements ExerciseCounter {
  @override
  int reps = 0;
  @override
  String get exerciseName => 'Squats';

  final _tracker = RepStateTracker(downThresholdRatio: 0.65, upThresholdRatio: 0.90);

  @override
  bool processPose(Pose pose) {
    final angle = _averageKneeAngle(pose);
    if (angle == null) return false;

    final completed = _tracker.update(angle);
    if (completed) reps++;
    return completed;
  }

  @override
  void reset() {
    reps = 0;
    _tracker.reset();
  }

  double? _averageKneeAngle(Pose pose) {
    final left = _kneeAngle(
      pose, PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle,
    );
    final right = _kneeAngle(
      pose, PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle,
    );

    if (left != null && right != null) return (left + right) / 2;
    return left ?? right;
  }

  double? _kneeAngle(
    Pose pose, PoseLandmarkType hipType, PoseLandmarkType kneeType, PoseLandmarkType ankleType,
  ) {
    final hip = pose.landmarks[hipType];
    final knee = pose.landmarks[kneeType];
    final ankle = pose.landmarks[ankleType];

    if (hip == null || knee == null || ankle == null) return null;
    if (hip.likelihood < 0.5 || knee.likelihood < 0.5 || ankle.likelihood < 0.5) return null;

    return _angleBetween(hip.x, hip.y, knee.x, knee.y, ankle.x, ankle.y);
  }

  double _angleBetween(double ax, double ay, double bx, double by, double cx, double cy) {
    final angleA = atan2(ay - by, ax - bx);
    final angleC = atan2(cy - by, cx - bx);
    var angle = (angleA - angleC) * (180 / pi);
    angle = angle.abs();
    if (angle > 180) angle = 360 - angle;
    return angle;
  }
}
