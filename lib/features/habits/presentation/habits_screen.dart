import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/habits_repository.dart';
import '../domain/habit.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  IconData _iconFor(HabitCategory c) {
    switch (c) {
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.nutrition:
        return Icons.restaurant;
      case HabitCategory.mindfulness:
        return Icons.self_improvement;
      case HabitCategory.sleep:
        return Icons.bedtime;
      case HabitCategory.other:
        return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsRepositoryProvider);
    final dueToday = habits.where((h) => h.isDueToday).toList();
    final notDueToday = habits.where((h) => !h.isDueToday).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/habits/add'),
        child: const Icon(Icons.add),
      ),
      body: habits.isEmpty
          ? _EmptyState(onAdd: () => context.push('/habits/add'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (dueToday.isNotEmpty) ...[
                  const Text('Today',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...dueToday.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HabitTile(habit: h, icon: _iconFor(h.category)),
                      )),
                  const SizedBox(height: 24),
                ],
                if (notDueToday.isNotEmpty) ...[
                  const Text('Other habits',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...notDueToday.map((h) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _HabitTile(habit: h, icon: _iconFor(h.category)),
                      )),
                ],
              ],
            ),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  final Habit habit;
  final IconData icon;

  const _HabitTile({required this.habit, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isCompletedToday;

    return GlassCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: done
              ? AppColors.accentTertiary.withOpacity(0.2)
              : AppColors.accentPrimary.withOpacity(0.15),
          child: Icon(icon,
              color: done ? AppColors.accentTertiary : AppColors.accentPrimary),
        ),
        title:
            Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle:
            Text('🔥 ${habit.currentStreak} day streak  ·  +${habit.xpReward} XP'),
        trailing: IconButton(
          icon: Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? AppColors.accentTertiary : Colors.grey,
            size: 32,
          ),
          onPressed: () {
            ref.read(habitsRepositoryProvider.notifier)
                .toggleCompletionToday(habit.id);
          },
        ),
        onLongPress: () => _confirmDelete(context, ref),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete habit?'),
        content:
            Text('This will permanently remove "${habit.name}" and its history.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(habitsRepositoryProvider.notifier).deleteHabit(habit.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.checklist, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No habits yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Add a habit to start building your streak and earning XP.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: onAdd, child: const Text('Add your first habit')),
          ],
        ),
      ),
    );
  }
}
