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

class RepStateTracker {
  RepStateTracker({
    required this.downThresholdRatio,
    required this.upThresholdRatio,
    // Reduced from 3 to 2: the EMA smoothing above already filters
    // most frame-to-frame noise before this check runs, so requiring
    // 3 consecutive confirmations on top of that was over-cautious —
    // it made fast reps impossible to register in time.
    this.requiredConsecutiveFrames = 2,
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
