import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/habits_repository.dart';
import '../domain/habit.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key, this.habitToEdit});

  /// When provided, the form is pre-filled and saving updates this
  /// habit instead of creating a new one.
  final Habit? habitToEdit;

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  late final TextEditingController _nameController;
  late HabitCategory _category;
  late HabitFrequency _frequency;
  late final Set<int> _activeDays;
  late int _xpReward;

  bool get _isEditing => widget.habitToEdit != null;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final existing = widget.habitToEdit;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _category = existing?.category ?? HabitCategory.fitness;
    _frequency = existing?.frequency ?? HabitFrequency.daily;
    _activeDays = Set.of(existing?.activeDays ?? []);
    _xpReward = existing?.xpReward ?? 10;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    if (_frequency == HabitFrequency.specificDays && _activeDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pick at least one day, or switch to Daily.')),
      );
      return;
    }

    if (_isEditing) {
      ref.read(habitsRepositoryProvider.notifier).updateHabit(
            id: widget.habitToEdit!.id,
            name: name,
            category: _category,
            frequency: _frequency,
            activeDays: _activeDays.toList(),
            xpReward: _xpReward,
          );
    } else {
      ref.read(habitsRepositoryProvider.notifier).addHabit(
            name: name,
            category: _category,
            frequency: _frequency,
            activeDays: _activeDays.toList(),
            xpReward: _xpReward,
          );
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Habit' : 'New Habit')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Habit name', hintText: 'e.g. Drink 2L water'),
          ),
          const SizedBox(height: 24),
          const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: HabitCategory.values.map((c) {
              return ChoiceChip(
                label: Text(c.name),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<HabitFrequency>(
            segments: const [
              ButtonSegment(value: HabitFrequency.daily, label: Text('Daily')),
              ButtonSegment(
                  value: HabitFrequency.specificDays,
                  label: Text('Specific days')),
            ],
            selected: {_frequency},
            onSelectionChanged: (s) => setState(() => _frequency = s.first),
          ),
          if (_frequency == HabitFrequency.specificDays) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: List.generate(7, (i) {
                final day = i + 1;
                return FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: _activeDays.contains(day),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _activeDays.add(day);
                      } else {
                        _activeDays.remove(day);
                      }
                    });
                  },
                );
              }),
            ),
          ],
          const SizedBox(height: 24),
          Text('XP reward: $_xpReward',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _xpReward.toDouble(),
            min: 5,
            max: 50,
            divisions: 9,
            label: '$_xpReward XP',
            onChanged: (v) => setState(() => _xpReward = v.round()),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _save,
            child: Text(_isEditing ? 'Save changes' : 'Save habit'),
          ),
        ],
      ),
    );
  }
}
