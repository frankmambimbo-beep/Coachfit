import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/progress_ring.dart';
import '../data/challenges_repository.dart';
import '../domain/challenge.dart';
import '../domain/challenge_templates.dart';

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  IconData _iconFor(ChallengeCategory c) {
    switch (c) {
      case ChallengeCategory.fitness:
        return Icons.fitness_center;
      case ChallengeCategory.nutrition:
        return Icons.water_drop_outlined;
      case ChallengeCategory.mindfulness:
        return Icons.self_improvement;
      case ChallengeCategory.discipline:
        return Icons.bolt;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joined = ref.watch(challengesRepositoryProvider);
    final active = joined.where((c) => !c.completed && !c.isExpired).toList();
    final finished = joined.where((c) => c.completed).toList();
    final joinedTemplateIds = joined
        .where((c) => !c.completed && !c.isExpired)
        .map((c) => c.templateId)
        .toSet();
    final available =
        challengeCatalog.where((t) => !joinedTemplateIds.contains(t.id)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          if (active.isNotEmpty) ...[
            Text('Active',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            ...active.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ActiveChallengeTile(challenge: c, icon: _iconFor(c.category)),
                )),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text('Available',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                "You've joined every challenge available right now!",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            )
          else
            ...available.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _CatalogTile(template: t, icon: _iconFor(t.category)),
                )),
          if (finished.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('Completed',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            ...finished.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _ActiveChallengeTile(challenge: c, icon: _iconFor(c.category)),
                )),
          ],
        ],
      ),
    );
  }
}

class _ActiveChallengeTile extends ConsumerWidget {
  final Challenge challenge;
  final IconData icon;

  const _ActiveChallengeTile({required this.challenge, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkedIn = challenge.isCheckedInToday;

    return GlassCard(
      child: Row(
        children: [
          ProgressRing(
            progress: challenge.progress,
            size: 56,
            strokeWidth: 6,
            gradient: challenge.completed
                ? const LinearGradient(
                    colors: [AppColors.accentTertiary, AppColors.accentTertiary])
                : AppColors.primaryGradient,
            centerLabel: Icon(
              challenge.completed ? Icons.check : icon,
              size: 20,
              color: challenge.completed
                  ? AppColors.accentTertiary
                  : AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  challenge.completed
                      ? 'Completed 🎉  ·  +${challenge.xpReward} XP earned'
                      : '${challenge.daysCompleted} / ${challenge.durationDays} days',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          if (!challenge.completed)
            IconButton(
              icon: Icon(
                checkedIn ? Icons.check_circle : Icons.radio_button_unchecked,
                color: checkedIn ? AppColors.accentTertiary : Colors.grey,
                size: 32,
              ),
              onPressed: checkedIn
                  ? null
                  : () => ref
                      .read(challengesRepositoryProvider.notifier)
                      .checkInToday(challenge.id),
            ),
        ],
      ),
    );
  }
}

class _CatalogTile extends ConsumerWidget {
  final ChallengeTemplate template;
  final IconData icon;

  const _CatalogTile({required this.template, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      child: Row(
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
                Text(template.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(template.description,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text('${template.durationDays} days  ·  +${template.xpReward} XP',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(challengesRepositoryProvider.notifier)
                .joinChallenge(template),
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
