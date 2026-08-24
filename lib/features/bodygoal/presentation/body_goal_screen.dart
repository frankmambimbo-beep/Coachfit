import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/body_goal_repository.dart';
import '../domain/body_type_goal.dart';
import '../domain/body_type_catalog.dart';

/// Shown once right after onboarding (mandatory first pick), and
/// revisitable any time from the Profile tab to change the goal.
/// [fromOnboarding] controls whether the button at the bottom says
/// "Continue" (→ dashboard) or "Save" (→ back to Profile).
class BodyGoalScreen extends ConsumerStatefulWidget {
  const BodyGoalScreen({super.key, this.fromOnboarding = false});

  final bool fromOnboarding;

  @override
  ConsumerState<BodyGoalScreen> createState() => _BodyGoalScreenState();
}

class _BodyGoalScreenState extends ConsumerState<BodyGoalScreen> {
  BodyTypeGoal? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref.read(bodyGoalRepositoryProvider);
  }

  Future<void> _confirm() async {
    if (_selected == null) return;
    await ref.read(bodyGoalRepositoryProvider.notifier).selectGoal(_selected!);
    if (!mounted) return;

    if (widget.fromOnboarding) {
      context.go('/dashboard');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _selected != null ? bodyTypeCatalog[_selected!] : null;

    return Scaffold(
      appBar: widget.fromOnboarding
          ? null
          : AppBar(title: const Text('Body Goal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (widget.fromOnboarding) ...[
              Text('What build are you working toward?',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "We'll tailor exercise recommendations to this — you can change it any time from your Profile.",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            ...BodyTypeGoal.values.map((goal) {
              final catalogInfo = bodyTypeCatalog[goal]!;
              final selected = _selected == goal;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(
                  onTap: () => setState(() => _selected = goal),
                  child: Row(
                    children: [
                      Icon(
                        selected ? Icons.check_circle : Icons.circle_outlined,
                        color: selected ? AppColors.accentPrimary : AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(catalogInfo.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(catalogInfo.description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (info != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text('Recommended exercises',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: info.recommendedExercises
                      .map((e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.fitness_center,
                                    size: 16, color: AppColors.accentTertiary),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(child: Text(e)),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _selected != null ? _confirm : null,
              child: Text(widget.fromOnboarding ? 'Continue' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
