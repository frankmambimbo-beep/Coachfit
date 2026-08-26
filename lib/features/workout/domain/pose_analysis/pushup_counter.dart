import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'exercise_counter.dart';

/// Tracks push-up reps via normalized vertical torso movement (primary)
/// with elbow-angle as a fallback when hips aren't visible. See prior
/// version's comments for the full rationale — logic unchanged here,
/// only wrapped to implement ExerciseCounter.
class PushupCounter implements ExerciseCounter {
  @override
  int reps = 0;
  @override
  String get exerciseName => 'Push-ups';

  bool _isDown = false;
  double? _torsoBaseline;
  double? _elbowBaseline;

  @override
  bool processPose(Pose pose) {
    final torsoRatio = _torsoRatio(pose);
    if (torsoRatio != null) {
      return _evaluate(torsoRatio, isTorso: true);
    }

    final elbowAngle = _averageElbowAngle(pose);
    if (elbowAngle != null) {
      return _evaluate(elbowAngle, isTorso: false);
    }

    return false;
  }

  bool _evaluate(double value, {required bool isTorso}) {
    if (isTorso) {
      _torsoBaseline ??= value;
    } else {
      _elbowBaseline ??= value;
    }

    final baseline = isTorso ? _torsoBaseline! : _elbowBaseline!;
    final downThreshold = baseline * 0.75;
    final upThreshold = baseline * 0.90;

    if (!_isDown && value < downThreshold) {
      _isDown = true;
    } else if (_isDown && value > upThreshold) {
      _isDown = false;
      reps++;
      return true;
    }
    return false;
  }

  @override
  void reset() {
    reps = 0;
    _isDown = false;
    _torsoBaseline = null;
    _elbowBaseline = null;
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

  double? _averageElbowAngle(Pose pose) {
    final leftAngle = _elbowAngle(
      pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist,
    );
    final rightAngle = _elbowAngle(
      pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist,
    );

    if (leftAngle != null && rightAngle != null) return (leftAngle + rightAngle) / 2;
    return leftAngle ?? rightAngle;
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
