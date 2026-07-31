import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/workout_repository.dart';
import '../domain/workout_session.dart';

class WorkoutScreen extends ConsumerWidget {
  const WorkoutScreen({super.key});

  IconData _iconFor(WorkoutType t) {
    switch (t) {
      case WorkoutType.strength:
        return Icons.fitness_center;
      case WorkoutType.cardio:
        return Icons.directions_run;
      case WorkoutType.flexibility:
        return Icons.self_improvement;
      case WorkoutType.sports:
        return Icons.sports_basketball;
      case WorkoutType.other:
        return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(workoutRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Workouts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/workout/add'),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // TEMPORARY — Phase 5 Stage A entry point. Remove once real
          // rep-counting UI replaces this manual test button.
          GlassCard(
            onTap: () => context.push('/workout/camera-test'),
            child: Row(
              children: [
                const Icon(Icons.videocam, color: AppColors.accentSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Test Camera (Phase 5)',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (sessions.isEmpty)
            _EmptyState(onAdd: () => context.push('/workout/add'))
          else
            ...sessions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _SessionTile(session: s, icon: _iconFor(s.type)),
                )),
        ],
      ),
    );
  }
}

class _SessionTile extends ConsumerWidget {
  final WorkoutSession session;
  final IconData icon;

  const _SessionTile({required this.session, required this.icon});

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete workout?'),
        content: Text('This will permanently remove "${session.title}" and its XP.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(workoutRepositoryProvider.notifier).deleteSession(session.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = DateFormat('EEE, MMM d').format(session.date);

    return GlassCard(
      onLongPress: () => _confirmDelete(context, ref),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accentPrimary.withOpacity(0.15),
            child: Icon(icon, color: AppColors.accentPrimary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '$dateLabel · ${session.exercises.length} exercises · ${session.totalSets} sets'
                  '${session.durationMinutes > 0 ? ' · ${session.durationMinutes} min' : ''}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
                if (session.notes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(session.notes,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          Text('+${session.xpReward} XP',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.accentTertiary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.fitness_center, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No workouts logged yet',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Log your sessions here to build a history and earn XP.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onAdd, child: const Text('Log your first workout')),
          ],
        ),
      ),
    );
  }
}
