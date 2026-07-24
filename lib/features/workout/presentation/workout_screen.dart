import 'package:flutter/material.dart';
import '../../../core/widgets/phase_placeholder.dart';

/// Placeholder for the Workout tab. Guided/custom/camera-based workouts
/// with real rep counting are substantial features on their own and
/// will be built in later phases (5 & 6).
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      icon: Icons.fitness_center_rounded,
      title: 'Workouts',
      description: 'Guided, custom, and camera-based workouts with live rep counting arrive in Phases 5 & 6.',
    );
  }
}
