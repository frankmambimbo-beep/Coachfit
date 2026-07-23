/// Design tokens: spacing, corner radius, and animation durations.
/// Using named constants instead of raw numbers (e.g. AppSpacing.md
/// instead of "16") keeps spacing consistent across every screen.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  AppRadius._();
  static const double sm = 12;
  static const double md = 20;
  static const double lg = 28;
  static const double pill = 999; // fully rounded, e.g. pill-shaped buttons
}

class AppDurations {
  AppDurations._();
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 500);
}
