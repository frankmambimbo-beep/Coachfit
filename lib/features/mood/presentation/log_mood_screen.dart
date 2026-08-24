import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../data/mood_repository.dart';
import '../domain/mood_entry.dart';

class LogMoodScreen extends ConsumerStatefulWidget {
  const LogMoodScreen({super.key});

  @override
  ConsumerState<LogMoodScreen> createState() => _LogMoodScreenState();
}

class _LogMoodScreenState extends ConsumerState<LogMoodScreen> {
  late final TextEditingController _journalController;
  MoodLevel? _selectedMood;

  static const _emojis = {
    MoodLevel.terrible: '😞',
    MoodLevel.bad: '🙁',
    MoodLevel.okay: '😐',
    MoodLevel.good: '🙂',
    MoodLevel.great: '😄',
  };

  @override
  void initState() {
    super.initState();
    final existing = ref.read(moodRepositoryProvider.notifier).todayEntry;
    _selectedMood = existing?.mood;
    _journalController = TextEditingController(text: existing?.journalText ?? '');
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _save() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick how you\'re feeling first.')),
      );
      return;
    }

    ref.read(moodRepositoryProvider.notifier).logToday(
          mood: _selectedMood!,
          journalText: _journalController.text.trim(),
        );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-in')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text('How are you feeling?',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodLevel.values.map((m) {
              final selected = _selectedMood == m;
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? AppColors.accentPrimary.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: selected ? AppColors.accentPrimary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Text(_emojis[m]!, style: const TextStyle(fontSize: 32)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Journal (optional)',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _journalController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'What\'s on your mind today?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(onPressed: _save, child: const Text('Save check-in')),
        ],
      ),
    );
  }
}
