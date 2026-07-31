import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Tracks push-up reps by watching the elbow angle across frames.
/// A "down" phase (elbow bent past [downThreshold]) followed by an
/// "up" phase (elbow straight past [upThreshold]) counts as one rep.
/// Two thresholds with a gap between them (instead of one) prevents
/// small tracking jitter near a single angle from triggering false
/// counts.
class PushupCounter {
  static const double downThreshold = 90; // degrees — arms bent
  static const double upThreshold = 160; // degrees — arms extended

  int reps = 0;
  bool _isDown = false;

  /// Returns true if this frame completed a rep (arms went down, then
  /// back up), so the caller can trigger UI feedback / XP.
  bool processPose(Pose pose) {
    final angle = _averageElbowAngle(pose);
    if (angle == null) return false;

    if (!_isDown && angle < downThreshold) {
      _isDown = true;
    } else if (_isDown && angle > upThreshold) {
      _isDown = false;
      reps++;
      return true;
    }
    return false;
  }

  void reset() {
    reps = 0;
    _isDown = false;
  }

  // Averages both arms when visible, so the count isn't thrown off if
  // one arm is briefly obscured from the camera's angle.
  double? _averageElbowAngle(Pose pose) {
    final leftAngle = _elbowAngle(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    );
    final rightAngle = _elbowAngle(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    );

    if (leftAngle != null && rightAngle != null) {
      return (leftAngle + rightAngle) / 2;
    }
    return leftAngle ?? rightAngle;
  }

  double? _elbowAngle(
    Pose pose,
    PoseLandmarkType shoulderType,
    PoseLandmarkType elbowType,
    PoseLandmarkType wristType,
  ) {
    final shoulder = pose.landmarks[shoulderType];
    final elbow = pose.landmarks[elbowType];
    final wrist = pose.landmarks[wristType];

    // ML Kit reports a confidence score per landmark. Below ~0.5 the
    // point is likely a guess, not a real detection, so we skip it
    // rather than count a potentially garbage angle.
    if (shoulder == null || elbow == null || wrist == null) return null;
    if (shoulder.likelihood < 0.5 ||
        elbow.likelihood < 0.5 ||
        wrist.likelihood < 0.5) {
      return null;
    }

    return _angleBetween(
      shoulder.x, shoulder.y,
      elbow.x, elbow.y,
      wrist.x, wrist.y,
    );
  }

  // Standard "angle at the middle point" formula using the law of
  // cosines via atan2 — gives the angle at point B in the A-B-C chain,
  // in degrees.
  double _angleBetween(
    double ax, double ay,
    double bx, double by,
    double cx, double cy,
  ) {
    final angleA = atan2(ay - by, ax - bx);
    final angleC = atan2(cy - by, cx - bx);
    var angle = (angleA - angleC) * (180 / pi);
    angle = angle.abs();
    if (angle > 180) angle = 360 - angle;
    return angle;
  }
}
