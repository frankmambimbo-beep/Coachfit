import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/habits_repository.dart';
import '../domain/habit.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _nameController = TextEditingController();
  HabitCategory _category = HabitCategory.fitness;
  HabitFrequency _frequency = HabitFrequency.daily;
  final Set<int> _activeDays = {}; // Monday=1 ... Sunday=7
  int _xpReward = 10;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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

    ref.read(habitsRepositoryProvider.notifier).addHabit(
          name: name,
          category: _category,
          frequency: _frequency,
          activeDays: _activeDays.toList(),
          xpReward: _xpReward,
        );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Habit')),
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
          ElevatedButton(onPressed: _save, child: const Text('Save habit')),
        ],
      ),
    );
  }
}
