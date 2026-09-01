import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/pose_analysis/counter_factory.dart';
import '../../domain/pose_analysis/exercise_demo_poses.dart';
import 'pose_painter.dart';

/// Small looping animated skeleton showing correct form for the
/// exercise currently being tracked. Purely illustrative — built from
/// hand-placed reference poses, not the live camera feed — so it
/// keeps demonstrating perfect form regardless of how the real
/// tracking is going.
class ExerciseDemoWidget extends StatefulWidget {
  const ExerciseDemoWidget({super.key, required this.exercise});

  final TrackableExercise exercise;

  @override
  State<ExerciseDemoWidget> createState() => _ExerciseDemoWidgetState();
}

class _ExerciseDemoWidgetState extends State<ExerciseDemoWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<PoseLandmarkType, Offset> _interpolate(DemoPoseSet set, double t) {
    final result = <PoseLandmarkType, Offset>{};
    for (final entry in set.start.entries) {
      final endPoint = set.end[entry.key];
      if (endPoint != null) {
        result[entry.key] = Offset.lerp(entry.value, endPoint, t)!;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final demoSet = exerciseDemoPoses[widget.exercise];
    if (demoSet == null) return const SizedBox.shrink();

    return Container(
      width: 110,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accentSecondary.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'Demo',
              style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final points = _interpolate(demoSet, _controller.value);
                return CustomPaint(
                  painter: PosePainter(points, const Size(1, 1), CameraLensDirection.back),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
