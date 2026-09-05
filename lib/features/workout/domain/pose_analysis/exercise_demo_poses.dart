import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'counter_factory.dart';

class DemoPoseSet {
  final Map<PoseLandmarkType, Offset> start;
  final Map<PoseLandmarkType, Offset> end;
  const DemoPoseSet({required this.start, required this.end});
}

const Map<TrackableExercise, DemoPoseSet> exerciseDemoPoses = {
  TrackableExercise.pushups: DemoPoseSet(
    // Side-profile plank, arms extended. Layout: shoulder(0.35) →
    // hip(0.55) → knee(0.72) → ankle(0.88) — increasing x runs toward
    // the feet.
    start: {
      PoseLandmarkType.leftShoulder: Offset(0.35, 0.25),
      PoseLandmarkType.rightShoulder: Offset(0.35, 0.22),
      PoseLandmarkType.leftElbow: Offset(0.35, 0.40),
      PoseLandmarkType.rightElbow: Offset(0.35, 0.37),
      PoseLandmarkType.leftWrist: Offset(0.35, 0.60),
      PoseLandmarkType.rightWrist: Offset(0.35, 0.57),
      PoseLandmarkType.leftHip: Offset(0.55, 0.28),
      PoseLandmarkType.rightHip: Offset(0.55, 0.25),
      PoseLandmarkType.leftKnee: Offset(0.72, 0.32),
      PoseLandmarkType.rightKnee: Offset(0.72, 0.29),
      PoseLandmarkType.leftAnkle: Offset(0.88, 0.35),
      PoseLandmarkType.rightAnkle: Offset(0.88, 0.32),
    },
    // FIXED: as the chest lowers, the elbow bends BACKWARD toward the
    // feet (larger x, same direction as the hip) — not forward, away
    // from the body. Wrist stays planted roughly under the shoulder.
    end: {
      PoseLandmarkType.leftShoulder: Offset(0.35, 0.45),
      PoseLandmarkType.rightShoulder: Offset(0.35, 0.42),
      PoseLandmarkType.leftElbow: Offset(0.46, 0.50),
      PoseLandmarkType.rightElbow: Offset(0.46, 0.47),
      PoseLandmarkType.leftWrist: Offset(0.35, 0.60),
      PoseLandmarkType.rightWrist: Offset(0.35, 0.57),
      PoseLandmarkType.leftHip: Offset(0.55, 0.48),
      PoseLandmarkType.rightHip: Offset(0.55, 0.45),
      PoseLandmarkType.leftKnee: Offset(0.72, 0.50),
      PoseLandmarkType.rightKnee: Offset(0.72, 0.47),
      PoseLandmarkType.leftAnkle: Offset(0.88, 0.52),
      PoseLandmarkType.rightAnkle: Offset(0.88, 0.49),
    },
  ),
  TrackableExercise.squats: DemoPoseSet(
    start: {
      PoseLandmarkType.leftShoulder: Offset(0.40, 0.15),
      PoseLandmarkType.rightShoulder: Offset(0.60, 0.15),
      PoseLandmarkType.leftElbow: Offset(0.35, 0.30),
      PoseLandmarkType.rightElbow: Offset(0.65, 0.30),
      PoseLandmarkType.leftWrist: Offset(0.35, 0.45),
      PoseLandmarkType.rightWrist: Offset(0.65, 0.45),
      PoseLandmarkType.leftHip: Offset(0.42, 0.45),
      PoseLandmarkType.rightHip: Offset(0.58, 0.45),
      PoseLandmarkType.leftKnee: Offset(0.42, 0.65),
      PoseLandmarkType.rightKnee: Offset(0.58, 0.65),
      PoseLandmarkType.leftAnkle: Offset(0.42, 0.85),
      PoseLandmarkType.rightAnkle: Offset(0.58, 0.85),
    },
    end: {
      PoseLandmarkType.leftShoulder: Offset(0.38, 0.30),
      PoseLandmarkType.rightShoulder: Offset(0.62, 0.30),
      PoseLandmarkType.leftElbow: Offset(0.30, 0.42),
      PoseLandmarkType.rightElbow: Offset(0.70, 0.42),
      PoseLandmarkType.leftWrist: Offset(0.28, 0.50),
      PoseLandmarkType.rightWrist: Offset(0.72, 0.50),
      PoseLandmarkType.leftHip: Offset(0.40, 0.55),
      PoseLandmarkType.rightHip: Offset(0.60, 0.55),
      PoseLandmarkType.leftKnee: Offset(0.35, 0.68),
      PoseLandmarkType.rightKnee: Offset(0.65, 0.68),
      PoseLandmarkType.leftAnkle: Offset(0.42, 0.85),
      PoseLandmarkType.rightAnkle: Offset(0.58, 0.85),
    },
  ),
  TrackableExercise.bicepCurls: DemoPoseSet(
    start: {
      PoseLandmarkType.leftShoulder: Offset(0.40, 0.20),
      PoseLandmarkType.rightShoulder: Offset(0.60, 0.20),
      PoseLandmarkType.leftElbow: Offset(0.38, 0.40),
      PoseLandmarkType.rightElbow: Offset(0.62, 0.40),
      PoseLandmarkType.leftWrist: Offset(0.36, 0.60),
      PoseLandmarkType.rightWrist: Offset(0.64, 0.60),
      PoseLandmarkType.leftHip: Offset(0.42, 0.55),
      PoseLandmarkType.rightHip: Offset(0.58, 0.55),
      PoseLandmarkType.leftKnee: Offset(0.42, 0.72),
      PoseLandmarkType.rightKnee: Offset(0.58, 0.72),
      PoseLandmarkType.leftAnkle: Offset(0.42, 0.88),
      PoseLandmarkType.rightAnkle: Offset(0.58, 0.88),
    },
    end: {
      PoseLandmarkType.leftShoulder: Offset(0.40, 0.20),
      PoseLandmarkType.rightShoulder: Offset(0.60, 0.20),
      PoseLandmarkType.leftElbow: Offset(0.38, 0.40),
      PoseLandmarkType.rightElbow: Offset(0.62, 0.40),
      PoseLandmarkType.leftWrist: Offset(0.42, 0.25),
      PoseLandmarkType.rightWrist: Offset(0.58, 0.25),
      PoseLandmarkType.leftHip: Offset(0.42, 0.55),
      PoseLandmarkType.rightHip: Offset(0.58, 0.55),
      PoseLandmarkType.leftKnee: Offset(0.42, 0.72),
      PoseLandmarkType.rightKnee: Offset(0.58, 0.72),
      PoseLandmarkType.leftAnkle: Offset(0.42, 0.88),
      PoseLandmarkType.rightAnkle: Offset(0.58, 0.88),
    },
  ),
};
