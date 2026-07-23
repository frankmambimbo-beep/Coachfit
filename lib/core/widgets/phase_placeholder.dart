import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A consistent "not built yet" screen for tabs/features that belong to
/// a later development phase. Using this everywhere (instead of a blank
/// screen or fake content) makes it obvious what's real vs. placeholder
/// as the app grows.
class PhasePlaceholder extends StatelessWidget {
  const PhasePlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min, // don't force full height
              children: [
                Icon(icon, size: 56, color: AppColors.textMuted),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
