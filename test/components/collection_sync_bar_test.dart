import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/collection_sync_bar.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('shows Import all and Export all buttons', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: CollectionSyncBar(
            onImport: () {},
            onExport: () {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('collection-import-all')), findsOneWidget);
    expect(find.byKey(const Key('collection-export-all')), findsOneWidget);
    expect(find.text('Import all'), findsOneWidget);
    expect(find.text('Export all'), findsOneWidget);
  });

  testWidgets('tapping Import all fires onImport', (tester) async {
    var imported = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: CollectionSyncBar(
            onImport: () {
              imported = true;
            },
            onExport: () {},
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('collection-import-all')));
    await tester.pump();
    expect(imported, isTrue);
  });

  testWidgets('tapping Export all fires onExport', (tester) async {
    var exported = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: CollectionSyncBar(
            onImport: () {},
            onExport: () {
              exported = true;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const Key('collection-export-all')));
    await tester.pump();
    expect(exported, isTrue);
  });
}
