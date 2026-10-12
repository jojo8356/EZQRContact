import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/colors.dart';
import 'package:qr_code_app/theme/app_theme.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:qr_code_app/theme/typography.dart';

/// Hex values frozen from `docs/direction-artistique.md` §7.2 / §8.1.
/// These tests fail if the palette drifts back to the v1 blue/purple.
void main() {
  const papier = Color(0xFFF4EFE6);
  const carte = Color(0xFFFFFCF7);
  const sable = Color(0xFFEBE4D8);
  const encre = Color(0xFF1A1612);
  const cendre = Color(0xFF6F675C);
  const cuivre = Color(0xFFC45C26);
  const onCuivre = Color(0xFFFFF8F0);
  const marine = Color(0xFF1F3D4D);
  const ligne = Color(0xFFDDD4C6);
  const vertEncre = Color(0xFF3D6B4F);
  const rougeCachet = Color(0xFFB42318);

  const nuit = Color(0xFF141210);
  const carteNuit = Color(0xFF1E1B18);
  const sableNuit = Color(0xFF2A2622);
  const ivoire = Color(0xFFF3EDE4);
  const cendreNuit = Color(0xFFA89F93);
  const cuivreNuit = Color(0xFFE07A3D);
  const encreSurCuivre = Color(0xFF1A1612);
  const marineNuit = Color(0xFF8BB8C9);
  const ligneNuit = Color(0xFF3A342E);
  const vertNuit = Color(0xFF7BC49A);
  const rougeNuit = Color(0xFFF97066);

  const v1Blue = Color(0xFF2563EB);
  const v1Purple = Color(0xFF6635BB);

  group('ENCRE palette — jour', () {
    final light = appColorsEnum[ThemeModeType.whiteMode]!;

    test('semantic keys match the DA hex table', () {
      expect(light['bg'], papier);
      expect(light['surface'], carte);
      expect(light['surface-raised'], sable);
      expect(light['text'], encre);
      expect(light['text-muted'], cendre);
      expect(light['button-color'], cuivre);
      expect(light['on-button'], onCuivre);
      expect(light['navy'], marine);
      expect(light['border'], ligne);
      expect(light['success'], vertEncre);
      expect(light['danger'], rougeCachet);
      expect(light['popup-background'], carte);
      expect(light['popup-text'], encre);
      expect(light['popup-h1'], encre);
      expect(light['popup-h2'], marine);
      expect(light['shadow'], encre);
    });

    test('does not contain the v1 blue or purple accents', () {
      expect(light.values, isNot(contains(v1Blue)));
      expect(light.values, isNot(contains(v1Purple)));
    });
  });

  group('ENCRE palette — nuit', () {
    final dark = appColorsEnum[ThemeModeType.blackMode]!;

    test('semantic keys match the DA hex table', () {
      expect(dark['bg'], nuit);
      expect(dark['surface'], carteNuit);
      expect(dark['surface-raised'], sableNuit);
      expect(dark['text'], ivoire);
      expect(dark['text-muted'], cendreNuit);
      expect(dark['button-color'], cuivreNuit);
      expect(dark['on-button'], encreSurCuivre);
      expect(dark['navy'], marineNuit);
      expect(dark['border'], ligneNuit);
      expect(dark['success'], vertNuit);
      expect(dark['danger'], rougeNuit);
      expect(dark['popup-background'], carteNuit);
      expect(dark['popup-text'], ivoire);
      expect(dark['popup-h1'], ivoire);
      expect(dark['popup-h2'], marineNuit);
      expect(dark['shadow'], const Color(0xFF000000));
    });

    test('does not contain the v1 blue or purple accents', () {
      expect(dark.values, isNot(contains(v1Blue)));
      expect(dark.values, isNot(contains(v1Purple)));
    });
  });

  group('ENCRE tokens §8', () {
    test('spacing is the 4 dp grid from the DA', () {
      expect(AppTokens.s1, 4);
      expect(AppTokens.s2, 8);
      expect(AppTokens.s3, 12);
      expect(AppTokens.s4, 16);
      expect(AppTokens.s5, 20);
      expect(AppTokens.s6, 24);
      expect(AppTokens.s8, 32);
      expect(AppTokens.s10, 40);
      expect(AppTokens.s12, 48);
    });

    test('radii match chips, inputs, buttons, cards, sheets', () {
      expect(AppTokens.rXs, 6);
      expect(AppTokens.rSm, 10);
      expect(AppTokens.rMd, 14);
      expect(AppTokens.rLg, 18);
      expect(AppTokens.rXl, 24);
    });

    test('tap target, CTA and nav sizes', () {
      expect(AppTokens.tap, 48);
      expect(AppTokens.buttonH, 52);
      expect(AppTokens.navH, 64);
      expect(AppTokens.featuredH, 88);
      expect(AppTokens.hairline, 1);
    });

    test('motion is a stamp, not a bounce', () {
      expect(AppTokens.tMicro, const Duration(milliseconds: 120));
      expect(AppTokens.tFast, const Duration(milliseconds: 200));
      expect(AppTokens.tMed, const Duration(milliseconds: 300));
      expect(AppTokens.tPage, const Duration(milliseconds: 400));
      expect(AppTokens.pressScale, 0.98);
    });
  });

  group('ENCRE typography', () {
    test('UI face is Outfit, display face is Fraunces', () {
      expect(AppFonts.ui, 'Outfit');
      expect(AppFonts.display, 'Fraunces');
    });

    test('text theme assigns Fraunces to heroes and Outfit to UI', () {
      final theme = buildAppTextTheme(
        appColorsEnum[ThemeModeType.whiteMode]!,
      );
      expect(theme.displayLarge?.fontFamily, AppFonts.display);
      expect(theme.headlineLarge?.fontFamily, AppFonts.display);
      expect(theme.titleLarge?.fontFamily, AppFonts.ui);
      expect(theme.bodyLarge?.fontFamily, AppFonts.ui);
      expect(theme.labelLarge?.fontFamily, AppFonts.ui);
      expect(theme.titleLarge?.fontSize, 18);
      expect(theme.titleLarge?.fontWeight, FontWeight.w700);
      expect(theme.displayLarge?.fontSize, 32);
    });
  });

  group('ENCRE ThemeData', () {
    final light = appColorsEnum[ThemeModeType.whiteMode]!;
    final theme = buildAppTheme(colors: light, isDark: false);

    test('primary is copper, not Material blue', () {
      expect(theme.colorScheme.primary, cuivre);
      expect(theme.colorScheme.onPrimary, onCuivre);
      expect(theme.colorScheme.secondary, marine);
      expect(theme.colorScheme.primary, isNot(v1Blue));
    });

    test('scaffold and type use paper + Outfit', () {
      expect(theme.scaffoldBackgroundColor, papier);
      expect(theme.fontFamily, AppFonts.ui);
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.backgroundColor, papier);
    });

    test('CTA theme is 52 dp high with r-md, never a pill', () {
      final style = theme.elevatedButtonTheme.style!;
      expect(
        style.minimumSize!.resolve({}),
        const Size(AppTokens.tap, AppTokens.buttonH),
      );
      final shape = style.shape!.resolve({})! as RoundedRectangleBorder;
      expect(shape.borderRadius, BorderRadius.circular(AppTokens.rMd));
      expect(style.elevation!.resolve({}), 0);
    });

    test('FAB is a squircle, not a circle', () {
      final shape = theme.floatingActionButtonTheme.shape!;
      expect(shape, isA<RoundedRectangleBorder>());
      final r = shape as RoundedRectangleBorder;
      expect(r.borderRadius, BorderRadius.circular(AppTokens.rMd));
      expect(theme.floatingActionButtonTheme.backgroundColor, cuivre);
    });

    test('inputs are filled with r-sm and copper focus', () {
      final input = theme.inputDecorationTheme;
      expect(input.filled, isTrue);
      final enabled = input.enabledBorder! as OutlineInputBorder;
      expect(enabled.borderRadius, BorderRadius.circular(AppTokens.rSm));
      final focused = input.focusedBorder! as OutlineInputBorder;
      expect(focused.borderSide.color, cuivre);
      expect(focused.borderSide.width, 1.5);
    });
  });

  group('paperShadow', () {
    test('rest shadow is two soft layers', () {
      final shadows = paperShadow(encre);
      expect(shadows, hasLength(2));
    });

    test('float shadow is a single deeper layer for the nav', () {
      final shadows = paperShadow(encre, float: true);
      expect(shadows, hasLength(1));
      expect(shadows.first.blurRadius, 24);
    });
  });
}
