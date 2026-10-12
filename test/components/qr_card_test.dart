import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:qr_code_app/components/qr_card.dart';
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

  testWidgets('tapping trash removes the card from the list', (tester) async {
    final items = <Map<String, dynamic>>[
      {
        'id': 7,
        'deleted': 0,
        'prenom': 'Marie',
        'nom': 'Dupont',
        'photo': '',
      },
      {
        'id': 8,
        'deleted': 0,
        'prenom': 'Jean',
        'nom': 'Martin',
        'photo': '',
      },
    ];

    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return ListView(
                children: [
                  for (final item in items)
                    QRCard(
                      isVCard: true,
                      data: item,
                      onDelete: (id) async {
                        setState(() {
                          items.removeWhere((row) => row['id'] == id);
                        });
                      },
                      onRefresh: () async {},
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Marie Dupont'), findsOneWidget);
    expect(find.text('Jean Martin'), findsOneWidget);
    expect(find.byType(QRCard), findsNWidgets(2));

    await tester.tap(find.text('Marie Dupont'));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.trash), findsOneWidget);

    await tester.tap(find.byKey(const Key('qr-btn-delete')));
    await tester.pumpAndSettle();

    expect(find.text('Marie Dupont'), findsNothing);
    expect(find.byType(QRCard), findsOneWidget);
    expect(find.text('Jean Martin'), findsOneWidget);
  });
}
