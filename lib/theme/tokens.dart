/// Spacing, radius and motion tokens for the ENCRE art direction.
///
/// See `docs/direction-artistique.md`. Color tokens live in `lib/colors.dart`.
abstract final class AppTokens {
  // --- Spacing (4 dp grid) -------------------------------------------------
  /// 4 dp — tight inner gutters.
  static const double s1 = 4;

  /// 8 dp — icon/label gap.
  static const double s2 = 8;

  /// 12 dp — chip padding, grid gap.
  static const double s3 = 12;

  /// 16 dp — card padding, compact screen margin.
  static const double s4 = 16;

  /// 20 dp — default screen margin.
  static const double s5 = 20;

  /// 24 dp — section gap.
  static const double s6 = 24;

  /// 32 dp — after a hero block.
  static const double s8 = 32;

  /// 40 dp — bottom inset above the floating nav.
  static const double s10 = 40;

  /// 48 dp — large empty-state icon well.
  static const double s12 = 48;

  // --- Radius --------------------------------------------------------------
  /// 6 dp — chips, badges.
  static const double rXs = 6;

  /// 10 dp — inputs, small icon buttons.
  static const double rSm = 10;

  /// 14 dp — buttons, tiles.
  static const double rMd = 14;

  /// 18 dp — cards, floating nav.
  static const double rLg = 18;

  /// 24 dp — sheets, dialogs.
  static const double rXl = 24;

  /// Pill — avatars, FAB-like dots only. Never on full-width CTAs.
  static const double rFull = 999;

  // --- Sizes ---------------------------------------------------------------
  /// Minimum tap target (Material / HIG).
  static const double tap = 48;

  /// Default CTA height.
  static const double buttonH = 52;

  /// Floating bottom nav inner height.
  static const double navH = 64;

  /// Featured home tile min height.
  static const double featuredH = 88;

  /// App bar hairline.
  static const double hairline = 1;

  // --- Motion --------------------------------------------------------------
  /// Press feedback.
  static const Duration tMicro = Duration(milliseconds: 120);

  /// Color / fade.
  static const Duration tFast = Duration(milliseconds: 200);

  /// Theme lerp, card expand.
  static const Duration tMed = Duration(milliseconds: 300);

  /// Onboarding page.
  static const Duration tPage = Duration(milliseconds: 400);

  /// Pressed scale — a stamp, not a bounce.
  static const double pressScale = 0.98;
}
