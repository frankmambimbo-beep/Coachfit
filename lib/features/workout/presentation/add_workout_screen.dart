import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/workout_repository.dart';
import '../domain/workout_session.dart';

class AddWorkoutScreen extends ConsumerStatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  ConsumerState<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends ConsumerState<AddWorkoutScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  WorkoutType _type = WorkoutType.strength;
  DateTime _date = DateTime.now();
  int _durationMinutes = 30;
  final List<ExerciseEntry> _exercises = [];

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _addExercise() async {
    final nameController = TextEditingController();
    final setsController = TextEditingController(text: '3');
    final repsController = TextEditingController(text: '10');
    final weightController = TextEditingController(text: '0');

    final result = await showDialog<ExerciseEntry>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                  labelText: 'Exercise name', hintText: 'e.g. Bench press'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Weight (kg)', hintText: '0 for bodyweight'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(
                ctx,
                ExerciseEntry(
                  name: name,
                  sets: int.tryParse(setsController.text) ?? 0,
                  reps: int.tryParse(repsController.text) ?? 0,
                  weightKg: double.tryParse(weightController.text) ?? 0,
                ),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _exercises.add(result));
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Give the workout a title.')),
      );
      return;
    }

    ref.read(workoutRepositoryProvider.notifier).addSession(
          title: title,
          type: _type,
          date: _date,
          durationMinutes: _durationMinutes,
          exercises: _exercises,
          notes: _notesController.text.trim(),
        );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'Workout title', hintText: 'e.g. Push Day'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: WorkoutType.values.map((t) {
              return ChoiceChip(
                label: Text(t.name),
                selected: _type == t,
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
                'Date: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
            trailing: TextButton(onPressed: _pickDate, child: const Text('Change')),
          ),
          Text('Duration: $_durationMinutes min',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _durationMinutes.toDouble(),
            min: 5,
            max: 180,
            divisions: 35,
            label: '$_durationMinutes min',
            onChanged: (v) => setState(() => _durationMinutes = v.round()),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Text('Exercises', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(
                onPressed: _addExercise,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
          if (_exercises.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text('No exercises added yet.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted)),
            )
          else
            ..._exercises.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${e.name} — ${e.sets}×${e.reps}'
                          '${e.weightKg > 0 ? ' @ ${e.weightKg}kg' : ''}',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _exercises.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Notes (optional)', hintText: 'How did it feel?'),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(onPressed: _save, child: const Text('Save workout')),
        ],
      ),
    );
  }
}
