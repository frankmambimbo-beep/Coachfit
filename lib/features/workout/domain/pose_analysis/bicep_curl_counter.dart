import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'exercise_counter.dart';

/// Tracks bicep curl reps via elbow angle (shoulder-elbow-wrist). Unlike
/// push-ups, curls bend mostly in a plane the camera CAN see clearly
/// from the front (the forearm swings up toward the shoulder), so a
/// direct angle threshold is reliable here without needing a torso
/// fallback signal.
class BicepCurlCounter implements ExerciseCounter {
  @override
  int reps = 0;
  @override
  String get exerciseName => 'Bicep Curls';

  bool _isCurled = false;
  double? _baseline;

  @override
  bool processPose(Pose pose) {
    final angle = _averageElbowAngle(pose);
    if (angle == null) return false;

    _baseline ??= angle;
    final baseline = _baseline!;
    final curledThreshold = baseline * 0.55; // arm fully bent
    final extendedThreshold = baseline * 0.85; // arm back down

    if (!_isCurled && angle < curledThreshold) {
      _isCurled = true;
    } else if (_isCurled && angle > extendedThreshold) {
      _isCurled = false;
      reps++;
      return true;
    }
    return false;
  }

  @override
  void reset() {
    reps = 0;
    _isCurled = false;
    _baseline = null;
  }

  double? _averageElbowAngle(Pose pose) {
    final left = _elbowAngle(
      pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist,
    );
    final right = _elbowAngle(
      pose, PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist,
    );

    if (left != null && right != null) return (left + right) / 2;
    return left ?? right;
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
