/// Exponential moving average — blends each new reading with recent
/// history so a single noisy frame can't cause a big jump. Lower
/// [alpha] = smoother but slower to react; higher = more responsive
/// but noisier.
class SmoothedValue {
  SmoothedValue({this.alpha = 0.3});

  final double alpha;
  double? _value;

  double update(double newValue) {
    _value = _value == null ? newValue : (alpha * newValue + (1 - alpha) * _value!);
    return _value!;
  }

  void reset() => _value = null;
}

/// Shared "did a rep just happen" state machine used by every exercise
/// counter. Two things prevent jitter from causing phantom reps:
/// 1. The tracked value is smoothed (see SmoothedValue) before it's
///    ever compared to a threshold.
/// 2. A threshold crossing must hold for [requiredConsecutiveFrames]
///    in a row before it's trusted — one noisy frame flickering past
///    a threshold and back is ignored, only a sustained movement
///    counts.
class RepStateTracker {
  RepStateTracker({
    required this.downThresholdRatio,
    required this.upThresholdRatio,
    this.requiredConsecutiveFrames = 3,
    double smoothingAlpha = 0.3,
  }) : _smoother = SmoothedValue(alpha: smoothingAlpha);

  final double downThresholdRatio;
  final double upThresholdRatio;
  final int requiredConsecutiveFrames;
  final SmoothedValue _smoother;

  double? _baseline;
  bool _isTriggered = false;
  int _consecutiveCount = 0;

  /// Feed in one frame's raw measured value (an angle or ratio).
  /// Returns true exactly when a full down-then-up rep is confirmed.
  bool update(double rawValue) {
    final value = _smoother.update(rawValue);
    _baseline ??= value;
    final baseline = _baseline!;
    final downThreshold = baseline * downThresholdRatio;
    final upThreshold = baseline * upThresholdRatio;

    if (!_isTriggered) {
      if (value < downThreshold) {
        _consecutiveCount++;
        if (_consecutiveCount >= requiredConsecutiveFrames) {
          _isTriggered = true;
          _consecutiveCount = 0;
        }
      } else {
        _consecutiveCount = 0;
      }
    } else {
      if (value > upThreshold) {
        _consecutiveCount++;
        if (_consecutiveCount >= requiredConsecutiveFrames) {
          _isTriggered = false;
          _consecutiveCount = 0;
          return true;
        }
      } else {
        _consecutiveCount = 0;
      }
    }
    return false;
  }

  void reset() {
    _baseline = null;
    _isTriggered = false;
    _consecutiveCount = 0;
    _smoother.reset();
  }
}
