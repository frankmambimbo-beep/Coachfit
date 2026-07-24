import 'package:flutter/material.dart';
import '../../../core/widgets/phase_placeholder.dart';

/// Placeholder for the Habits tab — built out in Phase 3.
class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PhasePlaceholder(
      icon: Icons.checklist_rounded,
      title: 'Habits',
      description: 'Daily habit tracking with streaks and XP rewards arrives in Phase 3.',
    );
  }
}
