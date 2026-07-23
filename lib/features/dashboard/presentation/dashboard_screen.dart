import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../profile/data/profile_repository.dart';

/// The daily home dashboard (the "Home" tab). Right now this renders
/// the real profile data (name, level, XP, streak) wired to Hive, plus
/// clearly-labeled placeholder cards for sections that later phases
/// will build out (habits, workout-of-the-day, water, goals, mood).
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch rebuilds this widget automatically whenever the
    // profile changes anywhere in the app (e.g. after gaining XP).
    final profile = ref.watch(profileRepositoryProvider);

    if (profile == null) {
      // Shouldn't normally happen (router redirects to onboarding first)
      // but guards against a null profile during the first frame.
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
            // These sections are placeholders until their respective
            // phases are built — clearly labeled so nothing is mistaken
            // for finished functionality.
            _SectionPlaceholder(title: "Today's Habits", subtitle: 'Habit tracking arrives in Phase 3', icon: Icons.check_circle_outline),
            const SizedBox(height: AppSpacing.md),
            _SectionPlaceholder(title: "Today's Workout", subtitle: 'Workout plans arrive in Phase 5', icon: Icons.fitness_center_outlined),
            const SizedBox(height: AppSpacing.md),
            _SectionPlaceholder(title: 'Water Intake', subtitle: 'Nutrition tracking arrives in Phase 7', icon: Icons.water_drop_outlined),
            const SizedBox(height: AppSpacing.md),
            _SectionPlaceholder(title: 'Goals in Progress', subtitle: 'Goal tracking arrives in Phase 4', icon: Icons.flag_outlined),
            const SizedBox(height: AppSpacing.md),
            _SectionPlaceholder(title: 'Mood Summary', subtitle: 'Mood & journal arrive in Phase 7', icon: Icons.mood_outlined),
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
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(AppRadius.pill)),
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
    // Hardcoded at 0% for now — will be calculated from real habits/
    // workout/goal completion once those features exist.
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
    'Small steps every day lead to big results over time.',
    "You don't have to be extreme, just consistent.",
    'The body achieves what the mind believes.',
  ];

  @override
  Widget build(BuildContext context) {
    // Picks a different quote each day based on the day of month
    final quote = _quotes[DateTime.now().day % _quotes.length];
    return GlassCard(
      child: Row(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.accentTertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(quote, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic))),
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
