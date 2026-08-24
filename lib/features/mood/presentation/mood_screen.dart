import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/mood_repository.dart';
import '../domain/mood_entry.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  String _emojiFor(MoodLevel m) {
    switch (m) {
      case MoodLevel.terrible:
        return '😞';
      case MoodLevel.bad:
        return '🙁';
      case MoodLevel.okay:
        return '😐';
      case MoodLevel.good:
        return '🙂';
      case MoodLevel.great:
        return '😄';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(moodRepositoryProvider);
    final todayEntry = ref.read(moodRepositoryProvider.notifier).todayEntry;
    final pastEntries = entries.where((e) => e.id != todayEntry?.id).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mood & Journal')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GlassCard(
            onTap: () => context.push('/mood/log'),
            child: Row(
              children: [
                Text(
                  todayEntry != null ? _emojiFor(todayEntry.mood) : '➕',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todayEntry != null ? 'Today: ${todayEntry.mood.name}' : 'How are you feeling today?',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        todayEntry != null ? 'Tap to update' : 'Tap to check in',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textMuted),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (pastEntries.isNotEmpty) ...[
            Text('History',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            ...pastEntries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _MoodTile(entry: e, emoji: _emojiFor(e.mood)),
                )),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                'No past entries yet. Your daily check-ins will show up here.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoodTile extends ConsumerWidget {
  final MoodEntry entry;
  final String emoji;

  const _MoodTile({required this.entry, required this.emoji});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = DateFormat('EEE, MMM d').format(entry.date);

    return GlassCard(
      onLongPress: () =>
          ref.read(moodRepositoryProvider.notifier).deleteEntry(entry.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateLabel,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
                if (entry.journalText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(entry.journalText,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
