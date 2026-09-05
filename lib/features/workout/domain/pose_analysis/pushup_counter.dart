import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'exercise_counter.dart';
import 'rep_state_tracker.dart';

class PushupCounter implements ExerciseCounter {
  @override
  int reps = 0;
  @override
  String get exerciseName => 'Push-ups';

  final _torsoTracker = RepStateTracker(downThresholdRatio: 0.75, upThresholdRatio: 0.90);
  final _elbowTracker = RepStateTracker(downThresholdRatio: 0.75, upThresholdRatio: 0.90);

  @override
  bool get isCalibrated => _torsoTracker.isCalibrated || _elbowTracker.isCalibrated;
  @override
  double get calibrationProgress =>
      _torsoTracker.calibrationProgress > _elbowTracker.calibrationProgress
          ? _torsoTracker.calibrationProgress
          : _elbowTracker.calibrationProgress;

  @override
  bool processPose(Pose pose) {
    final torsoRatio = _torsoRatio(pose);
    if (torsoRatio != null) {
      final completed = _torsoTracker.update(torsoRatio);
      if (completed) reps++;
      return completed;
    }

    final elbowAngle = _bestElbowAngle(pose);
    if (elbowAngle != null) {
      final completed = _elbowTracker.update(elbowAngle);
      if (completed) reps++;
      return completed;
    }

    return false;
  }

  @override
  void reset() {
    reps = 0;
    _torsoTracker.reset();
    _elbowTracker.reset();
  }

  double? _torsoRatio(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      return null;
    }
    if (leftShoulder.likelihood < 0.5 ||
        rightShoulder.likelihood < 0.5 ||
        leftHip.likelihood < 0.5 ||
        rightHip.likelihood < 0.5) {
      return null;
    }

    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final shoulderX = (leftShoulder.x + rightShoulder.x) / 2;
    final hipY = (leftHip.y + rightHip.y) / 2;
    final hipX = (leftHip.x + rightHip.x) / 2;

    final torsoLength = sqrt(pow(hipX - shoulderX, 2) + pow(hipY - shoulderY, 2));
    if (torsoLength < 1) return null;

    final verticalGap = (hipY - shoulderY).abs();
    return verticalGap / torsoLength;
  }

  // Near a 90° bend, small body rotation can make one arm look more
  // foreshortened than the other, causing left/right angles to
  // diverge sharply. If they agree reasonably, average them; if not,
  // trust only whichever side has higher landmark confidence.
  double? _bestElbowAngle(Pose pose) {
    final left = _elbowAngle(
      pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist,
    );
    final right = _elbowAngle(
      pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist,
    );

    if (left == null) return right;
    if (right == null) return left;

    final divergence = (left - right).abs();
    if (divergence <= 30) {
      return (left + right) / 2;
    }

    final leftConfidence = _armConfidence(
      pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist,
    );
    final rightConfidence = _armConfidence(
      pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist,
    );

    return leftConfidence >= rightConfidence ? left : right;
  }

  double _armConfidence(
    Pose pose, PoseLandmarkType shoulderType, PoseLandmarkType elbowType, PoseLandmarkType wristType,
  ) {
    final shoulder = pose.landmarks[shoulderType];
    final elbow = pose.landmarks[elbowType];
    final wrist = pose.landmarks[wristType];
    if (shoulder == null || elbow == null || wrist == null) return 0;
    return shoulder.likelihood + elbow.likelihood + wrist.likelihood;
  }

  double? _elbowAngle(
    Pose pose, PoseLandmarkType shoulderType, PoseLandmarkType elbowType, PoseLandmarkType wristType,
  ) {
    final shoulder = pose.landmarks[shoulderType];
    final elbow = pose.landmarks[elbowType];
    final wrist = pose.landmarks[wristType];

    if (shoulder == null || elbow == null || wrist == null) return null;
    if (shoulder.likelihood < 0.5 || elbow.likelihood < 0.5 || wrist.likelihood < 0.5) return null;

    return _angleBetween(shoulder.x, shoulder.y, elbow.x, elbow.y, wrist.x, wrist.y);
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
