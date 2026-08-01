import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../profile/data/profile_repository.dart';
import '../../habits/data/habits_repository.dart';
import '../../habits/domain/habit.dart';
import '../../goals/data/goals_repository.dart';
import '../../challenges/data/challenges_repository.dart';
import '../../nutrition/data/nutrition_repository.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileRepositoryProvider);

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back,', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                      Text(profile.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                _StreakBadge(streak: profile.currentStreak),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              child: Row(
                children: [
                  ProgressRing(
                    progress: profile.levelProgress,
                    size: 88,
                    strokeWidth: 8,
                    centerLabel: Text('Lv ${profile.level}', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${profile.xp} / ${profile.xpToNextLevel} XP',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Keep going — every rep and habit counts.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const _TodayProgressCard(),
            const SizedBox(height: AppSpacing.md),
            const _DailyQuoteCard(),
            const SizedBox(height: AppSpacing.md),
            const _TodayHabitsCard(),
            const SizedBox(height: AppSpacing.md),
            const _GoalsSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const _ChallengesSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            const _WaterSummaryCard(),
            const SizedBox(height: AppSpacing.md),
            _SectionPlaceholder(
              title: "Today's Workout",
              subtitle: 'Structured workout plans arrive in a later phase',
              icon: Icons.fitness_center_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            _SectionPlaceholder(
              title: 'Mood Summary',
              subtitle: 'Mood & journal — coming right after this',
              icon: Icons.mood_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text('$streak', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard();

  @override
  Widget build(BuildContext context) {
    const double todayProgress = 0.0;
    return GlassCard(
      child: Row(
        children: [
          const ProgressRing(progress: todayProgress, size: 64, strokeWidth: 6),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's Progress", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppSpacing.xs),
                Text('0% of tasks complete — nothing scheduled yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuoteCard extends StatelessWidget {
  const _DailyQuoteCard();

  static const List<String> _quotes = [
    'Discipline is choosing between what you want now and what you want most.',
    "Small steps every day lead to big results over time.",
    'You don\'t have to be extreme, just consistent.',
    'The body achieves what the mind believes.',
  ];

  @override
  Widget build(BuildContext context) {
    final quote = _quotes[DateTime.now().day % _quotes.length];
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.accentTertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(quote, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}

class _TodayHabitsCard extends ConsumerWidget {
  const _TodayHabitsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsRepositoryProvider);
    final dueToday = habits.where((h) => h.isDueToday).toList();

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text("Today's Habits",
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              ),
              TextButton(
                onPressed: () => context.go('/habits'),
                child: const Text('View all'),
              ),
            ],
          ),
          if (dueToday.isEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text('No habits due today. Add one from the Habits tab.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            ...dueToday.take(3).map((h) => _HabitRow(habit: h)),
            if (dueToday.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text('+${dueToday.length - 3} more due today',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
              ),
          ],
        ],
      ),
    );
  }
}

class _HabitRow extends ConsumerWidget {
  const _HabitRow({required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = habit.isCompletedToday;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(habitsRepositoryProvider.notifier).toggleCompletionToday(habit.id),
            child: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? AppColors.accentTertiary : AppColors.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              habit.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? AppColors.textMuted : null,
                  ),
            ),
          ),
          Text('+${habit.xpReward} XP',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _GoalsSummaryCard extends ConsumerWidget {
  const _GoalsSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsRepositoryProvider);
    final active = goals.where((g) => !g.completed).toList();

    return GlassCard(
      onTap: () => context.go('/goals'),
      child: Row(
        children: [
          const Icon(Icons.flag_outlined, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Goals in Progress',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  active.isEmpty
                      ? 'No active goals — tap to set one'
                      : '${active.length} active · closest: ${(active..sort((a, b) => b.progress.compareTo(a.progress))).first.title}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _ChallengesSummaryCard extends ConsumerWidget {
  const _ChallengesSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesRepositoryProvider);
    final active = challenges.where((c) => !c.completed && !c.isExpired).toList();

    return GlassCard(
      onTap: () => context.go('/challenges'),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_outlined, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Challenges',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  active.isEmpty
                      ? 'Join a challenge to build momentum'
                      : '${active.length} active — tap to check in',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// Real "Water Intake" card — replaces the Phase 1 placeholder that's
/// been sitting on the dashboard since the very first build.
class _WaterSummaryCard extends ConsumerWidget {
  const _WaterSummaryCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final water = ref.watch(waterRepositoryProvider);

    return GlassCard(
      onTap: () => context.go('/nutrition'),
      child: Row(
        children: [
          const Icon(Icons.water_drop_outlined, color: AppColors.accentSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Water Intake',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${water.glassesConsumed} / ${water.dailyGoalGlasses} glasses today',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.accentSecondary),
            onPressed: () => ref.read(waterRepositoryProvider.notifier).addGlass(),
          ),
        ],
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
