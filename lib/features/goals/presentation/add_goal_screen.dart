import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../data/goals_repository.dart';
import '../domain/goal.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  const AddGoalScreen({super.key});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();
  GoalCategory _category = GoalCategory.custom;
  DateTime? _deadline;
  int _xpReward = 50;

  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    final target = double.tryParse(_targetController.text.trim());
    final unit = _unitController.text.trim();

    if (title.isEmpty || target == null || target <= 0 || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fill in a title, a target above 0, and a unit.')),
      );
      return;
    }

    ref.read(goalsRepositoryProvider.notifier).addGoal(
          title: title,
          category: _category,
          targetValue: target,
          unit: unit,
          deadline: _deadline,
          xpReward: _xpReward,
        );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Goal')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
                labelText: 'Goal title', hintText: 'e.g. Lose 5kg'),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: GoalCategory.values.map((c) {
              return ChoiceChip(
                label: Text(c.name),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _targetController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Target', hintText: 'e.g. 5'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                      labelText: 'Unit', hintText: 'e.g. kg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_deadline == null
                ? 'No deadline set'
                : 'Deadline: ${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}'),
            trailing: TextButton(
              onPressed: _pickDeadline,
              child: const Text('Pick date'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('XP reward on completion: $_xpReward',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _xpReward.toDouble(),
            min: 20,
            max: 200,
            divisions: 9,
            label: '$_xpReward XP',
            onChanged: (v) => setState(() => _xpReward = v.round()),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(onPressed: _save, child: const Text('Save goal')),
        ],
      ),
    );
  }
}
