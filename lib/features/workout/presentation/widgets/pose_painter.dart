import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Draws a skeleton from already-smoothed landmark positions (see
/// exercise_camera_screen's landmark smoothing) rather than raw,
/// noisy per-frame detections — this is what stops the overlay from
/// visibly jittering/"dancing" between frames.
class PosePainter extends CustomPainter {
  PosePainter(this.points, this.imageSize, this.lensDirection);

  final Map<PoseLandmarkType, Offset> points;
  final Size imageSize;
  final CameraLensDirection lensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || imageSize.width == 0 || imageSize.height == 0) return;

    final dotPaint = Paint()
      ..color = const Color(0xFF9D7BFF)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF4ADE80)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double translateX(double x) {
      final scaled = x * size.width / imageSize.width;
      return lensDirection == CameraLensDirection.front
          ? size.width - scaled
          : scaled;
    }

    double translateY(double y) => y * size.height / imageSize.height;

    void drawBone(PoseLandmarkType a, PoseLandmarkType b) {
      final pa = points[a];
      final pb = points[b];
      if (pa == null || pb == null) return;
      canvas.drawLine(
        Offset(translateX(pa.dx), translateY(pa.dy)),
        Offset(translateX(pb.dx), translateY(pb.dy)),
        linePaint,
      );
    }

    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
    drawBone(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
    drawBone(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
    drawBone(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
    drawBone(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
    drawBone(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
    drawBone(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
    drawBone(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
    drawBone(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);

    for (final point in points.values) {
      canvas.drawCircle(
        Offset(translateX(point.dx), translateY(point.dy)),
        6,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
