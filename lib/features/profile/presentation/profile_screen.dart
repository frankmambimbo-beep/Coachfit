import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/profile_repository.dart';
import '../domain/user_profile.dart';
// Reuses the goalLabels map from the onboarding file instead of
// duplicating it — "show" limits the import to just that one symbol.
import '../../onboarding/presentation/profile_setup_screen.dart' show goalLabels;

/// The Profile tab. Unlike the other placeholder tabs, this one is
/// fully real — it just displays the data collected during onboarding.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileRepositoryProvider);
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                if (profile.isGuest)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('Guest account', style: TextStyle(color: AppColors.textMuted)),
                  ),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Age', value: '${profile.age}'),
                _InfoRow(label: 'Gender', value: profile.gender),
                _InfoRow(label: 'Height', value: '${profile.heightCm.toStringAsFixed(0)} cm'),
                _InfoRow(label: 'Weight', value: '${profile.weightKg.toStringAsFixed(0)} kg'),
                _InfoRow(label: 'Fitness level', value: profile.fitnessLevel.name),
                _InfoRow(label: 'Primary goal', value: goalLabels[profile.primaryGoal] ?? ''),
                _InfoRow(label: 'Location', value: profile.workoutLocation == WorkoutLocation.home ? 'Home' : 'Gym'),
                _InfoRow(label: 'Level', value: '${profile.level}'),
                _InfoRow(label: 'XP', value: '${profile.xp} / ${profile.xpToNextLevel}'),
                _InfoRow(label: 'Streak', value: '${profile.currentStreak} days'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () async {
              // Wipes the saved profile and sends the user back through
              // onboarding — handy for testing during development.
              await ref.read(profileRepositoryProvider.notifier).clear();
              if (context.mounted) context.go('/onboarding');
            },
            child: const Text('Reset & Restart Onboarding'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
