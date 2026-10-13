import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/action_tile.dart';
import 'package:qr_code_app/components/navbar.dart';
import 'package:qr_code_app/components/qr_mark.dart';
import 'package:qr_code_app/pages/actions_list_page.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'guideShown': 1,
      'coach_tour_done': true,
    });
    await LangProvider.init(lang: 'en');
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('home is ENCRE: wordmark, tagline, tiles, floating nav', (
    tester,
  ) async {
    await tester.pumpWidget(encreApp(home: const OptionsListPage()));
    await tester.pump();

    expect(find.text('EZQR'), findsOneWidget);
    expect(find.text('Contact'), findsOneWidget);
    expect(find.byType(QrMark), findsOneWidget);
    expect(find.text('Exchange. No cloud.'), findsOneWidget);
    expect(find.text('Your cards stay on this phone.'), findsOneWidget);

    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Also'), findsNothing);
    expect(find.byType(ActionTile), findsNWidgets(5));
    expect(find.byIcon(Icons.contact_page_outlined), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsOneWidget);

    expect(find.byType(Navbar), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('scaffold sits on papier, not stark white', (tester) async {
    await tester.pumpWidget(encreApp(home: const OptionsListPage()));
    await tester.pump();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(scaffold.backgroundColor, const Color(0xFFF4EFE6));
  });
}
