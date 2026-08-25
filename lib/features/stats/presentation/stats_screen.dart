import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass_card.dart';
import '../../profile/data/profile_repository.dart';
import '../../habits/data/habits_repository.dart';
import '../../habits/domain/habit.dart';
import '../../workout/data/workout_repository.dart';
import '../../mood/data/mood_repository.dart';
import '../../mood/domain/mood_entry.dart';
import '../../nutrition/data/nutrition_repository.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileRepositoryProvider);
    final habits = ref.watch(habitsRepositoryProvider);
    final workouts = ref.watch(workoutRepositoryProvider);
    final moods = ref.watch(moodRepositoryProvider);
    final waterHistory = ref.watch(waterRepositoryProvider.notifier).last7Days();

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Stats')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SummaryRow(
            level: profile.level,
            totalWorkouts: workouts.length,
            longestHabitStreak: habits.isEmpty
                ? 0
                : habits.map((h) => h.longestStreak).reduce((a, b) => a > b ? a : b),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Habit Completion — Last 7 Days',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(child: _HabitCompletionChart(habits: habits)),
          const SizedBox(height: AppSpacing.lg),
          Text('Workouts — Last 7 Days',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(child: _WorkoutFrequencyChart(sessions: workouts)),
          const SizedBox(height: AppSpacing.lg),
          Text('Mood Trend — Last 14 Days',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            child: moods.isEmpty
                ? _EmptyChartMessage(text: 'Log your mood to see trends here.')
                : _MoodTrendChart(entries: moods),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Water Intake — Last 7 Days',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(child: _WaterChart(logs: waterHistory)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int level;
  final int totalWorkouts;
  final int longestHabitStreak;

  const _SummaryRow({
    required this.level,
    required this.totalWorkouts,
    required this.longestHabitStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'Level', value: '$level')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(label: 'Workouts', value: '$totalWorkouts')),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _StatCard(label: 'Best Streak', value: '$longestHabitStreak')),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700, color: AppColors.accentPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  final String text;
  const _EmptyChartMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Text(text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
      ),
    );
  }
}

// Bar chart: % of that day's due habits that were completed, for the
// last 7 days.
class _HabitCompletionChart extends StatelessWidget {
  final List<Habit> habits;
  const _HabitCompletionChart({required this.habits});

  @override
  Widget build(BuildContext context) {
    final today = Habit.dateOnly(DateTime.now());
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final percentages = days.map((day) {
      final dueThatDay = habits.where((h) {
        if (h.frequency == HabitFrequency.daily) return true;
        return h.activeDays.contains(day.weekday);
      }).toList();

      if (dueThatDay.isEmpty) return 0.0;

      final completedCount = dueThatDay
          .where((h) => h.completions.any((c) => Habit.dateOnly(c) == day))
          .length;

      return completedCount / dueThatDay.length;
    }).toList();

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: 1,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(DateFormat('E').format(days[index]),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(days.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: percentages[i],
                  color: AppColors.accentTertiary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// Bar chart: number of workout sessions logged per day, last 7 days.
class _WorkoutFrequencyChart extends StatelessWidget {
  final List<dynamic> sessions; // WorkoutSession, kept dynamic to avoid extra import churn
  const _WorkoutFrequencyChart({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final counts = days.map((day) {
      return sessions.where((s) {
        final d = s.date as DateTime;
        return DateTime(d.year, d.month, d.day) == day;
      }).length;
    }).toList();

    final maxCount = counts.isEmpty ? 1 : (counts.reduce((a, b) => a > b ? a : b)).clamp(1, 999);

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxCount.toDouble() + 1,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(DateFormat('E').format(days[index]),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(days.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: counts[i].toDouble(),
                  color: AppColors.accentPrimary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// Line chart: mood level (0=terrible..4=great) over the last 14 days,
// connecting only days that actually have a logged entry.
class _MoodTrendChart extends StatelessWidget {
  final List<dynamic> entries; // MoodEntry
  const _MoodTrendChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    final today = MoodEntry.dateOnly(DateTime.now());
    final cutoff = today.subtract(const Duration(days: 13));

    final relevant = entries.where((e) {
      final d = MoodEntry.dateOnly(e.date as DateTime);
      return !d.isBefore(cutoff);
    }).toList()
      ..sort((a, b) => (a.date as DateTime).compareTo(b.date as DateTime));

    if (relevant.isEmpty) {
      return const _EmptyChartMessage(text: 'Log your mood to see trends here.');
    }

    final spots = relevant.map((e) {
      final daysSinceCutoff =
          MoodEntry.dateOnly(e.date as DateTime).difference(cutoff).inDays;
      final moodValue = (e.mood as MoodLevel).index.toDouble();
      return FlSpot(daysSinceCutoff.toDouble(), moodValue);
    }).toList();

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 4,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.accentSecondary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accentSecondary.withOpacity(0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bar chart: glasses of water logged per day, last 7 days.
class _WaterChart extends StatelessWidget {
  final List<dynamic> logs; // WaterLog
  const _WaterChart({required this.logs});

  @override
  Widget build(BuildContext context) {
    final maxGoal = logs.isEmpty
        ? 8
        : (logs.map((l) => l.dailyGoalGlasses as int).reduce((a, b) => a > b ? a : b));

    return SizedBox(
      height: 160,
      child: BarChart(
        BarChartData(
          maxY: maxGoal.toDouble() + 2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= logs.length) return const SizedBox();
                  final date = logs[index].date as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(DateFormat('E').format(date),
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(logs.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: (logs[i].glassesConsumed as int).toDouble(),
                  color: AppColors.accentSecondary,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
