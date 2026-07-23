import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated circular progress ring, e.g. "68% of today's tasks complete".
/// Whenever you rebuild this widget with a new `progress` value, it
/// smoothly animates from the old value to the new one automatically.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress, // a number from 0.0 (empty) to 1.0 (full)
    this.size = 120,
    this.strokeWidth = 10,
    this.centerLabel, // optional widget shown in the middle, e.g. "Lv 3"
    this.gradient = AppColors.primaryGradient,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Widget? centerLabel;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track (the "empty" part of the ring)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: AppColors.surfaceElevated,
            ),
          ),
          // TweenAnimationBuilder animates between old and new progress
          // values automatically whenever `progress` changes.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0, 1)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return SizedBox(
                width: size,
                height: size,
                child: ShaderMask(
                  // Paints the ring using a gradient instead of flat color
                  shaderCallback: (rect) => gradient.createShader(rect),
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: strokeWidth,
                    strokeCap: StrokeCap.round, // rounded ends, not square
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              );
            },
          ),
          if (centerLabel != null) centerLabel!,
        ],
      ),
    );
  }
}
