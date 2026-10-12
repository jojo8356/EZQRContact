import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/theme/typography.dart';

/// Builds a Material 3 [ThemeData] from the live ENCRE [colors] map.
///
/// Called on every dark-mode lerp frame so Material widgets (chips, FAB,
/// dialogs, inputs) stay in sync with `currentColors`.
ThemeData buildAppTheme({
  required Map<String, Color> colors,
  required bool isDark,
}) {
  final bg = colors['bg']!;
  final surface = colors['surface']!;
  final raised = colors['surface-raised']!;
  final ink = colors['text']!;
  final muted = colors['text-muted']!;
  final copper = colors['button-color']!;
  final onCopper = colors['on-button']!;
  final navy = colors['navy']!;
  final border = colors['border']!;
  final danger = colors['danger']!;
  final popup = colors['popup-background']!;
  final shadow = colors['shadow']!;

  var brightness = Brightness.light;
  var overlay = SystemUiOverlayStyle.dark;
  if (isDark) {
    brightness = Brightness.dark;
    overlay = SystemUiOverlayStyle.light;
  }
  final scheme = ColorScheme(
    brightness: brightness,
    primary: copper,
    onPrimary: onCopper,
    secondary: navy,
    onSecondary: onCopper,
    surface: bg,
    onSurface: ink,
    error: danger,
    onError: onCopper,
    outline: border,
    surfaceContainerLowest: bg,
    surfaceContainerLow: surface,
    surfaceContainer: surface,
    surfaceContainerHigh: raised,
    surfaceContainerHighest: raised,
  );

  final textTheme = buildAppTextTheme(colors);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    fontFamily: AppFonts.ui,
    textTheme: textTheme,
    iconTheme: IconThemeData(color: ink, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
      iconTheme: IconThemeData(color: ink, size: 24),
      systemOverlayStyle: overlay,
    ),
    dividerColor: border,
    dividerTheme: DividerThemeData(
      color: border,
      space: 1,
      thickness: AppTokens.hairline,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: const EdgeInsets.symmetric(
        horizontal: AppTokens.s4,
        vertical: AppTokens.s2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.rLg),
        side: BorderSide(color: border),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: popup,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.rXl),
        side: BorderSide(color: border),
      ),
      titleTextStyle: textTheme.headlineLarge,
      contentTextStyle: textTheme.bodyLarge,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: popup,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.rXl),
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: copper,
        foregroundColor: onCopper,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(AppTokens.tap, AppTokens.buttonH),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s6,
          vertical: AppTokens.s4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rMd),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        backgroundColor: Colors.transparent,
        minimumSize: const Size(AppTokens.tap, AppTokens.buttonH),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.s6,
          vertical: AppTokens.s4,
        ),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.rMd),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: navy,
        textStyle: textTheme.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: copper,
      foregroundColor: onCopper,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: textTheme.bodyLarge?.copyWith(color: muted),
      labelStyle: textTheme.bodySmall,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.s4,
        vertical: AppTokens.s4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.rSm),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.rSm),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.rSm),
        borderSide: BorderSide(color: copper, width: 1.5),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: raised,
      selectedColor: copper,
      labelStyle: textTheme.labelMedium?.copyWith(color: ink),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: onCopper,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.rXs),
        side: BorderSide(color: border),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: bg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.rMd),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: copper),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        return onCopper;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return copper;
        return raised;
      }),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return copper;
        return Colors.transparent;
      }),
      checkColor: WidgetStatePropertyAll(onCopper),
      side: BorderSide(color: border, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: ink,
      textColor: ink,
      titleTextStyle: textTheme.titleMedium,
      subtitleTextStyle: textTheme.bodySmall,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: copper,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: textTheme.labelSmall,
      unselectedLabelStyle: textTheme.labelSmall,
    ),
    shadowColor: shadow,
  );
}

/// Rest-level paper shadow used by cards and the floating nav.
List<BoxShadow> paperShadow(Color shadow, {bool float = false}) {
  if (float) {
    return [
      BoxShadow(
        color: shadow.withValues(alpha: 0.10),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }
  return [
    BoxShadow(
      color: shadow.withValues(alpha: 0.04),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}
