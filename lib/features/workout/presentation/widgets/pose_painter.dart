import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

/// Draws the detected pose as dots on each joint ("balls") connected by
/// lines ("sticks") — a live skeleton overlay on top of the camera
/// preview, so it's obvious what the tracker is actually seeing.
class PosePainter extends CustomPainter {
  PosePainter(this.pose, this.imageSize, this.lensDirection);

  final Pose? pose;
  final Size imageSize;
  final CameraLensDirection lensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final p = pose;
    if (p == null || imageSize.width == 0 || imageSize.height == 0) return;

    final dotPaint = Paint()
      ..color = const Color(0xFF9D7BFF) // violet, matches app accent
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF4ADE80) // mint, matches app accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double translateX(double x) {
      final scaled = x * size.width / imageSize.width;
      // Front camera preview is mirrored, so the overlay needs to
      // mirror too or the dots won't line up with what's on screen.
      return lensDirection == CameraLensDirection.front
          ? size.width - scaled
          : scaled;
    }

    double translateY(double y) => y * size.height / imageSize.height;

    void drawBone(PoseLandmarkType a, PoseLandmarkType b) {
      final la = p.landmarks[a];
      final lb = p.landmarks[b];
      if (la == null || lb == null) return;
      if (la.likelihood < 0.5 || lb.likelihood < 0.5) return;
      canvas.drawLine(
        Offset(translateX(la.x), translateY(la.y)),
        Offset(translateX(lb.x), translateY(lb.y)),
        linePaint,
      );
    }

    // The "sticks" — main skeleton connections.
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

    // The "balls" — one dot per confidently-detected joint.
    for (final landmark in p.landmarks.values) {
      if (landmark.likelihood < 0.5) continue;
      canvas.drawCircle(
        Offset(translateX(landmark.x), translateY(landmark.y)),
        6,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}
