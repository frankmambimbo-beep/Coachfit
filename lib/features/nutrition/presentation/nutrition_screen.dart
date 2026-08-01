import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../data/nutrition_repository.dart';
import '../domain/nutrition_entry.dart';

class NutritionScreen extends ConsumerWidget {
  const NutritionScreen({super.key});

  IconData _iconFor(MealType m) {
    switch (m) {
      case MealType.breakfast:
        return Icons.free_breakfast_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.dinner:
        return Icons.dinner_dining_outlined;
      case MealType.snack:
        return Icons.cookie_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutrition = ref.watch(nutritionRepositoryProvider);
    final water = ref.watch(waterRepositoryProvider);
    final today = DateTime.now();
    final todayEntries =
        ref.read(nutritionRepositoryProvider.notifier).entriesForDay(today);
    final todayCalories =
        ref.read(nutritionRepositoryProvider.notifier).caloriesForDay(today);

    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/nutrition/add'),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: AppColors.accentSecondary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Water Intake',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text('${water.glassesConsumed} / ${water.dailyGoalGlasses} glasses',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: water.dailyGoalGlasses == 0
                      ? 0
                      : (water.glassesConsumed / water.dailyGoalGlasses).clamp(0, 1),
                  backgroundColor: AppColors.surfaceGlass,
                  color: AppColors.accentSecondary,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(waterRepositoryProvider.notifier).removeGlass(),
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text('Glass'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(waterRepositoryProvider.notifier).addGlass(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Glass'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Row(
              children: [
                const Icon(Icons.local_fire_department_outlined,
                    color: AppColors.accentTertiary),
                const SizedBox(width: AppSpacing.sm),
                Text('Today: $todayCalories cal',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Meals',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          if (todayEntries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text('No meals logged today.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textMuted)),
            )
          else
            ...todayEntries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _EntryTile(entry: e, icon: _iconFor(e.mealType)),
                )),
        ],
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  final NutritionEntry entry;
  final IconData icon;

  const _EntryTile({required this.entry, required this.icon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassCard(
      onLongPress: () =>
          ref.read(nutritionRepositoryProvider.notifier).deleteEntry(entry.id),
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
                Text(entry.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                Text(entry.mealType.name,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Text('${entry.calories} cal',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
