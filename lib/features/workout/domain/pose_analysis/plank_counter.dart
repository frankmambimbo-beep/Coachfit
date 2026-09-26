import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'exercise_counter.dart';

/// Tracks plank hold time rather than reps. Each frame checks whether
/// the body is currently in a valid plank position (shoulder-hip-ankle
/// roughly a straight line, body oriented horizontally rather than
/// standing); while valid, elapsed real time between frames
/// accumulates into `reps` (repurposed here to mean "seconds held").
/// Briefly dropping out of position doesn't reset the count — a
/// harsh reset on every tracking glitch would be more frustrating
/// than useful given known pose-jitter.
class PlankHoldTracker implements ExerciseCounter {
  @override
  int reps = 0; // seconds held
  @override
  String get exerciseName => 'Plank';
  @override
  bool get isHoldBased => true;

  bool _hasCalibrated = false;
  DateTime? _lastFrameTime;
  double _fractionalSeconds = 0;
  int _secondsSinceLastMilestone = 0;

  @override
  bool get isCalibrated => _hasCalibrated;
  @override
  double get calibrationProgress => _hasCalibrated ? 1.0 : 0.0;

  @override
  bool processPose(Pose pose) {
    final validPosition = _isValidPlankPosition(pose);
    final now = DateTime.now();

    if (!_hasCalibrated) {
      if (validPosition) {
        _hasCalibrated = true;
        _lastFrameTime = now;
      }
      return false;
    }

    bool milestoneHit = false;

    if (validPosition && _lastFrameTime != null) {
      final elapsedSeconds = now.difference(_lastFrameTime!).inMilliseconds / 1000.0;
      // Guard against unrealistic gaps (e.g. the app briefly
      // backgrounded) throwing off the count.
      final clamped = elapsedSeconds.clamp(0.0, 3.0);
      _fractionalSeconds += clamped;

      while (_fractionalSeconds >= 1.0) {
        _fractionalSeconds -= 1.0;
        reps++;
        _secondsSinceLastMilestone++;
        if (_secondsSinceLastMilestone >= 15) {
          _secondsSinceLastMilestone = 0;
          milestoneHit = true; // triggers the rep-flash every 15s held
        }
      }
    }

    _lastFrameTime = now;
    return milestoneHit;
  }

  @override
  void reset() {
    reps = 0;
    _hasCalibrated = false;
    _lastFrameTime = null;
    _fractionalSeconds = 0;
    _secondsSinceLastMilestone = 0;
  }

  bool _isValidPlankPosition(Pose pose) {
    final shoulder = _midpoint(pose, PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    final hip = _midpoint(pose, PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    final ankle = _midpoint(pose, PoseLandmarkType.leftAnkle, PoseLandmarkType.rightAnkle);

    if (shoulder == null || hip == null || ankle == null) return false;

    // Body should form a roughly straight line from shoulder to ankle,
    // hinged at the hip.
    final bodyAngle = _angleBetween(
      shoulder.dx, shoulder.dy, hip.dx, hip.dy, ankle.dx, ankle.dy,
    );
    final isStraight = bodyAngle > 150;

    // A plank is horizontal (filmed side-on) — the body's horizontal
    // span should exceed its vertical span, unlike standing/kneeling.
    final horizontalSpan = (ankle.dx - shoulder.dx).abs();
    final verticalSpan = (ankle.dy - shoulder.dy).abs();
    final isHorizontal = horizontalSpan > verticalSpan;

    return isStraight && isHorizontal;
  }

  Offset? _midpoint(Pose pose, PoseLandmarkType a, PoseLandmarkType b) {
    final pa = pose.landmarks[a];
    final pb = pose.landmarks[b];
    if (pa == null || pb == null) return null;
    if (pa.likelihood < 0.5 || pb.likelihood < 0.5) return null;
    return Offset((pa.x + pb.x) / 2, (pa.y + pb.y) / 2);
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

class Offset {
  final double dx;
  final double dy;
  const Offset(this.dx, this.dy);
}
