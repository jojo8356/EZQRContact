// Live device test: launches the real app, taps Collection, expands a
// seeded card, taps the Lucide trash, and asserts the row is gone.
//
//   flutter test integration_test/trash_delete_test.dart
//   ./scripts/test_trash.sh                 # first connected device
//   ./scripts/test_trash.sh <device-id>
//
// Uses the production [deleteQR] path (no onDelete inject). Seeds a
// uniquely named vCard so we do not delete the user's own contacts.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:qr_code_app/components/qr_card.dart';
import 'package:qr_code_app/data/db/database.dart';
import 'package:qr_code_app/main.dart' as app;
import 'package:qr_code_app/pages/qr_card_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _title = 'ezqr-it-trash-target';

Future<void> _skipFirstRunGates() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);
  await prefs.setInt('guideShown', 1);
}

Future<void> _seedTarget() async {
  final db = QRDatabase();
  final existing = await db.getAllSimpleQR();
  for (final row in existing) {
    if (row['text'] == _title) {
      await db.deleteSimpleQR(row['id'] as int);
    }
  }
  // Newest SimpleQR is first in Collection, so the row is on screen
  // without scrolling past the user's own cards.
  await db.insertSimpleQR(_title, null);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'tapping trash on a live card removes it from Collection',
    (tester) async {
      await _skipFirstRunGates();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await _seedTarget();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.style_outlined));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(Collection), findsOneWidget);

      final name = find.text(_title);
      await tester.scrollUntilVisible(name, 200);
      expect(name, findsOneWidget);

      await tester.tap(name);
      await tester.pumpAndSettle();

      final card = find.ancestor(
        of: name,
        matching: find.byType(QRCard),
      );
      final trash = find.descendant(
        of: card,
        matching: find.byKey(const Key('qr-btn-delete')),
      );
      expect(trash, findsOneWidget);
      await tester.tap(trash);
      await tester.pumpAndSettle();

      expect(find.text(_title), findsNothing);
      expect(find.byType(Collection), findsOneWidget);
    },
  );
}
