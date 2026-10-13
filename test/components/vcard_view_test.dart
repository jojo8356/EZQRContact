import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/vcard_view.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/tools/tools.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

/// 1×1 PNG so the avatar uses MemoryImage instead of a network fetch.
const _tinyPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53, 0xDE, 0x00, 0x00, 0x00,
  0x0C, 0x49, 0x44, 0x41, 0x54, 0x08, 0xD7, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x00, 0x03, 0x00, 0x01, 0x00, 0x05, 0xFE, 0xD4, 0xEF, 0x00, 0x00,
  0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('data:image photo is not listed as a field (avatar only)',
      (tester) async {
    final uri = 'data:image/png;base64,${base64Encode(_tinyPng)}';
    final controllers = mapToControllers({
      'nom': 'Dupont',
      'prenom': 'Marie',
      'photo': uri,
    });
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(body: VCardView(controllers: controllers)),
      ),
    );
    expect(find.textContaining('data:image'), findsNothing);
  });

  testWidgets('http photo URL is shown with ellipsis, not wrapped',
      (tester) async {
    const url =
        'https://files.example.invalid/very/long/path/to/a/hosted/headshot.jpg'
        '?token=abcdefghijklmnopqrstuvwxyz0123456789';
    final controllers = mapToControllers({
      'nom': 'Dupont',
      'prenom': 'Marie',
      'photo': url,
    });
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(body: VCardView(controllers: controllers)),
      ),
    );

    Text? urlText;
    for (final t in tester.widgetList<Text>(find.byType(Text))) {
      if (t.data == url) {
        urlText = t;
        break;
      }
    }
    expect(urlText, isNotNull);
    expect(urlText!.maxLines, 1);
    expect(urlText.overflow, TextOverflow.ellipsis);
  });
}
