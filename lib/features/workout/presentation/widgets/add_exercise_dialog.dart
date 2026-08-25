import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../profile/data/profile_repository.dart';
import '../../../exercises/domain/exercise_info.dart';
import '../../../exercises/domain/exercise_library.dart';
import '../../../exercises/domain/weight_recommendation.dart';
import '../../domain/workout_session.dart';

/// Exercise-entry dialog used by AddWorkoutScreen. Lets the person
/// search the exercise library by name; picking a free-weight exercise
/// auto-fills a suggested starting weight (editable) based on their
/// fitness level and body weight. Bodyweight/cardio picks hide the
/// weight field entirely since there's nothing to suggest.
class AddExerciseDialog extends ConsumerStatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  ConsumerState<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends ConsumerState<AddExerciseDialog> {
  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '0');

  ExerciseInfo? _selected;

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _onExerciseSelected(ExerciseInfo exercise) {
    setState(() => _selected = exercise);
    _nameController.text = exercise.name;

    if (exercise.needsWeight) {
      final profile = ref.read(profileRepositoryProvider);
      if (profile != null) {
        final suggested = WeightRecommendation.recommendedKg(
          exercise: exercise,
          level: profile.fitnessLevel,
          bodyWeightKg: profile.weightKg,
        );
        if (suggested != null) {
          _weightController.text = suggested.toString();
        }
      }
    } else {
      _weightController.text = '0';
    }
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(
      context,
      ExerciseEntry(
        name: name,
        sets: int.tryParse(_setsController.text) ?? 0,
        reps: int.tryParse(_repsController.text) ?? 0,
        weightKg: double.tryParse(_weightController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showWeight = _selected?.needsWeight ?? true; // default to showing until a pick clarifies it

    return AlertDialog(
      title: const Text('Add exercise'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<ExerciseInfo>(
              displayStringForOption: (e) => e.name,
              optionsBuilder: (textValue) {
                if (textValue.text.isEmpty) return const Iterable<ExerciseInfo>.empty();
                return exerciseLibrary.where((e) =>
                    e.name.toLowerCase().contains(textValue.text.toLowerCase()));
              },
              onSelected: _onExerciseSelected,
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                // Keep our own controller in sync so free-typed names
                // (not in the library) still work when saving.
                controller.addListener(() {
                  _nameController.text = controller.text;
                });
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    hintText: 'e.g. Squats',
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Sets'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Reps'),
                  ),
                ),
              ],
            ),
            if (showWeight) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  helperText: _selected?.needsWeight == true
                      ? 'Suggested from your fitness level — adjust as needed'
                      : null,
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  'Bodyweight exercise — no weight needed.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: _save, child: const Text('Add')),
      ],
    );
  }
}
