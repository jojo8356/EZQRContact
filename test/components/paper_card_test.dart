import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/paper_card.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

import '../helpers/encre.dart';

void main() {
  const carte = Color(0xFFFFFCF7);
  const ligne = Color(0xFFDDD4C6);

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('paper card is surface + hairline + r-lg — DA §9.5', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          body: PaperCard(child: Text('Marie Dupont')),
        ),
      ),
    );

    final deco = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
    final box = deco.decoration as BoxDecoration;
    expect(box.color, carte);
    expect(box.borderRadius, BorderRadius.circular(AppTokens.rLg));
    expect(box.border?.top.color, ligne);
    expect(box.boxShadow, isNotEmpty);
    expect(find.text('Marie Dupont'), findsOneWidget);
  });

  testWidgets('optional onTap wraps the body in an InkWell', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: PaperCard(
            onTap: () => tapped = true,
            child: const Text('tap me'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('tap me'));
    expect(tapped, isTrue);
    expect(find.byType(InkWell), findsOneWidget);
  });
}
