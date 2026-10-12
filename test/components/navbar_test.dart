import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

void main() {
  const cuivre = Color(0xFFC45C26);
  const cendre = Color(0xFF6F675C);
  const carte = Color(0xFFFFFCF7);
  const v1Purple = Color(0xFF6635BB);

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('four tabs, floating paper bar — DA §9.7 / §10', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          bottomNavigationBar: Navbar(currentRoute: '/options'),
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    final boxes = tester.widgetList<DecoratedBox>(
      find.descendant(
        of: find.byType(Navbar),
        matching: find.byType(DecoratedBox),
      ),
    );
    final deco = boxes
        .map((box) => box.decoration)
        .whereType<BoxDecoration>()
        .firstWhere((d) => d.color == carte);
    expect(deco.borderRadius, BorderRadius.circular(AppTokens.rLg));
    expect(deco.boxShadow, isNotEmpty);
    expect(deco.color, isNot(v1Purple));

    final sized = tester.widgetList<SizedBox>(
      find.descendant(
        of: find.byType(Navbar),
        matching: find.byType(SizedBox),
      ),
    );
    expect(sized.any((box) => box.height == AppTokens.navH), isTrue);
  });

  testWidgets('active tab is copper filled, rest is cendre outlined', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          bottomNavigationBar: Navbar(currentRoute: '/options'),
        ),
      ),
    );

    final home = tester.widget<Icon>(find.byIcon(Icons.home_rounded));
    expect(home.color, cuivre);
    expect(home.size, 24);

    final collection = tester.widget<Icon>(find.byIcon(Icons.style_outlined));
    expect(collection.color, cendre);

    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });
}
