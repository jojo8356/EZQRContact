import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/pages/qr_scanner.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

void main() {
  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  test('scanner controls are copper discs, not white on paper', () {
    final theme = encreScannerTheme();
    expect(theme.controlBackgroundColor, const Color(0xFFC45C26));
    expect(theme.controlForegroundColor, const Color(0xFFFFF8F0));
    expect(
      theme.controlBackgroundColor,
      isNot(theme.controlForegroundColor),
    );
    expect(theme.controlSize, AppTokens.compactWell);
  });

  test('torch-on state stays high-contrast in light mode', () {
    final theme = encreScannerTheme();
    expect(theme.controlActiveBackgroundColor, const Color(0xFF1A1612));
    expect(theme.controlActiveForegroundColor, const Color(0xFFF4EFE6));
  });

  test('scanner controls stay high-contrast in dark mode', () {
    darkProv.forceSetDarkMode(true);
    final theme = encreScannerTheme();
    expect(theme.controlBackgroundColor, const Color(0xFFE07A3D));
    expect(theme.controlForegroundColor, const Color(0xFF1A1612));
    expect(
      theme.controlBackgroundColor,
      isNot(theme.controlForegroundColor),
    );
  });
}
