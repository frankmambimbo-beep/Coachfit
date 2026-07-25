import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

/// The very first screen a new user sees. Sets the tone: premium,
/// motivational, low-friction.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, size: 48, color: Colors.white),
                ).animate().scale(duration: AppDurations.slow, curve: Curves.elasticOut),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'CoachFit',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Your personal coach — for discipline, fitness,\nand progress that actually sticks.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
                const Spacer(flex: 2),
                ElevatedButton(
                  onPressed: () => context.go('/onboarding'),
                  child: const Text('Create Account'),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.go('/onboarding'),
                  child: const Text('Continue as Guest'),
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
