import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_code_app/components/qr_options.dart';
import 'package:qr_code_app/providers/lang_provider.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/encre.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LangProvider.init(lang: 'en');
  });

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('collapsed row does not fire delete on a trash tap', (
    tester,
  ) async {
    final deleted = <int>[];
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: OptionsQR(
            isVCard: false,
            data: const {'id': 7, 'deleted': 0},
            expanded: false,
            onRefresh: () async {},
            onDelete: (id) async {
              deleted.add(id);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // AnimatedCrossFade keeps the fading child in the tree behind
    // IgnorePointer; a tap must not reach onDelete.
    await tester.tap(
      find.byKey(const Key('qr-btn-delete'), skipOffstage: false),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(deleted, isEmpty);
  });

  testWidgets('tapping trash calls onDelete with the row id then onRefresh', (
    tester,
  ) async {
    final deleted = <int>[];
    var refreshCount = 0;

    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: OptionsQR(
            isVCard: false,
            data: const {'id': 7, 'deleted': 0},
            expanded: true,
            onRefresh: () async {
              refreshCount += 1;
            },
            onDelete: (id) async {
              deleted.add(id);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.trash), findsOneWidget);

    await tester.tap(find.byKey(const Key('qr-btn-delete')));
    await tester.pump();
    await tester.pump();

    expect(deleted, equals([7]));
    expect(refreshCount, 1);
  });

  testWidgets('soft-deleted rows do not show a trash button', (tester) async {
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: OptionsQR(
            isVCard: false,
            data: const {'id': 7, 'deleted': 1},
            expanded: true,
            onRefresh: () async {},
            onDelete: (_) async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.trash), findsNothing);
    expect(find.byKey(const Key('qr-btn-delete')), findsNothing);
  });

  testWidgets('string ids are parsed so the trash tap still fires', (
    tester,
  ) async {
    final deleted = <int>[];

    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: OptionsQR(
            isVCard: true,
            data: const {'id': '42', 'deleted': 0},
            expanded: true,
            onRefresh: () async {},
            onDelete: (id) async {
              deleted.add(id);
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(LucideIcons.trash));
    await tester.pump();
    await tester.pump();

    expect(deleted, equals([42]));
  });
}
