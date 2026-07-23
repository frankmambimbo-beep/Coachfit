import 'package:flutter/material.dart';

/// Centralized color tokens for CoachFit.
/// Keeping every color in one file means you can restyle the whole
/// app later by editing values here instead of hunting through screens.
class AppColors {
  AppColors._(); // prevents anyone from accidentally instantiating this

  // Base surfaces (dark theme background layers, darkest to lightest)
  static const Color background = Color(0xFF0B0D12);
  static const Color surface = Color(0xFF14161D);
  static const Color surfaceElevated = Color(0xFF1C1F29);
  static const Color surfaceGlass = Color(0x1AFFFFFF); // translucent white

  // Text colors
  static const Color textPrimary = Color(0xFFF5F6FA);
  static const Color textSecondary = Color(0xFFA0A4B2);
  static const Color textMuted = Color(0xFF6B6F7D);

  // Brand accent colors used for buttons, highlights, progress rings
  static const Color accentPrimary = Color(0xFF7C5CFF); // electric violet
  static const Color accentSecondary = Color(0xFFFF6B6B); // coral
  static const Color accentTertiary = Color(0xFF3DDC97); // mint (success/XP)

  // Semantic colors (meaning-based, not just decorative)
  static const Color success = Color(0xFF3DDC97);
  static const Color warning = Color(0xFFFFB84D);
  static const Color danger = Color(0xFFFF5C5C);
  static const Color info = Color(0xFF5CC8FF);

  // Gradients — reused across buttons, progress rings, XP bars
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [accentTertiary, accentPrimary],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0B0D12), Color(0xFF161821)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // A soft white border used on "glass" cards
  static Color glassBorder = Colors.white.withOpacity(0.08);
}
