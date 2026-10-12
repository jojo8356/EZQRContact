import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/action_tile.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

import '../helpers/encre.dart';

void main() {
  const cuivre = Color(0xFFC45C26);
  const carte = Color(0xFFFFFCF7);

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('featured tile is ≥88 dp with subtitle and chevron — DA §9.4', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: ActionTile(
            featured: true,
            icon: Icons.contact_page_outlined,
            title: 'VCard QR code',
            subtitle: 'Create your business card',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(ActionTile)).height,
      greaterThanOrEqualTo(AppTokens.featuredH),
    );
    expect(find.text('Create your business card'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.contact_page_outlined));
    expect(icon.color, cuivre);
    expect(icon.size, 22);
  });

  testWidgets('compact tile hides subtitle and uses a 40 dp well', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 160,
            child: ActionTile(
              icon: Icons.qr_code_2_rounded,
              title: 'Simple QR',
              subtitle: 'hidden on compact',
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('hidden on compact'), findsNothing);
    expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);

    final icon = tester.widget<Icon>(find.byIcon(Icons.qr_code_2_rounded));
    expect(icon.size, 20);
    expect(icon.color, cuivre);
  });

  testWidgets('tile surface is paper, not a Material elevation card', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: ActionTile(
            featured: true,
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scanner',
            onTap: () {},
          ),
        ),
      ),
    );

    final ink = tester.widget<Ink>(
      find.descendant(
        of: find.byType(ActionTile),
        matching: find.byType(Ink),
      ),
    );
    final deco = ink.decoration! as BoxDecoration;
    expect(deco.color, carte);
    expect(deco.borderRadius, BorderRadius.circular(AppTokens.rLg));
    expect(deco.boxShadow, isNotEmpty);
  });
}
