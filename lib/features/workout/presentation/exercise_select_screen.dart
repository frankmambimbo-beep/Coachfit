import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../domain/pose_analysis/counter_factory.dart';

/// Lets the person pick exactly ONE exercise before the camera opens.
/// The chosen exercise is passed through as route `extra`, so
/// ExerciseCameraScreen creates one dedicated counter for that exercise
/// only — there's no way to end up tracking two exercises at once.
class ExerciseSelectScreen extends StatelessWidget {
  const ExerciseSelectScreen({super.key});

  IconData _iconFor(TrackableExercise e) {
    switch (e) {
      case TrackableExercise.pushups:
        return Icons.fitness_center;
      case TrackableExercise.squats:
        return Icons.airline_seat_legroom_extra;
      case TrackableExercise.bicepCurls:
        return Icons.sports_gymnastics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Rep Counter')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Pick one exercise — the camera tracks that movement only, until you finish the set.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...TrackableExercise.values.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () => context.push('/workout/track/camera', extra: e),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accentPrimary.withOpacity(0.15),
                        child: Icon(_iconFor(e), color: AppColors.accentPrimary),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(e.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textMuted),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
