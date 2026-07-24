import 'package:flutter/material.dart';
import '../../../core/widgets/phase_placeholder.dart';

/// Placeholder for the Stats tab — charts, heat maps, and long-term
/// progress tracking are built out in Phase 8, once there's real
/// workout/habit data to actually chart.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      icon: Icons.bar_chart_rounded,
      title: 'Statistics',
      description: 'Charts, heat maps, and long-term progress tracking arrive in Phase 8.',
    );
  }
}
