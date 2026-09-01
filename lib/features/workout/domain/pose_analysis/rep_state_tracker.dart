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

/// Shared rep-detection state machine. Now includes a calibration
/// warm-up: rather than trusting a single first frame as the baseline
/// (risky if that frame is slightly off), it collects several frames
/// first and averages them — a much more stable reference point.
class RepStateTracker {
  RepStateTracker({
    required this.downThresholdRatio,
    required this.upThresholdRatio,
    this.requiredConsecutiveFrames = 3,
    this.calibrationFrames = 12,
    double smoothingAlpha = 0.3,
  }) : _smoother = SmoothedValue(alpha: smoothingAlpha);

  final double downThresholdRatio;
  final double upThresholdRatio;
  final int requiredConsecutiveFrames;
  final int calibrationFrames;
  final SmoothedValue _smoother;

  final List<double> _calibrationSamples = [];
  double? _baseline;
  bool _isTriggered = false;
  int _consecutiveCount = 0;

  bool get isCalibrated => _baseline != null;
  double get calibrationProgress =>
      (_calibrationSamples.length / calibrationFrames).clamp(0, 1);

  /// Feed in one frame's raw measured value. Returns true exactly when
  /// a full down-then-up rep is confirmed. Returns false during
  /// calibration — no reps can register until warm-up completes.
  bool update(double rawValue) {
    final value = _smoother.update(rawValue);

    if (_baseline == null) {
      _calibrationSamples.add(value);
      if (_calibrationSamples.length >= calibrationFrames) {
        _baseline = _calibrationSamples.reduce((a, b) => a + b) / _calibrationSamples.length;
      }
      return false;
    }

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
    _calibrationSamples.clear();
    _baseline = null;
    _isTriggered = false;
    _consecutiveCount = 0;
    _smoother.reset();
  }
}
