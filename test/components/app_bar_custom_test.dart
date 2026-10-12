import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/app_bar_custom.dart';
import 'package:qr_code_app/components/qr_mark.dart';
import 'package:qr_code_app/components/section_label.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

import '../helpers/encre.dart';

void main() {
  const papier = Color(0xFFF4EFE6);
  const encre = Color(0xFF1A1612);
  const ligne = Color(0xFFDDD4C6);
  const marine = Color(0xFF1F3D4D);

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('app bar is flat paper with a 1 dp hairline — DA §9.6', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(appBar: AppBarCustom('Options')),
      ),
    );

    final bar = tester.widget<AppBar>(find.byType(AppBar));
    expect(bar.elevation, 0);
    expect(bar.scrolledUnderElevation, 0);
    expect(bar.backgroundColor, papier);

    final title = tester.widget<Text>(find.text('Options'));
    expect(title.style?.color, encre);
    expect(title.style?.fontFamily, 'Outfit');

    final hairlineFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.byType(Container),
    );
    expect(tester.getSize(hairlineFinder).height, AppTokens.hairline);
    final hairline = tester.widget<Container>(hairlineFinder);
    expect(hairline.color, ligne);
  });

  testWidgets('wordmark is EZQR Outfit + Contact Fraunces + copper mark', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          appBar: AppBarCustom('', titleWidget: EzqrWordmark()),
        ),
      ),
    );

    expect(find.text('EZQR'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.byType(QrMark), findsOneWidget);

    final contact = tester.widget<Text>(find.text('Contact'));
    expect(contact.style?.fontFamily, 'Fraunces');
    expect(contact.style?.fontStyle, FontStyle.italic);
    expect(contact.style?.color, marine);
  });

  testWidgets('QrMark defaults to 22 dp copper', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(body: QrMark()),
      ),
    );
    expect(tester.getSize(find.byType(QrMark)), const Size(22, 22));
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(QrMark),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(paint.painter, isNotNull);
  });

  testWidgets('section label uses navy titleSmall', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(body: SectionLabel('Appearance')),
      ),
    );
    final text = tester.widget<Text>(find.text('Appearance'));
    expect(text.style?.color, marine);
    expect(text.style?.fontFamily, 'Outfit');
  });
}
