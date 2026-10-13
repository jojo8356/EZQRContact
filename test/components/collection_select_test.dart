import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/collection_select_bar.dart';
import 'package:qr_code_app/components/qr_card.dart';
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

  test('vcard and simple ids do not share a select key', () {
    expect(collectionItemKey(isVCard: true, id: 1), 'vcard:1');
    expect(collectionItemKey(isVCard: false, id: 1), 'simple:1');
    expect(
      collectionItemKey(isVCard: true, id: 1),
      isNot(collectionItemKey(isVCard: false, id: 1)),
    );
    expect(collectionSelectHold, const Duration(seconds: 2));
  });

  testWidgets('hold under 2s does not enter select', (tester) async {
    var held = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: QRCard(
            data: const {'id': 1, 'text': 'hello'},
            isVCard: false,
            onRefresh: () async {},
            onHoldSelect: () {
              held = true;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('hello')),
    );
    await tester.pump(const Duration(milliseconds: 1900));
    expect(held, isFalse);
    await gesture.up();
    await tester.pump();
    expect(held, isFalse);
  });

  testWidgets('2s hold selects the card and release does not uncheck it', (
    tester,
  ) async {
    var selectMode = false;
    final selected = <String>{};

    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return QRCard(
                data: const {'id': 1, 'text': 'hello'},
                isVCard: false,
                onRefresh: () async {},
                selectMode: selectMode,
                selected: selected.contains('simple:1'),
                onHoldSelect: () {
                  setState(() {
                    selectMode = true;
                    selected.add('simple:1');
                  });
                },
                onToggleSelect: () {
                  setState(() {
                    if (selected.contains('simple:1')) {
                      selected.remove('simple:1');
                    } else {
                      selected.add('simple:1');
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('hello')),
    );
    await tester.pump(const Duration(seconds: 2));
    expect(selectMode, isTrue);
    expect(selected, {'simple:1'});
    await gesture.up();
    await tester.pump();
    expect(selected, {'simple:1'});
    expect(find.byKey(const Key('qr-card-checkbox')), findsOneWidget);
  });

  testWidgets('tap in select mode toggles the checkbox', (tester) async {
    final selected = <String>{'simple:1'};
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return QRCard(
                data: const {'id': 1, 'text': 'hello'},
                isVCard: false,
                onRefresh: () async {},
                selectMode: true,
                selected: selected.contains('simple:1'),
                onToggleSelect: () {
                  setState(() {
                    if (selected.contains('simple:1')) {
                      selected.remove('simple:1');
                    } else {
                      selected.add('simple:1');
                    }
                  });
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);

    await tester.tap(find.text('hello'));
    await tester.pump();
    expect(selected, isEmpty);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
  });

  testWidgets('select bar exposes cancel, select-all, delete, export', (
    tester,
  ) async {
    var cancelled = false;
    var selectAll = false;
    var deleted = false;
    var exported = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: CollectionSelectBar(
            count: 2,
            onCancel: () {
              cancelled = true;
            },
            onSelectAll: () {
              selectAll = true;
            },
            onDelete: () {
              deleted = true;
            },
            onExport: () {
              exported = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('2 selected'), findsOneWidget);
    expect(find.byKey(const Key('collection-select-cancel')), findsOneWidget);
    expect(find.byKey(const Key('collection-select-all')), findsOneWidget);
    expect(find.byKey(const Key('collection-select-delete')), findsOneWidget);
    expect(find.byKey(const Key('collection-select-export')), findsOneWidget);

    await tester.tap(find.byKey(const Key('collection-select-cancel')));
    await tester.pump();
    expect(cancelled, isTrue);

    await tester.tap(find.byKey(const Key('collection-select-all')));
    await tester.pump();
    expect(selectAll, isTrue);

    await tester.tap(find.byKey(const Key('collection-select-delete')));
    await tester.pump();
    expect(deleted, isTrue);

    await tester.tap(find.byKey(const Key('collection-select-export')));
    await tester.pump();
    expect(exported, isTrue);
  });

  testWidgets('select bar disables delete and export at count 0', (
    tester,
  ) async {
    var deleted = false;
    var exported = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: CollectionSelectBar(
            count: 0,
            onCancel: () {},
            onSelectAll: () {},
            onDelete: () {
              deleted = true;
            },
            onExport: () {
              exported = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('collection-select-delete')));
    await tester.tap(find.byKey(const Key('collection-select-export')));
    await tester.pump();
    expect(deleted, isFalse);
    expect(exported, isFalse);
  });
}
