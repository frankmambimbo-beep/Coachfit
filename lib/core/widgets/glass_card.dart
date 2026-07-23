import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// A frosted-glass style card: subtle blur, translucent fill, soft border.
/// Used as the base container for dashboard tiles, summary cards, etc.
/// Wrap any content in GlassCard(child: ...) to get the look for free.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppRadius.md,
    this.onTap, // optional — pass a function to make the card tappable
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // Clip to rounded corners so the blur doesn't bleed outside them
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        // This is what creates the "frosted glass" blur effect
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: AppColors.surfaceGlass,
          child: InkWell(
            onTap: onTap, // shows a ripple effect when tapped, if provided
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
