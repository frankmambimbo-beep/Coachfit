import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/progress_ring.dart';
import '../data/goals_repository.dart';
import '../domain/goal.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  IconData _iconFor(GoalCategory c) {
    switch (c) {
      case GoalCategory.weight:
        return Icons.monitor_weight_outlined;
      case GoalCategory.strength:
        return Icons.fitness_center;
      case GoalCategory.endurance:
        return Icons.directions_run;
      case GoalCategory.habit:
        return Icons.repeat;
      case GoalCategory.custom:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsRepositoryProvider);
    final active = goals.where((g) => !g.completed).toList();
    final done = goals.where((g) => g.completed).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/goals/add'),
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? _EmptyState(onAdd: () => context.push('/goals/add'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                if (active.isNotEmpty) ...[
                  Text('In progress',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  ...active.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _GoalTile(goal: g, icon: _iconFor(g.category)),
                      )),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (done.isNotEmpty) ...[
                  Text('Completed',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.sm),
                  ...done.map((g) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _GoalTile(goal: g, icon: _iconFor(g.category)),
                      )),
                ],
              ],
            ),
    );
  }
}

class _GoalTile extends ConsumerWidget {
  final Goal goal;
  final IconData icon;

  const _GoalTile({required this.goal, required this.icon});

  void _showAddProgressDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update "${goal.title}"'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
              labelText: 'Add progress (${goal.unit})',
              hintText: 'e.g. 1'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final delta = double.tryParse(controller.text);
              if (delta != null) {
                ref
                    .read(goalsRepositoryProvider.notifier)
                    .addProgress(goal.id, delta);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete goal?'),
        content: Text('This will permanently remove "${goal.title}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(goalsRepositoryProvider.notifier).deleteGoal(goal.id);
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
    return GlassCard(
      onTap: goal.completed
          ? null
          : () => _showAddProgressDialog(context, ref),
      child: Row(
        children: [
          ProgressRing(
            progress: goal.progress,
            size: 56,
            strokeWidth: 6,
            gradient: goal.completed
                ? const LinearGradient(
                    colors: [AppColors.accentTertiary, AppColors.accentTertiary])
                : AppColors.primaryGradient,
            centerLabel: Icon(
              goal.completed ? Icons.check : icon,
              size: 20,
              color: goal.completed ? AppColors.accentTertiary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  goal.completed
                      ? 'Completed 🎉'
                      : '${goal.currentValue.toStringAsFixed(goal.currentValue == goal.currentValue.roundToDouble() ? 0 : 1)} / ${goal.targetValue.toStringAsFixed(goal.targetValue == goal.targetValue.roundToDouble() ? 0 : 1)} ${goal.unit}'
                          '${goal.isOverdue ? '  ·  overdue' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: goal.isOverdue
                            ? AppColors.danger
                            : AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            onPressed: () => _confirmDelete(context, ref),
          ),
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
            const Icon(Icons.flag_outlined, size: 64, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.md),
            Text('No goals yet',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Set a goal — like losing weight or hitting a workout count — and track it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(onPressed: onAdd, child: const Text('Add your first goal')),
          ],
        ),
      ),
    );
  }
}
