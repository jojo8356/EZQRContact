import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_code_app/components/app_button.dart';
import 'package:qr_code_app/components/empty_state.dart';
import 'package:qr_code_app/providers/theme_globals.dart';
import 'package:qr_code_app/theme/tokens.dart';

import '../helpers/encre.dart';

void main() {
  const sable = Color(0xFFEBE4D8);
  const cendre = Color(0xFF6F675C);

  setUp(() => darkProv.forceSetDarkMode(false));
  tearDown(() => darkProv.forceSetDarkMode(false));

  testWidgets('icon well is 72×72 sable, max width 280 — DA §9.14', (
    tester,
  ) async {
    await tester.pumpWidget(
      encreApp(
        home: const Scaffold(
          body: EmptyState(
            icon: Icons.history_rounded,
            title: 'Aucune carte',
            body: 'Scannez-en une.',
          ),
        ),
      ),
    );

    final wellFinder = find.descendant(
      of: find.byType(EmptyState),
      matching: find.byType(Container),
    );
    expect(tester.getSize(wellFinder), const Size(72, 72));
    final well = tester.widget<Container>(wellFinder);
    final deco = well.decoration! as BoxDecoration;
    expect(deco.color, sable);
    expect(deco.borderRadius, BorderRadius.circular(AppTokens.rLg));

    final icon = tester.widget<Icon>(find.byIcon(Icons.history_rounded));
    expect(icon.size, 32);
    expect(icon.color, cendre);

    final maxBoxes = tester.widgetList<ConstrainedBox>(
      find.descendant(
        of: find.byType(EmptyState),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(
      maxBoxes.any((box) => box.constraints.maxWidth == 280),
      isTrue,
    );

    expect(find.byType(AppButton), findsNothing);
  });

  testWidgets('optional CTA is a secondary AppButton', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      encreApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.style_outlined,
            title: 'Collection vide',
            actionLabel: 'Scanner',
            onAction: () => pressed = true,
          ),
        ),
      ),
    );

    final btn = tester.widget<AppButton>(find.byType(AppButton));
    expect(btn.variant, AppButtonVariant.secondary);
    await tester.tap(find.byType(AppButton));
    expect(pressed, isTrue);
  });
}
